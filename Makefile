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

mysql_user=root
mysql_password=

VERSION = SNAPSHOT

MODULES = clinicaltrials ttd drugbank
SOURCE_DIR = source
BUILD_DIR = target

## package distributions ##

assembly: convert $(MODULES)
	./assembly.sh "$(VERSION)" "$(BUILD_DIR)"

$(MODULES): %: $(BUILD_DIR)/drug-trials/%.schema.sql $(BUILD_DIR)/drug-trials/%.full.sql

$(BUILD_DIR)/drug-trials/%.schema.sql: $(BUILD_DIR)/drug-trials/
	mysqldump --user=${mysql_user} --password=${mysql_password} --result-file=$@ --no-data --databases $*

$(BUILD_DIR)/drug-trials/%.full.sql: $(BUILD_DIR)/drug-trials/
	mysqldump --user=${mysql_user} --password=${mysql_password} --result-file=$@ --complete-insert --single-transaction --databases $*

$(BUILD_DIR)/drug-trials/:
	@-mkdir -p $@

clean:
	@-rm -r ./$(BUILD_DIR)

.PHONY: assembly $(MODULES) clean

## apply conversion ##

convert: import ${SOURCE_DIR}/.convert

${SOURCE_DIR}/.convert: ./sql/*.migrate.sql
	cat ./sql/*.migrate.sql | mysql --user=${mysql_user} --password=${mysql_password}
	@touch $@

.PHONY: convert

## import source schema ##

import: $(SOURCE_DIR)/.import

$(SOURCE_DIR)/.import: $(SOURCE_DIR)/emergentec.tar.gz
	tar -xzf ./$(SOURCE_DIR)/emergentec.tar.gz --directory=./$(SOURCE_DIR)
	cat ./$(SOURCE_DIR)/emergentec/*.sql | mysql --user=${mysql_user} --password=${mysql_password}
	cat ./sql/move-emergentec.sql | mysql --user=${mysql_user} --password=${mysql_password}
	@touch $@

$(SOURCE_DIR)/emergentec.tar.gz:
	@-mkdir $(SOURCE_DIR)
	curl --fail --silent --output ./$(SOURCE_DIR)/emergentec.tar.gz --url http://elvira.par.univie.ac.at/archiva/repository/internal/at/ac/univie/isc/emergentec-dataset/1.0.0/emergentec-dataset-1.0.0.tgz

purge: clean
	@-rm -r ./$(SOURCE_DIR)

.PHONY: import purge
