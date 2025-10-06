# AI Asisten Warung - Dokumentasi Fitur

## Overview

AI Asisten Warung adalah fitur cerdas yang memberikan insight bisnis, prediksi penjualan, dan rekomendasi strategis untuk mengoptimalkan operasional warung UMKM.

## Fitur Utama

### 1. 💰 Prediksi Penjualan & Stok

**Sales Predictor** menganalisis data historis untuk memberikan prediksi yang akurat:

- **Analisis Trend**: Menggunakan linear regression untuk mendeteksi pola penjualan
- **Prediksi 7-30 Hari**: Estimasi kebutuhan stok berdasarkan pola historis
- **Confidence Score**: Tingkat kepercayaan prediksi berdasarkan konsistensi data
- **Rekomendasi Aksi**: Saran konkret berdasarkan analisis trend

**Contoh Output:**
```
Produk: Indomie Goreng
Prediksi 7 hari: 45 unit
Confidence: 85%
Trend: Naik 12%
Rekomendasi: Siapkan stok ekstra untuk antisipasi lonjakan permintaan
```

### 2. 🧾 Rekomendasi Harga & Produk Laris

**Price Recommender** memberikan strategi pricing yang optimal:

- **Margin-based Pricing**: Harga berdasarkan target margin
- **Competitive Pricing**: Analisis harga kompetitor
- **Demand-based Pricing**: Penyesuaian berdasarkan permintaan
- **Psychological Pricing**: Harga yang menarik secara psikologis

**Product Recommender** mengidentifikasi peluang bisnis:

- **Top Products Analysis**: Produk terlaris dengan analisis mendalam
- **Category Performance**: Kategori paling menguntungkan
- **Product Suggestions**: Rekomendasi produk baru berdasarkan kategori menguntungkan

### 3. 🔄 AI Warung Assistant (Gabungan)

**Dashboard Insight Harian:**
- Ringkasan penjualan hari ini
- Produk terlaris real-time
- Alert stok rendah
- Rekomendasi aksi prioritas

**Business Performance:**
- Trend revenue 30 hari
- Analisis margin per kategori
- Performance comparison

**Business Forecast:**
- Prediksi revenue 30 hari ke depan
- Confidence level prediksi
- Rekomendasi strategis

## Arsitektur Teknis

### Core Services

1. **SalesPredictor**
   - Analisis data transaksi historis
   - Linear regression untuk trend analysis
   - Confidence calculation berdasarkan variasi data

2. **PriceRecommender**
   - Multi-strategy pricing analysis
   - Competitor price comparison
   - Margin optimization

3. **WarungAssistant**
   - Orchestrator utama
   - Dashboard data aggregation
   - Business intelligence insights

### Database Schema

```sql
-- Tabel untuk analisis penjualan
transactions (
  id, created_at, total, status
)

transaction_items (
  id, transaction_id, product_id, quantity, unit_price, subtotal
)

products (
  id, name, category_id, price_buy, price_sell, min_stock
)

categories (
  id, name
)

inventory (
  id, product_id, quantity
)
```

### Algoritma Prediksi

**Linear Regression untuk Trend:**
```dart
// Hitung slope untuk trend analysis
slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
trend = slope / (sumY / n) // Normalize by average
```

**Confidence Calculation:**
```dart
// Berdasarkan coefficient of variation
coefficient = stdDev / mean
confidence = 1.0 - coefficient.clamp(0.0, 1.0)
```

## UI/UX Features

### Tab-based Interface

1. **Insight Tab**
   - Daily summary dengan metrics
   - Top products hari ini
   - Low stock alerts
   - Action recommendations

2. **Performance Tab**
   - Revenue trend chart
   - Category performance
   - Margin analysis

3. **Forecast Tab**
   - 30-day revenue prediction
   - Confidence indicators
   - Strategic recommendations

4. **Recommendations Tab**
   - Priority-based action items
   - Business improvement suggestions
   - Impact assessment

5. **Products Tab**
   - Top products analysis
   - Category insights
   - Performance metrics

6. **Pricing Tab**
   - Products needing price review
   - Margin optimization
   - Competitive analysis

### Visual Indicators

- **Color Coding**: 
  - 🟢 Green: Positive trend, good performance
  - 🟡 Yellow: Neutral, needs attention
  - 🔴 Red: Negative trend, urgent action needed

- **Priority Chips**: High/Medium/Low priority indicators
- **Confidence Bars**: Visual representation of prediction confidence
- **Trend Arrows**: Up/Down/Stable indicators

## Konfigurasi

### Dependency Injection

```dart
// AI services registration
Get.lazyPut<SalesPredictor>(() => SalesPredictor(
  databaseHelper: Get.find<DatabaseHelper>(),
));
Get.lazyPut<PriceRecommender>(() => PriceRecommender(
  databaseHelper: Get.find<DatabaseHelper>(),
));
Get.lazyPut<WarungAssistant>(() => WarungAssistant(
  databaseHelper: Get.find<DatabaseHelper>(),
  salesPredictor: Get.find<SalesPredictor>(),
  priceRecommender: Get.find<PriceRecommender>(),
));
```

### Navigation

```dart
// Route configuration
GetPage(
  name: '/ai-assistant',
  page: () => const AIAssistantPage(),
  transition: Transition.rightToLeft,
  middlewares: [AuthMiddleware()],
),
```

## Penggunaan

### Akses dari Dashboard

1. Buka aplikasi POS
2. Di dashboard, scroll ke bagian "Fitur AI Unggulan"
3. Klik tombol "AI Assistant"
4. Pilih tab yang diinginkan

### Interpretasi Hasil

**Insight Harian:**
- Monitor transaksi dan revenue harian
- Perhatikan produk terlaris untuk restock
- Tindak lanjuti alert stok rendah

**Prediksi:**
- Gunakan confidence score untuk keputusan
- Confidence > 80%: Highly reliable
- Confidence 60-80%: Moderate reliability
- Confidence < 60%: Use with caution

**Rekomendasi:**
- Prioritaskan High priority items
- Implementasikan rekomendasi pricing
- Ekspansi produk di kategori menguntungkan

## Best Practices

### Data Quality
- Pastikan data transaksi lengkap dan akurat
- Update stok secara berkala
- Maintain product information yang up-to-date

### Pengambilan Keputusan
- Kombinasikan AI insights dengan knowledge bisnis
- Monitor performance setelah implementasi rekomendasi
- Adjust strategy berdasarkan hasil

### Maintenance
- Review rekomendasi secara berkala
- Update pricing strategy berdasarkan market changes
- Monitor competitor pricing

## Roadmap

### Phase 1 (Current)
- ✅ Basic sales prediction
- ✅ Price recommendation
- ✅ Business insights dashboard

### Phase 2 (Future)
- 🔄 Advanced ML models
- 🔄 Real-time competitor analysis
- 🔄 Automated pricing adjustments
- 🔄 Customer behavior analysis

### Phase 3 (Advanced)
- 🔄 Predictive inventory management
- 🔄 Dynamic pricing optimization
- 🔄 Market trend analysis
- 🔄 Integration with external data sources

## Troubleshooting

### Common Issues

**No Data Available:**
- Pastikan ada transaksi historis minimal 7 hari
- Check database connection
- Verify data integrity

**Low Confidence Predictions:**
- Normal untuk produk baru atau jarang terjual
- Tambahkan lebih banyak data historis
- Consider manual review

**Performance Issues:**
- Optimize database queries
- Implement data caching
- Consider data archiving untuk dataset besar

## Support

Untuk pertanyaan atau issues terkait AI Assistant:
1. Check dokumentasi ini terlebih dahulu
2. Review error logs di console
3. Contact development team dengan detail error message
