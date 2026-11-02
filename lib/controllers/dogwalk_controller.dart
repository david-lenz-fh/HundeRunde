import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_flutter/models/gps_status.dart';
import '../models/dogwalks.dart';
import '../services/dogwalk_service.dart';



class DogWalkController extends ChangeNotifier {

  List<DogWalk> _lastWalks = [];
  Dog? _currentDog;

  GPSStatus gpsStatus = GPSStatus.idle;

  List<DogWalk> get lastWalks => _lastWalks;
  Dog? get currentDog => _currentDog;

  final DogWalkService _dogwalkService = DogWalkService();
  late final StreamSubscription _subscriptionWalk;
  late final StreamSubscription _subscriptionDog;
  
  DogWalkController(){
      print(_currentDog);
    _subscriptionWalk = _dogwalkService.walksStream.listen((walks) {
      _lastWalks = walks;
      notifyListeners();
    });
    _subscriptionDog = _dogwalkService.dogStream.listen((dogs) {
      _currentDog = dogs.firstOrNull;
      print(_currentDog);
      notifyListeners();
    });
    print(_currentDog);
    startUp();
  }
  void startUp() async{    
    await _dogwalkService.pushAllUnsychronized();
    await _dogwalkService.fetchAndSyncAllDogs();
    _dogwalkService.fetchAndSyncAllWalks();
  }

  void addNewDog(String dogName){
    _dogwalkService.addNewDog(dogName);
  }

  @override
  void dispose() {
    _subscriptionWalk.cancel();
    _subscriptionDog.cancel();
    super.dispose();
  }
}