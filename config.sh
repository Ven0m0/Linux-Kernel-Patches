#!/usr/bin/env bash
# Set extra kernel options.

### Exit immediately on error.
set -e

cd "$1" || { echo "Directory not found: $1"; exit 1; }

### Answer unconfigured (NEW) kernel options in the CachyOS config.
scripts/config -d DRM_MGAG200_DISABLE_WRITECOMBINE
scripts/config -d GPIO_BT8XX
scripts/config -d INTEL_TDX_HOST
scripts/config -d SND_SE6X

### Disable memory hotplug not needed for desktop use.
scripts/config -d MEMORY_HOTPLUG

### Set the minimal base_slice_ns option for BORE.
### 1000Hz = 2.0ms, 800Hz = 2.5ms, 600Hz = 1.6(6)ms, 500Hz = 2.0ms.
#scripts/config --set-val MIN_BASE_SLICE_NS 1600000

### Decrease the kernel log buffer size (default 17).
scripts/config --set-val LOG_BUF_SHIFT 16

### Decrease the maximum number of vCPUs per KVM guest.
scripts/config --set-val KVM_MAX_NR_VCPUS 128

### Decrease the maximum number of GPUs.
scripts/config --set-val VGA_ARB_MAX_GPUS 4

### Enable ACPI options. (default -m)
scripts/config -e ACPI_TAD -e ACPI_VIDEO -e ACPI_WMI -e INPUT_SPARSEKMAP

### Enable input modules. (default -m)
#scripts/config -e SERIO -e SERIO_I8042 -e SERIO_LIBPS2 -e UHID -e USB_HID
scripts/config -d HID_APPLE
scripts/config -e HID_BELKIN -e HID_CHERRY -e HID_CHICONY
#scripts/config -e HID_GENERIC -e HID_HOLTEK -e HID_KENSINGTON -e HID_LENOVO
#scripts/config -e HID_LOGITECH -e HID_LOGITECH_DJ -e HID_LOGITECH_HIDPP
#scripts/config -e HID_MICROSOFT -e HID_SAMSUNG -d HID_VIVALDI
#scripts/config -e SERIO_GPIO_PS2 -e SERIO_SERPORT

### Enable storage modules. (default -m)
scripts/config -e NVME_KEYRING -e NVME_AUTH -e NVME_CORE
scripts/config -e BLK_DEV_DM -e BLK_DEV_LOOP -e BLK_DEV_NVME
scripts/config -e BLK_DEV_MD -d MD_AUTODETECT -d DM_INIT
scripts/config -e USB_XHCI_PCI -e USB_XHCI_PCI_RENESAS -e USB_XHCI_PLATFORM
scripts/config -e USB_STORAGE -e USB_STORAGE_REALTEK -e USB_UAS

### Enable file systems. (default -m)
scripts/config -d MSDOS_FS -e FAT_FS -e VFAT_FS
scripts/config -e EXT4_FS -e FS_MBCACHE
#scripts/config -e JBD2
#scripts/config -e BTRFS_FS
scripts/config -e F2FS_FS -e XFS_FS

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

### Disable tracers.
scripts/config -d ATH5K_TRACER
scripts/config -d DM_UEVENT
scripts/config -d FUNCTION_PROFILER
scripts/config -d FTRACE_RECORD_RECURSION
scripts/config -d FTRACE_SORT_STARTUP_TEST
scripts/config -d FTRACE_VALIDATE_RCU_IS_WATCHING
scripts/config -d HWLAT_TRACER
scripts/config -d IRQSOFF_TRACER
scripts/config -d KPROBE_EVENTS_ON_NOTRACE
scripts/config -d LOCK_EVENT_COUNTS
scripts/config -d MMIOTRACE
scripts/config -d MMIOTRACE_TEST
scripts/config -d OSNOISE_TRACER
scripts/config -d PM_DEVFREQ_EVENT
scripts/config -d PREEMPT_TRACER
scripts/config -d PSTORE_FTRACE
scripts/config -d TIMERLAT_TRACER
scripts/config -d SYNTH_EVENTS
scripts/config -d USER_EVENTS
scripts/config -d HIST_TRIGGERS

### Disable debug.
scripts/config -d SLUB_DEBUG
scripts/config -d SLUB_DEBUG_ON
scripts/config -d PAGE_POISONING
scripts/config -d GDB_SCRIPTS
scripts/config -d ACPI_DEBUG
scripts/config -d PM_DEBUG
scripts/config -d PM_ADVANCED_DEBUG
scripts/config -d PM_SLEEP_DEBUG
scripts/config -d PM_TRACE_RTC
scripts/config -d LATENCYTOP
scripts/config -d LEDS_TRIGGER_CPU
scripts/config -d LEDS_TRIGGER_GPIO
scripts/config -d PCIEAER_INJECT
scripts/config -d PCIE_ECRC
scripts/config -d GENERIC_IRQ_DEBUGFS
scripts/config -d GENERIC_IRQ_INJECTION
scripts/config -d FUNCTION_ERROR_INJECTION
scripts/config -d PRINTK_INDEX
scripts/config -d SOFTLOCKUP_DETECTOR_INTR_STORM
scripts/config -d GENERIC_IRQ_STAT_SNAPSHOT
scripts/config -d 6LOWPAN_DEBUGFS
scripts/config -d AF_RXRPC_DEBUG
scripts/config -d AFS_DEBUG
scripts/config -d AFS_DEBUG_CURSOR
scripts/config -d ATA_VERBOSE_ERROR
scripts/config -d ATH10K_DEBUG
scripts/config -d ATH10K_DEBUGFS
scripts/config -d ATH12K_DEBUG
scripts/config -d ATH5K_DEBUG
scripts/config -d ATH6KL_DEBUG
scripts/config -d ATH9K_HTC_DEBUGFS
scripts/config -d ATM_ENI_DEBUG
scripts/config -d ATM_IA_DEBUG
scripts/config -d ATM_IDT77252_DEBUG
scripts/config -d BCACHE_DEBUG
scripts/config -d BCACHEFS_DEBUG
scripts/config -d BEFS_DEBUG
scripts/config -d BLK_DEBUG_FS
scripts/config -d BT_DEBUGFS
scripts/config -d CEPH_LIB_PRETTYDEBUG
scripts/config -d CFG80211_DEBUGFS
scripts/config -d CIFS_DEBUG
scripts/config -d CIFS_DEBUG2
scripts/config -d CIFS_DEBUG_DUMP_KEYS
scripts/config -d CMA_DEBUGFS
scripts/config -d CROS_EC_DEBUGFS
scripts/config -d CRYPTO_DEV_AMLOGIC_GXL_DEBUG
scripts/config -d CRYPTO_DEV_CCP_DEBUGFS
scripts/config -d DEBUG_KMAP_LOCAL_FORCE_MAP
scripts/config -d DEBUG_MEMORY_INIT
scripts/config -d DEBUG_RODATA_TEST
scripts/config -d DEBUG_RSEQ
scripts/config -d DEBUG_WX
scripts/config -d DLM_DEBUG
scripts/config -d DM_DEBUG_BLOCK_MANAGER_LOCKING
scripts/config -d DM_DEBUG_BLOCK_STACK_TRACING
scripts/config -d DRM_ACCEL_IVPU_DEBUG
scripts/config -d DRM_DEBUG_DP_MST_TOPOLOGY_REFS
scripts/config -d DRM_DEBUG_MODESET_LOCK
scripts/config -d DRM_DISPLAY_DP_TUNNEL_STATE_DEBUG
scripts/config -d DRM_I915_DEBUG
scripts/config -d DRM_I915_DEBUG_GUC
scripts/config -d DRM_I915_DEBUG_MMIO
scripts/config -d DRM_I915_DEBUG_VBLANK_EVADE
scripts/config -d DRM_I915_DEBUG_WAKEREF
scripts/config -d DRM_I915_SW_FENCE_DEBUG_OBJECTS
scripts/config -d DRM_XE_DEBUG
scripts/config -d DRM_XE_DEBUG_MEM
scripts/config -d DRM_XE_DEBUG_MEMIRQ
scripts/config -d DRM_XE_DEBUG_SRIOV
scripts/config -d DRM_XE_DEBUG_VM
scripts/config -d DVB_USB_DEBUG
scripts/config -d EARLY_PRINTK_DBGP
scripts/config -d EARLY_PRINTK_USB_XDBC
scripts/config -d EXT4_DEBUG
scripts/config -d HIST_TRIGGERS_DEBUG
scripts/config -d INFINIBAND_MTHCA_DEBUG
scripts/config -d IWLEGACY_DEBUG
scripts/config -d IWLWIFI_DEBUG
scripts/config -d JFS_DEBUG
scripts/config -d LDM_DEBUG
scripts/config -d LIBERTAS_THINFIRM_DEBUG
scripts/config -d NETFS_DEBUG
scripts/config -d NFS_DEBUG
scripts/config -d NVME_TARGET_DEBUGFS
scripts/config -d NVME_VERBOSE_ERRORS
scripts/config -d OCFS2_DEBUG_FS
scripts/config -d PNP_DEBUG_MESSAGES
scripts/config -d QUOTA_DEBUG
scripts/config -d RTLWIFI_DEBUG
scripts/config -d RTW88_DEBUG
scripts/config -d RTW88_DEBUGFS
scripts/config -d RTW89_DEBUGFS
scripts/config -d RTW89_DEBUGMSG
scripts/config -d SHRINKER_DEBUG
scripts/config -d SMS_SIANO_DEBUGFS
scripts/config -d SND_SOC_SOF_DEBUG
scripts/config -d SUNRPC_DEBUG
scripts/config -d UFS_DEBUG
scripts/config -d USB_DWC2_DEBUG
scripts/config -d VFIO_DEBUGFS
scripts/config -d VIRTIO_DEBUG
scripts/config -d VISL_DEBUGFS
scripts/config -d WCN36XX_DEBUGFS
scripts/config -d WWAN_DEBUGFS
scripts/config -d XEN_DEBUG_FS

# Data Access Monitoring
scripts/config -d DAMON

# Networking options
scripts/config -d IP_FIB_TRIE_STATS
scripts/config -d IP_ROUTE_VERBOSE
scripts/config -d NET_IPGRE_BROADCAST
scripts/config -d INET_DIAG

# Classification
scripts/config -d BATMAN_ADV_NC
scripts/config -d BATMAN_ADV_MCAST

# Network testing
scripts/config -d HAMRADIO
scripts/config -d CAN_ISOTP
scripts/config -d BT_LEDS
scripts/config -d BT_AOSPEXT
scripts/config -d BT_DEBUGFS

# Bluetooth device drivers
scripts/config -d BT_HCIUART_BCSP
scripts/config -d BT_HCIUART_ATH3K
scripts/config -d BT_HCIUART_LL
scripts/config -d BT_HCIUART_3WIRE
scripts/config -d BT_HCIUART_RTL
scripts/config -d BT_HCIUART_QCA
scripts/config -d BT_HCIUART_AG6XX
scripts/config -d BT_HCIUART_MRVL
scripts/config -d BT_MTKUART
scripts/config -d BT_NXPUART
scripts/config -d AF_RXRPC_IPV6
scripts/config -d AF_RXRPC_DEBUG
scripts/config -d RXKAD
scripts/config -d MCTP
scripts/config -d CFG80211_CERTIFICATION_ONUS
scripts/config -d MAC80211_MESH
scripts/config -d CEPH_LIB_PRETTYDEBUG
scripts/config -d CEPH_LIB_USE_DNS_RESOLVER
scripts/config -d NFC_NCI_SPI
scripts/config -d NFC_NCI_UART
scripts/config -d NFC_SHDLC

# Near Field Communication (NFC) devices
scripts/config -d NFC_FDP
scripts/config -d NFC_MRVL_I2C
scripts/config -d NFC_ST_NCI_I2C
scripts/config -d NFC_ST_NCI_SPI
scripts/config -d NFC_S3FWRN5_I2C
scripts/config -d NFC_S3FWRN82_UART
scripts/config -d NFC_ST95HF

# Device Drivers
scripts/config -d PCIEAER_INJECT
scripts/config -d PCIE_ECRC
scripts/config -d PCIE_DPC
scripts/config -d PCI_P2PDMA
scripts/config -d HOTPLUG_PCI_CPCI
scripts/config -d PCCARD

# RAM/ROM/Flash chip drivers
scripts/config -d MTD_CFI_BE_BYTE_SWAP
scripts/config -d MTD_CFI_LE_BYTE_SWAP
scripts/config -d MTD_OTP
scripts/config -d MTD_CFI_AMDSTD
scripts/config -d MTD_CFI_STAA
scripts/config -d MTD_ROM
scripts/config -d MTD_SBC_GXX
scripts/config -d MTD_PCI
scripts/config -d MTD_PHRAM
scripts/config -d MTD_MTDRAM
scripts/config -d MTD_NAND_NANDSIM
scripts/config -d MTD_NAND_ECC_SW_HAMMING_SMC
scripts/config -d MTD_NAND_ECC_SW_BCH
scripts/config -d MTD_NAND_ECC_MXIC
scripts/config -d MTD_UBI_NVMEM
scripts/config -d PNP_DEBUG_MESSAGES

# NVME Support
scripts/config -d NVME_VERBOSE_ERRORS
scripts/config -d NVME_TARGET_DEBUGFS

# Misc devices
scripts/config -d AD525X_DPOT
scripts/config -d PHANTOM
scripts/config -d ICS932S401
scripts/config -d HMC6352
scripts/config -d DS1682
scripts/config -d LATTICE_ECP3_CONFIG
scripts/config -d PCI_ENDPOINT_TEST
scripts/config -d XILINX_SDFEC
scripts/config -d TPS6594_ESM
scripts/config -d C2PORT

# Texas Instruments shared transport line discipline
scripts/config -d TI_ST
scripts/config -d GENWQE
scripts/config -d BCM_VK_TTY
scripts/config -d PVPANIC
scripts/config -d KEBA_CP500

# SCSI device support
scripts/config -d SCSI_PROC_FS
scripts/config -d SCSI_AIC94XX
scripts/config -d SCSI_MVSAS_TASKLET
scripts/config -d MEGARAID_NEWGEN
scripts/config -d SCSI_FLASHPOINT
scripts/config -d SCSI_PPA
scripts/config -d SCSI_IMM
scripts/config -d QEDI
scripts/config -d QEDF
scripts/config -d SCSI_EFCT
scripts/config -d SCSI_DH
scripts/config -d ATA_VERBOSE_ERROR
scripts/config -d SATA_ZPODD

# SATA SFF controllers with BMDMA
scripts/config -d SATA_DWC

# PATA SFF controllers with BMDMA
scripts/config -d PATA_ALI
scripts/config -d PATA_AMD
scripts/config -d PATA_ARTOP
scripts/config -d PATA_ATIIXP
scripts/config -d PATA_ATP867X
scripts/config -d PATA_CMD64X
scripts/config -d PATA_CYPRESS
scripts/config -d PATA_EFAR
scripts/config -d PATA_HPT366
scripts/config -d PATA_HPT37X
scripts/config -d PATA_HPT3X2N
scripts/config -d PATA_HPT3X3
scripts/config -d PATA_IT8213
scripts/config -d PATA_IT821X
scripts/config -d PATA_MARVELL
scripts/config -d PATA_NETCELL
scripts/config -d PATA_NINJA32
scripts/config -d PATA_NS87415
scripts/config -d PATA_OLDPIIX
scripts/config -d PATA_OPTIDMA
scripts/config -d PATA_PDC2027X
scripts/config -d PATA_PDC_OLD
scripts/config -d PATA_RADISYS
scripts/config -d PATA_RDC
scripts/config -d PATA_SERVERWORKS
scripts/config -d PATA_SIL680
scripts/config -d PATA_TOSHIBA
scripts/config -d PATA_TRIFLEX
scripts/config -d PATA_VIA
scripts/config -d PATA_WINBOND

# PIO-only SFF controllers
scripts/config -d PATA_CMD640_PCI
scripts/config -d PATA_NS87410
scripts/config -d PATA_OPTI
scripts/config -d PATA_RZ1000
scripts/config -d PATA_PARPORT

# IEEE 1394 (FireWire) support
scripts/config -d FIREWIRE
scripts/config -d FIREWIRE_NOSY
scripts/config -d MACINTOSH_DRIVERS
scripts/config -d NET_FC
scripts/config -d MHI_NET

# MII PHY device drivers
scripts/config -d ADIN_PHY
scripts/config -d MARVELL_88X2222_PHY
scripts/config -d MICROCHIP_T1_PHY
scripts/config -d NXP_C45_TJA11XX_PHY
scripts/config -d NXP_TJA11XX_PHY
scripts/config -d DP83TC811_PHY
scripts/config -d DP83867_PHY
scripts/config -d DP83869_PHY
scripts/config -d DP83TD510_PHY
scripts/config -d MICREL_KS8995MA
scripts/config -d CAN_NETLINK
scripts/config -d MDIO_GPIO
scripts/config -d MDIO_MVUSB
scripts/config -d MDIO_MSCC_MIIM
scripts/config -d MDIO_THUNDER
scripts/config -d PPP_FILTER
scripts/config -d PPP_MULTILINK
scripts/config -d SLIP_COMPRESSED
scripts/config -d SLIP_SMART
scripts/config -d SLIP_MODE_SLIP6
scripts/config -d USB_NET_SR9800
scripts/config -d USB_EPSON2888
scripts/config -d USB_KC2190
scripts/config -d ADM8211
scripts/config -d ATH5K_DEBUG
scripts/config -d ATH5K_TRACER
scripts/config -d ATH9K_AHB
scripts/config -d ATH9K_DYNACK
scripts/config -d ATH9K_WOW
scripts/config -d ATH9K_CHANNEL_CONTEXT
scripts/config -d ATH9K_HTC_DEBUGFS
scripts/config -d ATH9K_HWRNG
scripts/config -d ATH6KL_DEBUG
scripts/config -d ATH6KL_TRACING
scripts/config -d ATH10K_DEBUG
scripts/config -d ATH10K_DEBUGFS
scripts/config -d ATH10K_TRACING
scripts/config -d WCN36XX_DEBUGFS
scripts/config -d ATH11K_AHB
scripts/config -d ATH12K_DEBUG
scripts/config -d ATH12K_TRACING
scripts/config -d AT76C50X_USB
scripts/config -d BRCM_TRACING
scripts/config -d BRCMDBG

# iwl3945 / iwl4965 Debugging Options
scripts/config -d IWLEGACY_DEBUG

# Debugging Options
scripts/config -d IWLWIFI_DEBUG
scripts/config -d IWLWIFI_DEVICE_TRACING
scripts/config -d P54_SPI
scripts/config -d LIBERTAS_SPI
scripts/config -d LIBERTAS_MESH
scripts/config -d LIBERTAS_THINFIRM
scripts/config -d MT7603E
scripts/config -d MT7663S
scripts/config -d WLAN_VENDOR_MICROCHIP
scripts/config -d RTLWIFI_DEBUG
scripts/config -d RTL8XXXU_UNTESTED
scripts/config -d RTW88_DEBUG
scripts/config -d RTW88_DEBUGFS
scripts/config -d RTW89_DEBUGMSG
scripts/config -d RTW89_DEBUGFS
scripts/config -d IEEE802154_HWSIM

# Wireless WAN
scripts/config -d WWAN_DEBUGFS
scripts/config -d WWAN_HWSIM
scripts/config -d RPMSG_WWAN_CTRL
scripts/config -d IOSM
scripts/config -d NETDEVSIM
scripts/config -d ISDN

# Input Device Drivers
scripts/config -d MOUSE_PS2_BYD
scripts/config -d MOUSE_PS2_SENTELIC
scripts/config -d MOUSE_PS2_TOUCHKIT
scripts/config -d TOUCHSCREEN_CY8CTMA140
scripts/config -d TOUCHSCREEN_ILITEK
scripts/config -d TOUCHSCREEN_MSG2638
scripts/config -d TOUCHSCREEN_TSC2007_IIO
scripts/config -d TOUCHSCREEN_ZINITIX
scripts/config -d INPUT_AD714X
scripts/config -d INPUT_BMA150
scripts/config -d INPUT_MMA8450
scripts/config -d INPUT_GPIO_BEEPER
scripts/config -d INPUT_GPIO_DECODER
scripts/config -d INPUT_GPIO_VIBRA
scripts/config -d INPUT_REGULATOR_HAPTIC
scripts/config -d INPUT_PCF8574
scripts/config -d INPUT_PWM_BEEPER
scripts/config -d INPUT_ADXL34X
scripts/config -d INPUT_IMS_PCU
scripts/config -d INPUT_IQS269A
scripts/config -d INPUT_IQS626A
scripts/config -d INPUT_DRV260X_HAPTICS
scripts/config -d INPUT_DRV2665_HAPTICS
scripts/config -d INPUT_DRV2667_HAPTICS

# Hardware I/O ports
scripts/config -d SERIO_CT82C710
scripts/config -d SERIO_PARKBD
scripts/config -d SERIO_PCIPS2
scripts/config -d SERIO_PS2MULT

# Serial drivers
scripts/config -d SERIAL_8250_EXTENDED
scripts/config -d SERIAL_8250_DFL
scripts/config -d SERIAL_8250_RT288X
scripts/config -d SERIAL_8250_MID

# Non-8250 serial port support
scripts/config -d SERIAL_MAX3100
scripts/config -d SERIAL_MAX310X
scripts/config -d SERIAL_UARTLITE
scripts/config -d SERIAL_SCCNXP
scripts/config -d SERIAL_SC16IS7XX
scripts/config -d SERIAL_ALTERA_JTAGUART
scripts/config -d SERIAL_ALTERA_UART
scripts/config -d SERIAL_RP2
scripts/config -d SERIAL_FSL_LPUART
scripts/config -d SERIAL_FSL_LINFLEXUART
scripts/config -d SERIAL_SPRD
scripts/config -d SERIAL_NONSTANDARD
scripts/config -d RPMSG_TTY
scripts/config -d LP_CONSOLE
scripts/config -d HW_RANDOM_BA431
scripts/config -d HW_RANDOM_VIA
scripts/config -d HW_RANDOM_XIPHERA
scripts/config -d APPLICOM
scripts/config -d TCG_VTPM_PROXY
scripts/config -d TCG_TIS_ST33ZP24_SPI
scripts/config -d XILLYUSB

# ACPI drivers
scripts/config -d I2C_CBUS_GPIO
scripts/config -d I2C_EMEV2
scripts/config -d I2C_GPIO
scripts/config -d I2C_OCORES

# GPIO Debugging utilities
scripts/config -d GPIO_SLOPPY_LOGIC_ANALYZER

# Analog TV USB devices
scripts/config -d VIDEO_GO7007_USB_S2250_BOARD

# Analog/digital TV USB devices
scripts/config -d VIDEO_AU0828_RC

# Digital TV USB devices
scripts/config -d DVB_USB_LME2510
scripts/config -d DVB_USB

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

# Lens drivers
scripts/config -d VIDEO_AD5820
scripts/config -d VIDEO_AK7375
scripts/config -d VIDEO_DW9714
scripts/config -d VIDEO_DW9719
scripts/config -d VIDEO_DW9768
scripts/config -d VIDEO_DW9807_VCM

# Graphics support
scripts/config -d DRM_DEBUG_DP_MST_TOPOLOGY_REFS
scripts/config -d DRM_DEBUG_MODESET_LOCK
#scripts/config -d DRM_FBDEV_LEAK_PHYS_SMEM
scripts/config -d DRM_DISPLAY_DP_TUNNEL_STATE_DEBUG

# drm/i915 Debugging
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

# drm/Xe Debugging
scripts/config -d DRM_XE_WERROR
scripts/config -d DRM_XE_DEBUG
scripts/config -d DRM_XE_DEBUG_VM
scripts/config -d DRM_XE_DEBUG_SRIOV
scripts/config -d DRM_XE_DEBUG_MEM
scripts/config -d DRM_XE_USERPTR_INVAL_INJECT
scripts/config -d DRM_VKMS
scripts/config -d DRM_GMA500

# Backlight & LCD device support
scripts/config -d LCD_L4F00242T03
scripts/config -d LCD_LMS283GF05
scripts/config -d LCD_LTV350QV
scripts/config -d LCD_ILI922X
scripts/config -d LCD_ILI9320
scripts/config -d LCD_TDO24M
scripts/config -d LCD_VGG2432A4
scripts/config -d LCD_AMS369FG06
scripts/config -d LCD_LMS501KF03
scripts/config -d LCD_HX8357
scripts/config -d LCD_OTM3225A
scripts/config -d BACKLIGHT_KTD253
scripts/config -d BACKLIGHT_SAHARA
scripts/config -d BACKLIGHT_ADP8860
scripts/config -d BACKLIGHT_ADP8870
scripts/config -d BACKLIGHT_LM3630A
scripts/config -d BACKLIGHT_LM3639
scripts/config -d BACKLIGHT_GPIO
scripts/config -d BACKLIGHT_LV5207LP
scripts/config -d BACKLIGHT_BD6107
scripts/config -d SND_UMP_LEGACY_RAWMIDI
scripts/config -d SND_SEQ_UMP
scripts/config -d SND_DUMMY
scripts/config -d SND_PCMTEST
scripts/config -d SND_MTPAV
scripts/config -d SND_MTS64
scripts/config -d SND_SERIAL_U16550
scripts/config -d SND_MPU401
scripts/config -d SND_PORTMAN2X4
scripts/config -d SND_AW2
scripts/config -d SND_ES1968_INPUT
scripts/config -d SND_ES1968_RADIO
scripts/config -d SND_FM801_TEA575X_BOOL
scripts/config -d SND_MAESTRO3_INPUT

# USB Imaging devices
scripts/config -d USBIP_VUDC

# USB Miscellaneous drivers
scripts/config -d USB_TEST
scripts/config -d USB_EHSET_TEST_FIXTURE
scripts/config -d USB_LINK_LAYER_TEST

# USB Peripheral Controller
scripts/config -d USB_AMD5536UDC
scripts/config -d USB_DUMMY_HCD

# USB Gadget precomposed configurations
scripts/config -d USB_ZERO
scripts/config -d USB_ETH
scripts/config -d USB_G_NCM
scripts/config -d USB_GADGETFS
scripts/config -d USB_FUNCTIONFS
# scripts/config -d USB_MASS_STORAGE
scripts/config -d USB_GADGET_TARGET
scripts/config -d USB_G_SERIAL
scripts/config -d USB_MIDI_GADGET
scripts/config -d USB_G_PRINTER
scripts/config -d USB_CDC_COMPOSITE
scripts/config -d USB_G_ACM_MS
scripts/config -d USB_G_MULTI
scripts/config -d USB_G_DBGP
scripts/config -d USB_G_WEBCAM
scripts/config -d TYPEC_TCPCI_MAXIM
scripts/config -d TYPEC_STUSB160X

# USB Type-C Multiplexer/DeMultiplexer Switch support
scripts/config -d TYPEC_MUX_WCD939X_USBSS
scripts/config -d MMC_TEST

# MemoryStick drivers
scripts/config -d MS_BLOCK

# MemoryStick Host Controller Drivers
scripts/config -d LEDS_CLASS_MULTICOLOR
scripts/config -d LEDS_BRIGHTNESS_HW_CHANGED

# Qualcomm SoC drivers
scripts/config -d QCOM_PMIC_PDCHARGER_ULOG
scripts/config -d SOC_TI

# LED drivers
scripts/config -d LEDS_CHT_WCOVE
scripts/config -d LEDS_LM3642
scripts/config -d LEDS_PCA9532_GPIO
scripts/config -d LEDS_PCA955X
scripts/config -d LEDS_PCA963X
scripts/config -d LEDS_PCA995X
scripts/config -d LEDS_DAC124S085
scripts/config -d LEDS_PWM
scripts/config -d LEDS_REGULATOR
scripts/config -d LEDS_BD2802
scripts/config -d LEDS_LT3593
scripts/config -d LEDS_TCA6507
scripts/config -d LEDS_TLC591XX
scripts/config -d LEDS_LM355x

# LED Triggers
scripts/config -d LEDS_TRIGGER_DISK
scripts/config -d LEDS_TRIGGER_MTD
scripts/config -d LEDS_TRIGGER_CPU

# iptables trigger is under Netfilter config (LED target)
scripts/config -d LEDS_TRIGGER_PANIC
scripts/config -d LEDS_TRIGGER_PATTERN
scripts/config -d LEDS_TRIGGER_INPUT_EVENTS

# Simple LED drivers
scripts/config -d LEDS_SIEMENS_SIMATIC_IPC_APOLLOLAKE
scripts/config -d ACCESSIBILITY
scripts/config -d INFINIBAND_IRDMA
scripts/config -d INFINIBAND_MTHCA_DEBUG
scripts/config -d INFINIBAND_RTRS_SERVER
scripts/config -d EDAC_AMD64
scripts/config -d EDAC_IGEN6
scripts/config -d RTC_HCTOSYS
scripts/config -d RTC_SYSTOHC
scripts/config -d RTC_NVMEM

# RTC interfaces
scripts/config -d RTC_INTF_DEV_UIE_EMUL

# I2C RTC drivers
scripts/config -d RTC_DRV_ABB5ZES3
scripts/config -d RTC_DRV_ABEOZ9
scripts/config -d RTC_DRV_DS1307_CENTURY
scripts/config -d RTC_DRV_MAX31335
scripts/config -d RTC_DRV_PCF85363
scripts/config -d RTC_DRV_M41T80_WDT
scripts/config -d RTC_DRV_S35390A
scripts/config -d RTC_DRV_RV3028
scripts/config -d RTC_DRV_RV3032
scripts/config -d RTC_DRV_RV8803
scripts/config -d RTC_DRV_SD3078

# SPI RTC drivers
scripts/config -d RTC_DRV_DS1302

# SPI and I2C RTC drivers
scripts/config -d RTC_DRV_RX6110

# Platform RTC drivers
scripts/config -d RTC_DRV_M48T86

# on-CPU RTC drivers
scripts/config -d RTC_DRV_FTRTC010

# DMABUF options
scripts/config -d DMABUF_SYSFS_STATS
scripts/config -d VFIO_DEBUGFS

# Accelerometers
scripts/config -d ADIS16203
scripts/config -d ADIS16240

# Analog to digital converters
scripts/config -d AD7816

# Analog digital bi-direction converters
scripts/config -d ADT7316

# Direct Digital Synthesis
scripts/config -d AD9832
scripts/config -d AD9834

# Network Analyzer, Impedance Converters
scripts/config -d LTE_GDM724X
scripts/config -d CROS_EC_DEBUGFS
scripts/config -d CHROMEOS_PRIVACY_SCREEN
scripts/config -d CZNIC_PLATFORMS
scripts/config -d SURFACE_AGGREGATOR_REGISTRY
scripts/config -d SURFACE_DTX
scripts/config -d NVIDIA_WMI_EC_BACKLIGHT
scripts/config -d ADV_SWBUTTON
scripts/config -d DELL_WMI_PRIVACY
scripts/config -d TOUCHSCREEN_DMI

# Accelerometers
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
scripts/config -d AD7091R5
scripts/config -d AD7091R8
scripts/config -d AD7124
scripts/config -d AD7192
scripts/config -d AD7266
scripts/config -d AD7280
scripts/config -d AD7291
scripts/config -d AD7292
scripts/config -d AD7298
scripts/config -d AD7380
scripts/config -d AD7476
scripts/config -d AD7606_IFACE_PARALLEL
scripts/config -d AD7606_IFACE_SPI
scripts/config -d AD7768_1
scripts/config -d AD7780
scripts/config -d AD7791
scripts/config -d AD7793
scripts/config -d AD7887
scripts/config -d AD7923
scripts/config -d AD7949
scripts/config -d AD799X
scripts/config -d AD9467
scripts/config -d CC10001_ADC
scripts/config -d HI8435
scripts/config -d HX711
scripts/config -d INA2XX_ADC
scripts/config -d LTC2309
scripts/config -d LTC2471
scripts/config -d LTC2485
scripts/config -d LTC2496
scripts/config -d LTC2497
scripts/config -d MAX1027
scripts/config -d MAX11100
scripts/config -d MAX1118
scripts/config -d MAX1241
scripts/config -d MAX34408
scripts/config -d MAX9611
scripts/config -d MCP320X
scripts/config -d MCP3422
scripts/config -d NAU7802
scripts/config -d TI_ADC081C
scripts/config -d TI_ADC0832
scripts/config -d TI_ADC084S021
scripts/config -d TI_ADC12138
scripts/config -d TI_ADC108S102
scripts/config -d TI_ADC128S052
scripts/config -d TI_ADC161S626
scripts/config -d TI_ADS1119
scripts/config -d TI_ADS7950
scripts/config -d TI_ADS131E08
scripts/config -d TI_TLC4541
scripts/config -d TI_TSC2046
scripts/config -d VIPERBOARD_ADC
scripts/config -d XILINX_XADC

# Amplifiers
scripts/config -d AD8366
scripts/config -d HMC425

# Capacitance to digital converters
scripts/config -d AD7150
scripts/config -d AD7746

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

# Digital to analog converters
scripts/config -d AD5064
scripts/config -d AD5360
scripts/config -d AD5380
scripts/config -d AD5421
scripts/config -d AD5446
scripts/config -d AD5449
scripts/config -d AD5592R
scripts/config -d AD5593R
scripts/config -d AD5504
scripts/config -d AD5624R_SPI
scripts/config -d AD5686_SPI
scripts/config -d AD5696_I2C
scripts/config -d AD5755
scripts/config -d AD5758
scripts/config -d AD5761
scripts/config -d AD5764
scripts/config -d AD5770R
scripts/config -d AD5791
scripts/config -d AD7303
scripts/config -d AD8801
scripts/config -d DS4424
scripts/config -d LTC2632
scripts/config -d M62332
scripts/config -d MAX517
scripts/config -d MCP4725
scripts/config -d MCP4821
scripts/config -d MCP4922
scripts/config -d TI_DAC082S085
scripts/config -d TI_DAC5571
scripts/config -d TI_DAC7311
scripts/config -d TI_DAC7612

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

# Inertial measurement units
scripts/config -d ADIS16400
scripts/config -d ADIS16460
scripts/config -d ADIS16475
scripts/config -d ADIS16480
scripts/config -d BMI160_I2C
scripts/config -d BMI160_SPI
scripts/config -d BMI323_I2C
scripts/config -d BMI323_SPI
scripts/config -d FXOS8700_I2C
scripts/config -d FXOS8700_SPI
scripts/config -d KMX61
scripts/config -d INV_ICM42600_I2C
scripts/config -d INV_ICM42600_SPI
scripts/config -d INV_MPU6050_SPI
scripts/config -d IIO_ST_LSM6DSX
scripts/config -d IIO_ST_LSM9DS0

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

# Triggers - standalone
scripts/config -d IIO_HRTIMER_TRIGGER

# Digital potentiometers
scripts/config -d DS1803
scripts/config -d MAX5432
scripts/config -d MAX5481
scripts/config -d MAX5487
scripts/config -d MCP4131
scripts/config -d MCP4531
scripts/config -d MCP41010
scripts/config -d TPL0102
scripts/config -d X9250

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

# Resolver to digital converters
scripts/config -d AD2S90
scripts/config -d AD2S1200
scripts/config -d AD2S1210

# PHY Subsystem
scripts/config -d USB_LGM_PHY
scripts/config -d PHY_CAN_TRANSCEIVER

# PHY drivers for Broadcom platforms
scripts/config -d BCM_KONA_USB2_PHY
scripts/config -d PHY_PXA_28NM_HSIC
scripts/config -d PHY_PXA_28NM_USB2
scripts/config -d PHY_QCOM_USB_HS
scripts/config -d PHY_QCOM_USB_HSIC
scripts/config -d PHY_TUSB1210
scripts/config -d MCB

# File systems
scripts/config -d REISERFS_FS
scripts/config -d JFS_FS
scripts/config -d BCACHEFS_QUOTA
scripts/config -d BCACHEFS_POSIX_ACL
scripts/config -d BCACHEFS_LOCK_TIME_STATS

# Caches
scripts/config -d NETFS_STATS
scripts/config -d NETFS_DEBUG
scripts/config -d FSCACHE_STATS

# Pseudo filesystems
scripts/config -d SUNRPC_DEBUG
scripts/config -d CIFS_DEBUG
scripts/config -d DLM_DEBUG

# Crypto core or helper
scripts/config -d CRYPTO_MANAGER_DISABLE_TESTS
scripts/config -d CRYPTO_MANAGER_EXTRA_TESTS

### Apply various Clear Linux defaults.
### To skip, uncomment the exit line.
### exit 0

if [[ $(uname -m) = *"x86"* ]]; then
    ### Default to IOMMU passthrough domain type.
    scripts/config -d IOMMU_DEFAULT_DMA_LAZY -e IOMMU_DEFAULT_PASSTHROUGH

    ### Disable support for memory balloon compaction.
    #scripts/config -d BALLOON_COMPACTION

    ### Disable the Contiguous Memory Allocator.
    #scripts/config -d CMA

    ### Disable HWPoison pages injector.
    scripts/config -d HWPOISON_INJECT

    ### Disable track memory changes and idle page tracking.
    #scripts/config -d MEM_SOFT_DIRTY -d IDLE_PAGE_TRACKING

    ### Disable paravirtual steal time accounting.
    scripts/config -d PARAVIRT_TIME_ACCOUNTING

    ### Disable pvpanic device support.
    scripts/config -d PVPANIC

    ### Require boot param to enable pressure stall information tracking.
    scripts/config -e PSI_DEFAULT_DISABLED

    ### Disable khugepaged to put read-only file-backed pages in THP.
    scripts/config -d READ_ONLY_THP_FOR_FS

    ### Disable Integrity Policy Enforcement (IPE).
    scripts/config -d SECURITY_IPE

    ### Disable support for userspace-controlled virtual timers.
    scripts/config -d SND_UTIMER

    ### Disable the general notification queue.
    scripts/config -d WATCH_QUEUE

    ### Disable Watchdog Timer Support.
    scripts/config -d WATCHDOG

    ### Disable PCI Express ASPM L0s and L1, even if the BIOS enabled them.
    scripts/config -d PCIEASPM_DEFAULT -e PCIEASPM_PERFORMANCE

    ### Disable workqueue power-efficient mode by default.
    scripts/config -d WQ_POWER_EFFICIENT_DEFAULT

    ### Set the default state of memory_corruption_check to off.
    scripts/config -d X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK

    ### Disable Split Lock Detect and Bus Lock Detect support.
    scripts/config -d X86_BUS_LOCK_DETECT

    ### Disable statistic for Change Page Attribute.
    scripts/config -d X86_CPA_STATISTICS

    ### Disable x86 instruction decoder selftest.
    scripts/config -d X86_DECODER_SELFTEST

    ### Disable 5-level page tables support.
    scripts/config -d X86_5LEVEL

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

    ### Enforce strict size checking for sigaltstack.
    scripts/config -e STRICT_SIGALTSTACK_SIZE

    ### Disable Kexec and crash features.
    scripts/config -d KEXEC -d KEXEC_FILE -d CRASH_DUMP

    ### Disable low-overhead sampling-based memory safety error detector.
    scripts/config -d KFENCE

    ### Disable automatic stack variable initialization. (Clear and XanMod default)
    scripts/config -d INIT_STACK_ALL_ZERO -e INIT_STACK_NONE

    ### Disable utilization clamping for RT/FAIR tasks.
    scripts/config -d UCLAMP_TASK

    ### Disable CGROUP controllers.
    #scripts/config -d CGROUP_HUGETLB
    #scripts/config -d CGROUP_NET_PRIO
    #scripts/config -d CGROUP_PERF
    scripts/config -d CGROUP_RDMA

    ### Disable support for latency based cgroup IO protection.
    #scripts/config -d BLK_CGROUP_IOLATENCY

    ### Disable support for cost model based cgroup IO controller.
    #scripts/config -d BLK_CGROUP_IOCOST

    ### Disable cgroup I/O controller for assigning an I/O priority class.
    #scripts/config -d BLK_CGROUP_IOPRIO

    ### Disable netfilter "control group" match support.
    #scripts/config -d NETFILTER_XT_MATCH_CGROUP

    ### Apply Clear defaults for NR_CPUS and NODES_SHIFT.
    scripts/config -d CPUMASK_OFFSTACK -d MAXSMP
    scripts/config --set-val NR_CPUS_RANGE_BEGIN 2
    scripts/config --set-val NR_CPUS_RANGE_END 512
    scripts/config --set-val NR_CPUS_DEFAULT 64
    scripts/config --set-val NR_CPUS 512
    scripts/config --set-val NODES_SHIFT 10

    ### Default to the 2:1 compression allocator (zbud) as the default allocator.
    #scripts/config -d ZSWAP_DEFAULT_ON -d ZSWAP_SHRINKER_DEFAULT_ON
    #scripts/config -d ZSWAP_ZPOOL_DEFAULT_ZSMALLOC -d ZSMALLOC_STAT
    #scripts/config -e ZSWAP_ZPOOL_DEFAULT_ZBUD -e ZBUD
    #scripts/config --set-str ZSWAP_ZPOOL_DEFAULT "zbud"
fi

