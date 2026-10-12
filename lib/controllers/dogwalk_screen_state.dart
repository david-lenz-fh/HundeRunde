import 'package:flutter/material.dart';

class DogWalkController extends ChangeNotifier {
  bool _isWalking = false;

  bool get isWalking => _isWalking;

  String get durationText => _isWalking ? '12:45 min' : '00:00 min';
  String get distanceText => _isWalking ? '850 m' : '0 m';

  void toggleWalk() {
    _isWalking = !_isWalking;
    notifyListeners();
  }
}