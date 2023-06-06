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

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();
  bool isOpen = false;

  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isOpen
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(47.159510, 9.553648),
                zoom: 15,
                maxZoom: 19,
              ),
              children: [
                  VectorTileLayer(
                    key: const Key('VectorTileLayerWidget'),
                    theme: OSMBrightTheme.osmBrightJaTheme(),
                    tileProviders: TileProviders({
                      'openmaptiles': VectorMBTilesProvider(
                        //    mbtilesPath: 'assets/liechtenstein-none.mbtiles',
                        //'/data/user/0/com.example.example/cache/file_picker/liechtenstein-none.mbtiles'
                        mbtilesPath: file!.path,
                        maximumZoom: 15,
                        tileCompression: TileCompression.none,
                      )
                    }),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 50,
                        point: LatLng(47.159510, 9.553648),
                        builder: (context) => const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(),
                            FittedBox(child: Text('47.159510, 9.553648')),
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
