import '../../domain/models/user_model.dart';

class AdminState {
  final List<UserModel> users;
  final Map<String, double> userBalances;
  final List<Map<String, dynamic>> withdrawalRequests;
  final List<Map<String, dynamic>> adminLogs;

  // 11.3, 11.4, 11.6
  final List<Map<String, dynamic>> matches;

  // 11.8, 11.9
  final Map<String, dynamic> adminSettings;

  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AdminState({
    this.users = const [],
    this.userBalances = const {},
    this.withdrawalRequests = const [],
    this.adminLogs = const [],
    this.matches = const [],
    this.adminSettings = const {},
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  List<UserModel> get filteredUsers {
    if (searchQuery.isEmpty) {
      return users;
    }

    final query = searchQuery.toLowerCase();

    return users.where((user) {
      final name = user.displayName.toLowerCase();
      final email = user.email.toLowerCase();
      final phone = user.phoneNumber.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  Map<String, dynamic> get antiGamblingSettings {
    final data = adminSettings['antiGambling'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {};
  }

  Map<String, dynamic> get educationContent {
    final data = adminSettings['educationContent'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {};
  }

  AdminState copyWith({
    List<UserModel>? users,
    Map<String, double>? userBalances,
    List<Map<String, dynamic>>? withdrawalRequests,
    List<Map<String, dynamic>>? adminLogs,
    List<Map<String, dynamic>>? matches,
    Map<String, dynamic>? adminSettings,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return AdminState(
      users: users ?? this.users,
      userBalances: userBalances ?? this.userBalances,
      withdrawalRequests:
      withdrawalRequests ?? this.withdrawalRequests,
      adminLogs: adminLogs ?? this.adminLogs,
      matches: matches ?? this.matches,
      adminSettings: adminSettings ?? this.adminSettings,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}