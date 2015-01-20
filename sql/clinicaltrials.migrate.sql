-- clinicaltrials.gov database
DROP DATABASE IF EXISTS `clinicaltrials`;
CREATE DATABASE `clinicaltrials` DEFAULT CHARACTER SET utf8;
USE `clinicaltrials`;

-- define schema
CREATE TABLE `clinicaltrials`.`trial` (
  `id`             INTEGER      NOT NULL,
  `designator`     VARCHAR(11)  NOT NULL,
  `title`          VARCHAR(300) NOT NULL,
  `official_title` VARCHAR(600),
  `summary`        TEXT,
  `start_date`     DATE,
  `end_date`       DATE,
  `sponsor`        VARCHAR(150) NOT NULL,
  `type`           VARCHAR(25)  NOT NULL,
  `status`         VARCHAR(25)  NOT NULL,
  `phase`          VARCHAR(25)  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`designator`)
);

CREATE TABLE `clinicaltrials`.`trial_drug` (
  `trial_id`        INTEGER NOT NULL,
  `drug_designator` VARCHAR(11),
  PRIMARY KEY (`trial_id`, `drug_designator`),
  FOREIGN KEY (`trial_id`) REFERENCES `trial` (`id`)
);

CREATE TABLE `clinicaltrials`.`condition` (
  `id`   INTEGER      NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `clinicaltrials`.`trial_condition`
(
  `trial_id`     INTEGER NOT NULL,
  `condition_id` INTEGER NOT NULL,
  PRIMARY KEY (`trial_id`, `condition_id`),
  FOREIGN KEY (`trial_id`) REFERENCES `trial` (`id`),
  FOREIGN KEY (`condition_id`) REFERENCES `condition` (`id`)
);

CREATE TABLE `clinicaltrials`.`intervention` (
  `id`   INTEGER      NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `type` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `clinicaltrials`.`trial_intervention` (
  `trial_id`        INTEGER NOT NULL,
  `intervention_id` INTEGER NOT NULL,
  PRIMARY KEY (`trial_id`, `intervention_id`),
  FOREIGN KEY (`trial_id`) REFERENCES `trial` (`id`),
  FOREIGN KEY (`intervention_id`) REFERENCES `intervention` (`id`)
);

-- migrate from trials database
INSERT INTO clinicaltrials.trial (id, designator, title, official_title, summary, start_date, end_date, sponsor, type, status, phase)
  SELECT study_id, clinicaltrials_gov_id, title, official_title, summary, start_date, end_date,
    sponsor_name, type, `status`, `phase`
  FROM trials.study
    INNER JOIN trials.clinicaltrials_gov
      ON (trials.study.study_id = trials.clinicaltrials_gov.study_fid)
    INNER JOIN trials.sponsor ON (trials.study.sponsor_fid = trials.sponsor.sponsor_id)
    INNER JOIN trials.type ON (trials.study.type_fid = trials.type.type_id)
    INNER JOIN trials.status ON (trials.study.status_fid = trials.status.status_id)
    INNER JOIN trials.phase ON (trials.study.phase_fid = trials.phase.phase_id);

INSERT INTO clinicaltrials.`condition` (id, name)
  SELECT condition_id, `condition`
  FROM trials.`condition`;

INSERT INTO clinicaltrials.trial_condition (trial_id, condition_id)
  SELECT study_fid, condition_fid FROM trials.study_condition;

INSERT INTO clinicaltrials.intervention (id, name, type)
  SELECT intervention_id, `name`, intervention_type
  FROM trials.intervention INNER JOIN trials.intervention_type ON (trials.intervention.intervention_type_fid = trials.intervention_type.intervention_type_id);

INSERT INTO clinicaltrials.trial_intervention (trial_id, intervention_id)
  SELECT study_fid, intervention_fid FROM trials.study_intervention;

INSERT INTO clinicaltrials.trial_drug (trial_id, drug_designator)
  SELECT DISTINCT study_fid, drug_id
  FROM trials.intervention_to_drug INNER JOIN trials.study_intervention ON (trials.intervention_to_drug.intervention_id = trials.study_intervention.intervention_fid);
