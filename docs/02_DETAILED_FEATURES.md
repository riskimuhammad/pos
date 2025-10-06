# Detail Fitur Aplikasi POS UMKM

## Overview
Dokumen ini menjelaskan secara detail setiap fitur yang akan dibangun dalam aplikasi POS, lengkap dengan requirements, acceptance criteria, dan prioritas.

---

## 1. MODUL AUTHENTICATION & USER MANAGEMENT

### 1.1 Login & Authentication
**Prioritas:** P0 (MVP)
**User Story:** Sebagai user, saya ingin login dengan aman agar bisa mengakses sistem

**Fitur:**
- Login dengan username/email + password
- JWT token untuk session management
- Refresh token mechanism
- Remember me functionality
- Logout dan clear session
- Password strength validation

**Acceptance Criteria:**
- [ ] User dapat login dengan kredensial valid
- [ ] Token expire setelah 24 jam, refresh token 30 hari
- [ ] Password minimal 8 karakter, kombinasi huruf & angka
- [ ] Login gagal max 5x, account lock 15 menit
- [ ] Audit log setiap login/logout

**Technical Notes:**
- JWT stored di secure storage (flutter_secure_storage)
- Biometric login optional (fingerprint/face)

---

### 1.2 User Management
**Prioritas:** P0 (MVP)
**User Story:** Sebagai owner, saya ingin mengelola user agar bisa kontrol akses

**Fitur:**
- CRUD user (Create, Read, Update, Delete/Deactivate)
- Role-based access: Super Admin, Admin Pasar, Owner, Manager, Kasir
- Permission granular per feature
- User activity log
- Reset password functionality

**Roles & Permissions:**

| Role | Permissions |
|------|------------|
| Super Admin | Full access, manage tenants |
| Admin Pasar | View all tenants, reports, manage tenant users |
| Owner | Full access in tenant, manage products, users, reports |
| Manager | Manage products, inventory, view reports |
| Kasir | Create transactions, view products, basic inventory |

**Acceptance Criteria:**
- [ ] Owner dapat create user baru dengan role
- [ ] User hanya bisa akses fitur sesuai permission
- [ ] Deactivated user tidak bisa login
- [ ] Admin dapat reset password user

---

## 2. MODUL POINT OF SALE (POS)

### 2.1 Transaksi Penjualan
**Prioritas:** P0 (MVP)
**User Story:** Sebagai kasir, saya ingin melakukan transaksi penjualan dengan cepat

**Fitur:**
- Search produk (nama, SKU, barcode)
- Scan barcode/QR code
- Input quantity manual
- Multiple items dalam 1 transaksi
- Edit quantity, remove item
- Apply discount (% atau nominal)
- Apply discount per item atau total
- Multiple payment methods: Cash, QRIS, E-Wallet, Transfer
- Split payment
- Kembalian otomatis
- Hold/Park transaction
- Retrieve parked transaction

**UI/UX Requirements:**
- Grid view produk dengan foto
- Search bar dengan autocomplete
- Numeric keypad untuk input cepat
- Shopping cart view dengan summary
- Touch-optimized untuk tablet

**Acceptance Criteria:**
- [ ] Kasir dapat add produk via scan atau search dalam <2 detik
- [ ] Dapat edit qty produk di keranjang
- [ ] Discount dapat diapply dengan validation
- [ ] Transaksi berhasil tersimpan dan stok terupdate
- [ ] Receipt otomatis generated
- [ ] Dapat hold hingga 10 transaksi bersamaan

**Technical Notes:**
- Debounce search 300ms
- Optimistic UI update untuk performance
- Local transaction ID format: TRX-{tenantId}-{timestamp}-{random}

---

### 2.2 Receipt / Struk
**Prioritas:** P0 (MVP)
**User Story:** Sebagai kasir, saya ingin cetak struk otomatis setelah transaksi

**Fitur:**
- Auto-generate receipt setelah transaksi
- Print via thermal printer (Bluetooth/USB)
- Receipt format: header toko, items, total, payment, footer
- Reprint receipt dari history
- Share receipt via WhatsApp/Email
- Digital receipt (PDF)

**Receipt Content:**
- Nama toko, alamat, telp
- No. struk + tanggal/waktu
- Nama kasir
- List items (nama, qty, harga, subtotal)
- Subtotal, discount, tax (optional), grand total
- Payment method & jumlah bayar
- Kembalian
- Footer (terima kasih, return policy)

**Acceptance Criteria:**
- [ ] Receipt auto-print setelah transaksi sukses
- [ ] Format receipt sesuai standar Indonesia
- [ ] Dapat reprint dari transaction history
- [ ] Dapat share digital receipt

---

### 2.3 Return / Refund
**Prioritas:** P1 (Post-MVP)
**User Story:** Sebagai kasir, saya ingin proses retur barang dengan mudah

**Fitur:**
- Search transaksi by receipt number
- Select items untuk diretur (full/partial)
- Input reason (rusak, salah, expired, dll)
- Refund to original payment atau cash
- Update stok otomatis
- Generate return receipt

**Acceptance Criteria:**
- [ ] Kasir dapat search transaksi untuk retur
- [ ] Dapat pilih item spesifik untuk partial return
- [ ] Stok otomatis bertambah setelah return
- [ ] Return receipt tergenerate dengan refund details
- [ ] Require approval untuk return > threshold amount

---

## 3. MODUL PRODUCT MANAGEMENT

### 3.1 Kelola Produk
**Prioritas:** P0 (MVP)
**User Story:** Sebagai owner, saya ingin mengelola master produk

**Fitur:**
- CRUD product
- Field: SKU (unique), nama, kategori, unit, harga beli, harga jual, foto
- Multiple product photos
- Barcode/QR generation
- Product variants (size, warna, dll)
- Track by batch/serial number (optional)
- Expiry date tracking (untuk produk expired)
- Bulk import via CSV
- Bulk edit (update harga massal)

**Product Attributes:**
```json
{
  "id": "uuid",
  "sku": "string (unique)",
  "name": "string",
  "categoryId": "uuid",
  "unit": "pcs/kg/liter/etc",
  "priceBuy": "decimal",
  "priceSell": "decimal",
  "weight": "decimal (optional)",
  "photos": ["url1", "url2"],
  "hasBarcode": "boolean",
  "barcode": "string",
  "isExpirable": "boolean",
  "minStock": "integer",
  "description": "text",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Acceptance Criteria:**
- [ ] User dapat create produk dengan foto
- [ ] SKU unique per tenant
- [ ] Harga jual > harga beli (warning jika tidak)
- [ ] Dapat upload multiple photos
- [ ] Bulk import validate format CSV
- [ ] Inactive product tidak muncul di POS

---

### 3.2 Kategori Produk
**Prioritas:** P0 (MVP)
**User Story:** Sebagai owner, saya ingin mengorganisir produk dengan kategori

**Fitur:**
- CRUD kategori
- Hierarchical categories (parent-child)
- Icon/image untuk kategori
- Sort order custom
- Filter produk by kategori di POS

**Acceptance Criteria:**
- [ ] Dapat create kategori dengan sub-kategori
- [ ] Kategori tampil di dropdown saat create product
- [ ] Dapat filter produk by kategori di POS

---

### 3.3 Deteksi Produk AI (Camera-Based)
**Prioritas:** P1 (Post-MVP - Fitur Unggulan)
**User Story:** Sebagai kasir, saya ingin scan produk tanpa barcode menggunakan kamera

**Fitur:**
- Camera capture produk
- On-device inference (TFLite model)
- Show top 3 predictions dengan confidence score
- Kasir pilih hasil atau koreksi
- Fallback to cloud inference jika confidence rendah
- Feedback loop untuk improve model

**Flow:**
1. Kasir tap "Scan Produk via Kamera"
2. Ambil foto produk
3. Sistem jalankan ML model on-device
4. Tampilkan 3 prediksi teratas dengan % confidence
5. Kasir pilih yang benar atau input manual
6. Feedback dikirim ke server untuk retraining

**Acceptance Criteria:**
- [ ] Inference time < 2 detik di perangkat standar
- [ ] Top-1 accuracy > 80% untuk produk yang sudah trained
- [ ] Dapat fallback to manual input
- [ ] Feedback loop terimplementasi
- [ ] Model dapat di-update via OTA

**Technical Notes:**
- Model: MobileNetV2 atau EfficientNet-Lite
- Input: 224x224 RGB image
- Output: product_id dengan confidence score
- Min confidence threshold: 70% untuk auto-add

---

## 4. MODUL INVENTORY MANAGEMENT

### 4.1 Stock Management
**Prioritas:** P0 (MVP)
**User Story:** Sebagai manager, saya ingin track stok real-time

**Fitur:**
- Real-time stock level per produk per lokasi
- Stock movement history (in, out, adjustment)
- Low stock alert (push notification)
- Reorder point setting per produk
- Multiple locations (toko, gudang)
- Stock reservation (untuk online order)

**Stock Movement Types:**
- SALE (transaksi penjualan)
- PURCHASE (pembelian)
- RETURN (retur)
- ADJUSTMENT (stock opname)
- TRANSFER (antar lokasi)
- DAMAGE (barang rusak)
- EXPIRED (kadaluarsa)

**Acceptance Criteria:**
- [ ] Stok auto-update setelah transaksi
- [ ] Dapat view stock per location
- [ ] Alert muncul saat stok <= reorder point
- [ ] Stock movement log lengkap dengan user & timestamp

---

### 4.2 Stock Opname
**Prioritas:** P1 (Post-MVP)
**User Story:** Sebagai manager, saya ingin lakukan stock opname periodik

**Fitur:**
- Generate list produk untuk opname
- Input qty fisik via scan atau manual
- Sistem hitung selisih (fisik vs sistem)
- Approval workflow untuk adjustment
- Generate laporan stock opname
- Auto-create adjustment record

**Acceptance Criteria:**
- [ ] Dapat generate daftar produk by kategori/lokasi
- [ ] Selisih otomatis terkalkulasi
- [ ] Require approval untuk adjustment > threshold
- [ ] Audit log lengkap setiap adjustment

---

### 4.3 Purchase Order
**Prioritas:** P1 (Post-MVP)
**User Story:** Sebagai owner, saya ingin buat PO untuk restock

**Fitur:**
- Create PO ke supplier
- Auto-suggest produk low stock
- Track PO status (draft, sent, partial received, completed)
- Receive stock from PO
- Update inventory saat receive
- Track supplier & supplier pricing

**Acceptance Criteria:**
- [ ] Dapat create PO dengan multiple items
- [ ] Stock otomatis bertambah saat mark as received
- [ ] Dapat track PO history

---

### 4.4 Stock Forecasting AI
**Prioritas:** P2 (Future Enhancement)
**User Story:** Sebagai owner, saya ingin prediksi demand untuk optimize stok

**Fitur:**
- ML model predict demand based on historical sales
- Consider seasonality, trend, promo
- Rekomendasi quantity to order
- Confidence interval
- Self-learning model improve over time

**Acceptance Criteria:**
- [ ] Forecast accuracy > 75% untuk produk fast-moving
- [ ] Rekomendasi order muncul di dashboard
- [ ] Model retrain otomatis setiap bulan

---

## 5. MODUL REPORTING & ANALYTICS

### 5.1 Sales Report
**Prioritas:** P0 (MVP)
**User Story:** Sebagai owner, saya ingin lihat laporan penjualan

**Fitur:**
- Sales by period (hari, minggu, bulan, custom range)
- Sales by product, kategori, kasir
- Chart: line chart, bar chart, pie chart
- Key metrics: total sales, qty sold, transactions count, avg transaction
- Export to PDF, Excel, CSV

**Metrics:**
- Total Penjualan (Gross Sales)
- Diskon
- Net Sales
- Jumlah Transaksi
- Rata-rata Transaksi
- Top 10 Produk
- Sales by Hour (peak hours analysis)

**Acceptance Criteria:**
- [ ] Report generate dalam < 5 detik untuk 1 bulan data
- [ ] Chart interactive dan responsive
- [ ] Export berhasil dengan format lengkap

---

### 5.2 Profit & Loss Report
**Prioritas:** P1 (Post-MVP)
**User Story:** Sebagai owner, saya ingin tahu profit saya

**Fitur:**
- Calculate profit per transaksi (harga jual - harga beli)
- Profit by product, kategori, period
- Include operational costs (optional)
- Profit margin %

**Acceptance Criteria:**
- [ ] Profit calculation accurate
- [ ] Dapat view profit by product
- [ ] Export laporan laba rugi

---

### 5.3 Inventory Report
**Prioritas:** P1 (Post-MVP)
**User Story:** Sebagai owner, saya ingin laporan inventory

**Fitur:**
- Current stock level all products
- Stock value (qty × harga beli)
- Low stock products
- Slow-moving products
- Dead stock analysis

**Acceptance Criteria:**
- [ ] Report real-time dengan data inventory terkini
- [ ] Dapat filter by kategori/lokasi
- [ ] Export ke Excel

---

### 5.4 Multi-Tenant Dashboard (Admin Pasar)
**Prioritas:** P2 (Future Enhancement)
**User Story:** Sebagai admin pasar, saya ingin dashboard semua tenant

**Fitur:**
- List all tenants dengan status
- Aggregate sales per tenant
- Tenant ranking by sales
- Alert tenant dengan issue (low stock, anomaly)
- Export consolidated report

**Acceptance Criteria:**
- [ ] Dashboard load all tenant data dalam < 10 detik
- [ ] Dapat drill-down ke detail tenant
- [ ] Export report per tenant atau aggregate

---

## 6. MODUL SYNC & OFFLINE

### 6.1 Offline Mode
**Prioritas:** P0 (MVP)
**User Story:** Sebagai kasir, saya ingin tetap bisa transaksi walau internet mati

**Fitur:**
- Local database SQLite untuk semua data
- Transaksi tersimpan lokal jika offline
- Queue system untuk sync saat online
- Conflict resolution strategy
- Sync status indicator di UI

**Data yang Disync:**
- Transactions
- Inventory updates
- Product changes
- User activities

**Sync Strategy:**
- Auto-sync setiap 5 menit jika online
- Manual sync button
- Background sync saat app idle
- Retry failed sync dengan exponential backoff

**Acceptance Criteria:**
- [ ] Transaksi berhasil di offline mode
- [ ] Data tersync otomatis saat online kembali
- [ ] No data loss saat offline
- [ ] Conflict resolution works correctly

---

## 7. MODUL HARDWARE INTEGRATION

### 7.1 Thermal Printer
**Prioritas:** P0 (MVP)
- Bluetooth printer support (ESC/POS protocol)
- USB printer support
- Auto-detect printer
- Test print function

### 7.2 Barcode Scanner
**Prioritas:** P0 (MVP)
- External Bluetooth scanner
- Camera as scanner (built-in)
- Support EAN, UPC, QR code

### 7.3 Timbangan Digital
**Prioritas:** P2 (Future)
- Bluetooth scale integration
- Auto-capture weight
- Calculate price by weight

---

## 8. MODUL PAYMENT INTEGRATION

### 8.1 QRIS Payment
**Prioritas:** P1 (Post-MVP)
**User Story:** Sebagai kasir, saya ingin terima pembayaran QRIS

**Fitur:**
- Generate QRIS code
- Check payment status
- Auto-complete transaksi saat payment confirmed

**Acceptance Criteria:**
- [ ] QRIS code generated dengan amount
- [ ] Payment callback update transaksi status
- [ ] Timeout 5 menit untuk QRIS

---

## 9. MODUL ANOMALY DETECTION

### 9.1 Fraud Detection
**Prioritas:** P2 (Future)
**User Story:** Sebagai owner, saya ingin deteksi aktivitas mencurigakan

**Fitur:**
- Deteksi void transaction berulang
- Deteksi return abnormal
- Deteksi discount berlebihan
- Alert dashboard untuk anomaly

**Acceptance Criteria:**
- [ ] Alert muncul saat terdeteksi anomaly
- [ ] False positive rate < 10%

---

## Priority Matrix

| Priority | Description | Target |
|----------|-------------|--------|
| P0 | MVP Must-Have | Sprint 1-3 (12 weeks) |
| P1 | Post-MVP Important | Sprint 4-6 (24 weeks) |
| P2 | Future Enhancement | Sprint 7+ (36+ weeks) |

## Feature Roadmap

**Phase 1 - MVP (Weeks 1-12)**
- Authentication & User Management
- POS Transaction (Basic)
- Product Management (Basic)
- Inventory (Basic)
- Sales Report (Basic)
- Offline Sync
- Receipt Printing

**Phase 2 - Enhancement (Weeks 13-24)**
- Product Detection AI
- Stock Opname
- Purchase Order
- Advanced Reports (P&L, Inventory)
- QRIS Payment
- Return/Refund

**Phase 3 - AI & Multi-tenant (Weeks 25-36)**
- Stock Forecasting
- Anomaly Detection
- Multi-tenant Dashboard
- Scale Integration
- Advanced Analytics


