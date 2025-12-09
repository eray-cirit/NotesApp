import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/debts_cubit.dart';
import '../cubits/operations_cubit.dart';
import '../models/person.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/operation.dart';
import '../models/states/debts_state.dart';
import '../models/states/operations_state.dart';
import '../widgets/custom_card.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/date_range_filter.dart';
import '../widgets/operation_dialog.dart';

/// Yeni kişi detay ekranı - Tab yapısı ile Borçlar ve İşlemler
class PersonDetailScreen extends StatefulWidget {
  final Person person;

  const PersonDetailScreen({super.key, required this.person});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cubitleri resetle ve başlat
    context.read<DebtsCubit>().resetState();
    context.read<OperationsCubit>().resetState();
    context.read<DebtsCubit>().loadDebts(widget.person.id!);
    context.read<OperationsCubit>().loadOperations(widget.person.id!);
  }

  @override
  void dispose() {
    // State'i temizle
    context.read<DebtsCubit>().resetState();
    context.read<OperationsCubit>().resetState();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Bugün ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Dün ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    }
  }

  final GlobalKey<_DebtsTabState> _debtsKey = GlobalKey<_DebtsTabState>();
  final GlobalKey<_OperationsTabState> _operationsKey = GlobalKey<_OperationsTabState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.person.name),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Borçlar', icon: Icon(Icons.account_balance_wallet)),
                  Tab(text: 'İşlemler', icon: Icon(Icons.medical_services)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _DebtsTab(key: _debtsKey, person: widget.person),
                _OperationsTab(key: _operationsKey, person: widget.person),
              ],
            ),
            floatingActionButton: AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                final currentTab = tabController.index;
                if (currentTab == 0) {
                  // Borçlar tab'ı - İki buton
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () => _debtsKey.currentState?._addDebt(context, true),
                        heroTag: 'debt',
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.add),
                        label: const Text('Borç Ekle'),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton.extended(
                        onPressed: () => _debtsKey.currentState?._addDebt(context, false),
                        heroTag: 'payment',
                        backgroundColor: Colors.green,
                        icon: const Icon(Icons.remove),
                        label: const Text('Ödeme Ekle'),
                      ),
                    ],
                  );
                } else {
                  // İşlemler tab'ı - Tek buton
                  return FloatingActionButton.extended(
                    onPressed: () => _operationsKey.currentState?._addOperation(context),
                    heroTag: 'operation',
                    backgroundColor: Colors.blue,
                    icon: const Icon(Icons.add),
                    label: const Text('İşlem Ekle'),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/// Borçlar Tab'ı
class _DebtsTab extends StatefulWidget {
  final Person person;

  const _DebtsTab({super.key, required this.person});

  @override
  State<_DebtsTab> createState() => _DebtsTabState();
}

class _DebtsTabState extends State<_DebtsTab> {

  Future<void> _addDebt(BuildContext context, bool isDebt) async {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isDebt ? 'Borç Ekle' : 'Ödeme Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tutar',
                prefixText: '₺ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDebt ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (result == true && amountController.text.isNotEmpty && context.mounted) {
      final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
      if (amount != null && amount > 0) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => ConfirmationDialog(
            title: 'Onay',
            message: isDebt
                ? '₺${amount.toStringAsFixed(2)} tutarında borç eklenecek. Onaylıyor musunuz?'
                : '₺${amount.toStringAsFixed(2)} tutarında ödeme eklenecek. Onaylıyor musunuz?',
            onConfirm: () {},
          ),
        );

        if (confirmed == true && context.mounted) {
          final description = descController. text.trim().isEmpty 
              ? (isDebt ? 'Borç' : 'Ödeme')
              : descController.text.trim();

          if (isDebt) {
            context.read<DebtsCubit>().addDebt(widget.person.id!, amount, description);
          } else {
            context.read<DebtsCubit>().addPayment(widget.person.id!, amount, description);
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isDebt ? 'Borç eklendi' : 'Ödeme kaydedildi'),
                backgroundColor: isDebt ? Colors.red : Colors.green,
              ),
            );
          }
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçerli bir tutar giriniz'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _deleteTransaction(BuildContext context, app_transaction.Transaction transaction) async {
    final confirmed = await ConfirmationDialog.showDoubleConfirmation(
      context: context,
      title: 'İşlem Sil',
      firstMessage: 'Bu ${transaction.isDebt() ? "borç" : "ödeme"} kaydını silmek istediğinize emin misiniz?',
      secondMessage: 'Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?',
    );

    if (confirmed && context.mounted) {
      context.read<DebtsCubit>().deleteTransaction(transaction.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşlem silindi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTransactionDetail(BuildContext context, app_transaction.Transaction transaction) {
    final dateTime = DateTime.parse(transaction.createdAt);
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR');
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(transaction.isDebt() ? 'Borç Detayı' : 'Ödeme Detayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Tutar:', '₺${transaction.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _detailRow('Tarih:', formatter.format(dateTime)),
            const SizedBox(height: 12),
            _detailRow('Açıklama:', transaction.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Bugün ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Dün ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtsCubit, DebtsState>(
      builder: (context, state) {
        if (state is DebtsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DebtsError) {
          return Center(
            child: Text('Hata: ${state.message}'),
          );
        }

        if (state is DebtsLoaded) {
          final transactions = state.transactions;
          final totalDebt = state.totalDebt;
          final isInDebt = totalDebt > 0;

          return Column(
            children: [
              // Toplam borç kartı
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isInDebt
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : totalDebt < 0
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isInDebt ? Colors.red : totalDebt < 0 ? Colors.green : Colors.blue).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isInDebt
                          ? 'TOPLAM BORÇ'
                          : totalDebt < 0
                              ? 'TOPLAM ALACAK'
                              : 'HESAP TEMİZ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(totalDebt.abs()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Filtreleme
              DateRangeFilter(
                key: ValueKey('debts_filter_${widget.person.id}'),
                onFilterChanged: (start, end) {
                  context.read<DebtsCubit>().filterByDateRange(start, end);
                },
              ),

              // İşlemler listesi
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz işlem yok',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Borç veya ödeme ekleyerek başlayın',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<DebtsCubit>().loadDebts(widget.person.id!),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            final isDebt = transaction.isDebt();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CustomCard(
                                onTap: () => _showTransactionDetail(context, transaction),
                                onLongPress: () => _deleteTransaction(context, transaction),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDebt
                                            ? Colors.red.shade100
                                            : Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                                        color: isDebt ? Colors.red : Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.description,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(transaction.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isDebt ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDebt ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// İşlemler Tab'ı  
class _OperationsTab extends StatefulWidget {
  final Person person;

  const _OperationsTab({super.key, required this.person});

  @override
  State<_OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends State<_OperationsTab> {

  Future<void> _addOperation(BuildContext context) async {
    final result = await OperationDialog.show(
      context: context,
      personName: widget.person.name,
    );

    if (result != null && context.mounted) {
      context.read<OperationsCubit>().addOperation(
        widget.person.id!,
        result['operationType'] as String,
        result['description'] as String,
        result['operationDate'] as DateTime,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İşlem kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteOperation(BuildContext context, Operation operation) async {
    final confirmed = await ConfirmationDialog.showDoubleConfirmation(
      context: context,
      title: 'İşlem Sil',
      firstMessage: 'Bu işlem kaydını silmek istediğinize emin misiniz?',
      secondMessage: 'Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?',
    );

    if (confirmed && context.mounted) {
      context.read<OperationsCubit>().deleteOperation(operation.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşlem silindi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOperationDetail(BuildContext context, Operation operation) {
    final dateTime = DateTime.parse(operation.operationDate);
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR');
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${operation.operationType} Detayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('İşlem Tipi:', operation.operationType),
            const SizedBox(height: 12),
            _detailRow('Tarih:', formatter.format(dateTime)),
            const SizedBox(height: 12),
            _detailRow('Açıklama:', operation.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('dd.MM.yyyy HH:mm', 'tr_TR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OperationsCubit, OperationsState>(
      builder: (context, state) {
        if (state is OperationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OperationsError) {
          return Center(
            child: Text('Hata: ${state.message}'),
          );
        }

        if (state is OperationsLoaded) {
          final operations = state.operations;

          return Column(
            children: [
              // Filtreleme
              DateRangeFilter(
                key: ValueKey('operations_filter_${widget.person.id}'),
                onFilterChanged: (start, end) {
                  context.read<OperationsCubit>().filterByDateRange(start, end);
                },
              ),

              // İşlemler listesi
              Expanded(
                child: operations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz işlem kaydı yok',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sağ alttaki + butonuna tıklayarak başlayın',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<OperationsCubit>().loadOperations(widget.person.id!),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: operations.length,
                          itemBuilder: (context, index) {
                            final operation = operations[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CustomCard(
                                onTap: () => _showOperationDetail(context, operation),
                                onLongPress: () => _deleteOperation(context, operation),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.medical_services,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            operation.operationType,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            operation.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(operation.operationDate),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
