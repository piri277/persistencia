import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../providers/user_providers.dart';
import 'punto_pelo.dart';
import 'user_detail_view.dart';

/// VISTA (lista + filtro por color de pelo)
///
/// Estructura idéntica a ProductsView: una barra de chips arriba y la lista
/// debajo. Ninguno de los dos widgets sabe del otro; los conecta el provider.

class UsersView extends ConsumerWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(usersProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: const Column(
        children: [
          _BarraDeColores(),
          Divider(height: 1),
          Expanded(child: _ListaDeUsuarios()),
        ],
      ),
    );
  }
}

/// Barra horizontal de chips, uno por color de pelo.
///
/// Widget aparte a propósito: cuando cambia la lista de usuarios, Flutter no
/// reconstruye esta barra.
class _BarraDeColores extends ConsumerWidget {
  const _BarraDeColores();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coloresAsync = ref.watch(hairColorsProvider);
    final seleccionado = ref.watch(colorSeleccionadoProvider);

    return SizedBox(
      height: 56,
      child: coloresAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, _) =>
            const Center(child: Text('No se pudieron cargar los colores')),
        data: (colores) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          // +1 porque el primer chip es "Todos", que no viene de la API.
          itemCount: colores.length + 1,
          itemBuilder: (context, index) {
            final esTodos = index == 0;
            final color = esTodos ? null : colores[index - 1];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: ChoiceChip(
                // avatar = el huequito de la izquierda del chip. Le metemos
                // el puntito para ver el color, no solo leerlo.
                avatar: esTodos ? null : PuntoPelo(color!, tamano: 15),
                label: Text(esTodos ? 'Todos' : color!),
                selected: seleccionado == color,
                // Dentro de un callback siempre `read`, nunca `watch`.
                onSelected: (_) => ref
                    .read(colorSeleccionadoProvider.notifier)
                    .seleccionar(color),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Lista de usuarios. No sabe nada del filtro: solo mira `usersProvider`.
class _ListaDeUsuarios extends ConsumerWidget {
  const _ListaDeUsuarios();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usersProvider);

    return usuariosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error al cargar usuarios $error'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(usersProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (usuarios) {
        if (usuarios.isEmpty) {
          return const Center(
            child: Text('No hay usuarios con ese color de pelo'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(usersProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: usuarios.length,
            itemBuilder: (context, index) => _TarjetaUsuario(usuarios[index]),
          ),
        );
      },
    );
  }
}

/// Una fila de la lista: foto, nombre, ocupación y el pelo.
class _TarjetaUsuario extends StatelessWidget {
  final User usuario;

  const _TarjetaUsuario(this.usuario);

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colores.surfaceContainerLow,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailView(userId: usuario.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Mismo tag que en el detalle -> la foto "vuela" al abrirlo.
              Hero(
                tag: 'usuario-${usuario.id}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: colores.surfaceContainerHighest,
                  // foregroundImage (y no backgroundImage) para que si la
                  // imagen falla se vea el icono de debajo.
                  foregroundImage: NetworkImage(usuario.image),
                  child: const Icon(Icons.person),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texto.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${usuario.age} años  ·  ${usuario.companyTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texto.bodySmall?.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        PuntoPelo(usuario.hair.color, tamano: 10),
                        const SizedBox(width: 6),
                        Text(
                          '${usuario.hair.color}  ·  ${usuario.hair.type}',
                          style: texto.labelSmall?.copyWith(
                            color: colores.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
