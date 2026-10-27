class Dog{
  String id;
  String name;
  
  Dog({required this.id, required this.name});
}
class DogWalk {
  String id;
  String dogId;
  DateTime startedAt;
  DateTime? endedAt;
  double distanceInM;
  String? routePolyline;
  String? comment;

  DogWalk({
    required this.id, 
    required this.dogId, 
    required this.startedAt, 
    this.endedAt, 
    this.distanceInM = 0, 
    this.routePolyline, 
    this.comment
  });
}