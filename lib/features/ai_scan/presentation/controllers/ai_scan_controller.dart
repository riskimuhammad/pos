import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:pos/core/ai/model_manager.dart';
import 'package:pos/core/ai/ai_data_service.dart';
// YOLO removed
import 'package:pos/core/ai/local_product_detector.dart';


class AIScanController extends GetxController {
  late final AIModelManager modelManager;
  late final AIDataService aiDataService;
  late final LocalProductDetector localDetector;
  
  // Camera related
  final RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final RxBool isCameraInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  
  // ML related
  final RxBool isModelLoaded = false.obs;
  final RxBool isProcessing = false.obs;
  
  // Results: local-only predictions list
  final RxList<AIProductPrediction> predictions = <AIProductPrediction>[].obs;
  final RxString selectedProductId = ''.obs;
  final RxBool showResults = false.obs;
  final RxString lastImagePath = ''.obs;
  
  // UI state
  final RxString currentStep = 'camera'.obs; // camera, processing, results
  final RxString errorMessage = ''.obs;
  final RxString capturedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize dependencies
    modelManager = Get.find<AIModelManager>();
    aiDataService = Get.find<AIDataService>();
    localDetector = Get.find<LocalProductDetector>();
    
    _initializeCamera();
    _loadMLModel();
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    super.onClose();
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    try {
      cameras.value = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController.value = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await cameraController.value!.initialize();
        isCameraInitialized.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Failed to initialize camera: $e';
    }
  }

  // Load ML model (disabled in local-only mode)
  Future<void> _loadMLModel() async {
    try {
      isModelLoaded.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to load ML model: $e';
    }
  }

  // Capture image and run inference
  Future<void> captureAndAnalyze() async {
    if (!isCameraInitialized.value) {
      Get.snackbar('Error', 'Camera not ready');
      return;
    }

    try {
      isCapturing.value = true;
      currentStep.value = 'processing';
      
      // Capture image
      final XFile image = await cameraController.value!.takePicture();
      final File imageFile = File(image.path);
      lastImagePath.value = imageFile.path;
      capturedImagePath.value = imageFile.path;
      
      // Process image
      await _processImage(imageFile);
      
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
      isCapturing.value = false;
      currentStep.value = 'camera';
    }
  }

  // Process captured image
  Future<void> _processImage(File imageFile) async {
    try {
      isProcessing.value = true;
      
      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Local-first: always try local detection first
      await _tryLocalDetection(imageBytes);
      if (predictions.isNotEmpty) {
        return;
      }

      // If still empty, move to add_training
      currentStep.value = 'add_training';
      
    } catch (e) {
      errorMessage.value = 'Failed to process image: $e';
      currentStep.value = 'camera';
    } finally {
      isProcessing.value = false;
      isCapturing.value = false;
    }
  }

  // Try local product detection as fallback
  Future<void> _tryLocalDetection(Uint8List imageBytes) async {
    try {
      // Extract features from image
      final features = await localDetector.extractFeatures(imageBytes);
      
      // Find similar products in local database
      final matches = await localDetector.findSimilarProducts(features);
      
      if (matches.isNotEmpty) {
        // Convert matches to predictions
        final localPredictions = matches.map((match) => AIProductPrediction(
          productId: match.product.id,
          productName: match.product.name,
          confidence: match.confidence,
          category: match.product.category,
          price: match.product.price,
        )).toList();
        
        predictions.assignAll(localPredictions);
        currentStep.value = 'results';
        showResults.value = true;
      } else {
        // No similar products found, show add training data option
        currentStep.value = 'add_training';
      }
      
    } catch (e) {
      print('Error with local detection: $e');
      // Show add training data option as last resort
      currentStep.value = 'add_training';
    }
  }

  // YOLO conversion removed in local-only mode
  
  // Map YOLO class names to product information
  Map<String, dynamic> _mapClassToProduct(String className) {
    // Indonesian product mapping - includes both COCO and custom labels
    final productMap = {
      // COCO classes
      'bottle': {'id': 'bottle_001', 'name': 'Botol Minuman', 'category': 'Minuman', 'price': 15000.0},
      'cup': {'id': 'cup_001', 'name': 'Gelas', 'category': 'Perlengkapan', 'price': 8000.0},
      'bowl': {'id': 'bowl_001', 'name': 'Mangkuk', 'category': 'Perlengkapan', 'price': 12000.0},
      'banana': {'id': 'banana_001', 'name': 'Pisang', 'category': 'Buah', 'price': 5000.0},
      'apple': {'id': 'apple_001', 'name': 'Apel', 'category': 'Buah', 'price': 8000.0},
      'orange': {'id': 'orange_001', 'name': 'Jeruk', 'category': 'Buah', 'price': 6000.0},
      'book': {'id': 'book_001', 'name': 'Buku', 'category': 'Alat Tulis', 'price': 25000.0},
      'laptop': {'id': 'laptop_001', 'name': 'Laptop', 'category': 'Elektronik', 'price': 5000000.0},
      'cell phone': {'id': 'phone_001', 'name': 'Handphone', 'category': 'Elektronik', 'price': 2000000.0},
      
      // Custom Indonesian products
      'kopi_abc': {'id': 'kopi_abc_001', 'name': 'Kopi ABC', 'category': 'Minuman', 'price': 2500.0},
      'kopi_instan': {'id': 'kopi_instan_001', 'name': 'Kopi Instan', 'category': 'Minuman', 'price': 3000.0},
      'teh_botol': {'id': 'teh_botol_001', 'name': 'Teh Botol', 'category': 'Minuman', 'price': 4000.0},
      'air_mineral': {'id': 'air_mineral_001', 'name': 'Air Mineral', 'category': 'Minuman', 'price': 2000.0},
      'jus_kemasan': {'id': 'jus_kemasan_001', 'name': 'Jus Kemasan', 'category': 'Minuman', 'price': 5000.0},
      'susu_kemasan': {'id': 'susu_kemasan_001', 'name': 'Susu Kemasan', 'category': 'Minuman', 'price': 6000.0},
      'biskuit': {'id': 'biskuit_001', 'name': 'Biskuit', 'category': 'Snack', 'price': 8000.0},
      'keripik': {'id': 'keripik_001', 'name': 'Keripik', 'category': 'Snack', 'price': 7000.0},
      'mie_instan': {'id': 'mie_instan_001', 'name': 'Mie Instan', 'category': 'Makanan', 'price': 3500.0},
      'sambal_botol': {'id': 'sambal_botol_001', 'name': 'Sambal Botol', 'category': 'Bumbu', 'price': 12000.0},
      'kecap': {'id': 'kecap_001', 'name': 'Kecap', 'category': 'Bumbu', 'price': 8000.0},
      'minyak_goreng': {'id': 'minyak_goreng_001', 'name': 'Minyak Goreng', 'category': 'Bumbu', 'price': 15000.0},
      'beras': {'id': 'beras_001', 'name': 'Beras', 'category': 'Sembako', 'price': 12000.0},
      'gula': {'id': 'gula_001', 'name': 'Gula', 'category': 'Sembako', 'price': 10000.0},
      'garam': {'id': 'garam_001', 'name': 'Garam', 'category': 'Sembako', 'price': 3000.0},
      'telur': {'id': 'telur_001', 'name': 'Telur', 'category': 'Sembako', 'price': 25000.0},
      'roti': {'id': 'roti_001', 'name': 'Roti', 'category': 'Makanan', 'price': 5000.0},
      'kue_kering': {'id': 'kue_kering_001', 'name': 'Kue Kering', 'category': 'Makanan', 'price': 15000.0},
      'permen': {'id': 'permen_001', 'name': 'Permen', 'category': 'Snack', 'price': 2000.0},
      'coklat': {'id': 'coklat_001', 'name': 'Coklat', 'category': 'Snack', 'price': 10000.0},
      'snack': {'id': 'snack_001', 'name': 'Snack', 'category': 'Snack', 'price': 5000.0},
      'minuman_energi': {'id': 'minuman_energi_001', 'name': 'Minuman Energi', 'category': 'Minuman', 'price': 8000.0},
      'soda': {'id': 'soda_001', 'name': 'Soda', 'category': 'Minuman', 'price': 6000.0},
      'bir': {'id': 'bir_001', 'name': 'Bir', 'category': 'Minuman', 'price': 15000.0},
      'rokok': {'id': 'rokok_001', 'name': 'Rokok', 'category': 'Tembakau', 'price': 20000.0},
      'shampoo': {'id': 'shampoo_001', 'name': 'Shampoo', 'category': 'Kecantikan', 'price': 25000.0},
      'sabun': {'id': 'sabun_001', 'name': 'Sabun', 'category': 'Kecantikan', 'price': 8000.0},
      'pasta_gigi': {'id': 'pasta_gigi_001', 'name': 'Pasta Gigi', 'category': 'Kecantikan', 'price': 12000.0},
      'detergen': {'id': 'detergen_001', 'name': 'Detergen', 'category': 'Pembersih', 'price': 15000.0},
      'tissue': {'id': 'tissue_001', 'name': 'Tissue', 'category': 'Pembersih', 'price': 8000.0},
    };
    
    return productMap[className.toLowerCase()] ?? {
      'id': 'unknown_${className.toLowerCase()}',
      'name': className,
      'category': 'Unknown',
      'price': 0.0,
    };
  }

  // Select a prediction
  void selectPrediction(String productId) {
    selectedProductId.value = productId;
    
    // Save user feedback for learning
    if (capturedImagePath.value.isNotEmpty) {
      final selectedPrediction = predictions.firstWhere(
        (p) => p.productId == productId,
        orElse: () => predictions.first,
      );
      
      saveUserFeedback(
        imagePath: capturedImagePath.value,
        selectedProductId: productId,
        confidence: selectedPrediction.confidence,
      );
    }
  }

  // Confirm selection and add to cart
  void confirmSelection() {
    if (selectedProductId.value.isNotEmpty) {
      final selectedPrediction = predictions.firstWhere(
        (p) => p.productId == selectedProductId.value,
      );
      
      // TODO: Add product to cart
      Get.snackbar(
        'Success',
        'Product "${selectedPrediction.productName}" added to cart',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Save scan result
      aiDataService.saveScanResult(
        imagePath: lastImagePath.value,
        predictedLabel: selectedPrediction.productName,
        confidence: selectedPrediction.confidence,
        chosenProductLabel: selectedPrediction.productName,
      );

      // Reset and go back to camera
      _resetScan();
    }
  }

  Future<void> saveLabeledSample(String label) async {
    if (lastImagePath.value.isEmpty) {
      Get.snackbar('AI Data', 'No image to label');
      return;
    }
    await aiDataService.saveTrainingSample(
      imagePath: lastImagePath.value,
      label: label,
    );
    Get.snackbar('AI Data', 'Labeled sample saved: $label');
  }

  // YOLO download disabled in local-only mode

  // Direct download without manifest (raw URLs)
  // YOLO direct download disabled in local-only mode

  // Manual search fallback
  void manualSearch() {
    // TODO: Navigate to manual product search
    Get.snackbar('Manual Search', 'Navigate to product search');
    _resetScan();
  }

  // Retake photo
  void retakePhoto() {
    _resetScan();
  }

  // Reset scan state
  void _resetScan() {
    predictions.clear();
    selectedProductId.value = '';
    showResults.value = false;
    currentStep.value = 'camera';
    errorMessage.value = '';
  }

  // Send feedback for model improvement
  void sendFeedback(String productId, bool isCorrect) {
    // TODO: Send feedback to server for model retraining
    Get.snackbar(
      'Feedback Sent',
      'Thank you for your feedback!',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Add training data when no product is detected
  Future<void> addTrainingData(String imagePath, String label) async {
    try {
      // For now, just show success message
      // TODO: Implement proper training data storage
      Get.snackbar('Success', 'Training data added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add training data: $e');
    }
  }

  // Save user feedback for learning
  Future<void> saveUserFeedback({
    required String imagePath,
    required String selectedProductId,
    required double confidence,
  }) async {
    try {
      await localDetector.saveUserFeedback(
        imagePath: imagePath,
        selectedProductId: selectedProductId,
        confidence: confidence,
      );
      print('User feedback saved successfully');
    } catch (e) {
      print('Failed to save user feedback: $e');
    }
  }

  // Check if high confidence prediction
  bool get hasHighConfidence => 
      predictions.isNotEmpty && predictions.first.confidence > 0.9;

  // Get top prediction
  AIProductPrediction? get topPrediction => 
      predictions.isNotEmpty ? predictions.first : null;
}

// AI Product Prediction model
class AIProductPrediction {
  final String productId;
  final String productName;
  final double confidence;
  final String category;
  final double price;

  AIProductPrediction({
    required this.productId,
    required this.productName,
    required this.confidence,
    required this.category,
    required this.price,
  });

  String get confidencePercentage => '${(confidence * 100).toInt()}%';
}
