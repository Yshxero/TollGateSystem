import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetService {
  static final InternetService _instance = InternetService._internal();
  factory InternetService() => _instance;
  InternetService._internal();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get internetStatus => _controller.stream;

  void initialize() {
    Connectivity().onConnectivityChanged.listen((_) async {
      bool hasInternet = await InternetConnectionChecker().hasConnection;
      _controller.add(hasInternet);
    });
  }

  Future<bool> hasInternet() async {
    return await InternetConnectionChecker().hasConnection;
  }
}
