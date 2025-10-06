import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';

class AIModelManifest {
  final String version;
  final String modelUrl;
  final String labelsUrl;

  AIModelManifest({
    required this.version,
    required this.modelUrl,
    required this.labelsUrl,
  });

  factory AIModelManifest.fromJson(Map<String, dynamic> json) {
    return AIModelManifest(
      version: json['version'] as String,
      modelUrl: json['model_url'] as String,
      labelsUrl: json['labels_url'] as String,
    );
  }
}

class AIModelManager {
  final Dio dio;
  final GetStorage storage;

  static const String _storageKeyVersion = 'ai_model_version';
  static const String _folderName = 'models';
  static const String _modelFile = 'yolo_detector.tflite';
  static const String _labelsFile = 'labels.txt';

  AIModelManager({required this.dio, required this.storage});

  Future<String> _modelsDirPath() async {
    final dbPath = await getDatabasesPath();
    final baseDir = p.dirname(dbPath);
    final modelsDir = p.join(baseDir, _folderName);
    final dir = Directory(modelsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return modelsDir;
  }

  Future<String> getModelPath() async => p.join(await _modelsDirPath(), _modelFile);
  Future<String> getLabelsPath() async => p.join(await _modelsDirPath(), _labelsFile);

  String? getCurrentVersion() => storage.read<String>(_storageKeyVersion);

  Future<void> setCurrentVersion(String version) async {
    await storage.write(_storageKeyVersion, version);
  }

  Future<bool> isModelReady() async {
    final modelPath = await getModelPath();
    final labelsPath = await getLabelsPath();
    return File(modelPath).existsSync() && File(labelsPath).existsSync();
  }

  Future<void> downloadModel(AIModelManifest manifest) async {
    final modelPath = await getModelPath();
    final labelsPath = await getLabelsPath();

    await dio.download(manifest.modelUrl, modelPath);
    await dio.download(manifest.labelsUrl, labelsPath);
    await setCurrentVersion(manifest.version);
  }

  // Direct download using raw URLs (without manifest)
  Future<void> downloadDirect({
    required String modelUrl,
    required String labelsUrl,
    String version = 'direct',
  }) async {
    final modelPath = await getModelPath();
    final labelsPath = await getLabelsPath();

    await dio.download(modelUrl, modelPath);
    await dio.download(labelsUrl, labelsPath);
    await setCurrentVersion(version);
  }

  Future<AIModelManifest> fetchManifest(String manifestUrl) async {
    final res = await dio.get(manifestUrl);
    return AIModelManifest.fromJson(res.data as Map<String, dynamic>);
  }
}


