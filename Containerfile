FROM quay.io/fedora/fedora-bootc:41

RUN <<EOF
set -xeuo pipefail

# Detect architecture
arch=$(uname -m)

# Add Asahi Linux repositories
cd /etc/yum.repos.d/
curl -OL https://copr.fedorainfracloud.org/coprs/g/asahi/kernel/repo/fedora-41/group_asahi-kernel-fedora-41.repo
curl -OL https://copr.fedorainfracloud.org/coprs/g/asahi/mesa/repo/fedora-41/group_asahi-mesa-fedora-41.repo
curl -OL https://copr.fedorainfracloud.org/coprs/g/asahi/fedora-remix-branding/repo/fedora-41/group_asahi-fedora-remix-branding-fedora-41.repo
curl -OL https://copr.fedorainfracloud.org/coprs/g/asahi/fedora-remix-scripts/repo/fedora-41/group_asahi-fedora-remix-scripts-fedora-41.repo
curl -OL https://copr.fedorainfracloud.org/coprs/g/asahi/u-boot/repo/fedora-41/group_asahi-u-boot-fedora-41.repo
EOF

# Install required packages
RUN <<EOF
 dnf install -y alsa-ucm-asahi asahi-bless asahi-fwupdate asahi-scripts \
               avahi-devel busybox codec2 crun-krun cups-devel \
               dracut-asahi dracut-config-generic egl-utils \
               glibc-minimal-langpack gnome-terminal \
               gnome-terminal-nautilus google-noto-sans-arabic-vf-fonts \
               im-chooser im-chooser-common imsettings \
               imsettings-gsettings imsettings-libs initial-setup \
               initial-setup-gui irqbalance json-devel keyutils-libs-devel \
               krb5-devel libestr libfastjson librabbitmq libretls \
               libtomcrypt libverto-devel linux-firmware-vendor lpcnetfreedv \
               lzfse-libs m1n1 netcat openfec plymouth plymouth-graphics-libs \
               plymouth-plugin-label plymouth-plugin-two-step \
               plymouth-scripts plymouth-system-theme plymouth-theme-spinner \
               pykickstart python3-asahi_firmware python3-asn1 python3-beaker \
               python3-crypto python3-paste python3-pyOpenSSL python3-tempita \
               qt5-qtbase-private-devel qt5-qtmultimedia-devel roc-toolkit \
               rsyslog rsyslog-logrotate rust smartmontools \
               smartmontools-selinux speexdsp-devel
dnf clean all
EOF


RUN <<EOF
# Install architecture-specific packages for aarch64 (Apple Silicon)
if [[ "$arch" == "aarch64" ]]; then
    dnf install -y grub2-efi-aa64-modules uboot-images-armv8 update-m1n1
fi
EOF

RUN rm -rf /usr/lib/modules/*
# Replace default kernel with Asahi's kernel-16k
RUN dnf swap -y kernel kernel-16k

# Replace Mesa packages with Asahi's versions
RUN <<EOF
    set -xeuo pipefail;
    dnf install -y mesa* --allowerasing --enablerepo=copr:copr.fedorainfracloud.org:group_asahi:mesa --disablerepo="*"
    dnf clean all
EOF
RUN rm -rf /var/cache/dnf \
  && rm -rf /var/log/dnf* \
  && rm -rf /boot/* 


# Validate Bootc container
# RUN bootc container lint

