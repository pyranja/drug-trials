# drug-trial dataset

# properties
mysql_user=root
mysql_password=

# commands

clean:
	-rm -r ./target

init:
	-mkdir target

all: clean import convert package

package: clinicaltrials ttd drugbank
	tar -czvf ./target/drug-trials.tgz --directory=./target drug-trials/

clinicaltrials ttd drugbank: init
	-mkdir ./target/drug-trials
	mysqldump --user=${mysql_user} --password=${mysql_password} --result-file=./target/drug-trials/$@-schema.sql --no-data --databases $@
	mysqldump --user=${mysql_user} --password=${mysql_password} --result-file=./target/drug-trials/$@.sql --complete-insert --single-transaction --databases $@

convert:
	cat ./sql/*.migrate.sql | mysql --user=${mysql_user} --password=${mysql_password}

import: target/emergentec
	cat ./target/emergentec/*.sql | mysql --user=${mysql_user} --password=${mysql_password}
	cat ./sql/move-emergentec.sql | mysql --user=${mysql_user} --password=${mysql_password}

target/emergentec: target/emergentec.tar.gz
	tar -xzvf ./target/emergentec.tar.gz --directory=./target

target/emergentec.tar.gz: init
	curl --fail --silent --output ./target/emergentec.tar.gz --url http://elvira.par.univie.ac.at/archiva/repository/internal/at/ac/univie/isc/emergentec-dataset/1.0.0/emergentec-dataset-1.0.0.tgz
