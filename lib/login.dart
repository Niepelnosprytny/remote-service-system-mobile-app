import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'reports.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool userLoggedIn = ref.watch(userLoggedInProvider);

    if (userLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReportsPage())
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: LoginForm()
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź adres email';
              }
              return null;
            },
          ),
          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź hasło';
              }
              return null;
            },
          ),
          // Login button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                print('Email: ${_emailController.text}, Password: ${_passwordController.text}');
              }
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)
            ),
            child: const Text('Zaloguj'),
          ),
        ],
      ),
    );
  }
}