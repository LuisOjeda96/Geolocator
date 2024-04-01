import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hmcheckpoint/features/visitador/presentation/providers/copiloto/mapa_provider.dart';


class MapView extends ConsumerWidget {
  final LatLng initialLocation;
  final Set<Polyline> polylines;

  const MapView({
    super.key, 
    required this.initialLocation,
    required this.polylines,
  });

  @override
  Widget build(BuildContext context, ref) {

    final size = MediaQuery.of(context).size;

    final CameraPosition initialCameraPosition = CameraPosition(
      bearing: 192.8334901395799,
      target: initialLocation,
      zoom: 15,
    );

    return SizedBox(
      width: size.width,
      height: size.height * 0.85,
      child:  Listener(
        onPointerMove: (event) => ref.read(mapaProvider.notifier).stopFollowingUser(),
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          compassEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) => ref.read(mapaProvider.notifier).onInitMap(controller),
          polylines: polylines,
        ),
      ),
    );
  }
}