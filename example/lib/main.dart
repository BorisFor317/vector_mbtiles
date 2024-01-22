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



final lih = LatLng(47.159510, 9.553648);

final belarus = LatLng(53.860543, 27.681657); // mkad
final gorvovka = LatLng(48.343987, 38.012386);

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
                center: belarus,
                zoom: 14,
                maxZoom: 15.4, // max zoom
              ),
              children: [
                  VectorTileLayer(
                    key: const Key('VectorTileLayerWidget'),
                    theme: OSMBrightTheme.osmBrightJaTheme(),
                    tileProviders: TileProviders({
                      'openmaptiles': VectorMBTilesProvider(
                        mbtilesPath: file!.path,
                        tileCompression: TileCompression.gzip,
                      )
                    }),
                  ),
                ])
          : Center(
              child: ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

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
