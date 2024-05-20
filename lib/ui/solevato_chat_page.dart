import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_conversation.dart';
import 'package:solevato_client_sdk_flutter/di/modules.dart';
import 'package:solevato_client_sdk_flutter/solevato_callbacks.dart';
import 'package:solevato_client_sdk_flutter/solevato_client.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_user.dart';
import 'package:solevato_client_sdk_flutter/data/remote/solevato_client_exception.dart';
import 'package:solevato_client_sdk_flutter/ui/custom_text_message.dart';
import 'package:solevato_client_sdk_flutter/ui/solevato_chat_theme.dart';
import 'package:solevato_client_sdk_flutter/ui/solevato_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:solevato_client_sdk_flutter/util/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../data/local/entity/solevato_contact.dart';
import '../data/local/local_storage.dart';
import '../util/package_info_handler.dart';
import 'package:synchronized/synchronized.dart';

import 'package:flutter_chat_ui/src/widgets/inherited_chat_theme.dart';

import 'package:flutter_chat_ui/src/util.dart';

///solevato chat widget
/// {@category FlutterClientSdk}
class SolevatoChat extends StatefulWidget {
  /// Specifies a custom app bar for solevato page widget
  final PreferredSizeWidget? appBar;

  ///Identifier for target solevato inbox.
  ///
  /// For more details contact solevato administration
  final String inboxIdentifier;

  /// Enables persistence of solevato client instance's contact, conversation and messages to disk
  /// for convenience.
  ///
  /// Setting [enablePersistence] to false holds solevato client instance's data in memory and is cleared as
  /// soon as solevato client instance is disposed
  final bool enablePersistence;

  /// Custom user details to be attached to solevato contact
  final SolevatoUser? user;

  /// See [ChatList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold]
  final double? onEndReachedThreshold;

  /// See [Message.onMessageLongPress]
  final void Function(types.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(types.Message)? onMessageTap;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText)? onSendPressed;

  /// See [Input.onTextChanged]
  final void Function(String)? onTextChanged;

  /// Show avatars for received messages.
  final bool showUserAvatars;

  /// Show user names for received messages.
  final bool showUserNames;

  final SolevatoChatTheme theme;

  /// See [SolevatoL10n]
  final SolevatoL10n l10n;

  /// See [Chat.timeFormat]
  final DateFormat? timeFormat;

  /// See [Chat.dateFormat]
  final DateFormat? dateFormat;

  ///See [SolevatoCallbacks.onWelcome]
  final void Function()? onWelcome;

  ///See [SolevatoCallbacks.onPing]
  final void Function()? onPing;

  ///See [SolevatoCallbacks.onConfirmedSubscription]
  final void Function()? onConfirmedSubscription;

  ///See [SolevatoCallbacks.onConversationStartedTyping]
  final void Function()? onConversationStartedTyping;

  ///See [SolevatoCallbacks.onConversationIsOnline]
  final void Function()? onConversationIsOnline;

  ///See [SolevatoCallbacks.onConversationIsOffline]
  final void Function()? onConversationIsOffline;

  ///See [SolevatoCallbacks.onConversationStoppedTyping]
  final void Function()? onConversationStoppedTyping;

  ///See [SolevatoCallbacks.onMessageReceived]
  final void Function(SolevatoMessage)? onMessageReceived;

  ///See [SolevatoCallbacks.onMessageSent]
  final void Function(SolevatoMessage)? onMessageSent;

  ///See [SolevatoCallbacks.onMessageDelivered]
  final void Function(SolevatoMessage)? onMessageDelivered;

  ///See [SolevatoCallbacks.onMessageUpdated]
  final void Function(SolevatoMessage)? onMessageUpdated;

  ///See [SolevatoCallbacks.onPersistedMessagesRetrieved]
  final void Function(List<SolevatoMessage>)? onPersistedMessagesRetrieved;

  ///See [SolevatoCallbacks.onMessagesRetrieved]
  final void Function(List<SolevatoMessage>)? onMessagesRetrieved;

  ///See [SolevatoCallbacks.onError]
  final void Function(SolevatoClientException)? onError;

  ///Horizontal padding is reduced if set to true
  final bool isPresentedInDialog;

  const SolevatoChat(
      {Key? key,
      required this.inboxIdentifier,
      this.enablePersistence = true,
      this.user,
      this.appBar,
      this.onEndReached,
      this.onEndReachedThreshold,
      this.onMessageLongPress,
      this.onMessageTap,
      this.onSendPressed,
      this.onTextChanged,
      this.showUserAvatars = true,
      this.showUserNames = true,
      this.theme = const SolevatoChatTheme(),
      this.l10n = const SolevatoL10n(),
      this.timeFormat,
      this.dateFormat,
      this.onWelcome,
      this.onPing,
      this.onConfirmedSubscription,
      this.onMessageReceived,
      this.onMessageSent,
      this.onMessageDelivered,
      this.onMessageUpdated,
      this.onPersistedMessagesRetrieved,
      this.onMessagesRetrieved,
      this.onConversationStartedTyping,
      this.onConversationStoppedTyping,
      this.onConversationIsOnline,
      this.onConversationIsOffline,
      this.onError,
      this.isPresentedInDialog = false})
      : super(key: key);

  @override
  _SolevatoChatState createState() => _SolevatoChatState();
}

class _SolevatoChatState extends State<SolevatoChat> {
  ///
  List<types.Message> _messages = [];

  final _lockMessages = Lock();

  late String status;

  final idGen = Uuid();
  late final _user;
  SolevatoClient? solevatoClient;

  late final solevatoCallbacks;

  bool? _disableBranding;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();

    PackageInfoHandler.instance.init();

    if (widget.user == null) {
      _user = types.User(id: idGen.v4());
    } else {
      _user = types.User(
        id: widget.user?.identifier ?? idGen.v4(),
        firstName: widget.user?.name,
        imageUrl: widget.user?.avatarUrl,
      );
    }

    solevatoCallbacks = SolevatoCallbacks(
      onWelcome: () {
        widget.onWelcome?.call();
      },
      onPing: () {
        widget.onPing?.call();
      },
      onConfirmedSubscription: () {
        widget.onConfirmedSubscription?.call();
      },
      onConversationStartedTyping: () {
        widget.onConversationStoppedTyping?.call();
      },
      onConversationStoppedTyping: () {
        widget.onConversationStartedTyping?.call();
      },
      onPersistedMessagesRetrieved: (persistedMessages) {
        if (widget.enablePersistence) {
          setState(() {
            _messages = persistedMessages
                .map((message) => _SolevatoMessageToTextMessage(message))
                .toList();
          });
        }
        for(var msg in _messages) {
          print("msggg: ${msg}");
        }
        widget.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages) {
        if (messages.isEmpty) {
          return;
        }
        setState(() {
          final chatMessages = messages
              .map((message) => _SolevatoMessageToTextMessage(message))
              .toList();
          final mergedMessages =
              <types.Message>[..._messages, ...chatMessages].toSet().toList();
          final now = DateTime.now().millisecondsSinceEpoch;
          mergedMessages.sort((a, b) {
            return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
          });
          _messages = mergedMessages;
        });
        widget.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (SolevatoMessage) {

        print("onMessageReceived: ${SolevatoMessage.toString()}");
        _addMessage(
          _SolevatoMessageToTextMessage(SolevatoMessage),
        );
        widget.onMessageReceived?.call(SolevatoMessage);
      },
      onMessageDelivered: (SolevatoMessage, echoId) {
        print("onMessageDelivered: ${SolevatoMessage.toString()}");

        _handleMessageSent(
            _SolevatoMessageToTextMessage(
              SolevatoMessage,
            ),
            echoId: echoId);
        widget.onMessageDelivered?.call(SolevatoMessage);
      },
      onMessageUpdated: (SolevatoMessage) {
        _handleMessageUpdated(
          _SolevatoMessageToTextMessage(
            SolevatoMessage,
          ),
        );
        widget.onMessageUpdated?.call(SolevatoMessage);
      },
      onMessageSent: (SolevatoMessage, echoId) {
        final textMessage = types.CustomMessage(
          id: echoId,
          author: _user,
          metadata: {
            "content": SolevatoMessage.content ?? '',
          },
          status: types.Status.delivered,
        );
        _handleMessageSent(textMessage, echoId: echoId);
        widget.onMessageSent?.call(SolevatoMessage);
      },
      onConversationResolved: (SolevatoConversation conversation) {
        final resolvedMessage = types.CustomMessage(
          id: idGen.v4(),
          metadata: {
            "content": widget.l10n.conversationResolvedMessage,
          },
          author: types.User(
              id: idGen.v4(),
              firstName: "Bot",
              imageUrl:
                  "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png"),
          status: types.Status.delivered,
        );
        _addMessage(resolvedMessage);
      },
      onError: (error) {
        if (error.type == SolevatoClientExceptionType.SEND_MESSAGE_FAILED) {
          _handleSendMessageFailed(error.data);
        }
        debugPrint(
            "Ooops! Something went wrong. Error Cause: ${error.cause} \nError Data: ${error.data} \nError Type: ${error.type}");
        widget.onError?.call(error);
      },
      onContactResolved: (SolevatoContact contact) {
        setState(() {
          _disableBranding = contact.disableBranding;
        });
      },
    );

    SolevatoClient.create(
      baseUrl: 'https://app.solevato.com',
      inboxIdentifier: widget.inboxIdentifier,
      user: widget.user,
      enablePersistence: widget.enablePersistence,
      callbacks: solevatoCallbacks,
    ).then((client) async {
      setState(() {
        solevatoClient = client;
        solevatoClient!.loadMessages();
      });
    }).onError((error, stackTrace) {
      widget.onError?.call(SolevatoClientException(
          error.toString(), SolevatoClientExceptionType.CREATE_CLIENT_FAILED));
      debugPrint("Solevato client failed with error $error: $stackTrace");
    });
  }

  types.CustomMessage _SolevatoMessageToTextMessage(
    SolevatoMessage message, {
    String? echoId,
  }) {
    String? avatarUrl = message.sender?.avatarUrl ?? message.sender?.thumbnail;

    //Sets avatar url to null if its a gravatar not found url
    //This enables placeholder for avatar to show
    if (avatarUrl?.contains("?d=404") ?? false) {
      avatarUrl = null;
    }
    var msgID = echoId == "" || echoId == null ? message.id.toString() : echoId;

    return types.CustomMessage(
      id: msgID,
      author: message.isMine ? _user : supportAgent(message, avatarUrl),
      metadata: {
        'content': message.content ?? "",
      },
      status: types.Status.seen,
      createdAt: DateTime.parse(message.createdAt).millisecondsSinceEpoch,
    );
  }

  types.User supportAgent(SolevatoMessage message, String? avatarUrl) {
    if (message.sender == null) {
      return types.User(
          id: idGen.v4(),
          firstName: "Bot",
          imageUrl:
              "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png");
    }
    return types.User(
      id: message.sender?.id.toString() ?? idGen.v4(),
      firstName: message.sender?.name,
      imageUrl: avatarUrl,
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendMessageFailed(String echoId) async {
    final index = _messages.indexWhere((element) => element.id == echoId);
    setState(() {
      _messages[index] = _messages[index].copyWith(status: types.Status.error);
    });
  }

  void _handleResendMessage(types.TextMessage message) async {
    solevatoClient!.sendMessage(content: message.text, echoId: message.id);
    final index = _messages.indexWhere((element) => element.id == message.id);
    setState(() {
      _messages[index] = message.copyWith(status: types.Status.sending);
    });
  }

  void _handleMessageTap(types.Message message) async {
    if (message.status == types.Status.error && message is types.TextMessage) {
      _handleResendMessage(message);
    }
    widget.onMessageTap?.call(message);
  }

  void _handlePreviewDataFetched(
      types.TextMessage message, types.PreviewData previewData) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleMessageSent(types.Message message, {String? echoId}) async {
    var msgID = echoId == "" || echoId == null ? message.id.toString() : echoId;

    await _lockMessages.synchronized(() {
      final index = _messages.indexWhere((element) => element.id == msgID);

      if (index == -1) return;

      if (_messages[index].status == types.Status.seen) {
        return;
      }

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        setState(() {
          _messages[index] = message;
        });
      });
    });
  }

  void _handleMessageUpdated(types.Message message) async {
    await _lockMessages.synchronized(() {
      final index = _messages
          .indexWhere((element) => element.id == message.id.toString());

      if (index == -1) return;

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        setState(() {
          _messages[index] = message;
        });
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.CustomMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      metadata: {
        'content': message.text,
      },
      status: types.Status.sending,
    );

    _addMessage(textMessage);

    solevatoClient!.sendMessage(
      content: textMessage.metadata?['content'] ?? '',
      echoId: textMessage.id,
    );
    widget.onSendPressed?.call(message);
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isPresentedInDialog ? 8.0 : 16.0;
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.theme.backgroundColor,
      body: Column(
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: Chat(
                messages: _messages,
                buildCustomMessage: (message) {
                  print('@@@@ ${message.author.toJson()}');
                  return CustomTextMessage(
                    isMe: widget.user?.identifier == message.author.id,
                    showUsersName: widget.showUserNames,
                    author: message.author,
                    message: message.metadata?['content'] ?? '',
                    theme: widget.theme,
                  );
                },
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onSendPressed: _handleSendPressed,
                user: _user,
                onEndReached: widget.onEndReached,
                onEndReachedThreshold: widget.onEndReachedThreshold,
                onMessageLongPress: widget.onMessageLongPress,
                onTextChanged: widget.onTextChanged,
                showUserAvatars: widget.showUserAvatars,
                showUserNames: widget.showUserNames,
                timeFormat: widget.timeFormat ?? DateFormat.Hm(),
                dateFormat: widget.timeFormat ?? DateFormat("EEEE MMMM d"),
                theme: widget.theme,
                l10n: widget.l10n,
              ),
            ),
          ),
          if ((_disableBranding ?? true) == false) ...[
            InkWell(
              onTap: () async {
                String? url =
                    'https://solevato.com/?utm_source=widget_branding&utm_referrer=${PackageInfoHandler.instance.appName}';
                LauncherHandler.url(url: url);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo_grey.png",
                      package: 'solevato_client_sdk_flutter',
                      width: 15,
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Powered by Solevato",
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    solevatoClient?.dispose();
  }
}
