// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyD4khHbGTlfsYgtX7sRKzhd2GpBt80BHqc",
  authDomain: "smarterp-1510.firebaseapp.com",
  projectId: "smarterp-1510",
  storageBucket: "smarterp-1510.firebasestorage.app",
  messagingSenderId: "598420514811",
  appId: "1:598420514811:web:968870654fdf2d9c830d5e",
  measurementId: "G-1QN5EB2ST8"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);