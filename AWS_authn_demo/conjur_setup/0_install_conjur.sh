#!/bin/bash
########################################
##  This script executes on AWS host  ##
########################################

source ./aws.config

if [[ "$(cat /etc/os-release | grep 'Ubuntu 18')" == "" ]]; then
  echo "These installation scripts assume Ubuntu 18"
  exit -1
fi

main() {
#  mount_image_volume
  install_docker
  load_images
  ./start_conjur
}

mount_image_volume() {
  # AWS host initialization
  mkdir -p $IMAGE_DIR
  sudo umount $EBS_BLK_DEV $IMAGE_DIR
  sudo mount $EBS_BLK_DEV $IMAGE_DIR
}

install_docker() {
  sudo snap install docker
}

load_images() {
  echo "Loading Conjur appliance image..."
  sudo docker load -i $IMAGE_DIR/$CONJUR_APPLIANCE_IMAGE_FILE
}

main "$@"
