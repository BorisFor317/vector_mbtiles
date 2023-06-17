import 'dart:developer';
import 'dart:io';
import 'package:example/permission_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_mbtiles/vector_mbtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart'
    as vector_tile_renderer;

import 'osm_bright_ja_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionService.initFilePermission();
  await PermissionService.initLocationPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VectorMBTiles example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'VectorMBTiles example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const maxMapZoom = 20.4; // 14.4
const minMapZoom = 5.5;

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();
  bool isOpen = false;

  File? file;
  double currentMapZoom = 14.4;
  void moveToCurrentPosition() =>
      _mapController.move(LatLng(53.965965, 30.384345), currentMapZoom);

  void zoomCamera() {
    if (currentMapZoom <= maxMapZoom - 1) {
      currentMapZoom = currentMapZoom + 1;

      moveToCurrentPosition();
    }
    print('zoom $currentMapZoom');
  }

  void unZoomCamera() {
    if (currentMapZoom >= minMapZoom) {
      currentMapZoom = currentMapZoom - 1;
      moveToCurrentPosition();
    }
    print('zoom $currentMapZoom');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => zoomCamera(),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => unZoomCamera(),
            child: const Icon(Icons.exposure_minus_1_rounded),
          ),
        ],
      ),
      body: isOpen
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                // 47.159510, 9.553648 -- lihten
                center: LatLng(53.965965, 30.384345),
                zoom: currentMapZoom,
                maxZoom: maxMapZoom,
              ),
              children: [
                  VectorTileLayer(
                    key: const Key('VectorTileLayerWidget'),
                    theme: OSMBrightTheme.osmBrightJaTheme(),
                    tileProviders: TileProviders({
                      'openmaptiles': VectorMBTilesProvider(
                        mbtilesPath: file!.path,
                        maximumZoom: 15,
                        //    tileCompression: TileCompression.none,
                      )
                    }),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 60,
                        point: LatLng(53.965965, 30.384345),
                        builder: (context) => const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(),
                            FittedBox(child: Text('hi there')),
                          ],
                        ),
                      )
                    ],
                  ),
                ])
          : Center(
              child: ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
// /data/user/0/com.example.example/databases/example.mbtiles
                  if (result != null) {
                    log('result.files.single.path! ${result.files.single.path!}');

                    file = File(result.files.last.path!);
                    setState(() {
                      isOpen = true;
                    });
                  } else {
                    // User canceled the picker
                  }
                },
                child: const Text('open'),
              ),
            ),
    );
  }
}

extension OSMBrightTheme on ProvidedThemes {
  static vector_tile_renderer.Theme osmBrightJaTheme({Logger? logger}) =>
      ThemeReader(logger: logger).read(osmBrightJaStyle());
}
