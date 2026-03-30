import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.notFound(String message) = NotFoundFailure;
  const factory Failure.unknown(String message) = UnknownFailure;
}

extension FailureMessage on Failure {
  String get message => when(
        server: (msg) => msg,
        network: (msg) => msg,
        notFound: (msg) => msg,
        unknown: (msg) => msg,
      );
}
