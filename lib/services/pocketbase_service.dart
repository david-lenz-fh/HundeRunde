import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:starter_flutter/models/dogwalks.dart';

class PocketBaseService extends ChangeNotifier{
  static final PocketBaseService instance = PocketBaseService._internal();
  late final PocketBase client;

  bool get isLoggedIn => client.authStore.isValid;

  PocketBaseService._internal();

  Future<void> init() async {
    const storage = FlutterSecureStorage();

    final initialAuth = await storage.read(key: 'pb_auth');

    final store = AsyncAuthStore(
      save: (String data) async => await storage.write(key: 'pb_auth', value: data),
      initial: initialAuth,
      clear: () async => await storage.delete(key: 'pb_auth'),
    );

    client = PocketBase('https://re-server.at:8443', authStore: store);
    client.authStore.onChange.listen((_) {
      notifyListeners();
    });
    if (client.authStore.isValid) {
      try {
        await client.collection('users').authRefresh();
      } catch (e) {
        if (e is ClientException && e.statusCode == 401) {
          client.authStore.clear();
        }
      }
    }
    else if(client.authStore.token.isNotEmpty){
      client.authStore.clear();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await client.collection('users').authWithPassword(email, password);
    } on ClientException catch (e) {
      print('Login fehlgeschlagen: ${e.response['message']}');
    }
  }
  void logout() {
    client.authStore.clear();
  }

  Future<bool> postWalk(DogWalk walk) async{
    try {
      print(convertWalkToRequestBody(walk));
      await client.collection('walks').create(body: convertWalkToRequestBody(walk));
    }
    catch(e){
      print(e);
      return false;
    }
    return true;
  }
  Future<bool> updateWalk(DogWalk walk) async{
    try {
      await client.collection('walks').update(walk.id, body: convertWalkToRequestBody(walk));
    }
    catch(e){
      return false;
    }
    return true;
  }
  Future<bool> postDog(Dog dog) async{
    final userId=client.authStore.record?.id;
    if(userId==null){
      return false;
    }

    try {
      await client.collection('dogs').create(body: convertDogToCreateBody(dog, userId));
    }
    catch(e){
      return false;
    }
    return true;
  }
  Future<bool> updateDog(Dog dog) async{
    try {
      await client.collection('dogs').update(dog.id, body: convertDogToUpdateBody(dog));
    }
    catch(e){
      return false;
    }
    return true;
  }
  Future<Dog?> addMemberToDog(String dogId) async{
    final userId=client.authStore.record?.id;
    if(userId==null){
      return null;
    }
    final updatedDog=await client.collection('dogs').update(dogId, body:{'members+': userId });
    return convertFetchedToDog(updatedDog);
    
  }
  Future<List<DogWalk>> fetchAllWalks() async{
    List<DogWalk> re = [];
    try{
      final records = await client.collection('walks').getFullList();
      print(records.toString());
      for (var record in records) {
        final fetchedWalk = convertFetchedToDogWalk(record);
        if(fetchedWalk==null){
          continue;
        }
        re.add(fetchedWalk);
      }
    } on ClientException catch (e) {
      print('PocketBase Fehler (ClientException):');
      print('Status Code: ${e.statusCode}');
      print('Response: ${e.response}');
    } catch (e) {
      print('Allgemeiner Fehler: $e');
    }
    return re;
  }
  Future<List<Dog>> fetchAllDogs() async{
    List<Dog> re = [];
    final records = await client.collection('dogs').getFullList();
    print("Lucys Dogs");print(records);
    for (var record in records) {
      final fetchedDog = convertFetchedToDog(record);
      if(fetchedDog==null){
        continue;
      }
      fetchedDog.isSynced = true;
      re.add(fetchedDog);
    }
    return re;
  }
  Map<String, dynamic> convertWalkToRequestBody(DogWalk walk){
    return {
    'id': walk.id,
    'dog': walk.dogId,
    'started_at': walk.startedAt.toIso8601String(),
    'ended_at': walk.endedAt?.toIso8601String(),
    'distance_in_m': walk.distanceInM,
    'routePolyline': walk.routePolyline,
    'comment': walk.comment,
    };
  }
  
  Map<String, dynamic> convertDogToUpdateBody(Dog dog){
    return {
      'id': dog.id,
      'dog_name': dog.name
    };
  }
  Map<String, dynamic> convertDogToCreateBody(Dog dog, String userId){
    return {
      'id': dog.id,
      'dog_name': dog.name,
      'members': [userId]
    };
  }
  DogWalk? convertFetchedToDogWalk(RecordModel entry) {
    final dogId = entry.data['dog'];
    final startedAtStr = entry.data['started_at'];
    
    if (startedAtStr == null || dogId == null) {
      return null;
    }
    try{
      return DogWalk(
          id: entry.id,
          dogId: dogId,
          startedAt: DateTime.parse(startedAtStr),
          endedAt: entry.data['ended_at'] != null ? DateTime.parse(entry.data['ended_at']) : null,
          distanceInM: (entry.data['distance_in_m'] as num?)?.toDouble() ?? 0.0,
          routePolyline: entry.data['routePolyline'],
          comment: entry.data['comment'],
        );
    }
    catch(e){
      return null;
    }
  }
  Dog? convertFetchedToDog(RecordModel entry) {        
    try{
      return Dog(id: entry.id, name: entry.data['dog_name']);
    }
    catch(e){
      return null;
    }
  }
}
