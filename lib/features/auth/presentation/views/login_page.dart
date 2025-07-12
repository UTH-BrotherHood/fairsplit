import 'package:fairsplit/core/utils/snarbar.dart';
import 'package:fairsplit/core/utils/validators.dart';
import 'package:fairsplit/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:fairsplit/features/auth/presentation/views/sign_up_page.dart';
import 'package:fairsplit/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:fairsplit/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:fairsplit/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fairsplit/core/theme/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  bool _loading = false;
  bool _obscurePassword = true;

  List<TextEditingController> controllers = List.generate(
    2,
    (index) => TextEditingController(),
  );

  final List<String> hintTexts = ["Email", "Password"];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // ignore: avoid_function_literals_in_foreach_calls
    controllers.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  login() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(authViewModelProvider.notifier)
          .login(email: controllers[0].text, password: controllers[1].text);
      if (!mounted) return;
      ref.invalidate(profileViewModelProvider);
      context.go('/');
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      showSnackBar(
        content: errorMessage,
        context: context,
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.backgroundColor,
              AppColors.primaryColorLight.withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            Positioned(
              top: 100,
              left: -50,
              child: _buildFloatingCircle(
                size: 120,
                color: AppColors.primaryColor.withOpacity(0.1),
                animation: _fadeAnimation,
              ),
            ),
            Positioned(
              top: 200,
              right: -30,
              child: _buildFloatingCircle(
                size: 80,
                color: AppColors.secondaryColor.withOpacity(0.1),
                animation: _fadeAnimation,
              ),
            ),
            Positioned(
              bottom: 150,
              left: 50,
              child: _buildFloatingCircle(
                size: 60,
                color: AppColors.accentColor.withOpacity(0.1),
                animation: _fadeAnimation,
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _globalKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          _buildHeader(),
                          const SizedBox(height: 50),
                          _buildLogoSection(),
                          const SizedBox(height: 50),
                          _buildLoginFields(),
                          const SizedBox(height: 30),
                          _buildLoginButton(),
                          const SizedBox(height: 20),
                          _buildSignupOption(context),
                          const SizedBox(height: 30),
                          _buildGoogleSignInButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'FairSplit',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Smart expense sharing made simple',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        // Email field
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: CustomTextField(
            hintText: hintTexts[0],
            controller: controllers[0],
            validator: (value) => Validators.validateEmail(value),
            prefixIcon: Icons.email_outlined,
            style: TextStyle(color: AppColors.textPrimaryColor),
            hintStyle: TextStyle(color: AppColors.textSecondaryColor),
          ),
        ),

        // Password field
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: CustomTextField(
            hintText: hintTexts[1],
            controller: controllers[1],
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            style: TextStyle(color: AppColors.textPrimaryColor),
            hintStyle: TextStyle(color: AppColors.textSecondaryColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondaryColor,
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
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AuthGradientButton(
        onPressed: () {
          if (_globalKey.currentState!.validate()) {
            login();
          }
        },
        text: 'SIGN IN',
        isLoading: _loading,
      ),
    );
  }

  Widget _buildSignupOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignUpPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15),
              children: [
                TextSpan(
                  text: 'Don\'t have an account? ',
                  style: TextStyle(color: AppColors.textSecondaryColor),
                ),
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ElevatedButton.icon(
        icon: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.login, color: AppColors.textOnPrimary),
        label: _loading
            ? const SizedBox.shrink()
            : Text(
                'Continue with Google',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        onPressed: _loading
            ? null
            : () async {
                setState(() => _loading = true);
                try {
                  await ref
                      .read(authViewModelProvider.notifier)
                      .signInWithGoogle();
                  if (!mounted) return;
                  ref.invalidate(profileViewModelProvider);
                  context.go('/');
                } catch (e) {
                  if (!mounted) return;
                  showSnackBar(
                    content: e.toString(),
                    context: context,
                    backgroundColor: AppColors.errorColor,
                  );
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCircle({
    required double size,
    required Color color,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );
      },
    );
  }
}
