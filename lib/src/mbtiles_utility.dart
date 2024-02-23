import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_mbtiles/src/vector_mbtiles_provider.dart';

/// MBTilesUtility is MBTiles access utility.
class MBTilesUtility {
  /// A constructor of `MBTilesUtility` class.
  /// [_mbtilesPath] MBTiles path
  /// [_tileCompression] option to set tile compression
  MBTilesUtility(this._mbtilesPath, this._tileCompression) {
    getDBFuture = _getDatabase(_mbtilesPath);
  }

  final String _mbtilesPath;
  final TileCompression _tileCompression;
  Database? _database;
  late Future<Database> getDBFuture;

  /// Get VectorTileBytes in binary
  /// [tile] TileIdentity(z, x, y)
  Future<Uint8List> getVectorTileBytes(TileIdentity tile) async {
    final max = pow(2, tile.z).toInt();
    if (tile.x >= max || tile.y >= max || tile.x < 0 || tile.y < 0) {
      throw ProviderException(
        message: 'Invalid tile coordinates $tile',
        retryable: Retryable.none,
        statusCode: 400,
      );
    }

    _database ??= await getDBFuture;

    final resultSet = await _database!.query(
      'tiles',
      columns: ['tile_data'],
      where: '''
      zoom_level = ?
      AND tile_column = ?
      AND tile_row = ?
      ''',
      whereArgs: [tile.z, tile.x, max - tile.y - 1],
    );

    if (resultSet.length == 1) {
      final tileData = resultSet.first['tile_data'];
      Uint8List extractedTile;
      switch (_tileCompression) {
        case TileCompression.gzip:
          extractedTile =
              GZipCodec().decode(tileData! as Uint8List) as Uint8List;

        case TileCompression.none:
          extractedTile = tileData! as Uint8List;
      }
      return extractedTile;
    } else if (resultSet.length > 1) {
      throw ProviderException(
        message: 'Too many match tiles',
        retryable: Retryable.none,
      );
    } else {
      return Uint8List(0);
    }
  }

  Future<Database> _getDatabase(String url) async {
    String dbFullPath;

    if (Platform.isLinux || Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
      await databaseFactoryFfi.setDatabasesPath(Directory.current.path);

      dbFullPath = url;
    } else {
      final dbFilename = url.split('/').last;
      final databasesPath = await getDatabasesPath();
      dbFullPath = path.join(databasesPath, dbFilename);
    }

    print('dbFullPath $dbFullPath');
    try {
      final exists = await databaseExists(dbFullPath);
      print('does exists: $exists');
      if (!exists) {
        final file = File(_mbtilesPath);
        final customBytes = await file.readAsBytes(); // Uint8List
        final byteData = customBytes.buffer.asByteData();

        final List<int> bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );

        await File(dbFullPath).writeAsBytes(bytes, flush: true);
      }
    } catch (e, t) {
      print('e: $e, $t');
    }

    return openDatabase(dbFullPath);
  }
}
