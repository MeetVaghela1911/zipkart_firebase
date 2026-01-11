import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/globle_provider/TheameMode.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/AppColors.dart';
import '../../../CommanWidget/Toast.dart';
import '../Provider/Login/Provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    ref.read(loginProvider.notifier).logIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    // setState(() {
    //   _isLoading = true;
    // });

    // try
    // {
    //   final authService = ref.read(authServiceProvider);
    //   final user = await authService.signInWithEmail(
    //     _emailController.text.trim(),
    //     _passwordController.text.trim(),
    //   );
    //
    //   if (user != null) {
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Login successful!')),
    //       );
    //       Navigator.pushReplacementNamed(context, '/HomePage');
    //     }
    //   } else {
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Invalid email or password')),
    //       );
    //     }
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Error: ${e.toString()}')),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginProvider, (_, next) {
      if (next.error != null) {
        Toast.show(next.error!, context);
      }

      if (next.isSuccess) {
        Toast.show('Login successful!', context);
        context.pushReplacement(
          AppRoutes.Home,
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // border: Border.all(
                //   color: Colors.black,
                //   width: 1.5,
                // ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title Text
                  const Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  // Subtitle Text
                  const Text(
                    'Hello, welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  // Email TextField
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email,
                        ),
                        hintText: 'Email',
                        filled: true,
                        fillColor: isDarkTheme
                            ? AppColors.dark.divider
                            : AppColors.light.divider,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  // Password TextField
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        hintText: 'Password',
                        filled: true,
                        fillColor: isDarkTheme
                            ? AppColors.dark.divider
                            : AppColors.light.divider,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Login Button
                  SizedBox(
                    width: 400,
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              // backgroundColor: const Color(0xFF6B56B2), // Purple button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              minimumSize: const Size(400.0, 60),
                            ),
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                // color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20.0),
                  // Sign Up Text Button
                  TextButton(
                    onPressed: () {
                      context.pushReplacement(
                        AppRoutes.Signup,
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        // style: TextStyle(color: Colors.black54),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              // color: Color(0xFF6B56B2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
