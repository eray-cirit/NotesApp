import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/stock_history.dart';
import '../models/product.dart';

// States
abstract class StockHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockHistoryInitial extends StockHistoryState {}

class StockHistoryLoading extends StockHistoryState {}

class StockHistoryLoaded extends StockHistoryState {
  final List<StockHistory> histories;
  final Product product;

  StockHistoryLoaded(this.histories, this.product);

  @override
  List<Object?> get props => [histories, product];
}

class StockHistoryError extends StockHistoryState {
  final String message;

  StockHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class StockHistoryCubit extends Cubit<StockHistoryState> {
  final DatabaseHelper _db;
  int? _currentProductId;
  String? _startDate;
  String? _endDate;

  StockHistoryCubit(this._db) : super(StockHistoryInitial());

  Future<void> loadHistory(int productId) async {
    try {
      _currentProductId = productId;
      emit(StockHistoryLoading());
      
      final product = await _db.getProduct(productId);
      if (product == null) {
        emit(StockHistoryError('Ürün bulunamadı'));
        return;
      }
      
      final histories = await _db.getStockHistoryByProduct(productId);
      emit(StockHistoryLoaded(histories, product));
    } catch (e) {
      emit(StockHistoryError(e.toString()));
    }
  }

  Future<void> filterByDateRange(String? startDate, String? endDate) async {
    if (_currentProductId == null) return;
    
    try {
      _startDate = startDate;
      _endDate = endDate;
      emit(StockHistoryLoading());
      
      final product = await _db.getProduct(_currentProductId!);
      if (product == null) {
        emit(StockHistoryError('Ürün bulunamadı'));
        return;
      }
      
      List<StockHistory> histories;
      if (startDate != null && endDate != null) {
        histories = await _db.getStockHistoryByProductAndDateRange(
          _currentProductId!,
          startDate,
          endDate,
        );
      } else {
        histories = await _db.getStockHistoryByProduct(_currentProductId!);
      }
      
      emit(StockHistoryLoaded(histories, product));
    } catch (e) {
      emit(StockHistoryError(e.toString()));
    }
  }

  Future<void> refresh() async {
    if (_currentProductId == null) return;
    
    if (_startDate != null && _endDate != null) {
      await filterByDateRange(_startDate, _endDate);
    } else {
      await loadHistory(_currentProductId!);
    }
  }
}
