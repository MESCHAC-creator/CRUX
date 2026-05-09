import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'package:crux/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    final user = await _authService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'inscription')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Créer un compte',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            CustomTextField(
              hint: AppConstants.nameHint,
              controller: _nameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: AppConstants.emailHint,
              controller: _emailController,
              icon: Icons.email,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: AppConstants.passwordHint,
              controller: _passwordController,
              icon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: AppConstants.registerButton,
              onPressed: _register,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}