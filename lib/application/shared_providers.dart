// shared_providers.dart
// File này export tất cả convenience providers để các module import 1 chỗ

// --- Auth (từ Module 0) ---
export 'auth/auth_provider.dart' show
    currentUserProvider,
    isAdminProvider,
    authStatusProvider;

// --- Wallet ---
export 'wallet/wallet_provider.dart' show
    currentBalanceProvider,
    availableBalanceProvider,
    isBrokeProvider,
    lockedAmountProvider;

// --- Matches ---
export 'matches/match_provider.dart' show
    scheduledMatchesProvider,
    liveMatchesProvider,
    selectedMatchProvider;

// --- Bets ---
export 'bets/bet_provider.dart' show
    pendingBetsProvider,
    pendingBetsCountProvider,
    currentDraftProvider;

// --- Anti Gambling ---
export 'anti_gambling/anti_gambling_provider.dart' show
    showLoanTrapProvider,
    showWarningOverlayProvider;
