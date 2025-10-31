// Chrome Extension Integration Example
// File: chrome-extension/firebase-integration.js

// Firebase configuration (same as Flutter app)
const firebaseConfig = {
  // Your Firebase config here
};

// Initialize Firebase
import { initializeApp } from 'firebase/app';
import { getDatabase, ref, set, onValue } from 'firebase/database';

const app = initializeApp(firebaseConfig);
const database = getDatabase(app);

class ChromeExtensionFirebase {
  constructor() {
    this.currentKey = null;
    this.rootPath = null;
    this.lastTimeStamp = "";
    
    // Load saved key from Chrome storage
    this.loadSavedKey();
  }
  
  // Load key from Chrome storage
  async loadSavedKey() {
    const result = await chrome.storage.local.get(['firebase_key']);
    if (result.firebase_key) {
      this.setKey(result.firebase_key);
    }
  }
  
  // Set Firebase key (should match Flutter app key)
  async setKey(key) {
    this.currentKey = key;
    
    // Save to Chrome storage
    await chrome.storage.local.set({ firebase_key: key });
    
    // Update Firebase path
    if (key && key.trim() !== '') {
      this.rootPath = ref(database, `CCCDAPP/${key}`);
    } else {
      this.rootPath = ref(database, 'CCCDAPP');
    }
    
    // Setup listeners
    this.setupListeners();
  }
  
  // Clear key
  async clearKey() {
    this.currentKey = null;
    await chrome.storage.local.remove(['firebase_key']);
    this.rootPath = ref(database, 'CCCDAPP');
    this.setupListeners();
  }
  
  // Setup Firebase listeners
  setupListeners() {
    if (!this.rootPath) return;
    
    // Listen to messages from Flutter app
    const messageRef = ref(database, `${this.rootPath.key}/message`);
    onValue(messageRef, (snapshot) => {
      if (snapshot.exists()) {
        const data = snapshot.val();
        this.handleMessage(data);
      }
    });
    
    // Listen to auto-run state
    const autoRunRef = ref(database, `${this.rootPath.key}/cccdauto`);
    onValue(autoRunRef, (snapshot) => {
      if (snapshot.exists()) {
        const isAutoRun = snapshot.val();
        this.handleAutoRunChange(isAutoRun);
      }
    });
  }
  
  // Send message to Flutter app
  async sendMessage(command, data) {
    if (!this.rootPath) {
      console.error('Firebase key not set');
      return;
    }
    
    const message = {
      lenh: command,
      MessageJson: JSON.stringify(data),
      TimeStamp: Date.now().toString()
    };
    
    const messageRef = ref(database, `${this.rootPath.key}/message`);
    await set(messageRef, message);
  }
  
  // Handle incoming messages from Flutter app
  handleMessage(data) {
    // Prevent duplicate processing
    if (this.lastTimeStamp === data.TimeStamp) return;
    this.lastTimeStamp = data.TimeStamp;
    
    console.log('Received message:', data);
    
    // Process based on command
    switch (data.lenh) {
      case 'cccd_scanned':
        this.handleCCCDScanned(JSON.parse(data.MessageJson));
        break;
      case 'auto_run_changed':
        this.handleAutoRunChange(JSON.parse(data.MessageJson));
        break;
      // Add more cases as needed
    }
  }
  
  // Handle CCCD scanned from Flutter app
  handleCCCDScanned(cccdData) {
    console.log('CCCD Scanned:', cccdData);
    // Process CCCD data in extension
    // e.g., auto-fill forms, save to database, etc.
  }
  
  // Handle auto-run state change
  handleAutoRunChange(isAutoRun) {
    console.log('Auto-run changed:', isAutoRun);
    // Update extension UI or behavior
  }
  
  // Send commands to Flutter app
  async sendCCCDRequest(cccdName) {
    await this.sendMessage('find_cccd', { name: cccdName });
  }
  
  async sendAutoRunCommand(enable) {
    await this.sendMessage('set_auto_run', { enabled: enable });
  }
}

// Usage in Chrome Extension
const firebaseIntegration = new ChromeExtensionFirebase();

// Extension popup or content script can use:
// firebaseIntegration.setKey('user123'); // Must match Flutter app key
// firebaseIntegration.sendCCCDRequest('Nguyen Van A');

// Export for use in other extension files
window.firebaseIntegration = firebaseIntegration;
