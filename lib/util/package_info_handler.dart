import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoHandler {
  static final PackageInfoHandler instance = PackageInfoHandler._instance();
  String? appName;

  PackageInfoHandler._instance();

  static String? getOperatingSystem() {
    return Platform.operatingSystem;
  }

  Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
  }
}
