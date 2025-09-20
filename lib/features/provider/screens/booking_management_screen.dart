import 'package:flutter/material.dart';
import '../widgets/booking_calendar_widget.dart';
import '../widgets/booking_list_view.dart';
import '../../../core/theme/app_colors.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'Upcoming',
    'In Progress',
    'Completed',
    'Cancelled',
  ];
  BookingViewType _viewType = BookingViewType.list;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(
            icon: Icon(
              _viewType == BookingViewType.list
                  ? Icons.calendar_month
                  : Icons.list,
            ),
            onPressed: _toggleViewType,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((String tab) {
          final status = _getBookingStatus(tab);
          return _viewType == BookingViewType.list
              ? BookingListView(
                  status: status,
                  onStatusChange: _updateBookingStatus,
                )
              : BookingCalendarWidget(
                  status: status,
                  onStatusChange: _updateBookingStatus,
                );
        }).toList(),
      ),
    );
  }

  void _toggleViewType() {
    setState(() {
      _viewType = _viewType == BookingViewType.list
          ? BookingViewType.calendar
          : BookingViewType.list;
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Filter Bookings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Date Range'),
                onTap: () {
                  // Show date range picker
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Service Type'),
                onTap: () {
                  // Show service type filter
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Price Range'),
                onTap: () {
                  // Show price range filter
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  BookingStatus _getBookingStatus(String tab) {
    switch (tab.toLowerCase()) {
      case 'upcoming':
        return BookingStatus.upcoming;
      case 'in progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.upcoming;
    }
  }

  Future<void> _updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    // Update booking status in the repository
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking status updated to ${newStatus.toString().split('.').last}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

enum BookingViewType { list, calendar }
