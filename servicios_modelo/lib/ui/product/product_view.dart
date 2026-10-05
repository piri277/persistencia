import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servicios_modelo/providers/product_providers.dart';

class ProductView extends ConsumerWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis productos')),
      body: Column(
        children: [MisCategorias(), Divider(height: 2), MisProductos()],
      ),
    );
  }
}

class MisProductos extends StatelessWidget {
  const MisProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 100,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: CategoryIcons(),
            title: Text('Producto #$index'),
            subtitle: Text('Descripción del producto'),
          );
        },
      ),
    );
  }
}

class MisCategorias extends ConsumerWidget {
  const MisCategorias({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final seleccion = ref.watch(categoriaSeleccionadaProvider);

    return SizedBox(
      height: 50,
      child: categoriesAsync.when(
        data: (categories) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: const Text('Todos'),
                  selected: seleccion == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(categoriaSeleccionadaProvider.notifier)
                          .seleccionar(null);
                    }
                  },
                ),
              );
            }

            final category = categories[index - 1];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ChoiceChip(
                label: Text(category.name),
                selected: seleccion == category.slug,
                onSelected: (selected) {
                  if (selected) {
                    ref
                        .read(categoriaSeleccionadaProvider.notifier)
                        .seleccionar(category.slug);
                  }
                },
              ),
            );
          },
        ),
        error: (error, stackTrace) =>
            const Center(child: Text('Error al cargar categorías')),
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(radius: 20, child: Icon(Icons.card_travel)),
    );
  }
}
