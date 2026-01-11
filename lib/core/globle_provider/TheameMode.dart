import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

final themeBrightnessProvider =
StateProvider<Brightness>((ref) {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
});

final isDarkThemeProvider  =
Provider<bool>((ref){
  return ref.watch(themeBrightnessProvider) == Brightness.dark;
});


bool get isDarkTheme => globalContainer.read(isDarkThemeProvider);