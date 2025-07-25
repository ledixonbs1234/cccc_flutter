import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../models/cccdInfo.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Ứng dụng Quét CCCD',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Postal Code Input Card
              _buildPostalCodeSection(context, colorScheme),

              const SizedBox(height: 24.0),

              // Section 2: Action Buttons
              _buildActionButtonsSection(context, colorScheme),

              const SizedBox(height: 24.0),

              // Section 3: Status and Controls
              _buildStatusSection(context, colorScheme),

              const SizedBox(height: 24.0),
              // Section 4: Search
              _buildSearchSection(context, colorScheme),

              const SizedBox(height: 24.0),

              // Section 5: Search Results (conditional)
              _buildSearchResultsSection(context, colorScheme),

              // Section 6: CCCD List and Error Management
              _buildCCCDListSection(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build postal code input section
  Widget _buildPostalCodeSection(
      BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_post_office_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mã bưu gửi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.postalCodeController,
              decoration: InputDecoration(
                labelText: 'Nhập mã bưu gửi',
                hintText: 'VD: BĐ590000',
                prefixIcon: Icon(
                  Icons.local_post_office,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              onChanged: (value) {
                controller.updatePostalCode(value);
              },
            ),
            const SizedBox(height: 12),
            Obx(() => controller.currentPostalCode.value.isNotEmpty
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mã hiện tại: ${controller.currentPostalCode.value}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  // Helper method to build action buttons section
  Widget _buildActionButtonsSection(
      BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Thao tác',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      controller.capture();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Quét CCCD'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.deleteAllCCCDData();
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Xóa tất cả'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build status and controls section
  Widget _buildStatusSection(BuildContext context, ColorScheme colorScheme) {
    return Obx(() => Card(
          elevation: 2,
          shadowColor: colorScheme.shadow.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Trạng thái hệ thống',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatusRow(
                        context,
                        Icons.numbers,
                        'Số lượng',
                        '${controller.indexCurrent.value} / ${controller.totalCCCD.length}',
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        context,
                        Icons.person_outline,
                        'Tên hiện tại',
                        controller.nameCurrent.value.isEmpty
                            ? 'Chưa có dữ liệu'
                            : controller.nameCurrent.value,
                        colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        context,
                        controller.isRunning.value
                            ? Icons.play_circle
                            : Icons.pause_circle,
                        'Trạng thái',
                        controller.isRunning.value ? 'Đang chạy' : 'Tạm dừng',
                        colorScheme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Control Switches
                Row(
                  children: [
                    Expanded(
                      child: _buildSwitchTile(
                        context,
                        'Gửi',
                        Icons.send,
                        controller.isRunning.value,
                        (value) {
                          controller.isRunning.value = value;
                          if (value && controller.totalCCCD.isNotEmpty) {
                            controller.sendCCCD(controller
                                .totalCCCD[controller.indexCurrent.value]);
                          }
                        },
                        colorScheme,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSwitchTile(
                        context,
                        'Tự động',
                        Icons.autorenew,
                        controller.isAutoRun.value,
                        (value) {
                          controller.isAutoRun.value = value;
                          if (controller.isAutoRun.value) {
                            controller.processCCCD();
                          } else {
                            controller.isSending = false;
                          }
                          controller.sendAutoRunToFirebase(value);
                        },
                        colorScheme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.previousCCCD();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Trước'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.nextCCCD();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Tiếp'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  // Helper method to build status row
  Widget _buildStatusRow(BuildContext context, IconData icon, String label,
      String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper method to build switch tile
  Widget _buildSwitchTile(BuildContext context, String title, IconData icon,
      bool value, Function(bool) onChanged, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: value
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: value
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // Helper method to build search section
  Widget _buildSearchSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tìm kiếm CCCD',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      controller.searchCCCD(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Nhập tên hoặc ID để tìm kiếm',
                      hintText: 'VD: Nguyễn Văn A hoặc 052321010762',
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => controller.isSearchActive.value
                    ? IconButton(
                        onPressed: () {
                          controller.clearSearch();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.error,
                        ),
                        tooltip: 'Xóa tìm kiếm',
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.errorContainer,
                          foregroundColor: colorScheme.onErrorContainer,
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build CCCD list section
  Widget _buildCCCDListSection(BuildContext context, ColorScheme colorScheme) {
    return Obx(() {
      if (controller.isAutoRun.value) {
        return Card(
          elevation: 2,
          shadowColor: colorScheme.shadow.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.list_alt_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Quản lý CCCD',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Error management buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          controller.addCurrentCCCDToError();
                        },
                        icon: const Icon(Icons.error_outline),
                        label: const Text('CCCD Lỗi'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.navigateToCCCDErrorPage();
                        },
                        icon: const Icon(Icons.list_alt),
                        label: Text(
                            'Xem Lỗi (${controller.errorCCCDList.length})'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.tertiary,
                          side: BorderSide(color: colorScheme.tertiary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // CCCD List Header
                Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Danh sách CCCD đã quét (${controller.totalCCCD.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // CCCD List
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: colorScheme.outline.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: controller.totalCCCD.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card_off,
                                size: 48,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có CCCD nào được quét',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: controller.totalCCCD.length,
                          itemExtent: HomeController
                              .cccdItemExtent, // Fixed item height for precise scroll positioning
                          itemBuilder: (context, index) {
                            final cccd = controller.totalCCCD[index];
                            final isCurrentIndex =
                                index == controller.indexCurrent.value;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isCurrentIndex
                                    ? colorScheme.primaryContainer
                                        .withOpacity(0.3)
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentIndex
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.2),
                                  width: isCurrentIndex ? 2 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCurrentIndex
                                        ? colorScheme.primary
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.credit_card,
                                    color: isCurrentIndex
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${index + 1}. ${cccd.Name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: isCurrentIndex
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isCurrentIndex
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurface,
                                      ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID: ${cccd.Id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    if (cccd.maBuuGui != null &&
                                        cccd.maBuuGui!.isNotEmpty)
                                      Text(
                                        'Mã bưu gửi: ${cccd.maBuuGui}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colorScheme.tertiary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                  ],
                                ),
                                trailing: isCurrentIndex
                                    ? Icon(
                                        Icons.play_circle,
                                        color: colorScheme.primary,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),

                // Resend button when sending
                if (controller.isSending)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          controller.resendCurrentCCCD();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Gửi lại'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      } else {
        return Card(
          elevation: 1,
          shadowColor: colorScheme.shadow.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.autorenew_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bật chế độ tự động để xem danh sách CCCD',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  // Helper method to build search results section
  Widget _buildSearchResultsSection(
      BuildContext context, ColorScheme colorScheme) {
    return Obx(() {
      if (!controller.isSearchActive.value) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Card(
            elevation: 3,
            shadowColor: colorScheme.shadow.withOpacity(0.2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.primaryContainer.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.search_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kết quả tìm kiếm: "${controller.searchQuery.value}"',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${controller.searchResults.length}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (controller.searchResults.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: colorScheme.error.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy kết quả',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Không có CCCD nào khớp với từ khóa "${controller.searchQuery.value}"',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: controller.searchResults.map((cccd) {
                        int positionInMainList = controller.totalCCCD
                                .indexWhere((item) => item.Id == cccd.Id) +
                            1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: colorScheme.outline.withOpacity(0.3)),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.credit_card,
                                color: colorScheme.onSecondaryContainer,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              cccd.Name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ID: ${cccd.Id}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                Text(
                                  'Ngày sinh: ${cccd.NgaySinh}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                if (cccd.maBuuGui != null &&
                                    cccd.maBuuGui!.isNotEmpty)
                                  Text(
                                    'Mã bưu gửi: ${cccd.maBuuGui}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.tertiary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                Text(
                                  'Vị trí: $positionInMainList/${controller.totalCCCD.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            trailing: FilledButton.icon(
                              onPressed: () {
                                controller.goToSearchResult(cccd);
                              },
                              icon: const Icon(Icons.my_location, size: 16),
                              label: const Text('Đi đến'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 36),
                                textStyle:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      );
    });
  }
}
