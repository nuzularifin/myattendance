part of 'location_bloc.dart';

@immutable
abstract class LocationEvent {}

class FindMyLocation extends LocationEvent {}

class DistanceMyLocation extends LocationEvent {}
