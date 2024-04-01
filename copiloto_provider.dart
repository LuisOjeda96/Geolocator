
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final copilotoProvider = StateNotifierProvider.autoDispose<CopilotoNotifier, CopilotoState>((ref) => CopilotoNotifier());

class CopilotoNotifier extends StateNotifier<CopilotoState> {
  CopilotoNotifier() : super(CopilotoState()){
    _init();
    askGpsAccess();
  }
  bool get isGpsEnable => state.isGpsEnable && state.isGpsPermissionGranted;

  void setGpsEnable(bool isGpsEnable) {
    state = state.copyWith(isGpsEnable: isGpsEnable);
  }

  void setGpsPermissionGranted(bool isGpsPermissionGranted) {
    state = state.copyWith(isGpsPermissionGranted: isGpsPermissionGranted);
  }

  Future<void> _init() async {
    final gpsInitStatus = await Future.wait([
      _checkGpsStatus(), 
      _isPermissionGranted()
    ]);

    setGpsEnable(gpsInitStatus[0]);
    setGpsPermissionGranted(gpsInitStatus[1]);
  }

  Future<bool> _isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<bool> _checkGpsStatus() async {
    final isEnable = await Geolocator.isLocationServiceEnabled();

    Geolocator.getServiceStatusStream().listen((event) { 
      if(event == ServiceStatus.disabled){
        setGpsEnable(false);
      }else{
        setGpsEnable(true);
      }
    });
    return isEnable;
  }

  Future<void> askGpsAccess() async {
    final newPermission = await Geolocator.requestPermission();
    if (newPermission == LocationPermission.denied || newPermission == LocationPermission.deniedForever) {
      setGpsPermissionGranted(false);
      // Si el permiso está denegado o denegado permanentemente, abre la configuración de la aplicación
      Geolocator.openAppSettings();    
    } else {
      setGpsPermissionGranted(true);
    }
  }
}

class CopilotoState{
  final bool isGpsEnable;
  final bool isGpsPermissionGranted;

  CopilotoState({
    this.isGpsEnable = false,
    this.isGpsPermissionGranted = false,
  });

  CopilotoState copyWith({
    bool? isGpsEnable,
    bool? isGpsPermissionGranted,
  }) => CopilotoState(
      isGpsEnable: isGpsEnable ?? this.isGpsEnable,
      isGpsPermissionGranted: isGpsPermissionGranted ?? this.isGpsPermissionGranted,
    );
  
}