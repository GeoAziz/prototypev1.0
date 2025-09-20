import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/services/service_service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/widgets/app_text_field.dart';
import 'package:poafix/features/home/widgets/popular_service_card.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, required this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceService _serviceService = ServiceService();

  List<Service>? _searchResults;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _performSearch(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _serviceService.getServices(
        searchQuery: query,
        sortBy: 'rating',
        limit: 20,
      );

      setState(() {
        _searchResults = results.services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load search results';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Services'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: AppSearchField(
              controller: _searchController,
              hint: 'Search for services...',
              onChanged: (value) => _performSearch(value),
              autofocus: true,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: AppTextStyles.body1.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _performSearch(_searchController.text),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_searchResults == null) {
      return const SizedBox.shrink();
    }

    if (_searchResults!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try using different keywords',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final service = _searchResults![index];
        return PopularServiceCard(
          service: service,
          onTap: () {
            context.push('/service/${service.id}');
          },
        );
      },
    );
  }
}
