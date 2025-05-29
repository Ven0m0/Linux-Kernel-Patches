#!/usr/bin/env bash
# Set/override custom kernel options
# Make a copy, "cp custom.sh.in custom.sh" and edit custom.sh
# Uncomment kernel options not needed to reduce build time

set -e

cd "$1" || { echo "Directory not found: $1"; exit 1; }

##
# scripts/config usage:
# scripts/config options command ...
# commands:
#     --enable   | -e option   Enable option
#     --disable  | -d option   Disable option
#     --module   | -m option   Turn option into a module
#     --set-str option string  Set option to "string"
#     --set-val option value   Set option to value
#     --undefine | -u option   Undefine option
##

# Disable debug
scripts/config -d SLUB_DEBUG
scripts/config -d PM_DEBUG
scripts/config -d PM_ADVANCED_DEBUG
scripts/config -d PM_SLEEP_DEBUG
scripts/config -d ACPI_DEBUG
scripts/config -d CRASH_DUMP
scripts/config -d USB_PRINTER
# Disable BPF/Tracers if not needed
scripts/config --disable BPF
scripts/config --disable FTRACE
scripts/config --disable FUNCTION_TRACER

# Disable security support
#scripts/config -d SECURITY_SELINUX
#scripts/config -d SECURITY_SMACK
#scripts/config -d SECURITY_TOMOYO

# Disable AMD Secure Memory Encryption (SME) support
scripts/config -d AMD_MEM_ENCRYPT

# Disable Intel Software Guard eXtensions (SGX)
# A set of CPU instructions that can be used by applications to set aside
# private regions of code and data, referred to as enclaves.
scripts/config -d X86_SGX

# Disable CXL (Compute Express Link) devices support
#scripts/config -d CXL_BUS

# Disable direct rendering manager support
scripts/config -d DRM_ACCEL_AMDXDNA
scripts/config -d DRM_AMDGPU
scripts/config -d DRM_APPLETBDRM
scripts/config -d DRM_ARCPGU
#scripts/config -d DRM_HISI_HIBMC
#scripts/config -d DRM_I915
#scripts/config -d DRM_NOUVEAU
scripts/config -d DRM_RADEON
scripts/config -d DRM_XE
scripts/config -d DRM_AST
scripts/config -d DRM_MGAG200

# Disable filesystem support
scripts/config -d BCACHEFS_FS
#scripts/config -d BTRFS_FS
#scripts/config -d XFS_FS

# Disable FPGA Configuration Framework
#scripts/config -d FPGA

# Disable laptop support
#scripts/config -d ASUS_LAPTOP
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
#scripts/config -d CHROME_PLATFORMS
scripts/config -d CZNIC_PLATFORMS
scripts/config -d MELLANOX_PLATFORM
scripts/config -d SURFACE_PLATFORMS

# Disable PS/2 keyboard and mouse
scripts/config -d KEYBOARD_ATKBD -d MOUSE_PS2 -d SERIO_I8042

# Disable joystick input devices
# https://github.com/torvalds/linux/blob/master/drivers/input/joystick/Kconfig
#scripts/config -d INPUT_JOYSTICK -d INPUT_JOYDEV

# Disable miscellaneous input devices
# https://github.com/torvalds/linux/blob/master/drivers/input/misc/Kconfig
#scripts/config -d INPUT_MISC

# Disable touchscreen input devices
# https://github.com/torvalds/linux/blob/master/drivers/input/touchscreen/Kconfig
scripts/config -d INPUT_TOUCHSCREEN

# Disable multiple devices driver support (RAID and LVM)
# https://github.com/torvalds/linux/blob/master/drivers/md/Kconfig
#scripts/config -d MD

# Disable Controller Area Network (CAN) bus subsystem support
# https://github.com/torvalds/linux/blob/master/net/can/Kconfig
#scripts/config -d CAN

# Disable industrial I/O subsystem support
# https://github.com/torvalds/linux/blob/master/drivers/iio/Kconfig
#scripts/config -d IIO

# Disable InfiniBand support
# https://github.com/torvalds/linux/blob/master/drivers/infiniband/Kconfig
#scripts/config -d INFINIBAND

# Disable ServerEngines' 10Gbps NIC - BladeEngine ethernet support
# https://github.com/torvalds/linux/blob/master/drivers/net/ethernet/emulex/Kconfig
#scripts/config -d BE2NET

# Disable Mellanox Technologies ethernet support
# https://github.com/torvalds/linux/blob/master/drivers/net/ethernet/mellanox/Kconfig
scripts/config -d MLX4_EN
scripts/config -d MLX5_CORE
scripts/config -d MLXSW_CORE
scripts/config -d MLXFW

# Disable parallel port support
# https://github.com/torvalds/linux/blob/master/drivers/parport/Kconfig
#scripts/config -d PARPORT

# Disable Sonics Silicon Backplane support
# https://github.com/torvalds/linux/blob/master/drivers/ssb/Kconfig
scripts/config -d SSB

# Disable media tuners
# https://github.com/torvalds/linux/blob/master/drivers/media/tuners/Kconfig
#scripts/config -d DVB_CORE
#scripts/config -d VIDEO_BT848
#scripts/config -d VIDEO_CX231XX
#scripts/config -d VIDEO_CX25821
#scripts/config -d VIDEO_CX88
#scripts/config -d VIDEO_DT3155
#scripts/config -d VIDEO_EM28XX
#scripts/config -d VIDEO_GO7007
#scripts/config -d VIDEO_HDPVR
#scripts/config -d VIDEO_HEXIUM_GEMINI
#scripts/config -d VIDEO_HEXIUM_ORION
#scripts/config -d VIDEO_IVTV
#scripts/config -d VIDEO_MXB
#scripts/config -d VIDEO_SAA7134
#scripts/config -d VIDEO_STK1160

# Disable GSPCA based webcams
# https://github.com/torvalds/linux/blob/master/drivers/media/usb/gspca/Kconfig
scripts/config -d USB_GSPCA

# Disable network drivers
# https://github.com/torvalds/linux/blob/master/drivers/net/ethernet/
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
#scripts/config -d NET_VENDOR_REALTEK
scripts/config -d NET_VENDOR_SOCIONEXT
scripts/config -d NET_VENDOR_SOLARFLARE
scripts/config -d NET_VENDOR_STMICRO
scripts/config -d NET_VENDOR_VERTEXCOM
scripts/config -d NET_VENDOR_WANGXUN

# Disable Distributed Switch Architecture
#scripts/config -d NET_DSA

# Disable PPP (point-to-point protocol) support
#scripts/config -d PPP

# Disable SLIP (serial line) support
#scripts/config -d SLIP

# Disable USB network adapters
#scripts/config -d USB_NET_DRIVERS

# Disable Wan interfaces support
#scripts/config -d WAN

# Disable IPv6 over Low power Wireless Personal Area Network
scripts/config -d 6LOWPAN -d IEEE802154

# Disable RF switch subsystem support
# Control over RF switches found on many WiFi and Bluetooth cards
#scripts/config -d RFKILL

# Disable wireless LAN drivers
# https://github.com/torvalds/linux/blob/master/net/wireless/Kconfig
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
# https://github.com/torvalds/linux/blob/master/sound/pci/hda/Kconfig
# https://github.com/torvalds/linux/blob/master/sound/soc/intel/Kconfig
# https://github.com/torvalds/linux/blob/master/sound/soc/Kconfig
#scripts/config -d SND_HDA_SCODEC_TAS2781_SPI
#scripts/config -d SND_I2S_HI6210_I2S
#scripts/config -d SND_SOC_CHV3_I2S
#scripts/config -d SND_SOC_INTEL_CATPT
#scripts/config -d SND_SOC

# Disable PCI sound devices
# https://github.com/torvalds/linux/blob/master/sound/pci/Kconfig
#scripts/config -d SND_AD1889
#scripts/config -d SND_ALI5451
#scripts/config -d SND_ALS300
#scripts/config -d SND_ALS4000
#scripts/config -d SND_ASIHPI
#scripts/config -d SND_ATIIXP
#scripts/config -d SND_ATIIXP_MODEM
#scripts/config -d SND_AU8810
#scripts/config -d SND_AU8820
#scripts/config -d SND_AU8830
#scripts/config -d SND_AW2
#scripts/config -d SND_AZT3328
#scripts/config -d SND_BT87X
#scripts/config -d SND_CA0106
#scripts/config -d SND_CMIPCI
#scripts/config -d SND_CS4281
#scripts/config -d SND_CS46XX
#scripts/config -d SND_CTXFI
#scripts/config -d SND_DARLA20
#scripts/config -d SND_DARLA24
#scripts/config -d SND_ECHO3G
#scripts/config -d SND_EMU10K1
#scripts/config -d SND_EMU10K1X
#scripts/config -d SND_ENS1370
#scripts/config -d SND_ENS1371
#scripts/config -d SND_ES1938
#scripts/config -d SND_ES1968
#scripts/config -d SND_FM801
#scripts/config -d SND_GINA20
#scripts/config -d SND_GINA24
#scripts/config -d SND_HDSP
#scripts/config -d SND_HDSPM
#scripts/config -d SND_ICE1712
#scripts/config -d SND_ICE1724
#scripts/config -d SND_INDIGO
#scripts/config -d SND_INDIGODJ
#scripts/config -d SND_INDIGODJX
#scripts/config -d SND_INDIGOIO
#scripts/config -d SND_INDIGOIOX
#scripts/config -d SND_INTEL8X0M
#scripts/config -d SND_KORG1212
#scripts/config -d SND_LAYLA20
#scripts/config -d SND_LAYLA24
#scripts/config -d SND_LOLA
#scripts/config -d SND_LX6464ES
#scripts/config -d SND_MAESTRO3
#scripts/config -d SND_MIA
#scripts/config -d SND_MIXART
#scripts/config -d SND_MONA
#scripts/config -d SND_NM256
#scripts/config -d SND_OXYGEN
#scripts/config -d SND_PCXHR
#scripts/config -d SND_RIPTIDE
#scripts/config -d SND_RME32
#scripts/config -d SND_RME96
#scripts/config -d SND_RME9652
#scripts/config -d SND_SE6X
#scripts/config -d SND_SONICVIBES
#scripts/config -d SND_TRIDENT
#scripts/config -d SND_VIA82XX
#scripts/config -d SND_VIA82XX_MODEM
#scripts/config -d SND_VIRTUOSO
#scripts/config -d SND_VX222
#scripts/config -d SND_YMFPCI

# Disable staging drivers
# Drivers that are not of the "normal" Linux kernel quality level
#scripts/config -d STAGING

