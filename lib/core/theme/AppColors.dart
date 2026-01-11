import 'package:flutter/material.dart';

class AppColors {
  // ------------------ Light Theme ------------------
  static const light = AppColorScheme(
    // Primary Brand Colors
    colorPrimary: Color(0xFF004AAD), // Trust blue - for buttons, links
    colorSecond: Color(0xFFFF6E40), // Energetic orange - for accents, CTAs
    colorAccent: Color(0xFFF67E58), // Warm coral - for highlights
    background: Color(0xFFFFFFFF), // Pure white
    colorPrimaryDark: Color(0xFF003580), // Darker blue for hover states
    colorPrimaryLight: Color(0xFFEEF6FF), // Very light blue for backgrounds

    // Surface & Cards
    surfaceCard: Color(0xFFFFFFFF), // Card backgrounds
    surfaceElevated: Color(0xFFFAFAFA), // Slightly elevated surfaces
    surfaceOverlay: Color(0x14000000), // Overlay for modals

    // Text Colors
    textPrimary: Color(0xFF1A1A1A), // Main text
    textSecondary: Color(0xFF050505), // Secondary text
    textTertiary: Color(0xFF9CA3AF), // Tertiary/disabled text
    textOnPrimary: Color(0xFFFFFFFF), // Text on primary color
    textOnSecond: Color(0xFFFFFFFF), // Text on secondary color

    // Semantic Colors
    success: Color(0xFF10B981), // Success green - for order success
    successLight: Color(0xFFD1FAE5), // Light success background
    error: Color(0xFFEF4444), // Error red - for errors, out of stock
    errorLight: Color(0xFFFEE2E2), // Light error background
    warning: Color(0xFFF59E0B), // Warning amber - for low stock
    warningLight: Color(0xFFFEF3C7), // Light warning background
    info: Color(0xFF3B82F6), // Info blue
    infoLight: Color(0xFFDBEAFE), // Light info background

    // Border & Divider
    border: Color(0xFFE5E7EB), // Standard borders
    borderLight: Color(0xFFF3F4F6), // Light borders
    borderDark: Color(0xFFD1D5DB), // Darker borders
    divider: Color(0xFFE5E7EB), // Divider lines

    // Interactive States
    hoverOverlay: Color(0x0A000000), // Hover state overlay
    pressedOverlay: Color(0x1F000000), // Pressed state overlay
    focusBorder: Color(0xFF004AAD), // Focus ring color

    // Icon Colors
    iconPrimary: Color(0xFF1A1A1A), // Primary icons
    iconSecondary: Color(0xFF6B7280), // Secondary icons
    iconTertiary: Color(0xFF9CA3AF), // Tertiary icons
    iconOnPrimary: Color(0xFFFFFFFF), // Icons on primary color

    // Special UI Elements
    badge: Color(0xFFFF6E40), // Badge/notification dot
    discount: Color(0xFFEF4444), // Discount tag
    rating: Color(0xFFFBBF24), // Star rating
    shimmer: Color(0xFFF3F4F6), // Shimmer loading

    // Bottom Navigation
    bottomNavBackground: Color(0xFFFFFFFF), // Bottom nav background
    bottomNavSelected: Color(0xFF004AAD), // Selected nav item
    bottomNavUnselected: Color(0xFF9CA3AF), // Unselected nav item

    // Search & Input
    searchBackground: Color(0xFFF3F4F6), // Search bar background
    inputBackground: Color(0xFFFFFFFF), // Input field background
    inputBorder: Color(0xFFE5E7EB), // Input border
    inputBorderFocused: Color(0xFF004AAD), // Input border when focused
    placeholder: Color(0xFF9CA3AF), // Placeholder text

    // Category Colors (for category icons/badges)
    categoryElectronics: Color(0xFF3B82F6),
    categoryFashion: Color(0xFFEC4899),
    categoryHome: Color(0xFF10B981),
    categoryBeauty: Color(0xFFF59E0B),
    categorySports: Color(0xFF8B5CF6),
    categoryBooks: Color(0xFF06B6D4),

    // Price & Money
    priceColor: Color(0xFF1A1A1A), // Regular price
    salePriceColor: Color(0xFFEF4444), // Sale price
    originalPriceStrike: Color(0xFF9CA3AF), // Strikethrough original price

    // Splash Screen
    splashBackground: Color(0xFF004AAD), // Splash screen background
    splashLogo: Color(0xFFFFFFFF), // Splash screen logo color

    // Skeleton Loading
    skeletonBase: Color(0xFFE5E7EB),
    skeletonHighlight: Color(0xFFF9FAFB),

    // Shadow Colors
    shadowLight: Color(0x0A000000), // Light shadow
    shadowMedium: Color(0x1A000000), // Medium shadow
    shadowHeavy: Color(0x33000000), // Heavy shadow
  );

  // ------------------ Dark Theme ------------------
  static const dark = AppColorScheme(
    // Primary Brand Colors
    colorPrimary: Color(0xFF3B82F6), // Brighter blue for dark mode
    colorSecond: Color(0xFFFF8A65), // Softer orange
    colorAccent: Color(0xFFFB8C7A), // Warm coral
    background: Color(0xFF0F172A), // Dark blue-gray background
    colorPrimaryDark: Color(0xFF2563EB), // Darker variant
    colorPrimaryLight: Color(0xFF1E293B), // Dark surface

    // Surface & Cards
    surfaceCard: Color(0xFF1E293B), // Card backgrounds
    surfaceElevated: Color(0xFF334155), // Elevated surfaces
    surfaceOverlay: Color(0x80000000), // Overlay for modals

    // Text Colors
    textPrimary: Color(0xFFF8FAFC), // Main text
    textSecondary: Color(0xFFCBD5E1), // Secondary text
    textTertiary: Color(0xFF64748B), // Tertiary text
    textOnPrimary: Color(0xFFFFFFFF), // Text on primary
    textOnSecond: Color(0xFFFFFFFF), // Text on secondary

    // Semantic Colors
    success: Color(0xFF34D399), // Brighter green for dark
    successLight: Color(0xFF064E3B), // Dark success background
    error: Color(0xFFF87171), // Brighter red for dark
    errorLight: Color(0xFF7F1D1D), // Dark error background
    warning: Color(0xFFFBBF24), // Brighter amber
    warningLight: Color(0xFF78350F), // Dark warning background
    info: Color(0xFF60A5FA), // Brighter info blue
    infoLight: Color(0xFF1E3A8A), // Dark info background

    // Border & Divider
    border: Color(0xFF334155), // Standard borders
    borderLight: Color(0xFF1E293B), // Light borders
    borderDark: Color(0xFF475569), // Darker borders
    divider: Color(0xFF334155), // Divider lines

    // Interactive States
    hoverOverlay: Color(0x14FFFFFF), // Hover state overlay
    pressedOverlay: Color(0x29FFFFFF), // Pressed state overlay
    focusBorder: Color(0xFF3B82F6), // Focus ring

    // Icon Colors
    iconPrimary: Color(0xFFF8FAFC), // Primary icons
    iconSecondary: Color(0xFFCBD5E1), // Secondary icons
    iconTertiary: Color(0xFF64748B), // Tertiary icons
    iconOnPrimary: Color(0xFFFFFFFF), // Icons on primary

    // Special UI Elements
    badge: Color(0xFFFF8A65), // Badge color
    discount: Color(0xFFF87171), // Discount tag
    rating: Color(0xFFFBBF24), // Star rating
    shimmer: Color(0xFF334155), // Shimmer loading

    // Bottom Navigation
    bottomNavBackground: Color(0xFF1E293B), // Bottom nav
    bottomNavSelected: Color(0xFF3B82F6), // Selected item
    bottomNavUnselected: Color(0xFF64748B), // Unselected item

    // Search & Input
    searchBackground: Color(0xFF1E293B), // Search bar
    inputBackground: Color(0xFF1E293B), // Input field
    inputBorder: Color(0xFF334155), // Input border
    inputBorderFocused: Color(0xFF3B82F6), // Focused border
    placeholder: Color(0xFF64748B), // Placeholder

    // Category Colors
    categoryElectronics: Color(0xFF60A5FA),
    categoryFashion: Color(0xFFF472B6),
    categoryHome: Color(0xFF34D399),
    categoryBeauty: Color(0xFFFBBF24),
    categorySports: Color(0xFFA78BFA),
    categoryBooks: Color(0xFF22D3EE),

    // Price & Money
    priceColor: Color(0xFFF8FAFC), // Regular price
    salePriceColor: Color(0xFFF87171), // Sale price
    originalPriceStrike: Color(0xFF64748B), // Strikethrough

    // Splash Screen
    splashBackground: Color(0xFF1E293B), // Splash background
    splashLogo: Color(0xFF3B82F6), // Splash logo

    // Skeleton Loading
    skeletonBase: Color(0xFF334155),
    skeletonHighlight: Color(0xFF475569),

    // Shadow Colors
    shadowLight: Color(0x14000000),
    shadowMedium: Color(0x29000000),
    shadowHeavy: Color(0x52000000),
  );
}

/// Color scheme class with all eCommerce-specific colors
class AppColorScheme {
  // Primary Brand Colors
  final Color colorPrimary;
  final Color colorSecond;
  final Color colorAccent;
  final Color background;
  final Color colorPrimaryDark;
  final Color colorPrimaryLight;

  // Surface & Cards
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color surfaceOverlay;

  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color textOnSecond;

  // Semantic Colors
  final Color success;
  final Color successLight;
  final Color error;
  final Color errorLight;
  final Color warning;
  final Color warningLight;
  final Color info;
  final Color infoLight;

  // Border & Divider
  final Color border;
  final Color borderLight;
  final Color borderDark;
  final Color divider;

  // Interactive States
  final Color hoverOverlay;
  final Color pressedOverlay;
  final Color focusBorder;

  // Icon Colors
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconTertiary;
  final Color iconOnPrimary;

  // Special UI Elements
  final Color badge;
  final Color discount;
  final Color rating;
  final Color shimmer;

  // Bottom Navigation
  final Color bottomNavBackground;
  final Color bottomNavSelected;
  final Color bottomNavUnselected;

  // Search & Input
  final Color searchBackground;
  final Color inputBackground;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color placeholder;

  // Category Colors
  final Color categoryElectronics;
  final Color categoryFashion;
  final Color categoryHome;
  final Color categoryBeauty;
  final Color categorySports;
  final Color categoryBooks;

  // Price & Money
  final Color priceColor;
  final Color salePriceColor;
  final Color originalPriceStrike;

  // Splash Screen
  final Color splashBackground;
  final Color splashLogo;

  // Skeleton Loading
  final Color skeletonBase;
  final Color skeletonHighlight;

  // Shadow Colors
  final Color shadowLight;
  final Color shadowMedium;
  final Color shadowHeavy;

  const AppColorScheme({
    required this.colorPrimary,
    required this.colorSecond,
    required this.colorAccent,
    required this.background,
    required this.colorPrimaryDark,
    required this.colorPrimaryLight,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.surfaceOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.textOnSecond,
    required this.success,
    required this.successLight,
    required this.error,
    required this.errorLight,
    required this.warning,
    required this.warningLight,
    required this.info,
    required this.infoLight,
    required this.border,
    required this.borderLight,
    required this.borderDark,
    required this.divider,
    required this.hoverOverlay,
    required this.pressedOverlay,
    required this.focusBorder,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconTertiary,
    required this.iconOnPrimary,
    required this.badge,
    required this.discount,
    required this.rating,
    required this.shimmer,
    required this.bottomNavBackground,
    required this.bottomNavSelected,
    required this.bottomNavUnselected,
    required this.searchBackground,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.placeholder,
    required this.categoryElectronics,
    required this.categoryFashion,
    required this.categoryHome,
    required this.categoryBeauty,
    required this.categorySports,
    required this.categoryBooks,
    required this.priceColor,
    required this.salePriceColor,
    required this.originalPriceStrike,
    required this.splashBackground,
    required this.splashLogo,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.shadowLight,
    required this.shadowMedium,
    required this.shadowHeavy,
  });
}