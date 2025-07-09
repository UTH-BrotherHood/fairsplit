import 'package:fairsplit/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AuthGradientButton extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  final Gradient? gradient;
  final bool isLoading;

  const AuthGradientButton({
    super.key,
    this.onPressed,
    required this.text,
    this.gradient,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient:
            gradient ??
            LinearGradient(colors: [Pallete.gradient1, Pallete.gradient2]),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(395, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
