import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as app_transaction;

// States
abstract class DebtsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DebtsInitial extends DebtsState {}

class DebtsLoading extends DebtsState {}

class DebtsLoaded extends DebtsState {
  final List<app_transaction.Transaction> transactions;
  final double totalDebt;

  DebtsLoaded(this.transactions, this.totalDebt);

  @override
  List<Object?> get props => [transactions, totalDebt];
}

class DebtsError extends DebtsState {
  final String message;

  DebtsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DebtsCubit extends Cubit<DebtsState> {
  final DatabaseHelper _db;
  int? _currentPersonId;
  String? _startDate;
  String? _endDate;

  DebtsCubit(this._db) : super(DebtsInitial());

  Future<void> loadDebts(int personId) async {
    try {
      _currentPersonId = personId;
      emit(DebtsLoading());
      
      final transactions = await _db.getTransactionsByPerson(personId);
      final totalDebt = await _db.getTotalDebt(personId);
      
      emit(DebtsLoaded(transactions, totalDebt));
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> filterByDateRange(String? startDate, String? endDate) async {
    if (_currentPersonId == null) return;
    
    try {
      _startDate = startDate;
      _endDate = endDate;
      emit(DebtsLoading());
      
      List<app_transaction.Transaction> transactions;
      if (startDate != null && endDate != null) {
        transactions = await _db.getTransactionsByPersonAndDateRange(
          _currentPersonId!,
          startDate,
          endDate,
        );
      } else {
        transactions = await _db.getTransactionsByPerson(_currentPersonId!);
      }
      
      // Filtrelenmiş işlemlerden toplam borç hesapla
      double totalDebt = 0;
      for (var t in transactions) {
        if (t.isDebt()) {
          totalDebt += t.amount;
        } else {
          totalDebt -= t.amount;
        }
      }
      
      emit(DebtsLoaded(transactions, totalDebt));
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> addDebt(int personId, double amount, String description) async {
    try {
      final transaction = app_transaction.Transaction(
        personId: personId,
        type: 'debt',
        amount: amount,
        description: description,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertTransaction(transaction);
      
      // Filtreleme varsa onu uygula, yoksa normal yükleme
      if (_startDate != null && _endDate != null) {
        await filterByDateRange(_startDate, _endDate);
      } else {
        await loadDebts(personId);
      }
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> addPayment(int personId, double amount, String description) async {
    try {
      final transaction = app_transaction.Transaction(
        personId: personId,
        type: 'payment',
        amount: amount,
        description: description,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertTransaction(transaction);
      
      // Filtreleme varsa onu uygula, yoksa normal yükleme
      if (_startDate != null && _endDate != null) {
        await filterByDateRange(_startDate, _endDate);
      } else {
        await loadDebts(personId);
      }
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    if (_currentPersonId == null) return;
    
    try {
      await _db.deleteTransaction(transactionId);
      
      // Filtreleme varsa onu uygula, yoksa normal yükleme
      if (_startDate != null && _endDate != null) {
        await filterByDateRange(_startDate, _endDate);
      } else {
        await loadDebts(_currentPersonId!);
      }
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }
}
