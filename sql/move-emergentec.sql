-- move original emergentec schemas

DROP DATABASE IF EXISTS `orig_drugbank`;
CREATE DATABASE IF NOT EXISTS `orig_drugbank`;

RENAME TABLE `drugbank`.`category` TO `orig_drugbank`.`category`;
RENAME TABLE `drugbank`.`drug` TO `orig_drugbank`.`drug`;
RENAME TABLE `drugbank`.`drug_brand` TO `orig_drugbank`.`drug_brand`;
RENAME TABLE `drugbank`.`drug_category` TO `orig_drugbank`.`drug_category`;
RENAME TABLE `drugbank`.`drug_drugbank_accession` TO `orig_drugbank`.`drug_drugbank_accession`;
RENAME TABLE `drugbank`.`drug_group` TO `orig_drugbank`.`drug_group`;
RENAME TABLE `drugbank`.`drug_mixture` TO `orig_drugbank`.`drug_mixture`;
RENAME TABLE `drugbank`.`drug_synonym` TO `orig_drugbank`.`drug_synonym`;
RENAME TABLE `drugbank`.`drug_target` TO `orig_drugbank`.`drug_target`;
RENAME TABLE `drugbank`.`drug_target_action` TO `orig_drugbank`.`drug_target_action`;
RENAME TABLE `drugbank`.`gene` TO `orig_drugbank`.`gene`;
RENAME TABLE `drugbank`.`group` TO `orig_drugbank`.`group`;
RENAME TABLE `drugbank`.`type` TO `orig_drugbank`.`type`;

DROP DATABASE IF EXISTS `orig_ttd`;
CREATE DATABASE IF NOT EXISTS `orig_ttd`;

RENAME TABLE `ttd`.`drug` TO `orig_ttd`.`drug`;
RENAME TABLE `ttd`.`drug_group` TO `orig_ttd`.`drug_group`;
RENAME TABLE `ttd`.`drug_indication` TO `orig_ttd`.`drug_indication`;
RENAME TABLE `ttd`.`drug_synonym` TO `orig_ttd`.`drug_synonym`;
RENAME TABLE `ttd`.`drug_target` TO `orig_ttd`.`drug_target`;
RENAME TABLE `ttd`.`drug_target_action` TO `orig_ttd`.`drug_target_action`;
RENAME TABLE `ttd`.`drug_ttd_accession` TO `orig_ttd`.`drug_ttd_accession`;
RENAME TABLE `ttd`.`group` TO `orig_ttd`.`group`;
RENAME TABLE `ttd`.`indication` TO `orig_ttd`.`indication`;
RENAME TABLE `ttd`.`target` TO `orig_ttd`.`target`;
RENAME TABLE `ttd`.`target_synonym` TO `orig_ttd`.`target_synonym`;
