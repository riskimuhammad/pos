# UML Diagrams - Aplikasi POS UMKM

## 1. Class Diagram - Domain Model

```plantuml
@startuml

' Core Entities
class Product {
  +String id
  +String sku
  +String name
  +String categoryId
  +double priceBuy
  +double priceSell
  +String unit
  +double? weight
  +List<String> photos
  +Map<String, dynamic> attributes
  +DateTime createdAt
  +DateTime updatedAt
  +bool isActive
  --
  +calculateProfit()
  +hasBarcode()
  +isExpirable()
}

class Category {
  +String id
  +String name
  +String? parentId
  +String icon
  +int sortOrder
  --
  +getFullPath()
}

class Inventory {
  +String id
  +String productId
  +String locationId
  +int quantity
  +int reserved
  +int reorderPoint
  +DateTime lastUpdated
  +String syncStatus
  --
  +isLowStock()
  +getAvailableQty()
  +reserve(qty)
  +release(qty)
}

class Transaction {
  +String id
  +String tenantId
  +String userId
  +List<TransactionItem> items
  +double subtotal
  +double discount
  +double tax
  +double total
  +String paymentMethod
  +DateTime timestamp
  +String status
  +String? receiptNumber
  +String syncStatus
  --
  +calculateTotal()
  +addItem(item)
  +removeItem(itemId)
  +applyDiscount(amount)
  +void()
}

class TransactionItem {
  +String id
  +String productId
  +String productName
  +double price
  +int quantity
  +double discount
  +double subtotal
  --
  +calculateSubtotal()
}

class Tenant {
  +String id
  +String name
  +String owner
  +String email
  +String phone
  +String address
  +Map<String, dynamic> settings
  +String subscriptionTier
  +DateTime subscriptionExpiry
  +bool isActive
}

class User {
  +String id
  +String tenantId
  +String username
  +String email
  +String passwordHash
  +String role
  +List<String> permissions
  +bool isActive
  +DateTime lastLogin
  --
  +hasPermission(permission)
  +authenticate(password)
}

class Location {
  +String id
  +String tenantId
  +String name
  +String type
  +String address
  +bool isPrimary
}

' AI/ML Related
class ProductDetectionEvent {
  +String id
  +String tenantId
  +String imageUrl
  +List<ProductPrediction> predictions
  +String? selectedProductId
  +bool isVerified
  +DateTime timestamp
  --
  +getTopPrediction()
}

class ProductPrediction {
  +String productId
  +double confidence
  +Map<String, dynamic> features
}

class StockForecast {
  +String id
  +String productId
  +String tenantId
  +DateTime forecastDate
  +double predictedDemand
  +double confidence
  +String modelVersion
  +DateTime createdAt
}

class AnomalyAlert {
  +String id
  +String tenantId
  +String type
  +String severity
  +String description
  +Map<String, dynamic> metadata
  +String status
  +DateTime detectedAt
}

' Sync & Events
class SyncQueue {
  +String id
  +String entityType
  +String entityId
  +String operation
  +Map<String, dynamic> payload
  +int retryCount
  +String status
  +DateTime createdAt
  --
  +retry()
  +markSynced()
}

class EventLog {
  +String id
  +String eventType
  +String entityType
  +String entityId
  +Map<String, dynamic> payload
  +String userId
  +DateTime timestamp
}

' Relationships
Product "1" -- "many" Inventory
Product "many" -- "1" Category
Transaction "1" *-- "many" TransactionItem
Transaction "many" -- "1" Tenant
Transaction "many" -- "1" User
Inventory "many" -- "1" Location
Location "many" -- "1" Tenant
User "many" -- "1" Tenant
Product "many" -- "1" Tenant
ProductDetectionEvent "1" *-- "many" ProductPrediction
ProductDetectionEvent "many" -- "1" Tenant
StockForecast "many" -- "1" Product
AnomalyAlert "many" -- "1" Tenant

@enduml
```

## 2. Sequence Diagram - Transaksi POS

```plantuml
@startuml

actor Kasir
participant "POS UI" as UI
participant "Local DB\n(SQLite)" as LocalDB
participant "Transaction\nService" as TxService
participant "Inventory\nService" as InvService
participant "Sync Queue" as Queue
participant "API Gateway" as API
participant "Backend\nServices" as Backend

Kasir -> UI: Scan/Input Produk
UI -> LocalDB: Query Produk Info
LocalDB --> UI: Produk Data
UI -> UI: Tambah ke Keranjang

Kasir -> UI: Input Pembayaran
UI -> TxService: Create Transaction

activate TxService
TxService -> LocalDB: Begin Transaction
TxService -> LocalDB: Insert Transaction
TxService -> InvService: Deduct Inventory

activate InvService
InvService -> LocalDB: Update Inventory Qty
InvService -> LocalDB: Insert Stock Movement
InvService --> TxService: Success
deactivate InvService

TxService -> LocalDB: Commit Transaction
TxService -> Queue: Add Sync Job
TxService -> LocalDB: Log Event
TxService --> UI: Transaction ID
deactivate TxService

UI -> UI: Generate Receipt
UI --> Kasir: Show Receipt & Print

' Background Sync
Queue -> API: POST /transactions (when online)
activate API
API -> Backend: Sync Transaction
Backend -> Backend: Validate & Store
Backend --> API: Success
deactivate API
API -> Queue: Mark Synced
Queue -> LocalDB: Update Sync Status

@enduml
```

## 3. Sequence Diagram - Deteksi Produk AI

```plantuml
@startuml

actor Kasir
participant "Camera UI" as Camera
participant "ML Service\n(On-Device)" as MLLocal
participant "Local DB" as LocalDB
participant "API Gateway" as API
participant "ML Service\n(Cloud)" as MLCloud
participant "Feedback\nPipeline" as Feedback

Kasir -> Camera: Ambil Foto Produk
Camera -> Camera: Capture Image

Camera -> MLLocal: Inference (TFLite Model)
activate MLLocal
MLLocal -> MLLocal: Preprocess Image
MLLocal -> MLLocal: Run Model
MLLocal --> Camera: Top 3 Predictions\n(confidence > 70%)
deactivate MLLocal

Camera --> Kasir: Tampilkan Hasil

alt High Confidence (>90%)
    Kasir -> Camera: Pilih Prediksi #1
else Low/Medium Confidence
    Camera -> API: Request Cloud Inference
    activate API
    API -> MLCloud: Inference dengan Model Besar
    activate MLCloud
    MLCloud --> API: Refined Predictions
    deactivate MLCloud
    API --> Camera: Updated Results
    deactivate API
    Camera --> Kasir: Tampilkan Hasil Refined
    Kasir -> Camera: Pilih atau Koreksi
end

Camera -> LocalDB: Save Detection Event
Camera -> LocalDB: Link Selected Product

alt Produk Benar
    Camera -> Feedback: Send Positive Label
else Produk Salah/Dikoreksi
    Kasir -> Camera: Input Produk Yang Benar
    Camera -> Feedback: Send Corrected Label
end

Feedback -> Feedback: Queue untuk Retraining
Feedback -> MLCloud: Update Training Dataset

@enduml
```

## 4. Component Diagram - System Architecture

```plantuml
@startuml

package "Mobile Client (Flutter/Android)" {
  [POS UI]
  [Camera Module]
  [Offline Storage\nSQLite]
  [Sync Manager]
  [ML Inference\nTFLite]
  [Receipt Printer]
  [Hardware Integration]
}

package "API Layer" {
  [API Gateway]
  [Auth Service]
  [Rate Limiter]
  [Load Balancer]
}

package "Core Services" {
  [Transaction Service]
  [Inventory Service]
  [Product Catalog Service]
  [Tenant Management]
  [User Management]
  [Reporting Service]
}

package "AI/ML Services" {
  [Vision Service\nProduct Detection]
  [Forecasting Service]
  [Anomaly Detection]
  [Model Training Pipeline]
  [Feature Store]
}

package "Integration Services" {
  [Payment Gateway\nQRIS/E-Wallet]
  [Notification Service\nSMS/WhatsApp]
  [Sync Service]
  [Export Service]
}

package "Data Layer" {
  database "PostgreSQL\nPrimary DB" as PG
  database "Redis\nCache" as Redis
  database "ElasticSearch\nSearch & Analytics" as ES
  queue "Kafka\nEvent Stream" as Kafka
  storage "S3\nObject Storage" as S3
}

package "DevOps & Monitoring" {
  [CI/CD Pipeline]
  [Monitoring\nPrometheus/Grafana]
  [Log Aggregation\nELK]
  [Backup Service]
}

[POS UI] --> [Offline Storage\nSQLite]
[POS UI] --> [Camera Module]
[POS UI] --> [ML Inference\nTFLite]
[POS UI] --> [Sync Manager]
[Sync Manager] --> [API Gateway]
[Hardware Integration] --> [Receipt Printer]

[API Gateway] --> [Auth Service]
[API Gateway] --> [Core Services]
[API Gateway] --> [AI/ML Services]
[API Gateway] --> [Integration Services]

[Core Services] --> PG
[Core Services] --> Redis
[Core Services] --> Kafka
[AI/ML Services] --> S3
[AI/ML Services] --> [Feature Store]
[Reporting Service] --> ES

[Sync Service] --> [Offline Storage\nSQLite]
[Sync Service] --> PG

Kafka --> [Model Training Pipeline]
[Model Training Pipeline] --> [ML Inference\nTFLite]

@enduml
```

## 5. State Diagram - Transaction Status

```plantuml
@startuml

[*] --> Draft

Draft --> Pending : Submit Transaction
Pending --> Processing : Validate Payment
Processing --> Completed : Payment Success
Processing --> Failed : Payment Failed
Processing --> Pending : Retry Payment

Completed --> Voided : Void Transaction
Completed --> PartialRefund : Partial Refund
PartialRefund --> Completed : No More Refunds
Completed --> Refunded : Full Refund

Failed --> Cancelled : Cancel
Voided --> [*]
Refunded --> [*]
Cancelled --> [*]

note right of Completed
  Dapat dilakukan void hanya
  dalam waktu tertentu (misal 24 jam)
  dan dengan permission khusus
end note

@enduml
```

## 6. Activity Diagram - Stock Opname

```plantuml
@startuml

start

:Buka Menu Stock Opname;
:Pilih Lokasi Gudang/Toko;
:Sistem Generate Daftar Produk;

partition "Scan Products" {
  repeat
    :Scan Barcode / Input Manual;
    :Input Quantity Fisik;
    :Sistem Catat Jumlah Aktual;
  repeat while (Ada produk lagi?) is (Ya)
  ->Tidak;
}

:Sistem Hitung Selisih;

if (Ada Selisih?) then (Ya)
  :Tampilkan Laporan Selisih;
  :Manager Review;
  
  if (Approve Adjustment?) then (Ya)
    :Update Inventory;
    :Create Stock Adjustment Record;
    :Log Audit Trail;
  else (Tidak)
    :Ulangi Stock Opname;
    stop
  endif
else (Tidak)
  :Tampilkan Konfirmasi\nTidak Ada Selisih;
endif

:Generate Laporan Stock Opname;
:Sync ke Server;

stop

@enduml
```

## 7. Use Case Diagram

```plantuml
@startuml

left to right direction

actor Kasir
actor "Pemilik Toko" as Owner
actor "Admin Pasar" as Admin
actor "Sistem AI" as AI
actor "Payment Gateway" as Payment

rectangle "Aplikasi POS UMKM" {
  usecase "UC1: Transaksi Penjualan" as UC1
  usecase "UC2: Scan Produk (Barcode)" as UC2
  usecase "UC3: Deteksi Produk (Camera)" as UC3
  usecase "UC4: Kelola Inventory" as UC4
  usecase "UC5: Stock Opname" as UC5
  usecase "UC6: Laporan Penjualan" as UC6
  usecase "UC7: Forecasting Stok" as UC7
  usecase "UC8: Deteksi Anomali" as UC8
  usecase "UC9: Kelola Produk" as UC9
  usecase "UC10: Kelola User" as UC10
  usecase "UC11: Multi-Tenant Dashboard" as UC11
  usecase "UC12: Export Data" as UC12
  usecase "UC13: Proses Pembayaran" as UC13
  usecase "UC14: Sync Data Offline" as UC14
}

Kasir --> UC1
Kasir --> UC2
Kasir --> UC3
Kasir --> UC5

Owner --> UC4
Owner --> UC6
Owner --> UC9
Owner --> UC10
Owner --> UC12

Admin --> UC11
Admin --> UC6
Admin --> UC10

AI --> UC3
AI --> UC7
AI --> UC8

UC1 ..> UC13 : <<include>>
UC1 ..> UC14 : <<include>>
UC3 ..> AI : <<extend>>
UC7 ..> AI : <<extend>>

Payment --> UC13

@enduml
```

## Cara Menggunakan Diagram

1. **PlantUML**: Copy kode diagram ke editor PlantUML online (http://www.plantuml.com/plantuml/uml/) atau gunakan plugin IDE
2. **Mermaid**: Alternatif lain, bisa convert ke Mermaid syntax untuk GitHub/GitLab native rendering
3. **Export**: Export sebagai PNG/SVG untuk dokumentasi

## Tools yang Direkomendasikan

- PlantUML Online Editor
- Visual Studio Code + PlantUML Extension
- Draw.io / Lucidchart (untuk editing lebih visual)
- Enterprise Architect / StarUML (untuk proyek besar)


