import 'package:equatable/equatable.dart';
import '../operation.dart';

abstract class OperationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<Operation> operations;
  final int personId;

  OperationsLoaded({
    required this.operations,
    required this.personId,
  });

  @override
  List<Object?> get props => [operations, personId];
}

class OperationsError extends OperationsState {
  final String message;

  OperationsError(this.message);

  @override
  List<Object?> get props => [message];
}
