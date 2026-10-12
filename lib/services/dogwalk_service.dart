import 'package:starter_flutter/models/dogwalks.dart';

class DogWalkService {

  final List<DogWalk> _walks = [

    DogWalk(1, 1, DateTime(2026, 10, 10 ,10, 20), DateTime(2026, 10, 10 ,11, 20), 4000, "", ""),
    DogWalk(2, 1, DateTime(2026, 10, 4 ,10, 20), DateTime(2026, 10, 4 ,11, 20), 4000, "", ""),
    DogWalk(3, 1, DateTime(2026, 10, 4 ,18, 20), DateTime(2026, 10, 4 ,19, 20), 4000, "", ""),
    DogWalk(4, 1, DateTime(2026, 10, 9 ,10, 20), DateTime(2026, 10, 9 ,11, 20), 4000, "", ""),
    DogWalk(5, 1, DateTime(2026, 10, 8 ,10, 20), DateTime(2026, 10, 8 ,11, 20), 4000, "", ""),
    DogWalk(6, 1, DateTime(2026, 10, 7 ,10, 20), DateTime(2026, 10, 7 ,11, 20), 4000, "", ""),
    DogWalk(7, 1, DateTime(2026, 10, 6, 10, 20), DateTime(2026, 10, 6 ,11, 20), 4000, "", "")
  ];

  Future<List<DogWalk>> fetchLastWalks() async {
    await Future.delayed(const Duration(seconds: 1)); 
    
    final sortedList = List<DogWalk>.from(_walks);
    sortedList.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return sortedList.take(4).toList();
  }
}