#!/usr/bin/env bash

# Create directory structure for svn to git migration on my localhost.
#
# <ROOT_PATH>git-migration
# |-- clones
# |-- fetchers
# |-- mirrors
# |-- tools
#     |-- bin
#     |-- lib

ROOT_DIR=`pwd`
if [ -d "$1" ]; then
  ROOT_DIR=${1%/}
fi

echo "Using [${ROOT_DIR}] as root directory for migration folders"

BASE_DIR=git-migration
BASE_PATH="${ROOT_DIR}/${BASE_DIR}"
TOOLS_DIR=tools
BASE_CHILDREN=(clones fetchers mirrors $TOOLS_DIR)

echo "Creating $BASE_PATH"
`mkdir -p ${BASE_PATH}`

for child in "${BASE_CHILDREN[@]}"
do
  dir="${BASE_PATH}/${child}"
  echo "Creating ${dir}"
  `mkdir -p ${dir}`
done

TOOLS_CHILDREN=(bin lib)
for child in "${TOOLS_CHILDREN[@]}"
do
  dir="${BASE_PATH}/${TOOLS_DIR}/${child}"
  echo "Creating ${dir}"
  `mkdir -p ${dir}`
done

echo "Done"
