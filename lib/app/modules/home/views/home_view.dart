import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'HomeView is working',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
                onPressed: () {
                  controller.capture();
                },
                child: const Text('Capture')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      controller.saveData();
                    },
                    child: const Text('Lưu Trữ')),
                ElevatedButton(
                    onPressed: () {
                      controller.deleteData();
                    },
                    child: const Text('Xóa'))
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  controller.layDanhSach();
                },
                child: const Text('Lấy Danh Sách')),
            Obx(
              () => Card(
                child: Column(
                  children: [
                    Text(
                        'Số lượng: ${controller.indexCurrent} / ${controller.totalCCCD.length}'),
                    Text('Name: ${controller.nameCurrent}'),
                    Text('Đang chạy: ${controller.isRunning}'),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                Checkbox(
                                    value: controller.isRunning.value,
                                    onChanged: (value) {
                                      controller.isRunning.value = value!;
                                      if (value) {
                                        controller.sendCCCD(
                                            controller.totalCCCD[
                                                controller.indexCurrent.value]);
                                      }
                                    }),
                                Text('Gửi')
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                Checkbox(
                                    value: controller.isAutoRun.value,
                                    onChanged: (value) {
                                      controller.isAutoRun.value = value!;
                                      controller.sendAutoRunToFirebase(value);
                                    }),
                                Text('Tự động chạy')
                              ],
                            ),
                          )
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              controller.previousCCCD();
                            },
                            child: const Text('Left')),
                        ElevatedButton(
                            onPressed: () {
                              controller.nextCCCD();
                            },
                            child: const Text('Right')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
