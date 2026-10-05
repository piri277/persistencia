import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// 1. Entidades (Tablas)
// Modelado relacional e índices
@DataClassName('ProductEntity')
class ProductsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text()();
  RealColumn get price => real()();
  RealColumn get rating => real()();
  TextColumn get category => text()();
  TextColumn get thumbnail => text()();

  // Ejemplo de Migración a v2: Agregamos una nueva columna sin romper la DB
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. DAO (Data Access Object)
@DriftAccessor(tables: [ProductsTable])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  // Consultas Reactivas: emite un nuevo List cada vez que hay cambios
  Stream<List<ProductEntity>> watchAllProducts() =>
      select(productsTable).watch();

  Stream<List<ProductEntity>> watchProductsByCategory(String category) {
    return (select(
      productsTable,
    )..where((p) => p.category.equals(category))).watch();
  }

  Future<void> insertOrUpdateProduct(ProductEntity product) {
    return into(productsTable).insertOnConflictUpdate(product);
  }

  // Transacciones: inserción en lote (mucho más rápido y seguro)
  Future<void> insertProducts(List<ProductEntity> list) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(productsTable, list);
    });
  }
}

// 3. Database configuration & Migraciones
@DriftDatabase(tables: [ProductsTable], daos: [ProductDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? e}) : super(e ?? _openConnection());

  // Incrementamos schemaVersion cuando hacemos cambios en las tablas
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migración v1 -> v2 con datos existentes
          // Agregamos la columna 'isFavorite' a la tabla que ya existía
          await m.addColumn(productsTable, productsTable.isFavorite);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
