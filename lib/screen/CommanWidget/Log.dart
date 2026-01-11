import 'package:logger/logger.dart';

class Log {
  static void d({required String msg}){
   Logger().d(msg);
  }
}