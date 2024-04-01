import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) => LocationNotifier());

class LocationNotifier extends StateNotifier<LocationState> {
  
  StreamSubscription<Position>? positionStreamSubscription;

  LocationNotifier() : super(LocationState());

  Future getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    onNewUserLocation(position);
  }

  void startFollowingUser() {
    changeFollowingUser();
    positionStreamSubscription = Geolocator.getPositionStream().listen((event) { 
      final position = event;
      onNewUserLocation(position);
    });
  }

  void stopFollowingUser() {
    changeFollowingUser();
    positionStreamSubscription?.cancel();
  }

  void onNewUserLocation(Position position) {
      state = state.copyWith(
        lastKnowLocation: LatLng(position.latitude, position.longitude),
        myLocationHistory: [...state.myLocationHistory, LatLng(position.latitude, position.longitude)],
      );
  }

  void changeFollowingUser() {
    state = state.copyWith(followingUser: !state.followingUser);
  }

}

class LocationState{
  final bool followingUser;
  final LatLng? lastKnowLocation;
  final List<LatLng> myLocationHistory;

  LocationState({
    this.followingUser = false,
    this.lastKnowLocation,
      myLocationHistory,
  }): myLocationHistory = myLocationHistory ?? const [];

  LocationState copyWith({
    bool? followingUser,
    LatLng? lastKnowLocation,
    List<LatLng>? myLocationHistory,
  }) => LocationState(
      followingUser: followingUser ?? this.followingUser,
      lastKnowLocation: lastKnowLocation ?? this.lastKnowLocation,
      myLocationHistory: myLocationHistory ?? this.myLocationHistory,
    );
}