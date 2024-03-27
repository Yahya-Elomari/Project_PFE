import 'package:flutter/material.dart';

class TicketRefreshNotifier extends ChangeNotifier {
  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void triggerRefresh() {
    _shouldRefresh = true;
    notifyListeners();
  }

  void refreshCompleted() {
    _shouldRefresh = false;
    notifyListeners();
  }
}
