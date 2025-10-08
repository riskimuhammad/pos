# SQLite Data Type Compatibility Fix

## Problem
The application was experiencing SQLite data type compatibility errors when seeding the database:

```
Invalid argument {} with type _ConstMap<String, dynamic>.
Only num, String and Uint8List are supported.
```

```
Invalid argument [all] with type List<String>.
Only num, String and Uint8List are supported.
```

## Root Cause
SQLite only supports these data types:
- `num` (INTEGER, REAL)
- `String` (TEXT)
- `Uint8List` (BLOB)

However, several entity models were trying to store complex data types directly:
- `List<String>` (permissions in User model)
- `Map<String, dynamic>` (settings in Tenant model, paymentDetails in Transaction model)

## Solution
Modified entity models to convert complex data types to JSON strings before storing in SQLite:

### 1. User Model (`lib/shared/models/entities/user.dart`)
**Before:**
```dart
'permissions': permissions, // List<String> - NOT SUPPORTED
```

**After:**
```dart
'permissions': jsonEncode(permissions), // Convert List to JSON string
```

**fromJson handling:**
```dart
permissions: json['permissions'] != null
    ? (json['permissions'] is String 
        ? List<String>.from(jsonDecode(json['permissions'] as String))
        : List<String>.from(json['permissions'] as List))
    : [],
```

### 2. Tenant Model (`lib/shared/models/entities/tenant.dart`)
**Before:**
```dart
'settings': settings, // Map<String, dynamic> - NOT SUPPORTED
```

**After:**
```dart
'settings': jsonEncode(settings), // Convert Map to JSON string
```

**fromJson handling:**
```dart
settings: json['settings'] != null 
    ? (json['settings'] is String 
        ? Map<String, dynamic>.from(jsonDecode(json['settings'] as String))
        : Map<String, dynamic>.from(json['settings'] as Map))
    : {},
```

### 3. Transaction Model (`lib/shared/models/entities/transaction.dart`)
**Before:**
```dart
'payment_details': paymentDetails, // Map<String, dynamic> - NOT SUPPORTED
```

**After:**
```dart
'payment_details': jsonEncode(paymentDetails), // Convert Map to JSON string
```

**fromJson handling:**
```dart
paymentDetails: json['payment_details'] != null
    ? (json['payment_details'] is String 
        ? Map<String, dynamic>.from(jsonDecode(json['payment_details'] as String))
        : Map<String, dynamic>.from(json['payment_details'] as Map))
    : {},
```

## Additional Fixes

### FTS Table Schema Fix
Fixed FTS table schema issues in `database_helper.dart`:

**Before:**
```sql
CREATE VIRTUAL TABLE products_fts USING fts5(
  product_id,  -- Wrong column name
  name,
  sku,
  content='products',
  content_rowid='rowid'
)
```

**After:**
```sql
CREATE VIRTUAL TABLE products_fts USING fts5(
  id,          -- Correct column name
  name,
  sku,
  description
)
```

### FTS Triggers Fix
Updated FTS triggers to use correct column names:

**Before:**
```sql
INSERT INTO products_fts(product_id, name, sku) VALUES (NEW.id, NEW.name, NEW.sku);
```

**After:**
```sql
INSERT INTO products_fts(id, name, sku, description) VALUES (NEW.id, NEW.name, NEW.sku, NEW.description);
```

## Benefits
1. **SQLite Compatibility**: All data types are now compatible with SQLite
2. **Backward Compatibility**: fromJson methods handle both old and new formats
3. **Data Integrity**: Complex data structures are preserved as JSON strings
4. **Performance**: FTS table now works correctly for product search

## Testing
After these fixes:
1. Database seeding should work without data type errors
2. FTS table should populate correctly
3. Product search functionality should work
4. All entity models should save/load correctly

## Files Modified
- `lib/shared/models/entities/user.dart`
- `lib/shared/models/entities/tenant.dart`
- `lib/shared/models/entities/transaction.dart`
- `lib/core/storage/database_helper.dart`

## Dependencies Added
- `dart:convert` import added to all modified entity models for `jsonEncode`/`jsonDecode`
