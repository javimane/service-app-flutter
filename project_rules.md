# Especificación del Proyecto Flutter (MCP)

Este documento sirve como contexto maestro para el desarrollo de la aplicación. Todas las tareas de codificación deben adherirse a estas reglas.

## 1. Identidad Visual (UI/UX)

- **Colores Base:**
  - `Primary`: Coral (#FF7F50)
  - `Secondary`: Azul (#2196F3)
  - `Neutral`: Gris (#9E9E9E) y Blanco (#FFFFFF)
- **Feedback Semántico:**
  - `Success`: Verde (#4CAF50) - Botones de Guardar/Enviar/Éxito.
  - `Error/Destructive`: Rojo (#F44336) - Botones de Cancelar/Eliminar/Error.

## 2. Gestión de Estado (Riverpod)

- **Herramienta:** `flutter_riverpod` + `riverpod_annotation`.
- **Regla de Oro:** Prohibido mezclar lógica de negocio en los widgets.
- **Generación de Código:** Usar siempre `@riverpod` y ejecutar `build_runner`. Los providers deben ser inmutables.

## 3. Responsividad (ScreenUtil)

- **Resoluciones Objetivo:**
  - iPhone 17 Pro Max (440x956)
  - iPhone 16 (393x852)
  - Pixel 10 XL (412x915)
  - Pixel 9 (412x892)
- **Regla:** Utilizar `.h`, `.w`, `.sp` y `.r` de `flutter_screenutil`. **No usar valores hardcodeados.**

## 4. Sistema de Alertas (AlertService)

- **Librería:** `bot_toast` o `awesome_snackbar_content`.
- **Éxito:** Fondo verde + icono check.
- **Error:** Fondo rojo + icono advertencia/error.

## 5. Navegación (GoRouter)

- **Enrutamiento:** Declarativo mediante `GoRouter`.
- **Animaciones:** Implementar `CustomTransitionPage` para transiciones de tipo `FadeTransition` o `SlideTransition`. Evitar saltos bruscos.

## 6. Listados y Carga (Infinite Scroll)

- **Paginación:** `infinite_scroll_pagination`.
- **UX de Carga:** Prohibido el uso de `CircularProgressIndicator` para listas. Usar **Shimmer effects** (esqueletos grises animados) para representar la carga de datos.

## 7. Estructura de Archivos

```text
lib/
 ├── core/
 │    ├── theme/          # Configuración de ThemeData
 │    ├── navigation/     # Configuración de GoRouter
 │    ├── services/       # AlertService, API clients
 │    └── widgets/        # Componentes comunes (Shimmers, etc.)
 ├── features/            # Arquitectura basada en funcionalidades
 │    └── [feature_name]/
 │         ├── data/      # Repositorios y Modelos
 │         ├── domain/    # Entidades
 │         └── presentation/ # Widgets y Providers (Riverpod)
```
