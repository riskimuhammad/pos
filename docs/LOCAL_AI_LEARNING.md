# Local AI Learning System

## Overview

Sistem AI Learning lokal memungkinkan aplikasi POS untuk belajar dari input user tanpa bergantung pada model eksternal. Sistem ini menggunakan pendekatan hybrid yang menggabungkan:

1. **YOLO Detection** (jika tersedia) - untuk deteksi objek umum
2. **Local Product Matching** - untuk mencocokkan dengan database produk lokal
3. **User Feedback Learning** - untuk meningkatkan akurasi dari waktu ke waktu

## Arsitektur

### 1. LocalProductDetector
- **Extract Features**: Ekstrak fitur visual dari gambar (histogram warna, dominant colors, texture)
- **Similarity Matching**: Bandingkan dengan database produk lokal
- **Learning Storage**: Simpan feedback user untuk pembelajaran

### 2. Feature Extraction
```dart
// Color Histogram - distribusi warna dalam gambar
List<double> _extractColorHistogram(img.Image image)

// Dominant Colors - warna dominan dalam gambar  
List<Map<String, int>> _extractDominantColors(img.Image image)

// Texture Features - fitur tekstur (edge density)
List<double> _extractTextureFeatures(img.Image image)

// Image Hash - hash unik untuk identifikasi cepat
String _calculateImageHash(img.Image image)
```

### 3. Similarity Calculation
```dart
// Kombinasi similarity dari berbagai fitur
double _calculateSimilarity(features1, features2) {
  - Color Histogram Similarity (40%)
  - Dominant Colors Similarity (30%) 
  - Image Hash Similarity (30%)
}
```

## Database Schema

### ai_learning_samples
```sql
CREATE TABLE ai_learning_samples (
  id TEXT PRIMARY KEY,
  image_path TEXT NOT NULL,
  product_id TEXT NOT NULL,
  features TEXT,              -- JSON string fitur visual
  confidence REAL,            -- Confidence score
  timestamp INTEGER NOT NULL,
  sync_status TEXT DEFAULT 'pending',
  error_message TEXT,
  FOREIGN KEY (product_id) REFERENCES products (id)
);
```

## Flow Detection

### 1. Primary Flow (YOLO Available)
```
Camera Capture → YOLO Detection → Product Mapping → Results
                     ↓ (no results)
                Local Detection → Similarity Matching → Results
                     ↓ (no matches)
                Add Training Data
```

### 2. Fallback Flow (YOLO Not Available)
```
Camera Capture → Local Detection → Similarity Matching → Results
                     ↓ (no matches)
                Add Training Data
```

### 3. Learning Flow
```
User Selects Product → Save Feedback → Extract Features → Store Learning Sample
```

## Implementation Details

### Feature Extraction Process
1. **Resize Image**: Standardisasi ke 224x224 pixels
2. **Color Analysis**: Hitung histogram dan warna dominan
3. **Texture Analysis**: Analisis edge density untuk tekstur
4. **Hash Generation**: Buat hash unik untuk identifikasi cepat

### Similarity Matching
1. **Feature Comparison**: Bandingkan fitur dengan database produk
2. **Threshold Filtering**: Hanya ambil similarity > 0.6
3. **Top-N Results**: Return top 5 matches terbaik
4. **Confidence Scoring**: Hitung confidence berdasarkan similarity

### Learning Mechanism
1. **User Feedback**: Simpan pilihan user saat memilih produk
2. **Feature Storage**: Simpan fitur visual dari gambar input
3. **Incremental Learning**: Update model lokal dengan feedback
4. **Sync Preparation**: Siapkan data untuk sync ke cloud (opsional)

## Configuration

### Thresholds
```dart
const double SIMILARITY_THRESHOLD = 0.6;  // Minimum similarity untuk match
const int TOP_N_RESULTS = 5;              // Jumlah hasil terbaik
const int FEATURE_WEIGHT_COLOR = 40;      // Bobot fitur warna (%)
const int FEATURE_WEIGHT_DOMINANT = 30;   // Bobot warna dominan (%)
const int FEATURE_WEIGHT_HASH = 30;       // Bobot image hash (%)
```

### Performance Optimization
- **Sampling**: Sample setiap 10th pixel untuk performance
- **Caching**: Cache fitur yang sudah diekstrak
- **Async Processing**: Proses fitur extraction secara async
- **Memory Management**: Cleanup gambar setelah processing

## Usage Examples

### 1. Basic Detection
```dart
final detector = Get.find<LocalProductDetector>();
final features = await detector.extractFeatures(imageBytes);
final matches = await detector.findSimilarProducts(features);
```

### 2. Save User Feedback
```dart
await detector.saveUserFeedback(
  imagePath: '/path/to/image.jpg',
  selectedProductId: 'product_123',
  confidence: 0.85,
);
```

### 3. Controller Integration
```dart
// AIScanController
if (predictions.isEmpty) {
  await _tryLocalDetection(imageBytes);
}

// Save feedback saat user pilih produk
void selectPrediction(String productId) {
  selectedProductId.value = productId;
  saveUserFeedback(/* ... */);
}
```

## Benefits

### 1. **Offline Capability**
- Tidak memerlukan koneksi internet
- Bekerja dengan database lokal
- Fast response time

### 2. **Learning from Usage**
- Meningkat akurasi dari waktu ke waktu
- Belajar dari preferensi user
- Adaptif dengan produk lokal

### 3. **Fallback Strategy**
- YOLO sebagai primary detection
- Local matching sebagai fallback
- Training data collection sebagai last resort

### 4. **Data Privacy**
- Semua data tetap lokal
- User control penuh atas data
- Optional sync ke cloud

## Future Enhancements

### 1. **Advanced Features**
- Deep learning features (CNN embeddings)
- Multi-scale feature extraction
- Temporal learning (sequence of scans)

### 2. **Performance**
- GPU acceleration untuk feature extraction
- Parallel processing untuk multiple images
- Smart caching dengan LRU eviction

### 3. **Learning**
- Online learning dengan incremental updates
- Active learning untuk sample selection
- Transfer learning dari pre-trained models

### 4. **Integration**
- Real-time learning dari POS transactions
- Integration dengan inventory management
- Analytics dashboard untuk learning progress
