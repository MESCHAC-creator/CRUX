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
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs')),
      );
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Le mot de passe doit avoir au moins 6 caracteres')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final user = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authService.lastError ?? 'Erreur lors de l\'inscription'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              const Text(
                'Créer un compte',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rejoignez CRUX et commencez à collaborer',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                hint: AppConstants.nameHint,
                controller: _nameController,
                icon: Icons.person_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: AppConstants.emailHint,
                controller: _emailController,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: AppConstants.passwordHint,
                controller: _passwordController,
                icon: Icons.lock_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: AppConstants.registerButton,
                onPressed: _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}