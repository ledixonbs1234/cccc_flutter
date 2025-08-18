import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

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
              // Section 1: Status Message
              _buildStatusMessageSection(context, colorScheme),

              const SizedBox(height: 8.0),

              // Section 2: Postal Code Input Card
              _buildPostalCodeSection(context, colorScheme),

              const SizedBox(height: 8.0),

              // Section 3: Action Buttons
              _buildActionButtonsSection(context, colorScheme),

              const SizedBox(height: 8.0),

              // Section 4: Status and Controls
              _buildStatusSection(context, colorScheme),

              const SizedBox(height: 8.0),
              // Section 5: Search
              _buildSearchSection(context, colorScheme),

              const SizedBox(height: 8.0),

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
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.scanPostalCode();
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Quét mã hiệu'),
                    style: OutlinedButton.styleFrom(
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
                      controller.testCapture();
                    },
                    icon: const Icon(Icons.science),
                    label: const Text('Test Capture'),
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
                const SizedBox(width: 12),
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

            const SizedBox(height: 16),

            // Error management buttons row
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: controller.isAutoRun.value
                            ? () {
                                controller.addCurrentCCCDToError();
                              }
                            : null,
                        icon: const Icon(Icons.error_outline),
                        label: const Text('CCCD Lỗi'),
                        style: FilledButton.styleFrom(
                          backgroundColor: controller.isAutoRun.value
                              ? colorScheme.error
                              : colorScheme.surfaceContainerHighest,
                          foregroundColor: controller.isAutoRun.value
                              ? colorScheme.onError
                              : colorScheme.onSurfaceVariant,
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
                )),

            const SizedBox(height: 8),
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
                        controller.isAutoRun.value
                            ? Icons.autorenew
                            : Icons.pause_circle,
                        'Chế độ',
                        controller.isAutoRun.value ? 'Tự động' : 'Thủ công',
                        colorScheme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Control Actions
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => FilledButton.icon(
                            onPressed: controller.totalCCCD.isNotEmpty
                                ? () {
                                    // Send CCCD at current position
                                    if (controller.indexCurrent.value <
                                        controller.totalCCCD.length) {
                                      controller.sendCCCD(controller.totalCCCD[
                                          controller.indexCurrent.value]);

                                      // Show success feedback
                                      Get.snackbar(
                                        "Đã gửi",
                                        "Đã gửi CCCD: ${controller.totalCCCD[controller.indexCurrent.value].Name}",
                                        duration: const Duration(seconds: 2),
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor:
                                            colorScheme.primaryContainer,
                                        colorText:
                                            colorScheme.onPrimaryContainer,
                                        icon: Icon(
                                          Icons.check_circle,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      );
                                    }
                                  }
                                : null, // Disabled when no CCCDs available
                            icon: const Icon(Icons.send),
                            label: const Text('Gửi'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: controller.totalCCCD.isNotEmpty
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              foregroundColor: controller.totalCCCD.isNotEmpty
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          )),
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
      elevation: 4, // Increased elevation for more prominence
      shadowColor: colorScheme.primary
          .withOpacity(0.2), // Primary color shadow for attention
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(24.0), // Increased padding for more space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.search_outlined,
                      color: colorScheme.primary,
                      size: 28, // Larger icon for prominence
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tìm kiếm CCCD',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tìm nhanh theo tên hoặc số CCCD',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) {
                    controller.searchCCCD(value);
                  },
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  decoration: InputDecoration(
                    labelText: 'Nhập tên hoặc ID để tìm kiếm',
                    labelStyle: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: 'VD: Nguyễn Văn A hoặc 052321010762',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.search,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    suffixIcon: Obx(() => controller.hasSearchText.value
                        ? IconButton(
                            onPressed: () {
                              controller.clearSearch();
                            },
                            icon: Icon(
                              Icons.clear_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            tooltip: 'Xóa tìm kiếm',
                          )
                        : Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.5),
                          )),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20, // Increased vertical padding for height
                    ),
                  ),
                ),
              ),

              // Search status indicator
              const SizedBox(height: 16),
              Obx(() => controller.isSearchActive.value
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Đang tìm: "${controller.searchQuery.value}"',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.searchResults.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nhập để tìm kiếm trong ${controller.totalCCCD.length} CCCD',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
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

  // Helper method to build status message section
  Widget _buildStatusMessageSection(
      BuildContext context, ColorScheme colorScheme) {
    return Obx(() {
      // Only show if there's a status message
      if (controller.statusMessage.value.isEmpty) {
        return const SizedBox.shrink();
      }

      Color backgroundColor;
      Color textColor;
      Color borderColor;
      IconData icon;

      // Determine colors and icon based on status type
      switch (controller.statusType.value) {
        case StatusType.success:
          backgroundColor = colorScheme.primaryContainer;
          textColor = colorScheme.onPrimaryContainer;
          borderColor = colorScheme.primary;
          icon = Icons.check_circle_outline;
          break;
        case StatusType.error:
          backgroundColor = colorScheme.errorContainer;
          textColor = colorScheme.onErrorContainer;
          borderColor = colorScheme.error;
          icon = Icons.error_outline;
          break;
        case StatusType.warning:
          backgroundColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange.shade800;
          borderColor = Colors.orange;
          icon = Icons.warning_amber_outlined;
          break;
        case StatusType.info:
          backgroundColor = Colors.blue.withOpacity(0.1);
          textColor = Colors.blue.shade800;
          borderColor = Colors.blue;
          icon = Icons.info_outline;
          break;
        default:
          return const SizedBox.shrink();
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 3,
          shadowColor: borderColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: borderColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.statusMessage.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lúc ${_formatTime(controller.lastOperationTime.value)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      controller.clearStatusMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        color: textColor.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Helper method to format time
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
