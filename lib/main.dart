import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:host_watchdog/host.dart';
import 'package:host_watchdog/hosts.dart';

hostViews hostList = hostViews();
final _textFieldController = TextEditingController(

);

void main() {
  runApp(const MyApp());
  //_ping();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    print("Building ${hostList.views.length}");
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        leading:  IconButton(
              icon: const Icon(Icons.settings,
                  color: Color(0xff212435), size: 24),
              onPressed: () async {
                print("Settings");
              },
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xff212435), size: 24),
            onPressed: () async {
              var resultLabel = await _showMyDialog(context);
              if (resultLabel != null) {
                setState(() {
                  hostList.addHost(host(resultLabel));
                });
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                  "Host List",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    color: Color(0xff272727),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: hostList.views.length,
                  itemBuilder: (BuildContext context, int index) {
                    return hostList.views[index].myHost.build(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<String?> _showMyDialog(BuildContext bc) async {
  print("_showMyDialog - Start");
  //TextEditingController dialogController = TextEditingController();
  return showDialog<String>(
    context: bc,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('AlertDialog Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                  controller: _textFieldController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.clear),
                    labelText: 'IP Address',
                    helperText: 'Examples: 192.168.1.100 or 8.8.8.8',
                    border: OutlineInputBorder(),
                  )),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);

              print("_showMyDialog - Cancel");
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              //ip = _textFieldController.text.toString();
              if (_textFieldController.text.toString().isNotEmpty) {
                Navigator.pop(context, _textFieldController.text);
              }

              print("_showMyDialog - OK");
            },
          ),
        ],
      );
    },
  );
} /*

Future<String?> _showMyDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('TODO'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "タスクの名称を入力してください。"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, _textFieldController.text),
            ),
          ],
        );
      });
}*/

void _ping() async {
  // Create ping object with desired args
  if (hostList.views.isNotEmpty) {
    PingResponse? res;
    // for (host h in hostList) {
    //   final ping = Ping(h.ip, count: 5);
    //   ping.stream.listen((PingData event) {
    //     if (event.response != null) {
    //       h.state = 1;
    //     } else {
    //       h.state = 0;
    //     }
    //   });
    // }
  }
}
