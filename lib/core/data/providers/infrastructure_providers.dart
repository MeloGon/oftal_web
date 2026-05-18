import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oftal_web/core/data/datasources/remote/app_config_remote_datasource.dart';
import 'package:oftal_web/core/data/repositories/app_config_repository_impl.dart';
import 'package:oftal_web/core/domain/repositories/app_config_repository.dart';
import 'package:oftal_web/core/data/datasources/remote/expense_remote_datasource.dart';
import 'package:oftal_web/core/data/datasources/remote/mount_remote_datasource.dart';
import 'package:oftal_web/core/data/datasources/remote/payment_remote_datasource.dart';
import 'package:oftal_web/core/data/repositories/expense_repository_impl.dart';
import 'package:oftal_web/core/domain/repositories/expense_repository.dart';
import 'package:oftal_web/core/data/repositories/payment_repository_impl.dart';
import 'package:oftal_web/core/domain/repositories/payment_repository.dart';
import 'package:oftal_web/core/data/datasources/remote/patient_remote_datasource.dart';
import 'package:oftal_web/core/data/datasources/remote/resin_remote_datasource.dart';
import 'package:oftal_web/core/data/datasources/remote/review_remote_datasource.dart';
import 'package:oftal_web/core/data/datasources/remote/sale_remote_datasource.dart';
import 'package:oftal_web/core/data/datasources/remote/seller_remote_datasource.dart';
import 'package:oftal_web/core/data/repositories/mount_repository_impl.dart';
import 'package:oftal_web/core/data/repositories/patient_repository_impl.dart';
import 'package:oftal_web/core/data/repositories/resin_repository_impl.dart';
import 'package:oftal_web/core/data/repositories/review_repository_impl.dart';
import 'package:oftal_web/core/data/repositories/sale_repository_impl.dart';
import 'package:oftal_web/core/data/repositories/seller_repository_impl.dart';
import 'package:oftal_web/core/domain/repositories/mount_repository.dart';
import 'package:oftal_web/core/domain/repositories/patient_repository.dart';
import 'package:oftal_web/core/domain/repositories/resin_repository.dart';
import 'package:oftal_web/core/domain/repositories/review_repository.dart';
import 'package:oftal_web/core/domain/repositories/sale_repository.dart';
import 'package:oftal_web/core/domain/repositories/seller_repository.dart';

// ─── Supabase client ───────────────────────────────────────────────────────────
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ─── DataSources ──────────────────────────────────────────────────────────────
final patientRemoteDataSourceProvider = Provider<PatientRemoteDataSource>((ref) {
  return PatientRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final mountRemoteDataSourceProvider = Provider<MountRemoteDataSource>((ref) {
  return MountRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final resinRemoteDataSourceProvider = Provider<ResinRemoteDataSource>((ref) {
  return ResinRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final saleRemoteDataSourceProvider = Provider<SaleRemoteDataSource>((ref) {
  return SaleRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  return ReviewRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final sellerRemoteDataSourceProvider = Provider<SellerRemoteDataSource>((ref) {
  return SellerRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

// ─── Repositories ─────────────────────────────────────────────────────────────
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(ref.read(patientRemoteDataSourceProvider));
});

final mountRepositoryProvider = Provider<MountRepository>((ref) {
  return MountRepositoryImpl(ref.read(mountRemoteDataSourceProvider));
});

final resinRepositoryProvider = Provider<ResinRepository>((ref) {
  return ResinRepositoryImpl(ref.read(resinRemoteDataSourceProvider));
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepositoryImpl(ref.read(saleRemoteDataSourceProvider));
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(ref.read(reviewRemoteDataSourceProvider));
});

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  return SellerRepositoryImpl(ref.read(sellerRemoteDataSourceProvider));
});

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  return PaymentRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.read(paymentRemoteDataSourceProvider));
});

final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.read(expenseRemoteDataSourceProvider));
});

final appConfigRemoteDataSourceProvider =
    Provider<AppConfigRemoteDataSource>((ref) {
  return AppConfigRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

final appConfigRepositoryProvider = Provider<AppConfigRepository>((ref) {
  return AppConfigRepositoryImpl(ref.read(appConfigRemoteDataSourceProvider));
});
