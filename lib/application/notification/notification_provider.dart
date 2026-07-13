import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firebase_messaging_service.dart';
import '../../data/firebase/firestore_service.dart';
import '../auth/auth_provider.dart';
import '../wallet/wallet_provider.dart';
import 'notification_state.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final authState = ref.watch(authProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  final notifier = NotificationNotifier(
    firestoreService,
    authState.user?.uid,
  );

  // Note: we can't do async init in constructor easily, so we call it here 
  // or rely on a specific init method on startup.
  // The provider will self-initialize when first accessed.
  return notifier;
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final FirestoreService _firestoreService;
  final String? _uid;
  StreamSubscription<String>? _tokenRefreshSub;

  NotificationNotifier(this._firestoreService, this._uid)
      : super(const NotificationState()) {
    if (_uid != null) {
      _initFCM();
    }
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
  }

  Future<void> _initFCM() async {
    if (_uid == null) return;

    state = state.copyWith(isLoading: true);

    try {
      // 1. Get current token
      final token = await FirebaseMessagingService.getToken();
      if (token != null) {
        print('\n======================================================');
        print('🔥 YOUR FCM TOKEN IS:');
        print(token);
        print('======================================================\n');
        await _saveTokenToFirestore(token);
        state = state.copyWith(fcmToken: token, isPermissionGranted: true);
      }

      // 2. Listen to token refresh
      _tokenRefreshSub = FirebaseMessagingService.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken);
        state = state.copyWith(fcmToken: newToken);
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to initialize FCM: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    if (_uid == null) return;
    try {
      await _firestoreService.updateFcmToken(_uid, token);
    } catch (e) {
      // Handle error quietly
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settingsJson) async {
    if (_uid == null) return;
    try {
      await _firestoreService.updateNotificationSettings(_uid, settingsJson);
    } catch (e) {
      print('Failed to update notification settings: $e');
    }
  }
}
