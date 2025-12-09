import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/location.dart';
import '../models/states/locations_state.dart';

// Cubit
class LocationsCubit extends Cubit<LocationsState> {
  final DatabaseHelper _db;

  LocationsCubit(this._db) : super(LocationsInitial());

  /// Reset state to initial
  void resetState() {
    emit(LocationsInitial());
  }

  Future<void> loadLocations() async {
    try {
      emit(LocationsLoading());
      final locations = await _db.getAllLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationsError(e.toString()));
    }
  }

  Future<void> addLocation(String name) async {
    try {
      final location = Location(
        name: name,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertLocation(location);
      await loadLocations();
    } catch (e) {
      emit(LocationsError(e.toString()));
    }
  }

  Future<void> deleteLocation(int id) async {
    try {
      await _db.deleteLocation(id);
      await loadLocations();
    } catch (e) {
      emit(LocationsError(e.toString()));
    }
  }
}
