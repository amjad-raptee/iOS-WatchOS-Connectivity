import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data = "";
  static const watchChannel = MethodChannel("watchPlatform");

  final _eventChannel = const EventChannel("watchconnectivity");

  //In Build phase i Moved build watch cantent up

  StreamSubscription? subscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        data = event;
      });

      print("Flutter: Event receivied: $event");
    }, onError: (Object obj, StackTrace stackTrace) {
      print("Flutter Event Received Error: $obj");
      print("Flutter Event Received Error: $stackTrace");
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'WatchOS: $data',
            ),
            TextButton(
                onPressed: () async {
                  try {
                    final result = await watchChannel.invokeListMethod(
                        "sendToWatch", {"data": "Hi Watch, iPhone here"});
                    debugPrint("$result");
                  } on PlatformException catch (e) {
                    debugPrint(" Fail: ${e.message}");
                  }
                },
                child: const Text("Send data to watch")),
          ],
        ),
      ),
    );
  }
}
