#!/bin/bash
########################################
##  This script executes on AWS host  ##
########################################

source ./aws.config

# AWS host initialization
$SETUP_DIR/1_install_docker.sh
$SETUP_DIR/2_ruby_setup.sh
$SETUP_DIR/3_load_images.sh

# start/restart conjur
$SETUP_DIR/stop
$SETUP_DIR/4_start_conjur.sh
$SETUP_DIR/5_load_policies.sh
