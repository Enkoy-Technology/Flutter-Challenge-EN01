import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_router.dart';
import '../bloc/cubit/register_cubit.dart';

import '../widgets/gradient_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Create Account ✨",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                CustomTextField(controller: nameController, hint: "Full Name"),
                const SizedBox(height: 16),
                CustomTextField(controller: emailController, hint: "Email"),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hint: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: state is RegisterLoading ? "Creating..." : "Register",
                  onPressed: () {
                    if (state is! RegisterLoading) {
                      context.read<RegisterCubit>().register(
                        emailController.text,
                        passwordController.text,
                        nameController.text,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.login),
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
