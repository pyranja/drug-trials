#!/bin/bash

# Copyright 2015 Chris Borckholder
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#---------------------------------------------------------------------------------------------------
# publish to bintray from travis build
#---------------------------------------------------------------------------------------------------
set -ev

# default to revision tag provided by travis
VERSION=${1:-${TRAVIS_TAG:?'no travis tag found and no explicit version given'}}

: ${BUILD_DIR:='target'}
RPM_PATH="./${BUILD_DIR}/drug-trials.rpm"
TAR_PATH="./${BUILD_DIR}/drug-trials.tgz"

API='https://api.bintray.com/'

: ${BINTRAY_USER:='pyranja'}
: ${BINTRAY_API_KEY:?'bintray api key missing'}

BINTRAY_PACKAGE='drug-trials'

CURL="curl -u ${BINTRAY_USER}:${BINTRAY_API_KEY} -H Content-Type:application/json -H Accept:application/json --write-out %{http_code} --output /dev/stderr --silent --show-error"

[[ $(${CURL} -T "${RPM_PATH}" "${API}/content/${BINTRAY_USER}/rpm/${BINTRAY_PACKAGE}/${VERSION}/drug-trials-${VERSION}.rpm?publish=1&override=0") -eq 201 ]] \
&& [[ $(${CURL} -T "${TAR_PATH}" "${API}/content/${BINTRAY_USER}/generic/${BINTRAY_PACKAGE}/${VERSION}/drug-trials-${VERSION}.tgz?publish=1&override=0") -eq 201 ]] \
&& echo "pyranja:drug-trials:${VERSION} tarball and rpm deployed successfully"
