import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/remote/solevato_client_exception.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_action.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_action_data.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_api_interceptor.dart';
import 'package:solevato_client_sdk_flutter/data/remote/requests/solevato_new_message_request.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../local/entity/solevato_user.dart';

/// Service for handling solevato api calls
/// See [SolevatoClientServiceImpl]
abstract class SolevatoClientService {
  final String _baseUrl;
  WebSocketChannel? connection;
  final Dio _dio;

  SolevatoClientService(this._baseUrl, this._dio);

  Future<SolevatoContact> updateContact(update);

  Future<SolevatoContact> getContact();

  Future<List<SolevatoConversation>> getConversations();

  Future<SolevatoConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier);

  Future<SolevatoContact> createNewContact(
      String inboxIdentifier, SolevatoUser? user);

  Future<SolevatoMessage> createMessage(SolevatoNewMessageRequest request);

  Future<SolevatoMessage> updateMessage(String messageIdentifier, update);

  Future<List<SolevatoMessage>> getAllMessages();

  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection});

  void sendAction(String contactPubsubToken, SolevatoActionType action);
}

class SolevatoClientServiceImpl extends SolevatoClientService {
  SolevatoClientServiceImpl(String baseUrl, {required Dio dio})
      : super(baseUrl, dio);

  void _addInterceptor() {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        error: true,
        request: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  ///Sends message to solevato inbox
  @override
  Future<SolevatoMessage> createMessage(
      SolevatoNewMessageRequest request) async {
    _addInterceptor();
    try {
      CancelToken cancelToken = CancelToken();

      final createResponse = await _dio.post(
          "/public/api/v1/inboxes/${SolevatoClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SolevatoClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${SolevatoClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages",
          data: request.toJson(),
          cancelToken: cancelToken);
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return SolevatoMessage.fromJson(createResponse.data);
      } else {
        throw SolevatoClientException(
            createResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.SEND_MESSAGE_FAILED);
      }
    } on DioError catch (e) {
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.SEND_MESSAGE_FAILED);
    }
  }

  ///Gets all messages of current solevato client instance's conversation
  @override
  Future<List<SolevatoMessage>> getAllMessages() async {
    _addInterceptor();
    try {
      CancelToken cancelToken = CancelToken();
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${SolevatoClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SolevatoClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${SolevatoClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages",
          cancelToken: cancelToken);
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return (createResponse.data as List<dynamic>)
            .map(((json) => SolevatoMessage.fromJson(json)))
            .toList();
      } else {
        debugPrint('Error getting messages: ${createResponse.data}');
        throw SolevatoClientException(
            createResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.GET_MESSAGES_FAILED);
      }
    } on DioError catch (e) {
      debugPrint('Error getting messages: ${e.error}');
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.GET_MESSAGES_FAILED);
    }
  }

  ///Gets contact of current solevato client instance
  @override
  Future<SolevatoContact> getContact() async {
    _addInterceptor();

    try {
      CancelToken cancelToken = CancelToken();

      final createResponse = await _dio.get(
          "/public/api/v1"
          "/inboxes/${SolevatoClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}"
          "/contacts/${SolevatoClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}",
          cancelToken: cancelToken);
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        final contact = SolevatoContact.fromJson(createResponse.data);
        return SolevatoContact.fromJson(createResponse.data);
      } else {
        debugPrint('Error getting contact: ${createResponse.data}');
        throw SolevatoClientException(
            createResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.GET_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      debugPrint('Error getting contact: ${e.error}');
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.GET_CONTACT_FAILED);
    }
  }

  ///Gets all conversation of current solevato client instance
  @override
  Future<List<SolevatoConversation>> getConversations() async {
    _addInterceptor();
    try {
      CancelToken cancelToken = CancelToken();

      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${SolevatoClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SolevatoClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations",
          cancelToken: cancelToken);
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return (createResponse.data as List<dynamic>)
            .map(((json) => SolevatoConversation.fromJson(json)))
            .toList();
      } else {
        throw SolevatoClientException(
            createResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.GET_CONVERSATION_FAILED);
      }
    } on DioError catch (e) {
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.GET_CONVERSATION_FAILED);
    }
  }

  ///Update current client instance's contact
  @override
  Future<SolevatoContact> updateContact(update) async {
    _addInterceptor();
    try {
      CancelToken cancelToken = CancelToken();

      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${SolevatoClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SolevatoClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}",
          data: update,
          cancelToken: cancelToken);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        return SolevatoContact.fromJson(updateResponse.data);
      } else {
        throw SolevatoClientException(
            updateResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.UPDATE_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.UPDATE_CONTACT_FAILED);
    }
  }

  ///Update message with id [messageIdentifier] with contents of [update]
  @override
  Future<SolevatoMessage> updateMessage(
      String messageIdentifier, update) async {
    _addInterceptor();
    try {
      CancelToken cancelToken = CancelToken();

      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${SolevatoClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SolevatoClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${SolevatoClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages/$messageIdentifier",
          data: update,
          cancelToken: cancelToken);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        return SolevatoMessage.fromJson(updateResponse.data);
      } else {
        throw SolevatoClientException(
            updateResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.UPDATE_MESSAGE_FAILED);
      }
    } on DioError catch (e) {
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.UPDATE_MESSAGE_FAILED);
    }
  }

  @override
  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection}) {
    final socketUrl = Uri.parse(_baseUrl.replaceFirst("http", "ws") + "/cable");
    this.connection = onStartConnection == null
        ? WebSocketChannel.connect(socketUrl)
        : onStartConnection(socketUrl);
    connection!.sink.add(jsonEncode({
      "command": "subscribe",
      "identifier": jsonEncode(
          {"channel": "RoomChannel", "pubsub_token": contactPubsubToken})
    }));
  }

  @override
  void sendAction(String contactPubsubToken, SolevatoActionType actionType) {
    final SolevatoAction action;
    final identifier = jsonEncode(
        {"channel": "RoomChannel", "pubsub_token": contactPubsubToken});
    switch (actionType) {
      case SolevatoActionType.subscribe:
        action = SolevatoAction(identifier: identifier, command: "subscribe");
        break;
      default:
        action = SolevatoAction(
            identifier: identifier,
            data: SolevatoActionData(action: actionType),
            command: "message");
        break;
    }
    connection?.sink.add(jsonEncode(action.toJson()));
  }

  ///Creates a new conversation for inbox with [inboxIdentifier] and contact with source id [contactIdentifier]
  @override
  Future<SolevatoConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier) async {
    try {
      CancelToken cancelToken = CancelToken();

      final createResponse = await _dio.post(
          "/public/api/v1/inboxes/$inboxIdentifier/contacts/$contactIdentifier/conversations",
          cancelToken: cancelToken);

      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        //creating contact successful continue with request
        final newConversation =
            SolevatoConversation.fromJson(createResponse.data);
        return newConversation;
      } else {
        throw SolevatoClientException(
            createResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.CREATE_CONVERSATION_FAILED);
      }
    } on DioError catch (e) {
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.CREATE_CONVERSATION_FAILED);
    }
  }

  ///Creates new contact for inbox with [inboxIdentifier] and passes [user] body to be linked to created contact
  @override
  Future<SolevatoContact> createNewContact(
      String inboxIdentifier, SolevatoUser? user) async {
    try {
      CancelToken cancelToken = CancelToken();

      final createResponse = await _dio.post(
          "/public/api/v1/inboxes/$inboxIdentifier/contacts",
          data: user?.toJson(),
          cancelToken: cancelToken);
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        //creating contact successful continue with request
        final contact = SolevatoContact.fromJson(createResponse.data);
        debugPrint(
            'solevato-client-service: contact created: $contact - $createResponse');
        return contact;
      } else {
        throw SolevatoClientException(
            createResponse.statusMessage ?? "unknown error",
            SolevatoClientExceptionType.CREATE_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      debugPrint('Error creating contact: ${e.message}');
      throw SolevatoClientException(
          e.message, SolevatoClientExceptionType.CREATE_CONTACT_FAILED);
    }
  }
}
