import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:solevato_client_sdk_flutter/data/remote/solevato_client_exception.dart';
import 'package:solevato_client_sdk_flutter/data/remote/service/solevato_client_api_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for handling solevato user authentication api calls
/// See [SolevatoClientAuthServiceImpl]
abstract class SolevatoClientAuthService {
  WebSocketChannel? connection;
  final Dio dio;

  SolevatoClientAuthService(this.dio);

  Future<SolevatoContact> createNewContact(
      String inboxIdentifier, SolevatoUser? user);

  Future<SolevatoConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier);
}

/// Default Implementation for [SolevatoClientAuthService]
class SolevatoClientAuthServiceImpl extends SolevatoClientAuthService {
  SolevatoClientAuthServiceImpl({required Dio dio}) : super(dio);

  ///Creates new contact for inbox with [inboxIdentifier] and passes [user] body to be linked to created contact
  @override
  Future<SolevatoContact> createNewContact(
      String inboxIdentifier, SolevatoUser? user) async {
    try {
      final createResponse = await dio.post(
          "/public/api/v1/inboxes/$inboxIdentifier/contacts",
          data: user?.toJson());
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        //creating contact successful continue with request
        final contact = SolevatoContact.fromJson(createResponse.data);
        debugPrint('solevato-client-auth-service: contact created: $contact - $createResponse');
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

  ///Creates a new conversation for inbox with [inboxIdentifier] and contact with source id [contactIdentifier]
  @override
  Future<SolevatoConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier) async {
    try {
      final createResponse = await dio.post(
          "/public/api/v1/inboxes/$inboxIdentifier/contacts/$contactIdentifier/conversations");
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
}
