# servicios_modelo

Aplicación Flutter con arquitectura por capas y Riverpod.

## Arquitectura por capas

La aplicación ya está organizada en capas coherentes:

- `lib/models`: modelos de dominio (`Product`, `Category`, `User`, `Hair`)
- `lib/services`: capa de acceso a datos y llamadas HTTP
- `lib/providers`: providers de Riverpod que coordinan estado y carga de datos
- `lib/views` y `lib/ui`: capa de presentación y widgets reutilizables

Esta separación permite que la UI no dependa de la API directa y que el estado quede centralizado en Riverpod.

## Diagrama C4 nivel 2

Consulta el diagrama Mermaid en [docs/architecture/c4-level-2.md](docs/architecture/c4-level-2.md).

## Pruebas de providers

La suite de pruebas incluye validación de providers para productos y usuarios, comprobando el estado de filtros y datos cargados.
