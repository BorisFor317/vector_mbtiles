import 'dart:developer';
import 'dart:io';
import 'package:example/osm_bright_ja_style.dart';
import 'package:example/scale_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import 'package:vector_mbtiles/vector_mbtiles.dart';

void main() async {
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

const belarus = LatLng(53.860543, 27.681657); // mkad

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();

  bool isOpened = false;

  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isOpened
          ? FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onTap: (tapPosition, point) {
                  print('selected ${point.toJson()}');
                },
                initialCenter: belarus,
                initialZoom: 10,
                maxZoom: 15.4,
              ),
              children: [
                  // TileLayer(
                  //   tileProvider: FileTileProvider(),
                  //   maxZoom: 17,
                  //   urlTemplate:
                  //       // TODO provide your path

                  //       "C:/Users/medvedev.MECARO/Desktop/borovaya_air_port_8_17/{z}/{x}/{y}.png",
                  // ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.red,
                    child: const FlutterMapScaleLayer(),
                  ),
                  // TODO use these code for mbtiles
                  VectorTileLayer(
                    //  memoryTileCacheMaxSize: 1024 * 1024 * 1024, // 1 gb
                    // memoryTileDataCacheMaxSize: 1024 * 1024 * 1024, // 1 gb
                    memoryTileCacheMaxSize: 0,
                    memoryTileDataCacheMaxSize: 0,

                    key: const Key('VectorTileLayerWidget'),
                    theme: OSMBrightTheme.darkTheme(),
                    tileProviders: TileProviders({
                      'openmaptiles': VectorMBTilesProvider(
                        mbtilesPath: file!.path,
                        maximumZoom: 15,
                        minimumZoom: 6,
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

                    log('path ${file!.path}');
                    setState(() {
                      isOpened = true;
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
