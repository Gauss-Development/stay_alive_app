# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**

# Appwrite / Gson reflection
-keepattributes Signature
-keepattributes *Annotation*
-keep class io.appwrite.** { *; }
-keep class com.google.gson.** { *; }
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# home_widget — AppWidgetProvider must be reachable by Android framework
-keep class es.antonborri.home_widget.** { *; }
-keep class * extends android.appwidget.AppWidgetProvider { *; }
-keep class com.gaussdev.stayalive.DailyGoalWidgetProvider { *; }

# OkHttp / Kotlin coroutines used transitively
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn kotlinx.coroutines.**
