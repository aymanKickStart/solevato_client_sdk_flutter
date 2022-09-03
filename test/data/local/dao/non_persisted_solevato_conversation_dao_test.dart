import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_conversation_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Non Persisted Solevato Conversation Dao Test", () {
    late NonPersistedSolevatoConversationDao dao;
    late final SolevatoConversation testConversation;

    setUpAll(() async {
      testConversation = SolevatoConversation.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "conversation"));
      dao = NonPersistedSolevatoConversationDao();
    });

    test(
        'Given conversation is successfully deleted when deleteConversation is called, then getConversation should return null',
        () {
      //GIVEN
      dao.saveConversation(testConversation);

      //WHEN
      dao.deleteConversation();

      //THEN
      expect(dao.getConversation(), null);
    });

    test(
        'Given conversation is successfully save when saveConversation is called, then getConversation should return saved conversation',
        () {
      //WHEN
      dao.saveConversation(testConversation);

      //THEN
      expect(dao.getConversation(), testConversation);
    });

    test(
        'Given conversation is successfully retrieved when getConversation is called, then retrieved conversation should not be null',
        () {
      //GIVEN
      dao.saveConversation(testConversation);

      //WHEN
      final retrievedConversation = dao.getConversation();

      //THEN
      expect(retrievedConversation, testConversation);
    });

    test(
        'Given conversations are successfully cleared when clearAll is called, then retrieving a conversation should be null',
        () {
      //GIVEN
      dao.saveConversation(testConversation);

      //WHEN
      dao.clearAll();

      //THEN
      expect(dao.getConversation(), null);
    });

    test(
        'Given dao is successfully disposed when onDispose is called, then saved conversation should be null',
        () {
      //GIVEN
      dao.saveConversation(testConversation);

      //WHEN
      dao.onDispose();

      //THEN
      final retrievedConversation = dao.getConversation();
      expect(retrievedConversation, null);
    });

    tearDown(() {
      dao.clearAll();
    });
  });
}
