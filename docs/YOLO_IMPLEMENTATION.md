# YOLO Implementation Guide

## Overview
Implementasi YOLO (You Only Look Once) untuk deteksi produk real-time dalam aplikasi POS. Sistem ini menggunakan TFLite untuk inferensi on-device dengan performa optimal.

## Architecture

### 1. YOLODetector (`lib/core/ai/yolo_detector.dart`)
- **Fungsi**: Service utama untuk deteksi objek menggunakan YOLO
- **Input**: Uint8List image bytes
- **Output**: List<YOLODetection> dengan bounding boxes dan confidence scores
- **Features**:
  - Preprocessing image ke 640x640
  - Postprocessing dengan NMS (Non-Maximum Suppression)
  - IoU calculation untuk filtering deteksi overlap
  - Support untuk COCO dataset (80 classes)

### 2. YOLODetection Model
```dart
class YOLODetection {
  final double x, y, width, height;  // Normalized coordinates
  final double confidence;
  final int classId;
  final String className;
}
```

### 3. AIScanController Integration
- **Camera Integration**: Capture image dari camera
- **YOLO Processing**: Kirim image ke YOLODetector
- **Product Mapping**: Convert YOLO detections ke product predictions
- **UI State Management**: Handle camera, processing, results states

### 4. UI Components
- **Camera Preview**: Real-time camera feed
- **Bounding Box Overlay**: Visualisasi deteksi dengan CustomPainter
- **Results View**: List deteksi dengan confidence scores
- **Model Download**: UI untuk download model dari manifest URL

## Model Requirements

### YOLO Model Format
- **Format**: TFLite (.tflite)
- **Input Size**: 640x640x3 (RGB)
- **Output**: [1, 25200, 85] tensor
  - 25200: anchor boxes
  - 85: [x, y, w, h, confidence, class_probabilities...]

### Labels File
- **Format**: Text file dengan satu class per line
- **Default**: COCO dataset (80 classes)
- **Custom**: Bisa disesuaikan dengan produk spesifik

## Model Manifest
```json
{
  "version": "1.0.0",
  "model_url": "https://example.com/yolo_model.tflite",
  "labels_url": "https://example.com/labels.txt",
  "description": "YOLO model for product detection",
  "input_size": 640,
  "num_classes": 80,
  "confidence_threshold": 0.5,
  "nms_threshold": 0.4
}
```

## Usage Flow

### 1. Model Download
```dart
// Download model dari manifest URL
await controller.downloadModel('https://example.com/manifest.json');
```

### 2. Camera Detection
```dart
// Capture dan process image
await controller.captureAndAnalyze();

// Deteksi otomatis ditampilkan di camera preview
// Bounding boxes muncul real-time
```

### 3. Product Selection
```dart
// User pilih deteksi yang benar
controller.selectPrediction(productId);
controller.confirmSelection();
```

## Configuration

### Thresholds
- **Confidence Threshold**: 0.5 (default)
- **NMS Threshold**: 0.4 (default)
- **Input Size**: 640x640

### Performance Optimization
- **Model**: Gunakan quantized model (int8/float16)
- **Delegate**: NNAPI (Android) / Metal (iOS)
- **Batch Size**: 1 (real-time inference)

## Product Mapping

### Default COCO Classes
Sistem mapping otomatis dari COCO classes ke produk:
- `bottle` → Botol Minuman
- `cup` → Gelas
- `bowl` → Mangkuk
- `banana` → Pisang
- `apple` → Apel
- `book` → Buku
- `laptop` → Laptop
- `cell phone` → Handphone

### Custom Product Mapping
```dart
Map<String, dynamic> _mapClassToProduct(String className) {
  // Custom mapping logic
  return productMap[className.toLowerCase()] ?? defaultProduct;
}
```

## Training Data Collection

### Automatic Collection
- Deteksi dengan confidence rendah → prompt user untuk label
- User input label → save sebagai training sample
- Sync ke server untuk model retraining

### Manual Collection
- User bisa manual add training sample
- Image + label disimpan di `ai_training_samples` table
- Batch upload ke server

## Error Handling

### Model Loading
- Check model file existence
- Validate TFLite model format
- Handle initialization errors

### Detection Errors
- Image preprocessing failures
- Inference errors
- Postprocessing errors

### Network Issues
- Model download failures
- Manifest parsing errors
- Retry mechanisms

## Testing

### Unit Tests
- YOLODetector initialization
- Image preprocessing
- NMS algorithm
- Product mapping

### Integration Tests
- Camera integration
- Model download flow
- UI state management
- Error scenarios

## Performance Monitoring

### Metrics
- Inference time
- Memory usage
- Detection accuracy
- User feedback

### Optimization
- Model quantization
- Input resolution
- Batch processing
- Caching strategies

## Future Enhancements

### Model Improvements
- Custom YOLO training untuk produk spesifik
- Multi-class detection
- Real-time model updates

### UI Enhancements
- 3D bounding boxes
- AR overlay
- Voice commands
- Gesture recognition

### Integration
- Barcode scanner fallback
- Inventory management
- Analytics dashboard
- Cloud sync

## Troubleshooting

### Common Issues
1. **Model not loading**: Check file paths dan permissions
2. **Low detection accuracy**: Adjust confidence thresholds
3. **Slow inference**: Use quantized model atau smaller input size
4. **Memory issues**: Implement model caching dan cleanup

### Debug Tools
- Log inference times
- Visualize detection results
- Monitor memory usage
- Track user interactions
