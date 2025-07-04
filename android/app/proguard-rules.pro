# Aturan default Flutter.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-dontwarn io.flutter.embedding.**

# Aturan Umum Firebase
-keep class com.google.firebase.** { *; }
-keepnames class com.google.android.gms.tasks.OnFailureListener
-keepnames class com.google.android.gms.tasks.OnSuccessListener

# Aturan khusus untuk Firebase Auth & Google Sign-In
-keep class com.google.android.gms.common.api.internal.TaskApiCall { *; }
-keep class com.google.android.gms.internal.firebase-auth.** { *; }

# Aturan khusus untuk Cloud Firestore
-keep class com.google.firebase.firestore.** { *; }

# Aturan penting untuk local_auth (Biometric/Sidik Jari)
-keep class androidx.biometric.** { *; }
-keep class androidx.core.hardware.fingerprint.** { *; }