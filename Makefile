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

# properties
mysql_user=root
mysql_password=

VERSION=3.0.0
MODULES = clinicaltrials ttd drugbank

# commands

clean:
	-rm -r ./target/drug-trials
	-rm ./target/drug-trials*.tgz

purge:
	-rm -r ./target

init:
	-mkdir target

all: clean import convert package

package: $(MODULES)
	cp -r ./doc ./target/drug-trials
	cp ./README.md ./target/drug-trials/README
	cp ./LICENSE ./target/drug-trials/LICENSE
	tar -czvf ./target/drug-trials-${VERSION}.tgz --directory=./target drug-trials/

$(MODULES): init
	-mkdir ./target/drug-trials
	mysqldump --user=${mysql_user} --password=${mysql_password} --result-file=./target/drug-trials/$@.schema.sql --no-data --databases $@
	mysqldump --user=${mysql_user} --password=${mysql_password} --result-file=./target/drug-trials/$@.full.sql --complete-insert --single-transaction --databases $@

convert:
	cat ./sql/*.migrate.sql | mysql --user=${mysql_user} --password=${mysql_password}

import: target/emergentec
	cat ./target/emergentec/*.sql | mysql --user=${mysql_user} --password=${mysql_password}
	cat ./sql/move-emergentec.sql | mysql --user=${mysql_user} --password=${mysql_password}

target/emergentec: target/emergentec.tar.gz
	tar -xzvf ./target/emergentec.tar.gz --directory=./target

target/emergentec.tar.gz: init
	curl --fail --silent --output ./target/emergentec.tar.gz --url http://elvira.par.univie.ac.at/archiva/repository/internal/at/ac/univie/isc/emergentec-dataset/1.0.0/emergentec-dataset-1.0.0.tgz
