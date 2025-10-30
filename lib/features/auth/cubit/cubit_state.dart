abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final String token;
  final String role;
  LoginSuccess({required this.token, required this.role});
}
class LoginFailure extends LoginState {
  final String message;
  LoginFailure({required this.message});
}
