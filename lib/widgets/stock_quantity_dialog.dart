import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockQuantityDialog extends StatefulWidget {
  final String productName;

  const StockQuantityDialog({
    super.key,
    required this.productName,
  });

  @override
  State<StockQuantityDialog> createState() => _StockQuantityDialogState();

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required String productName,
  }) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StockQuantityDialog(productName: productName),
    );
  }
}

class _StockQuantityDialogState extends State<StockQuantityDialog> {
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isAdding = true;

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir miktar girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'changeAmount': _isAdding ? quantity : -quantity,
      'description': _descriptionController.text.trim().isEmpty
          ? (_isAdding ? 'Stok Eklendi' : 'Stok Çıkarıldı')
          : _descriptionController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.productName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İşlem tipi seçimi
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('Ekle'),
                icon: Icon(Icons.add_circle_outline),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('Çıkar'),
                icon: Icon(Icons.remove_circle_outline),
              ),
            ],
            selected: {_isAdding},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _isAdding = newSelection.first;
              });
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Miktar girişi
          TextField(
            controller: _quantityController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Miktar',
              hintText: 'Adet girin',
              prefixIcon: Icon(
                _isAdding ? Icons.add : Icons.remove,
                color: _isAdding ? Colors.green : Colors.red,
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          // Açıklama
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Açıklama (Opsiyonel)',
              hintText: 'Ör: Yeni sevkiyat',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAdding ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(_isAdding ? 'Ekle' : 'Çıkar'),
        ),
      ],
    );
  }
}
