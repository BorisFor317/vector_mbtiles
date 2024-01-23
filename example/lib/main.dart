import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

final belarus = LatLng(53.860543, 27.681657); // mkad

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();

  bool isOpened = true;

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
                initialZoom: 9,
                maxZoom: 17, //15.4 max zoom mbtiles
              ),
              children: [
                  TileLayer(
                    tileProvider: FileTileProvider(),
                    maxZoom: 17,
                    urlTemplate:
                        // TODO provide your path

                        "C:/Users/medvedev.MECARO/Desktop/borovaya_air_port_8_17/{z}/{x}/{y}.png",
                  ),
                  // TODO use for mbtiles
                  // VectorTileLayer(
                  //   //  memoryTileCacheMaxSize: 1024 * 1024 * 1024, // 1 gb
                  //   // memoryTileDataCacheMaxSize: 1024 * 1024 * 1024, // 1 gb
                  //   memoryTileCacheMaxSize: 0,
                  //   memoryTileDataCacheMaxSize: 0,

                  //   key: const Key('VectorTileLayerWidget'),
                  //   theme: OSMBrightTheme.osmBrightJaTheme(),
                  //   tileProviders: TileProviders({
                  //     'openmaptiles': VectorMBTilesProvider(
                  //       mbtilesPath: file!.path,
                  //       maximumZoom: 17,
                  //       minimumZoom: 6,
                  //       tileCompression: TileCompression.gzip,
                  //     )
                  //   }),
                  // ),
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
