import 'package:flutter/material.dart';

class ServiceCard extends StatefulWidget {
  final String title;
  final double price;
  final double? priceMax;
  final String currency;
  final String pricingType;
  final String status;
  final VoidCallback? onTap;

  const ServiceCard({
    required this.title,
    required this.price,
    this.priceMax,
    this.currency = 'KES',
    this.pricingType = 'flat',
    required this.status,
    this.onTap,
    super.key,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPressed
                        ? Theme.of(context).primaryColor.withOpacity(0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.build,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.priceMax != null
                        ? 'Price: ${widget.currency} ${widget.price.toStringAsFixed(0)} - ${widget.priceMax!.toStringAsFixed(0)}${widget.pricingType == 'hourly'
                              ? "/hr"
                              : widget.pricingType == 'per_unit'
                              ? "/unit"
                              : ''}'
                        : 'Price: ${widget.currency} ${widget.price.toStringAsFixed(0)}${widget.pricingType == 'hourly'
                              ? "/hr"
                              : widget.pricingType == 'per_unit'
                              ? "/unit"
                              : ''}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.status,
                      style: TextStyle(
                        color: _getStatusColor(widget.status),
                        fontWeight: FontWeight.w500,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}
