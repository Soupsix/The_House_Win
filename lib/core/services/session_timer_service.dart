import 'dart:async';
import 'dart:math';
import '../../domain/enums/session_status.dart';
import '../../domain/models/betting_session_model.dart';
import '../../domain/models/game_session_config.dart';
import '../../data/firebase/betting_session_service.dart';

// Service quản lý vòng đời của các phiên cược theo cấu hình
class SessionTimerService {
  final BettingSessionService _sessionService;
  final GameSessionConfig config;

  static const int lockThreshold = 10; // Giữ nguyên khóa 10 giây trước khi hết giờ (khi openDuration > 0)

  StreamSubscription? _sessionSubscription;
  Timer? _ticker;
  Timer? _cooldownTimer;
  BettingSessionModel? _activeSession;

  final _countdownController = StreamController<int>.broadcast();
  final _statusController = StreamController<SessionStatus>.broadcast();

  SessionTimerService(this._sessionService, this.config);

  // Khởi động timer service — lắng nghe Firestore và quản lý đếm ngược
  Future<void> start() async {
    stop();

    _sessionSubscription = _sessionService.watchActiveSession().listen((session) async {
      if (session == null) {
        // Phiên vừa kết toán (hoặc chưa có phiên nào): tính thời gian chờ và tạo phiên mới
        _scheduleNextSession();
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
    _cooldownTimer?.cancel();
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
    final sessionDurationSeconds = config.openDuration.inSeconds;
    final remainingInit = (sessionDurationSeconds - elapsedInit).clamp(0, sessionDurationSeconds);
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
      final remaining = (sessionDurationSeconds - elapsed).clamp(0, sessionDurationSeconds);

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
          // Tung 3 xúc xắc ngẫu nhiên (1-6)
          final d1 = Random().nextInt(6) + 1;
          final d2 = Random().nextInt(6) + 1;
          final d3 = Random().nextInt(6) + 1;
          final total = d1 + d2 + d3;
          // Tổng >= 11 → Tài (over), tổng <= 10 → Xỉu (under)
          final randomResult = total >= 11 ? 'over' : 'under';

          await _sessionService.settleSession(
            sessionId: currentSession.sessionId,
            result: randomResult,
            isAdminOverride: false,
            dice1: d1,
            dice2: d2,
            dice3: d3,
          );
        } catch (e) {
          // Log lỗi kết toán nhưng vẫn cho phép tiếp tục tạo phiên mới
        }
        
        // Sau khi kết toán, đợi đủ 12 giây (tính từ lúc kết toán) rồi mới tạo phiên mới
        // watchActiveSession() sẽ nhận null và gọi _scheduleNextSession()

      } else {
        if (remaining > lockThreshold) {
          _statusController.add(currentSession.status);
        } else {
          _statusController.add(SessionStatus.locked);
        }
      }
    });
  }

  // Tính thời gian cooldown còn lại và lên lịch tạo phiên mới
  void _scheduleNextSession() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    _doScheduleNextSession();
  }

  Future<void> _doScheduleNextSession() async {
    int delayMs = 0;

    try {
      final latest = await _sessionService.getLatestSession();
      if (latest != null && latest.status == SessionStatus.settled && latest.settledAt != null) {
        final elapsed = DateTime.now().difference(latest.settledAt!).inMilliseconds;
        final cooldownMs = config.lockBuffer.inMilliseconds;
        final remaining = cooldownMs - elapsed;
        if (remaining > 0) {
          delayMs = remaining;
        }
      }
    } catch (_) {
      // Nếu không lấy được phiên, tạo ngay không trễ
    }

    _cooldownTimer = Timer(Duration(milliseconds: delayMs), () async {
      try {
        await _sessionService.createSession();
      } catch (_) {
        // Bỏ qua lỗi race condition do client khác tạo phiên trước
      }
    });
  }
}
