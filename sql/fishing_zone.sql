-- MySQL dump 10.16  Distrib 10.1.38-MariaDB, for Win32 (AMD64)
--
-- Host: localhost    Database: dspdb
-- ------------------------------------------------------
-- Server version    10.1.38-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `fishing_zone`
--

DROP TABLE IF EXISTS `fishing_zone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fishing_zone` (
  `zoneid` smallint(5) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  `difficulty` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`zoneid`)
) ENGINE=Aria TRANSACTIONAL=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fishing_zone`
--

LOCK TABLES `fishing_zone` WRITE;
/*!40000 ALTER TABLE `fishing_zone` DISABLE KEYS */;

-- SINCE THE TABLE IS DROPPED AND RE-CREATED EVERY TIME, THERE WILL NEVER BE ANY "UPDATES" done but leave the merge pattern
    -- WITH DDL Sync
        -- If you implement a way to handle syncing DDL changes to the table(s) then 
        -- the script could be fully incremental and even faster
        -- as you don't need to drop the table at all and wouldn't need to re-insert every row
    
    -- WITHOUT DDL Sync
        -- Without adding extra steps OR scripts to deal with DDL sync's / changes
        -- we will leave the "drop/create" pattern and 
        -- adjust to the "multi value insert & merge" statement pattern.
        -- In addition, we will batch the inserts to attempt to handle
        -- "max_allowed_packet" Database setting & overflow potential
            -- if this overflow occurs you will receive an error like:
                -- ER_NET_PACKET_TOO_LARGE 
                -- or 
                -- "Lost connection to MySQL server during query".
            -- If this happens, you can structure the inserts to have "less" VALUES() and more batches etc....

insert into `fishing_zone`
(
    `zoneid`, `name`, `difficulty`
)
VALUES
    (0,'unknown',0),
    (1,'Phanauet_Channel',0),
    (2,'Carpenters_Landing',0),
    (3,'Manaclipper',0),
    (4,'Bibiki_Bay',0),
    (5,'Uleguerand_Range',0),
    (6,'Bearclaw_Pinnacle',0),
    (7,'Attohwa_Chasm',0),
    (8,'Boneyard_Gully',0),
    (9,'PsoXja',0),
    (10,'The_Shrouded_Maw',0),
    (11,'Oldton_Movalpolos',2),
    (12,'Newton_Movalpolos',0),
    (13,'Mine_Shaft_2716',0),
    (14,'Hall_of_Transference',0),
    (15,'Abyssea-Konschtat',0),
    (16,'Promyvion-Holla',0),
    (17,'Spire_of_Holla',0),
    (18,'Promyvion-Dem',0),
    (19,'Spire_of_Dem',0),
    (20,'Promyvion-Mea',0),
    (21,'Spire_of_Mea',0),
    (22,'Promyvion-Vahzl',0),
    (23,'Spire_of_Vahzl',0),
    (24,'Lufaise_Meadows',0),
    (25,'Misareaux_Coast',0),
    (26,'Tavnazian_Safehold',0),
    (27,'Phomiuna_Aqueducts',0),
    (28,'Sacrarium',0),
    (29,'Riverne-Site_B01',0),
    (30,'Riverne-Site_A01',0),
    (31,'Monarch_Linn',0),
    (32,'Sealions_Den',0),
    (33,'AlTaieu',0),
    (34,'Grand_Palace_of_HuXzoi',0),
    (35,'The_Garden_of_RuHmet',0),
    (36,'Empyreal_Paradox',0),
    (37,'Temenos',0),
    (38,'Apollyon',0),
    (39,'Dynamis-Valkurm',0),
    (40,'Dynamis-Buburimu',0),
    (41,'Dynamis-Qufim',0),
    (42,'Dynamis-Tavnazia',0),
    (43,'Diorama_Abdhaljs-Ghelsba',0),
    (44,'Abdhaljs_Isle-Purgonorgo',0),
    (45,'Abyssea-Tahrongi',0),
    (46,'Open_sea_route_to_Al_Zahbi',0),
    (47,'Open_sea_route_to_Mhaura',0),
    (48,'Al_Zahbi',0),
    (49,'49',0),
    (50,'Aht_Urhgan_Whitegate',0),
    (51,'Wajaom_Woodlands',0),
    (52,'Bhaflau_Thickets',0),
    (53,'Nashmau',0),
    (54,'Arrapago_Reef',0),
    (55,'Ilrusi_Atoll',0),
    (56,'Periqia',0),
    (57,'Talacca_Cove',3),
    (58,'Silver_Sea_route_to_Nashmau',0),
    (59,'Silver_Sea_route_to_Al_Zahbi',0),
    (60,'The_Ashu_Talif',0),
    (61,'Mount_Zhayolm',0),
    (62,'Halvung',0),
    (63,'Lebros_Cavern',0),
    (64,'Navukgo_Execution_Chamber',0),
    (65,'Mamook',0),
    (66,'Mamool_Ja_Training_Grounds',0),
    (67,'Jade_Sepulcher',0),
    (68,'Aydeewa_Subterrane',0),
    (69,'Leujaoam_Sanctum',0),
    (70,'Chocobo_Circuit',0),
    (71,'The_Colosseum',0),
    (72,'Alzadaal_Undersea_Ruins',0),
    (73,'Zhayolm_Remnants',0),
    (74,'Arrapago_Remnants',0),
    (75,'Bhaflau_Remnants',0),
    (76,'Silver_Sea_Remnants',0),
    (77,'Nyzul_Isle',0),
    (78,'Hazhalm_Testing_Grounds',0),
    (79,'Caedarva_Mire',0),
    (80,'Southern_San_dOria_[S]',0),
    (81,'East_Ronfaure_[S]',0),
    (82,'Jugner_Forest_[S]',0),
    (83,'Vunkerl_Inlet_[S]',0),
    (84,'Batallia_Downs_[S]',0),
    (85,'La_Vaule_[S]',0),
    (86,'Everbloom_Hollow',0),
    (87,'Bastok_Markets_[S]',0),
    (88,'North_Gustaberg_[S]',0),
    (89,'Grauberg_[S]',0),
    (90,'Pashhow_Marshlands_[S]',0),
    (91,'Rolanberry_Fields_[S]',0),
    (92,'Beadeaux_[S]',0),
    (93,'Ruhotz_Silvermines',0),
    (94,'Windurst_Waters_[S]',0),
    (95,'West_Sarutabaruta_[S]',0),
    (96,'Fort_Karugo-Narugo_[S]',0),
    (97,'Meriphataud_Mountains_[S]',0),
    (98,'Sauromugue_Champaign_[S]',0),
    (99,'Castle_Oztroja_[S]',0),
    (100,'West_Ronfaure',0),
    (101,'East_Ronfaure',0),
    (102,'La_Theine_Plateau',0),
    (103,'Valkurm_Dunes',0),
    (104,'Jugner_Forest',0),
    (105,'Batallia_Downs',0),
    (106,'North_Gustaberg',0),
    (107,'South_Gustaberg',0),
    (108,'Konschtat_Highlands',0),
    (109,'Pashhow_Marshlands',0),
    (110,'Rolanberry_Fields',0),
    (111,'Beaucedine_Glacier',0),
    (112,'Xarcabard',0),
    (113,'Cape_Teriggan',5),
    (114,'Eastern_Altepa_Desert',0),
    (115,'West_Sarutabaruta',0),
    (116,'East_Sarutabaruta',0),
    (117,'Tahrongi_Canyon',0),
    (118,'Buburimu_Peninsula',0),
    (119,'Meriphataud_Mountains',0),
    (120,'Sauromugue_Champaign',0),
    (121,'The_Sanctuary_of_ZiTah',0),
    (122,'RoMaeve',0),
    (123,'Yuhtunga_Jungle',0),
    (124,'Yhoator_Jungle',0),
    (125,'Western_Altepa_Desert',0),
    (126,'Qufim_Island',0),
    (127,'Behemoths_Dominion',0),
    (128,'Valley_of_Sorrows',0),
    (129,'Ghoyus_Reverie',0),
    (130,'RuAun_Gardens',0),
    (131,'Mordion_Gaol',0),
    (132,'Abyssea-La_Theine',0),
    (133,'133',0),
    (134,'Dynamis-Beaucedine',0),
    (135,'Dynamis-Xarcabard',0),
    (136,'Beaucedine_Glacier_[S]',0),
    (137,'Xarcabard_[S]',0),
    (138,'Castle_Zvahl_Baileys_[S]',0),
    (139,'Horlais_Peak',0),
    (140,'Ghelsba_Outpost',0),
    (141,'Fort_Ghelsba',0),
    (142,'Yughott_Grotto',0),
    (143,'Palborough_Mines',0),
    (144,'Waughroon_Shrine',0),
    (145,'Giddeus',0),
    (146,'Balgas_Dais',0),
    (147,'Beadeaux',0),
    (148,'Qulun_Dome',0),
    (149,'Davoi',2),
    (150,'Monastic_Cavern',0),
    (151,'Castle_Oztroja',0),
    (152,'Altar_Room',0),
    (153,'The_Boyahda_Tree',5),
    (154,'Dragons_Aery',2),
    (155,'Castle_Zvahl_Keep_[S]',0),
    (156,'Throne_Room_[S]',0),
    (157,'Middle_Delkfutts_Tower',0),
    (158,'Upper_Delkfutts_Tower',0),
    (159,'Temple_of_Uggalepih',0),
    (160,'Den_of_Rancor',0),
    (161,'Castle_Zvahl_Baileys',0),
    (162,'Castle_Zvahl_Keep',0),
    (163,'Sacrificial_Chamber',0),
    (164,'Garlaige_Citadel_[S]',0),
    (165,'Throne_Room',0),
    (166,'Ranguemont_Pass',0),
    (167,'Bostaunieux_Oubliette',0),
    (168,'Chamber_of_Oracles',0),
    (169,'Toraimarai_Canal',0),
    (170,'Full_Moon_Fountain',0),
    (171,'Crawlers_Nest_[S]',0),
    (172,'Zeruhn_Mines',3),
    (173,'Korroloka_Tunnel',0),
    (174,'Kuftal_Tunnel',5),
    (175,'The_Eldieme_Necropolis_[S]',0),
    (176,'Sea_Serpent_Grotto',0),
    (177,'VeLugannon_Palace',0),
    (178,'The_Shrine_of_RuAvitau',0),
    (179,'Stellar_Fulcrum',0),
    (180,'LaLoff_Amphitheater',0),
    (181,'The_Celestial_Nexus',0),
    (182,'Walk_of_Echoes',0),
    (183,'Maquette_Abdhaljs-Legion',0),
    (184,'Lower_Delkfutts_Tower',0),
    (185,'Dynamis-San_dOria',0),
    (186,'Dynamis-Bastok',0),
    (187,'Dynamis-Windurst',0),
    (188,'Dynamis-Jeuno',0),
    (189,'Residential_Area',0),
    (190,'King_Ranperres_Tomb',0),
    (191,'Dangruf_Wadi',0),
    (192,'Inner_Horutoto_Ruins',0),
    (193,'Ordelles_Caves',0),
    (194,'Outer_Horutoto_Ruins',0),
    (195,'The_Eldieme_Necropolis',0),
    (196,'Gusgen_Mines',0),
    (197,'Crawlers_Nest',0),
    (198,'Maze_of_Shakhrami',0),
    (199,'Residential_Area',0),
    (200,'Garlaige_Citadel',0),
    (201,'Cloister_of_Gales',0),
    (202,'Cloister_of_Storms',0),
    (203,'Cloister_of_Frost',0),
    (204,'FeiYin',0),
    (205,'Ifrits_Cauldron',0),
    (206,'QuBia_Arena',0),
    (207,'Cloister_of_Flames',0),
    (208,'Quicksand_Caves',2),
    (209,'Cloister_of_Tremors',0),
    (210,'GM_Home',0),
    (211,'Cloister_of_Tides',0),
    (212,'Gustav_Tunnel',0),
    (213,'Labyrinth_of_Onzozo',0),
    (214,'Residential_Area',0),
    (215,'Abyssea-Attohwa',0),
    (216,'Abyssea-Misareaux',0),
    (217,'Abyssea-Vunkerl',0),
    (218,'Abyssea-Altepa',0),
    (219,'Residential_Area',0),
    (220,'Ship_bound_for_Selbina',0),
    (221,'Ship_bound_for_Mhaura',0),
    (222,'Provenance',0),
    (223,'San_dOria-Jeuno_Airship',0),
    (224,'Bastok-Jeuno_Airship',0),
    (225,'Windurst-Jeuno_Airship',0),
    (226,'Kazham-Jeuno_Airship',0),
    (227,'Ship_bound_for_Selbina_Pirates',0),
    (228,'Ship_bound_for_Mhaura_Pirates',0),
    (229,'229',0),
    (230,'Southern_San_dOria',0),
    (231,'Northern_San_dOria',0),
    (232,'Port_San_dOria',0),
    (233,'Chateau_dOraguille',0),
    (234,'Bastok_Mines',0),
    (235,'Bastok_Markets',0),
    (236,'Port_Bastok',0),
    (237,'Metalworks',0),
    (238,'Windurst_Waters',0),
    (239,'Windurst_Walls',0),
    (240,'Port_Windurst',0),
    (241,'Windurst_Woods',0),
    (242,'Heavens_Tower',0),
    (243,'RuLude_Gardens',0),
    (244,'Upper_Jeuno',0),
    (245,'Lower_Jeuno',0),
    (246,'Port_Jeuno',0),
    (247,'Rabao',0),
    (248,'Selbina',0),
    (249,'Mhaura',0),
    (250,'Kazham',0),
    (251,'Hall_of_the_Gods',0),
    (252,'Norg',0),
    (253,'Abyssea-Uleguerand',0),
    (254,'Abyssea-Grauberg',0),
    (255,'Abyssea-Empyreal_Paradox',0),
    (256,'Western_Adoulin',0),
    (257,'Eastern_Adoulin',0),
    (258,'Rala_Waterways',0),
    (259,'Rala_Waterways_U',0),
    (260,'Yahse_Hunting_Grounds',0),
    (261,'Ceizak_Battlegrounds',0),
    (262,'Foret_de_Hennetiel',0),
    (263,'Yorcia_Weald',0),
    (264,'Yorcia_Weald_U',0),
    (265,'Morimar_Basalt_Fields',0),
    (266,'Marjami_Ravine',0),
    (267,'Kamihr_Drifts',0),
    (268,'Sih_Gates',0),
    (269,'Moh_Gates',0),
    (270,'Cirdas_Caverns',0),
    (271,'Cirdas_Caverns_U',0),
    (272,'Dho_Gates',0),
    (273,'Woh_Gates',0),
    (274,'Outer_RaKaznar',0),
    (275,'Outer_RaKaznar_U',0),
    (276,'RaKaznar_Inner_Court',0),
    (277,'RaKaznar_Turris',0),
    (278,'278',0),
    (279,'279',0),
    (280,'Mog_Garden',0),
    (281,'Leafallia',0),
    (282,'Mount_Kamihr',0),
    (283,'Silver_Knife',0),
    (284,'Celennia_Memorial_Library',0),
    (285,'Feretory',0),
    (286,'286',0),
    (287,'287',0),
    (288,'Escha_ZiTah',0),
    (289,'Escha_RuAun',0),
    (290,'Desuetia_Empyreal_Paradox',0),
    (291,'Reisenjima',0),
    (292,'Reisenjima_Henge',0),
    (293,'Reisenjima_Sanctorium',0)
ON DUPLICATE KEY 
UPDATE 
    -- if the existing value and new value DO NOT equal eachother
        -- return the "new" inserted values "value"
        -- else current column "value"
    `name` = IF(`name` <> VALUES(`name`), VALUES(`name`), `name`),
    `difficulty` = IF(`difficulty` <> VALUES(`difficulty`), VALUES(`difficulty`), `difficulty`)
;

/*!40000 ALTER TABLE `fishing_zone` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-01  5:11:33
