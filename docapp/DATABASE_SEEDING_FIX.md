# Database Seeding Fix - POS UMKM

## Problem Description

Database seeding gagal dengan error:
```
DatabaseException(java.lang.String cannot be cast to java.lang.Integer)
```

Error ini terjadi karena ada ketidakcocokan tipe data saat insert ke database SQLite.

## Root Causes

### 1. Foreign Key Constraint Error
- **Problem**: Tabel `categories` mencoba mereferensikan `tenant_id` ke tabel `tenants`, tetapi data tenant belum ada
- **Error**: `FOREIGN KEY constraint failed (code 787)`

### 2. Data Type Mismatch Error  
- **Problem**: Field `photos` (array) dan `attributes` (object) dikirim sebagai tipe kompleks, tetapi SQLite mengharapkan string
- **Error**: `java.lang.String cannot be cast to java.lang.Integer`

## Solutions Implemented

### 1. Fix Foreign Key Constraints

#### Added Tenant and Location Seeding
```dart
/// Seed tenant and location (required for foreign keys)
Future<void> _seedTenantAndLocation() async {
  final db = await _databaseHelper.database;
  
  // Check if tenant already exists
  final existingTenant = await db.query(
    'tenants',
    where: 'id = ?',
    whereArgs: ['default-tenant-id'],
  );
  
  if (existingTenant.isEmpty) {
    // Create default tenant
    final tenant = Tenant(
      id: 'default-tenant-id',
      name: 'Warung UMKM Demo',
      ownerName: 'Demo Owner',
      email: 'demo@warung.com',
      phone: '+6281234567890',
      address: 'Jl. Demo No. 123, Jakarta',
      subscriptionTier: 'free',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      syncStatus: 'synced',
      lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    
    await db.insert('tenants', tenant.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    print('🏢 Seeded default tenant');
  }
  
  // Check if location already exists
  final existingLocation = await db.query(
    'locations',
    where: 'id = ?',
    whereArgs: ['default-location-id'],
  );
  
  if (existingLocation.isEmpty) {
    // Create default location
    final location = Location(
      id: 'default-location-id',
      tenantId: 'default-tenant-id',
      name: 'Toko Utama',
      type: 'store',
      address: 'Jl. Demo No. 123, Jakarta',
      isPrimary: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      syncStatus: 'synced',
      lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    
    await db.insert('locations', location.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    print('📍 Seeded default location');
  }
}
```

#### Updated Seeding Order
```dart
Future<void> seedDatabase() async {
  try {
    print('🌱 Starting database seeding...');
    
    // Seed tenant and location first (required for foreign keys)
    await _seedTenantAndLocation();
    
    // Seed categories
    await _seedCategories();
    
    // Seed products
    await _seedProducts();
    
    // Seed stock movements
    await _seedStockMovements();
    
    print('✅ Database seeding completed successfully!');
  } catch (e) {
    print('❌ Database seeding failed: $e');
    rethrow;
  }
}
```

### 2. Fix Data Type Serialization

#### Updated Product Entity toJson()
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'tenant_id': tenantId,
    'sku': sku,
    'name': name,
    'category_id': categoryId,
    'description': description,
    'unit': unit,
    'price_buy': priceBuy,
    'price_sell': priceSell,
    'weight': weight,
    'has_barcode': hasBarcode ? 1 : 0,
    'barcode': barcode,
    'is_expirable': isExpirable ? 1 : 0,
    'is_active': isActive ? 1 : 0,
    'min_stock': minStock,
    'photos': jsonEncode(photos),        // Serialize array to JSON string
    'attributes': jsonEncode(attributes), // Serialize object to JSON string
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
    'deleted_at': deletedAt?.millisecondsSinceEpoch,
    'sync_status': syncStatus,
    'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
  };
}
```

#### Updated Product Entity fromJson()
```dart
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    // ... other fields
    photos: json['photos'] != null
        ? (json['photos'] is String 
            ? List<String>.from(jsonDecode(json['photos'] as String))
            : List<String>.from(json['photos'] as List))
        : [],
    attributes: json['attributes'] != null
        ? (json['attributes'] is String
            ? Map<String, dynamic>.from(jsonDecode(json['attributes'] as String))
            : Map<String, dynamic>.from(json['attributes'] as Map))
        : {},
    // ... other fields
  );
}
```

### 3. Added Conflict Resolution

#### Used ConflictAlgorithm.replace
```dart
// For all insert operations
await db.insert('tenants', tenant.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
await db.insert('locations', location.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
await db.insert('categories', category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
await db.insert('products', product.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
await db.insert('stock_movements', stockMovement.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
```

### 4. Enhanced StockMovement Entity

#### Added costPrice Field
```dart
class StockMovement extends Equatable {
  final String id;
  final String tenantId;
  final String productId;
  final String locationId;
  final StockMovementType type;
  final int quantity;
  final double? costPrice;  // Added this field
  final String? referenceType;
  // ... other fields
}
```

#### Updated Constructor and Methods
```dart
const StockMovement({
  required this.id,
  required this.tenantId,
  required this.productId,
  required this.locationId,
  required this.type,
  required this.quantity,
  this.costPrice,  // Added parameter
  this.referenceType,
  // ... other parameters
});

// Updated fromJson
factory StockMovement.fromJson(Map<String, dynamic> json) {
  return StockMovement(
    // ... other fields
    quantity: json['quantity'] as int,
    costPrice: (json['cost_price'] as num?)?.toDouble(),  // Added parsing
    referenceType: json['reference_type'] as String?,
    // ... other fields
  );
}

// Updated toJson
Map<String, dynamic> toJson() {
  return {
    // ... other fields
    'quantity': quantity,
    'cost_price': costPrice,  // Added serialization
    'reference_type': referenceType,
    // ... other fields
  };
}
```

## Files Modified

1. **`lib/core/data/database_seeder.dart`**
   - Added `_seedTenantAndLocation()` method
   - Updated seeding order
   - Added `ConflictAlgorithm.replace` for all inserts
   - Enhanced `clearSeededData()` method

2. **`lib/shared/models/entities/product.dart`**
   - Added `dart:convert` import
   - Updated `toJson()` to serialize complex types
   - Updated `fromJson()` to deserialize complex types

3. **`lib/shared/models/entities/stock_movement.dart`**
   - Added `costPrice` field
   - Updated constructor, fromJson, toJson, and copyWith methods
   - Updated props list

## Testing

### Before Fix
```
❌ Database seeding failed: DatabaseException(FOREIGN KEY constraint failed (code 787))
❌ Database seeding failed: DatabaseException(java.lang.String cannot be cast to java.lang.Integer)
```

### After Fix
```
🌱 Starting database seeding...
🏢 Seeded default tenant
📍 Seeded default location
📁 Seeded 5 categories
📦 Seeded 10 products
📊 Seeded 10 stock movements
✅ Database seeding completed successfully!
```

## Key Learnings

1. **Foreign Key Dependencies**: Always seed parent tables before child tables
2. **Data Type Serialization**: Complex types (arrays, objects) must be serialized to strings for SQLite
3. **Conflict Resolution**: Use `ConflictAlgorithm.replace` to handle duplicate data gracefully
4. **Database Schema Evolution**: Add new fields to entities and update serialization methods

## Prevention

1. **Database Schema Validation**: Ensure all foreign key references exist before insert
2. **Type Safety**: Always validate data types before database operations
3. **Error Handling**: Implement proper error handling and logging for database operations
4. **Testing**: Test database seeding with various data scenarios

---

## Status: ✅ RESOLVED

Database seeding now works correctly with proper foreign key relationships and data type handling.
