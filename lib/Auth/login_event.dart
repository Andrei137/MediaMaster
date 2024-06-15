part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final BuildContext context;
  final String email;
  final String password;

  const LoginButtonPressed(
      {required this.context, required this.email, required this.password});

  @override
  List<Object> get props => [context, email, password];

  @override
  String toString() =>
      'LoginButtonPressed {email: $email, password: $password }';
}
