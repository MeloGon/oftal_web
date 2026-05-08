# Guía de Desarrollo de Módulos — Oftal Web

Referencia para construir nuevos módulos de forma consistente con la arquitectura existente.

---

## Tabla de contenido

1. [Arquitectura general](#1-arquitectura-general)
2. [Estructura de un módulo](#2-estructura-de-un-módulo)
3. [Paso a paso: crear un módulo nuevo](#3-paso-a-paso-crear-un-módulo-nuevo)
4. [Plantillas de código](#4-plantillas-de-código)
5. [Estándares y convenciones](#5-estándares-y-convenciones)
6. [Mejoras a aplicar en nuevos módulos](#6-mejoras-a-aplicar-en-nuevos-módulos)
7. [Widgets y utilidades compartidas](#7-widgets-y-utilidades-compartidas)
8. [Checklist antes de dar por terminado un módulo](#8-checklist-antes-de-dar-por-terminado-un-módulo)

---

## 1. Arquitectura general

El proyecto sigue **Clean Architecture** dividida en tres capas:

```
┌─────────────────────────────────────────────────────────────┐
│  FEATURES  (UI + ViewModels)                                │
│  lib/features/{nombre}/                                     │
│    viewmodels/  →  state.dart + provider.dart               │
│    views/       →  view.dart + widgets/                     │
└───────────────────────┬─────────────────────────────────────┘
                        │ ref.read(repositoryProvider)
┌───────────────────────▼─────────────────────────────────────┐
│  DATA  (Repositorios + Datasources)                         │
│  lib/core/data/                                             │
│    datasources/remote/  →  *_remote_datasource.dart         │
│    repositories/        →  *_repository_impl.dart           │
│    providers/           →  infrastructure_providers.dart    │
└───────────────────────┬─────────────────────────────────────┘
                        │ implements
┌───────────────────────▼─────────────────────────────────────┐
│  DOMAIN  (Interfaces)                                       │
│  lib/core/domain/repositories/  →  *_repository.dart        │
└─────────────────────────────────────────────────────────────┘
```

**Stack tecnológico:**
- **State management:** Riverpod (`@Riverpod`) + Freezed
- **Backend:** Supabase (PostgreSQL)
- **UI Components:** shadcn_ui + Lucide Icons
- **Navegación:** GoRouter
- **Modelos:** Freezed + json_serializable
- **Error handling:** fpdart (`Either<Failure, T>`)

---

## 2. Estructura de un módulo

```
lib/features/{nombre}/
├── viewmodels/
│   ├── {nombre}_state.dart          # Estado Freezed
│   ├── {nombre}_state.freezed.dart  # Generado
│   ├── {nombre}_provider.dart       # ViewModel Riverpod
│   └── {nombre}_provider.g.dart     # Generado
└── views/
    ├── {nombre}_view.dart           # Vista principal
    └── widgets/                     # Widgets privados del módulo
        └── ...
```

Si el módulo necesita acceso a datos propios (no usa repositorios existentes):

```
lib/core/
├── domain/repositories/
│   └── {nombre}_repository.dart        # Interface
├── data/
│   ├── datasources/remote/
│   │   └── {nombre}_remote_datasource.dart
│   └── repositories/
│       └── {nombre}_repository_impl.dart
```

Y registrar el repositorio en `lib/core/data/providers/infrastructure_providers.dart`.

---

## 3. Paso a paso: crear un módulo nuevo

### Paso 1 — Domain: definir la interface del repositorio

```dart
// lib/core/domain/repositories/{nombre}_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class {Nombre}Repository {
  Future<Either<Failure, List<{Nombre}Model>>> getAll();
  Future<Either<Failure, void>> create({Nombre}Model item);
  Future<Either<Failure, void>> update({Nombre}Model item);
  Future<Either<Failure, void>> delete(int id);
}
```

### Paso 2 — Data: datasource remoto

```dart
// lib/core/data/datasources/remote/{nombre}_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

abstract class {Nombre}RemoteDataSource {
  Future<List<{Nombre}Model>> getAll();
  Future<void> create({Nombre}Model item);
  Future<void> update({Nombre}Model item);
  Future<void> delete(int id);
}

class {Nombre}RemoteDataSourceImpl implements {Nombre}RemoteDataSource {
  final SupabaseClient client;

  {Nombre}RemoteDataSourceImpl(this.client);

  @override
  Future<List<{Nombre}Model>> getAll() async {
    final response = await client
        .from('{tabla_supabase}')
        .select()
        .order('id', ascending: false);
    return response.map((json) => {Nombre}Model.fromJson(json)).toList();
  }

  @override
  Future<void> create({Nombre}Model item) async {
    await client.from('{tabla_supabase}').insert(item.toJson());
  }

  @override
  Future<void> update({Nombre}Model item) async {
    await client
        .from('{tabla_supabase}')
        .update(item.toJson())
        .eq('id', item.id!);
  }

  @override
  Future<void> delete(int id) async {
    await client.from('{tabla_supabase}').delete().eq('id', id);
  }
}
```

### Paso 3 — Data: implementación del repositorio

```dart
// lib/core/data/repositories/{nombre}_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:oftal_web/core/data/datasources/remote/{nombre}_remote_datasource.dart';
import 'package:oftal_web/core/domain/repositories/{nombre}_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class {Nombre}RepositoryImpl implements {Nombre}Repository {
  final {Nombre}RemoteDataSource _dataSource;

  {Nombre}RepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<{Nombre}Model>>> getAll() async {
    try {
      return Right(await _dataSource.getAll());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> create({Nombre}Model item) async {
    try {
      await _dataSource.create(item);
      return const Right(null);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> update({Nombre}Model item) async {
    try {
      await _dataSource.update(item);
      return const Right(null);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
```

### Paso 4 — Registrar en infrastructure_providers.dart

```dart
// lib/core/data/providers/infrastructure_providers.dart

final {nombre}RemoteDataSourceProvider = Provider<{Nombre}RemoteDataSource>((ref) {
  return {Nombre}RemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final {nombre}RepositoryProvider = Provider<{Nombre}Repository>((ref) {
  return {Nombre}RepositoryImpl(ref.read({nombre}RemoteDataSourceProvider));
});
```

### Paso 5 — Feature: definir el State

```dart
// lib/features/{nombre}/viewmodels/{nombre}_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

part '{nombre}_state.freezed.dart';

@freezed
abstract class {Nombre}State with _${Nombre}State {
  const factory {Nombre}State({
    // — siempre presentes —
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    SnackbarConfigModel? snackbarConfig,

    // — específicos del módulo —
    @Default([]) List<{Nombre}Model> items,
    {Nombre}Model? selectedItem,
    @Default(10) int rowsPerPage,
  }) = _{Nombre}State;
}
```

### Paso 6 — Feature: definir el Provider

```dart
// lib/features/{nombre}/viewmodels/{nombre}_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import '{nombre}_state.dart';

part '{nombre}_provider.g.dart';

@Riverpod(keepAlive: true)
class {Nombre} extends _${Nombre} {
  @override
  {Nombre}State build() {
    return const {Nombre}State();
  }

  Future<void> getItems() async {
    state = state.copyWith(isLoading: true);

    final result = await ref.read({nombre}RepositoryProvider).getAll();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        items: items,
      ),
    );
  }

  Future<void> createItem({Nombre}Model item) async {
    state = state.copyWith(isLoading: true);

    final result = await ref.read({nombre}RepositoryProvider).create(item);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(
          title: 'Error',
          type: SnackbarEnum.error,
        ),
      ),
      (_) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Guardado correctamente',
          snackbarConfig: SnackbarConfigModel(
            title: 'Éxito',
            type: SnackbarEnum.success,
          ),
        );
        getItems();
      },
    );
  }

  void selectItem({Nombre}Model item) {
    state = state.copyWith(selectedItem: item);
  }

  void changeRowsPerPage(int value) {
    state = state.copyWith(rowsPerPage: value);
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }
}
```

### Paso 7 — Feature: la Vista

```dart
// lib/features/{nombre}/views/{nombre}_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/features/{nombre}/viewmodels/{nombre}_provider.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class {Nombre}View extends ConsumerWidget {
  const {Nombre}View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch({nombre}Provider);
    final notifier = ref.read({nombre}Provider.notifier);

    // Loading bloqueante (para operaciones de escritura)
    ref.listenLoading({nombre}Provider.select((s) => s.isLoading), context);

    // Snackbar de feedback
    ref.listen({nombre}Provider, (previous, next) {
      if (next.errorMessage.isNotEmpty &&
          previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(
          context,
          next.snackbarConfig ??
              SnackbarConfigModel(title: 'Aviso', type: SnackbarEnum.info),
          next.errorMessage,
        );
        Future.microtask(() => notifier.clearErrorMessage());
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          // ─── Page header ──────────────────────────────────
          // ...

          // ─── Content ──────────────────────────────────────
          // ...
        ],
      ),
    );
  }
}
```

### Paso 8 — Registrar la ruta

En `lib/core/constants/router_name.dart`:
```dart
static const String {nombre} = '/dashboard/{nombre}';
```

En `lib/router/app_router.dart`:
```dart
GoRoute(
  path: RouterName.{nombre},
  pageBuilder: (context, state) => _fadeRoute(const {Nombre}View()),
  redirect: (context, state) {
    ref.read(navigationProvider.notifier).setCurrentPage(RouterName.{nombre});
    return RouterName.{nombre};
  },
),
```

### Paso 9 — Agregar al sidebar

En `lib/shared/widgets/sidebar.dart`, agregar el nuevo `MenuItem`.

### Paso 10 — Generar código

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Plantillas de código

### Model (Freezed + json_serializable)

```dart
// lib/shared/models/{nombre}_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{nombre}_model.freezed.dart';
part '{nombre}_model.g.dart';

@freezed
class {Nombre}Model with _${Nombre}Model {
  const factory {Nombre}Model({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'nombre') required String name,
    // ... más campos
  }) = _{Nombre}Model;

  factory {Nombre}Model.fromJson(Map<String, Object?> json) =>
      _${Nombre}ModelFromJson(json);
}
```

> **Convención `@JsonKey`:** Usar `snake_case` para columnas de Supabase nuevas.
> Ejemplo: `@JsonKey(name: 'nombre_completo')`.

### Enum con alias

```dart
// lib/core/enums/{nombre}_enum.dart
enum {Nombre}Enum {
  opcionA('Opción A'),
  opcionB('Opción B'),
  opcionC('Opción C');

  const {Nombre}Enum(this.label);
  final String label;
}
```

### DataTableSource

```dart
// lib/datatables/{nombre}_datasource.dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/theme/app_text_styles.dart';
import 'package:oftal_web/shared/models/shared_models.dart';

class {Nombre}DataSource extends DataTableSource {
  final List<{Nombre}Model> items;
  final BuildContext context;
  final WidgetRef ref;

  {Nombre}DataSource({
    required this.items,
    required this.context,
    required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    final item = items[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.name, style: AppTextStyles(context).small13)),
        // ... más celdas
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;
}
```

### Dialog de formulario

```dart
// lib/features/{nombre}/views/widgets/add_{nombre}_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Add{Nombre}Dialog {
  Future<void> show(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _Add{Nombre}DialogContent(ref: ref),
    );
  }
}

class _Add{Nombre}DialogContent extends ConsumerStatefulWidget {
  const _Add{Nombre}DialogContent({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_Add{Nombre}DialogContent> createState() =>
      _Add{Nombre}DialogContentState();
}

class _Add{Nombre}DialogContentState
    extends ConsumerState<_Add{Nombre}DialogContent> {
  final _formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Agregar {nombre}'),
      child: ShadForm(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            ShadInputFormField(
              label: const Text('Nombre'),
              validator: (v) => v.isEmpty ? 'Requerido' : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                ShadButton.outline(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ShadButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Llamar al provider
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Estándares y convenciones

### Nombres de archivos

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Vista | `{nombre}_view.dart` | `sell_view.dart` |
| State | `{nombre}_state.dart` | `sell_state.dart` |
| Provider | `{nombre}_provider.dart` | `sell_provider.dart` |
| Modelo | `{nombre}_model.dart` | `patient_model.dart` |
| Datasource | `{nombre}_remote_datasource.dart` | `sale_remote_datasource.dart` |
| Repository | `{nombre}_repository.dart` / `{nombre}_repository_impl.dart` | `sale_repository.dart` |
| Extension | `{nombre}_extension.dart` | `loading_extension.dart` |
| Widget privado | `{nombre}.dart` dentro de `widgets/` | `add_resin_dialog.dart` |

### Nombres de métodos en providers

| Prefijo | Uso | Sync/Async |
|---------|-----|-----------|
| `get*` | Carga datos del servidor | `async` |
| `search*` | Búsqueda con query | `async` |
| `create*` / `insert*` | Crear registro | `async` |
| `update*` | Actualizar registro | `async` |
| `delete*` / `remove*` | Eliminar | `async` |
| `select*` | Seleccionar item en estado local | `sync` |
| `apply*` | Acción que transforma el estado | `sync` |
| `clear*` | Limpiar parte del estado | `sync` |
| `open*` / `close*` | Controlar visibilidad de dialogs | `sync` |
| `_*` | Método privado | cualquiera |

### Organización dentro de un Provider

```
1. Controladores y configuración
2. build() + lifecycle (onDispose)
3. Métodos GET (lectura)
4. Métodos CREATE/UPDATE/DELETE
5. Métodos SELECT (selección local)
6. Métodos de UI (open/close dialogs, changeRowsPerPage)
7. Métodos privados (_*)
8. Métodos de limpieza (clear*, reset*)
```

### Propiedades obligatorias en todo State

```dart
@Default(false) bool isLoading,
@Default('') String errorMessage,
SnackbarConfigModel? snackbarConfig,
```

### Separadores en vistas

Usar comentarios de sección para organizar el `build()`:

```dart
// ─── Page header ──────────────────────────────────
// ─── Filters ──────────────────────────────────────
// ─── Table ────────────────────────────────────────
// ─── Actions ──────────────────────────────────────
```

### @JsonKey en modelos

Usar **snake_case** para columnas de Supabase en módulos nuevos:

```dart
// ✅ Nuevo estándar
@JsonKey(name: 'nombre_completo') required String name,
@JsonKey(name: 'fecha_creacion') String? createdAt,

// ❌ Estilo antiguo (solo en modelos existentes legacy)
@JsonKey(name: 'NOMBRE COMPLETO') required String name,
```

### `keepAlive` en providers

```dart
// ✅ Usar keepAlive: true cuando el módulo mantiene estado entre navegaciones
@Riverpod(keepAlive: true)
class Sell extends _$Sell { ... }

// ✅ Usar @riverpod (sin keepAlive) para providers simples o de solo lectura
@riverpod
Future<List<PatientModel>> patients(Ref ref) async { ... }
```

---

## 6. Mejoras a aplicar en nuevos módulos

Estas son mejoras sobre los patrones del código legacy. **Aplicar siempre en código nuevo.**

### 6.1 Helper para el pattern de error

En lugar de repetir el bloque fold completo en cada método, usar una función privada:

```dart
// En el provider
void _handleFailure(Failure failure) {
  state = state.copyWith(
    isLoading: false,
    errorMessage: failure.message,
    snackbarConfig: SnackbarConfigModel(
      title: 'Error',
      type: SnackbarEnum.error,
    ),
  );
}

void _handleSuccess(String message) {
  state = state.copyWith(
    isLoading: false,
    errorMessage: message,
    snackbarConfig: SnackbarConfigModel(
      title: 'Éxito',
      type: SnackbarEnum.success,
    ),
  );
}

// Uso:
Future<void> createItem({Nombre}Model item) async {
  state = state.copyWith(isLoading: true);
  final result = await ref.read({nombre}RepositoryProvider).create(item);
  result.fold(_handleFailure, (_) {
    _handleSuccess('Guardado correctamente');
    getItems();
  });
}
```

### 6.2 Constantes para nombres de tabla

```dart
// lib/core/constants/database_tables.dart
class DatabaseTables {
  static const String sales = 'ventas cortas';
  static const String salesDetails = 'ventas';
  static const String patients = 'pacientes';
  static const String profiles = 'perfiles';
  static const String mounts = 'armacones';
  static const String resins = 'oftalmicos';
  // Nuevos módulos agregan aquí
}
```

Usar en datasources:
```dart
// ✅
await client.from(DatabaseTables.sales).select();

// ❌
await client.from('ventas cortas').select();
```

### 6.3 Validación en tiempo real en formularios

Usar siempre `ShadInputFormField` con `validator` en lugar de `ShadInput` sin validación:

```dart
// ✅
ShadInputFormField(
  label: const Text('Nombre'),
  validator: (v) {
    if (v.trim().isEmpty) return 'El nombre es requerido';
    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
    return null;
  },
)

// ❌
ShadInput(
  placeholder: const Text('Nombre'),
)
```

### 6.4 Tipado fuerte: evitar `dynamic`

```dart
// ✅ Usar sealed class o generics
void selectItemToSell(MountModel mount) { ... }
void selectResinToSell(ResinModel resin) { ... }

// ❌ Evitar dynamic
void selectItemToSell(dynamic item) { ... }
```

### 6.5 Dispose de controllers siempre en build()

```dart
@override
{Nombre}State build() {
  ref.onDispose(() {
    searchController.dispose();
    // Disponer todos los controllers
  });
  return const {Nombre}State();
}
```

### 6.6 Límites en queries de Supabase

```dart
// ✅ Siempre limitar resultados
final response = await client
    .from(DatabaseTables.patients)
    .select()
    .ilike('nombre_completo', '%$query%')
    .limit(50)
    .order('nombre_completo');

// ❌ Sin límite
final response = await client.from('pacientes').select();
```

---

## 7. Widgets y utilidades compartidas

### AppSpinner

Spinner consistente con la identidad visual del app.

```dart
// Uso estándar
const AppSpinner()

// Con tamaño y color custom
AppSpinner(size: 16, color: Colors.white)  // en botones
AppSpinner(size: 36)                        // en overlays grandes
```

### LoadingOverlay

Para mostrar loading sobre tablas o secciones de contenido sin bloquear toda la pantalla.

```dart
LoadingOverlay(
  isLoading: state.isLoading,
  child: TuWidget(),
)
```

### LoadingDialog (via extension)

Para operaciones que bloquean la UI (guardar, eliminar, etc.). Usar siempre la extension, no instanciar directo.

```dart
// En build():
ref.listenLoading({nombre}Provider.select((s) => s.isLoading), context);

// Con lógica post-loading (abrir dialogs después de guardar):
ref.listenLoading(
  {nombre}Provider.select((s) => s.isLoading),
  context,
  onHidden: () {
    final state = ref.read({nombre}Provider);
    if (state.someFlag) { ... }
  },
);
```

### CustomSnackbar

Para feedback de éxito, error, warning o info.

```dart
CustomSnackbar().show(
  context,
  SnackbarConfigModel(title: 'Éxito', type: SnackbarEnum.success),
  'El registro fue guardado correctamente',
);
```

Tipos disponibles: `SnackbarEnum.success`, `SnackbarEnum.error`, `SnackbarEnum.warning`, `SnackbarEnum.info`.

### ShadCard, ShadButton, ShadInput

Usar siempre los componentes de shadcn antes que los de Material:

| Material | shadcn equivalente |
|----------|-------------------|
| `Card` | `ShadCard` |
| `ElevatedButton` | `ShadButton` |
| `OutlinedButton` | `ShadButton.outline` |
| `TextButton` | `ShadButton.ghost` |
| `TextField` | `ShadInput` / `ShadInputFormField` |
| `DropdownButton` | `ShadSelect` |
| `Dialog` | `ShadDialog` |

### Widget extensions disponibles

```dart
// Padding
widget.padding(all: 16)
widget.paddingSymmetric(horizontal: 24, vertical: 12)

// Constrains
widget.constrained(width: 200, height: 40)

// Clicks
widget.onClick(() => doSomething())

// Opacity
widget.opacity(0.5)
```

---

## 8. Checklist antes de dar por terminado un módulo

### Arquitectura
- [ ] Interface de repositorio definida en `core/domain/repositories/`
- [ ] Datasource remoto con abstract + impl en `core/data/datasources/remote/`
- [ ] Repository impl en `core/data/repositories/`
- [ ] Provider registrado en `infrastructure_providers.dart`
- [ ] `build_runner` ejecutado y archivos `.g.dart` / `.freezed.dart` generados

### State
- [ ] Tiene `isLoading`, `errorMessage` y `snackbarConfig`
- [ ] Todos los valores tienen `@Default()`

### Provider
- [ ] `ref.onDispose()` limpia todos los `TextEditingController`
- [ ] Cada método async empieza con `state = state.copyWith(isLoading: true)`
- [ ] Siempre termina con `isLoading: false` en ambos branches del `fold`
- [ ] `clearErrorMessage()` existe y se llama desde la vista

### Vista
- [ ] `ref.listenLoading(...)` para loading bloqueante
- [ ] `ref.listen(...)` para mostrar snackbar de errores/éxitos y llamar `clearErrorMessage()`
- [ ] Secciones del `build()` separadas con comentarios `// ─── nombre ───`
- [ ] Usa `ShadCard`, `ShadButton`, `ShadInput` de shadcn (no widgets de Material)
- [ ] `LoadingOverlay` en tablas que cargan datos paginados

### Navegación
- [ ] Ruta agregada en `RouterName`
- [ ] `GoRoute` registrado en `app_router.dart`
- [ ] Item en el `Sidebar` (si aplica)

### Calidad
- [ ] Sin `dynamic` en firma de métodos públicos
- [ ] Sin magic strings de tablas (usar `DatabaseTables.*`)
- [ ] Queries con `.limit()` en Supabase
- [ ] Validators en todos los `ShadInputFormField`
