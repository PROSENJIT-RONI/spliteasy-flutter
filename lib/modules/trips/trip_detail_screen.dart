import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/balance_model.dart';
import '../../data/models/trip_expense_model.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'trip_detail_controller.dart';

class TripDetailScreen extends GetView<TripDetailController> {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.trip.value?.name ?? 'Trip Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: controller.shareTrip,
            tooltip: 'Share Public Link',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: controller.goToEditTrip,
            tooltip: 'Edit Trip',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _confirmDeleteTrip(context),
            tooltip: 'Delete Trip',
          ),
          SizedBox(width: isDesktop ? 8.0 : 8.w),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value && controller.trip.value == null) {
              return const LoadingIndicator(message: 'Loading trip details...');
            }

            final t = controller.trip.value;
            if (t == null) {
              return const Center(child: Text('Trip not found'));
            }

            final dateStr = t.startDate != null
                ? '${DateFormat('dd/MM/yyyy').format(t.startDate!)}${t.endDate != null ? ' - ${DateFormat('dd/MM/yyyy').format(t.endDate!)}' : ''}'
                : 'No dates set';

            return Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 20.0 : 16.r),
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  child: CenteredContentWrapper(
                    maxWidth: 900,
                    child: Column(
                      children: [
                        Text(
                          t.name,
                          style: AppTextStyles.h2(isDark: isDark),
                          textAlign: TextAlign.center,
                        ),
                        if (t.destination.isNotEmpty) ...[
                          SizedBox(height: isDesktop ? 4.0 : 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_outlined, size: isDesktop ? 16.0 : 16.sp, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                t.destination,
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: isDesktop ? 4.0 : 4.h),
                        Text(
                          dateStr,
                          style: AppTextStyles.bodySmall(isDark: isDark),
                        ),
                        if (t.description.isNotEmpty) ...[
                          SizedBox(height: isDesktop ? 6.0 : 6.h),
                          Text(
                            t.description,
                            style: AppTextStyles.bodySmall(isDark: isDark),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        SizedBox(height: isDesktop ? 16.0 : 16.h),

                        // Metric Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniStatCard(
                                context,
                                'Total Expense',
                                '₹${controller.totalExpenseAmount.value.toStringAsFixed(2)}',
                                AppColors.primary,
                              ),
                            ),
                            SizedBox(width: isDesktop ? 12.0 : 8.w),
                            Expanded(
                              child: _buildMiniStatCard(
                                context,
                                'People',
                                '${controller.people.length}',
                                AppColors.secondary,
                              ),
                            ),
                            SizedBox(width: isDesktop ? 12.0 : 8.w),
                            Expanded(
                              child: _buildMiniStatCard(
                                context,
                                'Expenses',
                                '${controller.expenses.length}',
                                AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Switcher
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: CenteredContentWrapper(
                    maxWidth: 900,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.activeTab.value = 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: isDesktop ? 14.0 : 12.h),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: controller.activeTab.value == 0
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Balances',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: controller.activeTab.value == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: controller.activeTab.value == 0
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.activeTab.value = 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: isDesktop ? 14.0 : 12.h),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: controller.activeTab.value == 1
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Advances',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: controller.activeTab.value == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: controller.activeTab.value == 1
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.activeTab.value = 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: isDesktop ? 14.0 : 12.h),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: controller.activeTab.value == 2
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Expenses',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: controller.activeTab.value == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: controller.activeTab.value == 1
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Body
                Expanded(
                  child: CenteredContentWrapper(
                    maxWidth: 900,
                    child: RefreshIndicator(
                      onRefresh: controller.loadTripData,
                      color: AppColors.primary,
                      child: IndexedStack(
                        index: controller.activeTab.value,
                        children: [
                          // TAB 0: People Balances & Simplify Debts Section
                          SingleChildScrollView(
                            padding: EdgeInsets.only(
                              left: isDesktop ? 20.0 : 16.r,
                              right: isDesktop ? 20.0 : 16.r,
                              top: isDesktop ? 20.0 : 16.r,
                              bottom: isDesktop ? 120.0 : 120.h,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- SHAREABLE TRIP EXPENSE SUMMARY CARD ---
                                if (controller.personBalances.isNotEmpty) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(isDesktop ? 24.0 : 20.r),
                                    margin: EdgeInsets.only(bottom: isDesktop ? 24.0 : 24.h),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: isDesktop ? 24 : 24.sp),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Trip Expense Summary',
                                              style: AppTextStyles.h3(isDark: isDark).copyWith(color: AppColors.primary),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: isDesktop ? 20.0 : 16.h),
                                        ...controller.personBalances.map((b) {
                                          return Padding(
                                            padding: EdgeInsets.only(bottom: isDesktop ? 10.0 : 8.h),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  b.person.name,
                                                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  '₹${b.totalShare.toStringAsFixed(2)}',
                                                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: isDesktop ? 12.0 : 10.h),
                                          child: const Divider(),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total Trip Expense',
                                              style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '₹${controller.totalExpenseAmount.value.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: isDesktop ? 18.0 : 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // 1. BALANCES SECTION
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Balances (Paid vs Share)', style: AppTextStyles.h3(isDark: isDark)),
                                    OutlinedButton.icon(
                                      onPressed: controller.goToManagePeople,
                                      icon: const Icon(Icons.people_outline_rounded, size: 18),
                                      label: const Text('Manage People'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isDesktop ? 12.0 : 12.h),

                                if (controller.personBalances.isEmpty)
                                  Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(isDesktop ? 20.0 : 20.r),
                                      child: Center(
                                        child: Text(
                                          'No participants added yet. Tap "Manage People" to add trip participants!',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodySmall(isDark: isDark),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth >= 600) {
                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 400,
                                            mainAxisExtent: 180,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                          ),
                                          itemCount: controller.personBalances.length,
                                          itemBuilder: (context, index) {
                                            return _buildDetailedBalanceCard(
                                              context,
                                              controller.personBalances[index],
                                              isDark,
                                              isDesktop: true,
                                            );
                                          },
                                        );
                                      }
                                      return Column(
                                        children: controller.personBalances.map((b) {
                                          return _buildDetailedBalanceCard(context, b, isDark, isDesktop: false);
                                        }).toList(),
                                      );
                                    },
                                  ),
                                SizedBox(height: isDesktop ? 32.0 : 28.h),

                                // 2. SIMPLIFY DEBTS SECTION
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: isDesktop ? 20.0 : 22.sp),
                                    const SizedBox(width: 8),
                                    Text('Simplify Debts', style: AppTextStyles.h3(isDark: isDark)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.settlementSuggestions.isEmpty
                                      ? 'All participant balances are settled.'
                                      : '${controller.settlementSuggestions.length} payment${controller.settlementSuggestions.length == 1 ? '' : 's'} needed to settle all balances',
                                  style: AppTextStyles.bodySmall(isDark: isDark),
                                ),
                                SizedBox(height: isDesktop ? 12.0 : 12.h),

                                if (controller.settlementSuggestions.isEmpty)
                                  Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(isDesktop ? 20.0 : 20.r),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.check_circle_outline_rounded, color: AppColors.owed),
                                            const SizedBox(width: 8),
                                            Text(
                                              'All balances are settled. 🎉',
                                              style: AppTextStyles.bodyMedium(isDark: isDark)
                                                  .copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: controller.settlementSuggestions.map((s) {
                                      return Card(
                                        margin: EdgeInsets.only(bottom: isDesktop ? 10.0 : 10.h),
                                        color: isDark
                                            ? AppColors.surfaceDark
                                            : AppColors.primaryLight.withValues(alpha: 0.3),
                                        child: Padding(
                                          padding: EdgeInsets.all(isDesktop ? 14.0 : 14.r),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withValues(alpha: 0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.swap_horiz_rounded,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: isDesktop ? 12.0 : 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        style: AppTextStyles.bodyMedium(isDark: isDark),
                                                        children: [
                                                          TextSpan(
                                                            text: s.fromPerson.name,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.owe,
                                                            ),
                                                          ),
                                                          const TextSpan(text: ' ➔ pays '),
                                                          TextSpan(
                                                            text: s.toPerson.name,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.owed,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${s.fromPerson.name} (Owes) → ${s.toPerson.name} (Receives)',
                                                      style: AppTextStyles.bodySmall(isDark: isDark)
                                                          .copyWith(fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '₹${s.amount.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: isDesktop ? 16.0 : 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),

                          // TAB 1: Advances
                          _buildAdvancesTab(context, isDark, isDesktop),

                          // TAB 2: Expenses History
                          controller.expenses.isEmpty
                              ? const Center(child: Text('No Expenses Recorded Yet'))
                              : ListView.builder(
                                  padding: EdgeInsets.only(
                                    left: isDesktop ? 20.0 : 16.r,
                                    right: isDesktop ? 20.0 : 16.r,
                                    top: isDesktop ? 20.0 : 16.r,
                                    bottom: isDesktop ? 120.0 : 120.h,
                                  ),
                                  itemCount: controller.expenses.length,
                                  itemBuilder: (context, index) {
                                    final exp = controller.expenses[index];
                                    final dateStr = DateFormat('dd/MM/yyyy').format(exp.expenseDate);
                                    final paidByName = controller.getPersonName(exp.paidByPersonId);

                                    return Card(
                                      margin: EdgeInsets.only(bottom: isDesktop ? 10.0 : 10.h),
                                      child: ListTile(
                                        onTap: () => controller.goToExpenseDetail(exp.id),
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.primaryLight,
                                          child: Icon(
                                            _getCategoryIcon(exp.category),
                                            color: AppColors.primary,
                                            size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        exp.description,
                                        style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Paid by $paidByName • ${exp.splitType.name.toUpperCase()} split • $dateStr',
                                        style: AppTextStyles.bodySmall(isDark: isDark),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '₹${exp.totalAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 15.0 : 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            tooltip: 'Expense actions',
                                            onSelected: (action) {
                                              if (action == 'edit') {
                                                controller.goToEditExpense(exp);
                                              } else if (action == 'delete') {
                                                _confirmDeleteExpense(context, exp);
                                              }
                                            },
                                            itemBuilder: (context) => const [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: ListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  leading: Icon(Icons.edit_outlined),
                                                  title: Text('Edit'),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: ListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  leading: Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                                  title: Text('Delete'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Obx(
        () => controller.activeTab.value == 2
            ? FloatingActionButton.extended(
                heroTag: 'trip_detail_fab',
                onPressed: controller.goToAddExpense,
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
              )
            : (controller.activeTab.value == 1 
                ? FloatingActionButton.extended(
                    heroTag: 'trip_advance_fab',
                    onPressed: () => _showAddAdvanceDialog(context),
                    backgroundColor: AppColors.secondary,
                    icon: const Icon(Icons.money_rounded, color: Colors.white),
                    label: const Text('Add Advance', style: TextStyle(color: Colors.white)),
                  )
                : const SizedBox.shrink()),
      ),
    );
  }

  void _confirmDeleteExpense(BuildContext context, TripExpenseModel expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Delete "${expense.description}"? Its shares will be removed and trip balances recalculated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.deleteExpense(expense.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancesTab(BuildContext context, bool isDark, bool isDesktop) {
    if (controller.personBalances.isEmpty) {
      return Center(
        child: Text('No participants added yet.', style: AppTextStyles.bodyMedium(isDark: isDark)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: isDesktop ? 20.0 : 16.r,
        right: isDesktop ? 20.0 : 16.r,
        top: isDesktop ? 20.0 : 16.r,
        bottom: isDesktop ? 120.0 : 120.h,
      ),
      itemCount: controller.personBalances.length,
      itemBuilder: (context, index) {
        final b = controller.personBalances[index];
        final p = b.person;
        final advance = p.advanceAmount;
        final share = b.totalShare;
        final diff = advance - share;
        final isSettled = p.isAdvanceSettled;

        return Card(
          margin: EdgeInsets.only(bottom: isDesktop ? 12.0 : 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 16.0 : 16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.textSecondaryLight,
                          child: Text(
                            p.name.isNotEmpty ? p.name[0] : 'P',
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: isDesktop ? 12.0 : 12.w),
                        Text(
                          p.name,
                          style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (advance > 0 || diff != 0)
                      TextButton.icon(
                        onPressed: () => controller.toggleAdvanceSettled(p.id, isSettled),
                        icon: Icon(
                          isSettled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isSettled ? Colors.green : AppColors.primary,
                          size: 20,
                        ),
                        label: Text(
                          isSettled ? 'Settled' : 'Mark Settled',
                          style: TextStyle(
                            color: isSettled ? Colors.green : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Divider(height: isDesktop ? 24.0 : 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Advance Paid', style: AppTextStyles.bodyMedium(isDark: isDark)),
                    Text(
                      '₹${advance.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: isDesktop ? 15.0 : 15.sp, fontWeight: FontWeight.w600, color: AppColors.secondary),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 8.0 : 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expense Share', style: AppTextStyles.bodyMedium(isDark: isDark)),
                    Text(
                      '₹${share.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: isDesktop ? 15.0 : 15.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 8.0 : 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(diff >= 0 ? 'To Receive' : 'To Pay', style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '₹${diff.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isDesktop ? 16.0 : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: diff >= 0 ? AppColors.owed : AppColors.owe,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddAdvanceDialog(BuildContext context) {
    if (controller.people.isEmpty) {
      Get.snackbar('No Participants', 'Please add participants first.');
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedPersonId = controller.people.first.id;
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Advance Payment',
                    style: AppTextStyles.h2(isDark: isDark),
                  ),
                  const SizedBox(height: 20),
                  Text('Select Participant', style: AppTextStyles.bodyMedium(isDark: isDark)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedPersonId,
                    dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: controller.people.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, style: AppTextStyles.bodyMedium(isDark: isDark)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedPersonId = val;
                        // Auto-fill existing advance if any
                        final person = controller.people.firstWhereOrNull((p) => p.id == val);
                        if (person != null && person.advanceAmount > 0) {
                          amountController.text = person.advanceAmount.toStringAsFixed(2);
                        } else {
                          amountController.text = '';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Advance Amount (₹)', style: AppTextStyles.bodyMedium(isDark: isDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.bodyLarge(isDark: isDark),
                    decoration: InputDecoration(
                      hintText: 'Enter amount...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (selectedPersonId == null) return;
                        final amount = double.tryParse(amountController.text) ?? 0.0;
                        if (amount < 0) {
                          Get.snackbar('Error', 'Amount must be positive');
                          return;
                        }
                        controller.updatePersonAdvance(selectedPersonId!, amount, false);
                        Get.back();
                      },
                      child: const Text('Save Advance', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailedBalanceCard(BuildContext context, PersonBalanceModel b, bool isDark, {required bool isDesktop}) {
    final net = b.netBalance;
    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16.0 : 16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    b.person.name.isNotEmpty ? b.person.name[0] : 'P',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: isDesktop ? 12.0 : 12.w),
                Expanded(
                  child: Text(
                    b.person.name,
                    style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: net > 0
                        ? AppColors.owed.withValues(alpha: 0.15)
                        : (net < 0 ? AppColors.owe.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    net > 0 ? 'Gets back' : (net < 0 ? 'Owes' : 'Settled'),
                    style: TextStyle(
                      fontSize: isDesktop ? 12.0 : 12.sp,
                      fontWeight: FontWeight.bold,
                      color: net > 0 ? AppColors.owed : (net < 0 ? AppColors.owe : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: isDesktop ? 24.0 : 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Spent (Share)', style: AppTextStyles.bodyMedium(isDark: isDark)),
                Text(
                  '₹${b.totalShare.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: isDesktop ? 15.0 : 15.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 8.0 : 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Paid by them', style: AppTextStyles.bodyMedium(isDark: isDark)),
                Text(
                  '₹${b.totalPaid.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: isDesktop ? 15.0 : 15.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 8.0 : 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net Balance', style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(fontWeight: FontWeight.bold)),
                Text(
                  net > 0 ? '+₹${net.toStringAsFixed(2)}' : (net < 0 ? '-₹${net.abs().toStringAsFixed(2)}' : '₹0.00'),
                  style: TextStyle(
                    fontSize: isDesktop ? 16.0 : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: net > 0 ? AppColors.owed : (net < 0 ? AppColors.owe : Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 16.0 : 12.h,
        horizontal: isDesktop ? 12.0 : 8.w,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isDesktop ? 22.0 : 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 6.0 : 4.h),
          Text(
            label,
            style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
              fontSize: isDesktop ? 13.0 : 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTrip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: const Text(
            'Are you sure you want to delete this trip? All participants, expenses, and splits for this trip will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Get.back();
                controller.deleteTrip();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'rent':
        return Icons.home_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }
}