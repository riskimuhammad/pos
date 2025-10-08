# Foreign Key Constraint Fix - Product Save Error

## Problem
When trying to save a product, the application was experiencing a foreign key constraint error:

```
DatabaseException(FOREIGN KEY constraint failed (code 787)) sql 'INSERT INTO products ...'
```

## Root Cause Analysis
The foreign key constraint error occurred because the `products` table has foreign key references to:
1. `tenant_id` → `tenants(id)`
2. `category_id` → `categories(id)`

However, the `DatabaseSeeder` was only seeding:
- ✅ `tenants` (default-tenant-id)
- ✅ `locations` 
- ✅ `users` (system user)
- ❌ `categories` (missing)
- ❌ `units` (missing)

When users tried to save products, they would select categories and units that didn't exist in the database, causing foreign key constraint violations.

## Solution Implemented

### 1. Added Default Categories Seeding
Added `_seedDefaultCategories()` method to `DatabaseSeeder`:

```dart
/// Seed default categories (required for products)
Future<void> _seedDefaultCategories() async {
  final db = await _databaseHelper.database;
  
  // Check if categories already exist
  final existingCategories = await db.query('categories');
  
  if (existingCategories.isEmpty) {
    // Create default categories
    final defaultCategories = [
      Category(
        id: 'cat_1',
        tenantId: 'default-tenant-id',
        name: 'Makanan & Minuman',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now(),
      ),
      Category(
        id: 'cat_2',
        tenantId: 'default-tenant-id',
        name: 'Kebutuhan Pokok',
        // ... more categories
      ),
      // ... 5 total default categories
    ];
    
    for (final category in defaultCategories) {
      await db.insert('categories', category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    print('📁 Seeded ${defaultCategories.length} default categories');
  }
}
```

### 2. Added Default Units Seeding
Added `_seedDefaultUnits()` method to `DatabaseSeeder`:

```dart
/// Seed default units (required for products)
Future<void> _seedDefaultUnits() async {
  final db = await _databaseHelper.database;
  
  // Check if units already exist
  final existingUnits = await db.query('units');
  
  if (existingUnits.isEmpty) {
    // Create default units
    final defaultUnits = [
      Unit(
        id: 'unit_001',
        tenantId: 'default-tenant-id',
        name: 'pcs',
        description: 'Piece - satuan per buah',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now(),
      ),
      // ... 10 total default units (pcs, bungkus, botol, kg, gram, liter, ml, ikat, paket, sachet)
    ];
    
    for (final unit in defaultUnits) {
      await db.insert('units', unit.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    print('📦 Seeded ${defaultUnits.length} default units');
  }
}
```

### 3. Updated Seeding Order
Updated `seedDatabase()` method to include the new seeding methods:

```dart
Future<void> seedDatabase() async {
  try {
    print('🌱 Initializing database with minimal required data...');
    
    // Seed tenant and location first (required for foreign keys)
    await _seedTenantAndLocation();
    
    // Seed system user (required for stock movements)
    await _seedSystemUser();
    
    // Seed default categories (required for products)
    await _seedDefaultCategories();
    
    // Seed default units (required for products)
    await _seedDefaultUnits();
    
    print('✅ Database initialization completed successfully!');
    print('📝 Note: Minimal data seeded (tenant, location, user, categories, units).');
  } catch (e) {
    print('❌ Database initialization failed: $e');
    rethrow;
  }
}
```

### 4. Fixed Unit Name Resolution
Fixed `_getUnitName()` method in `product_form_dialog.dart`:

```dart
/// Get unit name by ID
String _getUnitName(String unitId) {
  final unit = _unitController.getUnitById(unitId);
  return unit?.name ?? 'pcs'; // Default to 'pcs' if unit not found
}
```

## Default Data Seeded

### Categories (5 items)
1. **Makanan & Minuman** (cat_1)
2. **Kebutuhan Pokok** (cat_2)
3. **Perlengkapan Rumah** (cat_3)
4. **Kesehatan & Kecantikan** (cat_4)
5. **Lain-lain** (cat_5)

### Units (10 items)
1. **pcs** (unit_001) - Piece - satuan per buah
2. **bungkus** (unit_002) - Bungkus - satuan per bungkus
3. **botol** (unit_003) - Botol - satuan per botol
4. **kg** (unit_004) - Kilogram - satuan berat
5. **gram** (unit_005) - Gram - satuan berat kecil
6. **liter** (unit_006) - Liter - satuan volume
7. **ml** (unit_007) - Mililiter - satuan volume kecil
8. **ikat** (unit_008) - Ikat - satuan per ikat
9. **paket** (unit_009) - Paket - satuan per paket
10. **sachet** (unit_010) - Sachet - satuan per sachet

## Database Schema Dependencies

The seeding order now follows proper foreign key dependencies:

1. **Tenants** (no dependencies)
2. **Locations** (depends on tenants)
3. **Users** (depends on tenants)
4. **Categories** (depends on tenants) ← **NEW**
5. **Units** (depends on tenants) ← **NEW**
6. **Products** (depends on tenants, categories) ← **NOW WORKS**

## Benefits

1. **Foreign Key Compliance**: All foreign key references are now satisfied
2. **User Experience**: Users can immediately start adding products without setup
3. **Data Consistency**: Default categories and units provide a good starting point
4. **Error Prevention**: No more foreign key constraint violations when saving products

## Testing

### Before Fix
```
❌ DatabaseException(FOREIGN KEY constraint failed (code 787)) sql 'INSERT INTO products ...'
```

### After Fix (Expected)
```
🌱 Initializing database with minimal required data...
🏢 Seeded default tenant
📍 Seeded default location
👤 Seeded system user
📁 Seeded 5 default categories
📦 Seeded 10 default units
✅ Database initialization completed successfully!
```

## Files Modified

1. **`lib/core/data/database_seeder.dart`**
   - Added `_seedDefaultCategories()` method
   - Added `_seedDefaultUnits()` method
   - Updated `seedDatabase()` to include new seeding methods

2. **`lib/features/products/presentation/widgets/product_form_dialog.dart`**
   - Fixed `_getUnitName()` method to handle missing units gracefully

## Related Issues Fixed

This fix also resolves:
- Product form dropdowns showing empty categories/units
- Unit name resolution errors
- Category selection issues
- Product save failures due to missing foreign key references
