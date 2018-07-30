#!/bin/bash
# This script requires jq and pup

# Constants
export readonly MODEL_S_DESIGN_URL="https://www.tesla.com/models/design"
export readonly MODELS_OPTIONS_FILE="models-options.md"
export readonly MODELS_TITLE="Model S Options"

export readonly MODEL_X_DESIGN_URL="https://www.tesla.com/modelx/design"
export readonly MODELX_OPTIONS_FILE="modelx-options.md"
export readonly MODELX_TITLE="Model X Options"

export readonly TEMP_FILE="temp.html"

###############################################################################
# Create options markdown for vehicle type
# Arguments:
#   ${1} - the design url to pull options from
#   ${2} - the markdown file output that will be written in the options dir
# Returns:
#   None
###############################################################################
get_options() {
  if [ -z "${1}" ]; then
    echo "No Design URL"
    exit 0
  fi
  
  if [ -z "${2}" ]; then
    echo "No Output File"
    exit 0
  fi

  if [ -z "${3}" ]; then
    echo "No Title"
    exit 0
  fi

  designURL="${1}"
  optionsFile="${2}"
  title="${3}"

  pushd .. 2>/dev/null
  pushd codes 2>/dev/null

  wget -q ${designURL} -O ${TEMP_FILE} >/dev/null 2>/dev/null

  DESIGN_URLS=`cat ${TEMP_FILE} | pup 'link[hreflang] attr{href}'`

  echo "# ${title}" > ${optionsFile}
  echo $'\n' >> ${optionsFile}
  for DESIGN_URL in $DESIGN_URLS
  do
    wget -q $DESIGN_URL -O ${TEMP_FILE} >/dev/null 2>/dev/null
    JQUERY=`grep "jQuery.extend" ${TEMP_FILE}`
    SIZE=`expr ${#JQUERY} - 33`
    JSON_STRING=`echo ${JQUERY:31:${SIZE}}`

    echo $"### ${DESIGN_URL}" >> ${optionsFile}
    echo $'\n' >> ${optionsFile}
    echo $'```javascript' >> ${optionsFile}
    echo $JSON_STRING | jq '.tesla.configSetPrices | fromjson.options | with_entries(.value |= .long_name) | del(.[] | nulls)' >> ${optionsFile}
    echo $'\n```\n\n' >> ${optionsFile}
  done

  rm ${TEMP_FILE}

  popd 2>/dev/null
  popd 2>/dev/null
}


###############################################################################
# Geneartes option code lists for the Model S and Model X
# Arguments:
#   None
# Returns:
#   None
###############################################################################
main() {
  get_options "${MODEL_S_DESIGN_URL}" "${MODELS_OPTIONS_FILE}" "${MODELS_TITLE}"
  get_options "${MODEL_X_DESIGN_URL}" "${MODELX_OPTIONS_FILE}" "${MODELX_TITLE}"

}

main