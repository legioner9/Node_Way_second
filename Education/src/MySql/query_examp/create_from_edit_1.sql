
CREATE SCHEMA `shop` DEFAULT CHARACTER SET utf8;
CREATE SCHEMA `st_schema`;
DROP DATABASE `st_schema`;

CREATE TABLE `shop`.`category` (
  `id_category` INT NOT NULL,
  `category_col` VARCHAR(128) NOT NULL,
  `category_discount` TINYINT NOT NULL,
  PRIMARY KEY (`id_category`));
  
  ALTER TABLE `shop`.`category` 
ADD COLUMN `category_alias_name_eng` VARCHAR(128) NULL AFTER `category_discount`,
CHANGE COLUMN `category_col` `category_name` VARCHAR(128) NOT NULL;

CREATE TABLE `shop`.`brend` (
  `id_brend` INT NOT NULL,
  `brend_name` VARCHAR(128) NOT NULL,
  PRIMARY KEY (`id_brend`));

CREATE TABLE `shop`.`prodtype` (
  `id_prodType` INT NOT NULL,
  `prodType_name` VARCHAR(128) NOT NULL,
  PRIMARY KEY (`id_prodType`));

INSERT INTO `shop`.`category` (`id_category`,`category_name`,`category_discount`,`category_alias_name_eng`) VALUES (1,'женск',3,'fem');
INSERT INTO `shop`.`category` (`id_category`,`category_name`,`category_discount`,`category_alias_name_eng`) VALUES (2,'мужск',6,'men');
insert into `shop`.`category` (`id_category`,`category_name`,`category_discount`,`category_alias_name_eng`) VALUES (3,'детск',7,'chaild');

ALTER TABLE `shop`.`category` 
CHANGE COLUMN `id_category` `id_category` INT NOT NULL AUTO_INCREMENT ;

insert into `shop`.`category` (`category_name`,`category_discount`) VALUES ('панамки',0);

ALTER TABLE `shop`.`brend` 
CHANGE COLUMN `id_brend` `id_brend` INT NOT NULL AUTO_INCREMENT ;

INSERT INTO `shop`.`brend` (`id_brend`, `brend_name`) VALUES ('1', 'Gooch');
INSERT INTO `shop`.`brend` (`brend_name`) VALUES ('Jerry');
insert into `shop`.`brend` (`brend_name`) values ('Montana');

ALTER TABLE `shop`.`prodtype` 
CHANGE COLUMN `id_prodtype` `id_prodtype` INT NOT NULL AUTO_INCREMENT ;

INSERT INTO `shop`.`prodtype` (`prodType_name`) VALUES ('носок');
INSERT INTO `shop`.`prodtype` (`prodType_name`) VALUES ('платье');
INSERT INTO `shop`.`prodtype` (`prodType_name`) VALUES ('брюки');
insert into `shop`.`prodtype` (`prodType_name`) values ('плавки');



