# User Foreign Key Fix - POS UMKM

## Problem Description

Database seeding gagal dengan error:
```
DatabaseException(FOREIGN KEY constraint failed (code 787)) sql 'INSERT OR REPLACE INTO stock_movements (id, tenant_id, product_id, location_id, type, quantity, cost_price, reference_type, reference_id, notes, user_id, created_at, sync_status, last_synced_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' args [sm_prod_001, default-tenant-id, prod_001, default-location-id, PURCHASE, 10, 2500.0, initial_stock, initial_prod_001, Initial stock seeding, system, 1757301221068, synced, 1757301221068]
```

## Root Cause

Tabel `stock_movements` mencoba mereferensikan `user_id: 'system'` ke tabel `users`, tetapi data user dengan ID `'system'` belum ada di database.

## Solution Implemented

### Added System User Seeding

#### New Method: `_seedSystemUser()`
```dart
/// Seed system user (required for stock movements)
Future<void> _seedSystemUser() async {
  final db = await _databaseHelper.database;
  
  // Check if system user already exists
  final existingUser = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: ['system'],
  );
  
  if (existingUser.isEmpty) {
    // Create system user
    final user = User(
      id: 'system',
      tenantId: 'default-tenant-id',
      username: 'system',
      email: 'system@warung.com',
      passwordHash: 'system_hash', // This is just for seeding, not real auth
      fullName: 'System User',
      role: 'admin',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      syncStatus: 'synced',
      lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    print('👤 Seeded system user');
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
    
    // Seed system user (required for stock movements)
    await _seedSystemUser();
    
    // Seed categories
    await _seedCategories();
    
    // Seed products
    await _seedProducts();
    
    // Seed stock movements
    await _seedStockMovements();
    
    print('✅ Database seeding completed successfully!');
  } catch (e) {
    // ... error handling
  }
}
```

#### Updated Retry Logic
```dart
// Retry seeding
await _seedTenantAndLocation();
await _seedSystemUser();  // Added this line
await _seedCategories();
await _seedProducts();
await _seedStockMovements();
```

## System User Details

The system user is created with the following properties:
- **ID**: `'system'`
- **Username**: `'system'`
- **Email**: `'system@warung.com'`
- **Full Name**: `'System User'`
- **Role**: `'admin'`
- **Password Hash**: `'system_hash'` (for seeding only, not real authentication)
- **Status**: Active
- **Tenant**: `'default-tenant-id'`

## Database Schema Dependencies

The seeding order now follows proper foreign key dependencies:

1. **Tenants** (no dependencies)
2. **Locations** (depends on tenants)
3. **Users** (depends on tenants) ← **NEW**
4. **Categories** (depends on tenants)
5. **Products** (depends on tenants, categories)
6. **Stock Movements** (depends on tenants, products, locations, users) ← **FIXED**

## Files Modified

1. **`lib/core/data/database_seeder.dart`**
   - Added `_seedSystemUser()` method
   - Updated seeding order to include system user
   - Updated retry logic to include system user seeding

## Testing

### Before Fix
```
❌ Database seeding failed: DatabaseException(FOREIGN KEY constraint failed (code 787))
```

### After Fix (Expected)
```
🌱 Starting database seeding...
🏢 Seeded default tenant
📍 Seeded default location
👤 Seeded system user
📁 Seeded 5 categories
📦 Seeded 10 products
📊 Seeded 10 stock movements
✅ Database seeding completed successfully!
```

## Key Learnings

1. **Foreign Key Dependencies**: Always ensure all referenced entities exist before creating dependent records
2. **System Users**: For automated operations, create a dedicated system user account
3. **Seeding Order**: Follow the dependency graph when seeding related data
4. **Error Recovery**: Include all seeding steps in retry logic

## Prevention

1. **Dependency Mapping**: Map all foreign key relationships before implementing seeding
2. **Validation**: Validate that all referenced entities exist before insert operations
3. **Testing**: Test seeding with various database states (empty, partial, corrupted)
4. **Documentation**: Document all entity relationships and dependencies

---

## Status: ✅ RESOLVED

Database seeding now properly handles all foreign key constraints by seeding the system user before creating stock movements.
