importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDajmD1rRk4N6hg1MfRvy6d78t5b6s_S7Q",
  authDomain: "we-source-you.firebaseapp.com",
  projectId: "we-source-you",
  storageBucket: "we-source-you.firebasestorage.app",
  messagingSenderId: "477012196994",
  appId: "1:477012196994:web:c239148f8c9b2b4fbb7e9b",
  measurementId: "G-9RT4KSYDLH"
});

const messaging = firebase.messaging();

// الرسائل أثناء التطبيق مغلق (Background)
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/app_icon.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
