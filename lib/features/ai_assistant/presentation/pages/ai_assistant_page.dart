import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/ai/warung_assistant.dart';
import 'package:pos/core/ai/sales_predictor.dart';
import 'package:pos/core/ai/price_recommender.dart';
import '../controllers/ai_assistant_controller.dart';
import 'package:pos/core/localization/language_controller.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AIAssistantController _controller;
  late LanguageController _languageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    if (Get.isRegistered<AIAssistantController>()) {
      _controller = Get.find<AIAssistantController>();
    } else {
      _controller = Get.put(AIAssistantController());
    }
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final tabs = ['insight', 'performance', 'forecast', 'recommendations', 'products', 'pricing'];
      _controller.changeTab(tabs[_tabController.index]);
    });
    // ensure language controller
    if (Get.isRegistered<LanguageController>()) {
      _languageController = Get.find<LanguageController>();
    } else {
      _languageController = Get.put(LanguageController());
    }

    // trigger initial load for default tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.changeTab('insight');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AI Asisten Warung'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.refreshAll,
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.dailyInsight.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _controller.clearError,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.primaryColor,
                onTap: (index) {
                  final tabs = ['insight', 'performance', 'forecast', 'recommendations', 'products', 'pricing'];
                  _controller.changeTab(tabs[index]);
                },
                tabs: const [
                  Tab(text: 'Insight'),
                  Tab(text: 'Performance'),
                  Tab(text: 'Forecast'),
                  Tab(text: 'Rekomendasi'),
                  Tab(text: 'Produk'),
                  Tab(text: 'Harga'),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInsightTab(_controller),
                  _buildPerformanceTab(_controller),
                  _buildForecastTab(_controller),
                  _buildRecommendationsTab(_controller),
                  _buildProductsTab(_controller),
                  _buildPricingTab(_controller),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _money(num value) => _languageController.formatCurrency(value.toDouble());

  Widget _buildInsightTab(AIAssistantController controller) {
    return Obx(() {
      final insight = controller.dailyInsight.value;
      if (insight == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Summary
            _buildSummaryCard(insight),
            const SizedBox(height: 16),
            
            // Top Products Today
            _buildTopProductsCard(insight.topProducts),
            const SizedBox(height: 16),
            
            // Low Stock Alert
            if (insight.lowStockItems.isNotEmpty) ...[
              _buildLowStockCard(insight.lowStockItems),
            const SizedBox(height: 16),
            _buildLowStockDetailCard(insight.lowStockItems),
              const SizedBox(height: 16),
            ],
            
            // Action Recommendations
            if (insight.recommendations.isNotEmpty) ...[
              _buildActionRecommendationsCard(insight.recommendations),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPerformanceTab(AIAssistantController controller) {
    return Obx(() {
      final performance = controller.businessPerformance.value;
      if (performance == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Chart
            _buildRevenueChartCard(performance.revenueTrend),
            const SizedBox(height: 16),
            
            // Category Performance
            _buildCategoryPerformanceCard(performance.categoryPerformance),
            const SizedBox(height: 16),
            
            // Margin Analysis
            _buildMarginAnalysisCard(performance.marginAnalysis),
          ],
        ),
      );
    });
  }

  Widget _buildForecastTab(AIAssistantController controller) {
    return Obx(() {
      final forecast = controller.businessForecast.value;
      if (forecast == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Forecast Summary
            _buildForecastSummaryCard(forecast),
            const SizedBox(height: 16),
            
            // Recommendations
            if (forecast.recommendations.isNotEmpty) ...[
              _buildForecastRecommendationsCard(forecast.recommendations),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildRecommendationsTab(AIAssistantController controller) {
    return Obx(() {
      final recommendations = controller.recommendations;
      if (recommendations.isEmpty) {
        return const Center(child: Text('No recommendations available'));
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Restock top 3 items with details
          _buildRestockTop3Card(controller),
          const SizedBox(height: 16),
          ...List.generate(recommendations.length, (index) => _buildRecommendationCard(recommendations[index])),
        ],
      );
    });
  }

  Widget _buildProductsTab(AIAssistantController controller) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Products
            _buildTopProductsListCard(controller.topProducts),
            const SizedBox(height: 16),
            
            // Top Categories
            _buildTopCategoriesCard(controller.topCategories),
          ],
        ),
      );
    });
  }

  Widget _buildPricingTab(AIAssistantController controller) {
    return Obx(() {
      final priceItems = controller.priceReviewItems;
      if (priceItems.isEmpty) {
        return const Center(child: Text('No products need price review'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: priceItems.length,
        itemBuilder: (context, index) {
          final item = priceItems[index];
          return _buildPriceReviewCard(item);
        },
      );
    });
  }

  // Widget builders
  Widget _buildSummaryCard(WarungInsight insight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Ringkasan Hari Ini',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Transaksi',
                    insight.todaySales.transactionCount.toString(),
                    Icons.receipt,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Revenue',
                    _money(insight.todaySales.totalRevenue),
                    Icons.attach_money,
                    AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Rata-rata',
                    _money(insight.todaySales.avgTransactionValue),
                    Icons.trending_up,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsCard(List<TopProductToday> products) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Produk Terlaris Hari Ini',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const Text('Belum ada data penjualan hari ini')
            else
              ...products.map((product) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    (product.quantitySold ?? 0).toString(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(product.productName ?? 'Unknown'),
                subtitle: Text('${product.quantitySold ?? 0} terjual'),
                trailing: Text(
                  _money(product.revenue ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockCard(List<LowStockItem> items) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Stok Rendah',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red[100],
                child: Text(
                  (item.currentStock ?? 0).toString(),
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(item.productName ?? 'Unknown'),
              subtitle: Text('Min: ${item.minStock ?? 0}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRecommendationsCard(List<ActionRecommendation> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Rekomendasi Aksi',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => ListTile(
              leading: Icon(
                _getActionIcon(rec.type ?? ActionType.promotion),
                color: _getActionColor(rec.priority ?? Priority.medium),
              ),
              title: Text(rec.title ?? 'Unknown'),
              subtitle: Text(rec.description ?? 'No description'),
              trailing: _getPriorityChip(rec.priority ?? Priority.medium),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastSummaryCard(BusinessForecast forecast) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Prediksi 30 Hari',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Prediksi Revenue',
                    _money(forecast.predictedRevenue),
                    Icons.attach_money,
                    AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Confidence',
                    '${(forecast.confidence * 100).toInt()}%',
                    Icons.analytics,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Trend',
                    forecast.trend > 0 ? 'Naik' : forecast.trend < 0 ? 'Turun' : 'Stabil',
                    forecast.trend > 0 ? Icons.trending_up : 
                    forecast.trend < 0 ? Icons.trending_down : Icons.trending_flat,
                    forecast.trend > 0 ? AppTheme.successColor : 
                    forecast.trend < 0 ? AppTheme.errorColor : AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRecommendationsCard(List<String> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Rekomendasi Berdasarkan Prediksi',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(rec)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BusinessRecommendation rec) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(rec.priority).withOpacity(0.1),
          child: Icon(
            _getRecommendationIcon(rec.type),
            color: _getPriorityColor(rec.priority),
          ),
        ),
        title: Text(rec.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rec.description),
            const SizedBox(height: 4),
            Text(
              rec.action,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),
             _getPriorityChip(rec.priority),
            const SizedBox(height: 4),
            Text(
              rec.impact,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
       
      ),
    );
  }

  Widget _buildTopProductsListCard(List<TopProduct> products) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Produk Terlaris 30 Hari',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const Text('Belum ada data penjualan')
            else
              ...products.map((product) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    (product.totalQuantity ?? 0).toString(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(product.productName ?? 'Unknown'),
                subtitle: Text('${product.categoryName ?? 'Unknown'} • ${product.transactionCount ?? 0} transaksi'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(product.totalRevenue ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                    Text(
                      _money(product.avgPrice ?? 0),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoriesCard(List<TopCategory> categories) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Kategori Terlaris',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              const Text('Belum ada data kategori')
            else
              ...categories.map((category) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    (category.totalQuantity ?? 0).toString(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(category.categoryName ?? 'Unknown'),
                subtitle: Text('${category.productCount ?? 0} produk'),
                trailing: Text(
                  _money(category.totalRevenue ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceReviewCard(PriceReviewItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.marginPercent < 15 ? Colors.red[100] : Colors.orange[100],
          child: Text(
            '${item.marginPercent.toInt()}%',
            style: TextStyle(
              color: item.marginPercent < 15 ? Colors.red[600] : Colors.orange[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(item.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Harga: ${_money(item.currentPrice)}'),
            Text('Cost: ${_money(item.costPrice)}'),
            const SizedBox(height: 4),
            // Regional average (mock) and suggestion
            Builder(builder: (context) {
              final regionalAvg = (item.currentPrice * 1.08);
              final suggested = ((item.currentPrice + regionalAvg) / 2);
              final increase = (suggested - item.currentPrice);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rata-rata daerah: ${_money(regionalAvg)}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  Text('Saran harga: ${_money(suggested)} (+${_money(increase)})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('Prediksi dampak: margin naik ~${((suggested - item.costPrice) / suggested * 100).toInt()}%', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                ],
              );
            }),
            if (item.issues.isNotEmpty)
              Text(
                item.issues.join(', '),
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to price review detail
        },
      ),
    );
  }

  Widget _buildLowStockDetailCard(List<LowStockItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Detail Stok Rendah',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final current = item.currentStock ?? 0;
              final minStock = item.minStock ?? 0;
              final deficit = (minStock - current).clamp(0, 1 << 31);
              // Mock daily consumption for estimate
              final estDailyUse = 3; // dev-only assumption
              final daysCoverage = estDailyUse == 0 ? 0 : (current / estDailyUse).floor();
              final targetBuffer = (minStock * 2);
              final restockQty = (targetBuffer - current).clamp(0, 1 << 31);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('Stok: $current • Min: $minStock • Selisih: $deficit', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                          Text('Perkiraan cukup: $daysCoverage hari', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Saran Restock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('$restockQty pcs', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRestockTop3Card(AIAssistantController controller) {
    final top = controller.topProducts.take(3).toList();
    if (top.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Tingkatkan Stok: 3 Item Terlaris',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...top.map((p) {
              final qty = p.totalQuantity ?? 0;
              // Mock restock qty suggestion: 20% of 30-day sales, rounded
              final suggestion = ((qty * 0.2)).clamp(5, 200).toInt();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(p.productName ?? 'Unknown'),
                subtitle: Text('${p.categoryName ?? 'Kategori'} • ${p.transactionCount ?? 0} transaksi'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Saran Restock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('$suggestion pcs', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartCard(List<DailyRevenue> revenueData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Trend Revenue 30 Hari',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Implement chart widget
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Chart will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceCard(List<CategoryPerformance> categories) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Performa Kategori',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
              ...categories.map((category) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    (category.quantitySold ?? 0).toString(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(category.categoryName ?? 'Unknown'),
                subtitle: Text('${category.productCount ?? 0} produk'),
                trailing: Text(
                  _money(category.revenue ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildMarginAnalysisCard(MarginAnalysis margin) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Analisis Margin',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Rata-rata',
                    '${margin.avgMargin.toInt()}%',
                    Icons.trending_up,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Terendah',
                    '${margin.minMargin.toInt()}%',
                    Icons.trending_down,
                    AppTheme.errorColor,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Tertinggi',
                    '${margin.maxMargin.toInt()}%',
                    Icons.trending_up,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  IconData _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.promotion:
        return Icons.campaign;
      case ActionType.inventory:
        return Icons.inventory;
      case ActionType.marketing:
        return Icons.campaign; // fallback for marketing
      case ActionType.pricing:
        return Icons.attach_money;
    }
  }

  Color _getActionColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.pricing:
        return Icons.attach_money;
      case RecommendationType.inventory:
        return Icons.inventory;
      case RecommendationType.product:
        return Icons.shopping_bag;
      case RecommendationType.category:
        return Icons.category;
      case RecommendationType.marketing:
        return Icons.campaign; // fallback for marketing
    }
  }

  Widget _getPriorityChip(Priority priority) {
    Color color;
    String text;
    
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        text = 'High';
        break;
      case Priority.medium:
        color = Colors.orange;
        text = 'Medium';
        break;
      case Priority.low:
        color = Colors.green;
        text = 'Low';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
