import 'dart:io';

import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_contact_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_conversation_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_messages_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_user_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:solevato_client_sdk_flutter/data/local/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'local_storage_test.mocks.dart';

@GenerateMocks([
  SolevatoConversationDao,
  SolevatoContactDao,
  SolevatoMessagesDao,
  PersistedSolevatoConversationDao,
  PersistedSolevatoContactDao,
  PersistedSolevatoMessagesDao,
  SolevatoUserDao,
  PersistedSolevatoUserDao
])
void main() {
  group("Local Storage Tests", () {
    final mockContactDao = MockSolevatoContactDao();
    final mockConversationDao = MockSolevatoConversationDao();
    final mockUserDao = MockSolevatoUserDao();
    final mockMessagesDao = MockSolevatoMessagesDao();

    late final LocalStorage localStorage;

    setUpAll(() {
      final hiveTestPath = Directory.current.path + '/test/hive_testing_path';

      Hive
        ..init(hiveTestPath)
        ..registerAdapter(SolevatoContactAdapter())
        ..registerAdapter(SolevatoConversationAdapter())
        ..registerAdapter(SolevatoMessageAdapter())
        ..registerAdapter(SolevatoUserAdapter());

      localStorage = LocalStorage(
          userDao: mockUserDao,
          conversationDao: mockConversationDao,
          contactDao: mockContactDao,
          messagesDao: mockMessagesDao);
    });

    test(
        'Given persisted db is successfully opened when openDB is called, then all hive boxes should be open',
        () async {
      //WHEN
      await LocalStorage.openDB(onInitializeHive: () {});

      //THEN
      expect(true, Hive.isBoxOpen(SolevatoContactBoxNames.CONTACTS.toString()));
      expect(
          true,
          Hive.isBoxOpen(
              SolevatoContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString()));
      expect(
          true,
          Hive.isBoxOpen(
              SolevatoConversationBoxNames.CONVERSATIONS.toString()));
      expect(
          true,
          Hive.isBoxOpen(SolevatoConversationBoxNames
              .CLIENT_INSTANCE_TO_CONVERSATIONS
              .toString()));
      expect(
          true, Hive.isBoxOpen(SolevatoMessagesBoxNames.MESSAGES.toString()));
      expect(
          true,
          Hive.isBoxOpen(SolevatoMessagesBoxNames
              .MESSAGES_TO_CLIENT_INSTANCE_KEY
              .toString()));
      expect(true, Hive.isBoxOpen(SolevatoUserBoxNames.USERS.toString()));
      expect(true, Hive.isBoxOpen(SolevatoUserBoxNames.USERS.toString()));
    });

    test(
        'Given localStorage is successfully cleared when clear is called, then daos should be cleared',
        () async {
      //WHEN
      await localStorage.clear(clearSolevatoUserStorage: true);

      //THEN
      verify(mockContactDao.deleteContact());
      verify(mockConversationDao.deleteConversation());
      verify(mockMessagesDao.clear());
      verify(mockUserDao.deleteUser());
    });

    test(
        'Given localStorage is successfully cleared except user db when clear is called, then daos should be cleared except user db',
        () async {
      //WHEN
      await localStorage.clear(clearSolevatoUserStorage: false);

      //THEN
      verifyNever(mockContactDao.deleteContact());
      verify(mockConversationDao.deleteConversation());
      verify(mockMessagesDao.clear());
      verifyNever(mockUserDao.deleteUser());
    });

    test(
        'Given all data is successfully cleared when clearAll is called, then all data daos should be cleared',
        () async {
      //WHEN
      await localStorage.clearAll();

      //THEN
      verify(mockContactDao.clearAll());
      verify(mockConversationDao.clearAll());
      verify(mockMessagesDao.clearAll());
      verify(mockUserDao.clearAll());
    });

    test(
        'Given localStorage is successfully disposed when dispose is called, then all daos should be disposed',
        () {
      //WHEN
      localStorage.dispose();

      //THEN
      verify(mockContactDao.onDispose());
      verify(mockConversationDao.onDispose());
      verify(mockMessagesDao.onDispose());
      verify(mockUserDao.onDispose());
    });

    tearDownAll(() async {
      await Hive.close();
    });
  });
}
