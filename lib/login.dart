import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'providers.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
                labelText: 'Email',
                hintText: "Wprowadź adres email"
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź adres email';
              }
              return null;
            },
          ),
          SizedBox(
            height: 2.5.h,
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
                labelText: 'Hasło',
                hintText: "Wprowadź hasło"
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź hasło';
              }
              return null;
            },
          ),
          SizedBox(
            height: 2.5.h,
          ),
          ElevatedButton(
            onPressed: () {
              String input = '${emailController.text},${passwordController.text}';

              if (formKey.currentState?.validate() == true) {
                FocusManager.instance.primaryFocus?.unfocus();

                ref.read(fetchUserProvider(input));
              }
            },
            style: ElevatedButton.styleFrom(
                fixedSize: Size(50.w, 7.5.h)
            ),
            child: const Text(
              'Zaloguj',
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }
}