import 'dart:io';

import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_conversation_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Persisted Solevato Conversation Dao Tests", () {
    late PersistedSolevatoConversationDao dao;
    late Box<String> mockClientInstanceKeyToConversationBox;
    late Box<SolevatoConversation> mockConversationBox;
    final testClientInstanceKey = "testKey";

    late final SolevatoConversation testConversation;

    setUpAll(() {
      return Future(() async {
        testConversation = SolevatoConversation.fromJson(
            await TestResourceUtil.readJsonResource(fileName: "conversation"));

        final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
        Hive
          ..init(hiveTestPath)
          ..registerAdapter(SolevatoConversationAdapter())
          ..registerAdapter(SolevatoContactAdapter())
          ..registerAdapter(SolevatoMessageAdapter());
      });
    });

    setUp(() {
      return Future(() async {
        mockConversationBox = await Hive.openBox(
            SolevatoConversationBoxNames.CONVERSATIONS.toString());
        mockClientInstanceKeyToConversationBox = await Hive.openBox(
            SolevatoConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS
                .toString());

        dao = PersistedSolevatoConversationDao(mockConversationBox,
            mockClientInstanceKeyToConversationBox, testClientInstanceKey);
      });
    });

    test(
        'Given conversation is successfully deleted when deleteConversation is called, then getConversation should return null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      await dao.deleteConversation();

      //THEN
      expect(dao.getConversation(), null);
    });

    test(
        'Given conversation is successfully save when saveConversation is called, then getConversation should return saved conversation',
        () async {
      //WHEN
      await dao.saveConversation(testConversation);

      //THEN
      expect(dao.getConversation(), testConversation);
    });

    test(
        'Given conversation is successfully retrieved when getConversation is called, then retrieved conversation should not be null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      final retrievedConversation = dao.getConversation();

      //THEN
      expect(retrievedConversation, testConversation);
    });

    test(
        'Given conversations are successfully cleared when clearAll is called, then retrieving a conversation should be null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      await dao.clearAll();

      //THEN
      expect(dao.getConversation(), null);
    });

    tearDown(() {
      return Future(() async {
        try {
          await mockConversationBox.clear();
          await mockClientInstanceKeyToConversationBox.clear();
        } on HiveError catch (e) {
          print(e);
        }
      });
    });

    tearDownAll(() {
      return Future(() async {
        await mockConversationBox.close();
        await mockClientInstanceKeyToConversationBox.close();
      });
    });
  });
}
