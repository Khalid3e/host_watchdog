// ignore_for_file: prefer_const_constructors

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;

void main() {
  setup();
  runApp(
    const MaterialApp(
      home: ExampleCupertinoDownloadButton(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

void setup() async {
  prefs = await SharedPreferences.getInstance();
  if (!prefs!.containsKey("decimal")){
    await prefs!.setDouble('decimal', 0.0);
  }
}

@immutable
class ExampleCupertinoDownloadButton extends StatefulWidget {
  const ExampleCupertinoDownloadButton({super.key});

  @override
  State<ExampleCupertinoDownloadButton> createState() =>
      _ExampleCupertinoDownloadButtonState();
}

class _ExampleCupertinoDownloadButtonState extends State<ExampleCupertinoDownloadButton> {

  late final List<DownloadController> _pingControllers;
  final _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pingControllers = List<DownloadController>.generate(
      0,
      (index) => SimulatedPingController(onOpenDownload: () {
        _openDownload(index);
      }),
    );
  }

  void _openDownload(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open App ${index + 1}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text( _pingControllers.isNotEmpty ? 'Pinging Tool (${_pingControllers.length})':'Pinging Tool',
            style: TextStyle(
                color: Colors.white
            )
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 24),
          onPressed: () async {
            print("Settings");
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 24),
            onPressed: () async {
              var resultLabel = await _showMyDialog(context);
              if (resultLabel != null) {
                setState(() {
                  _pingControllers
                      .add(SimulatedPingController(ip: resultLabel));
                });
              }
            },
          )
        ],
      ),
      body: ListView.separated(
        itemCount: _pingControllers.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: _buildListItem,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final downloadController = _pingControllers[index];

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.all(3),
      visualDensity: VisualDensity(vertical: 3), // to expand
      leading: AnimatedBuilder(
          animation: downloadController,
          builder: (context, child)  {
          return DemoAppIcon(status: downloadController.pingStatus);
        }
      ),
      title: Container(
        child: Text(
          downloadController.ip,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge,
        ),
      ),
      subtitle: AnimatedBuilder(
      animation: downloadController,
      builder: (context, child) {
      return Text(
        "Hostname: ${
                downloadController.hostname.isNotEmpty
                    ? downloadController.hostname
                    : downloadController.ip
              }",
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      );
              }
            ),
      trailing: SizedBox(
        width: 250,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: AnimatedBuilder(
                  animation: downloadController,
                  builder: (context, child) {
                    return HostStateShapeWidget(status: downloadController.pingStatus, successfulPingCount: downloadController.successfulPingCount ,failedPingCount:  downloadController.failedPingCount);
                  }
              ),
            ),
            Flexible(
              child: AnimatedBuilder(
                animation: downloadController,
                builder: (context, child) {
                  return DownloadButton(
                    status: downloadController.pingStatus,
                    downloadProgress: downloadController.progress,
                    onDownload: downloadController.startPing,
                    onCancel: downloadController.stopPing,
                    onOpen: downloadController.openDownload,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
                SizedBox(
                  width: 400,
                  child: TextField(
                      controller: _textFieldController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.computer, size: 16),
                        suffixIcon: IconButton(
                            onPressed: () {
                              _textFieldController.clear();
                            },
                            icon: Icon(Icons.clear, size: 16)),
                        labelText: 'IP Address',
                        helperText: 'Examples: 192.168.1.100 or 8.8.8.8',
                        border: OutlineInputBorder(),
                      )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
                _textFieldController.clear();

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
                _textFieldController.clear();

                print("_showMyDialog - OK");
              },
            ),
          ],
        );
      },
    );
  }
}

@immutable
class DemoAppIcon extends StatelessWidget {
  const DemoAppIcon({super.key,
    required this.status
  });

  final HostStatus status;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        child: SizedBox(
          width: 80,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: status == HostStatus.up ? CupertinoColors.activeGreen : status == HostStatus.down ? CupertinoColors.destructiveRed : CupertinoColors.lightBackgroundGray,

              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
              child: Icon(
                Icons.computer_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum HostStatus {
  idle,
  fetchingDownload,
  up,
  down,
  downloaded,
}

abstract class DownloadController implements ChangeNotifier {
  HostStatus get pingStatus;

  double get progress;

  String get ip;

  String get hostname;

  set hostname(String h){}

  int get successfulPingCount;

  int get failedPingCount;


  void startPing();

  void stopPing();

  void openDownload();
}

class SimulatedPingController extends DownloadController
    with ChangeNotifier {
  SimulatedPingController({
    HostStatus downloadStatus = HostStatus.idle,
    double progress = 0.0,
    String ip = '',
    String hostname = '',
    int successfulPingCount =0,
    int failedPingCount =0,
    VoidCallback? onOpenDownload,
  })  : _hostStatus = downloadStatus,
        _progress = progress,
        _successfulPingCount = successfulPingCount,
        _failedPingCount = failedPingCount,
        _ip = ip,
        _hostname = hostname,
        _onOpenDownload = onOpenDownload;

  HostStatus _hostStatus;

  @override
  HostStatus get pingStatus => _hostStatus;



  double _progress;
  final String _ip;
  String _hostname;
  int _successfulPingCount;
  int _failedPingCount;
  @override
  double get progress => _progress;


  final VoidCallback? _onOpenDownload;

  bool _isPinging = false;

  @override
  void startPing() {
    print('object : $pingStatus');
    if (pingStatus == HostStatus.idle) {
      _doPing();
    }
  }

  @override
  void stopPing() {
    if (_isPinging) {
      _isPinging = false;
      _hostStatus = HostStatus.idle;
      _progress = 0.0;
      notifyListeners();
    }
  }

  @override
  void openDownload() {
    if (pingStatus == HostStatus.downloaded) {
      _onOpenDownload!();
    }
  }



  Future<void> _doPing() async {
    _isPinging = true;
    _hostStatus = HostStatus.fetchingDownload;
    notifyListeners();


    // If the user chose to cancel the download, stop the simulation.
    if (!_isPinging) {
      return;
    }

    // Shift to the downloading phase.
    _hostStatus = HostStatus.up;
    notifyListeners();
    final double? decimal = prefs!.getDouble('decimal');
    if (decimal! > 0.0) {
      for (var i = 1; i <= decimal.toInt(); i++) {
        print("$i/${decimal.toInt()} pings");
        // Wait a second to simulate varying download speeds.
        final Ping ping = Ping(_ip, count: 1);
        ping.stream.listen((PingData event) {
          if (event.response != null) {
            try {
              event.response!.ip!.isNotEmpty ? _hostStatus = HostStatus.up : _hostStatus = HostStatus.down;
            }catch (error) {
              _hostStatus = HostStatus.down;
            }
            print("_hostStatus  $_hostStatus");
          }
          notifyListeners();
        });
        ping.stop();
        await Future<void>.delayed(const Duration(seconds: 1));

        // If the user chose to cancel the download, stop the simulation.
        if (!_isPinging) {
          return;
        }
        double p = i.toDouble() / decimal;
        // Update the download progress.
        _progress = p;
        notifyListeners();
      }
    }
    else {
      _successfulPingCount =0;
      _failedPingCount = 0;
      {
        print("endless");
        // Wait a second to simulate varying download speeds.
        final Ping ping = Ping(_ip);
        double p = 0.01;
        // Update the download progress.
        _progress = p;
        ping.stream.listen((PingData event) {
          if (!_isPinging) {
            ping.stop();
          }else{
            if (event.response != null) {
              try {
                if (event.response!.ip!.isNotEmpty) {
                  _hostStatus = HostStatus.up;
                  hostname = 'test';
                  _successfulPingCount++;
                } else {
                  _hostStatus = HostStatus.down;
                  _failedPingCount++;
                }
              }catch (error) {
                _hostStatus = HostStatus.down;
                _failedPingCount++;
              }
              print("_hostStatus  $_hostStatus");
            }
          }
          notifyListeners();
        });
        notifyListeners();
      }
    }

  }

  @override
  String get ip => _ip;



  @override
  String get hostname => _hostname;



  @override
  int get failedPingCount => _failedPingCount;

  @override
  int get successfulPingCount => _successfulPingCount;
}

@immutable
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.status,
    this.downloadProgress = 0.0,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
    this.isUP = false,
    this.transitionDuration = const Duration(milliseconds: 500),
  });

  final HostStatus status;
  final bool isUP;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final Duration transitionDuration;

  bool get _isPinging => status == HostStatus.up || status == HostStatus.down;

  bool get _isFetching => status == HostStatus.fetchingDownload;

  bool get _isUP => isUP;

  bool get _isDownloaded => status == HostStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case HostStatus.fetchingDownload:
        // do nothing.
        break;
      case HostStatus.up || HostStatus.down:
        onCancel();
      case HostStatus.downloaded:
        onOpen();
      case HostStatus.idle:
        onDownload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: ButtonShapeWidget(
        transitionDuration: transitionDuration,
        isDownloaded: _isDownloaded,
        isPinging: _isPinging,
        isFetching: _isFetching,
          hostStatus : status
      ),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.isPinging,
    required this.isDownloaded,
    required this.isFetching,
    required this.transitionDuration,
    required this.hostStatus,
  });

  final bool isPinging;
  final bool isDownloaded;
  final bool isFetching;
  final Duration transitionDuration;
  final HostStatus hostStatus;

  @override
  Widget build(BuildContext context) {


    /*if (isPinging || isFetching) {
      shape = ShapeDecoration(
        shape: const CircleBorder(),
        color: CupertinoColors.lightBackgroundGray,
      );
    }*/
    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.ease,
      width: double.infinity,
      decoration:  ShapeDecoration(
        shape: StadiumBorder(),
        color: !isPinging ? CupertinoColors.lightBackgroundGray : Colors.blueGrey,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedContainer(
          duration: transitionDuration,
          curve: Curves.ease,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child:  Icon(
                  isPinging ? Icons.stop_rounded: Icons.play_arrow_rounded ,
                  color: isPinging ? CupertinoColors.lightBackgroundGray : Colors.blueGrey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text( isPinging ? 'Stop':'Start',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      color: isPinging ? CupertinoColors.lightBackgroundGray : Colors.blueGrey,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}


/**/
@immutable
class HostStateShapeWidget extends StatelessWidget {

  const HostStateShapeWidget({
    super.key,
    required this.status,
    required this.successfulPingCount,
    required this.failedPingCount
  });

  final HostStatus status;
  final int successfulPingCount;
  final int failedPingCount;

  @override
  Widget build(BuildContext context) {

    print('HostStateShapeWidget $status');


    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          padding: EdgeInsets.only(left: 10, right:10),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.activeGreen),
            borderRadius: BorderRadius.all(Radius.circular(200)),
          ),
          child: Center(
            child: Text(
              "$successfulPingCount",
                style: const TextStyle(
                    color: CupertinoColors.activeGreen,
                    fontSize: 10)
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          padding: EdgeInsets.only(left: 10, right:10),
          decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.destructiveRed),
              borderRadius: BorderRadius.all(Radius.circular(200)),
            ),
          child: Text(
              "$failedPingCount",
              style: const TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontSize: 10)
          ),
        ),
      ],
    );
  }
}


@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isPinging,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isPinging;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: isPinging ? Colors.amber : Colors.lightBlueAccent,

      child: AspectRatio(
        aspectRatio: 1,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: downloadProgress),
          duration: const Duration(milliseconds: 200),
          builder: (context, progress, child) {
            return CircularProgressIndicator(
              backgroundColor: isPinging
                  ? CupertinoColors.lightBackgroundGray
                  : Colors.white.withOpacity(0),
              valueColor: AlwaysStoppedAnimation(isFetching
                  ? CupertinoColors.lightBackgroundGray
                  : CupertinoColors.activeBlue),
              strokeWidth: 2,
              value: isFetching ? null : progress,
            );
          },
        ),
      ),
    );
  }
}

//Old code
/*
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
} */
/*

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
}*/ /*


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
*/
