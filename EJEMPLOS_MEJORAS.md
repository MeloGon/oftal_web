# 💻 Ejemplos de Código Mejorado

## 1. Estado con Freezed (Reemplazar SellState)

```dart
// lib/features/sell/viewmodels/sell_state.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/core/enums/enums.dart';
import 'package:oftal_web/shared/models/shared_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

part 'sell_state.freezed.dart';

@freezed
class SellState with _$SellState {
  const factory SellState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default([]) List<PatientModel> patients,
    PatientModel? selectedPatient,
    SellItemOptionsEnum? selectedItemOption,
    PatientModel? patientToSell,
    @Default([]) List<ReviewModel> reviews,
    @Default([]) List<MountModel> mounts,
    SnackbarConfigModel? snackbarConfig,
    OptionsToSellEnum? selectedOptionToSell,
    @Default([]) List<SalesDetailsModel> itemsToSell,
    @Default('') String idRemision,
    @Default('') String idFolio,
    DiscountReasonEnum? selectedDiscountReason,
    @Default([]) List<ResinModel> resins,
    @Default(5) int rowsPerPage,
    GlobalKey<ShadFormState>? formKey,
  }) = _SellState;
}
```

**Ventajas:**
- ✅ `copyWith` generado automáticamente
- ✅ Inmutabilidad garantizada
- ✅ Comparación por valor (`==`)
- ✅ `toString()` útil para debugging
- ✅ Menos código boilerplate

---

## 2. Estructura Clean Architecture - Repositorio

### 2.1. Interfaz del Repositorio (Domain)

```dart
// lib/core/domain/repositories/patient_repository.dart
import 'package:dartz/dartz.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/patient_model.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<PatientModel>>> searchPatients(String query);
  Future<Either<Failure, PatientModel>> getPatientById(String id);
  Future<Either<Failure, PatientModel>> createPatient(PatientModel patient);
  Future<Either<Failure, void>> updatePatient(PatientModel patient);
  Future<Either<Failure, void>> deletePatient(String id);
}
```

### 2.2. DataSource (Data Layer)

```dart
// lib/core/data/datasources/remote/patient_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/core/data/datasources/remote/remote_datasource.dart';

abstract class PatientRemoteDataSource {
  Future<List<Map<String, dynamic>>> searchPatients(String query);
  Future<Map<String, dynamic>> getPatientById(String id);
  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data);
  Future<void> updatePatient(String id, Map<String, dynamic> data);
  Future<void> deletePatient(String id);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final SupabaseClient client;

  PatientRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final response = await client
          .from('pacientes')
          .select()
          .textSearch(
            '"NOMBRE COMPLETO"',
            '%$query%',
            type: TextSearchType.plain,
          );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getPatientById(String id) async {
    try {
      final response = await client
          .from('pacientes')
          .select()
          .eq('id', id)
          .single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data) async {
    try {
      final response = await client
          .from('pacientes')
          .insert(data)
          .select()
          .single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updatePatient(String id, Map<String, dynamic> data) async {
    try {
      await client
          .from('pacientes')
          .update(data)
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await client
          .from('pacientes')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
```

### 2.3. Excepciones

```dart
// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}
```

### 2.4. Failures

```dart
// lib/core/errors/failures.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server({
    required String message,
  }) = ServerFailure;

  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}
```

### 2.5. Implementación del Repositorio

```dart
// lib/core/data/repositories/patient_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:oftal_web/core/domain/repositories/patient_repository.dart';
import 'package:oftal_web/core/data/datasources/remote/patient_remote_datasource.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/core/errors/exceptions.dart';
import 'package:oftal_web/shared/models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PatientModel>>> searchPatients(String query) async {
    try {
      final data = await remoteDataSource.searchPatients(query);
      final patients = data.map((json) => PatientModel.fromJson(json)).toList();
      return Right(patients);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientModel>> getPatientById(String id) async {
    try {
      final data = await remoteDataSource.getPatientById(id);
      return Right(PatientModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientModel>> createPatient(PatientModel patient) async {
    try {
      final data = await remoteDataSource.createPatient(patient.toJson());
      return Right(PatientModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePatient(PatientModel patient) async {
    try {
      await remoteDataSource.updatePatient(patient.id.toString(), patient.toJson());
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePatient(String id) async {
    try {
      await remoteDataSource.deletePatient(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
```

### 2.6. Providers para Dependency Injection

```dart
// lib/core/data/providers/data_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/core/data/datasources/remote/patient_remote_datasource.dart';
import 'package:oftal_web/core/data/repositories/patient_repository_impl.dart';
import 'package:oftal_web/core/domain/repositories/patient_repository.dart';

part 'data_providers.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
PatientRemoteDataSource patientRemoteDataSource(Ref ref) {
  return PatientRemoteDataSourceImpl(
    client: ref.read(supabaseClientProvider),
  );
}

@riverpod
PatientRepository patientRepository(Ref ref) {
  return PatientRepositoryImpl(
    remoteDataSource: ref.read(patientRemoteDataSourceProvider),
  );
}
```

### 2.7. Provider Refactorizado (Usando Repositorio)

```dart
// lib/features/sell/viewmodels/sell_provider.dart
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oftal_web/core/domain/repositories/patient_repository.dart';
import 'package:oftal_web/core/data/providers/data_providers.dart';
import 'package:oftal_web/features/sell/viewmodels/sell_state.dart';
import 'package:oftal_web/shared/utils/random_id_generator.dart';
import 'package:dartz/dartz.dart';
import 'package:oftal_web/core/errors/failures.dart';

part 'sell_provider.g.dart';

@Riverpod(keepAlive: true)
class Sell extends _$Sell {
  final searchController = TextEditingController();

  @override
  SellState build() {
    ref.onDispose(() {
      searchController.dispose();
    });
    return const SellState();
  }

  Future<void> searchPatient() async {
    if (searchController.text.isEmpty) {
      state = state.copyWith(
        patients: [],
        errorMessage: 'Ingrese un nombre para buscar',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    
    final repository = ref.read(patientRepositoryProvider);
    final result = await repository.searchPatients(searchController.text);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
          patients: [],
          snackbarConfig: SnackbarConfigModel(
            title: 'Error',
            type: SnackbarEnum.error,
          ),
        );
      },
      (patients) {
        state = state.copyWith(
          isLoading: false,
          patients: patients,
          errorMessage: patients.isEmpty 
            ? 'No se encontraron pacientes' 
            : '',
        );
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    return failure.when(
      server: (message) => 'Error del servidor: $message',
      network: (message) => 'Error de conexión: $message',
      cache: (message) => 'Error de almacenamiento: $message',
      unknown: (message) => 'Error desconocido: $message',
    );
  }

  // ... resto de métodos
}
```

---

## 3. Extensiones Responsive

```dart
// lib/shared/extensions/responsive_extensions.dart
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 500;
  static const double mobileLarge = 700;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

extension ResponsiveContext on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  
  bool get isMobile => width <= Breakpoints.mobile;
  bool get isMobileLarge => width > Breakpoints.mobile && width <= Breakpoints.mobileLarge;
  bool get isTablet => width > Breakpoints.mobileLarge && width < Breakpoints.tablet;
  bool get isDesktop => width >= Breakpoints.tablet;
  
  T responsiveValue<T>({
    required T mobile,
    T? mobileLarge,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile) return mobile;
    if (isMobileLarge && mobileLarge != null) return mobileLarge;
    if (isTablet && tablet != null) return tablet;
    return desktop;
  }
  
  double get responsiveWidth {
    if (isMobile) return width * 0.95;
    if (isTablet) return width * 0.85;
    return width * 0.75;
  }
  
  EdgeInsets get responsivePadding {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
      vertical: responsiveValue(
        mobile: 12.0,
        tablet: 16.0,
        desktop: 20.0,
      ),
    );
  }
}
```

**Uso en vistas:**

```dart
// Antes
Container(
  width: MediaQuery.sizeOf(context).width * .9,
  padding: EdgeInsets.all(20),
  child: Column(...),
)

// Después
Container(
  width: context.responsiveWidth,
  padding: context.responsivePadding,
  child: Column(...),
)
```

---

## 4. Widget Responsive Mejorado

```dart
// lib/shared/widgets/responsive_builder.dart
import 'package:flutter/material.dart';
import 'package:oftal_web/shared/extensions/responsive_extensions.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? mobileLarge;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.mobileLarge,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return desktop;
        } else if (constraints.maxWidth >= Breakpoints.mobileLarge && tablet != null) {
          return tablet!;
        } else if (constraints.maxWidth >= Breakpoints.mobile && mobileLarge != null) {
          return mobileLarge!;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

---

## 5. SnackbarConfigModel con Freezed

```dart
// lib/shared/models/snackbar_config_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oftal_web/core/enums/snackbar_enum.dart';

part 'snackbar_config_model.freezed.dart';

@freezed
class SnackbarConfigModel with _$SnackbarConfigModel {
  const factory SnackbarConfigModel({
    required String title,
    required SnackbarEnum type,
  }) = _SnackbarConfigModel;
  
  factory SnackbarConfigModel.error(String message) => SnackbarConfigModel(
    title: 'Error',
    type: SnackbarEnum.error,
  );
  
  factory SnackbarConfigModel.success(String message) => SnackbarConfigModel(
    title: 'Éxito',
    type: SnackbarEnum.success,
  );
  
  factory SnackbarConfigModel.warning(String message) => SnackbarConfigModel(
    title: 'Advertencia',
    type: SnackbarEnum.warning,
  );
}
```

---

## 6. Caso de Uso (Opcional pero Recomendado)

```dart
// lib/core/domain/usecases/search_patient_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:oftal_web/core/domain/repositories/patient_repository.dart';
import 'package:oftal_web/core/errors/failures.dart';
import 'package:oftal_web/shared/models/patient_model.dart';

class SearchPatientUseCase {
  final PatientRepository repository;

  SearchPatientUseCase(this.repository);

  Future<Either<Failure, List<PatientModel>>> call(String query) async {
    if (query.isEmpty) {
      return const Right([]);
    }
    return await repository.searchPatients(query);
  }
}
```

**Provider del caso de uso:**

```dart
@riverpod
SearchPatientUseCase searchPatientUseCase(Ref ref) {
  return SearchPatientUseCase(ref.read(patientRepositoryProvider));
}
```

---

## 📦 Dependencias Necesarias

```yaml
# pubspec.yaml
dependencies:
  # ... tus dependencias actuales
  dartz: ^0.10.1  # Para Either<Left, Right>
  # O alternativamente:
  # fpdart: ^1.1.0  # Alternativa más moderna a dartz
```

---

## 🚀 Pasos para Implementar

1. **Agregar dartz o fpdart a pubspec.yaml**
2. **Crear estructura de carpetas Clean Architecture**
3. **Convertir estados a Freezed** (empezar con SellState)
4. **Crear DataSources** (empezar con PatientRemoteDataSource)
5. **Crear Repositorios** (interfaces e implementaciones)
6. **Refactorizar providers** para usar repositorios
7. **Agregar extensiones responsive**
8. **Actualizar vistas** para usar extensiones responsive

¿Quieres que implemente alguna de estas mejoras en tu código ahora?
