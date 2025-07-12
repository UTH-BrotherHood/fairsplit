import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fairsplit/features/profile/data/models/analytics_models.dart';
import 'package:fairsplit/injection.dart';
import 'package:intl/intl.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsViewModelProvider.notifier).fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsViewModelProvider);

    return analyticsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Unable to load analytics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(analyticsViewModelProvider.notifier).fetchAnalytics();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (analyticsData) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Section
            _buildOverviewSection(analyticsData.overview),
            const SizedBox(height: 24),

            // Monthly Analytics Section
            _buildMonthlySection(analyticsData.monthly),
            const SizedBox(height: 24),

            // Yearly Analytics Section
            _buildYearlySection(analyticsData.yearly),
            const SizedBox(height: 24),

            // Compare Section
            _buildCompareSection(analyticsData.compare),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(AnalyticsOverviewModel overview) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Tổng quan chi tiêu',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildOverviewRow(
                  'Tổng chi tiêu',
                  currencyFormat.format(overview.totalSpent),
                  Colors.red,
                ),
                const SizedBox(height: 12),
                _buildOverviewRow(
                  'Tổng đã trả',
                  currencyFormat.format(overview.totalPaid),
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildOverviewRow(
                  'Nợ',
                  currencyFormat.format(overview.totalDebt),
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildOverviewRow(
                  'Số dư',
                  currencyFormat.format(overview.balance),
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildOverviewRow(
                  'Số giao dịch',
                  '${overview.transactionCount}',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySection(List<MonthlyAnalyticsModel> monthlyData) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Thống kê theo tháng',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monthlyData.length,
            itemBuilder: (context, index) {
              final monthData = monthlyData[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tháng ${monthData.month}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewRow(
                      'Chi tiêu',
                      currencyFormat.format(monthData.totalSpent),
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildOverviewRow(
                      'Đã trả',
                      currencyFormat.format(monthData.totalPaid),
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildOverviewRow(
                      'Số dư',
                      currencyFormat.format(monthData.balance),
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildOverviewRow(
                      'Giao dịch',
                      '${monthData.transactionCount}',
                      Colors.purple,
                    ),
                    if (monthData.categoriesSpent.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Chi tiêu theo danh mục:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...monthData.categoriesSpent.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(currencyFormat.format(entry.value)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (index < monthlyData.length - 1)
                      const Divider(height: 32, color: Color(0xFFE5E7EB)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYearlySection(List<YearlyAnalyticsModel> yearlyData) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Thống kê theo năm',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: yearlyData.length,
            itemBuilder: (context, index) {
              final yearData = yearlyData[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Năm ${yearData.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewRow(
                      'Tổng chi tiêu',
                      currencyFormat.format(yearData.totalSpent),
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildOverviewRow(
                      'Tổng đã trả',
                      currencyFormat.format(yearData.totalPaid),
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildOverviewRow(
                      'Nợ',
                      currencyFormat.format(yearData.totalDebt),
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildOverviewRow(
                      'Số dư',
                      currencyFormat.format(yearData.balance),
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildOverviewRow(
                      'Giao dịch',
                      '${yearData.transactionCount}',
                      Colors.purple,
                    ),
                    if (index < yearlyData.length - 1)
                      const Divider(height: 32, color: Color(0xFFE5E7EB)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompareSection(CompareAnalyticsModel compareData) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'So sánh chi tiêu',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (compareData.spentChange != null)
                  _buildOverviewRow(
                    'Thay đổi chi tiêu',
                    '${compareData.spentChange! > 0 ? '+' : ''}${currencyFormat.format(compareData.spentChange)}',
                    compareData.spentChange! > 0 ? Colors.red : Colors.green,
                  ),
                if (compareData.paidChange != null) ...[
                  if (compareData.spentChange != null)
                    const SizedBox(height: 8),
                  _buildOverviewRow(
                    'Thay đổi đã trả',
                    '${compareData.paidChange! > 0 ? '+' : ''}${currencyFormat.format(compareData.paidChange)}',
                    compareData.paidChange! > 0 ? Colors.green : Colors.red,
                  ),
                ],
                if (compareData.spentChange == null &&
                    compareData.paidChange == null)
                  const Text(
                    'Không có dữ liệu so sánh',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
