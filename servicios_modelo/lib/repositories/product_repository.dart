import 'package:servicios_modelo/models/product.dart';
import 'package:servicios_modelo/services/product_service.dart';
import '../database/database.dart';

class ProductRepository {
  final AppDatabase _db;
  final ProductService _api;

  ProductRepository(this._db, this._api);

  // 1. Consulta Reactiva: La UI se suscribe a este Stream
  Stream<List<Product>> watchProducts() {
    return _db.productDao.watchAllProducts().map((entities) {
      return entities
          .map(
            (e) => Product(
              id: e.id,
              title: e.title,
              description: e.description,
              price: e.price,
              rating: e.rating,
              category: e.category,
              thumbnail: e.thumbnail,
            ),
          )
          .toList();
    });
  }

  // 2. Sincronización API -> BD local
  Future<void> refreshProducts() async {
    try {
      // Obtenemos los datos de la API (Servicio remoto)
      final apiProducts = await _api.getProducts();

      // Los mapeamos a entidades de Drift
      final entities = apiProducts
          .map(
            (p) => ProductEntity(
              id: p.id,
              title: p.title,
              description: p.description,
              price: p.price,
              rating: p.rating,
              category: p.category,
              thumbnail: p.thumbnail,
              isFavorite: false, // Por defecto en v2
            ),
          )
          .toList();

      // Guardamos en lote usando transacciones (rápido y seguro)
      await _db.productDao.insertProducts(entities);
    } catch (e) {
      // Manejar error de conexión, etc.
      rethrow;
    }
  }

  // 3. Modificación local (ej. marcar favorito)
  Future<void> toggleFavorite(Product product, bool isFavorite) async {
    final entity = ProductEntity(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      rating: product.rating,
      category: product.category,
      thumbnail: product.thumbnail,
      isFavorite: isFavorite,
    );
    await _db.productDao.insertOrUpdateProduct(entity);
  }
}
