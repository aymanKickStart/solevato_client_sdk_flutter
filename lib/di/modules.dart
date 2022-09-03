import 'package:solevato_client_sdk_flutter/data/solevato_repository.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_contact_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_conversation_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_messages_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_user_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:solevato_client_sdk_flutter/data/local/local_storage.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_api_interceptor.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_auth_service.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_service.dart';
import 'package:solevato_client_sdk_flutter/solevato_parameters.dart';
import 'package:solevato_client_sdk_flutter/repository_parameters.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

///Provides an instance of [Dio]
final unauthenticatedDioProvider =
    Provider.family.autoDispose<Dio, SolevatoParameters>((ref, params) {
  return Dio(BaseOptions(baseUrl: params.baseUrl));
});

///Provides an instance of [SolevatoClientApiInterceptor]
final solevatoClientApiInterceptorProvider =
    Provider.family<SolevatoClientApiInterceptor, SolevatoParameters>(
        (ref, params) {
  final localStorage = ref.read(localStorageProvider(params));
  final authService = ref.read(solevatoClientAuthServiceProvider(params));
  return SolevatoClientApiInterceptor(
      params.inboxIdentifier, localStorage, authService);
});

///Provides an instance of Dio with interceptors set to authenticate all requests called with this dio instance
final authenticatedDioProvider =
    Provider.family.autoDispose<Dio, SolevatoParameters>((ref, params) {
  final authenticatedDio = Dio(BaseOptions(baseUrl: params.baseUrl));
  final interceptor = ref.read(solevatoClientApiInterceptorProvider(params));
  authenticatedDio.interceptors.add(interceptor);
  return authenticatedDio;
});

///Provides instance of solevato client auth service [SolevatoClientAuthService].
final solevatoClientAuthServiceProvider =
    Provider.family<SolevatoClientAuthService, SolevatoParameters>(
        (ref, params) {
  final unAuthenticatedDio = ref.read(unauthenticatedDioProvider(params));
  return SolevatoClientAuthServiceImpl(dio: unAuthenticatedDio);
});

///Provides instance of solevato client api service [SolevatoClientService].
final solevatoClientServiceProvider =
    Provider.family<SolevatoClientService, SolevatoParameters>((ref, params) {
  final authenticatedDio = ref.read(authenticatedDioProvider(params));
  return SolevatoClientServiceImpl(params.baseUrl, dio: authenticatedDio);
});

///Provides hive box to store relations between solevato client instance and contact object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToContactBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SolevatoContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());
});

///Provides hive box to store relations between solevato client instance and conversation object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToConversationBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SolevatoConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS.toString());
});

///Provides hive box to store relations between solevato client instance and messages,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final messageToClientInstanceBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SolevatoMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY.toString());
});

///Provides hive box to store relations between solevato client instance and user object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToUserBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SolevatoUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());
});

///Provides hive box for [SolevatoContact] object, which is used when persistence is enabled
final contactBoxProvider = Provider<Box<SolevatoContact>>((ref) {
  return Hive.box<SolevatoContact>(SolevatoContactBoxNames.CONTACTS.toString());
});

///Provides hive box for [SolevatoConversation] object, which is used when persistence is enabled
final conversationBoxProvider = Provider<Box<SolevatoConversation>>((ref) {
  return Hive.box<SolevatoConversation>(
      SolevatoConversationBoxNames.CONVERSATIONS.toString());
});

///Provides hive box for [SolevatoMessage] object, which is used when persistence is enabled
final messagesBoxProvider = Provider<Box<SolevatoMessage>>((ref) {
  return Hive.box<SolevatoMessage>(
      SolevatoMessagesBoxNames.MESSAGES.toString());
});

///Provides hive box for [SolevatoUser] object, which is used when persistence is enabled
final userBoxProvider = Provider<Box<SolevatoUser>>((ref) {
  return Hive.box<SolevatoUser>(SolevatoUserBoxNames.USERS.toString());
});

///Provides an instance of solevato user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// solevato client's contact
final SolevatoContactDaoProvider =
    Provider.family<SolevatoContactDao, SolevatoParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSolevatoContactDao();
  }

  final contactBox = ref.read(contactBoxProvider);
  final clientInstanceToContactBox =
      ref.read(clientInstanceToContactBoxProvider);
  return PersistedSolevatoContactDao(
      contactBox, clientInstanceToContactBox, params.clientInstanceKey);
});

///Provides an instance of solevato user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// solevato client's conversation
final SolevatoConversationDaoProvider =
    Provider.family<SolevatoConversationDao, SolevatoParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSolevatoConversationDao();
  }
  final conversationBox = ref.read(conversationBoxProvider);
  final clientInstanceToConversationBox =
      ref.read(clientInstanceToConversationBoxProvider);
  return PersistedSolevatoConversationDao(conversationBox,
      clientInstanceToConversationBox, params.clientInstanceKey);
});

///Provides an instance of solevato user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// solevato client's messages
final SolevatoMessagesDaoProvider =
    Provider.family<SolevatoMessagesDao, SolevatoParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSolevatoMessagesDao();
  }
  final messagesBox = ref.read(messagesBoxProvider);
  final messageToClientInstanceBox =
      ref.read(messageToClientInstanceBoxProvider);
  return PersistedSolevatoMessagesDao(
      messagesBox, messageToClientInstanceBox, params.clientInstanceKey);
});

///Provides an instance of solevato user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// user info
final SolevatoUserDaoProvider =
    Provider.family<SolevatoUserDao, SolevatoParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSolevatoUserDao();
  }
  final userBox = ref.read(userBoxProvider);
  final clientInstanceToUserBoxBox = ref.read(clientInstanceToUserBoxProvider);
  return PersistedSolevatoUserDao(
      userBox, clientInstanceToUserBoxBox, params.clientInstanceKey);
});

///Provides an instance of local storage
final localStorageProvider =
    Provider.family<LocalStorage, SolevatoParameters>((ref, params) {
  final contactDao = ref.read(SolevatoContactDaoProvider(params));
  final conversationDao = ref.read(SolevatoConversationDaoProvider(params));
  final userDao = ref.read(SolevatoUserDaoProvider(params));
  final messagesDao = ref.read(SolevatoMessagesDaoProvider(params));

  return LocalStorage(
      contactDao: contactDao,
      conversationDao: conversationDao,
      userDao: userDao,
      messagesDao: messagesDao);
});

///Provides an instance of solevato repository
final SolevatoRepositoryProvider =
    Provider.family<SolevatoRepository, RepositoryParameters>(
        (ref, repoParams) {
  final localStorage = ref.read(localStorageProvider(repoParams.params));
  final clientService =
      ref.read(solevatoClientServiceProvider(repoParams.params));

  return SolevatoRepositoryImpl(
      clientService: clientService,
      localStorage: localStorage,
      streamCallbacks: repoParams.callbacks);
});
