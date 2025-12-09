import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/persons_cubit.dart';
import '../models/location.dart';
import '../models/person.dart';
import '../models/states/persons_state.dart';
import '../widgets/custom_card.dart';
import '../widgets/confirmation_dialog.dart';
import 'person_detail_screen.dart';

class PersonsScreen extends StatefulWidget {
  final Location location;

  const PersonsScreen({super.key, required this.location});

  @override
  State<PersonsScreen> createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  @override
  void initState() {
    super.initState();
    // State'i resetle ve kişileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonsCubit>().resetState();
      context.read<PersonsCubit>().loadPersons(widget.location.id!);
    });
  }

  @override
  void dispose() {
    // State'i temizle
    context.read<PersonsCubit>().resetState();
    super.dispose();
  }

  Future<void> _addPerson(BuildContext context) async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Kişi Ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Kişi Adı',
            hintText: 'Örn: Ahmet Yılmaz',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty && context.mounted) {
      context.read<PersonsCubit>().addPerson(widget.location.id!, controller.text.trim());
    }
  }

  Future<void> _deletePerson(BuildContext context, Person person) async {
    final confirmed = await ConfirmationDialog.showDoubleConfirmation(
      context: context,
      title: 'Kişi Sil',
      firstMessage: '${person.name} kişisini silmek istediğinize emin misiniz? '
          'Bu kişiye ait tüm borç kayıtları silinecektir.',
      secondMessage: 'Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?',
    );

    if (confirmed && context.mounted) {
      context.read<PersonsCubit>().deletePerson(person.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${person.name} silindi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatCurrency(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
      ),
      body: BlocConsumer<PersonsCubit, PersonsState>(
        listener: (context, state) {
          if (state is PersonsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PersonsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PersonsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PersonsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Hata: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<PersonsCubit>().loadPersons(widget.location.id!),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (state is PersonsLoaded) {
            final persons = state.persons;
            final personDebts = state.personDebts;

            if (persons.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz kişi eklemediniz',
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
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<PersonsCubit>().loadPersons(widget.location.id!),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index];
                  final debt = personDebts[person.id!] ?? 0.0;
                  final isInDebt = debt > 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonDetailScreen(
                              person: person,
                            ),
                          ),
                        );
                      },
                      onLongPress: () => _deletePerson(context, person),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isInDebt
                                    ? [Colors.red.shade300, Colors.red.shade500]
                                    : debt < 0
                                        ? [Colors.green.shade300, Colors.green.shade500]
                                        : [Colors.blue.shade300, Colors.blue.shade500],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isInDebt
                                  ? Icons.trending_up
                                  : debt < 0
                                      ? Icons.trending_down
                                      : Icons.check_circle,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isInDebt
                                      ? 'Borç: ${_formatCurrency(debt)}'
                                      : debt < 0
                                          ? 'Alacak: ${_formatCurrency(debt.abs())}'
                                          : 'Hesap Temiz',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isInDebt
                                        ? Colors.red
                                        : debt < 0
                                            ? Colors.green
                                            : Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPerson(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
