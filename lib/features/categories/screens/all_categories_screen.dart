import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/models/category.dart';
import 'package:poafix/core/services/firebase_service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();

  void _navigateToCategory(BuildContext context, Category category) {
    try {
      if (category.id.isNotEmpty) {
        context.push('/categories/${category.id}');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid category ID')));
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error navigating to category: $e')),
      );
    }
  }

  Future<int> _getServiceCount(String categoryId) async {
    final services = await _firebaseService
        .collection('services')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return services.docs.length;
  }

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  String _search = '';

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'car_repair':
        return Icons.car_repair;
      case 'build':
        return Icons.build;
      case 'star':
        return Icons.star;
      // Add more cases as needed for your category icons
      default:
        return Icons.category;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Categories')),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: FutureBuilder(
          future: _firebaseService.collection('categories').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final docs = snapshot.data?.docs ?? [];
            final categories = docs
                .map((doc) {
                  try {
                    final data = doc.data();
                    debugPrint('Processing category doc ${doc.id}: $data');
                    return Category.fromJson(data);
                  } catch (e) {
                    debugPrint('Error parsing category ${doc.id}: $e');
                    return null;
                  }
                })
                .where((cat) => cat != null)
                .cast<Category>()
                .toList();
            final filtered = categories
                .where(
                  (c) => c.name.toLowerCase().contains(_search.toLowerCase()),
                )
                .toList();
            final popular = categories
                .where((c) => c.isPopular == true)
                .toList();
            final featured = categories
                .where((c) => c.isFeatured == true)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Search
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search categories',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
                const SizedBox(height: 24),
                // Popular section
                Text('Popular Categories', style: AppTextStyles.headline3),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popular.length,
                    itemBuilder: (context, idx) {
                      final cat = popular[idx];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push('/categories/${cat.id}');
                            },
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      _iconFromString(cat.icon),
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat.name,
                                    style: AppTextStyles.body1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Featured section
                Text('Featured Categories', style: AppTextStyles.headline3),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    itemBuilder: (context, idx) {
                      final cat = featured[idx];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          color: Colors.amber.shade100,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push('/categories/${cat.id}');
                            },
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.amber.shade200,
                                    child: Icon(
                                      _iconFromString(cat.icon),
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat.name,
                                    style: AppTextStyles.body1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Grid view
                Text('All Categories', style: AppTextStyles.headline3),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final cat = filtered[idx];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.push('/categories/${cat.id}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      _iconFromString(cat.icon),
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: FutureBuilder<int>(
                                      future: _getServiceCount(cat.id),
                                      builder: (context, snap) {
                                        if (snap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 20,
                                            height: 16,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '${snap.data ?? 0}',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat.name,
                                style: AppTextStyles.body1.copyWith(
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  cat.description,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
