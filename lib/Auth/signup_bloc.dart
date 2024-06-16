import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:convert' show utf8;
import 'dart:math';
import '../Models/user.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitial());

  String generateRandomString() {
    var r = Random();
    int len = r.nextInt(20);
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  void addUser(String _username, String _email, String _password,
      String _confirmedPassword) {
    Box<User> users = Hive.box<User>('users');

    // check if the email address is valid
    if (!EmailValidator.validate(_email)) {
      throw Exception("Enter a valid email address.");
    }

    // check if a user has this email address
    for (int i = 0; i < users.length; i++) {
      if (users.getAt(i)!.email == _email) {
        throw Exception("This email address is already used.");
      }
    }

    // check if the password is the same as the confirmed password
    if (_password != _confirmedPassword) {
      throw Exception("The passwords don't match.");
    }

    // generate a hashSalt
    var _hashSalt = generateRandomString();
    var DBPassword = sha256.convert(utf8.encode(_password + _hashSalt));

    users.add(
      User(
          username: _username,
          email: _email,
          hashSalt: _hashSalt,
          password: DBPassword.toString()),
    );
  }

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is SignUpButtonPressed) {
      yield SignUpLoading();

      try {
        await Future.delayed(const Duration(seconds: 1));
        List<Object> list = event.props;
        addUser(list[1].toString(), list[2].toString(), list[3].toString(),
            list[4].toString());
        yield SignUpSuccess();
        Navigator.pop(list[0] as BuildContext);
      } catch (error) {
        yield SignUpFailure(error: error.toString());
      }
    }
  }
}
