import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng Quét CCCD'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 0: Postal Code Input
              TextField(
                controller: controller.postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã bưu gửi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_post_office),
                  hintText: 'Nhập mã bưu gửi cho các CCCD tiếp theo',
                ),
                onChanged: (value) {
                  controller.updatePostalCode(value);
                },
              ),

              const SizedBox(height: 16.0),

              // Section 1: Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.capture();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 8.0),
                          Flexible(
                            child: Text(
                              'Capture',
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // Section 1.5: Delete All Button
              ElevatedButton(
                onPressed: () {
                  controller.deleteAllCCCDData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_forever),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        'Xóa tất cả',
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // Section 2: Status Card
              Obx(
                () => Card(
                  margin: EdgeInsets.zero, // Remove default Card margin
                  elevation: 2.0, // Add a subtle shadow
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.numbers, size: 20.0),
                            const SizedBox(width: 8.0),
                            Text(
                              'Số lượng: ${controller.indexCurrent.value} / ${controller.totalCCCD.length}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 20.0),
                            const SizedBox(width: 8.0),
                            Text(
                              'Name: ${controller.nameCurrent.value}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            const Icon(Icons.play_arrow, size: 20.0),
                            const SizedBox(width: 8.0),
                            Text(
                              'Đang chạy: ${controller.isRunning.value}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: controller.isRunning.value,
                                  onChanged: (value) {
                                    controller.isRunning.value = value!;
                                    if (value) {
                                      controller.sendCCCD(controller.totalCCCD[
                                          controller.indexCurrent.value]);
                                    }
                                  },
                                ),
                                const Text('Gửi'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: controller.isAutoRun.value,
                                  onChanged: (value) {
                                    controller.isAutoRun.value = value!;
                                    if (controller.isAutoRun.value) {
                                      controller.processCCCD();
                                    } else {
                                      controller.isSending = false;
                                    }
                                    controller.sendAutoRunToFirebase(value);
                                  },
                                ),
                                const Text('Tự động chạy'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                controller.previousCCCD();
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_left),
                                  SizedBox(width: 4.0),
                                  Text('Left'),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                controller.nextCCCD();
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Right'),
                                  SizedBox(width: 4.0),
                                  Icon(Icons.arrow_right),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              //create a textbox to find cccd from name
              TextField(
                onChanged: (value) {
                  controller.searchCCCD(value);
                },
                decoration: InputDecoration(
                  labelText: 'Tìm kiếm CCCD',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),

              // Section 3: Conditional CCCD List and Resend Button
              Obx(() {
                if (controller.isAutoRun.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Auto-run mode buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.addCurrentCCCDToError();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error),
                                  SizedBox(width: 8.0),
                                  Flexible(
                                    child: Text(
                                      'CCCD Lỗi',
                                      style: TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.navigateToCCCDErrorPage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.list_alt),
                                  const SizedBox(width: 8.0),
                                  Flexible(
                                    child: Text(
                                      'Xem Lỗi (${controller.errorCCCDList.length})',
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Danh sách CCCD đã quét:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8.0),
                      // Display the list of CCCD
                      SizedBox(
                        height: 300.0, // Set a fixed height for the ListView
                        child: ListView.builder(
                          controller: controller.scrollController,
                          shrinkWrap:
                              true, // Important for nested ListView in SingleChildScrollView
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Enable ListView scrolling
                          itemCount: controller.totalCCCD.length,
                          itemBuilder: (context, index) {
                            final cccd = controller.totalCCCD[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                leading: const Icon(
                                    Icons.credit_card), // Add leading icon
                                title: Text(
                                    "${index + 1} ${cccd.Name}"), // Corrected property access
                                subtitle: Text(
                                    'ID: ${cccd.Id}'), // Corrected property access
                                // Add more details if needed
                              ),
                            );
                          },
                        ),
                      ),
                      if (controller
                          .isSending) // Show "Gửi lại" only when sending
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              controller.resendCurrentCCCD();
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh),
                                SizedBox(width: 8.0),
                                Text('Gửi lại'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return const SizedBox
                      .shrink(); // Hide the section when not auto-running
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
