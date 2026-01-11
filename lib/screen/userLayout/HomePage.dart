import 'dart:async';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zipkart_firebase/core/globle_provider/TheameMode.dart';
import 'package:zipkart_firebase/core/routes/routes.dart';
import 'package:zipkart_firebase/core/theme/AppColors.dart';
import 'package:collection/collection.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/Models/subcategory_model.dart';
import 'package:zipkart_firebase/Models/Product.dart';

import 'package:zipkart_firebase/Models/sale_model.dart';

import 'AccountPage.dart';
import 'CartScreen.dart';
import 'ExplorePage.dart';
import 'OffersPage.dart';
import 'package:zipkart_firebase/core/widgets/common_image.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showCategorySidebar;
  final VoidCallback onToggleSidebar;

  const HomeAppBar({
    super.key,
    required this.showCategorySidebar,
    required this.onToggleSidebar,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width >= 900;

    return AppBar(
      elevation: 0,
      title: Row(
        children: [
          // ✅ BRAND (WEB ONLY) WITH DROPDOWN ARROW
          if (isWeb) ...[
            const SizedBox(width: 12),
            Row(
              children: [
                Text(
                  'zipkart_firebase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                // ✅ DROPDOWN ARROW ONLY
                GestureDetector(
                  onTap: onToggleSidebar,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedRotation(
                      turns: showCategorySidebar ? 0.75 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        size: 24,
                        // color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 120),
          ],

          // ✅ SEARCH BAR
          Expanded(
            child: Container(
              height: 40,
              alignment: Alignment.center,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          if (isWeb) const SizedBox(width: 120),

          // ✅ CART
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              context.push(AppRoutes.CartScreen);
            },
          ),

          // ✅ PROFILE
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: isDarkTheme
                  ? AppColors.dark.colorPrimary
                  : AppColors.light.colorPrimary,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            onPressed: () {
              context.push(AppRoutes.AccountScreen);
            },
          ),
        ],
      ),
    );
  }
}

// ==================== CATEGORY SIDEBAR ====================
class CategorySidebar extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const CategorySidebar({required this.onClose, super.key});

  @override
  ConsumerState<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends ConsumerState<CategorySidebar> {
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  bool showSubcategories = false;

  void _selectCategory(CategoryModel category) {
    setState(() {
      selectedCategoryId = category.id;
      selectedSubCategoryId = null;
      showSubcategories = true;
    });
  }

  void _selectSubCategory(SubcategoryModel subCategory) {
    setState(() {
      selectedSubCategoryId = subCategory.id;
    });
  }

  void _goBack() {
    setState(() {
      showSubcategories = false;
      selectedSubCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategory = categoriesAsync.when(
      data: (categories) =>
          categories.firstWhereOrNull((c) => c.id == selectedCategoryId),
      loading: () => null,
      error: (_, __) => null,
    );

    final subcategoriesAsync = selectedCategoryId != null
        ? ref.watch(subcategoriesStreamProvider(selectedCategoryId!))
        : null;

    final hasSubcategories =
        subcategoriesAsync?.when(
          data: (subcategories) => subcategories.isNotEmpty,
          loading: () => false,
          error: (_, __) => false,
        ) ??
        false;

    return Container(
      width: 300,
      color: isDarkTheme
          ? AppColors.dark.background
          : AppColors.light.background,
      child: Column(
        children: [
          // ✅ HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showSubcategories ? selectedCategory!.name : 'Hello, 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? AppColors.dark.textPrimary
                        : AppColors.light.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),

          // ✅ BACK BUTTON (if showing subcategories)
          if (showSubcategories && hasSubcategories)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 20,
                      // color: Colors.blue
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        // color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ✅ CATEGORIES LIST
          if (!showSubcategories)
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories found'));
                  }
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategoryId == category.id;

                      return _CategoryItem(
                        category: category,
                        isSelected: isSelected,
                        hasSubcategories: true, // We'll check dynamically
                        onTap: () => _selectCategory(category),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),

          // ✅ SUBCATEGORIES LIST
          if (showSubcategories && selectedCategoryId != null)
            Expanded(
              child: subcategoriesAsync!.when(
                data: (subcategories) {
                  if (subcategories.isEmpty) {
                    return const Center(child: Text('No subcategories found'));
                  }
                  return ListView.builder(
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final subCategory = subcategories[index];
                      final isSelected =
                          selectedSubCategoryId == subCategory.id;

                      return _SubCategoryItem(
                        subCategory: subCategory,
                        isSelected: isSelected,
                        onTap: () {
                          _selectSubCategory(subCategory);
                          widget.onClose();
                          context.push(
                            AppRoutes.ProductListScreen,
                            extra: {
                              'subCategoryId': subCategory.id,
                              'categoryName': subCategory.name,
                            },
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== CATEGORY ITEM ====================
class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final bool hasSubcategories;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.hasSubcategories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (category.iconUrl != null && category.iconUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildCommonImage(
                  category.iconUrl,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorWidget: Icon(Icons.category, size: 22),
                ),
              )
            else
              Icon(Icons.category, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (hasSubcategories) Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== SUBCATEGORY ITEM ====================
class _SubCategoryItem extends StatelessWidget {
  final SubcategoryModel subCategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryItem({
    required this.subCategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subCategory.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> screenList = const [
    Homepage(),
    ExploreScreen(),
    CartScreen(),
    OffersScreeen(),
    AccountScreen(),
  ];

  int screenIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      screenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Row(
        children: [
          // if (isWide)
          // _ModernSidebar(
          //   currentIndex: screenIndex,
          //   onTap: _onItemTapped,
          // ),
          Expanded(child: screenList[screenIndex]),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _FloatingBottomNav(currentIndex: screenIndex, onTap: _onItemTapped),
    );
  }
}

/// 🎨 FLOATING PILL-SHAPED BOTTOM NAVIGATION (LIKE IMAGE)
class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _FloatingBottomNav({required this.currentIndex, required this.onTap});

  List<NavItem> get items => [
    NavItem(icon: Icons.home_rounded, label: 'Home'),
    NavItem(icon: Icons.explore_rounded, label: 'Explore'),
    NavItem(icon: Icons.shopping_bag_rounded, label: 'Cart'),
    NavItem(icon: Icons.local_offer_rounded, label: 'Offers'),
    NavItem(icon: Icons.person_rounded, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 70,
      decoration: BoxDecoration(
        color: isDarkTheme
            ? AppColors.dark.colorPrimary
            : AppColors.light.colorPrimary,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme
                ? AppColors.dark.colorPrimary
                : AppColors.light.colorPrimary,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          return _NavIcon(
            item: items[index],
            isSelected: currentIndex == index,
            onTap: () => onTap(index),
          );
        }),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? isDarkTheme
                        ? AppColors.dark.colorPrimary
                        : AppColors.light.colorPrimary
                  : Colors.white.withOpacity(0.8),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  color: isDarkTheme
                      ? AppColors.dark.colorPrimary
                      : AppColors.light.colorPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🎨 NOTION-STYLE EXPANDABLE SIDEBAR
class _ModernSidebar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _ModernSidebar({required this.currentIndex, required this.onTap});

  @override
  State<_ModernSidebar> createState() => _ModernSidebarState();
}

class _ModernSidebarState extends State<_ModernSidebar> {
  bool isExpanded = false;
  int? hoveredIndex;

  final List<NavItem> items = [
    NavItem(icon: Icons.home_rounded, label: 'Home'),
    NavItem(icon: Icons.explore_rounded, label: 'Explore'),
    NavItem(icon: Icons.shopping_bag_rounded, label: 'Cart'),
    NavItem(icon: Icons.local_offer_rounded, label: 'Offers'),
    NavItem(icon: Icons.person_rounded, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => isExpanded = true),
        onExit: (_) => setState(() {
          isExpanded = false;
          hoveredIndex = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isExpanded ? 200 : 60,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? AppColors.dark.background
                : AppColors.light.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkTheme
                  ? AppColors.dark.textTertiary
                  : AppColors.light.textTertiary,
              width: 1.5,
            ),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.blue.withOpacity(0.3),
              //   blurRadius: 5,
              //   offset: const Offset(2, 0),
              // ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (index) {
              return MouseRegion(
                onEnter: (_) => setState(() => hoveredIndex = index),
                onExit: (_) => setState(() => hoveredIndex = null),
                child: _SidebarItem(
                  item: items[index],
                  isSelected: widget.currentIndex == index,
                  isExpanded: isExpanded,
                  isHovered: hoveredIndex == index,
                  onTap: () => widget.onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

class _SidebarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final bool isExpanded;
  final bool isHovered;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.isHovered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? isDarkTheme
                    ? AppColors.dark.background
                    : AppColors.light.background
              : isHovered
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? isDarkTheme
                        ? AppColors.dark.colorPrimary
                        : AppColors.light.colorPrimary
                  : isDarkTheme
                  ? AppColors.dark.textTertiary
                  : AppColors.light.textTertiary,
              size: 24,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected
                        ? isDarkTheme
                              ? AppColors.dark.colorPrimary
                              : AppColors.light.colorPrimary
                        : isDarkTheme
                        ? AppColors.dark.textTertiary
                        : AppColors.light.textTertiary,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// CUSTOM SCROLL BEHAVIOR (ENABLE MOUSE + TOUCH DRAG)
/// ------------------------------------------------------------

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

/// ------------------------------------------------------------
/// PRODUCT DATA FROM FIRESTORE
/// ------------------------------------------------------------

/// ------------------------------------------------------------
/// HOMEPAGE
/// ------------------------------------------------------------

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage>
    with SingleTickerProviderStateMixin {
  bool _showCategorySidebar = false;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _sidebarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _showCategorySidebar = !_showCategorySidebar;
      if (_showCategorySidebar) {
        _sidebarAnimationController.forward();
      } else {
        _sidebarAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isWeb = width >= 900;

    return ScrollConfiguration(
      behavior: AppScrollBehavior(), // 🔥 FIX SCROLL INPUT
      child: Scaffold(
        appBar: HomeAppBar(
          showCategorySidebar: _showCategorySidebar,
          onToggleSidebar: _toggleSidebar,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        BannerCarousel(isDesktop: isDesktop),
                        const SizedBox(height: 32),

                        Section(title: "", child: CategoryRow()),
                        const SizedBox(height: 32),

                        PromoCardGrid(),
                        const SizedBox(height: 32),

                        const DynamicSaleSections(),
                        const SizedBox(height: 32),

                        Section(
                          title: "Recommended",
                          child: ProductGrid(maxItems: isDesktop ? 8 : 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ✅ OVERLAY (click outside to close) - Only show on web
            if (isWeb)
              AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  if (_sidebarAnimation.value == 0)
                    return const SizedBox.shrink();
                  return Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggleSidebar,
                      child: Container(
                        color: Colors.black.withOpacity(
                          0.2 * _sidebarAnimation.value,
                        ),
                      ),
                    ),
                  );
                },
              ),

            // ✅ CATEGORY SIDEBAR - RENDERED AFTER OVERLAY - Only show on web
            if (isWeb)
              AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  const sidebarWidth = 300.0;
                  return Positioned(
                    top: 0,
                    left:
                        -sidebarWidth +
                        (sidebarWidth * _sidebarAnimation.value),
                    bottom: 0,
                    child: CategorySidebar(onClose: _toggleSidebar),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// BANNER CAROUSEL (USER SWIPE + AUTO)
/// ------------------------------------------------------------

class BannerCarousel extends ConsumerStatefulWidget {
  final bool isDesktop;

  const BannerCarousel({super.key, required this.isDesktop});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final bannersAsync = ref.read(bannersStreamProvider);
      bannersAsync.whenData((banners) {
        if (banners.isNotEmpty) {
          setState(() {
            _index = (_index + 1) % banners.length;
          });
          _controller.animateToPage(
            _index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(bannersStreamProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            SizedBox(
              height: widget.isDesktop ? 340 : 220,
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: banners.length,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: banners[i].imageUrl.isNotEmpty
                      ? buildCommonImage(
                          banners[i].imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.image)),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 14 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        );
      },
      loading: () => SizedBox(
        height: widget.isDesktop ? 340 : 220,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        height: widget.isDesktop ? 340 : 220,
        child: Center(child: Text('Error loading banners: $error')),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// SALES SECTION
/// ------------------------------------------------------------

class DynamicSaleSections extends ConsumerWidget {
  const DynamicSaleSections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(activeSalesStreamProvider);

    return salesAsync.when(
      data: (sales) {
        if (sales.isEmpty) return const SizedBox.shrink();

        return Column(
          children: sales.map((sale) {
            return Column(
              children: [
                Section(
                  title: sale.name,
                  child: SaleProductList(sale: sale),
                ),
                const SizedBox(height: 32),
              ],
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class SaleProductList extends ConsumerWidget {
  final SaleModel sale;
  const SaleProductList({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByIdsProvider(sale.productIds));

    return SizedBox(
      height: 280,
      child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text("No products on sale"));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) =>
                SizedBox(width: 200, child: ProductCard(products[i])),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// SECTION
/// ------------------------------------------------------------

class Section extends StatelessWidget {
  final String title;
  final Widget child;

  const Section({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.06),
          //   blurRadius: 14,
          // ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// HORIZONTAL PRODUCT LIST (MOUSE SCROLLABLE ✅)
/// ------------------------------------------------------------

class HorizontalProducts extends ConsumerWidget {
  const HorizontalProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashSaleProductsAsync = ref.watch(flashSaleProductsProvider);
    final activeProductsAsync = ref.watch(activeProductsStreamProvider);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SizedBox(
        height: 260,
        child: flashSaleProductsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              // Fallback to active products if no flash sale products
              return activeProductsAsync.when(
                data: (allProducts) {
                  final displayProducts = allProducts.take(8).toList();
                  if (displayProducts.isEmpty) {
                    return const Center(child: Text('No products available'));
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: displayProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, i) => SizedBox(
                      width: 200,
                      child: ProductCard(displayProducts[i]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              );
            }
            final displayProducts = products.take(8).toList();
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: displayProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) =>
                  SizedBox(width: 200, child: ProductCard(displayProducts[i])),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PRODUCT GRID
/// ------------------------------------------------------------

class ProductGrid extends ConsumerWidget {
  final int maxItems;

  const ProductGrid({super.key, this.maxItems = 8});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final cols = width < 700
        ? 2
        : width < 1100
        ? 3
        : 4;

    final featuredProductsAsync = ref.watch(featuredProductsStreamProvider);
    final activeProductsAsync = ref.watch(activeProductsStreamProvider);

    return featuredProductsAsync.when(
      data: (featuredProducts) {
        final products = featuredProducts.isNotEmpty
            ? featuredProducts
            : activeProductsAsync.valueOrNull ?? [];
        final limited = products.take(maxItems).toList();

        if (limited.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        return GridView.builder(
          itemCount: limited.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, i) => ProductCard(limited[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// ------------------------------------------------------------
/// PRODUCT CARD
/// ------------------------------------------------------------

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    final displayPrice = product.salePrice ?? product.price;
    final hasDiscount =
        product.salePrice != null && product.salePrice! < product.price;

    return InkWell(
      onTap: () {
        context.push(AppRoutes.ProductDetailScreen, extra: product);
      },
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: product.images.isNotEmpty
                        ? buildCommonImage(
                            product.images.first,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            width: double.infinity,
                            height: double.infinity,
                            child: const Center(child: Icon(Icons.image)),
                          ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${((product.price - product.salePrice!) / product.price * 100).toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "₹${displayPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          "₹${product.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (product.rating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (product.reviewCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class PromoCardGrid extends StatelessWidget {
//   const PromoCardGrid({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final isDesktop = width >= 900;
//
//     return GridView.count(
//       crossAxisCount: isDesktop ? 4 : 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: 1.2,
//       children: const [
//         PromoCard(
//           title: "Revamp your home in style",
//           image: "https://images.pexels.com/photos/276583/pexels-photo-276583.jpeg",
//         ),
//         PromoCard(
//           title: "Bulk order discounts",
//           image: "https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg",
//         ),
//         PromoCard(
//           title: "Appliances up to 55% off",
//           image: "https://images.pexels.com/photos/1457842/pexels-photo-1457842.jpeg",
//         ),
//         PromoCard(
//           title: "Starting ₹49",
//           image: "https://images.pexels.com/photos/4239031/pexels-photo-4239031.jpeg",
//         ),
//       ],
//     );
//   }
// }

class PromoSection {
  final String title;
  final List<String> images;

  const PromoSection({required this.title, required this.images});
}

class PromoMultiImageCard extends StatefulWidget {
  final PromoSection section;

  const PromoMultiImageCard({super.key, required this.section});

  @override
  State<PromoMultiImageCard> createState() => _PromoMultiImageCardState();
}

class _PromoMultiImageCardState extends State<PromoMultiImageCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.ProductListScreen);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // color: isDarkTheme ? AppColors.dark.colorPrimaryLight : AppColors.light.colorPrimaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 TITLE
            Text(
              widget.section.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                // color: isDarkTheme ? AppColors.dark.textPrimary : AppColors.light.textPrimary,
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 12),

            // 🔹 IMAGE GRID (2x2)
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.section.images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: buildCommonImage(
                      widget.section.images[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 EXPLORE ALL
            Text(
              "Explore all",
              style: TextStyle(
                color: isDarkTheme
                    ? AppColors.dark.colorPrimary
                    : AppColors.light.colorPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromoCardGrid extends StatefulWidget {
  PromoCardGrid({super.key});

  @override
  State<PromoCardGrid> createState() => _PromoCardGridState();
}

class _PromoCardGridState extends State<PromoCardGrid> {
  final List<PromoSection> sections = const [
    PromoSection(
      title: "Revamp your home in style",
      images: [
        "https://images.pexels.com/photos/276583/pexels-photo-276583.jpeg",
        "https://images.pexels.com/photos/186077/pexels-photo-186077.jpeg",
        "https://images.pexels.com/photos/1643383/pexels-photo-1643383.jpeg",
        "https://images.pexels.com/photos/37347/office-stationery.jpg",
      ],
    ),
    PromoSection(
      title: "Bulk order discounts",
      images: [
        "https://images.pexels.com/photos/374074/pexels-photo-374074.jpeg",
        "https://images.pexels.com/photos/18105/pexels-photo.jpg",
        "https://images.pexels.com/photos/325153/pexels-photo-325153.jpeg",
        "https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg",
      ],
    ),
    PromoSection(
      title: "Appliances for your home",
      images: [
        "https://images.pexels.com/photos/1457842/pexels-photo-1457842.jpeg",
        "https://images.pexels.com/photos/4099356/pexels-photo-4099356.jpeg",
        "https://images.pexels.com/photos/4112604/pexels-photo-4112604.jpeg",
        "https://images.pexels.com/photos/3952047/pexels-photo-3952047.jpeg",
      ],
    ),
    PromoSection(
      title: "Starting ₹49 | Deals",
      images: [
        "https://images.pexels.com/photos/4239031/pexels-photo-4239031.jpeg",
        "https://images.pexels.com/photos/4792482/pexels-photo-4792482.jpeg",
        "https://images.pexels.com/photos/6195123/pexels-photo-6195123.jpeg",
        "https://images.pexels.com/photos/3952246/pexels-photo-3952246.jpeg",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Top Offers For You",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sections.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // IMPORTANT
          ),
          itemBuilder: (_, i) {
            return PromoMultiImageCard(section: sections[i]);
          },
        ),
      ],
    );
  }
}

class PromoCard extends StatelessWidget {
  final String title;
  final String image;

  const PromoCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: buildCommonImage(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryRow extends ConsumerWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return SizedBox(
      height: 120,
      child: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final category = categories[i];
              return InkWell(
                onTap: () {
                  context.push(
                    AppRoutes.ProductListScreen,
                    extra: {
                      'categoryId': category.id,
                      'categoryName': category.name,
                    },
                  );
                },
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔵 ICON CIRCLE BACKGROUND
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        alignment: Alignment.center,
                        child:
                            category.iconUrl != null &&
                                category.iconUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: buildCommonImage(
                                  category.iconUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorWidget: Icon(
                                    Icons.category,
                                    size: 24,
                                    color: isDarkTheme
                                        ? AppColors.dark.colorPrimary
                                        : AppColors.light.colorPrimary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.category,
                                size: 24,
                                color: isDarkTheme
                                    ? AppColors.dark.colorPrimary
                                    : AppColors.light.colorPrimary,
                              ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading categories: $error')),
      ),
    );
  }
}
