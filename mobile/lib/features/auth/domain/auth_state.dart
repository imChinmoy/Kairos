class UserModel {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? department;
  final String? designation;

  const UserModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.department,
    this.designation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'OFFICER',
      department: json['department'] as String?,
      designation: json['designation'] as String?,
    );
  }

  bool get isOfficer => role == 'OFFICER';
  bool get isSupervisor => role == 'SUPERVISOR';
  bool get isAdmin => role == 'ADMIN';

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get firstName => name.split(' ').first;
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  const AuthState.loading() : this(isLoading: true);
  const AuthState.authenticated(UserModel user)
      : this(isAuthenticated: true, user: user);
  const AuthState.error(String error) : this(error: error);
  const AuthState.unauthenticated() : this();

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
