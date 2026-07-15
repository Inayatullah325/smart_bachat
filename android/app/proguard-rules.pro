# Syncfusion charts – keep all classes since they use reflection internally
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**

# Flutter local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# SQLite – sqflite plugin
-keep class io.flutter.plugins.sqflite.** { *; }
-dontwarn io.flutter.plugins.sqflite.**

# Timezone / flutter_timezone
-keep class com.pinkfish.flutter.flutter_timezone.** { *; }
-dontwarn com.pinkfish.flutter.flutter_timezone.**

# Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Flutter engine – keep entry points used for reflection
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep all native method signatures
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep serializable classes intact
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

