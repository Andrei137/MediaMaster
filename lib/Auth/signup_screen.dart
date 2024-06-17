import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'signup_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmedPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpBloc = BlocProvider.of<SignUpBloc>(context);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up Screen'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
                  ? AdaptiveTheme.of(context).setDark()
                  : AdaptiveTheme.of(context).setLight();
            },
            icon: const Icon(Icons.dark_mode),
            tooltip: 'Toggle dark mode',
          ),
        ],
      ),
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 3),
              ));
          }
          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text("The account has been successfully registered."),
                duration: Duration(seconds: 3),
              ));
          }
        },
        child: Form(
          key: formKey,
          child: BlocBuilder<SignUpBloc, SignUpState>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 500,
                      child: TextFormField(
                          controller: _usernameController,
                          cursorColor: const Color.fromARGB(219, 10, 94, 87),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a username.";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 500,
                      child: TextFormField(
                          controller: _emailController,
                          cursorColor: const Color.fromARGB(219, 10, 94, 87),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an email.";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 500,
                      child: TextFormField(
                          controller: _passwordController,
                          cursorColor: const Color.fromARGB(219, 10, 94, 87),
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password.";
                            }
                            if (value.length < 8) {
                              return "Please enter a password of at least 8 characters.";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 500,
                      child: TextFormField(
                          controller: _confirmedPasswordController,
                          cursorColor: const Color.fromARGB(219, 10, 94, 87),
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the same password as above.";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: state is! SignUpLoading
                          ? () {
                              if (formKey.currentState!.validate()) {
                                signUpBloc.add(
                                  SignUpButtonPressed(
                                    context: context,
                                    username: _usernameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    confirmedPassword:
                                        _confirmedPasswordController.text,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(219, 10, 94, 87)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Sign up'),
                    ),
                    if (state is SignUpLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                            color: Color.fromARGB(219, 10, 94, 87)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
