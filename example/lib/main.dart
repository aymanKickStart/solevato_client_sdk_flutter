import 'package:solevato_client_sdk_flutter/solevato_client_sdk_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
 const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  _showSolevatoDialog() {
    SolevatoChatDialog.show(
      context,
      inboxIdentifier: "xxxxxxxxxxxxxxxxxxx",
      title: "Solevato Support",
      user: SolevatoUser(
        identifier: "test@test.com",
        name: "Tester test",
        email: "test@test.com",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolevatoChat(
      inboxIdentifier: "xxxxxxxxxxxxxxxxxxx",
      user: SolevatoUser(
        identifier: "test1@test.com",
        name: "Tester test1",
        email: "test1@test.com",
      ),
      appBar: AppBar(
        title: Text(
          "Solevato",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: InkWell(
          onTap: () => _showSolevatoDialog(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/solevato_logo.png"),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      onWelcome: () {
        debugPrint("Welcome event received");
      },
      onPing: () {
        print("Ping event received");
      },
      onConfirmedSubscription: () {
        print("Confirmation event received");
      },
      onMessageDelivered: (_) {
        print("Message delivered event received");
      },
      onMessageSent: (_) {
        print("Message sent event received");
      },
      onConversationIsOffline: () {
        print("Conversation is offline event received");
      },
      onConversationIsOnline: () {
        print("Conversation is online event received");
      },
      onConversationStoppedTyping: () {
        print("Conversation stopped typing event received");
      },
      onConversationStartedTyping: () {
        print("Conversation started typing event received");
      },
    );
  }
}
