import '../../domain/models/user_model.dart';

class AdminState {
  final List<UserModel> users;
  final Map<String, double> userBalances;
  final List<Map<String, dynamic>> withdrawalRequests;
  final List<Map<String, dynamic>> adminLogs;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AdminState({
    this.users = const [],
    this.userBalances = const {},
    this.withdrawalRequests = const [],
    this.adminLogs = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  List<UserModel> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    final query = searchQuery.toLowerCase();
    return users.where((u) {
      final name = u.displayName.toLowerCase();
      final email = u.email.toLowerCase();
      final phone = u.phoneNumber.toLowerCase();
      return name.contains(query) || email.contains(query) || phone.contains(query);
    }).toList();
  }

  AdminState copyWith({
    List<UserModel>? users,
    Map<String, double>? userBalances,
    List<Map<String, dynamic>>? withdrawalRequests,
    List<Map<String, dynamic>>? adminLogs,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminState(
      users: users ?? this.users,
      userBalances: userBalances ?? this.userBalances,
      withdrawalRequests: withdrawalRequests ?? this.withdrawalRequests,
      adminLogs: adminLogs ?? this.adminLogs,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
