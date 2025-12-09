import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/operation.dart';
import '../models/states/operations_state.dart';

// Cubit
class OperationsCubit extends Cubit<OperationsState> {
  final DatabaseHelper _db;
  int? _currentPersonId;
  String? _startDate;
  String? _endDate;

  OperationsCubit(this._db) : super(OperationsInitial());

  /// Reset state to initial
  void resetState() {
    _currentPersonId = null;
    _startDate = null;
    _endDate = null;
    emit(OperationsInitial());
  }

  Future<void> loadOperations(int personId) async {
    try {
      // Eğer farklı bir person'a geçiş yapılıyorsa state'i resetle
      if (_currentPersonId != null && _currentPersonId != personId) {
        emit(OperationsInitial());
        _startDate = null;
        _endDate = null;
      }
      
      _currentPersonId = personId;
      emit(OperationsLoading());
      
      final operations = await _db.getOperationsByPerson(personId);
      emit(OperationsLoaded(
        operations: operations,
        personId: personId,
      ));
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }

  Future<void> filterByDateRange(String? startDate, String? endDate) async {
    if (_currentPersonId == null) return;
    
    try {
      _startDate = startDate;
      _endDate = endDate;
      emit(OperationsLoading());
      
      List<Operation> operations;
      if (startDate != null && endDate != null) {
        operations = await _db.getOperationsByPersonAndDateRange(
          _currentPersonId!,
          startDate,
          endDate,
        );
      } else {
        operations = await _db.getOperationsByPerson(_currentPersonId!);
      }
      
      emit(OperationsLoaded(
        operations: operations,
        personId: _currentPersonId!,
      ));
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }

  Future<void> addOperation(
    int personId,
    String operationType,
    String description,
    DateTime operationDate,
  ) async {
    try {
      final operation = Operation(
        personId: personId,
        operationType: operationType,
        description: description,
        operationDate: operationDate.toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertOperation(operation);
      
      // Filtreleme varsa onu uygula, yoksa normal yükleme
      if (_startDate != null && _endDate != null) {
        await filterByDateRange(_startDate, _endDate);
      } else {
        await loadOperations(personId);
      }
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }

  Future<void> deleteOperation(int operationId) async {
    if (_currentPersonId == null) return;
    
    try {
      await _db.deleteOperation(operationId);
      
      // Filtreleme varsa onu uygula, yoksa normal yükleme
      if (_startDate != null && _endDate != null) {
        await filterByDateRange(_startDate, _endDate);
      } else {
        await loadOperations(_currentPersonId!);
      }
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }
}
