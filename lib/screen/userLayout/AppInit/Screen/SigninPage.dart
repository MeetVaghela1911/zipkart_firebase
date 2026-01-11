import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipkart_firebase/core/globle_provider/TheameMode.dart';
import 'package:zipkart_firebase/core/theme/AppColors.dart';
import 'package:zipkart_firebase/screen/CommanWidget/Toast.dart';

import 'package:zipkart_firebase/screen/userLayout/AppInit/Provider/Signin/SigninProvider.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../core/routes/routes.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _base64Image;

  String _selectedRole = 'Buyer';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _selectedImage = image;

        final bytes = await image.readAsBytes();
        _base64Image = base64Encode(bytes);

        // setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.trim().isEmpty) {
      _showError("Please enter your email");
      return;
    }

    if (_usernameController.text.trim().isEmpty) {
      _showError("Please enter your username");
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showError("Please enter your password");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    // setState(() => _isLoading = true);

    ref.read(signUpProvider.notifier).signIn(
        email: _emailController.text,
        password: _passwordController.text,
        userName: _usernameController.text,
        phone: _phoneNumberController.text);

    // TODO: connect API / auth provider here
  }

  void _showError(String msg) {
    // Toast.show(msg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signUpProvider, (_, next) {
      if (next.error != null) {
        // _showError(next.error!);
        // Toast.show(next.error!);
        Toast.show(next.error!, context);
      }

      if (next.isSuccess) {
        Toast.show("Account created successfully!", context);
      }
    });

    return Scaffold(
      // ✅ FIX:
      // LayoutBuilder is moved OUTSIDE SingleChildScrollView
      // so we can read the full viewport height (constraints.maxHeight).
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // ✅ FIX:
            // SingleChildScrollView removes height constraints.
            // ConstrainedBox restores them using minHeight,
            // allowing Center to vertically align its child.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Card(
                      elevation: constraints.maxWidth > 700 ? 6 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),

                        // ✅ CHANGE:
                        // Removed nested SingleChildScrollView.
                        // Nested scroll views break layout logic.
                        child: _buildForm(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ CHANGE:
  // Extracted form into a method to keep build() readable
  // and avoid unnecessary rebuild nesting.
  Widget _buildForm() {
    return Column(
      // ✅ IMPORTANT:
      // mainAxisSize.min prevents Column from expanding
      // vertically and breaking Center alignment.
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Sign up",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Just a few quick things to get started",
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 30),

        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _selectedImage != null
                ? (kIsWeb
                    ? MemoryImage(base64Decode(_base64Image!))
                    : FileImage(File(_selectedImage!.path))) as ImageProvider
                : null,
            child: _selectedImage == null
                ? const Icon(Icons.camera_alt, size: 50)
                : null,
          ),
        ),

        const SizedBox(height: 25),

        _buildTextField(
          controller: _emailController,
          hint: "Email",
          icon: Icons.email,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _usernameController,
          hint: "Username",
          icon: Icons.person,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _passwordController,
          hint: "Password",
          icon: Icons.lock,
          obscure: true,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _phoneNumberController,
          hint: "Phone Number",
          icon: Icons.phone,
          inputType: TextInputType.phone,
        ),
        // const SizedBox(height: 20),
        //
        // DropdownButtonFormField<String>(
        //   value: _selectedRole,
        //   items: ["Buyer", "Seller"]
        //       .map((r) => DropdownMenuItem(
        //     value: r,
        //     child: Text(r),
        //   ))
        //       .toList(),
        //   onChanged: (v) =>
        //       setState(() => _selectedRole = v!),
        //   decoration:
        //   _inputDecoration(Icons.person_outline),
        // ),

        const SizedBox(height: 30),

        ref.watch(signUpProvider).isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Create account",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

        const SizedBox(height: 18),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Already have an account? Log in"),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      decoration: _inputDecoration(icon).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: isDarkTheme ? AppColors.dark.divider : AppColors.light.divider,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
