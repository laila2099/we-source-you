// importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
// importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// firebase.initializeApp({
//   apiKey: "AIzaSyDajmD1rRk4N6hg1MfRvy6d78t5b6s_S7Q",
//   authDomain: "we-source-you.firebaseapp.com",
//   projectId: "we-source-you",
//   storageBucket: "we-source-you.firebasestorage.app",
//   messagingSenderId: "477012196994",
//   appId: "1:477012196994:web:c239148f8c9b2b4fbb7e9b",
//   measurementId: "G-9RT4KSYDLH"
// });

// const messaging = firebase.messaging();

// // الرسائل أثناء التطبيق مغلق (Background)
// messaging.onBackgroundMessage(function(payload) {
//   console.log('[firebase-messaging-sw.js] Received background message ', payload);

//   const notificationTitle = payload.notification.title;
//   const notificationOptions = {
//     body: payload.notification.body,
//     icon: '/icons/app_icon.png'
//   };

//   self.registration.showNotification(notificationTitle, notificationOptions);
// });
// استيراد المكتبات بنظام Compat (الأكثر استقراراً داخل الـ Service Worker في الويب)
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// نفس الإعدادات الموجودة في index.html
const firebaseConfig = {
  apiKey: "AIzaSyDajmD1rRk4N6hg1MfRvy6d78t5b6s_S7Q",
  authDomain: "we-source-you.firebaseapp.com",
  projectId: "we-source-you",
  storageBucket: "we-source-you.firebasestorage.app",
  messagingSenderId: "477012196994", // تأكد أن هذا الرقم صحيح
  appId: "1:477012196994:web:c239148f8c9b2b4fbb7e9b",
  measurementId: "G-9RT4KSYDLH"
};

// تهيئة Firebase
firebase.initializeApp(firebaseConfig);

// تعريف Messaging
const messaging = firebase.messaging();

// معالجة الرسائل في الخلفية (عندما يكون المتصفح مغلقاً أو التاب غير نشط)
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/app_icon.png', // تأكد أن هذا الملف موجود في مجلد web/icons/
    badge: '/icons/app_icon.png',
    data: {
        click_action: payload.data?.click_action || '/' 
    }
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// إضافة مستمع لحدث النقر على الإشعار
self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    clients.openWindow(event.notification.data.click_action)
  );
});