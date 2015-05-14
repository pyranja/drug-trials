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
# package drug-trials distribution
#---------------------------------------------------------------------------------------------------
set -ev

VERSION=${1:?"version argument missing"}
BUILD_DIR=${2:?"build directory argument missing"}

cp -r ./doc ./${BUILD_DIR}/drug-trials
cp ./README.md ./${BUILD_DIR}/drug-trials/README
cp ./LICENSE ./${BUILD_DIR}/drug-trials/LICENSE

tar -czf ./${BUILD_DIR}/drug-trials.tgz --directory=./${BUILD_DIR}/ drug-trials/

fpm --name 'drug-trials' --version "${VERSION}" --iteration '1' --description 'relational test data' \
  --maintainer 'chris.borckholder@gmail.com' --vendor 'Chris Borckholder' --license 'Apache License, Version 2' --url 'https://github.com/pyranja/drug-trials' \
  --architecture 'all' --rpm-auto-add-directories --force --package "./${BUILD_DIR}/drug-trials.rpm" \
  -C "${BUILD_DIR}/" -t 'rpm' -s 'dir' 'drug-trials/=/opt/'
