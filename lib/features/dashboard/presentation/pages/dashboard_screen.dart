import 'package:flutter/material.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/layout/app_layout.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI row
          SizedBox(
            height: 120,
            child: Row(
              children: const [
                Expanded(child: KpiCard(title: 'Revenue', value: 125000, changePercent: 4.5, icon: Icons.attach_money)),
                SizedBox(width: 16),
                Expanded(child: KpiCard(title: 'Expenses', value: 42000, changePercent: -1.3, icon: Icons.money_off, color: AppColors.error)),
                SizedBox(width: 16),
                Expanded(child: KpiCard(title: 'Net Profit', value: 83000, changePercent: 2.0, icon: Icons.trending_up, color: AppColors.success)),
                SizedBox(width: 16),
                Expanded(child: KpiCard(title: 'Pending Invoices', value: 18, changePercent: 6.0, icon: Icons.receipt_long, color: AppColors.warning)),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Sections
          const SectionHeader(title: 'Financial Performance', subtitle: 'Last 30 days'),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(color: AppColors.surfaceGlass, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Line chart placeholder', style: TextStyle(color: Colors.white70))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.surfaceGlass, borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('Expense category donut', style: TextStyle(color: Colors.white70))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.surfaceGlass, borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('Recent activity feed', style: TextStyle(color: Colors.white70))),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
