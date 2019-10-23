# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from Z5151 device
$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_BRAND := zte
PRODUCT_DEVICE := Z5151
PRODUCT_MANUFACTURER := zte
PRODUCT_NAME := lineage_Z5151
PRODUCT_MODEL := Z5151V

PRODUCT_GMS_CLIENTID_BASE := android-zte
TARGET_VENDOR := zte
TARGET_VENDOR_PRODUCT_NAME := Z5151
PRODUCT_BUILD_PROP_OVERRIDES += PRIVATE_BUILD_DESC="Z5151V-user 8.1.0 OPM1.171019.026 322 release-keys"

# Set BUILD_FINGERPRINT variable to be picked up by both system and vendor build.prop
BUILD_FINGERPRINT := ZTE/VSBL_Z5151V/Z5151:8.1.0/OPM1.171019.026/20190514.155559:user/release-keys
