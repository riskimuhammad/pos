# Setup Model Kaggle untuk AI Scan

## Overview
Panduan untuk mengintegrasikan model custom dari Kaggle ke sistem AI Scan POS.

## Prerequisites
1. Akun Kaggle dengan API key
2. Model yang sudah di-upload ke Kaggle (contoh: `riskimhd/kopi-abc`)

## Setup Kaggle API

### 1. Install Kaggle CLI
```bash
pip install kaggle
```

### 2. Setup Credentials
```bash
# Set environment variables
export KAGGLE_USERNAME=your_username
export KAGGLE_KEY=your_api_key

# Or create ~/.kaggle/kaggle.json
{
  "username": "your_username",
  "key": "your_api_key"
}
```

## Download Model

### Method 1: Using Script
```bash
# Set credentials
export KAGGLE_USERNAME=your_username
export KAGGLE_KEY=your_api_key

# Run download script
./scripts/download_kaggle_model.sh
```

### Method 2: Manual Download
```bash
# Download model
curl -L -u $KAGGLE_USERNAME:$KAGGLE_KEY \
  -o ~/Downloads/model.tar.gz \
  https://www.kaggle.com/api/v1/models/riskimhd/kopi-abc/tensorFlow2/default/1/download

# Extract to assets/models/
cd assets/models
tar -xzf ~/Downloads/model.tar.gz
```

## Model Format Requirements

### TFLite Model
- Format: `.tflite`
- Input: 640x640x3 (RGB)
- Output: Detection tensor sesuai format YOLO

### Labels File
- Format: `.txt`
- Satu label per baris
- Contoh:
```
kopi_abc
kopi_instan
teh_botol
air_mineral
```

## Integration Steps

### 1. Update Model Manager
Model manager sudah mendukung download dari URL langsung:
```dart
await controller.downloadModelDirect(
  modelUrl: 'https://your-server.com/custom_model.tflite',
  labelsUrl: 'https://your-server.com/custom_labels.txt',
);
```

### 2. Update Product Mapping
Product mapping sudah diperluas untuk produk Indonesia:
- Kopi ABC, Kopi Instan
- Teh Botol, Air Mineral
- Mie Instan, Biskuit
- Dan 50+ produk lainnya

### 3. Test Model
1. Upload model ke server/CDN
2. Buka AI Scan → Download Model
3. Pilih "Direct URLs"
4. Masukkan URL model dan labels
5. Test deteksi produk

## Model Deployment Options

### Option 1: GitHub Releases
```bash
# Upload model to GitHub releases
gh release create v1.0.0 assets/models/custom_model.tflite assets/models/custom_labels.txt
```

### Option 2: Cloud Storage
- Google Drive (public link)
- Dropbox (public link)
- AWS S3 (public bucket)
- Firebase Storage

### Option 3: Custom Server
```json
{
  "version": "1.0.0",
  "model_url": "https://your-server.com/models/custom_model.tflite",
  "labels_url": "https://your-server.com/models/custom_labels.txt",
  "description": "Custom Indonesian product detection model"
}
```

## Testing Workflow

### 1. Local Testing
```bash
# Test model locally
flutter run
# Navigate to AI Scan
# Download model using direct URLs
# Test detection with Indonesian products
```

### 2. Production Testing
1. Deploy model to production server
2. Update manifest URL
3. Test download from app
4. Verify detection accuracy
5. Monitor performance

## Model Performance

### Expected Metrics
- **Inference Time**: < 100ms (mobile)
- **Model Size**: < 50MB
- **Accuracy**: > 85% (custom products)
- **Confidence Threshold**: 0.5

### Optimization Tips
1. **Quantization**: Use int8 quantization
2. **Pruning**: Remove unused layers
3. **Input Size**: Optimize for 640x640
4. **Batch Size**: Use batch size 1 for real-time

## Troubleshooting

### Common Issues

#### Model Not Loading
```bash
# Check model format
file assets/models/custom_model.tflite
# Should show: TFLite model
```

#### Labels Not Found
```bash
# Check labels file
cat assets/models/custom_labels.txt
# Should show one label per line
```

#### Detection Errors
- Verify input size (640x640)
- Check confidence threshold
- Validate label mapping

### Debug Commands
```bash
# Check model info
python -c "
import tensorflow as tf
interpreter = tf.lite.Interpreter('assets/models/custom_model.tflite')
interpreter.allocate_tensors()
print('Input:', interpreter.get_input_details())
print('Output:', interpreter.get_output_details())
"
```

## Next Steps

### Model Improvement
1. **Data Collection**: Gather more Indonesian product images
2. **Training**: Retrain with custom dataset
3. **Validation**: Test with real POS scenarios
4. **Deployment**: Roll out to production

### Integration
1. **API Sync**: Enable sync to backend
2. **Analytics**: Track detection accuracy
3. **Feedback Loop**: Collect user corrections
4. **Auto Updates**: Implement model versioning

## References
- [Kaggle API Documentation](https://www.kaggle.com/docs/api)
- [TFLite Model Optimization](https://www.tensorflow.org/lite/performance/model_optimization)
- [YOLO Custom Training](https://docs.ultralytics.com/modes/train/)
