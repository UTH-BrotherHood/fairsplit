import 'package:fairsplit/core/utils/validators.dart';
import 'package:fairsplit/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:fairsplit/features/auth/presentation/views/sign_up_page.dart';
import 'package:fairsplit/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:fairsplit/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _loading = false;
  bool _obscurePassword = true;

  List<TextEditingController> controllers = List.generate(
    2,
    (index) => TextEditingController(),
  );

  final List<String> hintTexts = ["Email", "Password"];

  @override
  void dispose() {
    // ignore: avoid_function_literals_in_foreach_calls
    controllers.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  login() async {
    ref
        .read(authViewModelProvider.notifier)
        .login(email: controllers[0].text, password: controllers[1].text);
  }

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider);

    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _globalKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                _buildLogoSection(),

                SizedBox(height: 40),
                _buildLoginFields(),

                SizedBox(height: 10),
                _buildLoginButton(),

                SizedBox(height: 20),
                _buildSignupOption(context),

                SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text('Sign in with Google'),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await ref
                              .read(authViewModelProvider.notifier)
                              .signInWithGoogle();
                          if (!mounted) return;
                          setState(() => _loading = false);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFE83D7B), // Pink
                Color(0xFF6A3DE8), // Purple
              ],
            ),
          ),
          child: Icon(Icons.add_task, color: Colors.white, size: 40),
        ),
        SizedBox(height: 16),
        Text(
          'Fairsplit',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'Shared Shopping List',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        // Email field with custom styling
        Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomTextField(
            hintText: hintTexts[0],
            controller: controllers[0],
            validator: (value) => Validators.validateEmail(value),
            prefixIcon: Icons.email_outlined,
          ),
        ),

        // Password field with custom styling
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomTextField(
            hintText: hintTexts[1],
            controller: controllers[1],
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) => Validators.validatePassword(value),
          ),
        ),

        // Forgot password option
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: Color(0xFF6A3DE8), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: AuthGradientButton(
        onPressed: () {
          if (_globalKey.currentState!.validate()) {
            login();
          }
        },
        text: 'LOGIN',
        gradient: LinearGradient(
          colors: [
            Color(0xFFE83D7B), // Pink
            Color(0xFF6A3DE8), // Purple
          ],
        ),
      ),
    );
  }

  Widget _buildSignupOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SignUpPage()),
        );
      },
      child: Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 15),
            children: [
              TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(color: Colors.white70),
              ),
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: Color(0xFFE83D7B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
