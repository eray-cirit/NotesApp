import 'package:equatable/equatable.dart';
import '../person.dart';

abstract class PersonsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PersonsInitial extends PersonsState {}

class PersonsLoading extends PersonsState {}

class PersonsLoaded extends PersonsState {
  final List<Person> persons;
  final Map<int, double> personDebts;
  final int locationId;

  PersonsLoaded({
    required this.persons,
    required this.personDebts,
    required this.locationId,
  });

  @override
  List<Object?> get props => [persons, personDebts, locationId];
}

class PersonsError extends PersonsState {
  final String message;

  PersonsError(this.message);

  @override
  List<Object?> get props => [message];
}
