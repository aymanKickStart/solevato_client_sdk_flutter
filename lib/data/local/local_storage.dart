import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_contact_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_conversation_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_messages_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/dao/solevato_user_dao.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/remote/responses/solevato_event.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entity/solevato_contact.dart';
import 'entity/solevato_conversation.dart';
import 'entity/solevato_message.dart';
import 'entity/solevato_user.dart';

const SOLEVATO_CONTACT_HIVE_TYPE_ID = 0;
const SOLEVATO_CONVERSATION_HIVE_TYPE_ID = 1;
const SOLEVATO_MESSAGE_HIVE_TYPE_ID = 2;
const SOLEVATO_HIVE_TYPE_ID = 3;
const SOLEVATO_EVENT_USER_HIVE_TYPE_ID = 4;

class LocalStorage {
  SolevatoUserDao userDao;
  SolevatoConversationDao conversationDao;
  SolevatoContactDao contactDao;
  SolevatoMessagesDao messagesDao;

  LocalStorage({
    required this.userDao,
    required this.conversationDao,
    required this.contactDao,
    required this.messagesDao,
  });

  static Future<void> openDB({void Function()? onInitializeHive}) async {
    if (onInitializeHive == null) {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(SOLEVATO_CONTACT_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SolevatoContactAdapter());
      }
      if (!Hive.isAdapterRegistered(SOLEVATO_CONVERSATION_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SolevatoConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(SOLEVATO_MESSAGE_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SolevatoMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(SOLEVATO_EVENT_USER_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SolevatoEventMessageUserAdapter());
      }
      if (!Hive.isAdapterRegistered(SOLEVATO_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SolevatoUserAdapter());
      }
    } else {
      onInitializeHive();
    }

    await PersistedSolevatoContactDao.openDB();
    await PersistedSolevatoConversationDao.openDB();
    await PersistedSolevatoMessagesDao.openDB();
    await PersistedSolevatoUserDao.openDB();
  }

  Future<void> clear({bool clearSolevatoUserStorage = true}) async {
    await conversationDao.deleteConversation();
    await messagesDao.clear();
    if (clearSolevatoUserStorage) {
      await userDao.deleteUser();
      await contactDao.deleteContact();
    }
  }

  Future<void> clearAll() async {
    await conversationDao.clearAll();
    await contactDao.clearAll();
    await messagesDao.clearAll();
    await userDao.clearAll();
  }

  dispose() {
    userDao.onDispose();
    conversationDao.onDispose();
    contactDao.onDispose();
    messagesDao.onDispose();
  }
}
