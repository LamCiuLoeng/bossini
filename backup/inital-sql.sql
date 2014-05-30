--DROP TABLE THAT IS UNNECESSARY

/*
drop table if EXISTS product_log_sheet_brand cascade;
drop table if EXISTS product_log_sheet_dpci cascade;
drop table if EXISTS product_log_sheet_type cascade;
drop table if EXISTS product_log_sheet_vendor cascade;
drop table if EXISTS production_log_sheet cascade;
drop table if EXISTS t_city cascade;
drop table if EXISTS t_code_dtl cascade;
drop table if exists t_sub_cat1_master cascade;
drop table if EXISTS t_item_cat_master cascade;
drop table if EXISTS t_item_hdr cascade;
drop table if EXISTS t_item_supl_item cascade;
drop table if EXISTS t_sub_cat1_mastercascade;
drop table if EXISTS t_supl_fact cascade;
drop table if EXISTS t_supl_hdr cascade;
drop table if EXISTS vat_invoice_detail cascade;

drop table if exists user_permission cascade;
drop table if exists group_permission cascade;
drop table if exists permission cascade;
drop table if exists visit cascade;
drop table if exists visit_identity cascade;
drop table if exists user_group cascade;
drop table if exists tg_group cascade;
drop table if exists tg_user cascade;
*/

--delete table's sequence above manual

INSERT INTO "tg_group" VALUES (1, 'Admin', '2008-11-26 17:42:11');
INSERT INTO "tg_group" VALUES (2, 'KOHLS_TEAM', '2009-3-31 11:29:38');
INSERT INTO "tg_group" VALUES (3, 'KOHLS_VIEW', '2009-8-17 18:31:07');


INSERT INTO "tg_user" VALUES (1, 'admin', 'ecrmadmin', 'admin4pls@rpac.com', '2008-11-26 17:42:11', NULL);
INSERT INTO "tg_user" VALUES (8, 'Elsie.Sung', 'es428eg', 'Elsie.Sung@rpac.com', '2008-11-26 17:42:12', NULL);
INSERT INTO "tg_user" VALUES (16, 'June.Lam', 'jl112em', 'June.Lam@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (24, 'Phoebe.Ying', 'py52eg', 'Phoebe.Ying@rpac.com', '2008-11-26 17:42:14', NULL);
INSERT INTO "tg_user" VALUES (4, 'Co.Tai', '7h5tdnt', 'Co.Tai@rpac.com', '2008-11-26 17:42:12', NULL);
INSERT INTO "tg_user" VALUES (5, 'Chi.Chan', 'cc22ni', 'Chi.Chan@rpac.com', '2008-11-26 17:42:12', NULL);
INSERT INTO "tg_user" VALUES (12, 'Sheila.Luo', 'sl41aof', 'Sheila.Luo@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (9, 'Minnie.Wong', 'mw901eg', 'Minnie.Wong@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (2, 'Venus.Sung', 'vs618sg', 'Venus.Sung@rpac.com', '2008-11-26 17:42:11', NULL);
INSERT INTO "tg_user" VALUES (22, 'Jeffrey.Hang', 'jh618yg', 'Jeffrey.Hang@rpac.com', '2008-11-26 17:42:14', NULL);
INSERT INTO "tg_user" VALUES (19, 'Isabella.Lam', 'il610am', 'Isabella.Lam@rpac.com', '2008-11-26 17:42:14', NULL);
INSERT INTO "tg_user" VALUES (6, 'Coby.Wu', 'cw724yu', 'Coby.Wu@rpac.com', '2008-11-26 17:42:12', NULL);
INSERT INTO "tg_user" VALUES (3, 'Cat.Lai', 'cl910ti', 'Cat.Lai@rpac.com', '2008-11-26 17:42:11', NULL);
INSERT INTO "tg_user" VALUES (14, 'Crystal.Liu', 'cl91lu', 'Crystal.Liu@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (15, 'Chris.Chan', 'cc723sn', 'Chris.Chan@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (10, 'Celia.Wong', 'cw901ag', 'Celia.Wong@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (7, 'Kathy.Tam', 'kt409ym', 'Kathy.Tam@rpac.com', '2008-11-26 17:42:12', NULL);
INSERT INTO "tg_user" VALUES (21, 'Doris.Chu', 'dc111su', 'Doris.Chu@rpac.com', '2008-11-26 17:42:14', NULL);
INSERT INTO "tg_user" VALUES (20, 'Alex.Chan', 'ac118xn', 'Alex.Chan@rpac.com', '2008-11-26 17:42:14', NULL);
INSERT INTO "tg_user" VALUES (11, 'Nancy.Xia', 'nx93ya', 'Nancy.Xia@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (23, 'Isadora.Wong', 'iw217ag', 'Isadora.Wong@rpac.com', '2008-11-26 17:42:14', NULL);
INSERT INTO "tg_user" VALUES (18, 'Meiji.Chen', 'mc413in', 'Meiji.Chen@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (25, 'Kenneth.Lau', 'kl11hu', 'Kenneth.Lau@rpac.com', '2008-11-26 17:42:14', NULL);
INSERT INTO "tg_user" VALUES (17, 'Edmond.Yip', 'ey112yp', 'Edmond.Yip@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (26, 'Lucy.Lu', 'll216yu', 'll216yu@r-pac.com.cn', '2008-12-5 17:40:06', NULL);
INSERT INTO "tg_user" VALUES (27, 'Eric.Li', 'el29ci', 'el29ci@r-pac.com.cn', '2008-12-5 17:41:50', NULL);
INSERT INTO "tg_user" VALUES (28, 'Mike.Guo', 'mg121eo', 'Mike.Guo@r-pac.com.cn', '2008-12-5 17:42:16', NULL);
INSERT INTO "tg_user" VALUES (29, 'Juria.Hon', 'jh117an', 'Juria.Hon@r-pac.com', '2009-1-12 12:23:48', NULL);
INSERT INTO "tg_user" VALUES (13, 'Sara.Li', 'sl8ai28', 'Sara.Li@rpac.com', '2008-11-26 17:42:13', NULL);
INSERT INTO "tg_user" VALUES (30, 'Eileen.Mao', 'aaa', 'Eileen.Mao@r-pac.com.cn', '2009-3-26 15:35:56', NULL);
INSERT INTO "tg_user" VALUES (31, 'Jenna.Liu', 'aaa', 'Jenna.Liu@r-pac.com.cn', '2009-3-26 15:36:27', NULL);
INSERT INTO "tg_user" VALUES (32, 'Tommy.Guo', 'aaa', 'Tommy.Guo@r-pac.com.cn', '2009-3-26 15:36:48', NULL);
INSERT INTO "tg_user" VALUES (33, 'kohls_report', 'kohls090407', 'kohls_report@temp.com', '2009-3-31 12:42:00', NULL);
INSERT INTO "tg_user" VALUES (34, 'Shirley.Lam', 'aaa', 'Shirley.Lam@r-pac.com', '2009-4-24 17:31:47', NULL);
INSERT INTO "tg_user" VALUES (35, 'Kelly.Pang', 'aaa', 'Kelly.Pang@r-pac.com', '2009-4-24 17:32:28', NULL);
INSERT INTO "tg_user" VALUES (36, 'Annie.Lee', 'aaa', 'Annie.Lee@r-pac.com', '2009-4-24 17:32:58', NULL);
INSERT INTO "tg_user" VALUES (38, 'Clara.Lau', 'aaa', 'Clara.Lau@r-pac.com', '2009-4-24 17:34:23', NULL);
INSERT INTO "tg_user" VALUES (37, 'Christine.Cheung', 'aaa', 'Christine.Cheung@r-pac.com', '2009-4-24 17:33:40', NULL);
INSERT INTO "tg_user" VALUES (39, 'ray.zhang', 'aaa', 'ray.zhang@r-pac.com.cn', '2009-4-28 14:08:34', NULL);
INSERT INTO "tg_user" VALUES (40, 'Matt.Matsuo', 'abc123$', 'Matt.Matsuo@r-pac.com', '2009-5-8 10:14:08', NULL);
INSERT INTO "tg_user" VALUES (41, 'Tony.Wolken', '123asd!', 'Tony.Wolken@royalpromo.com', '2009-5-8 10:14:41', NULL);
INSERT INTO "tg_user" VALUES (42, 'Charlie.Ho', 'aaa', 'Charlie.Ho@r-pac.com', '2009-6-26 10:41:38', NULL);
INSERT INTO "tg_user" VALUES (43, 'Jane.Jim', 'aaa', 'Jane.Jim@r-pac.com', '2009-6-26 12:04:55', NULL);
INSERT INTO "tg_user" VALUES (44, 'Cheryl.DePalma', 'cd721#', 'Cheryl.DePalma@r-pac.com', '2009-7-13 16:49:19', NULL);




INSERT INTO "user_group" VALUES (1, 1);
INSERT INTO "user_group" VALUES (2, 36);
INSERT INTO "user_group" VALUES (2, 37);
INSERT INTO "user_group" VALUES (2, 38);
INSERT INTO "user_group" VALUES (2, 35);
INSERT INTO "user_group" VALUES (2, 34);
INSERT INTO "user_group" VALUES (2, 39);
INSERT INTO "user_group" VALUES (3, 36);
INSERT INTO "user_group" VALUES (3, 37);
INSERT INTO "user_group" VALUES (3, 38);
INSERT INTO "user_group" VALUES (3, 1);
INSERT INTO "user_group" VALUES (3, 35);
INSERT INTO "user_group" VALUES (3, 40);
INSERT INTO "user_group" VALUES (3, 34);
INSERT INTO "user_group" VALUES (3, 41);
INSERT INTO "user_group" VALUES (3, 39);


INSERT INTO "permission" VALUES (1, 'KOHLS_EDIT', '"KOHLS_EDIT" is used to grant all the process related to the Kohl''s .');
INSERT INTO "permission" VALUES (2, 'KOHLS_REPORT', '"KOHLS_REPORT" is used to generate the report related to Kohl''s from ERP');


INSERT INTO "group_permission" VALUES (2, 1);
INSERT INTO "group_permission" VALUES (2, 2);
INSERT INTO "group_permission" VALUES (1, 1);
INSERT INTO "group_permission" VALUES (1, 2);
INSERT INTO "group_permission" VALUES (3, 1);
