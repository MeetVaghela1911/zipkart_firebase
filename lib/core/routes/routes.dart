import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zipkart_firebase/screen/userLayout/AccountPage.dart';
import 'package:zipkart_firebase/screen/userLayout/CartScreen.dart';

// import your screens
import '../../ui/login_screen.dart';
import '../../ui/signup_screen.dart';
import '../../screen/userLayout/AppInit/Screen/SplashPage.dart';
import '../../screen/userLayout/AppInit/Screen/WelcomePage.dart';
import '../../screen/userLayout/HomePage.dart';
import '../../screen/userLayout/ProductDetail.dart';
import '../../screen/userLayout/ProductListScreen.dart';
import '../../screen/userLayout/UserProfilePage.dart';
import '../../screen/userLayout/AddressPage.dart';
import '../../screen/userLayout/PaymentPage.dart';
import '../../screen/userLayout/SuperOfferPage.dart';
import '../../screen/userLayout/ExplorePage.dart';
import '../../screen/userLayout/FavoritePage.dart';
import '../../screen/userLayout/UserSelectionScreen.dart';
import '../../screen/admin/MainPage.dart';

class AppRoutes {
  static const Splash = '/';
  static const Welcome = '/welcome';
  static const Login = '/login';
  static const Signup = '/signup';
  static const Home = '/home';
  static const UserProfile = '/userProfile';
  static const Address = '/address';
  static const Payment = '/payment';
  static const Offer = '/offer';
  static const Explore = '/explore';
  static const Favorite = '/favorite';
  static const UserSelection = '/userSelection';
  static const Admin = '/admin';
  static const ProductDetailScreen = '/ProductDetailScreen';
  static const CartScreen = '/CartScreen';
  static const AccountScreen = '/AccountScreen';
  static const ProductListScreen = '/ProductListScreen';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.Splash,
    routes: [
      GoRoute(
        path: AppRoutes.Splash,
        pageBuilder: (c, s) => _page(const SplashPage(), s),
      ),
      GoRoute(
        path: AppRoutes.Welcome,
        pageBuilder: (c, s) => _page(const WelcomeScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Login,
        pageBuilder: (c, s) => _page(const LoginScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Signup,
        pageBuilder: (c, s) => _page(const SignUpScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Home,
        pageBuilder: (c, s) => _page(const HomeScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.UserProfile,
        pageBuilder: (c, s) => _page(const ProfilePage(), s),
      ),
      GoRoute(
        path: AppRoutes.Address,
        pageBuilder: (c, s) => _page(const AddressScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Payment,
        pageBuilder: (c, s) => _page(const PaymentScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Offer,
        pageBuilder: (c, s) => _page(const SuperOfferScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Explore,
        pageBuilder: (c, s) => _page(const ExploreScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Favorite,
        pageBuilder: (c, s) => _page(const FavoriteScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.UserSelection,
        pageBuilder: (c, s) => _page(const UserSelectionScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.Admin,
        pageBuilder: (c, s) => _page(const AdminApp(), s),
      ),
      GoRoute(
        path: AppRoutes.ProductDetailScreen,
        pageBuilder: (c, s) {
          final product =
              s.extra
                  as dynamic; // Can be from Models/Product.dart or providers/product_provider.dart
          return _page(ProductDetailScreen(product: product), s);
        },
      ),
      GoRoute(
        path: AppRoutes.CartScreen,
        pageBuilder: (c, s) => _page(const CartScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.AccountScreen,
        pageBuilder: (c, s) => _page(const AccountScreen(), s),
      ),
      GoRoute(
        path: AppRoutes.ProductListScreen,
        pageBuilder: (c, s) {
          final extras = s.extra as Map<String, dynamic>?;
          return _page(
            ProductListScreen(
              categoryId: extras?['categoryId'],
              subCategoryId: extras?['subCategoryId'],
              categoryName: extras?['categoryName'],
            ),
            s,
          );
        },
      ),
    ],
  );

  /// Dynamic slide direction based on extra params
  static CustomTransitionPage _page(Widget child, GoRouterState state) {
    final vertical =
        (state.extra is Map && (state.extra as Map)['vertical'] == true);

    return CustomTransitionPage(
      key: ValueKey(child.hashCode),
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = vertical
            ? const Offset(0.0, 1.0) // vertical slide
            : const Offset(1.0, 0.0); // horizontal slide

        final offsetAnimation = animation.drive(
          Tween(
            begin: begin,
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        );

        final fade = animation.drive(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
    );
  }
}
