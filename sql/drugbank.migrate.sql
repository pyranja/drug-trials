/*
* Copyright 2015 Chris Borckholder
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

-- drugbank.ca database
DROP DATABASE IF EXISTS `drugbank`;
CREATE DATABASE `drugbank` DEFAULT CHARACTER SET utf8;
USE `drugbank`;

CREATE TABLE `drugbank`.`status` (
  `id`   SMALLINT    NOT NULL,
  `name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`name`)
) ENGINE=InnoDB;

CREATE TABLE `drugbank`.`drug` (
  `id`         INTEGER      NOT NULL,
  `designator`  VARCHAR(11)  NOT NULL,
  `name`        VARCHAR(255) NOT NULL,
  `type`        VARCHAR(50)  NOT NULL,
  `category`    VARCHAR(100)  DEFAULT NULL,
  `status_id`   SMALLINT     NOT NULL,
  `description` VARCHAR(3000) DEFAULT NULL,
  `indication`  VARCHAR(3000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`designator`),
  FOREIGN KEY (`status_id`) REFERENCES `status` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `drugbank`.`alias_type` (
  `id`   SMALLINT    NOT NULL,
  `name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`name`)
) ENGINE=InnoDB;

CREATE TABLE `drugbank`.`alias` (
  `drug_id` INTEGER      NOT NULL,
  `type_id` SMALLINT     NOT NULL,
  `value`   VARCHAR(255) NOT NULL,
  PRIMARY KEY (`drug_id`, `type_id`, `value`),
  FOREIGN KEY (`drug_id`) REFERENCES drug (`id`),
  FOREIGN KEY (`type_id`) REFERENCES alias_type (`id`)
) ENGINE=InnoDB;

CREATE TABLE `drugbank`.`interaction` (
  `drug_id`            INTEGER      NOT NULL,
  `gene_symbol`        VARCHAR(150) NOT NULL,
  `gene_taxonomy`      INT          NOT NULL,
  `action`             VARCHAR(100) DEFAULT NULL,
  `is_pharmacological` BOOLEAN      DEFAULT NULL,
  PRIMARY KEY (`drug_id`, `gene_symbol`, `gene_taxonomy`),
  FOREIGN KEY (`drug_id`) REFERENCES `drug` (`id`)
) ENGINE=InnoDB;

-- common static data
INSERT INTO `drugbank`.`status`
VALUES (1, 'approved'), (2, 'experimental'), (3, 'not-approved');
INSERT INTO `drugbank`.`alias_type` VALUES (1, 'synonym'), (2, 'brand'), (3, 'mixture');

-- @formatter:off
-- migrate from drugbank database
INSERT INTO drugbank.drug (id, designator, name, type, category, status_id, description, indication)
  SELECT d.drug_id, acc.accession, d.name, t.type, categories.category, status.status_id, d.description, d.indication
  FROM orig_drugbank.drug AS d
    INNER JOIN orig_drugbank.drug_drugbank_accession AS acc ON (d.drug_id = acc.drug_fid)
    INNER JOIN orig_drugbank.type AS t ON (d.type_fid = t.type_id)
    LEFT JOIN (SELECT drug_fid, MIN(category) AS category
               FROM orig_drugbank.drug_category INNER JOIN orig_drugbank.category ON (orig_drugbank.drug_category.category_fid = orig_drugbank.category.category_id)
               GROUP BY drug_fid) AS categories
      ON (categories.drug_fid = d.drug_id)
    INNER JOIN (SELECT g.drug_id,
                  CASE
                    WHEN g.groups LIKE '%illicit%' OR g.groups LIKE '%withdrawn%' THEN (SELECT id FROM drugbank.status WHERE name = 'not-approved')
                    WHEN g.groups LIKE '%approved%' THEN (SELECT id FROM drugbank.status WHERE name = 'approved')
                    WHEN g.groups LIKE '%experimental%' THEN (SELECT id FROM drugbank.status WHERE name = 'experimental')
                    ELSE (SELECT id FROM drugbank.status WHERE name = 'not-approved')
                  END AS status_id
                FROM (SELECT drug_id, GROUP_CONCAT(`group`.`group`) AS groups
                      FROM orig_drugbank.drug
                        LEFT JOIN orig_drugbank.drug_group ON (drug_id = drug_group.drug_fid)
                        LEFT JOIN orig_drugbank.`group` ON (group_fid = `group`.group_id)
                      GROUP BY drug_id) AS g) AS status
      ON (d.drug_id = status.drug_id)
;

INSERT INTO drugbank.alias (drug_id, value, type_id)
  (SELECT drug_fid AS drug_id, synonym AS value, (SELECT id FROM drugbank.alias_type WHERE name = 'synonym') AS type_id FROM orig_drugbank.drug_synonym)
  UNION (SELECT drug_fid AS drug_id, brand AS value, (SELECT id FROM drugbank.alias_type WHERE name = 'brand') AS type_id FROM orig_drugbank.drug_brand)
  UNION (SELECT drug_fid AS drug_id, name AS value, (SELECT id FROM drugbank.alias_type WHERE name = 'mixture') AS type_id FROM orig_drugbank.drug_mixture);

INSERT INTO drugbank.interaction (drug_id, gene_symbol, gene_taxonomy, action, is_pharmacological)
  SELECT DISTINCT dt.drug_fid, gene.symbol, gene.taxon_id, dta.action, CASE dt.pharmacological_action WHEN 'yes' THEN 1 WHEN 'no' THEN 0 ELSE NULL END
FROM orig_drugbank.drug_target AS dt
  INNER JOIN (SELECT MIN(gene_id) AS gene_id, symbol, taxon_id FROM orig_drugbank.gene GROUP BY symbol, taxon_id) AS gene
    ON (dt.gene_fid = gene.gene_id AND gene.symbol IS NOT NULL AND gene.taxon_id IS NOT NULL)
  LEFT JOIN (SELECT drug_fid, gene_fid, SUBSTRING_INDEX(GROUP_CONCAT(action), ',', 1) AS action FROM orig_drugbank.drug_target_action GROUP BY drug_fid, gene_fid) dta
    ON (dt.drug_fid = dta.drug_fid AND dt.gene_fid = dta.gene_fid);
