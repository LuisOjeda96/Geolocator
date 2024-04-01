
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hmcheckpoint/config/theme/uber.dart';
import 'package:hmcheckpoint/features/visitador/presentation/providers/copiloto/location_provider.dart';

final mapaProvider = StateNotifierProvider<MapaNotifier, MapaState>((ref) {
  final locationNotifier = ref.read(locationProvider.notifier);
  final locationState = ref.read(locationProvider);
  return MapaNotifier( locationNotifier, locationState);
});

class MapaNotifier extends StateNotifier<MapaState>{

  GoogleMapController? mapController;
  StreamSubscription? positionStreamSubscription;

  final LocationNotifier locationNotifier;
  final LocationState locationState;



  MapaNotifier(this.locationNotifier, this.locationState ) : super(MapaState()){

    positionStreamSubscription = locationNotifier.stream.listen((locationState) {
      if(locationState.lastKnowLocation != null){
        onPolylineNewPoint(locationState.myLocationHistory);
      }
      if ( !state.isFollowingUser ) return;
      if( locationState.lastKnowLocation == null ) return;
      moveCamera(locationState.lastKnowLocation!);
    });
  }

  void onInitMap(GoogleMapController controller){
    mapController = controller;
    mapController?.setMapStyle( jsonEncode(uberMapTheme));
    state = state.copyWith(isMapInicialized: true, isFollowingUser: true);
  }

  void moveCamera(LatLng location){
    final camaraUpdate = CameraUpdate.newLatLng(location);
    mapController?.animateCamera(camaraUpdate);
  }

  void startFollowingUser(){
    positionStreamSubscription?.resume();
    state = state.copyWith(isFollowingUser: true);
    if(locationState.lastKnowLocation == null) return;
      moveCamera(locationState.lastKnowLocation!);
  }

  void stopFollowingUser(){
    state = state.copyWith(isFollowingUser: false);
    //positionStreamSubscription?.cancel();
  }

  void changeUserFollowing() {
    state = state.copyWith(isFollowingUser: !state.isFollowingUser);
    if (state.isFollowingUser) {
      startFollowingUser();
    }
  }

  void onPolylineNewPoint( List<LatLng> userLocations ){
    final myRoute = Polyline(
      polylineId: const PolylineId('myRoute'),
      color: Colors.black87,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      points: userLocations,
    );

    final currentPolyines =  Map<String, Polyline>.from(state.polylines);
    currentPolyines['myRoute'] = myRoute;
    state = state.copyWith(polylines: currentPolyines);
  }

  void showMyRoute(){
    state = state.copyWith(showMyRoute: !state.showMyRoute);
  }
}


class MapaState{
  final bool isMapInicialized;
  final bool isFollowingUser;
  final bool showMyRoute;
  final Map<String, Polyline> polylines;

  MapaState({
    this.isMapInicialized = false,
    this.isFollowingUser = true,
    this.showMyRoute = true,
    Map<String, Polyline>? polylines,
  }) : polylines = polylines ?? const {};

  MapaState copyWith({
    bool? isMapInicialized,
    bool? isFollowingUser,
    Map<String, Polyline>? polylines,
    bool? showMyRoute,
  }) => MapaState(
      isMapInicialized: isMapInicialized ?? this.isMapInicialized,
      isFollowingUser: isFollowingUser ?? this.isFollowingUser,
      showMyRoute: showMyRoute ?? this.showMyRoute,
      polylines: polylines ?? this.polylines,
    );
}