import 'package:solevato_client_sdk_flutter/data/solevato_repository.dart';
import 'package:solevato_client_sdk_flutter/data/local/entity/solevato_message.dart';
import 'package:solevato_client_sdk_flutter/data/remote/solevato_client_exception.dart';
import 'package:solevato_client_sdk_flutter/data/remote/responses/solevato_event.dart';

///solevato callback are specified for each created client instance. Methods are triggered
///when a method satisfying their respective conditions occur.
///
///
/// {@category FlutterClientSdk}
class SolevatoCallbacks {
  ///Triggered when a welcome event/message is received after connecting to
  ///the solevatp websocket. See [SolevatoRepository.listenForEvents]
  void Function()? onWelcome;

  ///Triggered when a ping event/message is received after connecting to
  ///the solevato websocket. See [SolevatoRepository.listenForEvents]
  void Function()? onPing;

  ///Triggered when a subscription confirmation event/message is received after connecting to
  ///the solevato websocket. See [SolevatoRepository.listenForEvents]
  void Function()? onConfirmedSubscription;

  ///Triggered when a conversation typing on event/message [SolevatoEventMessageType.conversation_typing_on]
  ///is received after connecting to the solevato websocket. See [SolevatoRepository.listenForEvents]
  void Function()? onConversationStartedTyping;

  ///Triggered when a presence update event/message [SolevatoEventMessageType.presence_update]
  ///is received after connecting to the solevato websocket and conversation is online. See [SolevatoRepository.listenForEvents]
  void Function()? onConversationIsOnline;

  ///Triggered when a presence update event/message [SolevatoEventMessageType.presence_update]
  ///is received after connecting to the solevato websocket and conversation is offline.
  ///See [SolevatoRepository.listenForEvents]
  void Function()? onConversationIsOffline;

  ///Triggered when a conversation typing off event/message [SolevatoEventMessageType.conversation_typing_off]
  ///is received after connecting to the solevato websocket. See [SolevatoRepository.listenForEvents]
  void Function()? onConversationStoppedTyping;

  ///Triggered when a message created event/message [SolevatoEventMessageType.message_created]
  ///is received and message doesn't belong to current user after connecting to the solevato websocket.
  ///See [SolevatoRepository.listenForEvents]
  void Function(SolevatoMessage)? onMessageReceived;

  ///Triggered when a message created event/message [SolevatoEventMessageType.message_updated]
  ///is received after connecting to the solevato websocket.
  ///See [SolevatoRepository.listenForEvents]
  void Function(SolevatoMessage)? onMessageUpdated;

  void Function(SolevatoMessage, String)? onMessageSent;

  ///Triggered when a message created event/message [SolevatoEventMessageType.message_created]
  ///is received and message belongs to current user after connecting to the solevato websocket.
  ///See [SolevatoRepository.listenForEvents]
  void Function(SolevatoMessage, String)? onMessageDelivered;

  ///Triggered when a conversation's messages persisted on device are successfully retrieved
  void Function(List<SolevatoMessage>)? onPersistedMessagesRetrieved;

  ///Triggered when a conversation's messages is successfully retrieved from remote server
  void Function(List<SolevatoMessage>)? onMessagesRetrieved;

  ///Triggered when an agent resolves the current conversation
  void Function()? onConversationResolved;

  /// Triggered when any error occurs in solevato client's operations with the error
  ///
  /// See [SolevatoClientExceptionType] for the various types of exceptions that can be triggered
  void Function(SolevatoClientException)? onError;

  SolevatoCallbacks({
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
    this.onConversationResolved,
    this.onError,
  });
}
