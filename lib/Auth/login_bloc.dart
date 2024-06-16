import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:convert' show utf8;
import '../Models/user.dart';
import '../UserSystem.dart';
import '../GameLibrary.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  void checkUser(
    String _email,
    String _password,
  ) {
    Box<User> users = Hive.box<User>('users');

    // check if the email address is valid
    if (!EmailValidator.validate(_email)) {
      throw Exception("Enter a valid email address.");
    }

    // check if a user has this email address
    int index = -1;
    for (int i = 0; i < users.length; i++) {
      if (users.getAt(i)!.email == _email) {
        index = i;
      }
    }
    if (index == -1) {
      throw Exception("There is no account with this email address.");
    }

    // check if the password is the same as the confirmed password
    var possiblePassword =
        sha256.convert(utf8.encode(_password + users.getAt(index)!.hashSalt));
    if (possiblePassword.toString() != users.getAt(index)!.password) {
      throw Exception("Invalid password.");
    }

    User user = users.getAt(index)!;
    UserSystem().login(user);
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();
      try {
        await Future.delayed(const Duration(seconds: 1));
        List<Object> list = event.props;
        checkUser(list[1].toString(), list[2].toString());
        yield LoginSuccess();
        Navigator.pop(list[0] as BuildContext);
        Navigator.of(list[0] as BuildContext)
            .push(MaterialPageRoute(builder: (context) => const GameLibrary()));
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}
