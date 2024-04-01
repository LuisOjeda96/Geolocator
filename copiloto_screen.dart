import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hmcheckpoint/config/helpers/helpers.dart';
import 'package:hmcheckpoint/features/visitador/presentation/providers/copiloto/copiloto_provider.dart';
import 'package:hmcheckpoint/features/visitador/presentation/providers/copiloto/location_provider.dart';
import 'package:hmcheckpoint/features/visitador/presentation/providers/copiloto/mapa_provider.dart';
import 'package:hmcheckpoint/features/visitador/presentation/screens/views/map_view.dart';
import 'package:hmcheckpoint/features/visitador/presentation/widgets/widgets.dart';


class CopilotoScreen extends ConsumerStatefulWidget {
  
  const CopilotoScreen({super.key});

  @override
  CopilotoScreenState createState() => CopilotoScreenState();
}

class CopilotoScreenState extends ConsumerState<CopilotoScreen> {
  late LocationNotifier locationsProvider;

  @override
  void initState() {
    super.initState();
    locationsProvider = ref.read(locationProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationsProvider.startFollowingUser();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationsProvider.stopFollowingUser();
    });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    final ajustes = ref.watch(copilotoProvider);
    final datos = ref.watch(locationProvider);
    final mapa = ref.watch(mapaProvider);

    Map<String, Polyline> polylines = Map.from( mapa.polylines );
    if(!mapa.showMyRoute){
      polylines.removeWhere((key, value) => key == 'myRoute');
    }


    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: App.colorPrincipal, size: 28.0),
            onPressed: () {
              context.pop();
            },
          ),
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: const Text("COPILOTO", style: TextStyle(fontSize: 20, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(ajustes.isGpsPermissionGranted ? Icons.settings : Icons.settings , color: App.colorPrincipal, size: 30),
              onPressed: () async{
                ref.read(copilotoProvider.notifier).askGpsAccess();
              })
          ],
        ),
      body: datos.lastKnowLocation == null ? const Center(child: CircularProgressIndicator()) : 
      SingleChildScrollView(
        child: Stack(
          children: [
            MapView(
              initialLocation: datos.lastKnowLocation!, 
              polylines: polylines.values.toSet(),
            ),
            const Searchbar(),
            const ManualMarket(),
          ],

        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BtnPolyline(),
          BtnFollowUser(),
          BtnCurrentLocation(),
          
        ],
      ),
    );
  }
}