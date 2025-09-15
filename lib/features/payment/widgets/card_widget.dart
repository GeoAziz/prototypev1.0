import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaymentCardWidget extends StatefulWidget {
  final String cardType;
  final String last4;
  final String expiry;
  final bool isDefault;
  final VoidCallback? onTap;
  final String? heroTag;

  const PaymentCardWidget({
    Key? key,
    required this.cardType,
    required this.last4,
    required this.expiry,
    this.isDefault = false,
    this.onTap,
    this.heroTag,
  }) : super(key: key);

  @override
  State<PaymentCardWidget> createState() => _PaymentCardWidgetState();
}

class _PaymentCardWidgetState extends State<PaymentCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _showBack = !_showBack;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Hero(
        tag: widget.heroTag ?? 'card-${widget.last4}',
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_rotationAnimation.value),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade700, Colors.blue.shade900],
                    ),
                  ),
                  child: _rotationAnimation.value < math.pi / 2
                      ? _buildFrontCard()
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildBackCard(),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/${widget.cardType.toLowerCase()}_logo.png',
              height: 40,
              width: 60,
            ),
            if (widget.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '•••• •••• ••••',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 4,
              ),
            ),
            Text(
              widget.last4,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Valid Thru: ${widget.expiry}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            IconButton(
              icon: const Icon(Icons.flip, color: Colors.white70),
              onPressed: _flipCard,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackCard() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(height: 40, color: Colors.black),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: Container(height: 40, color: Colors.white24)),
              const SizedBox(width: 40),
              Container(
                width: 60,
                height: 40,
                color: Colors.white24,
                alignment: Alignment.center,
                child: const Text(
                  '***',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.flip, color: Colors.white70),
          onPressed: _flipCard,
        ),
      ],
    );
  }
}
