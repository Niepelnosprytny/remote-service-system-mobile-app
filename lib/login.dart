import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'reports.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLoggedIn = ref.watch(userLoggedInProvider);

    if (userLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReportsPage()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _LoginForm(),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
@override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Email field
          TextFormField(
            controller: emailController,
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
            controller: passwordController,
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
              String input = '${emailController.text},${passwordController.text}';

              if (formKey.currentState?.validate() == true) {
                ref.read(fetchUserProvider(input));
                ref.read(userLoggedInProvider.notifier).update((state) => true);
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            child: const Text('Zaloguj'),
          ),
        ],
      ),
    );
  }
}