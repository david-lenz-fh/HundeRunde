class Dog{
  String id;
  String name;
  bool isSynced;
  
  Dog({required this.id, required this.name, this.isSynced=false});
}
class DogWalk {
  String id;
  String dogId;
  DateTime startedAt;
  DateTime? endedAt;
  double distanceInM;
  String? routePolyline;
  String? comment;
  bool isSynced;

  DogWalk({
    required this.id, 
    required this.dogId, 
    required this.startedAt, 
    this.endedAt, 
    this.distanceInM = 0, 
    this.routePolyline, 
    this.comment,
    this.isSynced=false
  });
}