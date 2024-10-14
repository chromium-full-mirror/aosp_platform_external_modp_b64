#
# TODO(b/371112401): Add license information
#

include $(TOPDIR)/rules.mk

PKG_NAME:=modp_b64
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=gwifi
  CATEGORY:=Nest WiFi Mesh Solutions
  SUBMENU:=Libs
  DEPENDS:=+libstdcpp
  TITLE:=Base64 encoder/decoder library
endef

define Package/$(PKG_NAME)description
Base64 encoder/decoder library.
endef

MODB64_CFLAGS:=["-O2","-pipe"]
MODB64_CPPFLAGS:=["-D_LARGEFILE_SOURCE","-D_LARGEFILE64_SOURCE","-DNDEBUG"]
MODB64_CXXFLAGS:=["-Os","-pipe","-fno-caller-saves","-std=c++17", \
  "-Wno-error=unused-but-set-variable","-Wno-error=unused-result","-Wformat",\
  "-Werror=format-security","-fstack-protector","-Wl,-z","-Wunused-function",\
  "-Wno-error","-fpermissive","-fPIC","-fno-exceptions","-fno-unwind-tables",\
  "-fno-asynchronous-unwind-tables","-Wno-implicit-fallthrough"]
MODPB64_LDFLAGS:=["-Wl,-O2","-Wl,--as-needed","-Wl,-Bdynamic"]

USE_FLAGS:={fuzzer=false cros_host=true profiling=false tcmalloc=false}

GN_ARGS:=platform_subdir="modp_b64" OS="linux" \
	 platform2_root="$(BUILD_DIR)" \
	 sysroot="$(STAGING_DIR)" \
	 pkg_config="$(STAGING_DIR_HOST)/bin/pkg-config" \
	 cc="$(TARGET_CC)" ar="$(TARGET_AR)" build_root="$(PKG_BUILD_DIR)/"\
	 enable_exceptions=false \
	 cxx="$(TARGET_CXX)" \
	 libdir="$(STAGING_DIR_ROOT)/usr/lib" \
         external_cxxflags=$(MODB64_CXXFLAGS) \
	 external_cflags=$(MODB64_CFLAGS) \
	 external_cppflags=$(MODB64_CPPFLAGS) \
	 external_ldflags=$(MODPB64_LDFLAGS) \
	 use=$(USE_FLAGS)

define Build/Prepare
	$(CP) $(TOPDIR)/package/gwifi/external/modp_b64/ $(BUILD_DIR)/
	$(CP) $(TOPDIR)/package/gwifi/external/platform2/common-mk/ $(BUILD_DIR)/
	$(CP) $(TOPDIR)/package/gwifi/external/platform2/.gn $(BUILD_DIR)/
	$(call Build/Prepare/Default)
endef

define Build/Configure/Default
        cd $(PKG_BUILD_DIR) && $(STAGING_DIR_HOSTPKG)/bin/gn gen \
	  --root='$(BUILD_DIR)' --args='$(GN_ARGS)' $(PKG_BUILD_DIR)/out/Default
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && $(STAGING_DIR_HOST)/bin/ninja \
	  -C $(PKG_BUILD_DIR)/out/Default modp_b64:all
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/modp_b64
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/modp_b64/modp_b64*.h $(1)/usr/include/modp_b64/
	$(CP) $(PKG_BUILD_DIR)/out/Default/obj/modp_b64/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/out/Default/lib/*.so $(1)/usr/lib
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
