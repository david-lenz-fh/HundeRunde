import 'dart:async';

import 'package:uuid/uuid.dart';

import '../data/HundeRundeDB.dart';

import '../models/dogwalks.dart';

class DogWalkService {

  final List<DogWalk> _walks = [
    DogWalk(id:"a", dogId: "h", startedAt: DateTime(2026, 10, 10 ,10, 20),endedAt: DateTime(2026, 10, 10 ,11, 20), distanceInM: 3124, comment: null, routePolyline: null),
    DogWalk(id:"b", dogId: "h", startedAt: DateTime(2026, 10, 10 ,10, 20),endedAt: DateTime(2026, 10, 10 ,11, 20), distanceInM: 3124, comment: null, routePolyline: null),
    DogWalk(id:"c", dogId: "h", startedAt: DateTime(2026, 10, 10 ,10, 20),endedAt: DateTime(2026, 10, 10 ,11, 20), distanceInM: 3124, comment: null, routePolyline: null),
    DogWalk(id:"d", dogId: "h", startedAt: DateTime(2026, 10, 10 ,10, 20),endedAt: DateTime(2026, 10, 10 ,11, 20), distanceInM: 3124, comment: null, routePolyline: null),
    DogWalk(id:"e", dogId: "h", startedAt: DateTime(2026, 10, 10 ,10, 20),endedAt: DateTime(2026, 10, 10 ,11, 20), distanceInM: 3124, comment: null, routePolyline: null),
    
  ];
  
  final HundeRundeDB _database = HundeRundeDB.instance;
  final Uuid _uuid = const Uuid();

  Future<String> startWalk(String dogId) async {
    final db = await _database.database;

    final walkId = _uuid.v4();

    await db.insert('Walks', {
      'id': walkId,
      'dog_id': dogId,
      'started_at': DateTime.now().toUtc().toIso8601String(),
      'sync_status': 0,
    });

    postWalk(walkId);

    return walkId;
  }

  Future<void> finishWalk(String walkId) async {
    final db = await _database.database;

    await db.update(
      'Walks',
      {
        'ended_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [walkId],
    );
  }

  Future<void> updateRoute(
    String walkId,
    String route,
  ) async {
    final db = await _database.database;

    await db.update(
      'Walks',
      {
        'route': route,
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [walkId],
    );
  }

  Future<void> updateComment(String walkId, String comment) async {
    final db = await _database.database;

    await db.update(
      'Walks',
      {
        'comment': comment,
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [walkId],
    );
  }

  Future<void> syncWalk (String walkId) async{
    final db = await _database.database;
    
    await db.update('Walks',
    {
      'sync_status': 1
    },
    where: 'id = ?',
    whereArgs: [walkId]);
  }

  Future<List<DogWalk>> getWalks(
    String dogId,
  ) async {
    final db = await _database.database;

    final results = await db.query(
      'Walks',
      where: 'dog_id = ?',
      whereArgs: [dogId],
      orderBy: 'started_at DESC',
    );
    return convertDogWalksFromDb(results);
  }

  Future<DogWalk?> getWalk(String walkId) async {
    final db = await _database.database;

    final results = await db.query(
      'Walks',
      where: 'id = ?',
      whereArgs: [walkId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    return convertDogWalkFromDb(results.first);
  }

  Future<void> deleteWalk(String walkId) async {
    final db = await _database.database;

    await db.delete(
      'Walks',
      where: 'id = ?',
      whereArgs: [walkId],
    );
  }


  Future<List<DogWalk>> fetchLastWalks() async {
    await Future.delayed(const Duration(seconds: 1)); 
    
    final sortedList = List<DogWalk>.from(_walks);
    final now = DateTime.now();
    sortedList.sort((a, b) => (b.endedAt??now).compareTo(a.endedAt??now));

    return sortedList.take(4).toList();
  }

  void postWalk(String walkId) async{
    var localWalk = await getWalk(walkId);
    if(localWalk==null)return;

    final apiSuccess = false;
    if(!apiSuccess)return;

  }

  
  DogWalk? convertDogWalkFromDb(Map<String, dynamic> dbEntry) {
    try {
      return DogWalk(
        id: dbEntry['id'] as String, 
        dogId: dbEntry['dog_id'] as String, 

        startedAt: DateTime.parse(dbEntry['started_at'] as String), 
        
        endedAt: dbEntry['ended_at'] != null 
            ? DateTime.parse(dbEntry['ended_at'] as String) 
            : null, 
            
        distanceInM: (dbEntry['distance_in_m'] as num?)?.toDouble() ?? 0.0, 
        routePolyline: dbEntry['polyline'] as String?,
        comment: dbEntry['comment'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  List<DogWalk> convertDogWalksFromDb(List<Map<String, Object?>?> dbEntries){
    List<DogWalk> re=List.empty();
    for(var entry in dbEntries){
      if(entry==null)continue;

      final parsed = convertDogWalkFromDb(entry);
      if(parsed==null)continue;

      re.add(parsed);
    }
    return re;
  }
}