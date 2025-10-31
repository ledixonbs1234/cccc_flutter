# Firebase Key Management Implementation

## Tổng quan
Đã thêm chức năng quản lý Firebase key để tránh xung đột giữa nhiều người dùng và liên kết với Chrome Extension.

## Các thay đổi đã thực hiện

### 1. Cập nhật Dependencies
- Thêm `get_storage: ^2.1.1` vào `pubspec.yaml` để lưu trữ key locally

### 2. FirebaseManager Enhancement

#### Các thay đổi chính:
- **Storage Integration**: Thêm `GetStorage` để lưu Firebase key
- **Dynamic Root Path**: Firebase path thay đổi dựa trên key: `CCCDAPP/{key}/`
- **Key Management**: Getter/setter cho `currentKey` với auto-save
- **Connection Reset**: Method `resetConnection()` để tái kết nối khi key thay đổi

#### Code structure:
```dart
class FirebaseManager {
  final storage = GetStorage();
  String? _currentKey;
  
  // Dynamic path based on key
  String? get currentKey => _currentKey ?? storage.read('firebase_key');
  set currentKey(String? key) {
    _currentKey = key;
    if (key != null && key.isNotEmpty) {
      storage.write('firebase_key', key);
      _updateRootPath(); // Updates to: CCCDAPP/{key}/
    }
  }
  
  void resetConnection() {
    lastTimeStamp = "";
    setUp(); // Reinitialize listeners with new path
  }
}
```

### 3. HomeController Enhancement

#### Thêm state management:
- `firebaseKeyController`: TextField controller cho key input
- `currentFirebaseKey.obs`: Observable current key
- `isKeySetupComplete.obs`: Observable setup status

#### Thêm methods:
- `showFirebaseKeyDialog()`: Hiển thị dialog cấu hình key
- `saveFirebaseKey()`: Validate và lưu key với format checking
- `clearFirebaseKey()`: Xóa key và reset về default
- `getFirebaseStatus()`: Lấy status hiện tại cho UI

#### Key validation:
- Only alphanumeric characters, underscore, and hyphen allowed
- Maximum 20 characters
- Must not be empty

### 4. UI Implementation

#### Firebase Key Section:
- **Location**: Giữa Postal Code và Action Buttons sections
- **Status Display**: 
  - 🔑 Green container when key is set
  - ⚠️ Orange warning when no key
- **Actions**: 
  - ➕ Add key button when not set
  - ✏️ Edit key button when set

#### Dialog Features:
- Current key display
- Input validation
- Clear key option (red button)
- Save/Cancel actions

### 5. Main.dart Updates
- Thêm `await GetStorage.init()` trước Firebase initialization
- Import `get_storage/get_storage.dart`

## Cách sử dụng

### Cho người dùng ứng dụng:
1. Mở app, sẽ thấy cảnh báo "Chưa cấu hình Firebase key"
2. Nhấn nút ➕ để mở dialog cấu hình
3. Nhập key (ví dụ: `user123`, `room001`)
4. Nhấn "Lưu"
5. Firebase sẽ sử dụng path: `CCCDAPP/user123/`

### Cho Chrome Extension:
- Extension cần sử dụng cùng key để kết nối đến path tương ứng
- Path structure: `CCCDAPP/{shared_key}/message/`
- Auto-run state: `CCCDAPP/{shared_key}/cccdauto`

### Key Management:
- Key được lưu tự động trong local storage
- Thay đổi key sẽ reset Firebase connection
- Xóa key sẽ về lại path mặc định `CCCDAPP/`

## Lợi ích

1. **Tránh xung đột**: Mỗi user/room có riêng Firebase path
2. **Chrome Extension Integration**: Dễ dàng sync với extension thông qua shared key
3. **User Experience**: UI rõ ràng cho việc setup và quản lý key
4. **Persistent**: Key được lưu local, không cần setup lại mỗi lần mở app
5. **Validation**: Đảm bảo key format đúng cho Firebase path

## Firebase Structure
```
CCCDAPP/
├── (default - no key)/
│   ├── message/
│   └── cccdauto
├── user123/
│   ├── message/
│   └── cccdauto
└── room001/
    ├── message/
    └── cccdauto
```
