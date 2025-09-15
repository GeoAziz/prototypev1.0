import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poafix/core/services/auth_service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/widgets/app_button.dart';
import 'package:poafix/core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Save user data for persistence
      await AuthService.saveUserData(userCredential.user!);

      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // App Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.home_repair_service,
                    color: AppColors.white,
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Welcome Back',
                style: AppTextStyles.display1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to your account to continue',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Email field
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 20),

              // Password field
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: !_showPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  child: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to forgot password
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login button
              AppButton(
                text: 'Login',
                onPressed: _login,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              // Social login
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Or continue with', style: AppTextStyles.body2),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Social buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: Icons.g_mobiledata,
                    color: Colors.red,
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final GoogleSignInAccount? googleUser =
                            await GoogleSignIn().signIn();
                        if (googleUser == null) {
                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }
                        final googleAuth = await googleUser.authentication;
                        final credential = GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );
                        final userCredential = await FirebaseAuth.instance
                            .signInWithCredential(credential);
                        await AuthService.saveUserData(userCredential.user!);
                        setState(() {
                          _isLoading = false;
                        });
                        if (mounted) context.go('/');
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google Sign-In failed: \$e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildSocialButton(
                    icon: Icons.facebook,
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  const SizedBox(width: 20),
                  _buildSocialButton(
                    icon: Icons.apple,
                    color: Colors.black,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: AppTextStyles.body1,
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    child: Text(
                      'Register',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: Icon(icon, color: color, size: 30)),
      ),
    );
  }
}
