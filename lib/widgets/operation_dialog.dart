import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OperationDialog extends StatefulWidget {
  final String personName;

  const OperationDialog({
    super.key,
    required this.personName,
  });

  @override
  State<OperationDialog> createState() => _OperationDialogState();

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required String personName,
  }) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => OperationDialog(personName: personName),
    );
  }
}

class _OperationDialogState extends State<OperationDialog> {
  final _descriptionController = TextEditingController();
  final _customTypeController = TextEditingController();
  String _selectedType = 'Muayene';
  DateTime _selectedDate = DateTime.now();

  final List<String> _operationTypes = [
    'Muayene',
    'Tohumlama',
    'Aşı',
    'İğne',
    'Cerrahi',
    'Kontrol',
    'Tedavi',
    'Diğer',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
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
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  void _submit() {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen açıklama girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Diğer seçiliyse ve custom type boşsa uyar
    if (_selectedType == 'Diğer' && _customTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen işlem türünü belirtin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Diğer seçiliyse custom type kullan, değilse selected type kullan
    final operationType = _selectedType == 'Diğer'
        ? _customTypeController.text.trim()
        : _selectedType;

    Navigator.pop(context, {
      'operationType': operationType,
      'description': _descriptionController.text.trim(),
      'operationDate': _selectedDate,
    });
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(date);
    } catch (e) {
      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('İşlem Ekle - ${widget.personName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İşlem tipi seçimi
            const Text(
              'İşlem Tipi',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              items: _operationTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            
            // Diğer seçilince custom type input göster
            if (_selectedType == 'Diğer') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customTypeController,
                decoration: const InputDecoration(
                  labelText: 'İşlem Türü',
                  hintText: 'Özel işlem türünü yazın',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
            
            const SizedBox(height: 16),
            // Tarih seçimi
            const Text(
              'İşlem Tarihi',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Açıklama
            TextField(
              controller: _descriptionController,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'İşlem detaylarını girin',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
