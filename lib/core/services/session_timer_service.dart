import 'dart:async';
import 'dart:math';
import '../../domain/enums/session_status.dart';
import '../../domain/models/betting_session_model.dart';
import '../../data/firebase/betting_session_service.dart';

// Service quản lý vòng đời 60 giây của phiên cược Tài Xỉu
class SessionTimerService {
  final BettingSessionService _sessionService;

  static const int sessionDuration = 60;
  static const int lockThreshold = 10;

  StreamSubscription? _sessionSubscription;
  Timer? _ticker;
  BettingSessionModel? _activeSession;

  final _countdownController = StreamController<int>.broadcast();
  final _statusController = StreamController<SessionStatus>.broadcast();

  SessionTimerService(this._sessionService);

  // Khởi động timer service — lắng nghe Firestore và quản lý đếm ngược
  Future<void> start() async {
    stop();

    _sessionSubscription = _sessionService.watchActiveSession().listen((session) async {
      if (session == null) {
        // Nếu không có phiên nào active, gọi tạo phiên mới
        try {
          await _sessionService.createSession();
        } catch (e) {
          // Bỏ qua lỗi race condition do client khác tạo phiên trước
        }
        return;
      }

      final isNewSession = _activeSession == null || _activeSession!.sessionId != session.sessionId;
      _activeSession = session;

      // Chỉ khởi động lại ticker mới nếu đổi phiên cược
      if (isNewSession) {
        _startTicker();
      }
    });
  }

  // Dừng timer — gọi khi app vào background hoặc bị dispose
  void stop() {
    _ticker?.cancel();
    _sessionSubscription?.cancel();
    _activeSession = null;
  }

  // Stream countdown giây còn lại (60 → 0)
  Stream<int> get countdown => _countdownController.stream;

  // Stream trạng thái của phiên hiện tại
  Stream<SessionStatus> get sessionStatus => _statusController.stream;

  // Bắt đầu đếm ngược cho phiên hiện tại
  void _startTicker() {
    _ticker?.cancel();

    final session = _activeSession;
    if (session == null) return;

    // Phát tán giá trị ban đầu ngay lập tức
    final elapsedInit = DateTime.now().difference(session.startedAt).inSeconds;
    final remainingInit = (sessionDuration - elapsedInit).clamp(0, sessionDuration);
    _countdownController.add(remainingInit);
    _statusController.add(session.status);

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final currentSession = _activeSession;
      if (currentSession == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final elapsed = now.difference(currentSession.startedAt).inSeconds;
      final remaining = (sessionDuration - elapsed).clamp(0, sessionDuration);

      _countdownController.add(remaining);

      // Khoá cược khi còn 10 giây
      if (remaining <= lockThreshold && currentSession.status == SessionStatus.open) {
        _statusController.add(SessionStatus.locked);
        try {
          await _sessionService.updateSessionStatus(currentSession.sessionId, SessionStatus.locked);
        } catch (_) {}
      }

      // Kết toán khi hết giờ
      if (remaining <= 0) {
        timer.cancel();
        _statusController.add(SessionStatus.settled);

        try {
          final randomResult = Random().nextBool() ? 'over' : 'under';
          await _sessionService.settleSession(
            sessionId: currentSession.sessionId,
            result: randomResult,
            isAdminOverride: false,
          );
        } catch (e) {
          // Log lỗi kết toán nhưng vẫn cho phép tiếp tục tạo phiên mới
        }
        
        try {
          // Khởi tạo hoặc lấy phiên mới tiếp theo
          await _sessionService.createSession();
        } catch (_) {}
      } else {
        if (remaining > lockThreshold) {
          _statusController.add(currentSession.status);
        } else {
          _statusController.add(SessionStatus.locked);
        }
      }
    });
  }
}
