# Keep all ONNX Runtime classes & members
-keep class ai.onnxruntime.** { *; }
-keepclassmembers class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**

# Keep Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep HTTP / OkHttp / Networking
-keep class com.squareup.okhttp3.** { *; }
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep Map / Flutter Map packages
-keep class com.maptiler.** { *; }
-keep class org.osmdroid.** { *; }

# Keep Networking & SSL
-keep class javax.net.ssl.** { *; }
-keep interface javax.net.ssl.** { *; }
-keep class java.net.** { *; }
-dontwarn java.net.**