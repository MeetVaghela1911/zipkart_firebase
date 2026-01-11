import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/service/api_service/ApiServices.dart';
import 'firebase_options.dart';

late ProviderContainer globalContainer;
void main() async {
  globalContainer = ProviderContainer();
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( UncontrolledProviderScope(
      container: globalContainer,
      child: const ProviderScope(child: App()))
  );
}
