USE `kamailio`;
INSERT INTO `carrier_name` VALUES (1,'skype');
INSERT INTO `domain_name` VALUES (1,'pstn');


-- Examples of adding mediation servers/numbers/domains/proxies
-- INSERT INTO `carrierroute` VALUES (1,1,1,'+123456',0,0,1,0,'example.com','','','Employees'),(2,1,1,'+123457',0,0,1,0,'example.com','','','Employees');
-- INSERT INTO `dispatcher` VALUES (1,300,'sip:10.0.0.2:5068;transport=tcp',0,5,'','example.com MEDIATION'),(2,301,'sip:10.1.0.2:5068;transport=tcp',0,5,'','example2.com MEDIATION'),(3,200,'sip:pstn-gw.example.com',0,5,'','PROXY');
-- INSERT INTO `domain_lookup` VALUES (1,'example.com',300),(2,'example2.com',301);
-- INSERT INTO `address` VALUES (1,200,'10.0.0.1',32,0,'pstn-gw.example.com PROXY'),(2,300,'10.0.0.2',32,0,'example.com SKYPE'),(3,301,'10.1.0.2',32,0,'example2.com SKYPE');
