#!/bin/sh

#  run.sh
#  BaltoSDK
#
#  Created by h.terashima on 2016/01/18.
#  Copyright © 2016年 goodpatch. All rights reserved.

UUID=`uuidgen`
REPO_KEY="BaltoRepository"
KEY="Balto"
PLIST="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

if [ -z "$1" ]; then
    echo "Repository name has not been specified."
    exit 1
fi

repositoryName=$1
repo=$($PLIST_BUDDY -c "Print ${REPO_KEY}" "${PLIST}")
if [ $? = 1 ]; then
    $PLIST_BUDDY -c "Add :${REPO_KEY} string '${repositoryName}'" "${PLIST}"
else
    $PLIST_BUDDY -c "Set :${REPO_KEY} '${repositoryName}'" "${PLIST}"
fi

currentVersion=$($PLIST_BUDDY -c "Print ${KEY}" "${PLIST}")
if [ $? = 1 ]; then
    $PLIST_BUDDY -c "Add :${KEY} string '${UUID}'" "${PLIST}"
else
    $PLIST_BUDDY -c "Set :${KEY} '${UUID}'" "${PLIST}"
fi

QUERIES_KEY="LSApplicationQueriesSchemes"
QUERIES=$($PLIST_BUDDY -c "Print ${QUERIES_KEY}" "${PLIST}")
if [ $? = 1 ]; then
    $PLIST_BUDDY -c "Add :${QUERIES_KEY} array" "${PLIST}"
    $PLIST_BUDDY -c "Add :${QUERIES_KEY}:0 string 'dev-balto'" "${PLIST}"
    $PLIST_BUDDY -c "Add :${QUERIES_KEY}:0 string 'balto'" "${PLIST}"
else
    if [[ ${QUERIES} =~ balto ]]; then
        echo "Already exist balto"
    else
        $PLIST_BUDDY -c "Add :${QUERIES_KEY}:0 string 'dev-balto'" "${PLIST}"
        $PLIST_BUDDY -c "Add :${QUERIES_KEY}:0 string 'balto'" "${PLIST}"
    fi
fi

UrlTypesKey="CFBundleURLTypes"
UrlSchemesKey="CFBundleURLSchemes"

exist=1
type=0
urlTypeCheck=$($PLIST_BUDDY -c "Print ${UrlTypesKey}" "${PLIST}")
if [ $? = 1 ]; then
    exist=0
    type=0
else
    urlTypeCheck=$($PLIST_BUDDY -c "Print ${UrlTypesKey}:0:${UrlSchemesKey}" "${PLIST}")
    if [ $? = 1 ]; then
        exist=0
        type=1
    fi
fi

if [ $exist = 0 ]; then
    if [ $type = 0 ]; then
        $PLIST_BUDDY -c "Add :${UrlTypesKey} array" "${PLIST}"
    fi
    len=12
    char='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
    char_len=${#char}
    i=0
    while [ $i -lt $len ]
    do
        start=$(( ($RANDOM % $char_len) ))
        str=${str}${char:${start}:1}
        i=$(( i+1 ))
    done

    $PLIST_BUDDY -c "Add :${UrlTypesKey}:0:${UrlSchemesKey} array" "${PLIST}"
    $PLIST_BUDDY -c "Add :${UrlTypesKey}:0:${UrlSchemesKey}:0 string ${str}" "${PLIST}"
fi