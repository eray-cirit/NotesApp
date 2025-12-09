import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/locations_cubit.dart';
import '../models/location.dart';
import '../models/states/locations_state.dart';
import '../widgets/custom_card.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/search_dialog.dart';
import 'persons_screen.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  String _searchQuery = '';

  Future<void> _addLocation(BuildContext context) async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Mekan Ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Mekan Adı',
            hintText: 'Örn: Barış Köyü',
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

    if (result == true && controller.text.isNotEmpty) {
      context.read<LocationsCubit>().addLocation(controller.text.trim());
    }
  }

  Future<void> _deleteLocation(BuildContext context, Location location) async {
    final confirmed = await ConfirmationDialog.showDoubleConfirmation(
      context: context,
      title: 'Mekan Sil',
      firstMessage: '${location.name} mekanını silmek istediğinize emin misiniz? '
          'Bu mekana ait tüm kişiler ve borç kayıtları silinecektir.',
      secondMessage: 'Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?',
    );

    if (confirmed && context.mounted) {
      context.read<LocationsCubit>().deleteLocation(location.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${location.name} silindi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showSearch() async {
    final query = await SearchDialog.show(
      context: context,
      initialQuery: _searchQuery,
      hintText: 'Mekan ara...',
    );

    if (query != null) {
      setState(() {
        _searchQuery = query;
      });
    }
  }

  List<Location> _filterLocations(List<Location> locations) {
    if (_searchQuery.isEmpty) return locations;
    final query = _searchQuery.toLowerCase();
    return locations.where((loc) {
      return loc.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchQuery.isEmpty
            ? const Text('Defter')
            : Text(
                'Arama: "$_searchQuery"',
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
            tooltip: 'Ara',
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              tooltip: 'Aramayı Temizle',
            ),
        ],
      ),
      body: BlocConsumer<LocationsCubit, LocationsState>(
        listener: (context, state) {
          if (state is LocationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LocationsInitial) {
            context.read<LocationsCubit>().loadLocations();
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Hata: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<LocationsCubit>().loadLocations(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (state is LocationsLoaded) {
            final allLocations = state.locations;
            final locations = _filterLocations(allLocations);

            if (allLocations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz mekan eklemediniz',
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
              onRefresh: () => context.read<LocationsCubit>().loadLocations(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonsScreen(
                              location: location,
                            ),
                          ),
                        );
                      },
                      onLongPress: () => _deleteLocation(context, location),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Detaylar için tıklayın',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
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
        onPressed: () => _addLocation(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
