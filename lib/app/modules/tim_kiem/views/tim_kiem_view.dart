import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tim_kiem_controller.dart';

class TimKiemView extends GetView<TimKiemController> {
  const TimKiemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Tìm Kiếm CCCD',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // VNPost Account Card
              Obx(() => Card(
                    elevation: 2,
                    shadowColor: colorScheme.shadow.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Header
                        InkWell(
                          onTap: controller.toggleAccountCard,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.account_circle,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tài khoản VNPost',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      if (controller
                                          .usernameController.text.isNotEmpty)
                                        Text(
                                          controller.usernameController.text,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  controller.isAccountCardExpanded.value
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expandable content
                        if (controller.isAccountCardExpanded.value)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              children: [
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                // Username field
                                TextField(
                                  controller: controller.usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Tên đăng nhập',
                                    hintText: 'Nhập tên đăng nhập VNPost',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: colorScheme.primary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: colorScheme.outline),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: colorScheme.outline),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: colorScheme.primary, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Password field
                                Obx(() => TextField(
                                      controller: controller.passwordController,
                                      obscureText:
                                          !controller.isPasswordVisible.value,
                                      decoration: InputDecoration(
                                        labelText: 'Mật khẩu',
                                        hintText: 'Nhập mật khẩu VNPost',
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: colorScheme.primary,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller.isPasswordVisible.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          onPressed: controller
                                              .togglePasswordVisibility,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: colorScheme.outline),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: colorScheme.outline),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: colorScheme.primary,
                                              width: 2),
                                        ),
                                        filled: true,
                                        fillColor: colorScheme.surface,
                                      ),
                                    )),
                                const SizedBox(height: 16),
                                // Save button
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: controller.saveCredentials,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Lưu tài khoản'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )),

              const SizedBox(height: 16),

              // Search Criteria Card
              Card(
                elevation: 2,
                shadowColor: colorScheme.shadow.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tiêu chí tìm kiếm',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Info text for web search
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tìm kiếm trên hanhchinhcong.vnpost.vn. Hệ thống sẽ tự động đăng nhập.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name field
                      TextField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Nhập họ tên cần tìm',
                          prefixIcon: Icon(
                            Icons.person_outline,
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
                            borderSide: BorderSide(
                                color: colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Birth date field
                      TextField(
                        controller: controller.birthDateController,
                        readOnly: true,
                        onTap: () => controller.pickBirthDate(context),
                        decoration: InputDecoration(
                          labelText: 'Ngày sinh (dd-MM-yyyy)',
                          hintText: 'Chọn ngày sinh',
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: colorScheme.primary,
                          ),
                          suffixIcon:
                              controller.birthDateController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: colorScheme.onSurfaceVariant),
                                      onPressed: () {
                                        controller.birthDateController.clear();
                                        controller.selectedDate = null;
                                      },
                                    )
                                  : null,
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
                            borderSide: BorderSide(
                                color: colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Month dropdown
                      Obx(() => DropdownButtonFormField<int>(
                            value: controller.selectedMonth.value,
                            decoration: InputDecoration(
                              labelText: 'Tháng chấp nhận',
                              prefixIcon: Icon(
                                Icons.date_range_outlined,
                                color: colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: colorScheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                            items: List.generate(13, (index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text(controller.getMonthName(index)),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedMonth.value = value;
                              }
                            },
                          )),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                controller.clearSearch();
                              },
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Xóa'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Obx(() => FilledButton.icon(
                                  onPressed: controller.isSearching.value ||
                                          controller.isLoggingIn.value
                                      ? null
                                      : () {
                                          controller.performWebSearch();
                                        },
                                  icon: controller.isSearching.value ||
                                          controller.isLoggingIn.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.search),
                                  label: Text(
                                    controller.isLoggingIn.value
                                        ? 'Đang đăng nhập...'
                                        : controller.isSearching.value
                                            ? 'Đang tìm...'
                                            : 'Tìm Kiếm',
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Search Results - Web Search
              Obx(() {
                if (controller.webSearchResults.isNotEmpty) {
                  return Card(
                    elevation: 2,
                    shadowColor: colorScheme.shadow.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_done_outlined,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Kết quả từ VNPost',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${controller.webSearchResults.length}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.webSearchResults.length,
                            itemBuilder: (context, index) {
                              final transaction =
                                  controller.webSearchResults[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row 1: STT and Status
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'STT ${transaction.stt}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    transaction.trangThai,
                                                    colorScheme),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                transaction.trangThai,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Row 2: Name
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 18,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              transaction.hoTen,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Row 3: Postal Code with Copy Button
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_post_office_outlined,
                                            size: 18,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Mã bưu gửi: ${transaction.maBuuGui}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              controller.copyPostalCode(
                                                  transaction.maBuuGui);
                                            },
                                            icon: Icon(
                                              Icons.copy,
                                              size: 18,
                                              color: colorScheme.primary,
                                            ),
                                            tooltip: 'Sao chép mã bưu gửi',
                                            style: IconButton.styleFrom(
                                              backgroundColor: colorScheme
                                                  .primaryContainer
                                                  .withOpacity(0.5),
                                              padding: const EdgeInsets.all(8),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (transaction
                                          .cuocChuyenPhat.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 18,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Cước: ${transaction.cuocChuyenPhat} đ',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      if (transaction.ngayTao.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              transaction.ngayTao,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    if (status.contains('Chưa xác nhận') || status.contains('Chưa Xác Nhận')) {
      return Colors.orange;
    } else if (status.contains('Xác nhận') || status.contains('Xác Nhận')) {
      return Colors.green;
    } else if (status.contains('In phong bì') ||
        status.contains('In Phong Bì')) {
      return Colors.blue;
    } else if (status.contains('Xuất Portal') || status.contains('Portal')) {
      return Colors.purple;
    }
    return colorScheme.primary;
  }
}
