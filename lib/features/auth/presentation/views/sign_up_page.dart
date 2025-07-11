import 'package:fairsplit/core/utils/snarbar.dart';
import 'package:fairsplit/core/utils/validators.dart';
import 'package:fairsplit/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:fairsplit/features/auth/presentation/views/login_page.dart';
import 'package:fairsplit/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:fairsplit/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/core/theme/app_colors.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage>
    with TickerProviderStateMixin {
  List<TextEditingController> controllers = List.generate(
    5,
    (index) => TextEditingController(),
  );

  final List<String> hintTexts = [
    "Username",
    "Email",
    "Password",
    "Confirm Password",
    "Date of Birth",
  ];

  final List<IconData> fieldIcons = [
    Icons.person_outline,
    Icons.email_outlined,
    Icons.lock_outline,
    Icons.lock_outline,
    Icons.calendar_today,
  ];

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  signup() async {
    setState(() => _loading = true);
    try {
      // Parse date of birth
      DateTime dateOfBirth;
      try {
        dateOfBirth = DateTime.parse(controllers[4].text);
      } catch (e) {
        throw Exception('Invalid date format. Please use YYYY-MM-DD');
      }

      await ref
          .read(authViewModelProvider.notifier)
          .signUp(
            username: controllers[0].text,
            email: controllers[1].text,
            password: controllers[2].text,
            confirmPassword: controllers[3].text,
            dateOfBirth: dateOfBirth,
          );
      if (!mounted) return;
      showSnackBar(
        content:
            'Account created successfully! Please check your email to verify your account.',
        context: context,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              top: 80,
              left: -40,
              child: _buildFloatingCircle(
                size: 100,
                color: AppColors.primaryColor.withOpacity(0.1),
                animation: _fadeAnimation,
              ),
            ),
            Positioned(
              top: 180,
              right: -20,
              child: _buildFloatingCircle(
                size: 70,
                color: AppColors.secondaryColor.withOpacity(0.1),
                animation: _fadeAnimation,
              ),
            ),
            Positioned(
              bottom: 120,
              left: 30,
              child: _buildFloatingCircle(
                size: 50,
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
                        children: [
                          const SizedBox(height: 40),
                          _buildHeader(context),
                          const SizedBox(height: 40),
                          _buildLogoSection(),
                          const SizedBox(height: 40),
                          _buildSignupFields(),
                          const SizedBox(height: 30),
                          _buildSignupButton(),
                          const SizedBox(height: 20),
                          _buildLoginOption(context),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimaryColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Create Account',
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
          'Start sharing expenses with friends',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupFields() {
    return Column(
      children: List.generate(controllers.length, (index) {
        final bool isPasswordField = index == 2;
        final bool isConfirmPasswordField = index == 3;
        final bool isDateField = index == 4;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: CustomTextField(
            hintText: hintTexts[index],
            controller: controllers[index],
            validator: (value) {
              if (hintTexts[index] == "Email") {
                return Validators.validateEmail(value);
              } else if (hintTexts[index] == "Date of Birth") {
                if (value == null || value.isEmpty) {
                  return 'Please enter date of birth';
                }
                try {
                  DateTime.parse(value);
                  return null;
                } catch (e) {
                  return 'Please use format YYYY-MM-DD';
                }
              } else if (hintTexts[index] == "Confirm Password") {
                if (value != controllers[2].text) {
                  return 'Passwords do not match';
                }
                return null;
              }
              return null;
            },
            prefixIcon: fieldIcons[index],
            obscureText: isPasswordField
                ? _obscurePassword
                : isConfirmPasswordField
                ? _obscureConfirmPassword
                : false,
            onTap: isDateField ? () => _selectDate(context) : null,
            readOnly: isDateField,
            suffixIcon: isPasswordField || isConfirmPasswordField
                ? IconButton(
                    icon: Icon(
                      (isPasswordField
                              ? _obscurePassword
                              : _obscureConfirmPassword)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isPasswordField) {
                          _obscurePassword = !_obscurePassword;
                        } else {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }
                      });
                    },
                  )
                : null,
          ),
        );
      }),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controllers[4].text = picked.toIso8601String().split('T')[0];
    }
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AuthGradientButton(
        onPressed: () {
          if (_globalKey.currentState!.validate()) {
            signup();
          }
        },
        text: 'CREATE ACCOUNT',
        isLoading: _loading,
      ),
    );
  }

  Widget _buildLoginOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15),
              children: [
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: AppColors.textSecondaryColor),
                ),
                TextSpan(
                  text: 'Sign In',
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
