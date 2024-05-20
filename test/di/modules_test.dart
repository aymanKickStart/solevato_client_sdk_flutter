import 'dart:io';

import 'package:solevato_client_sdk_flutter/solevato_client_sdk_flutter.dart';
import 'package:solevato_client_sdk_flutter/solevato_parameters.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_contact_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_conversation_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_messages_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_user_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/remote/responses/solevato_event.dart';
import 'package:solevato_client_sdk_flutter/di/modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group("Modules Test", () {
    late ProviderContainer providerContainer;

    final testSolevatoParameters = SolevatoParameters(
        isPersistenceEnabled: true,
        baseUrl: "http://localhost:3000",
        inboxIdentifier: "testInboxIdentifier",
        clientInstanceKey: "testInstanceKey");

    setUpAll(() async {
      providerContainer = ProviderContainer();
      final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
      Hive
        ..init(hiveTestPath)
        ..registerAdapter(SolevatoContactAdapter())
        ..registerAdapter(SolevatoConversationAdapter())
        ..registerAdapter(SolevatoMessageAdapter())
        ..registerAdapter(SolevatoEventMessageUserAdapter())
        ..registerAdapter(SolevatoUserAdapter());

      await PersistedSolevatoMessagesDao.openDB();
      await PersistedSolevatoConversationDao.openDB();
      await PersistedSolevatoContactDao.openDB();
      await PersistedSolevatoUserDao.openDB();
    });

    test(
        'Given Dio instance is successfully provided when a read unauthenticatedDioProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(unauthenticatedDioProvider(testSolevatoParameters));

      //THEN
      expect(result.options.baseUrl, equals(testSolevatoParameters.baseUrl));
      expect(result.interceptors.isEmpty, equals(true));
    });

    test(
        'Given SolevatoClientAuthService instance is successfully provided when a read solevatoClientAuthServiceProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(solevatoClientAuthServiceProvider(testSolevatoParameters));

      //THEN
      expect(result.dio.interceptors.length, equals(0));
    });

    test(
        'Given Dio instance is successfully provided when a read authenticatedDioProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(authenticatedDioProvider(testSolevatoParameters));

      //THEN
      expect(result.options.baseUrl, equals(testSolevatoParameters.baseUrl));
      expect(result.interceptors.length, equals(1));
    });

    test(
        'Given SolevatoContactDao instance is successfully provided when a read SolevatoContactDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: true,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoContactDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is PersistedSolevatoContactDao, equals(true));
    });

    test(
        'Given SolevatoContactDao instance is successfully provided when a read SolevatoContactDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: false,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoContactDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is NonPersistedSolevatoContactDao, equals(true));
    });

    test(
        'Given SolevatoConversationDao instance is successfully provided when a read SolevatoConversationDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: true,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoConversationDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is PersistedSolevatoConversationDao, equals(true));
    });

    test(
        'Given SolevatoConversationDao instance is successfully provided when a read SolevatoConversationDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: false,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoConversationDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is NonPersistedSolevatoConversationDao, equals(true));
    });

    test(
        'Given SolevatoMessagesDao instance is successfully provided when a read SolevatoMessagesDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: true,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoMessagesDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is PersistedSolevatoMessagesDao, equals(true));
    });

    test(
        'Given SolevatoMessagesDao instance is successfully provided when a read SolevatoMessagesDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: false,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoMessagesDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is NonPersistedSolevatoMessagesDao, equals(true));
    });

    test(
        'Given SolevatoUserDao instance is successfully provided when a read SolevatoUserDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: true,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoUserDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is PersistedSolevatoUserDao, equals(true));
    });

    test(
        'Given SolevatoUserDao instance is successfully provided when a read SolevatoUserDaoProvider is called with persistence enabled, then return instance of PersistedSolevatoContactDao',
        () async {
      //GIVEN
      final testSolevatoParameters = SolevatoParameters(
          isPersistenceEnabled: false,
          baseUrl: "http://localhost:3000",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(SolevatoUserDaoProvider(testSolevatoParameters));

      //THEN
      expect(result is NonPersistedSolevatoUserDao, equals(true));
    });

    tearDownAll(() async {
      Hive.close();
    });
  });
}
