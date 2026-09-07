import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import "package:flutter_map/flutter_map.dart";
import 'package:hpiwf/config.dart';
import 'package:latlong2/latlong.dart';
import "../controllers/data-controller.dart";
import 'dart:math';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final MapController _mapController = MapController();
  bool _mapLoaded = false;

  void _zoomIn() {
    double curZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, curZoom + 1);
  }

  void _zoomOut() {
    double curZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, max(curZoom - 1, 0));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DataController(),
      builder: (context, child) {
        LatLng curPos = LatLng(
          DataController().lat ?? 51.509364,
          DataController().lng ?? -0.128928,
        );

        if (_mapLoaded) _mapController.move(curPos, _mapController.camera.zoom);

        return Stack(
          children: [
            Positioned(
              top: 35,
              left: 0,
              bottom: 0,
              right: 0,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.bottomCenter,
                    colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                    stops: [0, 0.15, 0.85, 1],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: curPos,
                    initialZoom: 16,
                    onMapReady: () {
                      _mapLoaded = true;
                      _mapController.move(curPos, 16);
                    },
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hpiwf',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: curPos,
                          child: Icon(Icons.location_on, color: Colors.red, size: 50),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).scaffoldBackgroundColor, blurRadius: 20),
                    ],
                  ),
                  child: Text(
                    "Location",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 40,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: _zoomIn,
                    heroTag: "zoom_in",
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Text(
                      "+",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 30,
                        fontFamily: "cubano",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),

                  FloatingActionButton(
                    onPressed: _zoomOut,
                    heroTag: "zoom_out",
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Text(
                      "-",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 30,
                        fontFamily: "cubano",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
