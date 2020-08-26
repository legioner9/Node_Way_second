CREATE DATABASE `shop` /*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
CREATE TABLE `category` (
  `id_category` int NOT NULL,
  `category_name` varchar(128) NOT NULL,
  `category_discount` tinyint NOT NULL,
  `category_alias_name_eng` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
