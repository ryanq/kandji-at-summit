#!/usr/bin/env zsh

autoload zmathfunc
zmathfunc

###################################################################################################
# Created by Ryan Quattlebaum | ryanq@summitchurch.com | The Summit Church
###################################################################################################
#
#   Created on 2022-08-16 - Ryan Quattlebaum
#
###################################################################################################
# Tested macOS Versions
###################################################################################################
#
#   - 12.3.1
#   - 12.5
#
###################################################################################################
# Software Information
###################################################################################################
#
#   This script checks that a minimum version of an application is installed. It returns an error
#   code if the application is not installed or if the installed version is earlier than the minimum
#   version to signal that Kandji should download and install the currently enforced version.
#
###################################################################################################
# CHANGELOG
###################################################################################################
#
#   1.0.0 - Initial version. This is a generalization of a script used for specific applications.
#
###################################################################################################

# Script version
VERSION="1.0.0"

###################################################################################################
###################################### VARIABLES ##################################################
###################################################################################################

APPLICATION="/Applications/ProPresenter.app"
INFO_PLIST_RELATIVE_PATH="Contents/Info.plist"
TARGET_VERSION="7.9.2"

INFO_PLIST="$APPLICATION/$INFO_PLIST_RELATIVE_PATH"

###################################################################################################
###################################### FUNCTIONS ##################################################
###################################################################################################

check_application_installed() {
  # Check whether an application is installed.
  # $1: application path

  local APPLICATION=$1

  echo -n "Checking application is installed..."

  if [[ -e "$APPLICATION" ]]; then
    echo "returning success: $APPLICATION is present"
    return 0
  else
    echo "returning error: $APPLICATION is missing"
    return 1
  fi
}

check_application_version() {
  # Check whether an application's version is less than the specified version.
  # $1: path to application's Info.plist
  # $2: target version string (e.g. "7.8.4")

  local INFO_PLIST=$1
  local TARGET_VERSION=$2
  local VERSION_KEY="CFBundleShortVersionString"

  echo -n "Checking installed version is at least $TARGET_VERSION..."

  local OUTPUT=$(plutil -extract $VERSION_KEY raw -expect string $INFO_PLIST 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo -n "returning error: unable to extract version string: "
  
    if [[ ! -e "$INFO_PLIST" ]]; then
      echo "'$INFO_PLIST' does not exist"
      return 1
    fi

    if [[ "$OUTPUT" =~ "No value at that key path or invalid key path" ]]; then
      echo "Invalid key path $VERSION_KEY"
      return 1
    fi

    if [[ "$OUTPUT" =~ "expected to be a string but is a" ]]; then
      echo "Value is not a string"
      return 1
    fi
  fi
  local INSTALLED_VERSION=$OUTPUT

  TARGET_VERSION=(${(s[.])TARGET_VERSION})
  INSTALLED_VERSION=(${(s[.])INSTALLED_VERSION})

  local COUNT=$(( min(${#TARGET_VERSION}, ${#INSTALLED_VERSION}) ))
  for I in $(seq $COUNT); do
    local TARGET=${TARGET_VERSION[$I]}
    local INSTALLED=${INSTALLED_VERSION[$I]}

    if [[ "$TARGET" -gt "$INSTALLED" ]]; then
      echo "returning error: Target version is later than installed version; install needed"
      return 1
    elif [[ "$TARGET" -lt "$INSTALLED" ]]; then
      echo "returning success: Installed version is later than target version"
      return 0
    fi
  done

  if [[ "${#TARGET_VERSION}" -gt "${#INSTALLED_VERSION}" ]]; then
    echo "returning error: Target version is later than installed version; install needed"
    return 1
  elif [[ "${#TARGET_VERSION}" -lt "${#INSTALLED_VERSION}" ]]; then
    echo "returning success: Installed version is later than target version"
    return 0
  else
    echo "returning success: Installed version is equal to target version"
    return 0
  fi
}

###################################################################################################
###################################### MAIN LOGIC #################################################
###################################################################################################

check_application_installed $APPLICATION \
 && check_application_version $INFO_PLIST $TARGET_VERSION

exit $?