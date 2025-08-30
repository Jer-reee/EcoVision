#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (indicating success) and let the script handle the
  # failure.
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

# Use a temporary file in /tmp to avoid sandbox restrictions
RESOURCES_TO_COPY=/tmp/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

# Try to copy the bundle files using cp instead of rsync to avoid sandbox issues
if [ -d "${BUILT_PRODUCTS_DIR}/GoogleMaps/GoogleMapsResources.bundle" ]; then
  echo "Copying GoogleMapsResources.bundle using cp"
  cp -R "${BUILT_PRODUCTS_DIR}/GoogleMaps/GoogleMapsResources.bundle" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/" || echo "Warning: Failed to copy GoogleMapsResources.bundle"
fi

if [ -d "${BUILT_PRODUCTS_DIR}/GooglePlaces/GooglePlacesResources.bundle" ]; then
  echo "Copying GooglePlacesResources.bundle using cp"
  cp -R "${BUILT_PRODUCTS_DIR}/GooglePlaces/GooglePlacesResources.bundle" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/" || echo "Warning: Failed to copy GooglePlacesResources.bundle"
fi

# Copy any other resources
if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of other pods, but that's how Xcode works)
  find "$PWD" -name "*.xcassets" \( -not -path "$PODS_ROOT/*" -and -not -path "$PODS_CONFIGURATION_BUILD_DIR/*" \) -print0 | while read -d $'\0' xcasset_file
  do
    if [[ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]] && [[ "${CODE_SIGNING_REQUIRED:-}" != "NO" ]] && [[ "${CODE_SIGNING_ALLOWED}" != "NO" ]]; then
      echo "xcrun actool --output-format human-readable-text --notices --warnings --platform \"${PLATFORM_NAME}\" --minimum-deployment-target \"${!DEPLOYMENT_TARGET_SETTING_NAME}\" ${TARGET_DEVICE_ARGS} ${DEPLOYMENT_TARGET_SETTING} --output-format human-readable-text --compile \"${BUILT_PRODUCTS_DIR}\" \"${xcasset_file}\" ${XCASSET_FILES[@]}"
      xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} ${DEPLOYMENT_TARGET_SETTING} --output-format human-readable-text --compile "${BUILT_PRODUCTS_DIR}" "${xcasset_file}" ${XCASSET_FILES[@]}
    else
      echo "xcrun actool --output-format human-readable-text --notices --warnings --platform \"${PLATFORM_NAME}\" --minimum-deployment-target \"${!DEPLOYMENT_TARGET_SETTING_NAME}\" ${TARGET_DEVICE_ARGS} ${DEPLOYMENT_TARGET_SETTING} --output-format human-readable-text --compile \"${BUILT_PRODUCTS_DIR}\" \"${xcasset_file}\" ${XCASSET_FILES[@]}"
      xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} ${DEPLOYMENT_TARGET_SETTING} --output-format human-readable-text --compile "${BUILT_PRODUCTS_DIR}" "${xcasset_file}" ${XCASSET_FILES[@]}
    fi
  done
fi

# Clean up temporary file
rm -f "$RESOURCES_TO_COPY"
