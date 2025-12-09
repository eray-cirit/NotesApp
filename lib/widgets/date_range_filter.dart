import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatefulWidget {
  final Function(String?, String?) onFilterChanged;
  final String? initialStartDate;
  final String? initialEndDate;

  const DateRangeFilter({
    super.key,
    required this.onFilterChanged,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    try {
      if (widget.initialStartDate != null && widget.initialStartDate!.isNotEmpty) {
        _startDate = DateTime.parse(widget.initialStartDate!);
      }
    } catch (e) {
      // Tarih parse hatası durumunda null olarak bırak
      _startDate = null;
    }
    
    try {
      if (widget.initialEndDate != null && widget.initialEndDate!.isNotEmpty) {
        _endDate = DateTime.parse(widget.initialEndDate!);
      }
    } catch (e) {
      // Tarih parse hatası durumunda null olarak bırak
      _endDate = null;
    }
  }

  @override
  void didUpdateWidget(DateRangeFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent'tan initial değerler değişirse state'i güncelle
    if (widget.initialStartDate != oldWidget.initialStartDate ||
        widget.initialEndDate != oldWidget.initialEndDate) {
      _updateDatesFromWidget();
    }
  }

  void _updateDatesFromWidget() {
    try {
      if (widget.initialStartDate != null && widget.initialStartDate!.isNotEmpty) {
        _startDate = DateTime.parse(widget.initialStartDate!);
      } else {
        _startDate = null;
      }
    } catch (e) {
      _startDate = null;
    }
    
    try {
      if (widget.initialEndDate != null && widget.initialEndDate!.isNotEmpty) {
        _endDate = DateTime.parse(widget.initialEndDate!);
      } else {
        _endDate = null;
      }
    } catch (e) {
      _endDate = null;
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      initialEntryMode: DatePickerEntryMode.calendarOnly, // YENİ - Sadece takvim modu
      locale: const Locale('tr', 'TR'),
      helpText: 'TARİH ARALIĞI SEÇİN',
      saveText: 'TAMAM',
      cancelText: 'İPTAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onFilterChanged(
        _startDate!.toIso8601String(),
        _endDate!.toIso8601String(),
      );
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onFilterChanged(null, null);
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd.MM.yyyy', 'tr_TR').format(date);
    } catch (e) {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _startDate != null && _endDate != null;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: hasFilter
                ? Text(
                    '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Text(
                    'Tarih Aralığı Seç',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: _clearFilter,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Filtreyi Temizle',
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () => _pickDateRange(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Tarih Seç',
          ),
        ],
      ),
    );
  }
}
