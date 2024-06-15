import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in Screen'),
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 3),
              ));
          }
        },
        child: Form(
          key: formKey,
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 500,
                      child: TextFormField(
                          controller: _emailController,
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
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password.";
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: state is! LoginLoading
                          ? () {
                              if (formKey.currentState!.validate()) {
                                loginBloc.add(
                                  LoginButtonPressed(
                                    context: context,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(219, 10, 94, 87)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Log in'),
                    ),
                    if (state is LoginLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
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
