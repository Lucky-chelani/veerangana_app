# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Google Maps classes
-keep class com.google.android.gms.maps.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }

# Keep model classes (replace with your actual model package)
-keep class com.example.veerangana.models.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep line numbers for crash reports
-keepattributes LineNumberTable
-keepattributes SourceFile
