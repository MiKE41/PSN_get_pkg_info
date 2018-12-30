#!/bin/sh -e

## Set variables
unset PLATFORMS
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PSV"
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PSVx"
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PSM"
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PSP"
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PSPx"
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PSX"
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PS3"
PLATFORMS="${PLATFORMS:+${PLATFORMS} }PS4"

## Analyse packages
for PLATFORM in ${PLATFORMS}
 do
  PLATFORMDIR="${PLATFORM}"
  [ -d "${PLATFORMDIR}" ] || continue
  [ -d "${PLATFORMDIR}/_pkginfo" ] || mkdir "${PLATFORMDIR}/_pkginfo"
  #
  URLSFILE="${PLATFORMDIR}/_analysis_urls.txt"
  if [ 0 -eq 1 -a -s "${URLSFILE}" ]
   then
    ERRORLOG="${PLATFORMDIR}/_error_url.log"
    [ ! -s "${ERRORLOG}" ] || rm -v "${ERRORLOG}"
    #
    RUNDATE="$(date +'%Y-%m-%d %H:%M:%S')"
    echo "[${RUNDATE}] >>>>> Creating analysis data for ${PLATFORM} via URL..."
    for FILE in $(cat "${URLSFILE}")
     do
      [ -n "${FILE}" ] || continue
      ## additional echo to see currently processed file
      #echo "${FILE}"
      { PSN_get_pkg_info.py --itementries --unknown -f 99 -- "${FILE}" 3>&1 1>"${PLATFORMDIR}/_pkginfo/$(basename "${FILE}").out" 2>&3 | tee -a "${ERRORLOG}" ; } || :
    done
    [ ! -s "${ERRORLOG}" ] || sed -i -e "1 i[${RUNDATE}] >>>>> Errors during analysis for ${PLATFORM} via URL..." "${ERRORLOG}"
  fi
  #
  if [ 1 -eq 1 ]
   then
    ERRORLOG="${PLATFORMDIR}/_error.log"
    [ ! -s "${ERRORLOG}" ] || rm -v "${ERRORLOG}"
    #
    RUNDATE="$(date +'%Y-%m-%d %H:%M:%S')"
    echo "[${RUNDATE}] >>>>> Creating analysis data for ${PLATFORM} via package file..."
    ## additional -print to see currently processed file
    ## additional --raw ./decrypted.pkg --overwrite to find gaps
    export PLATFORMDIR
    export ERRORLOG
    { find "${PLATFORMDIR}" -type f -name '*.pkg' -exec sh -c 'PSN_get_pkg_info.py --itementries --unknown -f 99 -- "${1}" 3>&1 1>"${PLATFORMDIR}/_pkginfo/$(basename "${1}").out" 2>&3 | tee -a "${ERRORLOG}"' -- '{}' \; ; } || :
    [ ! -s "${ERRORLOG}" ] || sed -i -e "1 i[${RUNDATE}] >>>>> Errors during analysis for ${PLATFORM} via package file..." "${ERRORLOG}"
  fi
done