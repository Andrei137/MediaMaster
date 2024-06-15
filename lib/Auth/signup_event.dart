part of 'signup_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpButtonPressed extends SignUpEvent {
  final BuildContext context;
  final String username;
  final String email;
  final String password;
  final String confirmedPassword;

  const SignUpButtonPressed(
      {required this.context,
      required this.username,
      required this.email,
      required this.password,
      required this.confirmedPassword});

  @override
  List<Object> get props =>
      [context, username, email, password, confirmedPassword];

  @override
  String toString() =>
      'SignUpButtonPressed {username: $username, email: $email, password: $password, confirmedPassword: $confirmedPassword }';
}
