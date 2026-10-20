# shared_preferences_android calls its Kotlin suspend functions from Dart
# through JNI (package:jni), which looks up these Kotlin classes and members by
# name. R8 renames or removes them in release builds, so the lookup fails,
# SharedPreferences.getInstance() throws and the app hangs on the splash screen.
# Neither the plugin (2.5.1) nor package:jni (1.1.0) ships rules for this.
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep interface kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
