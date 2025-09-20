import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';

class AvailabilityFilter extends StatefulWidget {
  final bool onlyAvailable;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final Function(bool) onAvailabilityChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;

  const AvailabilityFilter({
    super.key,
    required this.onlyAvailable,
    this.availableFrom,
    this.availableTo,
    required this.onAvailabilityChanged,
    required this.onDateRangeChanged,
  });

  @override
  State<AvailabilityFilter> createState() => _AvailabilityFilterState();
}

class _AvailabilityFilterState extends State<AvailabilityFilter> {
  late bool _onlyAvailable;
  DateTime? _availableFrom;
  DateTime? _availableTo;

  @override
  void initState() {
    super.initState();
    _onlyAvailable = widget.onlyAvailable;
    _availableFrom = widget.availableFrom;
    _availableTo = widget.availableTo;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Availability', style: AppTextStyles.subtitle1),
        const SizedBox(height: 16),

        // Only available toggle
        SwitchListTile(
          title: Text('Available Services Only', style: AppTextStyles.body1),
          subtitle: Text(
            'Show only services that can be booked now',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          value: _onlyAvailable,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _onlyAvailable = value;
            });
            widget.onAvailabilityChanged(value);
          },
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 16),

        // Date range selection
        Text('Specific Date Range', style: AppTextStyles.body1),
        const SizedBox(height: 8),

        // Quick date presets
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDatePreset('Today', _getTodayRange()),
            _buildDatePreset('Tomorrow', _getTomorrowRange()),
            _buildDatePreset('This Week', _getThisWeekRange()),
            _buildDatePreset('Next Week', _getNextWeekRange()),
            _buildDatePreset('This Month', _getThisMonthRange()),
          ],
        ),

        const SizedBox(height: 16),

        // Custom date range
        Row(
          children: [
            Expanded(
              child: _buildDateSelector('From', _availableFrom, (date) {
                setState(() {
                  _availableFrom = date;
                });
                widget.onDateRangeChanged(_availableFrom, _availableTo);
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector('To', _availableTo, (date) {
                setState(() {
                  _availableTo = date;
                });
                widget.onDateRangeChanged(_availableFrom, _availableTo);
              }),
            ),
          ],
        ),

        if (_availableFrom != null || _availableTo != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateRange(),
                style: AppTextStyles.body2.copyWith(color: AppColors.primary),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _availableFrom = null;
                    _availableTo = null;
                  });
                  widget.onDateRangeChanged(null, null);
                },
                child: Text(
                  'Clear',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDatePreset(String label, DateTimeRange range) {
    final isSelected =
        _availableFrom != null &&
        _availableTo != null &&
        _isSameDay(_availableFrom!, range.start) &&
        _isSameDay(_availableTo!, range.end);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _availableFrom = range.start;
            _availableTo = range.end;
          });
          widget.onDateRangeChanged(_availableFrom, _availableTo);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? _formatDate(date) : 'Select date',
              style: AppTextStyles.body2.copyWith(
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTimeRange _getTodayRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: today, end: today.add(const Duration(days: 1)));
  }

  DateTimeRange _getTomorrowRange() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return DateTimeRange(
      start: tomorrow,
      end: tomorrow.add(const Duration(days: 1)),
    );
  }

  DateTimeRange _getThisWeekRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return DateTimeRange(start: weekStart, end: weekEnd);
  }

  DateTimeRange _getNextWeekRange() {
    final thisWeek = _getThisWeekRange();
    return DateTimeRange(
      start: thisWeek.end,
      end: thisWeek.end.add(const Duration(days: 7)),
    );
  }

  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return DateTimeRange(start: monthStart, end: monthEnd);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateRange() {
    if (_availableFrom != null && _availableTo != null) {
      return '${_formatDate(_availableFrom!)} - ${_formatDate(_availableTo!)}';
    } else if (_availableFrom != null) {
      return 'From ${_formatDate(_availableFrom!)}';
    } else if (_availableTo != null) {
      return 'Until ${_formatDate(_availableTo!)}';
    }
    return '';
  }
}
