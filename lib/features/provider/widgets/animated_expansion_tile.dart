import 'package:flutter/material.dart';

class AnimatedExpansionTile extends StatefulWidget {
  final String title;
  final Widget content;
  final IconData? icon;
  final bool initiallyExpanded;

  const AnimatedExpansionTile({
    required this.title,
    required this.content,
    this.icon,
    this.initiallyExpanded = false,
    super.key,
  });

  @override
  State<AnimatedExpansionTile> createState() => _AnimatedExpansionTileState();
}

class _AnimatedExpansionTileState extends State<AnimatedExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<Color?> _backgroundColorTween;
  late Animation<Color?> _iconColorTween;
  late Animation<Color?> _titleColorTween;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(CurveTween(curve: Curves.easeIn)),
    );
    _backgroundColorTween = ColorTween(
      begin: Colors.transparent,
      end: Colors.grey.withOpacity(0.1),
    ).animate(_controller);
    _iconColorTween = ColorTween(
      begin: Colors.grey,
      end: Theme.of(context).primaryColor,
    ).animate(_controller);
    _titleColorTween = ColorTween(
      begin: Colors.black87,
      end: Theme.of(context).primaryColor,
    ).animate(_controller);

    _isExpanded =
        PageStorage.maybeOf(context)?.readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      PageStorage.maybeOf(context)?.writeState(context, _isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: _backgroundColorTween.value,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: _iconColorTween.value),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _titleColorTween.value,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _iconTurns,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: _iconColorTween.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: widget.content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
