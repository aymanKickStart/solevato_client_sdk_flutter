//import 'dart:async';

import 'package:solevato_client_sdk_flutter/solevato_client.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_contact.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:solevato_client_sdk_flutter/di/modules.dart';
import 'package:solevato_client_sdk_flutter/ui/solevato_chat_dialog.dart';
import 'package:solevato_client_sdk_flutter/ui/solevato_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

import '../data/solevato_repository_test.mocks.dart';
import '../utils/test_resources_util.dart';

void main() {
  final testInboxIdentifier = "testIdentifier";
  final testBaseUrl = "https://testbaseurl.com";
  late ProviderContainer mockProviderContainer;
  final mockService = MockSolevatoClientService();

  final testUser = SolevatoUser(
      identifier: "identifier",
      identifierHash: "identifierHash",
      name: "name",
      email: "email",
      avatarUrl: "avatarUrl",
      customAttributes: {});
  final testClientInstanceKey = SolevatoClient.getClientInstanceKey(
      baseUrl: testBaseUrl,
      inboxIdentifier: testInboxIdentifier,
      userIdentifier: testUser.identifier);
  late final SolevatoContact mockContact;
  late final SolevatoConversation mockConversation;
  late final List<SolevatoMessage> mockMessages;
  final SolevatoL10n testL10n = SolevatoL10n();
  final mockWebSocketChannel = MockWebSocketChannel();
  final String testModalTitle = "SolevatoSupport";

  setUpAll(() async {
    mockContact = SolevatoContact.fromJson(
        await TestResourceUtil.readJsonResource(fileName: "contact"));

    mockConversation = SolevatoConversation.fromJson(
        await TestResourceUtil.readJsonResource(fileName: "conversation"));

    mockMessages = [
      SolevatoMessage.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "message"))
    ];

    when(mockService.getContact())
        .thenAnswer((realInvocation) => Future.value(mockContact));
    when(mockService.getConversations())
        .thenAnswer((realInvocation) => Future.value([mockConversation]));
    when(mockService.getAllMessages())
        .thenAnswer((realInvocation) => Future.value(mockMessages));
    when(mockService.sendAction(any, any))
        .thenAnswer((realInvocation) => Future.microtask(() {}));

    when(mockService.connection).thenReturn(mockWebSocketChannel);

    mockProviderContainer = ProviderContainer();
    mockProviderContainer.updateOverrides([
      solevatoClientServiceProvider
          .overrideWithProvider((ref, param) => mockService)
    ]);
    SolevatoClient.providerContainerMap.update(
        testClientInstanceKey, (_) => mockProviderContainer,
        ifAbsent: () => mockProviderContainer);
    SolevatoClient.providerContainerMap.update(
        "all", (_) => mockProviderContainer,
        ifAbsent: () => mockProviderContainer);
  });

  testWidgets(
      'Given modal successfully instantiates when SolevatoChatModal is constructed, then modal should be correctly ',
      (WidgetTester tester) async {
    // WHEN
    await tester.pumpWidget(MaterialApp(
      home: SolevatoChatDialog(
        baseUrl: testBaseUrl,
        inboxIdentifier: testInboxIdentifier,
        title: testModalTitle,
        user: testUser,
        l10n: testL10n,
      ),
    ));

    // THEN
    expect(find.text(testModalTitle), findsOneWidget);
    expect(find.text(testL10n.offlineText), findsOneWidget);
  });
}
