# Architecture Diagrams - Aplikasi POS UMKM

## 1. High-Level System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        Mobile[Mobile App - Flutter]
        WebAdmin[Web Admin Dashboard]
    end
    
    subgraph "Edge Layer"
        Gateway[API Gateway - Kong/Nginx]
        LB[Load Balancer]
    end
    
    subgraph "Application Layer"
        AuthSvc[Auth Service]
        PosSvc[POS Transaction Service]
        InvSvc[Inventory Service]
        ProdSvc[Product Catalog Service]
        MLSvc[ML/AI Service]
        SyncSvc[Sync Service]
        ReportSvc[Reporting Service]
        NotifSvc[Notification Service]
        PaymentSvc[Payment Service]
    end
    
    subgraph "Data Layer"
        PG[(PostgreSQL - Primary DB)]
        Redis[(Redis - Cache)]
        ES[(ElasticSearch - Search)]
        S3[(S3/MinIO - Object Storage)]
    end
    
    subgraph "Event/Message Layer"
        Kafka[Apache Kafka - Event Stream]
    end
    
    subgraph "ML Pipeline"
        Training[Training Pipeline - Spark]
        FeatureStore[Feature Store]
        ModelRegistry[Model Registry - MLflow]
    end
    
    subgraph "Monitoring"
        Prometheus[Prometheus]
        Grafana[Grafana]
        Sentry[Sentry - Error Tracking]
        ELK[ELK Stack - Logging]
    end
    
    Mobile --> Gateway
    WebAdmin --> Gateway
    Gateway --> LB
    LB --> AuthSvc
    LB --> PosSvc
    LB --> InvSvc
    LB --> ProdSvc
    LB --> MLSvc
    LB --> SyncSvc
    LB --> ReportSvc
    LB --> NotifSvc
    LB --> PaymentSvc
    
    AuthSvc --> PG
    PosSvc --> PG
    PosSvc --> Kafka
    InvSvc --> PG
    InvSvc --> Kafka
    ProdSvc --> PG
    ProdSvc --> ES
    MLSvc --> ModelRegistry
    MLSvc --> S3
    SyncSvc --> PG
    ReportSvc --> PG
    ReportSvc --> ES
    NotifSvc --> Redis
    PaymentSvc --> PG
    
    AuthSvc --> Redis
    PosSvc --> Redis
    InvSvc --> Redis
    
    Kafka --> Training
    Training --> FeatureStore
    Training --> ModelRegistry
    
    PosSvc -.-> Prometheus
    InvSvc -.-> Prometheus
    MLSvc -.-> Prometheus
    Prometheus --> Grafana
    
    PosSvc -.-> Sentry
    InvSvc -.-> Sentry
    MLSvc -.-> Sentry
    
    PosSvc -.-> ELK
    InvSvc -.-> ELK
```

---

## 2. Mobile App Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[UI Widgets - Flutter]
        Screens[Screens - Feature Modules]
    end
    
    subgraph "Business Logic Layer"
        State[State Management - Riverpod/Bloc]
        UseCase[Use Cases]
        ViewModels[View Models]
    end
    
    subgraph "Data Layer"
        Repo[Repositories]
        LocalDS[Local Data Source]
        RemoteDS[Remote Data Source]
        SyncManager[Sync Manager]
    end
    
    subgraph "Local Storage"
        SQLite[(SQLite Database)]
        SecureStorage[Secure Storage]
        SharedPrefs[Shared Preferences]
    end
    
    subgraph "Network Layer"
        HTTP[HTTP Client - Dio]
        APIClient[API Client - Retrofit]
        Interceptors[Interceptors]
    end
    
    subgraph "Platform Services"
        Camera[Camera Service]
        Printer[Printer Service]
        Scanner[Scanner Service]
        ML[ML Inference - TFLite]
    end
    
    UI --> State
    Screens --> State
    State --> UseCase
    UseCase --> ViewModels
    ViewModels --> Repo
    
    Repo --> LocalDS
    Repo --> RemoteDS
    Repo --> SyncManager
    
    LocalDS --> SQLite
    LocalDS --> SecureStorage
    LocalDS --> SharedPrefs
    
    RemoteDS --> HTTP
    HTTP --> APIClient
    APIClient --> Interceptors
    
    SyncManager --> LocalDS
    SyncManager --> RemoteDS
    
    UseCase --> Camera
    UseCase --> Printer
    UseCase --> Scanner
    UseCase --> ML
```

---

## 3. Backend Microservices Architecture

```mermaid
graph LR
    subgraph "API Gateway"
        Gateway[Kong Gateway]
        Auth[Auth Plugin]
        RateLimit[Rate Limiter]
    end
    
    subgraph "Auth Service"
        AuthAPI[Auth API]
        JWT[JWT Manager]
        UserMgmt[User Management]
    end
    
    subgraph "Transaction Service"
        TxAPI[Transaction API]
        TxProcessor[Transaction Processor]
        InventoryUpdate[Inventory Updater]
    end
    
    subgraph "Inventory Service"
        InvAPI[Inventory API]
        StockManager[Stock Manager]
        LowStockMonitor[Low Stock Monitor]
    end
    
    subgraph "Product Service"
        ProdAPI[Product API]
        CatalogManager[Catalog Manager]
        SearchEngine[Search Engine]
    end
    
    subgraph "ML Service"
        MLAPI[ML API]
        Inference[Inference Engine]
        ModelLoader[Model Loader]
        FeedbackCollector[Feedback Collector]
    end
    
    subgraph "Sync Service"
        SyncAPI[Sync API]
        ConflictResolver[Conflict Resolver]
        QueueProcessor[Queue Processor]
    end
    
    Gateway --> Auth
    Gateway --> RateLimit
    Gateway --> AuthAPI
    Gateway --> TxAPI
    Gateway --> InvAPI
    Gateway --> ProdAPI
    Gateway --> MLAPI
    Gateway --> SyncAPI
    
    AuthAPI --> JWT
    AuthAPI --> UserMgmt
    
    TxAPI --> TxProcessor
    TxProcessor --> InventoryUpdate
    
    InvAPI --> StockManager
    StockManager --> LowStockMonitor
    
    ProdAPI --> CatalogManager
    CatalogManager --> SearchEngine
    
    MLAPI --> Inference
    Inference --> ModelLoader
    MLAPI --> FeedbackCollector
    
    SyncAPI --> ConflictResolver
    SyncAPI --> QueueProcessor
```

---

## 4. Data Flow Architecture (Transaction)

```mermaid
sequenceDiagram
    participant Kasir
    participant Mobile
    participant LocalDB
    participant SyncQueue
    participant APIGateway
    participant TxService
    participant InvService
    participant Kafka
    participant PostgreSQL
    
    Kasir->>Mobile: Scan Produk
    Mobile->>LocalDB: Query Produk
    LocalDB-->>Mobile: Produk Info
    
    Kasir->>Mobile: Confirm Payment
    Mobile->>LocalDB: BEGIN Transaction
    Mobile->>LocalDB: INSERT transaction
    Mobile->>LocalDB: INSERT transaction_items
    Mobile->>LocalDB: UPDATE inventory
    Mobile->>LocalDB: INSERT stock_movements
    Mobile->>LocalDB: COMMIT Transaction
    
    Mobile->>SyncQueue: Add Sync Job
    Mobile->>Kasir: Show Receipt
    
    Note over SyncQueue,APIGateway: Background Sync
    
    SyncQueue->>APIGateway: POST /sync/transactions
    APIGateway->>TxService: Validate & Process
    TxService->>PostgreSQL: Save Transaction
    TxService->>InvService: Update Inventory
    InvService->>PostgreSQL: Update Stock
    TxService->>Kafka: Publish Event
    Kafka-->>TxService: Event Confirmed
    TxService-->>APIGateway: 200 OK
    APIGateway-->>SyncQueue: Success
    SyncQueue->>LocalDB: Mark Synced
```

---

## 5. ML Pipeline Architecture

```mermaid
graph TB
    subgraph "Data Collection"
        App[Mobile App]
        DetectionEvents[Detection Events]
        UserFeedback[User Feedback]
    end
    
    subgraph "Data Ingestion"
        Kafka[Kafka Topic: ml.training.events]
        S3Raw[S3: Raw Data]
    end
    
    subgraph "Data Processing"
        Spark[Apache Spark]
        DataCleaning[Data Cleaning]
        FeatureEng[Feature Engineering]
        Labeling[Auto-Labeling]
    end
    
    subgraph "Feature Store"
        Feast[Feast Feature Store]
        Features[Processed Features]
    end
    
    subgraph "Model Training"
        TrainingJob[Training Job - Python]
        Hyperparameter[Hyperparameter Tuning]
        Validation[Model Validation]
    end
    
    subgraph "Model Registry"
        MLflow[MLflow Registry]
        Versioning[Model Versioning]
        Metrics[Metrics & Metadata]
    end
    
    subgraph "Model Deployment"
        TFServing[TF Serving - Cloud]
        TFLiteExport[TFLite Export]
        OTA[OTA Update Service]
    end
    
    subgraph "Inference"
        CloudInference[Cloud Inference API]
        EdgeInference[Edge Inference - Mobile]
    end
    
    App --> DetectionEvents
    App --> UserFeedback
    DetectionEvents --> Kafka
    UserFeedback --> Kafka
    
    Kafka --> S3Raw
    S3Raw --> Spark
    
    Spark --> DataCleaning
    DataCleaning --> FeatureEng
    FeatureEng --> Labeling
    Labeling --> Feast
    
    Feast --> Features
    Features --> TrainingJob
    
    TrainingJob --> Hyperparameter
    Hyperparameter --> Validation
    Validation --> MLflow
    
    MLflow --> Versioning
    MLflow --> Metrics
    
    Versioning --> TFServing
    Versioning --> TFLiteExport
    
    TFLiteExport --> OTA
    OTA --> EdgeInference
    
    TFServing --> CloudInference
    
    App --> CloudInference
    App --> EdgeInference
    
    CloudInference -.Feedback.-> Kafka
    EdgeInference -.Feedback.-> Kafka
```

---

## 6. Deployment Architecture (Kubernetes)

```mermaid
graph TB
    subgraph "Ingress Layer"
        Ingress[Ingress Controller]
        SSL[SSL/TLS Termination]
    end
    
    subgraph "API Layer Pods"
        Gateway1[API Gateway Pod 1]
        Gateway2[API Gateway Pod 2]
        Gateway3[API Gateway Pod 3]
    end
    
    subgraph "Service Layer Pods"
        Auth1[Auth Service Pod 1]
        Auth2[Auth Service Pod 2]
        
        Tx1[Transaction Service Pod 1]
        Tx2[Transaction Service Pod 2]
        Tx3[Transaction Service Pod 3]
        
        Inv1[Inventory Service Pod 1]
        Inv2[Inventory Service Pod 2]
        
        ML1[ML Service Pod 1]
        ML2[ML Service Pod 2]
    end
    
    subgraph "Data Layer"
        PGMaster[(PostgreSQL Master)]
        PGSlave1[(PostgreSQL Slave 1)]
        PGSlave2[(PostgreSQL Slave 2)]
        
        RedisCluster[(Redis Cluster)]
        ESCluster[(ElasticSearch Cluster)]
    end
    
    subgraph "Message Layer"
        KafkaBroker1[Kafka Broker 1]
        KafkaBroker2[Kafka Broker 2]
        KafkaBroker3[Kafka Broker 3]
    end
    
    subgraph "Storage Layer"
        PVC1[PVC - PostgreSQL]
        PVC2[PVC - Kafka]
        S3[S3 Storage]
    end
    
    subgraph "Monitoring"
        PrometheusPod[Prometheus Pod]
        GrafanaPod[Grafana Pod]
    end
    
    Ingress --> SSL
    SSL --> Gateway1
    SSL --> Gateway2
    SSL --> Gateway3
    
    Gateway1 --> Auth1
    Gateway1 --> Auth2
    Gateway2 --> Tx1
    Gateway2 --> Tx2
    Gateway2 --> Tx3
    Gateway3 --> Inv1
    Gateway3 --> Inv2
    
    Auth1 --> PGMaster
    Auth2 --> PGSlave1
    
    Tx1 --> PGMaster
    Tx2 --> PGSlave1
    Tx3 --> PGSlave2
    
    Tx1 --> KafkaBroker1
    Tx2 --> KafkaBroker2
    Tx3 --> KafkaBroker3
    
    Inv1 --> PGMaster
    Inv2 --> PGSlave1
    
    ML1 --> S3
    ML2 --> S3
    
    PGMaster --> PVC1
    KafkaBroker1 --> PVC2
    
    Auth1 -.-> PrometheusPod
    Tx1 -.-> PrometheusPod
    Inv1 -.-> PrometheusPod
    ML1 -.-> PrometheusPod
    
    PrometheusPod --> GrafanaPod
```

---

## 7. Network Architecture

```mermaid
graph TB
    subgraph "Public Internet"
        Users[Users - Mobile Apps]
        Admins[Admins - Web Dashboard]
    end
    
    subgraph "DMZ - Public Subnet"
        ALB[Application Load Balancer]
        WAF[Web Application Firewall]
        Bastion[Bastion Host]
    end
    
    subgraph "Application Subnet - Private"
        K8sCluster[Kubernetes Cluster]
        Pods[Application Pods]
    end
    
    subgraph "Data Subnet - Private"
        RDS[RDS PostgreSQL]
        ElastiCache[ElastiCache Redis]
        ES[ElasticSearch Domain]
    end
    
    subgraph "Storage Subnet"
        S3Bucket[S3 Buckets]
        EFS[EFS - Shared Storage]
    end
    
    subgraph "Monitoring Subnet"
        CloudWatch[CloudWatch]
        XRay[X-Ray]
    end
    
    Users --> WAF
    Admins --> WAF
    WAF --> ALB
    ALB --> K8sCluster
    K8sCluster --> Pods
    
    Pods --> RDS
    Pods --> ElastiCache
    Pods --> ES
    Pods --> S3Bucket
    Pods --> EFS
    
    Bastion --> K8sCluster
    Bastion --> RDS
    
    Pods -.-> CloudWatch
    Pods -.-> XRay
```

---

## 8. Security Architecture

```mermaid
graph TB
    subgraph "Client Security"
        AppEncryption[App Code Obfuscation]
        SQLCipher[SQLite Encryption]
        SecureStorage[Secure Storage - Keychain]
        CertPinning[Certificate Pinning]
    end
    
    subgraph "Transport Security"
        TLS[TLS 1.3]
        mTLS[Mutual TLS - Optional]
    end
    
    subgraph "API Gateway Security"
        WAF[WAF Rules]
        RateLimit[Rate Limiting]
        IPWhitelist[IP Whitelisting]
        JWTValidation[JWT Validation]
    end
    
    subgraph "Application Security"
        RBAC[Role-Based Access Control]
        InputValidation[Input Validation]
        SQLInjectionPrev[SQL Injection Prevention]
        XSSPrevention[XSS Prevention]
    end
    
    subgraph "Data Security"
        Encryption[Data Encryption at Rest]
        RLS[Row-Level Security]
        BackupEncryption[Backup Encryption]
        TokenEncryption[Token Encryption]
    end
    
    subgraph "Network Security"
        VPC[VPC Isolation]
        SecurityGroups[Security Groups]
        NACLs[Network ACLs]
        PrivateSubnets[Private Subnets]
    end
    
    subgraph "Monitoring & Audit"
        AuditLogs[Audit Logging]
        SIEM[SIEM Integration]
        Alerting[Security Alerting]
        PenetrationTest[Penetration Testing]
    end
    
    AppEncryption --> TLS
    SQLCipher --> TLS
    SecureStorage --> TLS
    CertPinning --> TLS
    
    TLS --> WAF
    WAF --> RateLimit
    RateLimit --> IPWhitelist
    IPWhitelist --> JWTValidation
    
    JWTValidation --> RBAC
    RBAC --> InputValidation
    InputValidation --> SQLInjectionPrev
    SQLInjectionPrev --> XSSPrevention
    
    XSSPrevention --> Encryption
    Encryption --> RLS
    RLS --> BackupEncryption
    BackupEncryption --> TokenEncryption
    
    TokenEncryption --> VPC
    VPC --> SecurityGroups
    SecurityGroups --> NACLs
    NACLs --> PrivateSubnets
    
    PrivateSubnets --> AuditLogs
    AuditLogs --> SIEM
    SIEM --> Alerting
    Alerting --> PenetrationTest
```

---

## 9. Disaster Recovery Architecture

```mermaid
graph TB
    subgraph "Primary Region - us-west-2"
        Primary[Primary Cluster]
        PrimaryDB[(Primary DB)]
        PrimaryS3[Primary S3]
    end
    
    subgraph "DR Region - us-east-1"
        DR[DR Cluster - Standby]
        DRDB[(DR DB - Replica)]
        DRS3[DR S3 - Cross-Region Replication]
    end
    
    subgraph "Backup Storage"
        Glacier[Glacier - Long-term Backups]
    end
    
    subgraph "Monitoring & Failover"
        HealthCheck[Health Check]
        Route53[Route53 - DNS Failover]
        SNS[SNS Alerts]
    end
    
    Primary --> PrimaryDB
    Primary --> PrimaryS3
    
    PrimaryDB -->|Streaming Replication| DRDB
    PrimaryS3 -->|Cross-Region Replication| DRS3
    
    PrimaryDB -->|Daily Backup| Glacier
    
    HealthCheck --> Primary
    HealthCheck --> DR
    
    HealthCheck -->|Unhealthy| Route53
    Route53 -->|Failover| DR
    
    HealthCheck -->|Alert| SNS
```

---

## 10. CI/CD Pipeline Architecture

```mermaid
graph LR
    subgraph "Source Control"
        GitHub[GitHub Repository]
        Branch[Feature Branch]
    end
    
    subgraph "CI Pipeline"
        Trigger[Push Trigger]
        Lint[Linting]
        UnitTest[Unit Tests]
        IntegrationTest[Integration Tests]
        Build[Build]
        Scan[Security Scan]
    end
    
    subgraph "Artifact Registry"
        DockerRegistry[Docker Registry]
        ModelRegistry[Model Registry]
    end
    
    subgraph "CD Pipeline - Staging"
        DeployStaging[Deploy to Staging]
        E2ETest[E2E Tests]
        PerformanceTest[Performance Tests]
    end
    
    subgraph "CD Pipeline - Production"
        ManualApproval[Manual Approval]
        DeployProd[Deploy to Production]
        BlueGreen[Blue-Green Deployment]
        Rollback[Auto Rollback on Failure]
    end
    
    subgraph "Monitoring"
        HealthCheck[Health Check]
        Metrics[Metrics Collection]
        Alerts[Alert on Issues]
    end
    
    GitHub --> Branch
    Branch --> Trigger
    Trigger --> Lint
    Lint --> UnitTest
    UnitTest --> IntegrationTest
    IntegrationTest --> Build
    Build --> Scan
    
    Scan --> DockerRegistry
    Scan --> ModelRegistry
    
    DockerRegistry --> DeployStaging
    DeployStaging --> E2ETest
    E2ETest --> PerformanceTest
    
    PerformanceTest --> ManualApproval
    ManualApproval --> DeployProd
    DeployProd --> BlueGreen
    
    BlueGreen --> HealthCheck
    HealthCheck --> Metrics
    Metrics --> Alerts
    
    Alerts -->|Failure| Rollback
    Rollback --> BlueGreen
```

---

## Architecture Decision Records (ADR)

### ADR-001: Offline-First Architecture
**Decision**: Use local SQLite database with sync queue  
**Rationale**: Target users have unreliable internet  
**Consequences**: Increased complexity in conflict resolution, but 100% availability for core features

### ADR-002: Event-Driven with Kafka
**Decision**: Use Kafka for inter-service communication  
**Rationale**: Need scalability and decoupling  
**Consequences**: Added infrastructure complexity, but better scalability

### ADR-003: On-Device ML with Cloud Fallback
**Decision**: TFLite on device, cloud inference for low confidence  
**Rationale**: Balance between latency and accuracy  
**Consequences**: Larger app size, but better UX

### ADR-004: Multi-Tenant with RLS
**Decision**: Single database with Row-Level Security  
**Rationale**: Cost efficiency for startup phase  
**Consequences**: Need careful security implementation, but reduced operational cost

### ADR-005: Microservices over Monolith
**Decision**: Start with modular monolith, extract to microservices gradually  
**Rationale**: Faster initial development, scale as needed  
**Consequences**: Some coupling initially, but easier to start

---

## Performance Benchmarks

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Transaction Processing | < 2s | TBD | 🟡 |
| Product Search | < 500ms | TBD | 🟡 |
| ML Inference (on-device) | < 2s | TBD | 🟡 |
| Sync Latency | < 5s | TBD | 🟡 |
| API Response Time (p95) | < 200ms | TBD | 🟡 |
| Database Query (p95) | < 100ms | TBD | 🟡 |

---

## Capacity Planning

### Phase 1 (100 stores)
- **App Servers**: 2 nodes (4 vCPU, 16GB RAM each)
- **Database**: 1 master + 1 replica (8 vCPU, 32GB RAM)
- **Redis**: 1 cluster (2GB)
- **Kafka**: 3 brokers (2 vCPU, 8GB RAM each)
- **Estimated Cost**: $500-800/month

### Phase 2 (500 stores)
- **App Servers**: 5 nodes (8 vCPU, 32GB RAM each)
- **Database**: 1 master + 2 replicas (16 vCPU, 64GB RAM)
- **Redis**: 1 cluster (8GB)
- **Kafka**: 3 brokers (4 vCPU, 16GB RAM each)
- **Estimated Cost**: $2000-3000/month

### Phase 3 (1000+ stores)
- **App Servers**: Auto-scaling 10-50 nodes
- **Database**: Sharded + Replicas
- **Redis**: Cluster mode (32GB+)
- **Kafka**: 5+ brokers
- **Estimated Cost**: $5000-10000/month


