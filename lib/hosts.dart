import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:host_watchdog/host.dart';

class hostViews {
  List<host> views = [];

  hostViews();

  void addHost(host h) {
    views.add(h);
    print("Add: ${h.ip} x ${views.length}");
  }

  void z() {
    print("Stop");
  }
}
