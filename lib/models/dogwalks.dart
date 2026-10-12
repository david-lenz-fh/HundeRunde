class Dog{
  int id;
  String name;
  
  Dog(this.id, this.name);
}

class DogWalk{
  int id;
  int dogId;
  DateTime startedAt;
  DateTime endedAt;
  int distanceInM;
  String routePolyline;
  String comment;

  DogWalk(this.id, this.dogId, this.startedAt, this.endedAt, 
  this.distanceInM, this.routePolyline, this.comment);
}