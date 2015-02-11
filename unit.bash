#!/bin/bash

testRootPasswd() {
    grep 'root:\*\?:' /etc/shadow >/dev/null
    returnCode=$?
    assertEquals "User root has a setted password" 0 $returnCode
}


testKernelModules() {
    test -d "/lib/modules/$(uname -r)/kernel"
    returnCode=$?
    assertEquals "Kernel modules not downloaded" 0 $returnCode
}


testMetadata() {
    which oc-metadata >/dev/null
    returnCode=$?
    assertEquals "oc-metadata not found" 0 $returnCode

    test -n "$(oc-metadata --cached)"
    returnCode=$?
    assertEquals "Cannot fetch metadata" 0 $returnCode

    local private_ip=$(ip addr list eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    local metadata_ip=$(oc-metadata --cached PRIVATE_IP)
    assertEquals "PRIVATE_IP from metadata does not match eth0" $private_ip $metadata_ip
}


. shunit2
