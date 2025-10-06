# Flow Diagrams - Aplikasi POS UMKM

## Overview
Dokumen ini berisi flow diagram untuk semua user journey utama dalam aplikasi POS.

---

## 1. LOGIN FLOW

```mermaid
flowchart TD
    Start([User Buka App]) --> CheckAuth{Auth Token\nValid?}
    CheckAuth -->|Yes| MainDashboard[Dashboard]
    CheckAuth -->|No| LoginScreen[Login Screen]
    
    LoginScreen --> InputCred[Input Username & Password]
    InputCred --> ValidateLocal{Validate\nFormat}
    
    ValidateLocal -->|Invalid| ShowError1[Show Error: Invalid Format]
    ShowError1 --> InputCred
    
    ValidateLocal -->|Valid| CheckOnline{Online?}
    
    CheckOnline -->|Yes| APIAuth[POST /api/auth/login]
    APIAuth --> CheckCred{Credentials\nValid?}
    
    CheckCred -->|No| FailedAttempt[Increment Failed Attempts]
    FailedAttempt --> CheckLock{Attempts >= 5?}
    CheckLock -->|Yes| LockAccount[Lock Account 15 min]
    CheckLock -->|No| ShowError2[Show Error: Invalid Credentials]
    ShowError2 --> InputCred
    
    CheckCred -->|Yes| SaveToken[Save JWT Token\nSecure Storage]
    SaveToken --> SyncData[Sync Master Data:\nProducts, Categories, Users]
    SyncData --> SaveLocal[Save to Local DB]
    SaveLocal --> MainDashboard
    
    CheckOnline -->|No| OfflineAuth[Validate Against\nLocal DB]
    OfflineAuth --> CheckLocalCred{Valid?}
    CheckLocalCred -->|Yes| SetOfflineMode[Set Offline Mode Flag]
    SetOfflineMode --> MainDashboard
    CheckLocalCred -->|No| ShowError3[Show Error: Invalid or\nNo Offline Data]
    ShowError3 --> InputCred
    
    LockAccount --> End1([End: Locked])
    MainDashboard --> End2([Success: Logged In])
```

---

## 2. TRANSACTION FLOW (Happy Path)

```mermaid
flowchart TD
    Start([Kasir: Mulai Transaksi]) --> Dashboard[POS Dashboard]
    Dashboard --> NewTx[Tap: New Transaction]
    NewTx --> EmptyCart[Initialize Empty Cart]
    
    EmptyCart --> AddProduct{Tambah Produk}
    
    AddProduct -->|Scan Barcode| ScanBarcode[Scan Barcode]
    ScanBarcode --> FindProduct1[Query Product by Barcode]
    FindProduct1 --> ProductFound1{Found?}
    ProductFound1 -->|Yes| AddToCart1[Add to Cart]
    ProductFound1 -->|No| ShowError1[Show Error: Product Not Found]
    ShowError1 --> AddProduct
    
    AddProduct -->|Search Manual| SearchProduct[Search by Name/SKU]
    SearchProduct --> ShowResults[Show Product List]
    ShowResults --> SelectProduct[Select Product]
    SelectProduct --> AddToCart1
    
    AddProduct -->|Scan Camera| CameraDetection[Product Detection Flow]
    CameraDetection --> AddToCart1
    
    AddToCart1 --> CheckStock{Stock\nAvailable?}
    CheckStock -->|No| ShowError2[Show Error: Out of Stock]
    ShowError2 --> AddProduct
    CheckStock -->|Yes| AddToCart2[Add to Cart with Qty]
    
    AddToCart2 --> UpdateCart[Update Cart Display]
    UpdateCart --> MoreProducts{Tambah\nProduk Lagi?}
    MoreProducts -->|Yes| AddProduct
    
    MoreProducts -->|No| ShowSummary[Show Transaction Summary:\nSubtotal, Items Count]
    ShowSummary --> ApplyDiscount{Apply\nDiscount?}
    
    ApplyDiscount -->|Yes| InputDiscount[Input Discount %/Nominal]
    InputDiscount --> ValidateDiscount{Valid?}
    ValidateDiscount -->|No| ShowError3[Show Error]
    ShowError3 --> InputDiscount
    ValidateDiscount -->|Yes| RecalculateTotal[Recalculate Total]
    
    ApplyDiscount -->|No| RecalculateTotal
    RecalculateTotal --> ShowFinalTotal[Show Final Total]
    
    ShowFinalTotal --> SelectPayment[Select Payment Method]
    SelectPayment --> PaymentMethod{Payment\nMethod}
    
    PaymentMethod -->|Cash| InputCash[Input Amount Paid]
    InputCash --> CalculateChange[Calculate Change]
    CalculateChange --> ShowChange[Show Change Amount]
    ShowChange --> ConfirmPayment
    
    PaymentMethod -->|QRIS| GenerateQRIS[Generate QRIS Code]
    GenerateQRIS --> WaitPayment[Wait Payment Confirmation]
    WaitPayment --> PaymentStatus{Payment\nSuccess?}
    PaymentStatus -->|No| ShowError4[Show Error: Payment Failed]
    ShowError4 --> SelectPayment
    PaymentStatus -->|Yes| ConfirmPayment
    
    PaymentMethod -->|E-Wallet| ProcessEwallet[Process E-Wallet]
    ProcessEwallet --> ConfirmPayment
    
    ConfirmPayment[Confirm Transaction] --> SaveTransaction[BEGIN Transaction]
    SaveTransaction --> InsertTx[Insert to transactions table]
    InsertTx --> InsertItems[Insert transaction_items]
    InsertItems --> UpdateInventory[Update inventory qty]
    UpdateInventory --> InsertMovement[Insert stock_movements]
    InsertMovement --> AddSyncQueue[Add to sync_queue]
    AddSyncQueue --> LogEvent[Insert event_logs]
    LogEvent --> CommitTx[COMMIT Transaction]
    
    CommitTx --> GenerateReceipt[Generate Receipt]
    GenerateReceipt --> PrintReceipt[Print Receipt]
    PrintReceipt --> ShowSuccess[Show Success Message]
    
    ShowSuccess --> NextAction{Next\nAction?}
    NextAction -->|New Transaction| NewTx
    NextAction -->|Dashboard| Dashboard
    NextAction --> End([End])
```

---

## 3. PRODUCT DETECTION (AI) FLOW

```mermaid
flowchart TD
    Start([Kasir: Scan via Camera]) --> OpenCamera[Open Camera UI]
    OpenCamera --> TakePhoto[Take Photo]
    TakePhoto --> ShowPreview[Show Photo Preview]
    
    ShowPreview --> Confirm{Foto OK?}
    Confirm -->|No| TakePhoto
    
    Confirm -->|Yes| SaveImage[Save Image Locally]
    SaveImage --> PreprocessImage[Preprocess Image:\nResize 224x224,\nNormalize]
    
    PreprocessImage --> CheckModel{Local Model\nAvailable?}
    CheckModel -->|No| DownloadModel[Download TFLite Model]
    DownloadModel --> LoadModel
    
    CheckModel -->|Yes| LoadModel[Load TFLite Model]
    LoadModel --> RunInference[Run Inference]
    
    RunInference --> GetPredictions[Get Top 3 Predictions\nwith Confidence]
    GetPredictions --> CheckConfidence{Top 1\nConfidence > 90%?}
    
    CheckConfidence -->|Yes| ShowResults[Show Top 3 Results\nHighlight Top 1]
    
    CheckConfidence -->|No| CloudInference{Online?}
    CloudInference -->|Yes| CallCloudAPI[POST /api/ml/detect]
    CallCloudAPI --> GetCloudPredictions[Get Cloud Predictions]
    GetCloudPredictions --> ShowResults
    
    CloudInference -->|No| ShowResults
    
    ShowResults --> UserSelection{User\nAction}
    
    UserSelection -->|Select Prediction #1| SelectProduct1[Select Product 1]
    UserSelection -->|Select Prediction #2| SelectProduct2[Select Product 2]
    UserSelection -->|Select Prediction #3| SelectProduct3[Select Product 3]
    UserSelection -->|Manual Input| ManualSearch[Search Product Manual]
    
    SelectProduct1 --> IsCorrect1{Produk\nBenar?}
    IsCorrect1 -->|Yes| LogFeedback1[Log: Correct Prediction]
    IsCorrect1 -->|No| LogFeedback2[Log: Incorrect Prediction]
    
    SelectProduct2 --> LogFeedback3[Log: Top-2 Selected]
    SelectProduct3 --> LogFeedback4[Log: Top-3 Selected]
    ManualSearch --> LogFeedback5[Log: Manual Correction]
    
    LogFeedback1 --> SaveDetectionEvent
    LogFeedback2 --> SaveDetectionEvent
    LogFeedback3 --> SaveDetectionEvent
    LogFeedback4 --> SaveDetectionEvent
    LogFeedback5 --> SaveDetectionEvent
    
    SaveDetectionEvent[Save Detection Event\nwith Feedback] --> QueueFeedback[Queue for Cloud Sync]
    QueueFeedback --> AddProductToCart[Add Product to Cart]
    AddProductToCart --> End([Return to Transaction])
```

---

## 4. OFFLINE SYNC FLOW

```mermaid
flowchart TD
    Start([Background Service]) --> CheckInterval{Sync Interval\n5 minutes?}
    CheckInterval -->|No| Sleep[Wait]
    Sleep --> CheckInterval
    
    CheckInterval -->|Yes| CheckOnline{Online?}
    CheckOnline -->|No| Sleep
    
    CheckOnline -->|Yes| CheckQueue{Sync Queue\nEmpty?}
    CheckQueue -->|Yes| Sleep
    
    CheckQueue -->|No| FetchQueue[Fetch Pending Items\nfrom sync_queue]
    FetchQueue --> SortByPriority[Sort by Priority & Created Time]
    
    SortByPriority --> ProcessLoop[For Each Item]
    
    ProcessLoop --> GetItem[Get Next Item]
    GetItem --> DetermineType{Entity\nType}
    
    DetermineType -->|Transaction| SyncTransaction[POST /api/sync/transactions]
    DetermineType -->|Inventory| SyncInventory[POST /api/sync/inventory]
    DetermineType -->|Product| SyncProduct[POST /api/sync/products]
    DetermineType -->|Event| SyncEvent[POST /api/sync/events]
    
    SyncTransaction --> CheckResponse{Response\nOK?}
    SyncInventory --> CheckResponse
    SyncProduct --> CheckResponse
    SyncEvent --> CheckResponse
    
    CheckResponse -->|Success 200| MarkSynced[Update: status = 'synced']
    MarkSynced --> DeleteQueue[Delete from sync_queue]
    DeleteQueue --> UpdateLocal[Update sync_status in entity table]
    UpdateLocal --> MoreItems{More\nItems?}
    
    CheckResponse -->|Conflict 409| ResolveConflict[Conflict Resolution]
    ResolveConflict --> ConflictStrategy{Strategy}
    
    ConflictStrategy -->|Server Wins| AcceptServer[Update Local with Server Data]
    ConflictStrategy -->|Client Wins| ForceUpdate[Force Update to Server]
    ConflictStrategy -->|Merge| ManualResolve[Queue for Manual Resolution]
    
    AcceptServer --> MarkSynced
    ForceUpdate --> MarkSynced
    ManualResolve --> MarkConflict[Update: status = 'conflict']
    MarkConflict --> NotifyUser[Notify User: Manual Resolution Needed]
    NotifyUser --> MoreItems
    
    CheckResponse -->|Error 4xx/5xx| IncrementRetry[Increment retry_count]
    IncrementRetry --> CheckRetry{retry_count\n< max_retries?}
    
    CheckRetry -->|Yes| CalculateBackoff[Calculate Exponential Backoff]
    CalculateBackoff --> UpdateNextRetry[Update next_retry_at]
    UpdateNextRetry --> MoreItems
    
    CheckRetry -->|No| MarkFailed[Update: status = 'failed']
    MarkFailed --> LogError[Log Error Details]
    LogError --> NotifyError[Notify Admin: Sync Failed]
    NotifyError --> MoreItems
    
    MoreItems -->|Yes| ProcessLoop
    MoreItems -->|No| UpdateLastSync[Update last_sync_at\nin app_settings]
    UpdateLastSync --> Sleep
```

---

## 5. STOCK OPNAME FLOW

```mermaid
flowchart TD
    Start([Manager: Stock Opname]) --> SelectLocation[Select Location]
    SelectLocation --> GenerateList[Generate Product List\nfrom Inventory]
    GenerateList --> ShowList[Show Product List:\nExpected Qty]
    
    ShowList --> StartOpname[Start Stock Opname]
    StartOpname --> ScanLoop{Scan\nProducts}
    
    ScanLoop --> ScanProduct[Scan Product\nBarcode/QR]
    ScanProduct --> FindProduct{Product\nFound?}
    
    FindProduct -->|No| ShowError[Show Error]
    ShowError --> ScanLoop
    
    FindProduct -->|Yes| InputActualQty[Input Actual Quantity]
    InputActualQty --> ShowExpected[Show:\nExpected vs Actual]
    ShowExpected --> CalculateDiff[Calculate Difference]
    CalculateDiff --> MarkScanned[Mark Product as Scanned]
    
    MarkScanned --> MoreProducts{More\nProducts?}
    MoreProducts -->|Yes| ScanLoop
    
    MoreProducts -->|No| ShowUnscanned{Products\nNot Scanned?}
    ShowUnscanned -->|Yes| ShowWarning[Show Warning:\nUnscanned Products]
    ShowWarning --> ConfirmContinue{Continue?}
    ConfirmContinue -->|No| ScanLoop
    
    ShowUnscanned -->|No| GenerateSummary
    ConfirmContinue -->|Yes| GenerateSummary
    
    GenerateSummary[Generate Summary Report] --> ShowDifferences[Show Differences:\n+ Surplus\n- Shortage]
    
    ShowDifferences --> CheckDiff{Ada\nSelisih?}
    CheckDiff -->|No| ConfirmNoChange[Confirm: No Changes]
    ConfirmNoChange --> SaveOpname[Save Stock Opname Record]
    SaveOpname --> End([End])
    
    CheckDiff -->|Yes| ReviewDiff[Manager Review Differences]
    ReviewDiff --> ApprovalDecision{Approve\nAdjustment?}
    
    ApprovalDecision -->|No| CancelOpname{Cancel or\nRe-scan?}
    CancelOpname -->|Cancel| End
    CancelOpname -->|Re-scan| ScanLoop
    
    ApprovalDecision -->|Yes| BeginAdjustment[BEGIN Transaction]
    BeginAdjustment --> AdjustLoop[For Each Difference]
    
    AdjustLoop --> UpdateInventory[Update inventory.quantity]
    UpdateInventory --> InsertMovement[Insert stock_movements\ntype: ADJUSTMENT]
    InsertMovement --> MoreAdjust{More?}
    
    MoreAdjust -->|Yes| AdjustLoop
    MoreAdjust -->|No| SaveOpnameRecord[Insert Stock Opname Record]
    SaveOpnameRecord --> LogAudit[Insert audit_logs]
    LogAudit --> CommitTx[COMMIT Transaction]
    
    CommitTx --> AddSyncQueue[Add to sync_queue]
    AddSyncQueue --> GenerateReport[Generate PDF Report]
    GenerateReport --> ShowSuccess[Show Success:\nStock Updated]
    ShowSuccess --> End
```

---

## 6. LOW STOCK ALERT FLOW

```mermaid
flowchart TD
    Start([Background Job:\nDaily 8 AM]) --> QueryLowStock[Query Products WHERE\nquantity <= min_stock]
    
    QueryLowStock --> CheckResults{Products\nFound?}
    CheckResults -->|No| End([End])
    
    CheckResults -->|Yes| GroupByLocation[Group by Location]
    GroupByLocation --> ForEachLocation[For Each Location]
    
    ForEachLocation --> GetOwner[Get Owner/Manager]
    GetOwner --> GenerateList[Generate Low Stock List:\n- Product Name\n- Current Stock\n- Min Stock\n- Suggested Order Qty]
    
    GenerateList --> SendNotification[Send Push Notification]
    SendNotification --> LogInApp[Create In-App Alert]
    LogInApp --> SendEmail{Email\nEnabled?}
    
    SendEmail -->|Yes| SendEmailNotif[Send Email]
    SendEmail -->|No| SendWhatsApp
    SendEmailNotif --> SendWhatsApp
    
    SendWhatsApp{WhatsApp\nEnabled?}
    SendWhatsApp -->|Yes| SendWANotif[Send WhatsApp Message]
    SendWhatsApp -->|No| NextLocation
    SendWANotif --> NextLocation
    
    NextLocation{More\nLocations?}
    NextLocation -->|Yes| ForEachLocation
    NextLocation -->|No| LogAlertsSent[Log Alerts Sent]
    LogAlertsSent --> End
```

---

## 7. RETURN/REFUND FLOW

```mermaid
flowchart TD
    Start([Kasir: Return]) --> SearchTransaction[Search Transaction\nby Receipt Number]
    SearchTransaction --> FindTx{Transaction\nFound?}
    
    FindTx -->|No| ShowError1[Show Error: Not Found]
    ShowError1 --> End([End])
    
    FindTx -->|Yes| ShowTxDetails[Show Transaction Details:\nDate, Items, Total]
    ShowTxDetails --> CheckStatus{Status\nCompleted?}
    
    CheckStatus -->|No| ShowError2[Show Error: Cannot Return]
    ShowError2 --> End
    
    CheckStatus -->|Yes| CheckTime{Within\nReturn Window?}
    CheckTime -->|No| RequireApproval[Require Manager Approval]
    RequireApproval --> ManagerApprove{Approved?}
    ManagerApprove -->|No| End
    
    CheckTime -->|Yes| SelectItems
    ManagerApprove -->|Yes| SelectItems
    
    SelectItems[Select Items to Return] --> InputQty[Input Return Quantity]
    InputQty --> ValidateQty{Qty Valid?}
    
    ValidateQty -->|No| ShowError3[Show Error: Invalid Qty]
    ShowError3 --> InputQty
    
    ValidateQty -->|Yes| SelectReason[Select Return Reason:\n- Rusak\n- Salah\n- Expired\n- Other]
    SelectReason --> InputNotes[Input Notes Optional]
    
    InputNotes --> CalculateRefund[Calculate Refund Amount]
    CalculateRefund --> ShowRefund[Show Refund Summary]
    
    ShowRefund --> SelectRefundMethod{Refund\nMethod}
    
    SelectRefundMethod -->|Original Payment| RefundOriginal[Refund to Original]
    SelectRefundMethod -->|Cash| RefundCash[Cash Refund]
    
    RefundOriginal --> ConfirmRefund
    RefundCash --> ConfirmRefund
    
    ConfirmRefund[Confirm Refund] --> BeginTx[BEGIN Transaction]
    BeginTx --> UpdateOriginalTx[Update original transaction:\nstatus = 'partial_refunded']
    UpdateOriginalTx --> InsertReturnTx[Insert return transaction]
    InsertReturnTx --> InsertReturnItems[Insert return items]
    InsertReturnItems --> UpdateInventory[Update inventory:\nquantity += return_qty]
    UpdateInventory --> InsertMovement[Insert stock_movements\ntype: RETURN]
    InsertMovement --> ProcessRefund[Process Refund Payment]
    ProcessRefund --> LogAudit[Insert audit_logs]
    LogAudit --> CommitTx[COMMIT Transaction]
    
    CommitTx --> AddSyncQueue[Add to sync_queue]
    AddSyncQueue --> GenerateReturnReceipt[Generate Return Receipt]
    GenerateReturnReceipt --> PrintReceipt[Print Receipt]
    PrintReceipt --> ShowSuccess[Show Success]
    ShowSuccess --> End
```

---

## 8. DATA SYNC CONFLICT RESOLUTION

```mermaid
flowchart TD
    Start([Sync Conflict Detected]) --> IdentifyEntity[Identify Entity:\nTransaction/Inventory/Product]
    
    IdentifyEntity --> FetchBoth[Fetch Both Versions:\n- Local\n- Server]
    
    FetchBoth --> CompareTimestamp{Compare\nupdated_at}
    
    CompareTimestamp -->|Server Newer| CheckEntityType1{Entity\nType}
    CompareTimestamp -->|Local Newer| CheckEntityType2{Entity\nType}
    CompareTimestamp -->|Same Time| CheckEntityType3{Entity\nType}
    
    CheckEntityType1 -->|Transaction| LocalWins1[Strategy: Local Wins\nTransaction Immutable]
    CheckEntityType1 -->|Inventory| ServerWins1[Strategy: Server Wins\nServer is Source of Truth]
    CheckEntityType1 -->|Product| ServerWins1
    
    CheckEntityType2 -->|Transaction| LocalWins2[Strategy: Local Wins]
    CheckEntityType2 -->|Inventory| CalculateDelta[Calculate Delta:\nLocal Change + Server Change]
    CheckEntityType2 -->|Product| LastWriteWins[Strategy: Last Write Wins]
    
    CheckEntityType3 -->|Any| ManualResolve[Strategy: Manual Resolution]
    
    LocalWins1 --> ForceSync[Force Sync Local to Server]
    LocalWins2 --> ForceSync
    
    ServerWins1 --> OverwriteLocal[Overwrite Local with Server Data]
    
    CalculateDelta --> MergeChanges[Merge Changes:\nSum of Changes]
    MergeChanges --> SyncMerged[Sync Merged Data]
    
    LastWriteWins --> AcceptNewer[Accept Newer Version]
    AcceptNewer --> ForceSync
    
    ManualResolve --> ShowConflictUI[Show Conflict Resolution UI]
    ShowConflictUI --> UserDecision{User\nChooses}
    UserDecision -->|Keep Local| ForceSync
    UserDecision -->|Accept Server| OverwriteLocal
    UserDecision -->|Merge| MergeChanges
    
    ForceSync --> MarkResolved[Mark Conflict as Resolved]
    OverwriteLocal --> MarkResolved
    SyncMerged --> MarkResolved
    
    MarkResolved --> UpdateSyncQueue[Update sync_queue:\nstatus = 'synced']
    UpdateSyncQueue --> LogResolution[Log Resolution in audit_logs]
    LogResolution --> End([End])
```

---

## 9. PAYMENT GATEWAY INTEGRATION (QRIS)

```mermaid
flowchart TD
    Start([User Select QRIS Payment]) --> GetAmount[Get Transaction Total]
    GetAmount --> ValidateAmount{Amount\nValid?}
    
    ValidateAmount -->|No| ShowError[Show Error]
    ShowError --> End([Cancel])
    
    ValidateAmount -->|Yes| CheckOnline{Online?}
    CheckOnline -->|No| ShowOfflineError[Show Error:\nQRIS Requires Internet]
    ShowOfflineError --> End
    
    CheckOnline -->|Yes| CallGateway[POST to Payment Gateway:\nCreate QRIS Payment]
    CallGateway --> GatewayResponse{Response\nOK?}
    
    GatewayResponse -->|Error| ShowGatewayError[Show Error:\nGateway Failed]
    ShowGatewayError --> Retry{Retry?}
    Retry -->|Yes| CallGateway
    Retry -->|No| End
    
    GatewayResponse -->|Success| GetQRCode[Get QRIS Code & Payment ID]
    GetQRCode --> DisplayQR[Display QRIS Code\nShow Timer: 5 min]
    
    DisplayQR --> StartPolling[Start Polling Payment Status\nEvery 3 seconds]
    
    StartPolling --> PollLoop{Check\nStatus}
    
    PollLoop --> CallStatusAPI[GET Payment Status]
    CallStatusAPI --> CheckStatus{Payment\nStatus}
    
    CheckStatus -->|Pending| CheckTimeout{Timeout\n5 min?}
    CheckTimeout -->|No| Wait[Wait 3 seconds]
    Wait --> PollLoop
    
    CheckTimeout -->|Yes| ShowTimeout[Show Timeout Error]
    ShowTimeout --> CancelPayment[Cancel Payment at Gateway]
    CancelPayment --> End
    
    CheckStatus -->|Success| VerifyAmount[Verify Amount Matches]
    VerifyAmount --> AmountMatch{Amount\nOK?}
    
    AmountMatch -->|No| ShowMismatch[Show Error: Amount Mismatch]
    ShowMismatch --> RefundInitiate[Initiate Refund]
    RefundInitiate --> End
    
    AmountMatch -->|Yes| UpdateTransaction[Update Transaction:\npayment_method = 'qris',\nstatus = 'completed']
    UpdateTransaction --> SavePaymentRef[Save Gateway Transaction ID]
    SavePaymentRef --> CompleteTransaction[Complete Transaction Flow]
    CompleteTransaction --> EndSuccess([Success])
    
    CheckStatus -->|Failed| ShowPaymentFailed[Show Payment Failed]
    ShowPaymentFailed --> End
```

---

## 10. ADMIN MULTI-TENANT DASHBOARD

```mermaid
flowchart TD
    Start([Admin Login]) --> VerifyRole{Role =\nSuper Admin?}
    VerifyRole -->|No| AccessDenied[Show Error: Access Denied]
    AccessDenied --> End([End])
    
    VerifyRole -->|Yes| LoadDashboard[Load Multi-Tenant Dashboard]
    LoadDashboard --> FetchTenants[Fetch All Tenants\nwith Metrics]
    
    FetchTenants --> AggregateData[Aggregate Data:\n- Total Tenants\n- Active Tenants\n- Total Sales Today\n- Total Transactions Today]
    
    AggregateData --> DisplaySummary[Display Summary Cards]
    DisplaySummary --> DisplayTenantList[Display Tenant List:\n- Name\n- Owner\n- Subscription\n- Status\n- Last Activity]
    
    DisplayTenantList --> FilterOptions[Filter Options:\n- Status\n- Subscription Tier\n- Date Range]
    
    FilterOptions --> UserAction{User\nAction}
    
    UserAction -->|View Tenant Details| SelectTenant[Select Tenant]
    SelectTenant --> LoadTenantDetails[Load Tenant Details:\n- Sales Report\n- Transaction History\n- Product Count\n- Inventory Value]
    LoadTenantDetails --> DisplayTenantDashboard[Display Tenant Dashboard]
    DisplayTenantDashboard --> BackToList{Back to\nList?}
    BackToList -->|Yes| DisplayTenantList
    
    UserAction -->|View Reports| SelectReport[Select Report Type:\n- Consolidated Sales\n- Tenant Ranking\n- Subscription Revenue\n- Usage Analytics]
    SelectReport --> GenerateReport[Generate Report]
    GenerateReport --> DisplayReport[Display Report with Charts]
    DisplayReport --> ExportOption{Export?}
    ExportOption -->|Yes| ExportReport[Export to PDF/Excel]
    ExportOption -->|No| BackToList
    
    UserAction -->|Manage Tenant| TenantAction{Action}
    TenantAction -->|Activate| ActivateTenant[Activate Tenant]
    TenantAction -->|Deactivate| DeactivateTenant[Deactivate Tenant]
    TenantAction -->|Edit| EditTenant[Edit Tenant Details]
    TenantAction -->|Delete| ConfirmDelete{Confirm\nDelete?}
    ConfirmDelete -->|Yes| DeleteTenant[Soft Delete Tenant]
    ConfirmDelete -->|No| DisplayTenantList
    
    ActivateTenant --> UpdateStatus[Update Tenant Status]
    DeactivateTenant --> UpdateStatus
    EditTenant --> UpdateStatus
    DeleteTenant --> UpdateStatus
    
    UpdateStatus --> LogAction[Log Admin Action]
    LogAction --> NotifyTenant[Notify Tenant Owner]
    NotifyTenant --> RefreshList[Refresh Tenant List]
    RefreshList --> DisplayTenantList
    
    UserAction -->|Logout| End
```

---

## 11. MODEL UPDATE (OTA) FLOW

```mermaid
flowchart TD
    Start([App Startup / Background]) --> CheckModelVersion[Get Current Model Version\nfrom local DB]
    CheckModelVersion --> CheckOnline{Online?}
    
    CheckOnline -->|No| UseLocal[Use Local Model]
    UseLocal --> End([End])
    
    CheckOnline -->|Yes| FetchLatest[GET /api/ml/models/latest]
    FetchLatest --> CompareVersion{Server Version\n> Local Version?}
    
    CompareVersion -->|No| UseLocal
    
    CompareVersion -->|Yes| CheckWifi{On\nWiFi?}
    CheckWifi -->|No| PromptUser[Prompt User:\nDownload using Mobile Data?]
    PromptUser --> UserDecision{User\nConsents?}
    UserDecision -->|No| UseLocal
    
    CheckWifi -->|Yes| StartDownload
    UserDecision -->|Yes| StartDownload
    
    StartDownload[Start Download\nShow Progress] --> DownloadModel[Download Model File]
    DownloadModel --> VerifyChecksum[Verify File Checksum]
    
    VerifyChecksum --> ChecksumValid{Valid?}
    ChecksumValid -->|No| ShowError[Show Error:\nDownload Corrupted]
    ShowError --> RetryDownload{Retry?}
    RetryDownload -->|Yes| StartDownload
    RetryDownload -->|No| UseLocal
    
    ChecksumValid -->|Yes| SaveModel[Save Model to Local Storage]
    SaveModel --> UpdateDB[Update ml_models table:\n- version\n- file_path\n- is_active = true]
    UpdateDB --> DeactivateOld[Deactivate Old Model]
    DeactivateOld --> TestModel[Run Test Inference]
    
    TestModel --> TestSuccess{Test\nOK?}
    TestSuccess -->|No| Rollback[Rollback to Old Model]
    Rollback --> LogError[Log Error]
    LogError --> UseLocal
    
    TestSuccess -->|Yes| DeleteOld[Delete Old Model File]
    DeleteOld --> ShowSuccess[Show Success Notification]
    ShowSuccess --> UseNewModel[Use New Model]
    UseNewModel --> End
```

---

## Summary

Semua flow diagram di atas menggambarkan user journey dan system flow untuk:

1. **Login Flow** - Authentication offline & online
2. **Transaction Flow** - Happy path dari scan produk sampai print receipt
3. **Product Detection** - AI-based product recognition dengan feedback
4. **Offline Sync** - Background sync dengan conflict resolution
5. **Stock Opname** - Inventory audit process
6. **Low Stock Alert** - Automated notification system
7. **Return/Refund** - Return process dengan approval
8. **Conflict Resolution** - Strategi resolve sync conflicts
9. **QRIS Payment** - Payment gateway integration
10. **Admin Dashboard** - Multi-tenant management
11. **Model Update** - OTA update untuk ML models

Setiap flow sudah include:
- ✅ Happy path & error handling
- ✅ Offline/online scenarios
- ✅ Validation steps
- ✅ Database transactions
- ✅ Sync queue management
- ✅ User feedback & notifications


