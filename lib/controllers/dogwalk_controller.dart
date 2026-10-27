import 'package:flutter/material.dart';
import 'package:starter_flutter/models/gps_status.dart';
import '../models/dogwalks.dart';
import '../services/dogwalk_service.dart';



class DogWalkController extends ChangeNotifier {

  List<DogWalk> _lastWalks = [];
  bool _isLoading = false;
  String? _errorMessage;

  GPSStatus gpsStatus = GPSStatus.idle;

  List<DogWalk> get lastWalks => _lastWalks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final DogWalkService _dogwalkService = DogWalkService();

  DogWalkController() {
    loadWalks();
    
  }

  Future<void> loadWalks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 

    try {
      _lastWalks = await Future.value(_dogwalkService.fetchLastWalks());
      
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Spaziergänge.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWalk(DogWalk newWalk) async {
    _lastWalks.insert(0, newWalk);
    notifyListeners(); 
  }
}