import 'package:solevato_client_sdk_flutter/solevato_callbacks.dart';
import 'package:solevato_client_sdk_flutter/solevato_parameters.dart';
import 'package:solevato_client_sdk_flutter/di/modules.dart';

/// Represent all needed parameters necessary for [SolevatoRepositoryProvider] to successfully provide an instance
/// of [SolevatoRepository].
class RepositoryParameters {
  /// See [SolevatoParameters]
  SolevatoParameters params;

  /// See [SolevatoCallbacks]
  SolevatoCallbacks callbacks;

  RepositoryParameters({required this.params, required this.callbacks});
}
