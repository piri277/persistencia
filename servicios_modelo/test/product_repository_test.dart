import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servicios_modelo/database/database.dart';
import 'package:servicios_modelo/models/product.dart';
import 'package:servicios_modelo/repositories/product_repository.dart';
import 'package:servicios_modelo/services/product_service.dart';

// Mock simple del servicio para evitar peticiones reales en los tests
class MockProductService extends ProductService {
  @override
  Future<List<Product>> getProducts({int limit = 20}) async {
    return [
      const Product(
        id: 1,
        title: 'Mock Product',
        description: 'Test',
        price: 10.0,
        rating: 4.5,
        category: 'mock_cat',
        thumbnail: 'mock.png',
      ),
    ];
  }
}

void main() {
  late AppDatabase db;
  late MockProductService mockApi;
  late ProductRepository repository;

  setUp(() {
    // Usamos base de datos en memoria para los tests: NativeDatabase.memory()
    db = AppDatabase(e: NativeDatabase.memory());
    mockApi = MockProductService();
    repository = ProductRepository(db, mockApi);
  });

  tearDown(() async {
    await db.close();
  });

  test('refreshProducts guarda los datos en local', () async {
    // 1. Ejecutamos refresh
    await repository.refreshProducts();

    // 2. Verificamos que se guardaron en la BD leyendo el Stream
    final productsStream = repository.watchProducts();
    final localProducts = await productsStream.first;

    expect(localProducts.length, 1);
    expect(localProducts.first.title, 'Mock Product');
  });

  test('toggleFavorite cambia el estado del producto local', () async {
    await repository.refreshProducts();
    var localProducts = await repository.watchProducts().first;

    // Obtenemos de la entidad directamente para testear el booleano
    var entity = await db.select(db.productsTable).getSingle();
    expect(entity.isFavorite, false); // valor por defecto de v2

    // Modificamos
    await repository.toggleFavorite(localProducts.first, true);

    // Verificamos
    entity = await db.select(db.productsTable).getSingle();
    expect(entity.isFavorite, true);
  });
}
