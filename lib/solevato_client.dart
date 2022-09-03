import 'package:solevato_client_sdk_flutter/solevato_client_sdk_flutter.dart';
import 'package:solevato_client_sdk_flutter/data/solevato_repository.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_action_data.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_new_message_request.dart';
import 'package:solevato_client_sdk_flutter/di/modules.dart';
import 'package:solevato_client_sdk_flutter/solevato_parameters.dart';
import 'package:solevato_client_sdk_flutter/repository_parameters.dart';
import 'package:riverpod/riverpod.dart';

import 'data/local/local_storage.dart';

/// Represents a solevato client instance. All solevato operations (Example: sendMessages) are
/// passed through solevato client.
///
/// {@category FlutterClientSdk}
class SolevatoClient {
  late final SolevatoRepository _repository;
  final SolevatoParameters _parameters;
  final SolevatoCallbacks? callbacks;
  final SolevatoUser? user;

  String get baseUrl => _parameters.baseUrl;

  String get inboxIdentifier => _parameters.inboxIdentifier;

  SolevatoClient._(this._parameters, {this.user, this.callbacks}) {
    providerContainerMap.putIfAbsent(
        _parameters.clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository = container.read(SolevatoRepositoryProvider(
        RepositoryParameters(
            params: _parameters, callbacks: callbacks ?? SolevatoCallbacks())));
  }

  void _init() {
    try {
      _repository.initialize(user);
    } on SolevatoClientException catch (e) {
      callbacks?.onError?.call(e);
    }
  }

  ///Retrieves solevato client's messages. If persistence is enabled [SolevatoCallbacks.onPersistedMessagesRetrieved]
  ///will be triggered with persisted messages. On successfully fetch from remote server
  ///[SolevatoCallbacks.onMessagesRetrieved] will be triggered
  void loadMessages() async {
    _repository.getPersistedMessages();
    await _repository.getMessages();
  }

  /// Sends solevato message. The echoId is your temporary message id. When message sends successfully
  /// [SolevatoMessage] will be returned with the [echoId] on [SolevatoCallbacks.onMessageSent]. If
  /// message fails to send [SolevatoCallbacks.onError] will be triggered [echoId] as data.
  Future<void> sendMessage(
      {required String content, required String echoId}) async {
    final request = SolevatoNewMessageRequest(content: content, echoId: echoId);
    await _repository.sendMessage(request);
  }

  ///Send solevato action performed by user.
  ///
  /// Example: User started typing
  Future<void> sendAction(SolevatoActionType action) async {
    _repository.sendAction(action);
  }

  ///Disposes solevato client and cancels all stream subscriptions
  dispose() {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository.dispose();
    container.dispose();
    providerContainerMap.remove(_parameters.clientInstanceKey);
  }

  /// Clears all solevato client data
  clearClientData() {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    final localStorage = container.read(localStorageProvider(_parameters));
    localStorage.clear(clearSolevatoUserStorage: false);
  }

  /// Creates an instance of [SolevatoClient] with the [baseUrl] of your solevato installation,
  /// [inboxIdentifier] for the targeted inbox. Specify custom user details using [user] and [callbacks] for
  /// handling solevato events. By default persistence is enabled, to disable persistence set [enablePersistence] as false
  static Future<SolevatoClient> create(
      {required String baseUrl,
      required String inboxIdentifier,
      SolevatoUser? user,
      bool enablePersistence = true,
      SolevatoCallbacks? callbacks}) async {
    if (enablePersistence) {
      await LocalStorage.openDB();
    }

    final solevatoParams = SolevatoParameters(
        clientInstanceKey: getClientInstanceKey(
            baseUrl: baseUrl,
            inboxIdentifier: inboxIdentifier,
            userIdentifier: user?.identifier),
        isPersistenceEnabled: enablePersistence,
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: user?.identifier);

    final client =
        SolevatoClient._(solevatoParams, callbacks: callbacks, user: user);

    client._init();

    return client;
  }

  static final _keySeparator = "|||";

  ///Create a solevato client instance key using the solevato client instance baseurl, inboxIdentifier
  ///and userIdentifier. Client instance keys are used to differentiate between client instances and their data
  ///(contact ([SolevatoContact]),conversation ([SolevatoConversation]) and messages ([SolevatoMessage]))
  ///
  /// Create separate [SolevatoClient] instances with same baseUrl, inboxIdentifier, userIdentifier and persistence
  /// enabled will be regarded as same therefore use same contact and conversation.
  static String getClientInstanceKey(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) {
    return "$baseUrl$_keySeparator$userIdentifier$_keySeparator$inboxIdentifier";
  }

  static Map<String, ProviderContainer> providerContainerMap = Map();

  ///Clears all persisted solevato data on device for a particular solevato client instance.
  ///See [getClientInstanceKey] on how solevato client instance are differentiated
  static Future<void> clearData(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) async {
    final clientInstanceKey = getClientInstanceKey(
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: userIdentifier);
    providerContainerMap.putIfAbsent(
        clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[clientInstanceKey]!;
    final params = SolevatoParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clear();

    localStorage.dispose();
    container.dispose();
    providerContainerMap.remove(clientInstanceKey);
  }

  /// Clears all persisted solevato data on device.
  static Future<void> clearAllData() async {
    providerContainerMap.putIfAbsent("all", () => ProviderContainer());
    final container = providerContainerMap["all"]!;
    final params = SolevatoParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clearAll();

    localStorage.dispose();
    container.dispose();
  }
}
