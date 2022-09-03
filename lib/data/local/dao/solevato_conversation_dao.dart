import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class SolevatoConversationDao {
  Future<void> saveConversation(SolevatoConversation conversation);
  SolevatoConversation? getConversation();
  Future<void> deleteConversation();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum SolevatoConversationBoxNames {
  CONVERSATIONS,
  CLIENT_INSTANCE_TO_CONVERSATIONS
}

class PersistedSolevatoConversationDao extends SolevatoConversationDao {
  //box containing all persisted conversations
  Box<SolevatoConversation> _box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> _clientInstanceIdToConversationIdentifierBox;

  final String _clientInstanceKey;

  PersistedSolevatoConversationDao(
      this._box,
      this._clientInstanceIdToConversationIdentifierBox,
      this._clientInstanceKey);

  @override
  Future<void> deleteConversation() async {
    final conversationIdentifier =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToConversationIdentifierBox
        .delete(_clientInstanceKey);
    await _box.delete(conversationIdentifier);
  }

  @override
  Future<void> saveConversation(SolevatoConversation conversation) async {
    await _clientInstanceIdToConversationIdentifierBox.put(
        _clientInstanceKey, conversation.id.toString());
    await _box.put(conversation.id, conversation);
  }

  @override
  SolevatoConversation? getConversation() {
    if (_box.values.length == 0) {
      return null;
    }

    final conversationidentifierString =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    final conversationIdentifier =
        int.tryParse(conversationidentifierString ?? "");

    if (conversationIdentifier == null) {
      return null;
    }

    return _box.get(conversationIdentifier);
  }

  @override
  Future<void> onDispose() async {}

  static Future<void> openDB() async {
    await Hive.openBox<SolevatoConversation>(
        SolevatoConversationBoxNames.CONVERSATIONS.toString());
    await Hive.openBox<String>(SolevatoConversationBoxNames
        .CLIENT_INSTANCE_TO_CONVERSATIONS
        .toString());
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToConversationIdentifierBox.clear();
  }
}

class NonPersistedSolevatoConversationDao extends SolevatoConversationDao {
  SolevatoConversation? _conversation;

  @override
  Future<void> deleteConversation() async {
    _conversation = null;
  }

  @override
  SolevatoConversation? getConversation() {
    return _conversation;
  }

  @override
  Future<void> onDispose() async {
    _conversation = null;
  }

  @override
  Future<void> saveConversation(SolevatoConversation conversation) async {
    _conversation = conversation;
  }

  @override
  Future<void> clearAll() async {
    _conversation = null;
  }
}
