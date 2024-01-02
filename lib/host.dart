import 'dart:isolate';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

class host {
  var myHost;

  String ip = "0.0.0.0";

  //-1 idle, 0 dead, 1 alive
  int hostState = -1;
  var previousState, changed;
  String hostname = "hostname";

  bool pinging = false;
  bool stopCall = false;

  host(String ip) {
    this.ip = ip;
    myHost = _MyHost(this);
  }
}

void _ping(SendPort send2main) {
  print('_ping 0');
  final rcvPort = ReceivePort(); // ReceivePort for the spawned isolate.
  print('_ping 1');
  send2main.send(rcvPort.sendPort); // Send the SendPort to the main isolate.
  print('_ping 2');

  rcvPort.listen((message) {
    print("message is type: ${message.runtimeType}");
    if (message is host) {
      print("message stopCall: ${message.stopCall}");
      while (!message.stopCall) {
        //pinging = true;

        final ping = Ping(message.ip, count: 1);
        ping.stream.listen((PingData event) {
          message.hostState = event.response != null ? 1 : 0;
          print('send2main.send(${message.hostState});');
          send2main.send(message.hostState);
          /*if (previousState != hostState) {
            myHost.setState(() {
              myHost.hostState = hostState;

              if (hostState == 1)
                myHost.color = Colors.green;
              else if (hostState == 0)
                myHost.color = Colors.red;
              else
                myHost.color = Colors.grey;
              myHost.ip = ip;
              myHost.hostname = hostname;
            });
          }
          previousState = hostState;
          */
        });
      }
    }
  });
/*    pinging = false;

    print("Pinging, Stop: $stopCall");
    pinging = true;

    final ping = Ping(ip, count: 1);
    ping.stream.listen((PingData event) {
      if (event.response != null) {
        hostState = 1;
      } else {
        hostState = 0;
      }
      if (previousState != hostState) {
        myHost.setState(() {
          myHost.hostState = hostState;

          if (hostState == 1)
            myHost.color = Colors.green;
          else if (hostState == 0)
            myHost.color = Colors.red;
          else
            myHost.color = Colors.grey;
          myHost.ip = ip;
          myHost.hostname = hostname;
        });
      }
      previousState = hostState;
    });*/
}

class hostWidget extends StatefulWidget {
  @override
  _MyHost createState() {
    // TODO: implement createState
    throw _MyHost(null);
  }
}

class _MyHost extends State<hostWidget> {
  int hostState = -1;
  var previousState;
  var ping;
  Color color = Colors.grey;
  String ip = "", hostname = "";
  int state = -1, aliveCounter = 0, deadCounter = 0;
  host? h;
  bool pinging = false;
  final rcvPort = ReceivePort(); // ReceivePort for the main isolate.
  var isolate;

  _MyHost(host? h) {
    this.h = h;
    ip = h!.ip;
    hostname = h.hostname;
    state = h.hostState;
  }

  @override
  Widget build(BuildContext context) {
    print("building...");
    return hostCard();
  }

  Card hostCard(){
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      color: const Color(0xffffffff),
      shadowColor: const Color(0x4d939393),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: const BorderSide(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(h!.pinging ? Icons.stop : Icons.play_arrow,
                    color: const Color(0xff212435), size: 16),
                onPressed: () {

                  if (h!.pinging == false) {

                      ping = Ping(h!.ip, count: 10);
                      ping.stream.listen((PingData event) {
                        print(event.response);
                        h!.pinging = true;
                      });
                    pinging = true;


                  } else {
                    if (ping != null && ping is Ping) {
                      ping.stop();
                      h!.pinging = false;
                      pinging = false;
                    }
                  }


                  /*if (state != 1) {

                    final completer = Completer<SendPort>(); // For awaiting the SendPort.

                    isolate = await Isolate.spawn<SendPort>(
                      _ping,
                      rcvPort.sendPort,
                      errorsAreFatal: true,
                      debugName: 'MyIsolate',
                    );

                    rcvPort.listen((message) {
                      print("message.runtimeType : ${message.runtimeType}");
                      if (message is SendPort) completer.complete(message);
                      */ /*if (message is bool) {
                      if (message) {
                        h?.stopCall = false;
                      } else {
                        h?.stopCall = true;
                      }
                    }*/ /*
                      if (message is int) {
                        if (previousState != state) {
                          setState(() {
                            if (state == 1)
                              color = Colors.green;
                            else if (state == 0)
                              color = Colors.red;
                            else
                              color = Colors.grey;
                          });
                        }
                        previousState = state;
                      }
                    });
                    final send2Isolate = await completer.future; // Get the SendPort.


                    send2Isolate.send( h!.ip);

                  } else {
                    rcvPort.close(); // Close the ReceivePort.
                    isolate.kill();
                  }*/
                  /*final send2Isolate =
                      await completer.future; // Get the SendPort.
                  if (message) {
                    send2Isolate
                        .send(true); // Send a message to the spawned isolate.
                    await Future<void>.delayed(const Duration(seconds: 1));
                    print('Continue');
                  }*/
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      ip,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: Color(0xff000000),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      child: Text(
                        hostname,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff6c6c6c),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  /*Row(

                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 24,
                      ),
                      Padding(padding: EdgeInsets.all(5), child: Text("13"),)
                    ],
                  ),*/
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Text("$aliveCounter",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text("$deadCounter",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void stop() {
    print("Stop");
  }

  void start() {
    print("Start");
  }
}
