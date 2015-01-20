-- therapeutic targets database (ttd)
DROP DATABASE IF EXISTS `ttd`;
CREATE DATABASE `ttd` DEFAULT CHARACTER SET utf8;
USE `ttd`;

CREATE TABLE `ttd`.`status` (
  `id`   SMALLINT    NOT NULL,
  `name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`name`)
) ENGINE=InnoDB;

CREATE TABLE `ttd`.`drug` (
  `id`         INTEGER      NOT NULL,
  `designator` VARCHAR(11)  NOT NULL,
  `name`       VARCHAR(255) NOT NULL,
  `status_id`  SMALLINT     NOT NULL,
  `indication` VARCHAR(3000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`designator`),
  FOREIGN KEY (`status_id`) REFERENCES `status` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `ttd`.`alias` (
  `drug_id` INTEGER      NOT NULL,
  `value`   VARCHAR(255) NOT NULL,
  PRIMARY KEY (`drug_id`, `value`),
  FOREIGN KEY (`drug_id`) REFERENCES `drug` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `ttd`.`interaction` (
  `drug_id` INTEGER      NOT NULL,
  `target`  VARCHAR(150) NOT NULL,
  `action`  VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`drug_id`, `target`),
  FOREIGN KEY (`drug_id`) REFERENCES `drug` (`id`)
) ENGINE=InnoDB;

-- common static data
INSERT INTO `ttd`.`status` VALUES (1, 'approved'), (2, 'experimental'), (3, 'not-approved');

-- @formatter:off
-- parse group entries and match to status values
CREATE TABLE translate_group (
  status_id SMALLINT NOT NULL,
  group_id BIGINT NOT NULL,
  PRIMARY KEY (group_id)
) ENGINE=InnoDB;

INSERT INTO translate_group (status_id, group_id)
  SELECT 2 AS status_id, group_id
  FROM orig_ttd.`group`;
UPDATE translate_group INNER JOIN orig_ttd.`group` ON (translate_group.group_id = orig_ttd.`group`.group_id)
  SET status_id = 3
  WHERE `group` = 'FDA non-approvable letter' OR `group` LIKE 'No%' OR `group` LIKE 'Trial halted%'
      OR `group` LIKE 'Disco%' OR `group` LIKE 'Halted%' OR `group` LIKE 'Suspend%'
      OR `group` LIKE '%Terminated%' OR `group` LIKE 'Withdraw%' OR `group` LIKE '%Teminated%';
UPDATE translate_group INNER JOIN orig_ttd.`group` ON (translate_group.group_id = orig_ttd.`group`.group_id)
  SET status_id = 1
  WHERE `group` LIKE 'Approved%' OR `group` LIKE 'Launched' OR `group` LIKE 'Marketed'
      OR `group` LIKE 'Registered%';

-- migrate from ttd database
INSERT INTO ttd.drug (id, designator, name, status_id, indication)
  SELECT orig_ttd.drug.drug_id AS id, orig_ttd.drug_ttd_accession.accession, orig_ttd.drug.name,
    CASE
      WHEN EXISTS(SELECT 1 FROM ttd.translate_group INNER JOIN orig_ttd.drug_group ON ttd.translate_group.group_id = orig_ttd.drug_group.group_fid WHERE status_id = 3 AND drug_fid = id) THEN 3
      WHEN EXISTS(SELECT 1 FROM ttd.translate_group INNER JOIN orig_ttd.drug_group ON ttd.translate_group.group_id = orig_ttd.drug_group.group_fid WHERE status_id = 1 AND drug_fid = id) THEN 1
      ELSE 2
    END AS status_id,
    indication.text
  FROM orig_ttd.drug
    INNER JOIN orig_ttd.drug_ttd_accession ON (orig_ttd.drug_ttd_accession.drug_fid = orig_ttd.drug.drug_id)
    LEFT JOIN (SELECT drug_fid, GROUP_CONCAT(indication) AS text
                FROM orig_ttd.drug_indication INNER JOIN orig_ttd.indication ON (orig_ttd.drug_indication.indication_fid = orig_ttd.indication.indication_id)
                GROUP BY drug_fid) AS indication ON (orig_ttd.drug.drug_id = indication.drug_fid)
;

INSERT INTO ttd.alias (drug_id, value)
    SELECT DISTINCT drug_fid, synonym FROM orig_ttd.drug_synonym WHERE synonym IS NOT NULL AND LENGTH(synonym) <= 255;

INSERT INTO ttd.interaction (drug_id, target, action)
  SELECT orig_ttd.drug_target.drug_fid, orig_ttd.target.name, MIN(dta.action)
  FROM orig_ttd.drug_target
    INNER JOIN orig_ttd.target ON (orig_ttd.drug_target.target_fid = orig_ttd.target.target_id)
    LEFT JOIN (SELECT drug_fid, target_fid, SUBSTRING_INDEX(GROUP_CONCAT(action), ',', 1) AS action FROM orig_ttd.drug_target_action GROUP BY drug_fid, target_fid) dta
      ON (orig_ttd.drug_target.target_fid = dta.drug_fid AND orig_ttd.drug_target.target_fid = dta.target_fid)
  GROUP BY orig_ttd.drug_target.drug_fid, orig_ttd.target.name
  ;

DROP TABLE IF EXISTS translate_group;
