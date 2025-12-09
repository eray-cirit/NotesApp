import 'package:flutter_bloc/flutter_bloc.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/stock_history.dart';
import '../models/states/products_state.dart';

// Cubit
class ProductsCubit extends Cubit<ProductsState> {
  final DatabaseHelper _db;

  ProductsCubit(this._db) : super(ProductsInitial());

  /// Reset state to initial
  void resetState() {
    emit(ProductsInitial());
  }

  Future<void> loadProducts() async {
    try {
      emit(ProductsLoading());
      final products = await _db.getAllProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> addProduct(String name, String imagePath) async {
    try {
      final product = Product(
        name: name,
        imagePath: imagePath,
        quantity: 0,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> updateStock(
    int productId,
    int changeAmount,
    String description,
  ) async {
    try {
      // Mevcut ürünü al
      final product = await _db.getProduct(productId);
      if (product == null) return;

      // Stok miktarını güncelle
      final newQuantity = product.quantity + changeAmount;
      if (newQuantity < 0) {
        emit(ProductsError('Stok miktarı negatif olamaz'));
        return;
      }

      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        imagePath: product.imagePath,
        quantity: newQuantity,
        createdAt: product.createdAt,
      );

      await _db.updateProduct(updatedProduct);

      // Stok geçmişine ekle
      final history = StockHistory(
        productId: productId,
        changeAmount: changeAmount,
        description: description,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertStockHistory(history);

      await loadProducts();
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _db.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
