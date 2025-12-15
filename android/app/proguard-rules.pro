#  ProGuard rules for Stripe Android SDK

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class com.google.android.gms.** { *; }

# Stripe Push Provisioning
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Kotlin parcelize
-dontwarn kotlinx.parcelize.Parceler$DefaultImpls
-dontwarn kotlinx.parcelize.Parceler
-dontwarn kotlinx.parcelize.Parcelize

# Keep Stripe classes
-keep class com.stripe.** { *; }

# Keep Google Pay classes
-keep class com.google.android.gms.wallet.** { *; }
-keep class com.google.android.gms.common.** { *; }