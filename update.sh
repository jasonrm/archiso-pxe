#!/bin/bash

HTTP_MIRROR="http://mirrors.kernel.org"

for arch in x86_64 i686; do
    echo "Updating archlinux: ${arch}"
    mkdir -p ${arch}
    pushd ${arch}
    curl --progress -o airootfs.sfs    ${HTTP_MIRROR}/archlinux/iso/latest/arch/${arch}/airootfs.sfs || exit 1
    curl --progress -o archiso.img     ${HTTP_MIRROR}/archlinux/iso/latest/arch/boot/${arch}/archiso.img || exit 1
    curl --progress -o intel_ucode.img ${HTTP_MIRROR}/archlinux/iso/latest/arch/boot/intel_ucode.img || exit 1
    curl --progress -o vmlinuz         ${HTTP_MIRROR}/archlinux/iso/latest/arch/boot/${arch}/vmlinuz || exit 1
    popd
done

echo "Done."
