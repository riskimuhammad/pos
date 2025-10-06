import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/features/products/domain/entities/product.dart';

class LocalProductDetector extends GetxController {
  final DatabaseHelper _databaseHelper;
  
  LocalProductDetector({required DatabaseHelper databaseHelper}) 
      : _databaseHelper = databaseHelper;

  // Extract visual features from image
  Future<Map<String, dynamic>> extractFeatures(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return {};

    // Resize to standard size
    final resizedImage = img.copyResize(image, width: 224, height: 224);
    
    // Extract color histogram
    final colorHistogram = _extractColorHistogram(resizedImage);
    
    // Extract dominant colors
    final dominantColors = _extractDominantColors(resizedImage);
    
    // Extract texture features (simplified)
    final textureFeatures = _extractTextureFeatures(resizedImage);
    
    return {
      'color_histogram': colorHistogram,
      'dominant_colors': dominantColors,
      'texture_features': textureFeatures,
      'image_hash': _calculateImageHash(resizedImage),
    };
  }

  // Find similar products using learned samples to map back to product_id
  Future<List<ProductMatch>> findSimilarProducts(Map<String, dynamic> features) async {
    final db = await _databaseHelper.database;

    // Pull learning samples (image_path + product_id)
    final samples = await db.query(
      'ai_learning_samples',
      columns: ['image_path', 'product_id', 'features'],
      orderBy: 'timestamp DESC',
    );

    final matches = <SampleMatch>[];

    for (final row in samples) {
      final imagePath = row['image_path'] as String?;
      final productId = row['product_id'] as String?;
      if (imagePath == null || productId == null) continue;

      try {
        Map<String, dynamic>? sampleFeatures;
        final featuresStr = row['features'] as String?;
        if (featuresStr != null && featuresStr.isNotEmpty) {
          // Attempt to parse JSON features if stored as JSON
          sampleFeatures = _tryParseJson(featuresStr);
        }

        // If features weren’t stored, compute on the fly from image
        if (sampleFeatures == null) {
          final imageFile = File(imagePath);
          if (!await imageFile.exists()) continue;
          final imageBytes = await imageFile.readAsBytes();
          sampleFeatures = await extractFeatures(imageBytes);
        }

        final similarity = _calculateSimilarity(features, sampleFeatures);
        if (similarity > 0.6) {
          matches.add(SampleMatch(productId: productId, similarity: similarity));
        }
      } catch (e) {
        // ignore corrupt rows
      }
    }

    // Also consider ai_training_samples (label-only)
    final training = await db.query(
      'ai_training_samples',
      columns: ['image_path', 'label'],
      orderBy: 'created_at DESC',
    );

    for (final row in training) {
      final imagePath = row['image_path'] as String?;
      final label = row['label'] as String?;
      if (imagePath == null || label == null) continue;
      try {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) continue;
        final bytes = await imageFile.readAsBytes();
        final f = await extractFeatures(bytes);
        final similarity = _calculateSimilarity(features, f);
        if (similarity > 0.6) {
          matches.add(SampleMatch(productId: 'label:$label', similarity: similarity, label: label));
        }
      } catch (_) {}
    }

    // Aggregate by productId to find best scores
    final Map<String, double> bestByProduct = {};
    for (final m in matches) {
      bestByProduct[m.productId] = (bestByProduct[m.productId] ?? 0.0).clamp(0.0, 1.0);
      if (m.similarity > (bestByProduct[m.productId] ?? 0.0)) {
        bestByProduct[m.productId] = m.similarity;
      }
    }

    if (bestByProduct.isEmpty) return [];

    // Fetch product rows for matched productIds (exclude label-only)
    final productIds = bestByProduct.keys.where((k) => !k.startsWith('label:')).toList();
    Map<String, Map<String, Object?>> productById = {};
    if (productIds.isNotEmpty) {
      final placeholders = List.filled(productIds.length, '?').join(',');
      final productRows = await db.rawQuery(
        'SELECT * FROM products WHERE id IN ($placeholders)',
        productIds,
      );
      productById = {for (final row in productRows) row['id'] as String: row};
    }
    final result = <ProductMatch>[];
    for (final entry in bestByProduct.entries) {
      final id = entry.key;
      final sim = entry.value;
      if (id.startsWith('label:')) {
        final match = matches.firstWhere((m) => m.productId == id, orElse: () => SampleMatch(productId: id, similarity: sim, label: id.substring(6)));
        final label = match.label ?? 'Unknown';
        final product = Product(
          id: id,
          name: label,
          sku: label,
          category: 'Unknown',
          price: 0.0,
          imageUrl: null,
          description: null,
          stock: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        result.add(ProductMatch(product: product, similarity: sim, confidence: sim));
      } else {
        final prod = productById[id];
        if (prod == null) continue;
        result.add(ProductMatch(
          product: Product.fromJson(prod),
          similarity: sim,
          confidence: sim,
        ));
      }
    }

    result.sort((a, b) => b.similarity.compareTo(a.similarity));
    return result.take(5).toList();
  }

  Map<String, dynamic>? _tryParseJson(String source) {
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Save user feedback for learning
  Future<void> saveUserFeedback({
    required String imagePath,
    required String selectedProductId,
    required double confidence,
  }) async {
    final db = await _databaseHelper.database;
    
    // Extract features from the image
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) return;
    
    final imageBytes = await imageFile.readAsBytes();
    final features = await extractFeatures(imageBytes);
    
    // Save to learning database
    await db.insert('ai_learning_samples', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'image_path': imagePath,
      'product_id': selectedProductId,
      'features': features.toString(), // Simplified storage
      'confidence': confidence,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'sync_status': 'pending',
    });
  }

  // Extract color histogram
  List<double> _extractColorHistogram(img.Image image) {
    final histogram = List<double>.filled(256, 0.0);
    final totalPixels = image.width * image.height;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final gray = ((pixel.r + pixel.g + pixel.b) / 3).round();
        histogram[gray]++;
      }
    }
    
    // Normalize
    for (int i = 0; i < 256; i++) {
      histogram[i] /= totalPixels;
    }
    
    return histogram;
  }

  // Extract dominant colors
  List<Map<String, int>> _extractDominantColors(img.Image image) {
    final colorCounts = <String, int>{};
    
    // Sample every 10th pixel for performance
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final colorKey = '${pixel.r ~/ 32}_${pixel.g ~/ 32}_${pixel.b ~/ 32}';
        colorCounts[colorKey] = (colorCounts[colorKey] ?? 0) + 1;
      }
    }
    
    // Get top 5 colors
    final sortedColors = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedColors.take(5).map((entry) {
      final parts = entry.key.split('_');
      return {
        'r': int.parse(parts[0]) * 32,
        'g': int.parse(parts[1]) * 32,
        'b': int.parse(parts[2]) * 32,
      };
    }).toList();
  }

  // Extract texture features (simplified)
  List<double> _extractTextureFeatures(img.Image image) {
    // Convert to grayscale
    final grayImage = img.grayscale(image);
    
    // Calculate edge density (simplified)
    int edgeCount = 0;
    for (int y = 1; y < grayImage.height - 1; y++) {
      for (int x = 1; x < grayImage.width - 1; x++) {
        final center = grayImage.getPixel(x, y).r;
        final right = grayImage.getPixel(x + 1, y).r;
        final down = grayImage.getPixel(x, y + 1).r;
        
        if ((center - right).abs() > 30 || (center - down).abs() > 30) {
          edgeCount++;
        }
      }
    }
    
    final totalPixels = (grayImage.width - 2) * (grayImage.height - 2);
    return [edgeCount / totalPixels];
  }

  // Calculate image hash (simplified)
  String _calculateImageHash(img.Image image) {
    // Resize to 8x8 for hash calculation
    final smallImage = img.copyResize(image, width: 8, height: 8);
    final grayImage = img.grayscale(smallImage);
    
    int hash = 0;
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final pixel = grayImage.getPixel(x, y).r;
        hash = (hash << 1) | (pixel > 128 ? 1 : 0);
      }
    }
    
    return hash.toRadixString(16);
  }

  // Calculate similarity between two feature sets
  double _calculateSimilarity(Map<String, dynamic> features1, Map<String, dynamic> features2) {
    double similarity = 0.0;
    
    // Color histogram similarity
    final hist1 = features1['color_histogram'] as List<double>? ?? [];
    final hist2 = features2['color_histogram'] as List<double>? ?? [];
    if (hist1.isNotEmpty && hist2.isNotEmpty) {
      similarity += _calculateHistogramSimilarity(hist1, hist2) * 0.4;
    }
    
    // Dominant colors similarity
    final colors1 = features1['dominant_colors'] as List<Map<String, int>>? ?? [];
    final colors2 = features2['dominant_colors'] as List<Map<String, int>>? ?? [];
    if (colors1.isNotEmpty && colors2.isNotEmpty) {
      similarity += _calculateColorSimilarity(colors1, colors2) * 0.3;
    }
    
    // Image hash similarity
    final hash1 = features1['image_hash'] as String? ?? '';
    final hash2 = features2['image_hash'] as String? ?? '';
    if (hash1.isNotEmpty && hash2.isNotEmpty) {
      similarity += _calculateHashSimilarity(hash1, hash2) * 0.3;
    }
    
    return similarity;
  }

  double _calculateHistogramSimilarity(List<double> hist1, List<double> hist2) {
    double sum = 0.0;
    for (int i = 0; i < hist1.length && i < hist2.length; i++) {
      sum += (hist1[i] - hist2[i]).abs();
    }
    return 1.0 - (sum / hist1.length);
  }

  double _calculateColorSimilarity(List<Map<String, int>> colors1, List<Map<String, int>> colors2) {
    double similarity = 0.0;
    for (final color1 in colors1) {
      for (final color2 in colors2) {
        final distance = _calculateColorDistance(color1, color2);
        similarity += (1.0 - distance / 441.0); // Max distance is sqrt(255^2 * 3)
      }
    }
    return similarity / (colors1.length * colors2.length);
  }

  double _calculateColorDistance(Map<String, int> color1, Map<String, int> color2) {
    final rDiff = color1['r']! - color2['r']!;
    final gDiff = color1['g']! - color2['g']!;
    final bDiff = color1['b']! - color2['b']!;
    return (rDiff * rDiff + gDiff * gDiff + bDiff * bDiff).toDouble();
  }

  double _calculateHashSimilarity(String hash1, String hash2) {
    if (hash1.length != hash2.length) return 0.0;
    
    int differences = 0;
    for (int i = 0; i < hash1.length; i++) {
      if (hash1[i] != hash2[i]) differences++;
    }
    
    return 1.0 - (differences / hash1.length);
  }

}

class SampleMatch {
  final String productId;
  final double similarity;
  final String? label;
  SampleMatch({required this.productId, required this.similarity, this.label});
}

class ProductMatch {
  final Product product;
  final double similarity;
  final double confidence;

  ProductMatch({
    required this.product,
    required this.similarity,
    required this.confidence,
  });
}
