import 'package:equatable/equatable.dart';

class SolevatoParameters extends Equatable {
  final bool isPersistenceEnabled;
  final String baseUrl;
  final String clientInstanceKey;
  final String inboxIdentifier;
  final String? userIdentifier;

  SolevatoParameters({
    required this.isPersistenceEnabled,
    this.baseUrl = 'https://app.solevato.com',
    required this.inboxIdentifier,
    required this.clientInstanceKey,
    this.userIdentifier,
  });

  @override
  List<Object?> get props => [
        isPersistenceEnabled,
        baseUrl,
        clientInstanceKey,
        inboxIdentifier,
        userIdentifier
      ];
}
