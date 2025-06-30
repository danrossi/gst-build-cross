#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Download and run a Raspberry PI OS image with Docker and QEMU to customise it.
"""
import shutil

import os,sys

sys.path.insert(1, os.path.join(sys.path[0], '../../rpi-os-custom-image/'))

import download_os
from download_os import  ImageURL, OS_IMGS
#import customise_os_build
import customise_os_build



#RPI_IMAGE= "https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz"
#RPI


download_os.DEFAULT_IMG_TAG = "2024-07-04"


download_os.OS_IMGS["bookworm"] = {
   "2024-07-04": ImageURL(
            url="https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz",
            sha256_url="https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz.sha256",
    )
}

download_os.DEFAULT_IMAGE_URL = download_os.OS_IMGS[download_os.DEFAULT_IMG_RELEASE][download_os.DEFAULT_IMG_TAG]


download_os.IMAGE_SAVE_LOCATION = os.path.join(
    "/rpiosimage"
)

def main():
    # Download and unzip OS image
    compressed_path = download_os.download_compressed_image(download_os.DEFAULT_IMAGE_URL)
    img_path = download_os.decompress_image(compressed_path)
    img_tag = download_os.DEFAULT_IMG_TAG

    # Create a copy of the original image and configure it autologin + ssh
    #img_path = "rpi-os-custom-image/rpiosimage/2024-07-04-raspios-bookworm-arm64-lite.img"
    autologin_ssh_img = img_path.replace(".img", "-autologin-ssh.img")
    shutil.copyfile(img_path, autologin_ssh_img)
    #autologin_ssh_img = "rpi-os-custom-image/rpiosimage/2024-07-04-raspios-bookworm-arm64-lite-autologin-ssh.img"
    customise_os_build.run_edits(
        autologin_ssh_img, img_tag=img_tag, needs_login=True, autologin=True, ssh=True, expand_fs=False
    )

    # Copy original image and configure it autologin + ssh + expanded filesystem
    #autologin_ssh_fs_img = img_path.replace(".img", "-autologin-ssh-expanded.img")
    #shutil.copyfile(img_path, autologin_ssh_fs_img)
    #customise_os_build.run_edits(
    #   autologin_ssh_fs_img, img_tag=img_tag, needs_login=True, autologin=True, ssh=True, expand_fs=True
    #)

    # Copy expanded image (last one created) and install Mu dependencies
    #mu_img = img_path.replace(".img", "-mu.img")
    #shutil.copyfile(autologin_ssh_fs_img, mu_img)
    #customise_os_gstbuild.run_edits(mu_img, needs_login=False)


if __name__ == "__main__":
    main()
