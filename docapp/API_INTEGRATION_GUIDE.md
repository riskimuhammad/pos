# 🌐 API Integration Guide - POS UMKM

## 📋 **API ENDPOINTS & PARAMETERS**

### 🔐 **Authentication Endpoints**

#### **POST /api/auth/login**
```json
{
  "username": "string",     // Username or email
  "password": "string",     // User password
  "device_id": "string",    // Device identifier
  "device_type": "string"   // "android" | "ios" | "web"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "full_name": "Administrator",
      "role": "admin",
      "is_active": true,
      "tenant_id": 1
    },
    "tenant": {
      "id": 1,
      "name": "Toko ABC",
      "address": "Jl. Contoh No. 123",
      "phone": "08123456789",
      "is_active": true
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_at": "2024-12-31T23:59:59Z"
  }
}
```

#### **POST /api/auth/logout**
```json
{
  "token": "string"  // JWT token
}
```

#### **POST /api/auth/refresh**
```json
{
  "refresh_token": "string"  // Refresh token
}
```

---

### 📦 **Product Management Endpoints**

#### **GET /api/products**
**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20)
- `search` (string): Search term
- `category_id` (int): Filter by category
- `is_active` (boolean): Filter by status

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": 1,
        "name": "Indomie Goreng",
        "description": "Mie instan goreng",
        "sku": "IMG001",
        "barcode": "1234567890123",
        "price": 3000,
        "cost_price": 2500,
        "stock": 100,
        "min_stock": 10,
        "category_id": 1,
        "image_url": "https://example.com/image.jpg",
        "is_active": true,
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "items_per_page": 20
    }
  }
}
```

#### **POST /api/products**
```json
{
  "name": "string",
  "description": "string",
  "sku": "string",
  "barcode": "string",
  "price": 0,
  "cost_price": 0,
  "stock": 0,
  "min_stock": 0,
  "category_id": 1,
  "image_url": "string",
  "is_active": true
}
```

#### **PUT /api/products/{id}**
```json
{
  "name": "string",
  "description": "string",
  "price": 0,
  "stock": 0,
  "is_active": true
}
```

#### **DELETE /api/products/{id}**
No body required.

---

### 🛒 **Transaction Endpoints**

#### **POST /api/transactions**
```json
{
  "customer_name": "string",
  "customer_phone": "string",
  "items": [
    {
      "product_id": 1,
      "quantity": 2,
      "price": 3000,
      "discount": 0
    }
  ],
  "payment_method": "cash",
  "payment_amount": 6000,
  "change_amount": 0,
  "notes": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "transaction": {
      "id": 1,
      "transaction_number": "TRX001",
      "customer_name": "John Doe",
      "customer_phone": "08123456789",
      "subtotal": 6000,
      "tax": 600,
      "discount": 0,
      "total": 6600,
      "payment_method": "cash",
      "payment_amount": 7000,
      "change_amount": 400,
      "status": "completed",
      "user_id": 1,
      "created_at": "2024-01-01T00:00:00Z"
    },
    "items": [
      {
        "id": 1,
        "transaction_id": 1,
        "product_id": 1,
        "product_name": "Indomie Goreng",
        "quantity": 2,
        "price": 3000,
        "discount": 0,
        "subtotal": 6000
      }
    ]
  }
}
```

#### **GET /api/transactions**
**Query Parameters:**
- `page` (int): Page number
- `limit` (int): Items per page
- `start_date` (string): Start date (YYYY-MM-DD)
- `end_date` (string): End date (YYYY-MM-DD)
- `status` (string): Transaction status
- `payment_method` (string): Payment method

#### **GET /api/transactions/{id}**
Get transaction details by ID.

---

### 📊 **Reporting Endpoints**

#### **GET /api/reports/sales**
**Query Parameters:**
- `start_date` (string): Start date (YYYY-MM-DD)
- `end_date` (string): End date (YYYY-MM-DD)
- `period` (string): "daily" | "weekly" | "monthly" | "yearly"
- `group_by` (string): "product" | "category" | "user"

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_transactions": 150,
      "total_sales": 15000000,
      "total_profit": 3000000,
      "average_transaction": 100000
    },
    "chart_data": [
      {
        "date": "2024-01-01",
        "sales": 500000,
        "transactions": 25
      }
    ],
    "top_products": [
      {
        "product_id": 1,
        "product_name": "Indomie Goreng",
        "quantity_sold": 100,
        "total_sales": 300000
      }
    ]
  }
}
```

#### **GET /api/reports/inventory**
**Query Parameters:**
- `low_stock` (boolean): Show only low stock items
- `category_id` (int): Filter by category

#### **GET /api/reports/products**
**Query Parameters:**
- `start_date` (string): Start date
- `end_date` (string): End date
- `sort_by` (string): "sales" | "profit" | "quantity"

---

### 👥 **User Management Endpoints**

#### **GET /api/users**
**Query Parameters:**
- `page` (int): Page number
- `limit` (int): Items per page
- `role` (string): Filter by role
- `is_active` (boolean): Filter by status

#### **POST /api/users**
```json
{
  "username": "string",
  "email": "string",
  "full_name": "string",
  "password": "string",
  "role": "cashier",
  "is_active": true
}
```

#### **PUT /api/users/{id}**
```json
{
  "full_name": "string",
  "email": "string",
  "role": "cashier",
  "is_active": true
}
```

---

### 🏪 **Tenant Management Endpoints**

#### **GET /api/tenants**
Get tenant information.

#### **PUT /api/tenants/{id}**
```json
{
  "name": "string",
  "address": "string",
  "phone": "string",
  "email": "string",
  "is_active": true
}
```

---

### 📱 **Mobile-Specific Endpoints**

#### **POST /api/mobile/sync**
```json
{
  "last_sync": "2024-01-01T00:00:00Z",
  "device_id": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [...],
    "categories": [...],
    "transactions": [...],
    "sync_timestamp": "2024-01-01T00:00:00Z"
  }
}
```

#### **POST /api/mobile/upload-transactions**
```json
{
  "transactions": [
    {
      "local_id": "string",
      "transaction_data": {...}
    }
  ]
}
```

---

## 🔧 **API CONFIGURATION**

### **Base URL:**
```dart
// Development
const String baseUrl = 'https://api-dev.pos-umkm.com';

// Production
const String baseUrl = 'https://api.pos-umkm.com';
```

### **Headers:**
```dart
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
  'X-Device-ID': deviceId,
  'X-App-Version': appVersion,
};
```

### **Error Handling:**
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  
  ApiException(this.message, {this.statusCode, this.data});
}
```

---

## 🔄 **SYNC STRATEGY**

### **Offline-First Approach:**
1. **Local Database** - Primary data storage
2. **Background Sync** - Periodic data synchronization
3. **Conflict Resolution** - Handle data conflicts
4. **Queue System** - Queue failed requests

### **Sync Flow:**
```
App Start → Check Connectivity → Sync Data → Update UI
     ↓
Offline Mode → Queue Requests → Sync When Online
```

### **Data Priority:**
1. **Local Data** - Always available
2. **Server Data** - Sync when online
3. **Conflict Resolution** - Server wins for critical data

---

## 🚀 **IMPLEMENTATION STEPS**

### **Phase 1: Basic API Integration**
1. **HTTP Client Setup** - Dio configuration
2. **Authentication API** - Login/logout endpoints
3. **Error Handling** - API exception handling
4. **Token Management** - JWT token handling

### **Phase 2: Data Sync**
1. **Product Sync** - Sync product catalog
2. **Transaction Upload** - Upload offline transactions
3. **Conflict Resolution** - Handle data conflicts
4. **Background Sync** - Periodic synchronization

### **Phase 3: Advanced Features**
1. **Real-time Updates** - WebSocket integration
2. **Push Notifications** - Server notifications
3. **Analytics** - Usage analytics
4. **Performance Monitoring** - API performance tracking

---

## 📱 **MOBILE CONSIDERATIONS**

### **Network Handling:**
- **Connectivity Check** - Network status monitoring
- **Retry Logic** - Automatic retry for failed requests
- **Timeout Handling** - Request timeout management
- **Offline Mode** - Full offline functionality

### **Performance:**
- **Request Batching** - Batch multiple requests
- **Caching Strategy** - Cache frequently accessed data
- **Image Optimization** - Compress and cache images
- **Background Processing** - Non-blocking operations

### **Security:**
- **Certificate Pinning** - SSL certificate validation
- **Token Refresh** - Automatic token renewal
- **Data Encryption** - Encrypt sensitive data
- **Secure Storage** - Store credentials securely

---

## 🎯 **READY FOR API INTEGRATION**

### **Current Status:**
✅ **Local Database** - Ready for sync  
✅ **Authentication** - Mock data ready  
✅ **Error Handling** - Exception handling ready  
✅ **State Management** - GetX controllers ready  
✅ **UI Components** - Ready for real data  

### **Next Steps:**
1. **API Client Setup** - Configure HTTP client
2. **Endpoint Integration** - Connect to real APIs
3. **Data Sync** - Implement sync mechanism
4. **Testing** - Test with real API data

**Aplikasi sudah siap untuk integrasi API!** 🚀
