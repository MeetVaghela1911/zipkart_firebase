// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:zipkart_firebase/providers/auth_provider.dart';
// import 'package:zipkart_firebase/screen/admin/MainPage.dart';
// import 'package:zipkart_firebase/screen/userLayout/UserSelectionScreen.dart';
//
// import '../../../../core/routes/routes.dart';
//
// class WelcomeScreen extends ConsumerWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     bool isAdmin = false;
//
//     // Listen to auth state changes
//     ref.listen(authStateProvider, (previous, next) {
//       next.whenData((user) {
//         if (user != null) {
//           if (isAdmin) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const AdminApp()),
//             );
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
//             );
//           }
//         }
//       });
//     });
//
//     return Scaffold(
//       // backgroundColor: const Color(0xFF6B56B2),
//       body: Center(
//         child: Column(
//           // mainAxisAlignment: MainAxisAlignment.end,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Spacer(),
//             // Icon or Image representing the app
//             Container(
//               margin: const EdgeInsets.only(bottom: 20.0),
//               child: const Icon(
//                 Icons.bubble_chart,
//                 size: 80.0,
//                 // color: ,
//               ),
//             ),
//             const SizedBox(height: 20.0),
//             // Title Text
//             const Text(
//               'Make mymories',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 // color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 10.0),
//             // Subtitle Text
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40.0),
//               child: Text(
//                 'Record, recall and share your favorite mymories anytime.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   // color: Colors.white70,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40.0),
//             // Buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18.0),
//               child: Column(
//                 children: [
//                   buildAuthBtn(
//                       text: 'Sign in',
//                       // backgroundColor : Colors.white,
//                       onPressed: (){
//                         context.push(AppRoutes.signup);
//                       }
//                   ),
//                   SizedBox(height: 12,),
//                   buildAuthBtn(
//                       text: 'Log in',
//                       // backgroundColor : Colors.white,
//                       onPressed: (){
//                         context.push(AppRoutes.login);
//                       }
//                   ),
//
//                   // const SizedBox(height: 15.0),
//                   // // Continue with Google Button
//                   // ElevatedButton(
//                   //   onPressed: () async {
//                   //     final authService = ref.read(authServiceProvider);
//                   //     User? user = await authService.googleSignUp();
//                   //     if (user != null) {
//                   //       Navigator.pushReplacementNamed(context, '/Userselection');
//                   //     }
//                   //   },
//                   //   style: ElevatedButton.styleFrom(
//                   //     backgroundColor: Colors.amber.shade100,
//                   //     shape: RoundedRectangleBorder(
//                   //       borderRadius: BorderRadius.circular(8.0),
//                   //     ),
//                   //   ),
//                   //   child: const Padding(
//                   //     padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 35.0),
//                   //     child: Text(
//                   //       'Continue with Google',
//                   //       style: TextStyle(
//                   //         color: Colors.black,
//                   //         fontWeight: FontWeight.bold,
//                   //         fontSize: 16,
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                   // const SizedBox(height: 15.0),
//                   // // Sign up with email Button
//                   // ElevatedButton(
//                   //   onPressed: () {
//                   //     Navigator.push(
//                   //       context,
//                   //       MaterialPageRoute(builder: (context) => const SignUpScreen()),
//                   //     );
//                   //   },
//                   //   style: OutlinedButton.styleFrom(
//                   //     side: const BorderSide(color: Colors.white),
//                   //     shape: RoundedRectangleBorder(
//                   //       borderRadius: BorderRadius.circular(8.0),
//                   //     ),
//                   //   ),
//                   //   child: const Padding(
//                   //     padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 45.0),
//                   //     child: Text(
//                   //       'Sign up with email',
//                   //       style: TextStyle(
//                   //         color: Colors.black,
//                   //         fontWeight: FontWeight.bold,
//                   //         fontSize: 16,
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),                // Continue with Apple Button
//                   // ElevatedButton(
//                   //   onPressed: () async {
//                   //     final authService = ref.read(authServiceProvider);
//                   //     User? user = await authService.signInWithApple();
//                   //     if (user != null) {
//                   //       // Navigation handled by auth state listener
//                   //     }
//                   //   },
//                   //   style: ElevatedButton.styleFrom(
//                   //     backgroundColor: const Color(0xFF90C9C3),
//                   //     shape: RoundedRectangleBorder(
//                   //       borderRadius: BorderRadius.circular(8.0),
//                   //     ),
//                   //   ),
//                   //   child: const Padding(
//                   //     padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
//                   //     child: Text(
//                   //       'Continue with Apple',
//                   //       style: TextStyle(
//                   //         color: Colors.white,
//                   //         fontWeight: FontWeight.bold,
//                   //         fontSize: 16,
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                   //
//                 ],
//               ),
//             ),
//             const SizedBox(height: kToolbarHeight /2),
//             // Footer Text
//             // TextButton(
//             //   onPressed: () {
//             //     Navigator.pushNamed(context, '/LoginPage');
//             //   },
//             //   child: RichText(
//             //     text: const TextSpan(
//             //       text: 'Already have an account? ',
//             //       style: TextStyle(color: Colors.white70),
//             //       children: <TextSpan>[
//             //         TextSpan(
//             //           text: 'Log in',
//             //           style: TextStyle(
//             //             color: Colors.white,
//             //             fontWeight: FontWeight.bold,
//             //           ),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget buildAuthBtn({
//     required String text,
//     // required Color backgroundColor,
//     required VoidCallback onPressed,
//   }){
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           // backgroundColor: backgroundColor,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 55.0),
//           child: Text(
//             text,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zipkart_firebase/providers/auth_provider.dart';
import 'package:zipkart_firebase/screen/admin/MainPage.dart';
import 'package:zipkart_firebase/screen/userLayout/UserSelectionScreen.dart';
import '../../../../core/routes/routes.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Replace Navigator with GoRouter
          context.go(user.email ==
              // 'vaghelameet6139@gmail.com'
              'admin@gmail.com'
              ? AppRoutes.Admin
              : AppRoutes.Home);
        }
      });
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;

          // Control width for web/tablet
          double contentWidth = maxWidth > 700 ? 500 : maxWidth * 0.88;

          double spacing = maxWidth > 600 ? 30 : 20;

          return Center(
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: spacing * 1.2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bubble_chart,
                        size: 80,
                      ),
                      SizedBox(height: spacing),

                      const Text(
                        'Make mymories',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Record, recall and share your favorite mymories anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),

                      SizedBox(height: spacing * 2),

                      _authBtn(
                        text: 'Sign in',
                        onPressed: () => context.push(AppRoutes.Signup),
                      ),
                      const SizedBox(height: 14),

                      _authBtn(
                        text: 'Log in',
                        onPressed: () => context.push(AppRoutes.Login),
                      ),

                      SizedBox(height: spacing * 2),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _authBtn({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
