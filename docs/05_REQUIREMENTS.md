# Requirements - Aplikasi POS UMKM

## 1. TECHNOLOGY STACK

### 1.1 Mobile Application (Client)

#### Framework & Language
- **Flutter 3.x** - Cross-platform framework (prioritas Android)
- **Dart 3.x** - Programming language
- **Alasan**: Cepat develop, single codebase, offline-first support

#### State Management
- **Riverpod 2.x** atau **Bloc 8.x**
- **Alasan**: Reactive, testable, maintainable

#### Local Database
- **sqflite 2.x** - SQLite untuk Flutter
- **sqflite_sqlcipher** - Untuk database encryption
- **drift** (optional) - Type-safe SQL queries

#### Network & API
- **dio 5.x** - HTTP client dengan interceptors
- **retrofit** - Type-safe REST client
- **connectivity_plus** - Network connectivity check

#### Storage
- **flutter_secure_storage** - Secure storage untuk tokens
- **shared_preferences** - App settings
- **path_provider** - File system access

#### ML/AI
- **tflite_flutter** - TensorFlow Lite untuk on-device inference
- **image_picker** - Camera & gallery access
- **image** - Image processing
- **camera** - Camera control

#### Hardware Integration
- **blue_thermal_printer** - Bluetooth thermal printer
- **flutter_barcode_scanner** - Barcode/QR scanner
- **esc_pos_utils** - ESC/POS protocol untuk printer

#### UI/UX
- **material 3** - Material Design 3
- **flutter_slidable** - Swipe actions
- **shimmer** - Loading skeletons
- **cached_network_image** - Image caching
- **fl_chart** - Charts untuk reports

#### Other Dependencies
- **intl** - Internationalization & date formatting
- **uuid** - UUID generation
- **pdf** - PDF generation untuk receipts
- **url_launcher** - External links
- **permission_handler** - Runtime permissions

---

### 1.2 Backend Services

#### Framework
- **Option 1: Node.js + NestJS** (Recommended untuk fast development)
  - TypeScript based
  - Modular architecture
  - Built-in DI, validation, documentation
  
- **Option 2: Scala + Play Framework** (Sesuai PRD, untuk scalability)
  - Type-safe
  - Reactive
  - High performance

- **Option 3: Go + Gin/Echo** (Alternative untuk lightweight & fast)

#### Database
- **PostgreSQL 15+** - Primary relational database
  - JSONB support
  - Full-text search
  - Row-level security
  - Partitioning support

- **Redis 7+** - Caching & session storage
  - Cache query results
  - Rate limiting
  - Pub/sub untuk notifications

- **ElasticSearch 8+** (Optional) - Search & analytics
  - Product search
  - Log aggregation
  - Analytics queries

#### Event Streaming
- **Apache Kafka** - Event streaming
  - Transaction events
  - Inventory updates
  - ML training data pipeline
  
- **Alternative: RabbitMQ** - Lebih simple untuk start

#### Object Storage
- **MinIO** - Self-hosted S3-compatible storage
- **AWS S3** - Cloud storage
- **Untuk**: Product images, ML models, backups

#### ML/AI Stack
- **TensorFlow 2.x / PyTorch** - Model training
- **TensorFlow Lite** - Mobile deployment
- **ONNX** - Model interchange format
- **Apache Spark (Scala)** - Batch processing untuk training
- **MLflow** - ML lifecycle management
- **Feature Store (Feast)** - Feature management

#### API Gateway
- **Kong** atau **Nginx** - API gateway
- **Rate limiting**
- **Authentication**
- **Load balancing**

#### Authentication
- **JWT** - Token-based auth
- **Passport.js** (Node) atau **Keycloak** - Identity provider
- **bcrypt** - Password hashing

---

### 1.3 DevOps & Infrastructure

#### Containerization
- **Docker** - Containerization
- **Docker Compose** - Local development

#### Orchestration
- **Kubernetes** - Production orchestration
- **Helm** - Package manager untuk K8s

#### CI/CD
- **GitHub Actions** atau **GitLab CI**
- **Automated testing**
- **Automated deployment**

#### Monitoring
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Sentry** - Error tracking
- **ELK Stack** (ElasticSearch, Logstash, Kibana) - Log management

#### Cloud Provider
- **AWS** - Full featured (EC2, RDS, S3, EKS)
- **Google Cloud Platform** - Alternative
- **DigitalOcean** - Budget friendly untuk start
- **On-premise** - Untuk pasar tradisional dengan dedicated server

---

## 2. HARDWARE REQUIREMENTS

### 2.1 Kasir/POS Device

#### Minimum Specs
- **Android Tablet 10"**
- **OS**: Android 8.0+ (API level 26+)
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 16GB minimum, 32GB recommended
- **Camera**: 8MP+ untuk product detection
- **Connectivity**: WiFi 802.11n, Bluetooth 4.0+
- **Battery**: 5000mAh+ untuk full day usage

#### Recommended Devices
- **Samsung Galaxy Tab A** series
- **Huawei MediaPad** series
- **Lenovo Tab** series
- **Budget**: $150-300

### 2.2 Thermal Printer

#### Specs
- **Width**: 58mm atau 80mm
- **Connectivity**: Bluetooth atau USB
- **Protocol**: ESC/POS
- **Speed**: 50-90mm/s
- **Compatible brands**: Epson, Xprinter, Rongta, Goojprt
- **Budget**: $50-150

### 2.3 Barcode Scanner (Optional)

#### Specs
- **Type**: Bluetooth atau Wired USB
- **Format**: 1D (EAN, UPC, Code128) + 2D (QR Code)
- **Range**: 10-20cm
- **Compatible brands**: Inateck, Eyoyo, Tera
- **Budget**: $30-80
- **Alternative**: Use camera scanner (built-in)

### 2.4 Timbangan Digital (Optional - Future)

#### Specs
- **Capacity**: 5-30kg
- **Accuracy**: 1-5g
- **Connectivity**: Bluetooth atau Serial (RS232)
- **Budget**: $50-200

### 2.5 Server (Backend)

#### Small-Medium Deployment (100-500 toko)
- **CPU**: 4-8 cores
- **RAM**: 16-32GB
- **Storage**: 500GB SSD
- **Bandwidth**: 100Mbps
- **Cloud VM**: AWS t3.xlarge atau DigitalOcean Professional ($80-160/month)

#### Large Deployment (500+ toko)
- **Kubernetes Cluster**: 3+ nodes
- **Load balancer**
- **Database**: Managed PostgreSQL (AWS RDS, GCP Cloud SQL)
- **Object Storage**: S3
- **Monthly Cost**: $500-2000+ depending on scale

---

## 3. FUNCTIONAL REQUIREMENTS

### 3.1 MVP (Phase 1) - Priority P0

#### Authentication & User Management
- [ ] Login/logout dengan username & password
- [ ] JWT token authentication
- [ ] Role-based access control (Owner, Manager, Kasir)
- [ ] User CRUD operations
- [ ] Password reset functionality

#### POS Transaction
- [ ] Product search (nama, SKU, barcode)
- [ ] Barcode scanning (camera atau external scanner)
- [ ] Add/remove items dari cart
- [ ] Edit quantity
- [ ] Apply discount (% atau nominal)
- [ ] Multiple payment methods (Cash, QRIS, E-Wallet)
- [ ] Calculate change
- [ ] Generate & print receipt
- [ ] Hold/park transaction
- [ ] Transaction history

#### Product Management
- [ ] CRUD products (nama, SKU, harga, kategori, foto)
- [ ] Upload product photos
- [ ] Category management
- [ ] Barcode generation
- [ ] Product activation/deactivation
- [ ] Product search & filter

#### Inventory Management
- [ ] Real-time stock tracking per location
- [ ] Auto-deduct stock saat transaksi
- [ ] Stock movement history
- [ ] Low stock alert
- [ ] Multiple locations (toko, gudang)
- [ ] View current stock levels

#### Reporting
- [ ] Sales report (daily, weekly, monthly)
- [ ] Transaction list with filter
- [ ] Top selling products
- [ ] Sales by category
- [ ] Sales by cashier
- [ ] Export to CSV/PDF

#### Offline Mode
- [ ] Local SQLite database
- [ ] Offline transaction processing
- [ ] Sync queue management
- [ ] Auto-sync when online
- [ ] Manual sync trigger
- [ ] Sync status indicator
- [ ] Conflict resolution

#### Hardware Integration
- [ ] Bluetooth thermal printer
- [ ] Receipt printing (auto & manual)
- [ ] Barcode scanner (external or camera)
- [ ] Print test function

---

### 3.2 Post-MVP (Phase 2) - Priority P1

#### Product Detection AI
- [ ] Camera-based product recognition
- [ ] On-device ML inference (TFLite)
- [ ] Top-3 predictions dengan confidence
- [ ] Fallback to cloud inference
- [ ] Feedback loop untuk labeling
- [ ] Model versioning & OTA updates

#### Advanced Inventory
- [ ] Stock opname/adjustment
- [ ] Transfer stock antar lokasi
- [ ] Purchase order management
- [ ] Receive stock from PO
- [ ] Batch & expiry date tracking

#### Return & Refund
- [ ] Return transaction
- [ ] Partial return
- [ ] Refund processing
- [ ] Return receipt
- [ ] Stock adjustment pada return

#### Advanced Reporting
- [ ] Profit & Loss report
- [ ] Inventory valuation report
- [ ] Slow-moving product analysis
- [ ] Sales trend analysis
- [ ] Custom date range reports

#### Payment Integration
- [ ] QRIS payment gateway
- [ ] E-wallet integration (GoPay, OVO, Dana)
- [ ] Payment callback handling
- [ ] Payment reconciliation

#### Customer Management
- [ ] Customer database
- [ ] Customer phone/name tracking
- [ ] Purchase history per customer
- [ ] Customer loyalty points (optional)

---

### 3.3 Future Enhancements (Phase 3) - Priority P2

#### AI/ML Features
- [ ] Stock forecasting & demand prediction
- [ ] Auto-reorder recommendations
- [ ] Anomaly detection (fraud, void patterns)
- [ ] Pricing optimization suggestions
- [ ] Self-learning model improvement

#### Multi-tenant & Marketplace
- [ ] Admin dashboard untuk pengelola pasar
- [ ] Multi-tenant reporting
- [ ] Cross-tenant order (marketplace)
- [ ] Tenant analytics
- [ ] Revenue sharing calculation

#### Advanced Features
- [ ] Scale/weight integration
- [ ] Shelf monitoring via fixed camera
- [ ] Voice assistant untuk kasir
- [ ] Smart catalog importer (OCR)
- [ ] WhatsApp notification integration
- [ ] Accounting software export

---

## 4. NON-FUNCTIONAL REQUIREMENTS

### 4.1 Performance
- [ ] Transaction processing < 2 detik
- [ ] Product search response < 500ms
- [ ] ML inference < 2 detik on-device
- [ ] Sync latency < 5 detik when online
- [ ] Receipt print < 3 detik
- [ ] App startup < 3 detik
- [ ] Database query optimization untuk 10k+ products
- [ ] Support 100+ concurrent users per server

### 4.2 Scalability
- [ ] Horizontal scaling via Kubernetes
- [ ] Database partitioning untuk large datasets
- [ ] Caching strategy untuk read-heavy operations
- [ ] CDN untuk static assets
- [ ] Load balancing untuk multiple instances
- [ ] Support 1000+ tenants

### 4.3 Reliability
- [ ] 99.5% uptime SLA
- [ ] Automatic failover untuk database
- [ ] Data replication (master-slave)
- [ ] Zero data loss pada offline mode
- [ ] Graceful degradation saat partial outage
- [ ] Circuit breaker untuk external services

### 4.4 Security
- [ ] TLS 1.3 untuk API communication
- [ ] Database encryption at rest (AES-256)
- [ ] JWT token dengan refresh mechanism
- [ ] Token expiry: 24h access, 30d refresh
- [ ] Password hashing dengan bcrypt (cost 12)
- [ ] Input validation & sanitization
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] Rate limiting (100 req/min per user)
- [ ] RBAC enforcement
- [ ] Audit logging untuk sensitive operations
- [ ] Secure storage untuk credentials
- [ ] PCI DSS compliance untuk payment (jika applicable)

### 4.5 Availability
- [ ] Offline-first architecture
- [ ] Local data persistence
- [ ] Works without internet for core POS functions
- [ ] Background sync saat online
- [ ] Graceful error handling
- [ ] User-friendly error messages

### 4.6 Maintainability
- [ ] Modular architecture
- [ ] Clean code practices
- [ ] Code documentation
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Unit test coverage > 70%
- [ ] Integration tests untuk critical flows
- [ ] CI/CD automation
- [ ] Logging & monitoring
- [ ] Version control (Git)

### 4.7 Usability
- [ ] Intuitive UI untuk kasir dengan minimal training
- [ ] Touch-optimized untuk tablet
- [ ] Large buttons (min 48x48dp)
- [ ] High contrast colors
- [ ] Bahasa Indonesia (primary)
- [ ] Responsive layout
- [ ] Loading indicators
- [ ] Confirmation dialogs untuk destructive actions
- [ ] Keyboard shortcuts (optional)

### 4.8 Compatibility
- [ ] Android 8.0+ (API level 26+)
- [ ] Support multiple screen sizes (phone & tablet)
- [ ] Support multiple printers (ESC/POS standard)
- [ ] Support multiple payment gateways
- [ ] Backward compatible database migrations

---

## 5. DATA REQUIREMENTS

### 5.1 Data Volume Estimates

#### Per Toko per Tahun
- **Products**: 500-2000 items
- **Transactions**: 30k-100k (100-300/day)
- **Transaction Items**: 150k-500k (5 items avg per transaction)
- **Stock Movements**: 60k-200k
- **Event Logs**: 200k-500k
- **Images**: 1-5GB (product photos)

#### Storage Requirements
- **Local DB**: 250MB-1GB per year per toko
- **Backend DB**: 1-5GB per year per 100 toko
- **Object Storage**: 10-50GB per 100 toko

### 5.2 Backup & Retention
- **Local Backup**: Daily backup ke cloud storage
- **Backend Backup**: 
  - Full backup: Daily
  - Incremental: Hourly
  - Retention: 30 days full, 7 days incremental
- **Transaction Data**: 7 years (requirement pajak Indonesia)
- **Event Logs**: 90 days online, archive to cold storage

---

## 6. INTEGRATION REQUIREMENTS

### 6.1 Payment Gateways
- [ ] **QRIS** (Prioritas)
  - OY! Indonesia
  - Xendit
  - Midtrans
- [ ] **E-Wallet**
  - GoPay
  - OVO
  - DANA
  - ShopeePay

### 6.2 Notification Services
- [ ] **SMS Gateway** (optional)
  - Twilio
  - Nexmo
  - Local provider
- [ ] **WhatsApp Business API**
  - For receipts & notifications

### 6.3 Cloud Storage
- [ ] AWS S3
- [ ] Google Cloud Storage
- [ ] MinIO (self-hosted)

### 6.4 Analytics (Optional)
- [ ] Google Analytics
- [ ] Firebase Analytics
- [ ] Mixpanel

### 6.5 Accounting Export
- [ ] CSV export
- [ ] Excel format
- [ ] Integration dengan software akuntansi lokal

---

## 7. COMPLIANCE & LEGAL

### 7.1 Data Privacy
- [ ] Comply dengan UU Perlindungan Data Pribadi Indonesia
- [ ] Privacy policy
- [ ] Terms of service
- [ ] Data retention policy
- [ ] Right to delete data (GDPR-like)

### 7.2 Tax Compliance
- [ ] Support PPN (Pajak Pertambahan Nilai)
- [ ] Tax report generation
- [ ] Integration dengan e-Faktur (optional)

### 7.3 Business License
- [ ] Comply dengan regulasi POS Indonesia
- [ ] Financial transaction compliance

---

## 8. DEVELOPMENT REQUIREMENTS

### 8.1 Team Composition
- **Product Manager**: 1
- **UI/UX Designer**: 1
- **Mobile Developer** (Flutter): 2
- **Backend Developer**: 2-3
- **ML/Data Engineer**: 1-2
- **DevOps Engineer**: 1
- **QA Engineer**: 1
- **Support & Sales**: 2

### 8.2 Development Environment
- **Version Control**: Git (GitHub/GitLab)
- **Project Management**: Jira, Linear, atau Trello
- **Design**: Figma
- **Documentation**: Notion, Confluence
- **Communication**: Slack, Discord

### 8.3 Testing Requirements
- **Unit Tests**: Jest (backend), Flutter test (mobile)
- **Integration Tests**: Supertest, Flutter integration test
- **E2E Tests**: Cypress, Flutter driver
- **Performance Tests**: JMeter, k6
- **Security Tests**: OWASP ZAP, SonarQube

---

## 9. TIMELINE & MILESTONES

### Phase 1: MVP (Week 1-12)
- **Week 1-2**: Setup, architecture, design system
- **Week 3-5**: Core POS features (transaction, product)
- **Week 6-7**: Inventory & offline sync
- **Week 8-9**: Reporting & printer integration
- **Week 10-11**: Testing & bug fixing
- **Week 12**: Pilot deployment & feedback

### Phase 2: Enhancement (Week 13-24)
- **Week 13-16**: Product detection AI
- **Week 17-19**: Advanced inventory & PO
- **Week 20-22**: Payment integration & return
- **Week 23-24**: Testing & refinement

### Phase 3: Scale (Week 25+)
- **Week 25-30**: Multi-tenant & analytics
- **Week 31-36**: ML forecasting & anomaly detection
- **Ongoing**: Iteration based on user feedback

---

## 10. BUDGET ESTIMATES

### Development (MVP - 12 weeks)
- **Team Salary**: $30k-60k (depending on location)
- **Infrastructure**: $500-1000
- **Tools & Licenses**: $500-1000
- **Hardware (testing)**: $1000-2000
- **Total**: $32k-64k

### Operational (per month)
- **Cloud Infrastructure**: $500-2000
- **Object Storage**: $50-200
- **Domain & SSL**: $10-50
- **Payment Gateway Fees**: Variable (0.5-2% transaction)
- **Support & Marketing**: Variable

### Per-Customer Cost
- **Hardware Bundle**: $200-400 (tablet + printer + scanner)
- **Optional Subsidy**: $50-150 per customer
- **Onboarding & Training**: $50-100 per customer

---

## 11. SUCCESS METRICS (KPI)

### Product Metrics
- **Active Users**: Target 1000 toko in year 1
- **Daily Active Users (DAU)**: 70%+ of registered
- **Transactions per Day**: Avg 100+ per toko
- **Offline Uptime**: 99.9% (no blocks during offline)
- **Sync Success Rate**: 99%+
- **App Crash Rate**: <0.5%

### Business Metrics
- **Monthly Recurring Revenue (MRR)**: Target $15k by month 12
- **Customer Acquisition Cost (CAC)**: <$50
- **Customer Lifetime Value (LTV)**: >$500
- **Churn Rate**: <5% monthly
- **Net Promoter Score (NPS)**: >50

### AI Model Metrics
- **Product Detection Accuracy**: >80% top-1, >95% top-3
- **Forecasting MAPE**: <25%
- **Anomaly Detection Precision**: >70%, Recall >60%


