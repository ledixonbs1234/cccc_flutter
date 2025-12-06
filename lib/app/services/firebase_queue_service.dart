import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../managers/fireabaseManager.dart';
import '../modules/home/models/cccdInfo.dart';

/// Service class để quản lý CCCD Queue trên Firebase
/// Tuân theo structure của Chrome Extension
class FirebaseQueueService {
  final FirebaseManager _firebaseManager = FirebaseManager();

  DatabaseReference get _rootPath => _firebaseManager.rootPath;

  /// Get reference to cccdQueue node
  DatabaseReference get _queueRef => _rootPath.child('cccdQueue');

  /// Get reference to currentIndex node
  DatabaseReference get _currentIndexRef => _rootPath.child('currentIndex');

  /// Get reference to cccdauto node
  DatabaseReference get _autoRunRef => _rootPath.child('cccdauto');

  /// ✅ 1. Add single CCCD to queue
  /// Tự động tạo createdAt timestamp unique
  Future<String?> addCCCDToQueue({
    required CCCDInfo cccd,
  }) async {
    try {
      // Ensure createdAt is set with unique timestamp
      if (cccd.createdAt.isEmpty) {
        cccd.createdAt = DateTime.now().toIso8601String();
      }

      // Ensure status is set
      if (cccd.status.isEmpty) {
        cccd.status = 'pending';
      }

      // Push to Firebase (auto-generates key)
      final newRef = _queueRef.push();
      await newRef.set(cccd.toJsonFull());

      print('✅ Added CCCD to queue: ${cccd.Name} (key: ${newRef.key})');
      return newRef.key;
    } catch (e) {
      print('❌ Error adding CCCD to queue: $e');
      Get.snackbar('Lỗi', 'Không thể thêm CCCD vào queue: $e');
      return null;
    }
  }

  /// ✅ 2. Upload multiple CCCDs to queue
  /// Clear existing queue và thêm danh sách mới
  Future<bool> uploadCCCDList({
    required List<CCCDInfo> cccdList,
    bool clearExisting = true,
  }) async {
    try {
      // Clear existing queue if requested
      if (clearExisting) {
        await _queueRef.remove();
      }

      // Add all CCCDs with unique timestamps
      for (int i = 0; i < cccdList.length; i++) {
        final cccd = cccdList[i];

        // Set index and unique timestamp
        cccd.index = i;
        cccd.status = 'pending';
        cccd.createdAt =
            DateTime.now().add(Duration(milliseconds: i)).toIso8601String();

        await _queueRef.push().set(cccd.toJsonFull());
      }

      // Reset currentIndex to 0
      await _currentIndexRef.set(0);

      print('✅ Uploaded ${cccdList.length} CCCDs to queue');
      Get.snackbar(
          'Thành công', 'Đã upload ${cccdList.length} CCCD lên Firebase');
      return true;
    } catch (e) {
      print('❌ Error uploading CCCD list: $e');
      Get.snackbar('Lỗi', 'Không thể upload danh sách CCCD: $e');
      return false;
    }
  }

  /// ✅ 3. Watch CCCD Queue (realtime stream)
  /// Returns sorted list by createdAt timestamp
  Stream<List<CCCDInfo>> watchCCCDQueue() {
    return _queueRef.onValue.map((event) {
      if (event.snapshot.value == null) {
        return <CCCDInfo>[];
      }

      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final cccdList = <CCCDInfo>[];

        data.forEach((key, value) {
          try {
            final cccdData = Map<String, dynamic>.from(value as Map);
            final cccd = CCCDInfo('', '', '');
            cccd.fromJson(cccdData);
            cccd.firebaseKey = key; // Save Firebase key for updates
            cccdList.add(cccd);
          } catch (e) {
            print('Error parsing CCCD entry: $e');
          }
        });

        // ✅ CRITICAL: Sort by createdAt timestamp
        cccdList.sort((a, b) {
          try {
            final timeA = DateTime.parse(a.createdAt);
            final timeB = DateTime.parse(b.createdAt);
            return timeA.compareTo(timeB);
          } catch (e) {
            print('Error sorting by createdAt: $e');
            return 0;
          }
        });

        print('📊 Queue loaded: ${cccdList.length} CCCDs');
        return cccdList;
      } catch (e) {
        print('❌ Error parsing queue data: $e');
        return <CCCDInfo>[];
      }
    });
  }

  /// ✅ 4. Watch current index (realtime stream)
  Stream<int> watchCurrentIndex() {
    return _currentIndexRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return 0;

      try {
        return value as int;
      } catch (e) {
        print('Error parsing currentIndex: $e');
        return 0;
      }
    });
  }

  /// ✅ 5. Watch auto-run state (realtime stream)
  Stream<bool> watchAutoRunState() {
    print('🔍 Watching auto-run state at: ${_autoRunRef.path}');

    return _autoRunRef.onValue.map((event) {
      final value = event.snapshot.value;
      print(
          '🔍 Auto-run value from Firebase: $value (type: ${value.runtimeType})');

      if (value == null) {
        print('⚠️ Auto-run value is null, returning false');
        return false;
      }

      try {
        final boolValue = value as bool;
        print('✅ Auto-run parsed: $boolValue');
        return boolValue;
      } catch (e) {
        print('❌ Error parsing autorun state: $e');
        return false;
      }
    });
  }

  /// ✅ 6. Update CCCD status in queue
  /// Used by Extension to mark processing/completed/error
  Future<bool> updateCCCDStatus({
    required String firebaseKey,
    required String status,
    String? errorReason,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };

      // Add processedAt timestamp for non-pending status
      if (status == 'processing' ||
          status == 'completed' ||
          status == 'error') {
        updates['processedAt'] = DateTime.now().toIso8601String();
      }

      // Add error reason if provided
      if (errorReason != null && errorReason.isNotEmpty) {
        updates['errorReason'] = errorReason;
      }

      await _queueRef.child(firebaseKey).update(updates);
      print('✅ Updated CCCD status: $firebaseKey -> $status');
      return true;
    } catch (e) {
      print('❌ Error updating CCCD status: $e');
      return false;
    }
  }

  /// ✅ 7. Update current index
  /// Used when manually navigating (when auto is OFF)
  Future<bool> updateCurrentIndex(int index) async {
    try {
      await _currentIndexRef.set(index);
      print('✅ Updated currentIndex: $index');
      return true;
    } catch (e) {
      print('❌ Error updating currentIndex: $e');
      return false;
    }
  }

  /// ✅ 8. Set auto-run state
  Future<bool> setAutoRunState(bool isAuto) async {
    try {
      // ✅ Nếu muốn chắc chắn cả 2 đều thành công:
      await _firebaseManager.sendAutoRunToFirebase(isAuto);

      print('✅ Updated auto-run state: $isAuto');
      return true;
    } catch (e) {
      print('❌ Error updating auto-run state: $e');
      return false;
    }
  }

  /// ✅ Get current auto-run state (one-time read)
  Future<bool> getAutoRunState() async {
    try {
      final snapshot = await _autoRunRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        return false;
      }
      return snapshot.value as bool;
    } catch (e) {
      print('❌ Error getting auto-run state: $e');
      return false;
    }
  }

  /// ✅ 9. Clear entire queue
  Future<bool> clearQueue() async {
    try {
      await _queueRef.remove();
      await _currentIndexRef.set(0);
      print('✅ Cleared CCCD queue');
      return true;
    } catch (e) {
      print('❌ Error clearing queue: $e');
      return false;
    }
  }

  /// ✅ 10. Remove single CCCD from queue
  Future<bool> removeCCCD(String firebaseKey) async {
    try {
      await _queueRef.child(firebaseKey).remove();
      print('✅ Removed CCCD from queue: $firebaseKey');
      return true;
    } catch (e) {
      print('❌ Error removing CCCD: $e');
      return false;
    }
  }

  /// ✅ 11. Get queue statistics
  Future<Map<String, int>> getQueueStats() async {
    try {
      final snapshot = await _queueRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        return {
          'total': 0,
          'pending': 0,
          'processing': 0,
          'completed': 0,
          'error': 0,
        };
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      int total = 0;
      int pending = 0;
      int processing = 0;
      int completed = 0;
      int error = 0;

      data.forEach((key, value) {
        total++;
        final status = (value as Map)['status'] ?? 'pending';
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'processing':
            processing++;
            break;
          case 'completed':
            completed++;
            break;
          case 'error':
            error++;
            break;
        }
      });

      return {
        'total': total,
        'pending': pending,
        'processing': processing,
        'completed': completed,
        'error': error,
      };
    } catch (e) {
      print('❌ Error getting queue stats: $e');
      return {
        'total': 0,
        'pending': 0,
        'processing': 0,
        'completed': 0,
        'error': 0,
      };
    }
  }

  /// ✅ 12. Get current CCCD being processed (by Extension)
  Future<CCCDInfo?> getCurrentCCCD() async {
    try {
      // Get current index
      final indexSnapshot = await _currentIndexRef.get();
      if (!indexSnapshot.exists || indexSnapshot.value == null) {
        return null;
      }

      final currentIndex = indexSnapshot.value as int;

      // Get queue
      final queueSnapshot = await _queueRef.get();
      if (!queueSnapshot.exists || queueSnapshot.value == null) {
        return null;
      }

      final data = queueSnapshot.value as Map<dynamic, dynamic>;
      final cccdList = <CCCDInfo>[];

      data.forEach((key, value) {
        try {
          final cccdData = Map<String, dynamic>.from(value as Map);
          final cccd = CCCDInfo('', '', '');
          cccd.fromJson(cccdData);
          cccd.firebaseKey = key;
          cccdList.add(cccd);
        } catch (e) {
          print('Error parsing CCCD: $e');
        }
      });

      // Sort by createdAt
      cccdList.sort((a, b) {
        final timeA = DateTime.parse(a.createdAt);
        final timeB = DateTime.parse(b.createdAt);
        return timeA.compareTo(timeB);
      });

      // Return CCCD at currentIndex
      if (currentIndex >= 0 && currentIndex < cccdList.length) {
        return cccdList[currentIndex];
      }

      return null;
    } catch (e) {
      print('❌ Error getting current CCCD: $e');
      return null;
    }
  }
}
