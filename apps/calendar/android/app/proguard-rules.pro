# R8 rules for the release build.

# flutter_local_notifications stores scheduled notifications with Gson,
# which reads these classes and their generic types by reflection.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Home-screen widget providers are named in the manifest.
-keep class in.armid.calendar.** { *; }

# Play Core is referenced by Flutter's deferred components, which this app
# doesn't use.
-dontwarn com.google.android.play.core.**
