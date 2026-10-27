import 'package:uuid/uuid.dart';

class Dog{
  Uuid id;
  String name;
  Dog(this.id, this.name);
}

class User{
  int id;
  String username;
  String? profilePictureBase64;

  User(this.id, this.username, this.profilePictureBase64);
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