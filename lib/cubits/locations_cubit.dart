import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/location.dart';

// States
abstract class LocationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsLoaded extends LocationsState {
  final List<Location> locations;

  LocationsLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class LocationsError extends LocationsState {
  final String message;

  LocationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class LocationsCubit extends Cubit<LocationsState> {
  final DatabaseHelper _db;

  LocationsCubit(this._db) : super(LocationsInitial());

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
