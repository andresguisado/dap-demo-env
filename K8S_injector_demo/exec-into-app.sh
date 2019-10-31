#!/bin/bash

source ../config/dap.config
source ../config/$PLATFORM.config
source ./injector.config

clear
app_pod=$($CLI -n $INJECTED_NAMESPACE_NAME get pods | grep $INJECTED_APP_NAME | awk '{print $1}')
$CLI -n $INJECTED_NAMESPACE_NAME exec -it $app_pod -- bash
