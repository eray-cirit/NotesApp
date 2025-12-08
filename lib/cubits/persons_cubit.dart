import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/person.dart';

// States
abstract class PersonsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PersonsInitial extends PersonsState {}

class PersonsLoading extends PersonsState {}

class PersonsLoaded extends PersonsState {
  final List<Person> persons;
  final Map<int, double> personDebts;

  PersonsLoaded(this.persons, this.personDebts);

  @override
  List<Object?> get props => [persons, personDebts];
}

class PersonsError extends PersonsState {
  final String message;

  PersonsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class PersonsCubit extends Cubit<PersonsState> {
  final DatabaseHelper _db;
  int? _currentLocationId;

  PersonsCubit(this._db) : super(PersonsInitial());

  Future<void> loadPersons(int locationId) async {
    try {
      _currentLocationId = locationId;
      emit(PersonsLoading());
      final persons = await _db.getPersonsByLocation(locationId);
      
      // Her kişi için borç miktarını hesapla
      final Map<int, double> personDebts = {};
      for (var person in persons) {
        final debt = await _db.getTotalDebt(person.id!);
        personDebts[person.id!] = debt;
      }
      
      emit(PersonsLoaded(persons, personDebts));
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
