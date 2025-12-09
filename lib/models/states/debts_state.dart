import 'package:equatable/equatable.dart';
import '../transaction.dart' as app_transaction;

abstract class DebtsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DebtsInitial extends DebtsState {}

class DebtsLoading extends DebtsState {}

class DebtsLoaded extends DebtsState {
  final List<app_transaction.Transaction> transactions;
  final double totalDebt;
  final int personId;

  DebtsLoaded({
    required this.transactions,
    required this.totalDebt,
    required this.personId,
  });

  @override
  List<Object?> get props => [transactions, totalDebt, personId];
}

class DebtsError extends DebtsState {
  final String message;

  DebtsError(this.message);

  @override
  List<Object?> get props => [message];
}
