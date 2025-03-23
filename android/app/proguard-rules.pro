# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep models and data classes
-keep class com.eatsafe.app.models.** { *; }

# Keep API service classes
-keep class com.eatsafe.app.api.** { *; }

# Keep third party libraries
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# OkHttp Rules
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Image Picker
-keep class androidx.core.app.CoreComponentFactory { *; }

# Play Core library rules
-keep class com.google.android.play.core.** { *; }

# Keep R8 from stripping away the classes required for deferred components
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep permissions rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception 