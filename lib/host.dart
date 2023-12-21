import 'dart:ffi';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';


class  host{
  var myHost;
  hostWidget widget = hostWidget();

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

  void _ping() async {
    print("Pinging, Stop: $stopCall");
    pinging = true;
    final ping = Ping(ip, count :1);
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
    });
    await Future.delayed(Duration(milliseconds: 500));
    if (!stopCall) _ping();
    else pinging = false;
  }
}

class hostWidget extends StatefulWidget {
  @override
  _MyHost createState() {
    // TODO: implement createState
    throw _MyHost(null);
  }
}

class _MyHost extends State<hostWidget> {
  Color color = Colors.grey;
  String ip = "", hostname = "";
  int state = -1, aliveCounter = 0, deadCounter = 0;
  host? h;
  _MyHost(host? h){
    this.h = h;
    ip = h!.ip;
    hostname = h.hostname;
    state = h.hostState;
  }

  @override
  Widget build(BuildContext context) {
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
                icon: Icon(state == 1 ? Icons.stop : Icons.play_arrow, color: const Color(0xff212435), size: 16),
                onPressed: (){
                  print("Button, state: $state");
                  if (!h!.pinging) {
                    h?.stopCall = false;
                    h?._ping();
                  } else {
                    h?.stopCall = true;
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                    child:  Text("$aliveCounter",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                            fontWeight: FontWeight.w700
                        )),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child:  Text("$deadCounter",
                        style: const TextStyle(
                          color: Colors.white,
                            fontSize: 9,
                          fontWeight: FontWeight.w700
                        )),
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
