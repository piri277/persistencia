# Diagrama C4 nivel 2 - servicios_modelo

Este proyecto sigue una arquitectura por capas con Riverpod:

- Capa de presentación: vistas y widgets
- Capa de estado: providers de Riverpod
- Capa de datos: servicios y modelos
- Capa externa: API de DummyJSON

```mermaid
flowchart LR
    User["Usuario"] --> View["Views / UI"]
    View --> Provider["Riverpod Providers"]
    Provider --> Service["Services"]
    Service --> Model["Models"]
    Service --> API["DummyJSON API"]

    subgraph App["servicios_modelo"]
        View
        Provider
        Service
        Model
    end
```

![Diagrama C4 nivel 2 de servicios_modelo](./diagrama.png)

## Descripción

- La vista no conoce cómo se cargan los datos: solo consume providers.
- Los providers orquestan la lógica de estado y coordinar la fuente de datos.
- Los servicios encapsulan las llamadas HTTP y la transformación de JSON.
- Los modelos representan el dominio para que la UI trabaje con tipos seguros.
