# Oftal Web - Architecture Guide

> Sistema de gestion oftalmologica construido en Flutter Web.
> Este documento es la referencia central de arquitectura. Toda IA o desarrollador
> que trabaje en este proyecto debe leerlo antes de crear o modificar codigo.

---

## Stack Tecnologico

| Capa | Tecnologia | Version |
|---|---|---|
| Framework | Flutter Web | SDK ^3.7.0 |
| State Management | Riverpod + riverpod_annotation (code-gen) | ^2.6.1 |
| Modelos / Estado | Freezed + json_serializable | ^3.1.0 |
| Routing | GoRouter | ^16.1.0 |
| Backend | Supabase (PostgreSQL + Auth) | ^2.10.0 |
| UI Library | shadcn_ui (Zinc color scheme + Poppins) | ^0.28.5 |
| Error Handling | fpdart (Either pattern) | ^1.1.0 |
| Charts | fl_chart | ^1.1.1 |
| Tables | data_table_2 | ^2.7.2 |
| PDF | pdf | ^3.11.3 |
| Locale | intl (es_ES) + timeago | - |

---

## Estructura del Proyecto

```
lib/
  main.dart                          # Entry point, Supabase init, ProviderScope

  core/                              # Infraestructura compartida (no UI)
    constants/
      app_enviroment.dart            # URLs y keys de Supabase (.env)
      app_images.dart                # Rutas de assets
      app_strings.dart               # Strings constantes
      breakpoints.dart               # Breakpoints responsivos
      constants.dart                 # Barrel
    enums/
      enums.dart                     # Barrel
      branch_enum.dart               # Sucursales (OFTALVISION / MEDILENT)
      payment_method_enum.dart       # Metodos de pago
      report_period_filter.dart      # Filtros de periodo
      ...
    errors/
      failures.dart                  # Freezed sealed class: ServerFailure, NetworkFailure, NotFoundFailure, UnknownFailure
    theme/
      app_colors.dart                # Paleta semantica centralizada (zinc, brand, sky, emerald, semantic, blue, violet, gray, etc.)
      app_spacing.dart               # Sistema de espaciado (xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, xxxl=32)
      app_text_styles.dart           # TextStyles basados en ShadTheme + Poppins
      theme.dart                     # Barrel export
    data/
      providers/
        infrastructure_providers.dart  # DI central: Supabase client -> DataSources -> Repositories
      datasources/remote/
        patient_remote_datasource.dart
        mount_remote_datasource.dart
        resin_remote_datasource.dart
        sale_remote_datasource.dart
        review_remote_datasource.dart
        seller_remote_datasource.dart
        payment_remote_datasource.dart
        expense_remote_datasource.dart
        app_config_remote_datasource.dart
        audit_log_remote_datasource.dart
      repositories/                  # Implementaciones de Repository (try/catch -> Either)
        patient_repository_impl.dart
        mount_repository_impl.dart
        ...
    domain/
      repositories/                  # Contratos abstractos (interfaces)
        patient_repository.dart      # Future<Either<Failure, T>> signatures
        mount_repository.dart
        ...

  features/                          # Modulos de funcionalidad
    dashboard/                       # Panel principal
    login/                           # Autenticacion
    add_patient/                     # Registro de pacientes
    search_patient/                  # Busqueda y gestion de pacientes
    sell/                            # Punto de venta
    sales_history/                   # Historial de ventas
    expenses/                        # Gastos
    settings/                        # Configuracion (sub-features: resins, mounts, payments_report, sales_by_seller, features, audit_logs)

  shared/                            # Codigo compartido entre features
    extensions/                      # Extension methods (ver seccion dedicada abajo)
    layouts/                         # Shell layouts (auth, dashboard, splash)
    models/                          # Modelos Freezed compartidos
    providers/                       # Providers globales (auth, navigation)
    services/                        # Servicios (local_storage, authorization)
    utils/                           # Utilidades (random_id_generator)
    views/                           # Vistas compartidas (no_page_found)
    widgets/                         # Widgets reutilizables (ver seccion dedicada abajo)

  router/
    app_router.dart                  # GoRouter config con @riverpod, auth redirect, StatefulShellRoute
    router_name.dart                 # Rutas constantes
```

---

## Estructura de un Feature

Cada feature sigue esta estructura interna:

```
features/<feature_name>/
  data/                              # DataSources locales al feature (ej: DataSource para data_table_2)
    <feature>_datasource.dart
  viewmodels/
    <feature>_provider.dart          # @riverpod Notifier con logica de negocio
    <feature>_provider.g.dart        # Generado por riverpod_generator
    <feature>_state.dart             # @freezed state class
    <feature>_state.freezed.dart     # Generado por freezed
    <feature>_form_controllers.dart  # (opcional) TextEditingControllers extraidos
  views/
    <feature>_view.dart              # Widget principal (ConsumerWidget o ConsumerStatefulWidget)
    widgets/                         # Widgets extraidos de la vista (feature-specific)
      widget_a.dart
      widget_b.dart
```

---

## Design Tokens

### AppColors (`core/theme/app_colors.dart`)

Todos los colores deben venir de `AppColors`. NUNCA usar `Color(0xff...)` directamente.

```dart
import 'package:oftal_web/core/theme/app_colors.dart';

// Categorias disponibles:
AppColors.zinc50 ... AppColors.zinc950   // Escala de grises (shadcn zinc)
AppColors.primary / primaryBg / primaryLight / primaryDark  // Brand morado
AppColors.sky / skyBg                    // Azul informativo
AppColors.emerald / emeraldBg            // Verde esmeralda
AppColors.success / successDark / successBg / successBgLight / successBorder / successDeep  // Exito
AppColors.error / errorDark / errorBg    // Error
AppColors.warning / warningDark / warningBg / warningBgLight  // Advertencia
AppColors.orange / orangeBg              // Naranja
AppColors.blue / blueDark / blueBg / blueBgDark / blueBorder  // Azul
AppColors.violetBg / violetBgLight       // Violeta
AppColors.pink / teal                    // Charts
AppColors.gray100 / gray400 / gray500    // Tailwind gray (distinto de zinc)
AppColors.efectivo / tarjeta / transferencia  // Metodos de pago
AppColors.layoutBg                       // Fondo del dashboard
```

### AppSpacing (`core/theme/app_spacing.dart`)

```dart
AppSpacing.xs    // 4.0
AppSpacing.sm    // 8.0
AppSpacing.md    // 12.0
AppSpacing.lg    // 16.0
AppSpacing.xl    // 20.0
AppSpacing.xxl   // 24.0
AppSpacing.xxxl  // 32.0
AppSpacing.pagePadding  // EdgeInsets.all(24)
```

---

## Widgets Compartidos (`shared/widgets/`)

Exportados desde `shared/widgets/widgets.dart`:

| Widget | Uso |
|---|---|
| `Navbar` | Barra superior con titulo de pagina y chip de usuario |
| `Sidebar` | Navegacion lateral |
| `MenuItem` | Item del sidebar |
| `Logo` | Logo de la app |
| `DataColHeader` | Header unificado para columnas de DataTable |
| `EmptyState` | Estado vacio reutilizable (icono + mensaje + accion opcional) |
| `CustomSnackbar` | Snackbar con tipos (success, error, info) |
| `AppSpinner` | Spinner de carga |
| `LoadingOverlay` | Overlay semi-transparente de carga |
| `LoadingDialog` | Dialog de carga |
| `AuthorizationDialog` | Dialog de autorizacion con password |
| `AppDatePickerButton` | Boton selector de fecha |
| `LinkText` | Texto con link |
| `TextSeparator` | Separador con texto central |

**Regla:** Si un widget se usa en 2+ features, debe vivir en `shared/widgets/`.

---

## Extensions (`shared/extensions/`)

Exportados desde `shared/extensions/extensions.dart`:

| Archivo | Extension | Uso |
|---|---|---|
| `widget_padding_extension.dart` | `StyledWidgetPadding` | `.padding(all:)`, `.paddingH()`, etc. |
| `widget_decoration_extension.dart` | `StyledWidgetDecoration` | `.backgroundColor()`, `.border()`, `.shadow()` |
| `widget_clip_extension.dart` | `StyledWidgetClip` | `.clipRRect()`, `.clipOval()` |
| `widget_transform_extension.dart` | `StyledWidgetTransform` | `.rotate()`, `.scale()`, `.translate()` |
| `widget_layout_extension.dart` | `StyledWidgetLayout` | `.constrained()`, `.expanded()`, `.positioned()` |
| `widget_gesture_extension.dart` | `StyledWidgetGesture` | `.gestures()`, `.onTap()` |
| `widget_margin_extension.dart` | `WidgetMarginX` | `.marginAll()`, `.sliverBox` |
| `string_extension.dart` | - | Utilidades de String |
| `double_extension.dart` | - | `.toCurrency()` formatea como moneda |
| `responsive_extension.dart` | - | Helpers responsive |
| `loading_extension.dart` | - | Helpers de loading |

---

## Patrones y Convenciones

### 1. State Management (Riverpod + Freezed)

**State classes** usan Freezed con valores default:

```dart
@freezed
abstract class FeatureState with _$FeatureState {
  const factory FeatureState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default(<ItemModel>[]) List<ItemModel> items,
    SnackbarConfigModel? snackbarConfig,
  }) = _FeatureState;
}
```

**Providers** usan @riverpod annotation (code-gen):

```dart
@riverpod
class FeatureProvider extends _$FeatureProvider {
  @override
  FeatureState build() {
    Future.microtask(_loadInitialData);
    return const FeatureState();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(repositoryProvider).getData();
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
        isLoading: false,
      ),
      (data) => state = state.copyWith(items: data, isLoading: false),
    );
  }
}
```

**Convencion de nombres:**
- Provider class: `<Feature>` (e.g., `SearchPatient`, `Dashboard`)
- State class: `<Feature>State` (e.g., `SearchPatientState`)
- En UI: `ref.watch(<feature>Provider)` para estado, `ref.read(<feature>Provider.notifier)` para acciones

### 2. Form Controllers (patron extraido)

Cuando un feature tiene multiples TextEditingControllers, se extraen a una clase dedicada:

```dart
// features/<feature>/viewmodels/<feature>_form_controllers.dart
class FeatureFormControllers {
  final name = TextEditingController();
  final email = TextEditingController();
  final date = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    date.text = DateFormat('dd-MM-yyyy').format(newDate);
  }

  void clearAll() {
    for (final c in _all) { c.clear(); }
  }

  List<TextEditingController> get _all => [name, email, date];

  void dispose() {
    for (final c in _all) { c.dispose(); }
  }
}

final featureFormControllersProvider = Provider.autoDispose<FeatureFormControllers>((ref) {
  final c = FeatureFormControllers();
  ref.onDispose(c.dispose);
  return c;
});
```

El provider principal delega con getters:
```dart
@riverpod
class Feature extends _$Feature {
  late final FeatureFormControllers _form;

  TextEditingController get nameController => _form.name;
  // ...

  @override
  FeatureState build() {
    _form = FeatureFormControllers();
    ref.onDispose(_form.dispose);
    return const FeatureState();
  }
}
```

### 3. Data Layer (Clean Architecture)

El flujo de datos sigue:

```
UI (ConsumerWidget)
  -> ref.read(featureProvider.notifier).action()
    -> ref.read(repositoryProvider).method()
      -> RepositoryImpl (try/catch -> Either<Failure, T>)
        -> RemoteDataSource (Supabase queries)
```

**DataSource** (abstracta + impl):
```dart
abstract class FooRemoteDataSource {
  Future<List<FooModel>> getAll();
}

class FooRemoteDataSourceImpl implements FooRemoteDataSource {
  final SupabaseClient client;
  FooRemoteDataSourceImpl(this.client);

  @override
  Future<List<FooModel>> getAll() async {
    final response = await client.from('table').select();
    return response.map((json) => FooModel.fromJson(json)).toList();
  }
}
```

**Repository** (abstracta + impl):
```dart
// Domain (contrato)
abstract class FooRepository {
  Future<Either<Failure, List<FooModel>>> getAll();
}

// Data (implementacion)
class FooRepositoryImpl implements FooRepository {
  final FooRemoteDataSource _dataSource;
  FooRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<FooModel>>> getAll() async {
    try {
      return Right(await _dataSource.getAll());
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
```

**DI wiring** en `infrastructure_providers.dart`:
```dart
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final fooDataSourceProvider = Provider<FooRemoteDataSource>((ref) {
  return FooRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final fooRepositoryProvider = Provider<FooRepository>((ref) {
  return FooRepositoryImpl(ref.read(fooDataSourceProvider));
});
```

### 4. Modelos (Freezed + json_serializable)

```dart
@freezed
@JsonSerializable()
class FooModel with _$FooModel {
  @override
  @JsonKey(name: 'COLUMN_NAME')
  final String fieldName;

  FooModel({required this.fieldName});

  factory FooModel.fromJson(Map<String, Object?> json) => _$FooModelFromJson(json);
  Map<String, dynamic> toJson() => _$FooModelToJson(this);
}
```

> Nota: Los nombres de columna en Supabase usan formato legacy con espacios y mayusculas
> (e.g., `"NOMBRE COMPLETO"`, `"ID PACIENTE"`). Se mapean via `@JsonKey(name: ...)`.

### 5. Error Handling

```dart
@freezed
sealed class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.notFound(String message) = NotFoundFailure;
  const factory Failure.unknown(String message) = UnknownFailure;
}
```

Siempre usar `Either<Failure, T>` en repositorios. En providers, hacer `fold`:
```dart
result.fold(
  (failure) => state = state.copyWith(errorMessage: failure.message),
  (data) => state = state.copyWith(items: data),
);
```

### 6. Routing

- GoRouter con `@riverpod` provider
- Auth redirect automatico basado en `AuthStatus` (checking/authenticated/notAuthenticated)
- `StatefulShellRoute.indexedStack` para navegacion principal con sidebar
- Subrutas de settings como rutas anidadas
- Transiciones con `FadeTransition` (200ms)
- Rutas definidas como constantes en `RouterName`

### 7. UI Patterns

- **UI Library**: shadcn_ui con `ShadZincColorScheme.light()` + `Poppins` font
- **Colores**: Siempre usar `AppColors.xxx` — NUNCA `Color(0xff...)`
- **Layouts**: Shell pattern - `AuthLayout`, `DashboardLayout`, `SplashLayout`
- **Dashboard Layout**: Sidebar fijo en desktop (>= 700px), drawer animado en mobile
- **Widget extensions**: Chainable styling via extensions en `shared/extensions/`
- **Responsive**: `LayoutBuilder` + `Breakpoints` class para adaptar layouts
- **Tables**: `data_table_2` con DataSource classes en `features/<feature>/data/`
- **Widgets en vistas**: Se usa `ConsumerWidget` para vistas principales, `ConsumerStatefulWidget` cuando hay animaciones o focus nodes

### 8. Snackbar Pattern

```dart
// En el provider:
state = state.copyWith(
  errorMessage: 'Operacion exitosa',
  snackbarConfig: SnackbarConfigModel(title: 'Aviso', type: SnackbarEnum.success),
);

// En la vista:
ref.listen(featureProvider, (previous, next) {
  if (next.errorMessage.isNotEmpty && previous?.errorMessage != next.errorMessage) {
    CustomSnackbar().show(context, next.snackbarConfig, next.errorMessage);
    Future.microtask(() => ref.read(featureProvider.notifier).clearErrorMessage());
  }
});
```

### 9. Autenticacion

- Supabase Auth con email/password
- Estado global en `authProvider` (Riverpod)
- Perfil almacenado en `LocalStorage` (shared_preferences)
- Redirect automatico via GoRouter
- `AuthorizationDialog` para acciones protegidas (requiere password de admin)

### 10. Code Generation

Ejecutar despues de cambios en modelos, estados o providers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Archivos generados (NO editar manualmente):
- `*.freezed.dart` - Freezed classes
- `*.g.dart` - json_serializable + riverpod_generator

---

## Guia para Crear un Nuevo Feature

### Paso 1: Crear estructura de carpetas

```
lib/features/<new_feature>/
  viewmodels/
    <feature>_provider.dart
    <feature>_state.dart
    <feature>_form_controllers.dart   # Solo si tiene formularios
  views/
    <feature>_view.dart
    widgets/
  data/                               # Solo si usa DataTable con DataSource custom
    <feature>_datasource.dart
```

### Paso 2: Definir el State

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';

part '<feature>_state.freezed.dart';

@freezed
abstract class NewFeatureState with _$NewFeatureState {
  const factory NewFeatureState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    SnackbarConfigModel? snackbarConfig,
    // ... campos especificos del feature
  }) = _NewFeatureState;
}
```

### Paso 3: Crear el Provider

```dart
import 'package:oftal_web/core/data/providers/infrastructure_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '<feature>_provider.g.dart';

@riverpod
class NewFeature extends _$NewFeature {
  @override
  NewFeatureState build() {
    Future.microtask(_loadInitialData);
    return const NewFeatureState();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(newFeatureRepositoryProvider).getAll();
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        snackbarConfig: SnackbarConfigModel(title: 'Error', type: SnackbarEnum.error),
        isLoading: false,
      ),
      (data) => state = state.copyWith(items: data, isLoading: false),
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: '', snackbarConfig: null);
  }
}
```

### Paso 4: Si necesita datos de Supabase

1. Crear modelo en `shared/models/` (o local al feature si es exclusivo)
2. Crear DataSource en `core/data/datasources/remote/<feature>_remote_datasource.dart`
3. Crear Repository interface en `core/domain/repositories/<feature>_repository.dart`
4. Crear Repository impl en `core/data/repositories/<feature>_repository_impl.dart`
5. Registrar providers en `core/data/providers/infrastructure_providers.dart`

### Paso 5: Crear la Vista

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/models/snackbar_config_model.dart';
import 'package:oftal_web/shared/widgets/widgets.dart';

class NewFeatureView extends ConsumerWidget {
  const NewFeatureView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newFeatureProvider);
    final notifier = ref.read(newFeatureProvider.notifier);

    ref.listen(newFeatureProvider, (previous, next) {
      if (next.errorMessage.isNotEmpty && previous?.errorMessage != next.errorMessage) {
        CustomSnackbar().show(context, next.snackbarConfig, next.errorMessage);
        Future.microtask(notifier.clearErrorMessage);
      }
    });

    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // ... UI aqui, max ~250 lineas
          // Si crece mas, extraer widgets a views/widgets/
        ],
      ),
    );
  }
}
```

### Paso 6: Registrar ruta

1. Agregar constante en `router/router_name.dart`:
   ```dart
   static const newFeature = '/dashboard/new-feature';
   ```

2. Agregar GoRoute en `router/app_router.dart` dentro del `StatefulShellRoute`

### Paso 7: Agregar al sidebar (si es navegacion principal)

En `shared/widgets/sidebar.dart`, agregar un `MenuItem`.

### Paso 8: Generar codigo

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Reglas y Restricciones

### HACER
- Usar `AppColors.xxx` para TODOS los colores
- Usar `AppSpacing.xxx` para espaciados cuando sea practico
- Usar `@riverpod` annotation (code-gen) para providers nuevos
- Usar `@freezed` para estados y modelos
- Usar `Either<Failure, T>` para resultados de repositorios
- Descomponer vistas en widgets separados cuando un archivo supere ~250 lineas
- Colocar widgets feature-specific en `features/<feature>/views/widgets/`
- Colocar widgets usados por 2+ features en `shared/widgets/`
- Registrar DataSources y Repositories en `infrastructure_providers.dart`
- Usar `ref.watch()` en build methods, `ref.read()` en callbacks
- Usar `Future.microtask()` para carga inicial en `build()` de Notifiers
- Reutilizar `DataColHeader` y `EmptyState` en vez de crear duplicados
- Extraer TextEditingControllers a clases dedicadas si son mas de 3

### NO HACER
- No usar `Color(0xff...)` directamente — siempre `AppColors`
- No crear archivos de vista con mas de 300 lineas
- No mezclar TextEditingControllers dentro de Notifier classes (extraerlos)
- No poner logica de negocio en widgets
- No editar archivos `*.freezed.dart` o `*.g.dart`
- No usar `StateProvider` o `StateNotifierProvider` (usar `@riverpod` annotation)
- No crear DataSources sin su Repository correspondiente
- No duplicar widgets que ya existen en `shared/widgets/`
- No crear imports de `dart:html` (usar `package:web` si es necesario)

---

## Naming Conventions

| Tipo | Patron | Ejemplo |
|---|---|---|
| Feature folder | snake_case | `sales_history/` |
| Vista principal | `<feature>_view.dart` | `expenses_view.dart` |
| Widget extraido | descriptivo snake_case | `filter_bar.dart`, `summary_card.dart` |
| Dialog | `<accion>_<entidad>_dialog.dart` | `edit_review_dialog.dart` |
| Provider | `<Feature>` (PascalCase) | `SearchPatient`, `Dashboard` |
| State | `<Feature>State` | `SearchPatientState` |
| Form controllers | `<feature>_form_controllers.dart` | `sell_form_controllers.dart` |
| DataSource (feature) | `<feature>_datasource.dart` | `patients_datasource.dart` |
| DataSource (core) | `<entity>_remote_datasource.dart` | `patient_remote_datasource.dart` |
| Repository interface | `<entity>_repository.dart` | `patient_repository.dart` |
| Repository impl | `<entity>_repository_impl.dart` | `patient_repository_impl.dart` |
| Modelo | `<entity>_model.dart` | `patient_model.dart` |

---

## Tablas de Supabase (conocidas)

| Tabla | Uso |
|---|---|
| `pacientes` | Registro de pacientes |
| `ventas` | Ventas realizadas |
| `detalle_ventas` | Detalles de cada venta |
| `pagos` | Pagos recibidos |
| `gastos` | Gastos registrados |
| `categorias_gastos` | Categorias de gastos |
| `armazones` | Inventario de monturas |
| `resinas` | Inventario de resinas |
| `revisiones` | Revisiones oftalmologicas |
| `vendedores` | Vendedores |
| `perfiles` | Perfiles de usuario |
| `app_config` | Configuracion de la app |
| `audit_logs` | Logs de auditoria |

> Nota: Las columnas usan nombres legacy con espacios y mayusculas.
> Siempre mapear con `@JsonKey(name: 'NOMBRE COLUMNA')` en los modelos.

---

## Rutas de la App

| Constante | Path | Vista |
|---|---|---|
| `splash` | `/` | SplashLayout |
| `login` | `/auth/login` | LoginView |
| `dashboard` | `/dashboard` | DashboardView |
| `searchPatient` | `/dashboard/search-patient` | SearchPatientView |
| `addPatient` | `/dashboard/add-patient` | AddPatientView |
| `sell` | `/dashboard/sell` | SellView |
| `salesHistory` | `/dashboard/sales-history` | SalesHistoryView |
| `expenses` | `/dashboard/expenses` | ExpensesView |
| `settings` | `/dashboard/settings` | SettingsView |
| `resins` | `/dashboard/settings/resins` | ResinsView |
| `mounts` | `/dashboard/settings/mounts` | MountsView |
| `paymentsReport` | `/dashboard/settings/payments-report` | PaymentsReportView |
| `salesBySeller` | `/dashboard/settings/sales-by-seller` | SalesBySellerView |
| `features` | `/dashboard/settings/features` | FeaturesView |
| `auditLogs` | `/dashboard/settings/audit-logs` | AuditLogsView |

---

## Breakpoints Responsivos

| Nombre | Ancho (px) |
|---|---|
| mobile | 500 |
| mobileLarge | 700 |
| tablet | 1024 |
| desktop | 1440 |

El sidebar se muestra fijo a partir de 700px. Por debajo, usa drawer animado.
