import 'package:flutter/material.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class PopularServicesScreen extends StatefulWidget {
  const PopularServicesScreen({super.key});

  @override
  State<PopularServicesScreen> createState() => _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  String _sortBy = 'mostBooked';
  String _filter = 'all';

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

  List<Service> get _filteredServices {
    var services = demoServices.where((s) => s.isPopular).toList();
    if (_filter == 'trending') {
      services = services.where((s) => s.bookingCount > 50).toList();
    } else if (_filter == 'topRated') {
      services = services.where((s) => s.rating > 4.5).toList();
    }
    if (_sortBy == 'mostBooked') {
      services.sort((a, b) => b.bookingCount.compareTo(a.bookingCount));
    } else if (_sortBy == 'rating') {
      services.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'reviews') {
      services.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }
    return services;
  }

  void _bookService(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Booking'),
        content: Text('Book ${service.name} for \u0024${service.price}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Service booked!')));
            },
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Services')),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _filter,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                          value: 'trending',
                          child: Text('Trending'),
                        ),
                        DropdownMenuItem(
                          value: 'topRated',
                          child: Text('Top Rated'),
                        ),
                      ],
                      onChanged: (val) => setState(() => _filter = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'mostBooked',
                          child: Text('Most Booked'),
                        ),
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Rating'),
                        ),
                        DropdownMenuItem(
                          value: 'reviews',
                          child: Text('Reviews'),
                        ),
                      ],
                      onChanged: (val) => setState(() => _sortBy = val!),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredServices.isEmpty
                  ? const Center(child: Text('No popular services found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, idx) {
                        final service = _filteredServices[idx];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  service.images.isNotEmpty
                                      ? service.images.first
                                      : '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.lightGrey,
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.business,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                service.name,
                                style: AppTextStyles.headline3,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${service.rating}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            '(${service.reviewCount} reviews)',
                                            style: AppTextStyles.body2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Bookings: ${service.bookingCount}',
                                    style: AppTextStyles.body2,
                                  ),
                                  Text(
                                    'Price: \u0024${service.price}',
                                    style: AppTextStyles.body2,
                                  ),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.bookmark_border),
                                      tooltip: 'Save',
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Service saved!'),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      tooltip: 'Share',
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        // TODO: Implement share logic
                                      },
                                    ),
                                    Flexible(
                                      child: SizedBox(
                                        width: 40,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _bookService(service),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            minimumSize: const Size(30, 28),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Book',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ),
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
          ],
        ),
      ),
    );
  }
}
