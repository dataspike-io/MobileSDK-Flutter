import 'dart:async';
import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  final _loadingController = StreamController<bool>.broadcast();
  Stream<bool> get loadingStream => _loadingController.stream;

  void showLoading(bool show) {
    _loadingController.add(show);
    notifyListeners();
  }

  @override
  void dispose() {
    _loadingController.close();
    super.dispose();
  }
}