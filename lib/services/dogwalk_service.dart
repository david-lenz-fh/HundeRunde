import 'dart:async';

import 'package:path/path.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:sqflite/sqflite.dart';
import 'package:starter_flutter/services/pocketbase_service.dart';
import 'package:uuid/uuid.dart';

import '../data/HundeRundeDB.dart';

import '../models/dogwalks.dart';

class DogWalkService {
  
  final HundeRundeDB _database = HundeRundeDB.instance;
  final Uuid _uuid = const Uuid();

  final _streamControllerWalk = StreamController<List<DogWalk>>.broadcast();
  Stream<List<DogWalk>> get walksStream => _streamControllerWalk.stream;

  final _streamControllerDog = StreamController<List<Dog>>.broadcast();
  Stream<List<Dog>> get dogStream => _streamControllerDog.stream;

  DogWalkService(){
    initRealtimeSync();
  }
  Future<void> refreshAndEmitWalks() async {
      final walks = await getAllWalks();
      
      _streamControllerWalk.add(walks);

      final dogs = await getAllDogs();
      _streamControllerDog.add(dogs);
    }
  UnsubscribeFunc? _walksSubscription;
  UnsubscribeFunc? _dogSubscription;

  Future<void> initRealtimeSync() async {
    try {
      await stopRealtimeSync();

      _walksSubscription = await PocketBaseService.instance.client
          .collection('walks')
          .subscribe('*', (e) async {
            final record = e.record;
            if (record == null) return;
            final db = await _database.database;
            switch (e.action) {
              case 'create':              
              case 'update':
                DogWalk? fetchedWalk = PocketBaseService.instance.convertFetchedToDogWalk(record);            
                if(fetchedWalk==null)return;
                fetchedWalk.isSynced=true;
                await db.insert('Walks', convertDogWalkToLocalDb(fetchedWalk), conflictAlgorithm: ConflictAlgorithm.replace);                
                break;

              case 'delete':
                await deleteWalk(record.id);
                break;
            }            
            refreshAndEmitWalks();
          });
          _dogSubscription = await PocketBaseService.instance.client
          .collection('dogs')
          .subscribe('*', (e) async {
            final record = e.record;
            if (record == null) return;
            final db = await _database.database;
            switch (e.action) {
              case 'create':              
              case 'update':
                final userId=PocketBaseService.instance.client.authStore.record?.id;
                Dog? fetchedDog = PocketBaseService.instance.convertFetchedToDog(record);            
                if(fetchedDog==null||userId==null)return;
                fetchedDog.isSynced=true;
                await db.insert('Dogs', convertDogToLocalDb(fetchedDog), conflictAlgorithm: ConflictAlgorithm.replace);                
                await db.insert('DogUsers', {'dog_id':fetchedDog.id, 'user_id':userId},conflictAlgorithm: ConflictAlgorithm.replace);
                await fetchAndSyncAllWalks();
                break;
              case 'delete':
                deleteDogAndWalks(record.id);
            }
            
            refreshAndEmitWalks();
          });

    } catch (e){print('Fehler bei Realtime-Sync: $e');}

  }
  Future<void> stopRealtimeSync() async {
    if (_walksSubscription != null) {
      await _walksSubscription!();
      _walksSubscription = null;
    }
    if (_dogSubscription != null) {
      await _dogSubscription!();
      _dogSubscription = null;
    }
  }

  Future<void> fetchAndSyncAllWalks() async {
    
    final db = await _database.database;
    try {
      final fetchedWalks = await PocketBaseService.instance.fetchAllWalks();
      for(var fetchedWalk in fetchedWalks){

        final localWalk = await getWalk(fetchedWalk.id);
        if (localWalk != null && !localWalk.isSynced) {
          continue; 
        }
        fetchedWalk.isSynced=true;
        await db.insert('Walks', convertDogWalkToLocalDb(fetchedWalk), conflictAlgorithm: ConflictAlgorithm.replace); 
      }
      _syncDeletedWalks(fetchedWalks);
      refreshAndEmitWalks();
      print('Alle Spaziergänge erfolgreich synchronisiert.');
    } catch (e) {
      print('Konnte Daten nicht vom Server laden (vielleicht offline?): $e');
    }
  }
  Future<void> fetchAndSyncAllDogs() async {
    
    final db = await _database.database;
    try {
      final fetchedDogs = await PocketBaseService.instance.fetchAllDogs();
      for(var fetchedDog in fetchedDogs){

        final localDog = await getDog(fetchedDog.id);
        if (localDog != null && !localDog.isSynced) {
          continue; 
        }
        final userId=PocketBaseService.instance.client.authStore.record?.id;
        if(userId==null)return;
        await db.insert('Dogs', convertDogToLocalDb(fetchedDog), conflictAlgorithm: ConflictAlgorithm.replace); 
        await db.insert('DogUsers', {'dog_id':fetchedDog.id, 'user_id':userId},conflictAlgorithm: ConflictAlgorithm.replace);
      }
      _syncDeletedDogs(fetchedDogs);
      refreshAndEmitWalks();
      print('Alle Hunde erfolgreich synchronisiert.');
    } catch (e) {
      print('Konnte Daten nicht vom Server laden (vielleicht offline?): $e');
    }
  }
Future<void> _syncDeletedWalks(List<DogWalk> fetchedWalks) async{
  final db = await _database.database;
  final localWalks = await getAllWalks();
  final localWalkIds = localWalks.map((w) => w.id).toSet();
  final fetchedWalkIds = fetchedWalks.map((w) => w.id).toSet();
  final deletedIds = localWalkIds.difference(fetchedWalkIds);

  for (var toDeleteId in deletedIds){
    final localWalk = localWalks.firstWhere((w) => w.id == toDeleteId);
    if (!localWalk.isSynced) {
      print("synched skipeed");
      continue;
    }
    await db.delete(
      'Walks',
      where: 'id = ?',
      whereArgs: [toDeleteId],
    );
  }
}
Future<void> _syncDeletedDogs(List<Dog> fetchedDogs) async {
  
  final localDogs = await getAllDogs();
  final localDogIds = localDogs.map((d) => d.id).toSet();
  final fetchedDogIds = fetchedDogs.map((d) => d.id).toSet();
  final deletedIds = localDogIds.difference(fetchedDogIds);

  for (var toDeleteId in deletedIds) {
    final localDog = localDogs.firstWhere((d) => d.id == toDeleteId);
    if (!localDog.isSynced) {
      continue;
    }
    deleteDogAndWalks(toDeleteId);
  }
}
Future<void> deleteDogAndWalks(String toDeleteId) async{
  final db = await _database.database;
  await db.delete(
      'Walks',
      where: 'dog_id = ?',
      whereArgs: [toDeleteId],
    );
    await db.delete(
      'Dogs',
      where: 'id = ?',
      whereArgs: [toDeleteId],
    );
}
Future<void> addNewDog(String dogName) async{
  final db = await _database.database;
  
  final dogId = _uuid.v4();
  final dog = Dog(id: dogId, name: dogName);
  try{
    await db.insert('Dogs', convertDogToLocalDb(dog), conflictAlgorithm: ConflictAlgorithm.replace) == 0;
    refreshAndEmitWalks();
  }
  catch(e){
    return;
  }
  PocketBaseService.instance.postDog(dog);
}
Future<Dog?> joinDog(String dogId) async{
  final db = await _database.database;
  final joinedDog = await PocketBaseService.instance.addMemberToDog(dogId);
  if(joinedDog==null){
    return null;
  }
  await db.insert('Dogs', convertDogToLocalDb(joinedDog), conflictAlgorithm: ConflictAlgorithm.replace);
  return joinedDog;
}
Future<void> pushAllUnsychronized() async{
  print("push all");
  final dogs = await getAllDogs();
  for(var dog in dogs){
    print(dog.isSynced);
    print(dog.id);
    if(dog.isSynced==true){
      continue;
    }
    await syncDog(dog.id);
  }
  final walks = await getAllWalks();
  for(var walk in walks){
    if(walk.isSynced==true){
      continue;
    }
    await syncWalk(walk.id);
  }

}
Future<void> syncWalk (String walkId) async{
    final db = await _database.database;
    final walk = await getWalk(walkId);
    if(walk==null){
      return;
    }
    if(!await PocketBaseService.instance.postWalk(walk))
    {
      if(!await PocketBaseService.instance.updateWalk(walk)){
        return;
      }
    }

    await db.update('Walks',
    {
      'sync_status': 1
    },
    where: 'id = ?',
    whereArgs: [walkId]);
  } 
Future<void> syncDog (String dogId) async{
    final db = await _database.database;
    final dog = await getDog(dogId);
        print("syc dogf>");
    if(dog==null){
      return;
    }
    if(!await PocketBaseService.instance.postDog(dog))
    {
      if(!await PocketBaseService.instance.updateDog(dog)){
        final fetchedDogs=await PocketBaseService.instance.fetchAllDogs();
        if (fetchedDogs.any((el) => el.id == dogId)) {
          final userId=PocketBaseService.instance.client.authStore.record?.id;
          if(userId==null){
            return;
          }
          await db.delete(
            'DogUsers', 
            where: 'dog_id = ? AND user_id = ?',
            whereArgs: [dog.id, userId],
          );          
        }
        return;
      }
    }

    await db.update('Dogs',
    {
      'sync_status': 1
    },
    where: 'id = ?',
    whereArgs: [dogId]);
  } 
  Future<String> startWalk(String dogId) async {

    final dogThatsHereTillAppSupportsMultipleDogs=(await getAllDogs()).firstOrNull;
    if(dogThatsHereTillAppSupportsMultipleDogs==null){
      return "";
    }
    dogId = dogThatsHereTillAppSupportsMultipleDogs.id;

    
    final db = await _database.database;
    final walkId = _uuid.v4();

    DogWalk newWalk = DogWalk(id: walkId, dogId: dogId, startedAt: DateTime.now().toUtc());
    bool success = await db.insert('Walks', convertDogWalkToLocalDb(newWalk)) != 0;
    if(!success){
      return "";
    }
    refreshAndEmitWalks();
    success = await PocketBaseService.instance.postWalk(newWalk);
    if(success){
      await db.update('Walks',{'sync_status': 1}, where: 'id = ?', whereArgs: [walkId]);
    }
    return walkId;
  }
  
  Future<void> finishWalk(String walkId, int distanceInM, String routePolyline) async {
    final db = await _database.database;

    bool success = await db.update(
      'Walks',
      {
        'route': routePolyline,
        'distance_in_m': distanceInM,
        'ended_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status': 0,
      },
      where: 'id = ?',
      whereArgs: [walkId],
    ) != 0;
    
    final updatedWalk = await getWalk(walkId);
    if(!success || updatedWalk == null){
      return;
    }
    refreshAndEmitWalks();
    success = await PocketBaseService.instance.updateWalk(updatedWalk);
    if(success){
      await db.update('Walks',{'sync_status': 1}, where: 'id = ?', whereArgs: [walkId]);
    }
  }
  Future<List<DogWalk>> getAllWalks() async {
    final db = await _database.database;

    final results = await db.query('Walks');
    return convertDogWalksFromDb(results);
  }
  Future<List<Dog>> getAllDogs() async {
    final userId=PocketBaseService.instance.client.authStore.record?.id;
    final db = await _database.database;
    if (userId == null) {
      return [];
    }
    final results = await db.rawQuery('''
      SELECT Dogs.* 
      FROM Dogs
      INNER JOIN DogUsers ON Dogs.id = DogUsers.dog_id
      WHERE DogUsers.user_id = ?
    ''', [userId]);

    print(results);

    return convertDogsFromDb(results);
  }
  Future<List<DogWalk>> getWalks(String dogId) async {
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
  Future<Dog?> getDog(String dogId) async {
    final db = await _database.database;

    final userId=PocketBaseService.instance.client.authStore.record?.id;
    if (userId == null) {
      return null;
    }
    final results = await db.rawQuery('''
      SELECT Dogs.* 
      FROM Dogs
      INNER JOIN DogUsers ON Dogs.id = DogUsers.dog_id
      WHERE DogUsers.user_id = ? AND Dogs.id = ? 
    ''', [userId, dogId]);

    if (results.isEmpty) return null;

    return convertDogFromDb(results.first);
  }

  Future<void> deleteWalk(String walkId) async {
    final db = await _database.database;

    await db.delete(
      'Walks',
      where: 'id = ?',
      whereArgs: [walkId],
    );
    refreshAndEmitWalks();
  }
  Dog? convertDogFromDb(Map<String, dynamic> dbEntry) {
    try {
      return Dog(
        id: dbEntry['id'] as String,
        name: dbEntry['name'],     
        isSynced: (dbEntry['sync_status'] as num)==1
      );
    } catch (e) {
      return null;
    }
  }
  List<Dog> convertDogsFromDb(List<Map<String, Object?>?> dbEntries){
    List<Dog> re=[];
    for(var entry in dbEntries){
      if(entry==null)continue;

      final parsed = convertDogFromDb(entry);
      if(parsed==null)continue;

      re.add(parsed);
    }
    return re;
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
        routePolyline: dbEntry['route'] as String?,
        comment: dbEntry['comment'] as String?,
        isSynced: (dbEntry['sync_status'] as num)==1
      );
    } catch (e) {
      return null;
    }
  }

  List<DogWalk> convertDogWalksFromDb(List<Map<String, Object?>?> dbEntries){
    List<DogWalk> re=[];
    for(var entry in dbEntries){
      if(entry==null)continue;

      final parsed = convertDogWalkFromDb(entry);
      if(parsed==null)continue;

      re.add(parsed);
    }
    return re;
  }

  Map<String, dynamic> convertDogWalkToLocalDb(DogWalk walk) {
    return {
      'id': walk.id,
      'dog_id': walk.dogId,
      'started_at': walk.startedAt.toIso8601String(),
      'ended_at': walk.endedAt?.toIso8601String(),
      'distance_in_m': walk.distanceInM,
      'route': walk.routePolyline,
      'comment': walk.comment,
      'sync_status': walk.isSynced ? 1 : 0
    };
  }

  Map<String, dynamic> convertDogToLocalDb(Dog dog) {
    return {
      'id': dog.id,
      'name': dog.name,
      'sync_status': dog.isSynced ? 1 : 0
    };
  }
}