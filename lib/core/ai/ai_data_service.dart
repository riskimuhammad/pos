import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

class AIDataService {
  final Database database;

  AIDataService({required this.database});

  Future<void> saveScanResult({
    required String imagePath,
    String? predictedLabel,
    double? confidence,
    String? chosenProductLabel,
  }) async {
    await database.insert('ai_scans', {
      'id': const Uuid().v4(),
      'image_path': imagePath,
      'predicted_label': predictedLabel,
      'confidence': confidence,
      'chosen_product_label': chosenProductLabel,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'sync_status': 'pending',
    });
  }

  Future<void> saveTrainingSample({
    required String imagePath,
    required String label,
  }) async {
    await database.insert('ai_training_samples', {
      'id': const Uuid().v4(),
      'image_path': imagePath,
      'label': label,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'sync_status': 'pending',
    });
  }
}


