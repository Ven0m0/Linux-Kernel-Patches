#!/usr/bin/env bash

set -e

### Answer unconfigured (NEW) kernel options in the CachyOS config.
scripts/config -d DRM_MGAG200_DISABLE_WRITECOMBINE
scripts/config -d GPIO_BT8XX
scripts/config -d INTEL_TDX_HOST
scripts/config -d SND_SE6X

scripts/config -e LD_DEAD_CODE_DATA_ELIMINATION
scripts/config -d COMPILE_TEST
scripts/config -e POLLY_CLANG

### Disable memory hotplug not needed for desktop use.
scripts/config -d MEMORY_HOTPLUG

scripts/config --set-val LOG_BUF_SHIFT 16

### Decrease the maximum number of GPUs.
scripts/config --set-val VGA_ARB_MAX_GPUS 4

### Set tree-based hierarchical RCU fanout value. (default 64)
scripts/config --set-val RCU_FANOUT 32

### Disable hardware monitors.
scripts/config -d IGB_HWMON
scripts/config -d IXGBE_HWMON
scripts/config -d TIGON3_HWMON
scripts/config -d SCSI_UFS_HWMON
scripts/config -d SENSORS_IIO_HWMON

### Disable more drivers.
scripts/config -d AGP
scripts/config -d ATA_SFF
scripts/config -d ISDN
scripts/config -d NET_FC
scripts/config -d RD_BZIP2
scripts/config -d RD_LZMA
scripts/config -d RD_LZO
scripts/config -d RD_LZ4
scripts/config -d FUSION
scripts/config -d MACINTOSH_DRIVERS
scripts/config -d SCSI_PROC_FS
scripts/config -d SCSI_CONSTANTS
scripts/config -d SCSI_LOWLEVEL

### Disable debug.
scripts/config -d LEDS_TRIGGER_CPU
scripts/config -d LEDS_TRIGGER_GPIO
scripts/config -d USB_PRINTER

# Disable AMD Secure Memory Encryption (SME) support
scripts/config -d AMD_MEM_ENCRYPT

# Disable Intel Software Guard eXtensions (SGX)
scripts/config -d X86_SGX

# Disable direct rendering manager support
scripts/config -d DRM_ACCEL_AMDXDNA
scripts/config -d DRM_AMDGPU
scripts/config -d DRM_APPLETBDRM
scripts/config -d DRM_ARCPGU
scripts/config -d DRM_HISI_HIBMC
scripts/config -d DRM_I915
scripts/config -d DRM_RADEON
scripts/config -d DRM_XE
scripts/config -d DRM_AST
scripts/config -d DRM_MGAG200

# Disable laptop support
scripts/config -d CHROMEOS_LAPTOP
scripts/config -d COMPAL_LAPTOP
scripts/config -d DELL_LAPTOP
scripts/config -d EEEPC_LAPTOP
scripts/config -d FUJITSU_LAPTOP
scripts/config -d IDEAPAD_LAPTOP
scripts/config -d LG_LAPTOP
scripts/config -d MSI_LAPTOP
scripts/config -d PANASONIC_LAPTOP
scripts/config -d SAMSUNG_LAPTOP
scripts/config -d SONY_LAPTOP
scripts/config -d TOPSTAR_LAPTOP

# Disable platform support
scripts/config -d CZNIC_PLATFORMS
scripts/config -d MELLANOX_PLATFORM
scripts/config -d SURFACE_PLATFORMS

# Disable PS/2 keyboard and mouse
scripts/config -d KEYBOARD_ATKBD -d MOUSE_PS2 -d SERIO_I8042
scripts/config -d MOUSE_PS2_BYD
scripts/config -d MOUSE_PS2_SENTELIC
scripts/config -d MOUSE_PS2_TOUCHKIT

# Disable touchscreen input devices
scripts/config -d INPUT_TOUCHSCREEN
scripts/config -d TOUCHSCREEN_CY8CTMA140
scripts/config -d TOUCHSCREEN_ILITEK
scripts/config -d TOUCHSCREEN_MSG2638
scripts/config -d TOUCHSCREEN_TSC2007_IIO
scripts/config -d TOUCHSCREEN_ZINITIX
scripts/config -d INPUT_TABLET


# Disable Controller Area Network (CAN) bus subsystem support
scripts/config -d CAN

# Disable InfiniBand support
scripts/config -d INFINIBAND

# Disable ServerEngines' 10Gbps NIC - BladeEngine ethernet support
scripts/config -d BE2NET

# Disable Mellanox Technologies ethernet support
scripts/config -d MLX4_EN
scripts/config -d MLX5_CORE
scripts/config -d MLXSW_CORE
scripts/config -d MLXFW

# Disable Sonics Silicon Backplane support
scripts/config -d SSB

# Disable GSPCA based webcams
scripts/config -d USB_GSPCA

# Disable network drivers
scripts/config -d NET_VENDOR_ADI
scripts/config -d NET_VENDOR_AGERE
scripts/config -d NET_VENDOR_AMAZON
scripts/config -d NET_VENDOR_AMD
scripts/config -d NET_VENDOR_AQUANTIA
scripts/config -d NET_VENDOR_ASIX
scripts/config -d NET_VENDOR_ATHEROS
scripts/config -d NET_VENDOR_BROADCOM
scripts/config -d NET_VENDOR_CADENCE
scripts/config -d NET_VENDOR_CHELSIO
scripts/config -d NET_VENDOR_CISCO
scripts/config -d NET_VENDOR_CORTINA
scripts/config -d NET_VENDOR_DAVICOM
scripts/config -d NET_VENDOR_DLINK
scripts/config -d NET_VENDOR_EMULEX
scripts/config -d NET_VENDOR_ENGLEDER
scripts/config -d NET_VENDOR_FUNGIBLE
scripts/config -d NET_VENDOR_GOOGLE
scripts/config -d NET_VENDOR_HISILICON
scripts/config -d NET_VENDOR_HUAWEI
scripts/config -d NET_VENDOR_I825XX
scripts/config -d NET_VENDOR_INTEL
scripts/config -d NET_VENDOR_LITEX
scripts/config -d NET_VENDOR_MARVELL
scripts/config -d NET_VENDOR_MELLANOX
scripts/config -d NET_VENDOR_META
scripts/config -d NET_VENDOR_MICROSOFT
scripts/config -d NET_VENDOR_NETRONOME
scripts/config -d NET_VENDOR_NI
scripts/config -d NET_VENDOR_PACKET_ENGINES
scripts/config -d NET_VENDOR_QLOGIC
scripts/config -d NET_VENDOR_SOCIONEXT
scripts/config -d NET_VENDOR_SOLARFLARE
scripts/config -d NET_VENDOR_STMICRO
scripts/config -d NET_VENDOR_VERTEXCOM
scripts/config -d NET_VENDOR_WANGXUN

# Disable Wan interfaces support
scripts/config -d WAN

# Disable IPv6 over Low power Wireless Personal Area Network
scripts/config -d 6LOWPAN -d IEEE802154

# Disable wireless LAN drivers
scripts/config -d WLAN

# Disable wireless vendor support
# https://github.com/torvalds/linux/blob/master/drivers/net/wireless/
scripts/config -d WLAN_VENDOR_ADMTEK
scripts/config -d WLAN_VENDOR_ATH
scripts/config -d WLAN_VENDOR_ATMEL
scripts/config -d WLAN_VENDOR_BROADCOM
scripts/config -d WLAN_VENDOR_INTEL
scripts/config -d WLAN_VENDOR_INTERSIL
scripts/config -d WLAN_VENDOR_MARVELL
scripts/config -d WLAN_VENDOR_MEDIATEK
scripts/config -d WLAN_VENDOR_PURELIFI
scripts/config -d WLAN_VENDOR_QUANTENNA
scripts/config -d WLAN_VENDOR_RALINK
scripts/config -d WLAN_VENDOR_REALTEK
scripts/config -d WLAN_VENDOR_RSI
scripts/config -d WLAN_VENDOR_SILABS
scripts/config -d WLAN_VENDOR_ST
scripts/config -d WLAN_VENDOR_TI
scripts/config -d WLAN_VENDOR_ZYDAS

# Disable misc sound devices
scripts/config -d SND_HDA_SCODEC_TAS2781_SPI
scripts/config -d SND_I2S_HI6210_I2S
scripts/config -d SND_SOC_CHV3_I2S
scripts/config -d SND_SOC_INTEL_CATPT
scripts/config -d SND_AD1889
scripts/config -d SND_ALI5451
scripts/config -d SND_ALS300
scripts/config -d SND_ALS4000
scripts/config -d SND_ASIHPI
scripts/config -d SND_ATIIXP
scripts/config -d SND_ATIIXP_MODEM
scripts/config -d SND_EMU10K1
scripts/config -d SND_EMU10K1X
scripts/config -d SND_TRIDENT
scripts/config -d SND_VIA82XX
scripts/config -d SND_VIA82XX_MODEM
scripts/config -d SND_VIRTUOSO

### Apply various Clear Linux defaults
scripts/config -d IOMMU_DEFAULT_DMA_LAZY -e IOMMU_DEFAULT_PASSTHROUGH

### Disable HWPoison pages injector.
scripts/config -d HWPOISON_INJECT

### Disable paravirtual steal time accounting.
scripts/config -d PARAVIRT_TIME_ACCOUNTING

### Disable pvpanic device support.
scripts/config -d PVPANIC

### Disable Integrity Policy Enforcement (IPE).
scripts/config -d SECURITY_IPE

### Disable PCI Express ASPM L0s and L1, even if the BIOS enabled them.
scripts/config -d PCIEASPM_DEFAULT -e PCIEASPM_PERFORMANCE

### Disable workqueue power-efficient mode by default.
scripts/config -d WQ_POWER_EFFICIENT_DEFAULT

### Disable Split Lock Detect and Bus Lock Detect support.
scripts/config -d X86_BUS_LOCK_DETECT

### Disable strong stack protector.
scripts/config -d STACKPROTECTOR_STRONG -e STACKPROTECTOR

### Default to none for vsyscall table for legacy applications.
scripts/config -d LEGACY_VSYSCALL_XONLY -e LEGACY_VSYSCALL_NONE

### Disable LDT (local descriptor table) to run 16-bit or segmented code such as
### DOSEMU or some Wine programs. Enabling this adds a small amount of overhead
### to context switches and increases the low-level kernel attack surface.
scripts/config -d UID16 -d X86_16BIT -d MODIFY_LDT_SYSCALL

### Disable obsolete sysfs syscall support.
scripts/config -d SYSFS_SYSCALL

### Disable Kexec and crash features.
scripts/config -d KEXEC -d KEXEC_FILE -d CRASH_DUMP

### Disable low-overhead sampling-based memory safety error detector.
scripts/config -d KFENCE

### Disable automatic stack variable initialization. (Clear and XanMod default)
scripts/config -d INIT_STACK_ALL_ZERO -e INIT_STACK_NONE

# Partition Types
scripts/config -d MAC_PARTITION
scripts/config -d KARMA_PARTITION

# Near Field Communication (NFC) devices
scripts/config -d NFC_FDP
scripts/config -d NFC_MRVL_I2C
scripts/config -d NFC_ST_NCI_I2C
scripts/config -d NFC_ST_NCI_SPI
scripts/config -d NFC_S3FWRN5_I2C
scripts/config -d NFC_S3FWRN82_UART
scripts/config -d NFC_ST95HF

# NVME Support
scripts/config -d NVME_VERBOSE_ERRORS
scripts/config -d NVME_TARGET_DEBUGFS
scripts/config -d PNP_DEBUG_MESSAGES

# Texas Instruments shared transport line discipline
scripts/config -d TI_ST
scripts/config -d GENWQE
scripts/config -d BCM_VK_TTY
scripts/config -d KEBA_CP500

# Analog TV USB devices
scripts/config -d VIDEO_GO7007_USB_S2250_BOARD

# Analog/digital TV USB devices
scripts/config -d VIDEO_AU0828_RC

# Digital TV USB devices
scripts/config -d DVB_USB_LME2510
scripts/config -d DVB_USB

# Software defined radio USB devices
# Added USB_AIRSPY and USB_HACKRF not found in the CachyOS config
scripts/config -d USB_AIRSPY
scripts/config -d USB_HACKRF
scripts/config -d USB_MSI2500

# Media capture support
scripts/config -d VIDEO_ZORAN_DC30
scripts/config -d VIDEO_ZORAN_BUZ

# Media capture/analog TV support
scripts/config -d VIDEO_FB_IVTV_FORCE_PAT

# Media capture/analog/hybrid TV support
scripts/config -d VIDEO_COBALT

# Media digital TV PCI Adapters
scripts/config -d DVB_NETUP_UNIDVB
scripts/config -d RADIO_TEF6862
scripts/config -d USB_RAREMONO
scripts/config -d USB_SI4713
scripts/config -d PLATFORM_SI4713
scripts/config -d I2C_SI4713
scripts/config -d SDR_PLATFORM_DRIVERS
scripts/config -d DVB_PLATFORM_DRIVERS
scripts/config -d V4L_MEM2MEM_DRIVERS

# Cadence media platform drivers
scripts/config -d VIDEO_CADENCE_CSI2RX
scripts/config -d VIDEO_CADENCE_CSI2TX

# Marvell media platform drivers
scripts/config -d VIDEO_CAFE_CCIC

# MMC/SDIO DVB adapters
scripts/config -d SMS_SDIO_DRV
scripts/config -d V4L_TEST_DRIVERS
scripts/config -d DVB_TEST_DRIVERS

# Lens drivers
scripts/config -d VIDEO_AD5820
scripts/config -d VIDEO_AK7375
scripts/config -d VIDEO_DW9714
scripts/config -d VIDEO_DW9719
scripts/config -d VIDEO_DW9768
scripts/config -d VIDEO_DW9807_VCM

# Customize TV tuners
scripts/config -d MEDIA_TUNER_MSI001
scripts/config -d MEDIA_TUNER_TDA18250


# drm debugging
scripts/config -d DRM_I915_WERROR
scripts/config -d DRM_I915_REPLAY_GPU_HANGS_API
scripts/config -d DRM_I915_DEBUG
scripts/config -d DRM_I915_DEBUG_MMIO
scripts/config -d DRM_I915_SW_FENCE_DEBUG_OBJECTS
scripts/config -d DRM_I915_SW_FENCE_CHECK_DAG
scripts/config -d DRM_I915_DEBUG_GUC
scripts/config -d DRM_I915_SELFTEST
scripts/config -d DRM_I915_DEBUG_VBLANK_EVADE
scripts/config -d DRM_I915_DEBUG_WAKEREF
scripts/config -d DRM_XE_WERROR
scripts/config -d DRM_XE_DEBUG
scripts/config -d DRM_XE_DEBUG_VM
scripts/config -d DRM_XE_DEBUG_SRIOV
scripts/config -d DRM_XE_DEBUG_MEM
scripts/config -d DRM_XE_USERPTR_INVAL_INJECT
scripts/config -d DRM_VKMS
scripts/config -d DRM_GMA500

# USB Type-C Multiplexer/DeMultiplexer Switch support
scripts/config -d TYPEC_MUX_WCD939X_USBSS
scripts/config -d MMC_TEST

# Accelerometers
scripts/config -d ADIS16203
scripts/config -d ADIS16240
scripts/config -d ADIS16201
scripts/config -d ADIS16209
scripts/config -d ADXL345_I2C
scripts/config -d ADXL345_SPI
scripts/config -d BMA180
scripts/config -d BMA220
scripts/config -d BMA400
scripts/config -d BMI088_ACCEL
scripts/config -d DMARD09
scripts/config -d FXLS8962AF_I2C
scripts/config -d FXLS8962AF_SPI
scripts/config -d KXSD9
scripts/config -d MC3230
scripts/config -d MMA7455_I2C
scripts/config -d MMA7455_SPI
scripts/config -d MMA8452
scripts/config -d MMA9551
scripts/config -d MMA9553
scripts/config -d MXC4005
scripts/config -d MXC6255
scripts/config -d SCA3000
scripts/config -d SCA3300
scripts/config -d STK8312
scripts/config -d STK8BA50

# Analog to digital converters
scripts/config -d AD7816

# Analog digital bi-direction converters
scripts/config -d ADT7316

# Direct Digital Synthesis
scripts/config -d AD9832
scripts/config -d AD9834

# Qualcomm SoC drivers
scripts/config -d QCOM_PMIC_PDCHARGER_ULOG
scripts/config -d SOC_TI

# Chemical Sensors
scripts/config -d AOSONG_AGS02MA
scripts/config -d ATLAS_PH_SENSOR
scripts/config -d ATLAS_EZO_SENSOR
scripts/config -d BME680
scripts/config -d CCS811
scripts/config -d IAQCORE
scripts/config -d PMS7003
scripts/config -d SCD30_CORE
scripts/config -d SENSIRION_SGP30
scripts/config -d SPS30_I2C
scripts/config -d SPS30_SERIAL
scripts/config -d VZ89X

# Digital gyroscope sensors
scripts/config -d ADIS16080
scripts/config -d ADIS16130
scripts/config -d ADIS16136
scripts/config -d ADIS16260
scripts/config -d ADXRS290
scripts/config -d ADXRS450
scripts/config -d BMG160
scripts/config -d FXAS21002C
scripts/config -d ITG3200

# Heart Rate Monitors
scripts/config -d AFE4403
scripts/config -d AFE4404
scripts/config -d MAX30102

# Humidity sensors
scripts/config -d AM2315
scripts/config -d HDC100X
scripts/config -d HDC2010
scripts/config -d HDC3020
scripts/config -d HTU21
scripts/config -d SI7005
scripts/config -d SI7020

# Light sensors
scripts/config -d ADJD_S311
scripts/config -d ADUX1020
scripts/config -d AL3010
scripts/config -d AL3320A
scripts/config -d APDS9300
scripts/config -d APDS9960
scripts/config -d AS73211
scripts/config -d BH1780
scripts/config -d CM3232
scripts/config -d CM3323
scripts/config -d CM36651
scripts/config -d GP2AP020A00F
scripts/config -d SENSORS_ISL29018
scripts/config -d ISL29125
scripts/config -d JSA1212
scripts/config -d ROHM_BU27008
scripts/config -d LTR501
scripts/config -d MAX44000
scripts/config -d MAX44009
scripts/config -d NOA1305
scripts/config -d SI1133
scripts/config -d SI1145
scripts/config -d TCS3414
scripts/config -d TCS3472
scripts/config -d SENSORS_TSL2563
scripts/config -d TSL2583
scripts/config -d TSL2591
scripts/config -d TSL4531
scripts/config -d US5182D
scripts/config -d VCNL4000
scripts/config -d VCNL4035
scripts/config -d VEML6030
scripts/config -d VEML6070

# Magnetometer sensors
scripts/config -d BMC150_MAGN_I2C
scripts/config -d BMC150_MAGN_SPI
scripts/config -d MAG3110
scripts/config -d MMC35240
scripts/config -d SENSORS_HMC5843_I2C
scripts/config -d SENSORS_HMC5843_SPI
scripts/config -d SENSORS_RM3100_I2C
scripts/config -d SENSORS_RM3100_SPI
scripts/config -d YAMAHA_YAS530

# Pressure sensors
scripts/config -d DLHL60D
scripts/config -d DPS310
scripts/config -d HP03
scripts/config -d HSC030PA
scripts/config -d ICP10100
scripts/config -d MPL115_I2C
scripts/config -d MPL115_SPI
scripts/config -d MPL3115
scripts/config -d MPRLS0025PA
scripts/config -d MS5611
scripts/config -d MS5637
scripts/config -d IIO_ST_PRESS
scripts/config -d T5403
scripts/config -d HP206C
scripts/config -d ZPA2326

# Lightning sensors
scripts/config -d AS3935

# Proximity and distance sensors
scripts/config -d IRSD200
scripts/config -d ISL29501
scripts/config -d LIDAR_LITE_V2
scripts/config -d MB1232
scripts/config -d PING
scripts/config -d RFD77402
scripts/config -d SX9310
scripts/config -d SX9500
scripts/config -d SRF08
scripts/config -d VCNL3020

# File systems
scripts/config -d REISERFS_FS
scripts/config -d JFS_FS
scripts/config -d ORANGEFS_FS
scripts/config -d CIFS_DEBUG
scripts/config -d DLM_DEBUG

# Cachy
scripts/config -d SLUB_DEBUG
scripts/config -d PM_DEBUG
scripts/config -d PM_ADVANCED_DEBUG
scripts/config -d PM_SLEEP_DEBUG
scripts/config -d ACPI_DEBUG
scripts/config -d LATENCYTOP
scripts/config -d SCHED_DEBUG
scripts/config -d DEBUG_PREEMPT
scripts/config -e USER_NS
scripts/config --disable CRASH_DUMP
