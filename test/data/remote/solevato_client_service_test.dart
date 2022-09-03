import 'dart:convert';

import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/remote/solevato_client_exception.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_action_data.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_new_message_request.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../utils/test_resources_util.dart';
import 'solevato_client_service_test.mocks.dart';

@GenerateMocks([Dio, WebSocketChannel, WebSocketSink])
void main() {
  group("Client Service Tests", () {
    late final SolevatoClientService clientService;
    final testBaseUrl = "https://test.com";
    final mockDio = MockDio();

    setUpAll(() {
      clientService = SolevatoClientServiceImpl(testBaseUrl, dio: mockDio);
    });

    _createSuccessResponse(body) {
      return Response(
          data: body,
          statusCode: 200,
          requestOptions: RequestOptions(path: ""));
    }

    _createErrorResponse({required int statusCode, body}) {
      return Response(
          data: body,
          statusCode: statusCode,
          requestOptions: RequestOptions(path: ""));
    }

    test(
        'Given message is successfully sent when createMessage is called, then return sent message',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "message");
      final request =
          SolevatoNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: request.toJson())).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.createMessage(request);

      //THEN
      expect(result, SolevatoMessage.fromJson(responseBody));
    });

    test(
        'Given sending message returns with error response when createMessage is called, then throw error',
        () async {
      //GIVEN
      final request =
          SolevatoNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: request.toJson())).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.createMessage(request);
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.SEND_MESSAGE_FAILED));
    });

    test(
        'Given sending message fails when createMessage is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      final request =
          SolevatoNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: request.toJson())).thenThrow(testError);

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.createMessage(request);
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.SEND_MESSAGE_FAILED));
    });

    test(
        'Given messages are successfully fetched when getAllMessages is called, then return fetched messages',
        () async {
      //GIVEN
      final dynamic responseBody =
          await TestResourceUtil.readJsonResource(fileName: "messages");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getAllMessages();

      //THEN
      final expected =
          responseBody.map((e) => SolevatoMessage.fromJson(e)).toList();
      expect(result, equals(expected));
    });

    test(
        'Given fetch messages returns with error response when getAllMessages is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.getAllMessages();
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.GET_MESSAGES_FAILED));
    });

    test(
        'Given fetch messages fails when getAllMessages is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.getAllMessages();
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.GET_MESSAGES_FAILED));
    });

    test(
        'Given contact is successfully fetched when getContact is called, then return fetched contact',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "contact");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getContact();

      //THEN
      expect(result, equals(SolevatoContact.fromJson(responseBody)));
    });

    test(
        'Given fetch contact returns with error response when getContact is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.getContact();
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.GET_CONTACT_FAILED));
    });

    test(
        'Given fetch contact fails when getContact is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.getContact();
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.GET_CONTACT_FAILED));
    });

    test(
        'Given conversations are successfully fetched when getConversations is called, then return fetched conversations',
        () async {
      //GIVEN
      final dynamic responseBody =
          await TestResourceUtil.readJsonResource(fileName: "conversations");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getConversations();

      //THEN
      final expected =
          responseBody.map((e) => SolevatoConversation.fromJson(e)).toList();
      expect(result, equals(expected));
    });

    test(
        'Given fetch conversations returns with error response when getConversations is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.getConversations();
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.GET_CONVERSATION_FAILED));
    });

    test(
        'Given fetch conversations fails when getConversations is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.getConversations();
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.GET_CONVERSATION_FAILED));
    });

    test(
        'Given contact is successfully updated when updateContact is called, then return updated contact',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "contact");
      final update = {"name": "Updated name"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateContact(update);

      //THEN
      expect(result, SolevatoContact.fromJson(responseBody));
    });

    test(
        'Given contact update returns with error response when updateContact is called, then throw error',
        () async {
      //GIVEN
      final update = {"name": "Updated name"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.updateContact(update);
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.UPDATE_CONTACT_FAILED));
    });

    test(
        'Given contact update fails when updateContact is called, then throw error',
        () async {
      //GIVEN
      final update = {"name": "Updated name"};
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.patch(any, data: update)).thenThrow(testError);

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.updateContact(update);
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.UPDATE_CONTACT_FAILED));
    });

    test(
        'Given message is successfully updated when updateMessage is called, then return updated message',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "message");
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateMessage(testMessageId, update);

      //THEN
      expect(result, SolevatoMessage.fromJson(responseBody));
    });

    test(
        'Given message update returns with error response when updateMessage is called, then throw error',
        () async {
      //GIVEN
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.updateMessage(testMessageId, update);
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)), data: update));
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.UPDATE_MESSAGE_FAILED));
    });

    test(
        'Given message update fails when updateMessage is called, then throw error',
        () async {
      //GIVEN
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.patch(any, data: update)).thenThrow(testError);

      //WHEN
      SolevatoClientException? solevatoClientException;
      try {
        await clientService.updateMessage(testMessageId, update);
      } on SolevatoClientException catch (e) {
        solevatoClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)), data: update));
      expect(SolevatoClientException, isNotNull);
      expect(solevatoClientException!.type,
          equals(SolevatoClientExceptionType.UPDATE_MESSAGE_FAILED));
    });

    test(
        'Given websocket connection is successful when startWebSocketConnection is called, then subscribe for events',
        () async {
      //GIVEN
      final testPubsubtoken = "testPubsubtoken";
      final mockWebSocketChannel = MockWebSocketChannel();
      final mockWebSocketSink = MockWebSocketSink();

      final WebSocketChannel Function(Uri) startConnection = (Uri uri) {
        return mockWebSocketChannel;
      };
      when(mockWebSocketChannel.sink).thenReturn(mockWebSocketSink);
      when(mockWebSocketSink.close()).thenAnswer((_) => Future.value({}));
      when(mockWebSocketSink.add(any)).thenAnswer((_) => Future.value({}));

      //WHEN
      clientService.startWebSocketConnection(testPubsubtoken,
          onStartConnection: startConnection);

      //THEN
      final subscriptionPayload = jsonEncode({
        "command": "subscribe",
        "identifier": jsonEncode(
            {"channel": "RoomChannel", "pubsub_token": testPubsubtoken})
      });
      verify(mockWebSocketSink.add(subscriptionPayload));
      mockWebSocketSink.close();
    });

    test(
        'Given action is sent successfully when sendAction is called, then websocket sink should be triggered',
        () async {
      //GIVEN
      final testPubsubtoken = "testPubsubtoken";
      final mockWebSocketChannel = MockWebSocketChannel();
      final mockWebSocketSink = MockWebSocketSink();

      when(mockWebSocketChannel.sink).thenReturn(mockWebSocketSink);
      when(mockWebSocketSink.close()).thenAnswer((_) => Future.value({}));
      when(mockWebSocketSink.add(any)).thenAnswer((_) => Future.value({}));
      clientService.connection = mockWebSocketChannel;

      //WHEN
      clientService.sendAction(
          testPubsubtoken, SolevatoActionType.update_presence);

      //THEN
      verify(mockWebSocketSink.add(any));
    });
  });
}
