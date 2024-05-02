import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:solevato_client_sdk_flutter/solevato_callbacks.dart';
import 'package:solevato_client_sdk_flutter/solevato_client.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:solevato_client_sdk_flutter/data/local/local_storage.dart';
import 'package:solevato_client_sdk_flutter/data/remote/solevato_client_exception.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_action_data.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_new_message_request.dart';
import 'package:solevato_client_sdk_flutter/data/remote/responses/solevato_event.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_service.dart';
import 'package:flutter/material.dart';

import 'local/entity/solevato_contact.dart';
import 'local/entity/solevato_conversation.dart';

/// Handles interactions between solevato client api service[clientService] and
/// [localStorage] if persistence is enabled.
///
/// Results from repository operations are passed through [callbacks] to be handled
/// appropriately
abstract class SolevatoRepository {
  @protected
  final SolevatoClientService clientService;
  @protected
  final LocalStorage localStorage;
  @protected
  SolevatoCallbacks callbacks;

  String inboxIdentifier;

  List<StreamSubscription> _subscriptions = [];

  SolevatoRepository(
    this.clientService,
    this.localStorage,
    this.callbacks,
    this.inboxIdentifier,
  );

  Future<void> initialize(SolevatoUser? user);

  void getPersistedMessages();

  Future<void> getMessages();

  void listenForEvents();

  Future<void> sendMessage(SolevatoNewMessageRequest request);

  void sendAction(SolevatoActionType action);

  Future<void> clear();

  void dispose();
}

class SolevatoRepositoryImpl extends SolevatoRepository {
  bool _isListeningForEvents = false;
  Timer? _publishPresenceTimer;
  Timer? _presenceResetTimer;

  SolevatoRepositoryImpl({
    required SolevatoClientService clientService,
    required LocalStorage localStorage,
    required SolevatoCallbacks streamCallbacks,
    required String inboxIdentifier,
  }) : super(
          clientService,
          localStorage,
          streamCallbacks,
          inboxIdentifier,
        );

  /// Fetches persisted messages.
  ///
  /// Calls [SolevatoCallbacks.onMessagesRetrieved] when [SolevatoClientService.getAllMessages] is successful
  /// Calls [SolevatoCallbacks.onError] when [SolevatoClientService.getAllMessages] fails
  @override
  Future<void> getMessages() async {
    try {
      final messages = await clientService.getAllMessages();
      await localStorage.messagesDao.saveAllMessages(messages);
      callbacks.onMessagesRetrieved?.call(messages);
    } on SolevatoClientException catch (e) {
      callbacks.onError?.call(e);
    }
  }

  /// Fetches persisted messages.
  ///
  /// Calls [SolevatoCallbacks.onPersistedMessagesRetrieved] if persisted messages are found
  @override
  void getPersistedMessages() {
    final persistedMessages = localStorage.messagesDao.getMessages();
    if (persistedMessages.isNotEmpty) {
      callbacks.onPersistedMessagesRetrieved?.call(persistedMessages);
    }
  }

  /// Initializes solevato client repository
  Future<void> initialize(SolevatoUser? user) async {
    try {
      if (user != null) {
        await localStorage.userDao.saveUser(user);
      }

      //refresh contact
      final contact = await clientService.getContact();
      localStorage.contactDao.saveContact(contact);

      callbacks.onContactResolved?.call(contact);

      //refresh conversation
      final conversations = await clientService.getConversations();
      final persistedConversation =
          localStorage.conversationDao.getConversation()!;
      final refreshedConversation = conversations.firstWhere(
          (element) => element.id == persistedConversation.id,
          orElse: () =>
              persistedConversation //highly unlikely orElse will be called but still added it just in case
          );
      localStorage.conversationDao.saveConversation(refreshedConversation);
    } on SolevatoClientException catch (e) {
      callbacks.onError?.call(e);
    }

    listenForEvents();
  }

  ///Sends message to solevato inbox
  Future<void> sendMessage(SolevatoNewMessageRequest request) async {
    SolevatoConversation? conversation =
        localStorage.conversationDao.getConversation();

    SolevatoContact? contact = localStorage.contactDao.getContact();

    if (conversation == null) {
      conversation =  await clientService.createNewConversation(
        inboxIdentifier,
        contact?.contactIdentifier ?? '',
      );
      await localStorage.conversationDao.saveConversation(conversation);
    }

    try {
      final createdMessage = await clientService.createMessage(request);
      await localStorage.messagesDao.saveMessage(createdMessage);
      callbacks.onMessageSent?.call(createdMessage, request.echoId);
      if (clientService.connection != null && !_isListeningForEvents) {
        listenForEvents();
      }
    } on SolevatoClientException catch (e) {
      callbacks.onError?.call(
          SolevatoClientException(e.cause, e.type, data: request.echoId));
    }
  }

  /// Connects to solevato websocket and starts listening for updates
  ///
  /// Received events/messages are pushed through [SolevatoClient.callbacks]
  @override
  void listenForEvents() {
    final token = localStorage.contactDao.getContact()?.pubsubToken;
    if (token == null) {
      return;
    }
    clientService.startWebSocketConnection(
        localStorage.contactDao.getContact()!.pubsubToken ?? "");

    final newSubscription = clientService.connection!.stream.listen((event) {
      SolevatoEvent solevatoEvent = SolevatoEvent.fromJson(jsonDecode(event));
      if (solevatoEvent.type == SolevatoEventType.welcome) {
        callbacks.onWelcome?.call();
      } else if (solevatoEvent.type == SolevatoEventType.ping) {
        callbacks.onPing?.call();
      } else if (solevatoEvent.type == SolevatoEventType.confirm_subscription) {
        if (!_isListeningForEvents) {
          _isListeningForEvents = true;
        }
        _publishPresenceUpdates();
        callbacks.onConfirmedSubscription?.call();
      } else if (solevatoEvent.message?.event ==
          SolevatoEventMessageType.message_created) {
        debugPrint("Here comes message: $event");
        final message = solevatoEvent.message!.data!.getMessage();
        localStorage.messagesDao.saveMessage(message);
        if (message.isMine) {
          callbacks.onMessageDelivered
              ?.call(message, solevatoEvent.message!.data!.echoId!);
        } else {
          callbacks.onMessageReceived?.call(message);
        }
      } else if (solevatoEvent.message?.event ==
          SolevatoEventMessageType.message_updated) {
        debugPrint("here comes the updated message: $event");

        final message = solevatoEvent.message!.data!.getMessage();
        localStorage.messagesDao.saveMessage(message);

        callbacks.onMessageUpdated?.call(message);
      } else if (solevatoEvent.message?.event ==
          SolevatoEventMessageType.conversation_typing_off) {
        callbacks.onConversationStoppedTyping?.call();
      } else if (solevatoEvent.message?.event ==
          SolevatoEventMessageType.conversation_typing_on) {
        callbacks.onConversationStartedTyping?.call();
      } else if (solevatoEvent.message?.event ==
              SolevatoEventMessageType.conversation_status_changed &&
          solevatoEvent.message?.data?.status == "resolved" &&
          solevatoEvent.message?.data?.id ==
              (localStorage.conversationDao.getConversation()?.id ?? 0)) {
        //delete conversation result
        callbacks.onConversationResolved?.call(
          localStorage.conversationDao.getConversation()!,
        );
        localStorage.conversationDao.deleteConversation();
        localStorage.messagesDao.clear();
      } else if (solevatoEvent.message?.event ==
          SolevatoEventMessageType.presence_update) {
        final presenceStatuses =
            (solevatoEvent.message!.data!.users as Map<dynamic, dynamic>)
                .values;
        final isOnline = presenceStatuses.contains("online");
        if (isOnline) {
          callbacks.onConversationIsOnline?.call();
          _presenceResetTimer?.cancel();
          _startPresenceResetTimer();
        } else {
          callbacks.onConversationIsOffline?.call();
        }
      } else {
        debugPrint("solevato unknown event: $event");
      }
    });
    _subscriptions.add(newSubscription);
  }

  /// Clears all data related to current solevato client instance
  @override
  Future<void> clear() async {
    await localStorage.clear();
  }

  /// Cancels websocket stream subscriptions and disposes [localStorage]
  @override
  void dispose() {
    localStorage.dispose();
    callbacks = SolevatoCallbacks();
    _presenceResetTimer?.cancel();
    _publishPresenceTimer?.cancel();
    _subscriptions.forEach((subs) {
      subs.cancel();
    });
  }

  ///Send actions like user started typing
  @override
  void sendAction(SolevatoActionType action) {
    clientService.sendAction(
        localStorage.contactDao.getContact()!.pubsubToken ?? "", action);
  }

  ///Publishes presence update to websocket channel at a 30 second interval
  void _publishPresenceUpdates() {
    sendAction(SolevatoActionType.update_presence);
    _publishPresenceTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      sendAction(SolevatoActionType.update_presence);
    });
  }

  ///Triggers an offline presence event after 40 seconds without receiving a presence update event
  void _startPresenceResetTimer() {
    _presenceResetTimer = Timer.periodic(Duration(seconds: 40), (timer) {
      callbacks.onConversationIsOffline?.call();
      _presenceResetTimer?.cancel();
    });
  }
}
