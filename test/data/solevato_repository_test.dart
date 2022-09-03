import 'dart:async';
import 'dart:convert';

import 'package:solevato_client_sdk_flutter/solevato_callbacks.dart';
import 'package:solevato_client_sdk_flutter/data/solevato_repository.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:solevato_client_sdk_flutter/data/local/local_storage.dart';
import 'package:solevato_client_sdk_flutter/data/remote/solevato_client_exception.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_action_data.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_new_message_request.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/test_resources_util.dart';
import 'solevato_repository_test.mocks.dart';
import 'local/local_storage_test.mocks.dart';

@GenerateMocks(
    [LocalStorage, SolevatoClientService, SolevatoCallbacks, WebSocketChannel])
void main() {
  group("Solevato Repository Tests", () {
    late final SolevatoContact testContact;

    late final SolevatoConversation testConversation;
    final testUser = SolevatoUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {});
    late final SolevatoMessage testMessage;

    final mockLocalStorage = MockLocalStorage();
    final mockSolevatoClientService = MockSolevatoClientService();
    final mockSolevatoCallbacks = MockSolevatoCallbacks();
    final mockMessagesDao = MockSolevatoMessagesDao();
    final mockContactDao = MockSolevatoContactDao();
    final mockConversationDao = MockSolevatoConversationDao();
    final mockUserDao = MockSolevatoUserDao();
    StreamController mockWebSocketStream = StreamController.broadcast();
    final mockWebSocketChannel = MockWebSocketChannel();

    late final SolevatoRepository repo;

    setUpAll(() async {
      testContact = SolevatoContact.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "contact"));
      testConversation = SolevatoConversation.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "conversation"));
      testMessage = SolevatoMessage.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "message"));

      when(mockLocalStorage.messagesDao).thenReturn(mockMessagesDao);
      when(mockLocalStorage.contactDao).thenReturn(mockContactDao);
      when(mockLocalStorage.userDao).thenReturn(mockUserDao);
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      when(mockSolevatoClientService.connection)
          .thenReturn(mockWebSocketChannel);
      when(mockWebSocketChannel.stream)
          .thenAnswer((_) => mockWebSocketStream.stream);
      when(mockSolevatoClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      repo = SolevatoRepositoryImpl(
          clientService: mockSolevatoClientService,
          localStorage: mockLocalStorage,
          streamCallbacks: mockSolevatoCallbacks);
    });

    setUp(() {
      reset(mockSolevatoCallbacks);
      reset(mockContactDao);
      reset(mockConversationDao);
      reset(mockUserDao);
      reset(mockMessagesDao);
      when(mockContactDao.getContact()).thenReturn(testContact);
      mockWebSocketStream = StreamController.broadcast();
      when(mockWebSocketChannel.stream)
          .thenAnswer((_) => mockWebSocketStream.stream);
    });

    test(
        'Given messages are successfully fetched when getMessages is called, then callback should be called with fetched messages',
        () async {
      //GIVEN
      final testMessages = [testMessage];
      when(mockSolevatoClientService.getAllMessages())
          .thenAnswer((_) => Future.value(testMessages));
      when(mockSolevatoCallbacks.onMessagesRetrieved).thenAnswer((_) => (_) {});
      when(mockMessagesDao.saveAllMessages(any))
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await repo.getMessages();

      //THEN
      verify(mockSolevatoClientService.getAllMessages());
      verify(mockSolevatoCallbacks.onMessagesRetrieved?.call(testMessages));
      verify(mockMessagesDao.saveAllMessages(testMessages));
    });

    test(
        'Given messages are fails to fetch when getMessages is called, then callback should be called with an error',
        () async {
      //GIVEN
      final testError = SolevatoClientException(
          "error", SolevatoClientExceptionType.GET_MESSAGES_FAILED);
      when(mockSolevatoClientService.getAllMessages()).thenThrow(testError);
      when(mockSolevatoCallbacks.onError).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onMessagesRetrieved).thenAnswer((_) => (_) {});

      //WHEN
      await repo.getMessages();

      //THEN
      verify(mockSolevatoClientService.getAllMessages());
      verifyNever(mockSolevatoCallbacks.onMessagesRetrieved);
      verify(mockSolevatoCallbacks.onError?.call(testError));
      verifyNever(mockMessagesDao.saveAllMessages(any));
    });

    test(
        'Given persisted messages are successfully fetched when getPersitedMessages is called, then callback should be called with fetched messages',
        () async {
      //GIVEN
      final testMessages = [testMessage];
      when(mockMessagesDao.getMessages()).thenReturn(testMessages);
      when(mockSolevatoCallbacks.onPersistedMessagesRetrieved)
          .thenAnswer((_) => (_) {});

      //WHEN
      repo.getPersistedMessages();

      //THEN
      verifyNever(mockSolevatoClientService.getAllMessages());
      verify(mockSolevatoCallbacks.onPersistedMessagesRetrieved
          ?.call(testMessages));
    });

    test(
        'Given message is successfully sent when sendMessage is called, then callback should be called with sent message',
        () async {
      //GIVEN
      final messageRequest =
          SolevatoNewMessageRequest(content: "new message", echoId: "echoId");
      when(mockSolevatoClientService.createMessage(any))
          .thenAnswer((_) => Future.value(testMessage));
      when(mockSolevatoCallbacks.onMessageSent).thenAnswer((_) => (_, __) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await repo.sendMessage(messageRequest);

      //THEN
      verify(mockSolevatoClientService.createMessage(messageRequest));
      verify(mockSolevatoCallbacks.onMessageSent
          ?.call(testMessage, messageRequest.echoId));
      verify(mockMessagesDao.saveMessage(testMessage));
    });

    test(
        'Given message fails to send when sendMessage is called, then callback should be called with an error',
        () async {
      //GIVEN
      final testError = SolevatoClientException(
          "error", SolevatoClientExceptionType.SEND_MESSAGE_FAILED);
      final messageRequest =
          SolevatoNewMessageRequest(content: "new message", echoId: "echoId");
      when(mockSolevatoClientService.createMessage(any)).thenThrow(testError);
      when(mockSolevatoCallbacks.onError).thenAnswer((_) => (_) {});

      //WHEN
      await repo.sendMessage(messageRequest);

      //THEN
      verify(mockSolevatoClientService.createMessage(messageRequest));
      verify(mockSolevatoCallbacks.onError?.call(testError));
      verifyNever(mockMessagesDao.saveMessage(any));
    });

    test(
        'Given repo is initialized with user successfully when initialize is called, then client should be properly initialized',
        () async {
      //GIVEN
      when(mockSolevatoClientService.getContact())
          .thenAnswer((_) => Future.value(testContact));
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockSolevatoClientService.getConversations())
          .thenAnswer((_) => Future.value([testConversation]));
      when(mockUserDao.saveUser(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockContactDao.saveContact(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockConversationDao.saveConversation(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockSolevatoClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      //WHEN
      await repo.initialize(testUser);

      //THEN
      verify(mockSolevatoClientService.getContact());
      verify(mockUserDao.saveUser(testUser));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
    });

    test(
        'Given repo is initialized with null user successfully when initialize is called, then client should be properly initialized',
        () async {
      //GIVEN
      when(mockSolevatoClientService.getContact())
          .thenAnswer((_) => Future.value(testContact));
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockSolevatoClientService.getConversations())
          .thenAnswer((_) => Future.value([testConversation]));
      when(mockUserDao.saveUser(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockContactDao.saveContact(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockConversationDao.saveConversation(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockSolevatoClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      //WHEN
      await repo.initialize(null);

      //THEN
      verifyNever(mockUserDao.saveUser(testUser));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
    });

    test(
        'Given welcome event is received when listening for events, then callback welcome event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onWelcome).thenAnswer((_) => () {});
      final dynamic welcomeEvent = {"type": "welcome"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(welcomeEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSolevatoCallbacks.onWelcome?.call());
    });

    test(
        'Given ping event is received when listening for events, then callback onPing event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onPing).thenAnswer((_) => () {});
      final dynamic pingEvent = {"type": "ping", "message": 12243849943};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(pingEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSolevatoCallbacks.onPing?.call());
    });

    test(
        'Given confirm subscription event is received when listening for events, then callback onConfirmSubscription event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoClientService.sendAction(any, any))
          .thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onConfirmedSubscription)
          .thenAnswer((_) => () {});
      final dynamic confirmSubscriptionEvent = {"type": "confirm_subscription"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(confirmSubscriptionEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSolevatoCallbacks.onConfirmedSubscription?.call());
      verify(mockSolevatoClientService.sendAction(
          testContact.pubsubToken, SolevatoActionType.update_presence));
    });

    test(
        'Given typing on event is received when listening for events, then callback onConversationStartedTyping event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onConversationStartedTyping)
          .thenAnswer((_) => () {});
      final dynamic typingOnEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_typing_on");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(typingOnEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSolevatoCallbacks.onConversationStartedTyping?.call());
    });

    test(
        'Given online presence update event is received when listening for events, then callback onConversationIsOnline event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onConversationIsOnline)
          .thenAnswer((_) => () {});
      final dynamic presenceUpdateOnlineEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_presence_update");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(presenceUpdateOnlineEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSolevatoCallbacks.onConversationIsOnline?.call());
    });

    test(
        'Given conversation is offline when listening for events, then callback onConversationIsOffline event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onConversationIsOffline)
          .thenAnswer((_) => () {});
      when(mockSolevatoCallbacks.onConversationIsOnline)
          .thenAnswer((_) => () {});
      final dynamic presenceUpdateOnlineEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_presence_update");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(presenceUpdateOnlineEvent));
      await Future.delayed(Duration(seconds: 41));

      //THEN
      verify(mockSolevatoCallbacks.onConversationIsOnline?.call());
      verify(mockSolevatoCallbacks.onConversationIsOffline?.call());
    }, timeout: Timeout(Duration(seconds: 45)));

    test(
        'Given typing off event is received when listening for events, then callback onConversationStoppedTyping event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onConversationStoppedTyping)
          .thenAnswer((_) => () {});
      final dynamic typingOffEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_typing_off");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(typingOffEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSolevatoCallbacks.onConversationStoppedTyping?.call());
    });

    test(
        'Given conversation status changed event is received when listening for events, then callback onConversationResolved event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onConversationResolved)
          .thenAnswer((_) => () {});
      final dynamic resolvedEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_status_changed");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(resolvedEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSolevatoCallbacks.onConversationResolved?.call());
    });

    test(
        'Given an updated message event is received when listening for events, then callback onMessageUpdated event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockSolevatoCallbacks.onMessageUpdated).thenAnswer((_) => (_) {});
      final dynamic messageUpdatedEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_message_updated");

      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(messageUpdatedEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      final message =
          SolevatoMessage.fromJson(messageUpdatedEvent["message"]["data"]);
      verify(mockSolevatoCallbacks.onMessageUpdated?.call(message));
    });

    test(
        'Given new message event is sent when listening for events, then callback onMessageSent event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSolevatoCallbacks.onMessageDelivered)
          .thenAnswer((_) => (_, __) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));
      final dynamic messageSentEvent = {
        "type": "message",
        "message": {
          "event": "message.created",
          "data": {
            "id": 0,
            "content": "content",
            "echo_id": "echo_id",
            "message_type": 0,
            "content_type": "contentType",
            "content_attributes": "contentAttributes",
            "created_at": DateTime.now().toString(),
            "conversation_id": 0,
            "attachments": [],
          }
        }
      };

      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(messageSentEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      final message =
          SolevatoMessage.fromJson(messageSentEvent["message"]["data"]);
      verify(mockSolevatoCallbacks.onMessageDelivered
          ?.call(message, messageSentEvent["message"]["echo_id"]));
    });

    test(
        'Given unknown event is received when listening for events, then no callback event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      final dynamic unknownEvent = {"type": "unknown"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(unknownEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verifyZeroInteractions(mockSolevatoCallbacks);
      repo.dispose();
    });

    test(
        'Given action is successfully sent when sendAction is called, then client service sendAction should be triggered',
        () {
      //GIVEN
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockSolevatoClientService.sendAction(any, any))
          .thenAnswer((realInvocation) => Future.microtask(() {}));

      //WHEN
      repo.sendAction(SolevatoActionType.update_presence);

      //THEN
      verify(mockSolevatoClientService.sendAction(
          testContact.pubsubToken, SolevatoActionType.update_presence));
    });

    test(
        'Given repository is successfully disposed when dispose is called, then localStorage should be disposed',
        () {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});

      //WHEN
      repo.dispose();

      //THEN
      verify(mockLocalStorage.dispose());
    });

    test(
        'Given repository is successfully cleared when clear is called, then localStorage should be cleared',
        () {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});

      //WHEN
      repo.clear();

      //THEN
      verify(mockLocalStorage.clear());
    });

    tearDown(() async {
      await mockWebSocketStream.close();
    });

    tearDownAll(() {
      repo.dispose();
    });
  });
}
