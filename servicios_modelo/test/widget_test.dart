import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servicios_modelo/models/category.dart';
import 'package:servicios_modelo/models/hair.dart';
import 'package:servicios_modelo/models/product.dart';
import 'package:servicios_modelo/models/user.dart';
import 'package:servicios_modelo/providers/product_providers.dart';
import 'package:servicios_modelo/providers/user_providers.dart';
import 'package:servicios_modelo/services/product_service.dart';
import 'package:servicios_modelo/services/user_service.dart';

class FakeProductService extends ProductService {
  @override
  Future<List<Category>> getCategories() async {
    return const [Category(slug: 'beauty', name: 'Beauty')];
  }

  @override
  Future<List<Product>> getProducts({int limit = 20}) async {
    return const [
      Product(
        id: 1,
        title: 'Product 1',
        description: 'Desc 1',
        price: 12.5,
        rating: 4.8,
        category: 'beauty',
        thumbnail: 'https://example.com/1.jpg',
      ),
      Product(
        id: 2,
        title: 'Product 2',
        description: 'Desc 2',
        price: 22.0,
        rating: 4.5,
        category: 'furniture',
        thumbnail: 'https://example.com/2.jpg',
      ),
    ];
  }

  @override
  Future<List<Product>> getProductsByCategory(String slug) async {
    final allProducts = await getProducts();
    return allProducts.where((product) => product.category == slug).toList();
  }
}

class FakeUserService extends UserService {
  @override
  Future<List<String>> getHairColors() async {
    return const ['Black', 'Brown'];
  }

  @override
  Future<List<User>> getUsers({int limit = 20}) async {
    return const [
      User(
        id: 1,
        firstName: 'Ana',
        lastName: 'García',
        age: 28,
        gender: 'female',
        email: 'ana@example.com',
        phone: '111',
        image: 'https://example.com/a.jpg',
        hair: Hair(color: 'Brown', type: 'Curly'),
        city: 'Madrid',
        country: 'Spain',
        university: 'UCM',
        companyTitle: 'Engineer',
      ),
      User(
        id: 2,
        firstName: 'Luis',
        lastName: 'Pérez',
        age: 34,
        gender: 'male',
        email: 'luis@example.com',
        phone: '222',
        image: 'https://example.com/b.jpg',
        hair: Hair(color: 'Black', type: 'Straight'),
        city: 'Sevilla',
        country: 'Spain',
        university: 'US',
        companyTitle: 'Designer',
      ),
    ];
  }

  @override
  Future<List<User>> getUsersByHairColor(String color) async {
    final allUsers = await getUsers();
    return allUsers.where((user) => user.hair.color == color).toList();
  }
}

void main() {
  test(
    'product providers load categories and filter by selected category',
    () async {
      final container = ProviderContainer(
        overrides: [
          productServiceProvider.overrideWithValue(FakeProductService()),
        ],
      );
      addTearDown(container.dispose);

      final categories = await container.read(categoriesProvider.future);
      expect(categories, isNotEmpty);
      expect(categories.first.slug, 'beauty');

      expect(container.read(categoriaSeleccionadaProvider), isNull);
      container
          .read(categoriaSeleccionadaProvider.notifier)
          .seleccionar('beauty');
      expect(container.read(categoriaSeleccionadaProvider), 'beauty');

      final products = await container.read(productsProvider.future);
      expect(products, hasLength(1));
      expect(products.first.category, 'beauty');

      container
          .read(categoriaSeleccionadaProvider.notifier)
          .seleccionar('beauty');
      expect(container.read(categoriaSeleccionadaProvider), isNull);
    },
  );

  test(
    'user providers load colors and filter by selected hair color',
    () async {
      final container = ProviderContainer(
        overrides: [userServiceProvider.overrideWithValue(FakeUserService())],
      );
      addTearDown(container.dispose);

      final colors = await container.read(hairColorsProvider.future);
      expect(colors, containsAll(['Black', 'Brown']));

      expect(container.read(colorSeleccionadoProvider), isNull);
      container.read(colorSeleccionadoProvider.notifier).seleccionar('Brown');
      expect(container.read(colorSeleccionadoProvider), 'Brown');

      final users = await container.read(usersProvider.future);
      expect(users, hasLength(1));
      expect(users.first.hair.color, 'Brown');

      container.read(colorSeleccionadoProvider.notifier).seleccionar('Brown');
      expect(container.read(colorSeleccionadoProvider), isNull);
    },
  );
}
