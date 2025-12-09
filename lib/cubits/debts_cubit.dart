import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/states/debts_state.dart';

// Cubit
class DebtsCubit extends Cubit<DebtsState> {
  final DatabaseHelper _db;
  int? _currentPersonId;
  String? _startDate;
  String? _endDate;

  DebtsCubit(this._db) : super(DebtsInitial());

  /// Reset state to initial
  void resetState() {
    _currentPersonId = null;
    _startDate = null;
    _endDate = null;
    emit(DebtsInitial());
  }

  Future<void> loadDebts(int personId) async {
    try {
      // Eğer farklı bir person'a geçiş yapılıyorsa state'i resetle
      if (_currentPersonId != null && _currentPersonId != personId) {
        emit(DebtsInitial());
        _startDate = null;
        _endDate = null;
      }
      
      _currentPersonId = personId;
      emit(DebtsLoading());
      
      final transactions = await _db.getTransactionsByPerson(personId);
      final totalDebt = await _db.getTotalDebt(personId);
      
      emit(DebtsLoaded(
        transactions: transactions,
        totalDebt: totalDebt,
        personId: personId,
      ));
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
      
      emit(DebtsLoaded(
        transactions: transactions,
        totalDebt: totalDebt,
        personId: _currentPersonId!,
      ));
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
