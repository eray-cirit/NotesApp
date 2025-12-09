import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/stock_history.dart';
import '../models/product.dart';
import '../models/states/stock_history_state.dart';

// Cubit
class StockHistoryCubit extends Cubit<StockHistoryState> {
  final DatabaseHelper _db;
  int? _currentProductId;
  String? _startDate;
  String? _endDate;

  StockHistoryCubit(this._db) : super(StockHistoryInitial());

  /// Reset state to initial
  void resetState() {
    _currentProductId = null;
    _startDate = null;
    _endDate = null;
    emit(StockHistoryInitial());
  }

  Future<void> loadHistory(int productId) async {
    try {
      // Eğer farklı bir product'a geçiş yapılıyorsa state'i resetle
      if (_currentProductId != null && _currentProductId != productId) {
        emit(StockHistoryInitial());
        _startDate = null;
        _endDate = null;
      }
      
      _currentProductId = productId;
      emit(StockHistoryLoading());
      
      final product = await _db.getProduct(productId);
      if (product == null) {
        emit(StockHistoryError('Ürün bulunamadı'));
        return;
      }
      
      final histories = await _db.getStockHistoryByProduct(productId);
      emit(StockHistoryLoaded(
        history: histories,
        productId: productId,
        product: product,
      ));
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
      
      emit(StockHistoryLoaded(
        history: histories,
        productId: _currentProductId!,
        product: product,
      ));
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
