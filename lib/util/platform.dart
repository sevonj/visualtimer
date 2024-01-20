import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum PlatformType { desktop, mobile, web }

class PlatformUtility {
  static PlatformType get type {
    if (kIsWeb) {
      return PlatformType.web;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return PlatformType.mobile;
    }

    return PlatformType.desktop;
  }
}
