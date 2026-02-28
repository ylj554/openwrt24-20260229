#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
# =========================================================
# 1. 拉取 OpenClash 源码
# =========================================================
rm -rf package/luci-app-openclash
git clone --depth=1 -b master https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# =========================================================
# 2. 预下载 OpenClash 内核文件到固件中
# =========================================================
# 【重要配置】请根据你的路由器架构修改下方的 CORE_ARCH 变量！
# 常见架构代号：
# - x86_64 软路由: amd64
# - 树莓派4/5, 瑞芯微RK3328/3399等(ARMv8): arm64
# - 联发科 MT798x (如红米AX6000等): arm64
# - 斐讯N1: arm64
# - 传统 ARMv7 (如高通IPQ4019等): armv7
# ---------------------------------------------------------
CORE_ARCH="amd64"
# ---------------------------------------------------------

echo "正在预下载 OpenClash 内核 (架构: $CORE_ARCH)..."

# 创建内核存放目录 (编译时会自动将该目录打包进路由器固件的对应位置)
CORE_DIR="files/etc/openclash/core"
mkdir -p $CORE_DIR

# 下载 Dev 内核
curl -sL -o $CORE_DIR/clash.tar.gz "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-$CORE_ARCH.tar.gz"
tar -zxf $CORE_DIR/clash.tar.gz -C $CORE_DIR/
rm -f $CORE_DIR/clash.tar.gz

# 下载 Meta 内核
curl -sL -o $CORE_DIR/clash_meta.tar.gz "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-$CORE_ARCH.tar.gz"
tar -zxf $CORE_DIR/clash_meta.tar.gz -C $CORE_DIR/
mv $CORE_DIR/clash $CORE_DIR/clash_meta
rm -f $CORE_DIR/clash_meta.tar.gz

# 下载 TUN 内核
curl -sL -o $CORE_DIR/clash_tun.gz "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-$CORE_ARCH.gz"
gzip -d $CORE_DIR/clash_tun.gz
mv $CORE_DIR/clash_tun $CORE_DIR/clash_tun

# 赋予可执行权限
chmod +x $CORE_DIR/clash*

echo "OpenClash 内核预下载完成！"
