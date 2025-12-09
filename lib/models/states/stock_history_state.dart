import 'package:equatable/equatable.dart';
import '../stock_history.dart';
import '../product.dart';

abstract class StockHistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockHistoryInitial extends StockHistoryState {}

class StockHistoryLoading extends StockHistoryState {}

class StockHistoryLoaded extends StockHistoryState {
  final List<StockHistory> history;
  final int productId;
  final Product product;

  StockHistoryLoaded({
    required this.history,
    required this.productId,
    required this.product,
  });

  @override
  List<Object?> get props => [history, productId, product];
}

class StockHistoryError extends StockHistoryState {
  final String message;

  StockHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
