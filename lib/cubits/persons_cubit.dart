import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/person.dart';
import '../models/states/persons_state.dart';

// Cubit
class PersonsCubit extends Cubit<PersonsState> {
  final DatabaseHelper _db;
  int? _currentLocationId;

  PersonsCubit(this._db) : super(PersonsInitial());

  /// Reset state to initial
  void resetState() {
    _currentLocationId = null;
    emit(PersonsInitial());
  }

  Future<void> loadPersons(int locationId) async {
    try {
      // Eğer farklı bir location'a geçiş yapılıyorsa state'i resetle
      if (_currentLocationId != null && _currentLocationId != locationId) {
        emit(PersonsInitial());
      }
      
      _currentLocationId = locationId;
      emit(PersonsLoading());
      final persons = await _db.getPersonsByLocation(locationId);
      
      // Her kişi için borç miktarını hesapla
      final Map<int, double> personDebts = {};
      for (var person in persons) {
        final debt = await _db.getTotalDebt(person.id!);
        personDebts[person.id!] = debt;
      }
      
      emit(PersonsLoaded(
        persons: persons,
        personDebts: personDebts,
        locationId: locationId,
      ));
    } catch (e) {
      emit(PersonsError(e.toString()));
    }
  }

  Future<void> addPerson(int locationId, String name) async {
    try {
      final person = Person(
        locationId: locationId,
        name: name,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertPerson(person);
      await loadPersons(locationId);
    } catch (e) {
      emit(PersonsError(e.toString()));
    }
  }

  Future<void> deletePerson(int id) async {
    try {
      await _db.deletePerson(id);
      if (_currentLocationId != null) {
        await loadPersons(_currentLocationId!);
      }
    } catch (e) {
      emit(PersonsError(e.toString()));
    }
  }
}
