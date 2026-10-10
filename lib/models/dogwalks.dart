class Dog{
  int id;
  String name;

  Dog(this.id, this.name);
}

class Walk{
  int id;
  int dogId;
  DateTime startedAt;
  DateTime endedAt;
  int distanceInM;
  String routePolyline;
  String comment;

  Walk(this.id, this.dogId, this.startedAt, this.endedAt, 
  this.distanceInM, this.routePolyline, this.comment);

  
}