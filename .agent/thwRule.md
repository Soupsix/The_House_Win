# THE HOUSE WINS — Project Rules for AI Agents

> Đọc file này trước khi làm bất kỳ task nào.
> Áp dụng cho toàn bộ thành viên và AI agent làm việc trên project.

---

## 1. Kiến trúc tổng quan

Project tuân theo **Clean Architecture** kết hợp **Riverpod StateNotifier**.
Có 5 tầng, mỗi tầng có nhiệm vụ riêng biệt — KHÔNG được trộn lẫn logic giữa các tầng.

```
lib/
├── domain/         # Nghiệp vụ cốt lõi — KHÔNG phụ thuộc bất kỳ tầng nào khác
├── data/           # Giao tiếp Firebase/API — chỉ phụ thuộc domain
├── application/    # State management Riverpod — chỉ phụ thuộc data + domain
├── presentation/   # UI Flutter — chỉ phụ thuộc application
└── core/           # Hạ tầng dùng chung — router, theme, services
```

### Nguyên tắc phụ thuộc (Dependency Rule)
```
presentation → application → data → domain
                                  ↑
                              core (dùng chung, không phụ thuộc tầng khác)
```

---

## 2. Quy tắc từng tầng

### 2.1 Domain — `lib/domain/`

- Chứa: `models/`, `enums/`, `repositories/` (interface)
- **KHÔNG** import bất kỳ package Flutter/Firebase nào
- **KHÔNG** chứa logic xử lý — chỉ định nghĩa cấu trúc dữ liệu và interface
- Mọi model phải dùng `@freezed` annotation

```dart
// ✅ ĐÚNG — domain/models/user_model.dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    // ...
  }) = _UserModel;

  // Factory từ Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) { ... }
}

// ❌ SAI — KHÔNG gọi FirebaseAuth trực tiếp trong domain
import 'package:firebase_auth/firebase_auth.dart'; // CẤM trong domain/
```

### 2.2 Data — `lib/data/`

- Chứa: `firebase/` (service gọi SDK trực tiếp), `repositories/` (implement interface từ domain)
- **KHÔNG** chứa Riverpod provider
- **KHÔNG** import từ `presentation/` hoặc `application/`
- Mỗi service chỉ làm 1 nhiệm vụ (AuthFirebaseService chỉ lo Auth, FirestoreService chỉ lo Firestore)

```dart
// ✅ ĐÚNG — data/firebase/auth_firebase_service.dart
class AuthFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng ký tài khoản mới bằng email và password
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

// ❌ SAI — KHÔNG để Riverpod provider trong data layer
final authServiceProvider = Provider((ref) => AuthFirebaseService()); // CẤM ở đây
```

### 2.3 Application — `lib/application/`

- Chứa: `*_state.dart`, `*_notifier.dart`, `*_provider.dart` theo từng feature
- Mỗi feature có đúng 3 file này, KHÔNG thêm file khác
- StateNotifier chỉ gọi Repository — KHÔNG gọi Firebase SDK trực tiếp
- Provider được khai báo trong `*_provider.dart` — KHÔNG khai báo trong file khác

```dart
// ✅ ĐÚNG — application/auth/auth_notifier.dart
class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  // Đăng nhập bằng email và password, cập nhật state tương ứng
  Future<void> signIn(String email, String password) async {
    // Báo UI đang xử lý
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signIn(email, password);
      // Cập nhật state khi đăng nhập thành công
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isAdmin: user.isAdmin,
        isLoading: false,
      );
    } catch (e) {
      // Map lỗi Firebase sang thông báo tiếng Việt
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapErrorMessage(e),
      );
    }
  }
}

// ❌ SAI — KHÔNG gọi Firebase SDK trực tiếp trong Notifier
final credential = await FirebaseAuth.instance.signIn(...); // CẤM
```

### 2.4 Presentation — `lib/presentation/`

- Chứa: các màn hình và widget, chia theo feature folder
- Widget chỉ dùng `ref.watch()` để đọc state, `ref.read().notifier` để gọi action
- **KHÔNG** chứa business logic — logic phải nằm ở Notifier
- **KHÔNG** gọi Firebase SDK trực tiếp
- **KHÔNG** gọi `context.go()` sau đăng nhập/đăng xuất — để GoRouter tự xử lý

```dart
// ✅ ĐÚNG — presentation/auth/login_screen.dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đọc state để phản ứng UI
    final authState = ref.watch(authProvider);

    return ElevatedButton(
      // Gọi action qua notifier — không xử lý logic ở đây
      onPressed: () => ref.read(authProvider.notifier).signIn(email, password),
      child: authState.isLoading
          ? CircularProgressIndicator()
          : Text('Đăng nhập'),
    );
  }
}

// ❌ SAI — KHÔNG để logic trong widget
onPressed: () async {
  final credential = await FirebaseAuth.instance.signIn(...); // CẤM
  if (credential != null) context.go('/home');               // CẤM
}
```

### 2.5 Core — `lib/core/`

- Chứa: `router/`, `theme/`, `services/`, `splash_screen.dart`
- `router/` chỉ chứa 2 file: `app_router.dart` và `app_routes.dart`
- `theme/` chỉ chứa: `app_theme.dart`, `app_colors.dart`, `app_text_styles.dart`
- **KHÔNG** tạo thêm file/folder trong core nếu không có sự đồng ý của team lead

---

## 3. Quy tắc comment

**Mọi hàm public đều phải có comment `//` giải thích ngắn gọn.**
Comment viết bằng tiếng Việt, đặt ngay trên dòng khai báo hàm.

```dart
// ✅ ĐÚNG
// Khởi tạo ví ảo với số dư mặc định 1.000.000 VNĐ khi user đăng ký
Future<void> createWalletDocument(String uid) async { ... }

// Tính xác suất ngầm định (implied probability) từ tỷ lệ kèo
double calculateImpliedProbability(double odds) => 1 / odds;

// Kiểm tra ngưỡng cháy túi — trigger anti-gambling nếu dưới 10% vốn ban đầu
void checkBrokeThreshold(double balance) { ... }

// ❌ SAI — không có comment
Future<void> createWalletDocument(String uid) async { ... }

// ❌ SAI — comment quá chung chung
// Hàm tạo ví
Future<void> createWalletDocument(String uid) async { ... }
```

Comment TRONG hàm: chỉ comment những đoạn logic phức tạp hoặc không rõ ràng.

```dart
Future<void> signIn(String email, String password) async {
  state = state.copyWith(isLoading: true);
  try {
    final user = await _repository.signIn(email, password);
    // Đọc thêm isAdmin từ Firestore vì Firebase Auth không lưu field này
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      isAdmin: user.isAdmin,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(isLoading: false, errorMessage: _mapErrorMessage(e));
  }
}
```

---

## 4. Quy tắc cấu trúc file

### KHÔNG tạo thêm file/folder nếu không cần thiết

Trước khi tạo file mới, kiểm tra:
1. File này có thể gộp vào file đã có không?
2. Logic này có thể đặt trong Notifier đã có không?
3. Widget này có dùng ở nhiều chỗ không? Nếu chỉ dùng 1 chỗ → để trong cùng file screen

```
// ✅ ĐÚNG — widget nhỏ chỉ dùng ở 1 màn hình thì để chung file
// presentation/betting/bet_screen.dart
class BetScreen extends ConsumerWidget { ... }
class _AmountInputSection extends StatelessWidget { ... }  // widget con, cùng file

// ❌ SAI — tách ra file riêng khi không cần thiết
// presentation/betting/widgets/amount_input_section.dart  ← KHÔNG tạo nếu chỉ dùng 1 chỗ
```

### Cấu trúc file trong application/ — đúng 3 file mỗi feature

```
application/
  auth/
    auth_state.dart      ← @freezed class AuthState
    auth_notifier.dart   ← class AuthNotifier extends StateNotifier<AuthState>
    auth_provider.dart   ← final authProvider = ...
```

---

## 5. Quy tắc Firestore

- Mọi read/write Firestore phải đi qua `FirestoreService` — KHÔNG gọi `FirebaseFirestore.instance` trực tiếp ở nơi khác
- Dùng `FieldValue.serverTimestamp()` cho mọi field timestamp — KHÔNG dùng `DateTime.now()`
- Document ID luôn là Firebase Auth `uid` của user — KHÔNG tự sinh ID

```dart
// ✅ ĐÚNG
await _firestore.collection('wallets').doc(uid).set({
  'balance': 1000000,
  'createdAt': FieldValue.serverTimestamp(), // server time
});

// ❌ SAI
await FirebaseFirestore.instance.collection('wallets').add({ // KHÔNG dùng .add() sinh ID tự động
  'createdAt': DateTime.now(),                               // KHÔNG dùng client time
});
```

### Collections đã định nghĩa — KHÔNG tạo collection mới

```
users/          → thông tin user (uid, email, displayName, isAdmin)
wallets/        → ví ảo (balance, lockedAmount, isBroke)
matches/        → trận đấu (thật + giả lập)
bets/           → lịch sử đặt cược
transactions/   → lịch sử giao dịch ví
simulations/    → kết quả mô phỏng Monte Carlo
admin_logs/     → log hành động của Admin
```

---

## 6. Quy tắc GoRouter

- Mọi route path phải khai báo trong `app_routes.dart` dạng constant — KHÔNG hardcode string path
- KHÔNG gọi `context.go()` hoặc `context.push()` sau đăng nhập/đăng xuất — GoRouter tự redirect theo AuthState
- Để thêm màn hình mới cần bảo vệ: chỉ cần thêm route vào `app_router.dart`, redirect guard tự xử lý

```dart
// ✅ ĐÚNG — dùng constant từ app_routes.dart
context.go(AppRoutes.home);

// ❌ SAI — hardcode string
context.go('/home');

// ✅ ĐÚNG — sau đăng xuất KHÔNG cần navigate
ref.read(authProvider.notifier).signOut();
// GoRouter tự redirect về /login

// ❌ SAI
await ref.read(authProvider.notifier).signOut();
context.go('/login'); // KHÔNG cần dòng này
```

---

## 7. Quy tắc Provider

- Provider tiện ích (convenience providers) khai báo trong `auth_provider.dart`, KHÔNG tạo file riêng
- Các module khác đọc uid/isAdmin qua convenience providers — KHÔNG watch toàn bộ authProvider

```dart
// ✅ ĐÚNG — dùng convenience provider, chỉ rebuild khi uid thay đổi
final uid = ref.watch(currentUserProvider)?.uid;

// ❌ SAI — watch cả authProvider chỉ để lấy uid, rebuild không cần thiết
final uid = ref.watch(authProvider).user?.uid;
```

### Các provider dùng chung (KHÔNG tạo lại)

```dart
// Trong auth_provider.dart — các module khác import và dùng trực tiếp
final currentUserProvider  // → UserModel?
final isAdminProvider      // → bool
final authStatusProvider   // → AuthStatus
```

---

## 8. Design System — màu sắc và font

Mọi màu sắc phải lấy từ `app_colors.dart` — KHÔNG hardcode hex trong widget.

```dart
// ✅ ĐÚNG
color: AppColors.primary    // #E94560

// ❌ SAI
color: Color(0xFFE94560)   // hardcode hex

// ❌ SAI
color: Colors.red          // dùng màu mặc định Flutter
```

### Bảng màu chuẩn

```dart
// app_colors.dart
static const background = Color(0xFF1A1A2E); // Nền chính
static const surface    = Color(0xFF16213E); // Card/Surface
static const panel      = Color(0xFF0F3460); // Panel/Input
static const primary    = Color(0xFFE94560); // CTA đỏ
static const success    = Color(0xFF00D4AA); // Thắng/teal
static const warning    = Color(0xFFFFB347); // Odds/amber
static const aiAccent   = Color(0xFF7B2FBE); // Gemini/purple
static const textPrimary   = Color(0xFFF5F5F5);
static const textSecondary = Color(0xFFA0A0B0);
```

---

## 9. Error handling

Mọi lỗi Firebase phải được map sang tiếng Việt trước khi hiển thị.
Hàm map lỗi đặt trong Notifier tương ứng — KHÔNG để trong widget.

```dart
// Chuyển đổi mã lỗi Firebase sang thông báo tiếng Việt thân thiện
String _mapErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    return switch (e.code) {
      'user-not-found'       => 'Email không tồn tại',
      'wrong-password'       => 'Mật khẩu không đúng',
      'email-already-in-use' => 'Email đã được sử dụng',
      'weak-password'        => 'Mật khẩu phải có ít nhất 6 ký tự',
      'invalid-email'        => 'Email không hợp lệ',
      'network-request-failed' => 'Lỗi kết nối mạng',
      _ => 'Đã xảy ra lỗi. Vui lòng thử lại',
    };
  }
  return 'Đã xảy ra lỗi. Vui lòng thử lại';
}
```

---

## 10. Checklist trước khi commit

```
□ Mọi hàm public đều có comment // tiếng Việt
□ Không hardcode màu hex trong widget — dùng AppColors
□ Không hardcode route string — dùng AppRoutes
□ Không gọi Firebase SDK trực tiếp ngoài data layer
□ Không có business logic trong widget
□ Không tạo file/folder mới không cần thiết
□ Dùng FieldValue.serverTimestamp() cho timestamp
□ Dùng convenience providers thay vì watch toàn bộ authProvider
□ Build thành công: flutter build apk --debug
□ Không có warning Riverpod về provider bị dispose
```

---

## 11. Phân công module

| Member | Module |
|---|---|
| Trường | Module 0 (Auth) + Module 5 (State) + Module 10 (Gemini AI) |
| Ngô Quang Minh | Module 1 (Trận đấu) + Module 2 (Ví ảo) |
| Minh Quang | Module 3 (Đặt cược) + Module 4 (Monte Carlo) |
| Ngọc Tú | Module 6 (Animation) + Module 7 (Notification) + Module 8 (Lịch sử) |
| Quang Anh | Module 9 (Anti-Gambling) + Module 11 (Admin Dashboard) |

**Nguyên tắc phối hợp:**
- Trường push Module 0 + 5 trước — cả nhóm pull về trước khi bắt đầu
- Mọi thành viên dùng mock data tuần 1, data thật tuần 2
- Mock data tập trung tại `lib/core/mocks/mock_data.dart`
- Branch riêng cho từng người, merge vào `dev` cuối ngày

---

## 12. Cách gọi agent hiệu quả

Khi gọi AI agent (Antigravity hoặc Claude), luôn bắt đầu prompt bằng:

```
Đọc file THE_HOUSE_WINS_RULES.md trước khi làm bất kỳ task nào.
Project dùng Clean Architecture + Riverpod StateNotifier.
[Mô tả task cụ thể ở đây]
```

Và kết thúc prompt bằng:
```
Sau khi xong, liệt kê:
1. Files đã tạo/sửa
2. Hàm nào cần các module khác biết
3. Điều gì cần team lead review
```

---

## 13. Freezed & build_runner

### Khi nào phải chạy build_runner
```
□ Sau khi tạo/sửa bất kỳ file có @freezed annotation
□ Sau khi tạo/sửa bất kỳ file có @JsonSerializable
□ Sau khi pull code từ Git về (phòng trường hợp teammate đã thêm model mới)
□ KHÔNG cần chạy khi chỉ sửa UI hoặc logic trong Notifier
```

Lệnh duy nhất được dùng:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### File generated — KHÔNG sửa tay
Các file sau do build_runner tự sinh, KHÔNG được sửa trực tiếp:
```
*.freezed.dart    ← generated từ @freezed
*.g.dart          ← generated từ @JsonSerializable
```

Nếu cần thay đổi → sửa file gốc rồi chạy lại build_runner.

### Đặt tên file model đúng chuẩn
```dart
// File gốc (tự viết)
user_model.dart

// File generated (build_runner tạo, không đụng vào)
user_model.freezed.dart
user_model.g.dart
```

### Xử lý conflict Git với file generated
File `*.freezed.dart` và `*.g.dart` thường gây conflict khi merge.
Cách xử lý: **luôn chọn "accept theirs"** khi conflict, sau đó chạy lại build_runner để regenerate đúng với code của mình:

```bash
# Sau khi resolve conflict
dart run build_runner build --delete-conflicting-outputs
```

---

## 14. Git Workflow

### Tên branch
```
feature/module-{số}-{tên-ngắn}

Ví dụ:
feature/module-0-auth
feature/module-1-matches
feature/module-2-wallet
feature/module-3-betting
feature/module-4-montecarlo
feature/module-6-animation
feature/module-7-notification
feature/module-8-history
feature/module-9-antigambling
feature/module-10-gemini
feature/module-11-admin
```

### Format commit message
```
{type}: {mô tả ngắn} [Module {số}]

type:
  feat     → thêm tính năng mới
  fix      → sửa bug
  refactor → cải thiện code không thay đổi tính năng
  style    → sửa UI/style
  docs     → cập nhật tài liệu/comment
  chore    → cập nhật config, package

Ví dụ:
feat: add register flow with Firestore wallet creation [Module 0]
fix: null check isAdmin before route redirect [Module 0]
feat: implement match list with football-data.org API [Module 1]
style: update bet card UI to match Stitch design [Module 3]
```

### .gitignore bắt buộc
Đảm bảo những file sau có trong `.gitignore`:

```gitignore
# Environment & secrets
.env
*.env

# Flutter generated
*.freezed.dart
*.g.dart
.dart_tool/
build/

# IDE
.idea/
.vscode/
*.iml

# Firebase (tuỳ team — nếu commit thì bỏ dòng này)
# lib/firebase_options.dart
```

> Với project học nhóm: `firebase_options.dart` có thể commit để tiện setup.
> Nếu commit thì KHÔNG add vào `.gitignore`.

### Flow làm việc hàng ngày
```
1. Sáng: git pull origin dev
2. Code trên branch feature của mình
3. Trước khi push: chạy flutter build apk --debug đảm bảo không lỗi
4. Cuối ngày: git push origin feature/module-X-tên
5. Khi xong task: tạo Pull Request vào dev, tag Trường review
6. KHÔNG merge trực tiếp vào main
```

---

## 15. Mock Data

### Vị trí và quyền sửa
File mock data tập trung tại một chỗ duy nhất:
```
lib/core/mocks/mock_data.dart
```

**Chỉ Trường (team lead) được thêm mock data mới vào file này.**
Thành viên khác cần mock data mới → tạo issue hoặc nhắn Trường bổ sung.

### Format mock data chuẩn
```dart
// mock_data.dart
class MockData {
  // Không cho khởi tạo instance — chỉ dùng static
  MockData._();

  // Số dư ví ảo mặc định khi khởi tạo — khớp với Firestore rule
  static const double initialBalance = 1000000;

  // User giả lập để test màn hình không cần đăng nhập
  static final mockUser = UserModel(
    uid: 'mock_uid_001',
    email: 'test@thehousewins.app',
    displayName: 'Test Player',
    isAdmin: false,
    createdAt: DateTime(2024, 1, 1),
  );

  // Admin giả lập để test Admin Dashboard
  static final mockAdmin = UserModel(
    uid: 'mock_admin_001',
    email: 'admin@thehousewins.app',
    displayName: 'Admin',
    isAdmin: true,
    createdAt: DateTime(2024, 1, 1),
  );

  // Danh sách trận đấu giả lập — đủ 3 trạng thái để test 3 tab
  static final mockMatches = [
    MatchModel(
      id: 'match_scheduled_001',
      homeTeam: 'Man United',
      awayTeam: 'Arsenal',
      utcDate: DateTime.now().add(Duration(hours: 2)),
      status: MatchStatus.scheduled,
      oddsOver: 1.85,
      oddsUnder: 1.95,
      overUnderLine: 2.5,
      isSimulated: false,
    ),
    MatchModel(
      id: 'match_live_001',
      homeTeam: 'Barcelona',
      awayTeam: 'Real Madrid',
      utcDate: DateTime.now().subtract(Duration(minutes: 45)),
      status: MatchStatus.inPlay,
      scoreHome: 1,
      scoreAway: 0,
      oddsOver: 1.90,
      oddsUnder: 1.90,
      overUnderLine: 3.5,
      isSimulated: true,
    ),
    MatchModel(
      id: 'match_finished_001',
      homeTeam: 'Liverpool',
      awayTeam: 'Chelsea',
      utcDate: DateTime.now().subtract(Duration(hours: 3)),
      status: MatchStatus.finished,
      scoreHome: 2,
      scoreAway: 1,
      result: MatchResult.over,
      oddsOver: 1.85,
      oddsUnder: 1.95,
      overUnderLine: 2.5,
      isSimulated: false,
    ),
  ];

  // Ví ảo giả lập
  static final mockWallet = WalletModel(
    userId: 'mock_uid_001',
    balance: 850000,
    lockedAmount: 100000,
    isBroke: false,
  );
}
```

### Khi nào xoá mock và dùng data thật
```
Tuần 1: Dùng MockData cho mọi widget
Tuần 2 ngày 8-9: Từng module switch sang Firestore/API thật
Sau khi switch: KHÔNG xoá MockData — giữ lại để chạy unit test
```

---

## 16. SQLite — Module 8 (Ngọc Tú)

SQLite chỉ dùng cho **Module 8 (lịch sử cược cache local)** và **Module 1 (cache trận đấu)**.
Các module khác dùng Firestore, KHÔNG dùng SQLite.

### Tên database và version
```dart
// database_helper.dart
static const String _dbName = 'the_house_wins.db';
static const int _dbVersion = 1;  // tăng lên khi thêm bảng/cột mới
```

### Tên bảng chuẩn (snake_case)
```sql
bet_history      -- lịch sử cược cache local (Module 8)
match_cache      -- cache trận đấu từ API (Module 1)
```

### Schema bắt buộc
```sql
-- bet_history
CREATE TABLE bet_history (
  id TEXT PRIMARY KEY,          -- betId từ Firestore
  user_id TEXT NOT NULL,
  match_id TEXT NOT NULL,
  home_team TEXT NOT NULL,
  away_team TEXT NOT NULL,
  choice TEXT NOT NULL,         -- 'over' hoặc 'under'
  amount REAL NOT NULL,
  odds_at_time REAL NOT NULL,
  payout REAL DEFAULT 0,
  status TEXT NOT NULL,         -- 'pending', 'won', 'lost', 'push'
  created_at INTEGER NOT NULL,  -- Unix timestamp milliseconds
  settled_at INTEGER            -- null nếu chưa có kết quả
);

-- match_cache
CREATE TABLE match_cache (
  id TEXT PRIMARY KEY,
  home_team TEXT NOT NULL,
  away_team TEXT NOT NULL,
  utc_date INTEGER NOT NULL,    -- Unix timestamp milliseconds
  status TEXT NOT NULL,
  score_home INTEGER DEFAULT 0,
  score_away INTEGER DEFAULT 0,
  result TEXT,                  -- 'over', 'under', null nếu chưa xong
  odds_over REAL NOT NULL,
  odds_under REAL NOT NULL,
  over_under_line REAL NOT NULL,
  is_simulated INTEGER NOT NULL DEFAULT 0,  -- 0=false, 1=true
  synced_at INTEGER NOT NULL    -- thời điểm cache lần cuối
);
```

### Migration strategy
Khi cần thêm cột/bảng mới, tăng `_dbVersion` và handle trong `onUpgrade`:
```dart
// Tăng version và xử lý migration — KHÔNG drop bảng cũ
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // Thêm cột mới nếu upgrade từ version 1 lên 2
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE bet_history ADD COLUMN note TEXT');
  }
}
```

---

## 17. Notification ID Convention — Module 7 (Ngọc Tú)

Mỗi loại notification dùng dải ID riêng để tránh override nhau.

```dart
// notification_constants.dart trong core/constants/
class NotificationIds {
  NotificationIds._();

  // Dải 1000-1999: nhắc trận đấu sắp bắt đầu (15 phút trước)
  // ID = 1000 + hashCode của matchId (lấy modulo để giữ trong dải)
  static int matchReminder15(String matchId) =>
      1000 + (matchId.hashCode.abs() % 999);

  // Dải 2000-2999: nhắc trận đấu sắp đóng kèo (5 phút trước)
  static int matchReminder5(String matchId) =>
      2000 + (matchId.hashCode.abs() % 999);

  // Dải 3000-3999: kết quả cược
  static int betResult(String betId) =>
      3000 + (betId.hashCode.abs() % 999);

  // ID cố định — luôn replace notification cũ thay vì stack
  static const int lowBalance = 9001;    // cảnh báo số dư thấp
  static const int inactivity = 9002;   // nhắc nhở không mở app
}
```

### Kênh notification (Android channel)
```dart
// Mỗi loại dùng channel riêng để người dùng có thể tắt từng loại
static const String channelMatchReminder = 'match_reminder';
static const String channelBetResult     = 'bet_result';
static const String channelLowBalance    = 'low_balance';
static const String channelInactivity    = 'inactivity';
```

---

## 18. API Key & Secret Management

**KHÔNG BAO GIỜ hardcode API key trong source code.**

### Cách quản lý key đúng

Tạo file `.env` ở root project (đã có trong `.gitignore`):
```
# .env — KHÔNG commit file này
FOOTBALL_DATA_API_KEY=your_key_here
GEMINI_API_KEY=your_key_here
```

Đọc key trong `api_constants.dart` qua package `flutter_dotenv`:
```dart
// core/constants/api_constants.dart

// Lấy API key từ .env — KHÔNG hardcode trực tiếp
static String get footballApiKey =>
    dotenv.env['FOOTBALL_DATA_API_KEY'] ?? '';

static String get geminiApiKey =>
    dotenv.env['GEMINI_API_KEY'] ?? '';

static const String footballBaseUrl =
    'https://api.football-data.org/v4';

static const String geminiBaseUrl =
    'https://generativelanguage.googleapis.com/v1beta';
```

### Chia sẻ key trong nhóm
Không commit `.env` lên Git. Chia sẻ key qua kênh riêng (Zalo nhóm, không qua chat công khai).
Trường giữ key gốc và chia sẻ cho từng thành viên khi cần.

### Kiểm tra trước khi commit
```bash
# Chạy lệnh này để đảm bảo không có key lọt vào code
grep -r "AIza" lib/          # Gemini key thường bắt đầu bằng AIza
grep -r "api_key" lib/       # tìm hardcode key
```

---

## 19. Naming Convention

### Files — snake_case
```
user_model.dart          ✅
UserModel.dart           ❌
userModel.dart           ❌
```

### Classes — PascalCase
```dart
class UserModel          ✅
class AuthFirebaseService ✅
class user_model         ❌
```

### Variables & Functions — camelCase
```dart
final matchId = '...';         ✅
Future<void> signIn() {}       ✅
final match_id = '...';        ❌
Future<void> SignIn() {}       ❌
```

### Constants — camelCase với prefix rõ ràng
```dart
static const double initialBalance = 1000000;  ✅
static const String channelBetResult = '...';  ✅
static const double INITIAL_BALANCE = 1000000; ❌ (SCREAMING_CASE không dùng trong Dart)
```

### Tên màn hình — luôn có suffix Screen
```dart
LoginScreen              ✅
BetScreen                ✅
AdminDashboardScreen     ✅
Login                    ❌
BettingPage              ❌ (dùng Screen không dùng Page)
```

### Tên Notifier — luôn có suffix Notifier
```dart
AuthNotifier             ✅
WalletNotifier           ✅
AuthController           ❌
AuthBloc                 ❌
```

### Tên Provider — luôn có suffix Provider
```dart
final authProvider       ✅
final walletProvider     ✅
final authState          ❌
final walletManager      ❌
```

### Tên State — luôn có suffix State
```dart
class AuthState          ✅
class WalletState        ✅
class AuthData           ❌
```

### Tên Firestore field — camelCase
```dart
// Trong Firestore document
'displayName'   ✅
'lockedAmount'  ✅
'display_name'  ❌
'locked_amount' ❌
```

### Tên SQLite column — snake_case
```sql
-- Trong SQLite (khác Firestore)
home_team       ✅
created_at      ✅
homeTeam        ❌
```

---

## 20. fl_chart & Animation Assets — Module 6 (Ngọc Tú)

### Vị trí assets
```
assets/
  animations/          ← file Lottie .json
    jackpot.json
    confetti.json
    warning_red.json
    coin_rain.json
  sounds/              ← âm thanh
    win_sound.mp3
    lose_sound.mp3
```

**Tên file assets: snake_case, mô tả rõ chức năng.**
KHÔNG đặt tên chung chung như `animation1.json` hay `sound.mp3`.

### Khai báo assets trong pubspec.yaml
```yaml
flutter:
  assets:
    - assets/animations/
    - assets/sounds/
```

### Format dữ liệu cho fl_chart
Mọi chart data phải được chuẩn bị ở Notifier trước khi truyền vào widget — KHÔNG xử lý data trong widget chart.

```dart
// ✅ ĐÚNG — chuẩn bị data trong SimulationNotifier
List<FlSpot> get balanceChartSpots {
  // Chuyển đổi lịch sử giao dịch thành điểm trên biểu đồ
  return transactions.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), entry.value.balanceAfter);
  }).toList();
}

// ✅ ĐÚNG — widget chỉ nhận data đã xử lý
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(spots: ref.watch(simulationProvider).balanceChartSpots),
    ],
  ),
)

// ❌ SAI — xử lý data trong widget
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: transactions.asMap().entries.map(...).toList(), // logic trong widget
      ),
    ],
  ),
)
```

### Ngưỡng trigger animation Jackpot
```dart
// app_constants.dart — KHÔNG hardcode trong widget
static const double jackpotThreshold = 500000;    // thắng > 500k VNĐ → nổ hũ
static const double brokeThreshold = 0.10;        // còn < 10% vốn → cảnh báo
static const double initialBalance = 1000000;     // vốn ban đầu
```