# Barcode Search Debug Guide

## 🔍 Problem
User reported that products with QR codes are not found during barcode search, even though the products exist in the list.

## 🛠️ Debugging Steps

### 1. **Enhanced Barcode Search Logic**
- **File**: `lib/features/products/presentation/controllers/product_controller.dart`
- **Method**: `searchByBarcode()`
- **Improvements**:
  - Added detailed debug logging
  - Shows total products loaded
  - Lists all products with barcodes
  - Displays barcode values and hasBarcode flags

### 2. **Improved Barcode Matching**
- **File**: `lib/features/products/presentation/controllers/product_controller.dart`
- **Method**: `getProductByBarcode()`
- **Improvements**:
  - Trims whitespace from input barcode
  - Trims whitespace from stored barcodes
  - Falls back to case-insensitive matching
  - Better error handling

### 3. **Debug Tools Added**
- **Debug Method**: `debugBarcodeInfo()`
  - Prints all products with barcodes
  - Shows barcode values, lengths, and types
  - Displays hasBarcode flags
- **Debug Menu**: Added "Debug Barcode" option in ProductsPage menu
  - Accessible via three-dot menu
  - Prints debug info to console

## 🔧 How to Debug

### Step 1: Use Debug Menu
1. Go to Products page
2. Tap three-dot menu (⋮) in top-right
3. Select "Debug Barcode"
4. Check console output for barcode information

### Step 2: Test Barcode Search
1. Scan or manually enter a barcode
2. Check console for debug output:
   ```
   🔍 Searching for barcode: "123456789"
   📦 Total products loaded: 25
   🏷️ Products with barcodes: 5
     - Indomie Goreng: "123456789" (hasBarcode: true)
     - Kopi ABC: "987654321" (hasBarcode: true)
   ```

### Step 3: Check Common Issues
- **Whitespace**: Barcode might have leading/trailing spaces
- **Case Sensitivity**: Barcode might be stored in different case
- **Null Values**: Product might have `barcode: null` or empty string
- **hasBarcode Flag**: Product might have barcode but `hasBarcode: false`

## 🐛 Common Issues & Solutions

### Issue 1: Barcode Not Found
**Symptoms**: Product exists but barcode search returns "Not Found"
**Debug Steps**:
1. Check if product has `hasBarcode: true`
2. Verify barcode value is not null/empty
3. Check for whitespace differences
4. Verify case sensitivity

### Issue 2: FTS Search Error
**Symptoms**: "no such column fts" error
**Solution**: 
- FTS search now has fallback to regular LIKE search
- FTS table is auto-populated on app start
- Error handling prevents crashes

### Issue 3: Data Loading Issues
**Symptoms**: No products loaded or barcode data missing
**Debug Steps**:
1. Check if products are loaded: `📦 Total products loaded: X`
2. Check if any products have barcodes: `🏷️ Products with barcodes: X`
3. Verify database seeding completed successfully

## 📊 Debug Output Example

```
🔍 Searching for barcode: "123456789"
📦 Total products loaded: 25
🏷️ Products with barcodes: 5
  - Indomie Goreng Rendang: "123456789" (hasBarcode: true)
  - Kopi ABC Sachet: "987654321" (hasBarcode: true)
  - Teh Botol Sosro: "456789123" (hasBarcode: true)
  - Aqua 600ml: "789123456" (hasBarcode: true)
  - Biskuit Roma: "321654987" (hasBarcode: true)
✅ Product found: Indomie Goreng Rendang
```

## 🎯 Next Steps

1. **Test the debug tools** to identify the specific issue
2. **Check console output** when scanning barcodes
3. **Verify product data** using the debug menu
4. **Report findings** with specific barcode values and product names

## 🔄 Temporary Debug Features

**Note**: The debug logging and menu option are temporary for troubleshooting. They should be removed once the issue is resolved.

- `searchByBarcode()` debug logging
- `debugBarcodeInfo()` method
- "Debug Barcode" menu option
- Enhanced error messages

## 📝 Files Modified

1. `lib/features/products/presentation/controllers/product_controller.dart`
   - Enhanced `searchByBarcode()`
   - Improved `getProductByBarcode()`
   - Added `debugBarcodeInfo()`

2. `lib/features/products/presentation/pages/products_page.dart`
   - Added debug menu option
   - Added debug handler

3. `lib/core/storage/local_datasource.dart`
   - Added FTS fallback in `searchProducts()`

4. `lib/core/storage/database_helper.dart`
   - Enhanced FTS table creation
   - Added `populateFtsTable()` method

5. `lib/core/sync/product_sync_service.dart`
   - Auto-populate FTS table on data load

