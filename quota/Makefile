#===============================================================================
#
#          FILE:  Makefile.mk
#
#   DESCRIPTION:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Lukasz Plewa (), ukaszyk@gmail.com
#       VERSION:  1.0
#       CREATED:  2015-06-30 10:27:30
# LAST MODIFIED:  2015-06-30 10:59:38
#      REVISION:  ---
#===============================================================================
include $(TOPDIR)/rules.mk

PKG_NAME:=quota_bandwidthd
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/quota_bandwidthd
	CATEGORY:=Utilities
	DEPENDS:= +cron +bandwidthd

	TITLE:=quota_bandwidthd
endef

define Package/quota_bandwidthd/description
	Very simple method to manage o monthly quota in per IP basis.
endef

define Build/Compile
endef


define Package/quota_bandwidthd/install

	# configuration setup during system startup

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(CP) ./files/bandwidthd_config.sh $(1)/etc/uci-defaults/

	# bandwidthd

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/check_quota.sh $(1)/sbin/

endef

$(eval $(call BuildPackage,quota_bandwidthd))
