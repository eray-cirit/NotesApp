import 'package:equatable/equatable.dart';
import '../location.dart';

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
