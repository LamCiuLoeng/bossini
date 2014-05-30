begin;
ALTER TABLE bossini_item ADD COLUMN component character varying(50);
ALTER TABLE bossini_item ADD COLUMN display character varying(100);
ALTER TABLE bossini_item ADD COLUMN img character varying(50);
update bossini_item set display=item_code,img=item_code;

CREATE TABLE bossini_parts
(
  id serial NOT NULL,
  "content" character varying(100),
  status integer,
  content_s_c character varying(100),
  content_t_c character varying(100),
  CONSTRAINT bossini_parts_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_parts OWNER TO postgres;

CREATE TABLE bossini_origin
(
  id serial NOT NULL,
  china character varying(100),
  hksinex_p character varying(100),
  tw_n character varying(100),
  egypt character varying(100),
  romanian character varying(100),
  poland character varying(100),
  russia character varying(100),
  japanese character varying(100),
  french character varying(100),
  germany character varying(100),
  spanish character varying(100),
  italian character varying(100),
  korea character varying(100),
  status integer,
  CONSTRAINT bossini_origin_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_origin OWNER TO postgres;

CREATE TABLE bossini_fiber_content
(
  id serial NOT NULL,
  china character varying(100),
  hksinex_p character varying(100),
  tw_n character varying(100),
  egypt character varying(100),
  romanian character varying(100),
  poland character varying(100),
  russia character varying(100),
  japanese character varying(100),
  french character varying(100),
  germany character varying(100),
  spanish character varying(100),
  italian character varying(100),
  status integer,
  CONSTRAINT bossini_fiber_content_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_fiber_content OWNER TO postgres;

CREATE TABLE bossini_care_instruction
(
  id serial NOT NULL,
  style_index integer,
  content_en character varying(100),
  content_s_c character varying(100),
  content_t_c character varying(100),
  instruction_type character varying(20),
  status integer,
  CONSTRAINT bossini_care_instruction_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_care_instruction OWNER TO postgres;

CREATE TABLE bossini_legacy_code
(
  id serial NOT NULL,
  legacy_code character varying(20),
  status integer,
  CONSTRAINT bossini_legacy_code_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_legacy_code OWNER TO postgres;


CREATE TABLE bossini_function_card_info
(
  id serial NOT NULL,
  order_info_id integer,
  card_type character varying(50),
  item_id integer,
  qty integer,
  status integer,
  CONSTRAINT bossini_function_card_info_pkey PRIMARY KEY (id),
  CONSTRAINT item_id_exists FOREIGN KEY (item_id)
      REFERENCES bossini_item (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT order_info_id_exists FOREIGN KEY (order_info_id)
      REFERENCES bossini_order_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_function_card_info OWNER TO postgres;


CREATE TABLE bossini_function_card_info_detail
(
  id serial NOT NULL,
  header_id integer,
  legacy_code_id integer,
  CONSTRAINT bossini_function_card_info_detail_pkey PRIMARY KEY (id),
  CONSTRAINT header_id_exists FOREIGN KEY (header_id)
      REFERENCES bossini_function_card_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT legacy_code_id_exists FOREIGN KEY (legacy_code_id)
      REFERENCES bossini_legacy_code (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_function_card_info_detail OWNER TO postgres;

CREATE TABLE bossini_style_label_info
(
  id serial NOT NULL,
  order_info_id integer,
  item_id integer,
  status integer,
  CONSTRAINT bossini_style_label_info_pkey PRIMARY KEY (id),
  CONSTRAINT item_id_exists FOREIGN KEY (item_id)
      REFERENCES bossini_item (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT order_info_id_exists FOREIGN KEY (order_info_id)
      REFERENCES bossini_order_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_style_label_info OWNER TO postgres;

CREATE TABLE bossini_style_label_info_detail
(
  id serial NOT NULL,
  header_id integer,
  legacy_code_id integer,
  qty integer,
  CONSTRAINT bossini_style_label_info_detail_pkey PRIMARY KEY (id),
  CONSTRAINT header_id_exists FOREIGN KEY (header_id)
      REFERENCES bossini_style_label_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT legacy_code_id_exists FOREIGN KEY (legacy_code_id)
      REFERENCES bossini_legacy_code (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_style_label_info_detail OWNER TO postgres;


CREATE TABLE bossini_care_label_info
(
  id serial NOT NULL,
  order_info_id integer,
  item_id integer,
  washing_id integer,
  bleaching_id integer,
  ironing_id integer,
  dry_cleaning_id integer,
  drying_id integer,
  others_drying_id integer,
  appendix character varying(50),
  qty integer,
  status integer,
  origin_id integer,
  CONSTRAINT bossini_care_label_info_pkey PRIMARY KEY (id),
  CONSTRAINT bleaching_id_exists FOREIGN KEY (bleaching_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT dry_cleaning_id_exists FOREIGN KEY (dry_cleaning_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT drying_id_exists FOREIGN KEY (drying_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ironing_id_exists FOREIGN KEY (ironing_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT item_id_exists FOREIGN KEY (item_id)
      REFERENCES bossini_item (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT order_info_id_exists FOREIGN KEY (order_info_id)
      REFERENCES bossini_order_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT origin_id_exist FOREIGN KEY (origin_id)
      REFERENCES bossini_origin (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE RESTRICT,
  CONSTRAINT others_drying_id_exists FOREIGN KEY (others_drying_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT washing_id_exists FOREIGN KEY (washing_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_care_label_info OWNER TO postgres;

CREATE TABLE bossini_care_label_info_detail
(
  id serial NOT NULL,
  header_id integer,
  legacy_code_id integer,
  qty integer,
  status integer,
  CONSTRAINT bossini_care_label_info_detail_pkey PRIMARY KEY (id),
  CONSTRAINT header_id_exists FOREIGN KEY (header_id)
      REFERENCES bossini_care_label_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT legacy_code_id_exists FOREIGN KEY (legacy_code_id)
      REFERENCES bossini_legacy_code (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_care_label_info_detail OWNER TO postgres;

CREATE TABLE bossini_care_label_component_header
(
  id serial NOT NULL,
  care_label_info_id integer,
  name_id integer,
  status integer,
  CONSTRAINT bossini_care_label_component_header_pkey PRIMARY KEY (id),
  CONSTRAINT care_label_info_id_exists FOREIGN KEY (care_label_info_id)
      REFERENCES bossini_care_label_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT name_id_exists FOREIGN KEY (name_id)
      REFERENCES bossini_parts (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_care_label_component_header OWNER TO postgres;

CREATE TABLE bossini_care_label_component_detail
(
  id serial NOT NULL,
  header_id integer,
  percentage integer,
  component_id integer,
  CONSTRAINT bossini_care_label_component_detail_pkey PRIMARY KEY (id),
  CONSTRAINT component_id_exists FOREIGN KEY (component_id)
      REFERENCES bossini_fiber_content (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT header_id_exists FOREIGN KEY (header_id)
      REFERENCES bossini_care_label_component_header (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_care_label_component_detail OWNER TO postgres;

CREATE TABLE bossini_down_jacket_info
(
  id serial NOT NULL,
  order_info_id integer,
  item_id integer,
  qty integer,
  down_content integer,
  filling165 integer,
  filling170 integer,
  filling175 integer,
  filling180 integer,
  filling185 integer,
  status integer,
  CONSTRAINT bossini_down_jacket_info_pkey PRIMARY KEY (id),
  CONSTRAINT item_id_exists FOREIGN KEY (item_id)
      REFERENCES bossini_item (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT order_info_id_exists FOREIGN KEY (order_info_id)
      REFERENCES bossini_order_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_down_jacket_info OWNER TO postgres;

CREATE TABLE bossini_down_jacket_info_detail
(
  id serial NOT NULL,
  header_id integer,
  legacy_code_id integer,
  CONSTRAINT bossini_down_jacket_info_detail_pkey PRIMARY KEY (id),
  CONSTRAINT header_id_exists FOREIGN KEY (header_id)
      REFERENCES bossini_down_jacket_info (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT legacy_code_id_exists FOREIGN KEY (legacy_code_id)
      REFERENCES bossini_legacy_code (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_down_jacket_info_detail OWNER TO postgres;

CREATE TABLE bossini_legacy_function
(
  legacy_id integer NOT NULL,
  function_id integer NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_legacy_function OWNER TO postgres;


CREATE TABLE bossini_legacy_style
(
  legacy_id integer NOT NULL,
  style_id integer NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_legacy_style OWNER TO postgres;


CREATE TABLE bossini_legacy_downjacket
(
  legacy_id integer NOT NULL,
  downjacket_id integer NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_legacy_downjacket OWNER TO postgres;


INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (1, 'DRY CLEAN ONLY', NULL, NULL, 'DryCleaning', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (3, 'DO NOT DRY CLEAN', NULL, NULL, 'DryCleaning', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (2, NULL, NULL, NULL, 'DryCleaning', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (1, 'HANG TO DRY', NULL, NULL, 'OthersDrying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (2, 'LINE DRY', NULL, NULL, 'OthersDrying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (3, 'LAY FLAT TO DRY', NULL, NULL, 'OthersDrying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (4, 'RESHAPE LAY FLAT DRY', NULL, NULL, 'OthersDrying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (6, 'DO NOT WASH', NULL, NULL, 'Washing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (2, 'DO NOT BLEACH', NULL, NULL, 'Bleaching', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (1, 'TUMBLE DRY', NULL, NULL, 'Drying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (2, 'TUMBLE DRY LOW', NULL, NULL, 'Drying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (4, 'DO NOT TUMBLE DRY', NULL, NULL, 'Drying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (1, 'LOW IRON', NULL, NULL, 'Ironing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (2, 'WARM IRON', NULL, NULL, 'Ironing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (3, 'WARM IRON IF NEEDED', NULL, NULL, 'Ironing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (6, 'STEAM PRESSING ONLY', NULL, NULL, 'Ironing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (7, 'DO NOT IRON', NULL, NULL, 'Ironing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (5, 'WARM IRON UNDER A COVER CLOTH', NULL, NULL, 'Ironing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (4, 'LOW IRON UNDER A COVER CLOTH', NULL, NULL, 'Ironing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (3, 'TUMBLE DRY LOW AND REMOVE PROMPTLY', NULL, NULL, 'Drying', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (1, 'CHLORINE BLEACH MAY BE USED', NULL, NULL, 'Bleaching', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (5, 'HAND WASH COLD SEPARATELY', NULL, NULL, 'Washing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (4, 'MACHINE WASH LUKEWARM SEPARATELY', NULL, NULL, 'Washing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (3, 'DELICATE MACHINE WASHLUKEWARM CYCLE SEPARATELY', NULL, NULL, 'Washing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (2, 'MACHINE WASH COLD SEPARATELY', NULL, NULL, 'Washing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (1, 'DELICATE MACHINE WASH COLD CYCLE SEPARATELY', NULL, NULL, 'Washing', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'WASH SEPARATELY', '分开洗涤', '分開洗滌', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'WASH INSIDE OUT', '反面洗涤', '反面洗滌', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DO NOT SOAK', '不可浸泡', '不可浸泡', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DRY IMMEDIATELY AFTER WASH', '洗后随即干燥', '洗後隨即乾燥', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'IRON ON REVERSE SIDE ONLY', '反面熨烫', '反面熨燙', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'TUMBLE DRY', '可烘干', '可烘乾', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'TUMBLE DRY LOW', '低温烘干', '低溫烘乾', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'TUMBLE DRY LOW AND REMOVE PROMPTLY', '低温烘干后立即取出', '低溫烘乾後立即取出', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DO NOT TUMBLE DRY', '不可烘干', '不可烘乾', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'HANG TO DRY', '悬挂晾干', '衣架懸掛晾乾', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'LINE DRY', '悬挂晾干', '懸掛晾乾', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'LAY FLAT TO DRY', '平摊干燥', '平放晾乾', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'RESHAPE LAY FLAT DRY', '保持衣形平放晾干', '保持衣形平放晾乾', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'WASH BEFORE WEAR', '洗涤一次后再穿着', '洗滌一次後再穿著', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'WASH BEFORE USED', '洗涤一次后再使用', '洗滌一次後再使用', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DO NOT USE SOFTENER', '不可使用衣物柔顺剂', '不可使用衣物柔軟劑', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'WET CLOTHER CLEANING', '只可用湿布轻轻擦拭', '只可用濕布輕輕擦拭', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'PUT INTO LAUNDRY BAG FOR WASHING', '放进洗衣袋中洗涤 ', '放進洗衣袋中洗滌', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'WITH FABRIC COVER PU LEATHER BEFORE DRY CLEAN', '干洗前用白色棉布包裹仿皮部分 ', '乾洗前用白色棉布包裹仿皮部分 ', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DETACH FUR BEFORE WASH', '洗前拆下毛领/毛边', '洗前拆下毛領/毛邊', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DETACH HOOD LINING BEFORE WASH', '洗前拆下帽里', '洗前拆下帽裡', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'REMOVE THE DECORATION BEFORE WASH', '洗前拆下装饰物', '洗前拆下裝飾物', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DETACH BELT OR SHOULDER TAPE  BEFORE WASH ', '洗前拆下腰带或肩带', '洗前拆下腰帶或肩帶', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DO NOT IRON ON PRINT AND MOTIF', '印花和图案表面不可熨烫', '印花和圖案表面不可熨燙', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DO NOT IRON ON APPLIQUE', '不可于贴花饰物上熨烫', '不可於貼花飾物上熨燙', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DO NOT IRON ON 3D CREASE LINE', '3D折皱位置不可熨烫', '3D 摺褶位置不可熨燙', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DETACH HOOD BEFORE WASH', '洗前拆下帽', '洗前拆下帽', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'REMOVE PROMPTLY AFTER WASH ', '脱水后立即取出', '脫水後立即取出', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'PROFESSIONAL LEATHER DRY CLEAN ONLY', '只可专业皮革干洗', '只可專業皮革乾洗', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DETACH NECKWEAR BEFORE WASH', '洗前拆下领带', '洗前拆下領帶', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'ADD SOFTENER ON PU LEATHER BEFORE DRY CLEAN', '干洗前添加柔顺剂在PU皮上', '乾洗前添加柔順劑在PU皮上', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, 'DO NOT USE OPTICAL BRIGHTENER ', '不可使用荧光增白剂 ', '不可使用熒光增白劑 ', 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, NULL, '垫布熨烫', NULL, 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, NULL, '建议蒸汽熨烫 ', NULL, 'Appendix', 0);
INSERT INTO "bossini_care_instruction" ("style_index", "content_en", "content_s_c", "content_t_c", "instruction_type", "status") VALUES (NULL, NULL, '不可拧干', NULL, 'Appendix', 0);

INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('醋纤', 'ACETATE', '醋酸纖維', 'أستات ', 'ACETAT', 'ACETAT', 'ацетат', 'アセテート', 'ACETATE', 'AZETAT', 'ACETATO', 'ACETATO', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('腈纶', 'ACRYLIC', '聚丙烯腈纖維', 'أكرليك', 'ACRIL', 'AKRYL', 'акрил', 'アクリル', 'ACRYLIQUE', 'ACRYL', 'ACRÍLICO', 'ACRILICO', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('羊驼毛', 'ALPACA', '羊駝毛', 'ألباكا صوف', 'ALPACA', 'ALPAKA', 'шерсть альпаки', 'アルパカ', 'ALPAGA', 'ALPACA', 'ALPACA', 'Alpaca  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('兔毛', 'ANGORA', '安哥拉毛', 'أنغورا', 'LANA ANGORA', 'ANGORA', 'ангора', 'アンゴラ', 'ANGORA', 'ANGORA', 'ANGORA', 'ANGORA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('羊绒', 'CASHMERE', '開司米亞', 'كشمير', 'CASMIR', 'KASZMIR', 'кашемир', 'カシミア織', 'CACHEMIRE', 'KASCHMIR', 'CACHEMIRA', 'KASHMIR', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('棉', 'COTTON', '棉', 'قطن', 'BUMBAC', 'BAWEŁNA', 'хлопок', '綿', 'COTON', 'BAUMWOLLE', 'ALGODÓN', 'COTONE', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('羽绒', 'DOWN', '羽絨', 'وبر ', 'PUF', 'PUCH', 'пух', 'ダウン', 'DUVET', 'DAUNEN', 'PLUMÓN', 'PIUMINO', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('氨纶', 'ELASTANE', '彈性纖維 ', 'الاستين', 'ELASTAN', 'ELASTAN', 'эластаза', 'ポリウレタン', 'ELASTHANNE', 'ELASTHAN', 'Elastan', 'ELASTAM', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('羽毛', 'FEATHER', '羽毛', 'صناعى ريش', 'PENE', 'PIERZE', 'перо', 'フェザー', 'PLUMES', 'FEDER', 'PLUMA', 'PIUMA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('羊毛', 'LAMBSWOOL', '羊毛', 'غنم صوف', 'LANA DE OAIE', 'WEŁNA JAGNIĘCA', 'овечья шерсть', '子羊のウール', 'LAINE D''AGNEAU', 'SCHURWOLLE', 'LANA', 'Lana di agnello  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('亚麻', 'LINEN', '麻', 'كتان ', 'PANZA', 'LEN', 'льняной', '麻', 'LIN', 'Leinen', 'LINO', 'Lino  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('苎麻', 'LINEN', '麻', 'كتان ', 'PANZA', 'LEN', 'льняной', '麻', 'LIN', 'Leinen', 'LINO', 'Lino  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('黄麻', 'LINEN', '麻', 'كتان ', 'PANZA', 'LEN', 'льняной', '麻', 'LIN', 'Leinen', 'LINO', 'Lino  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('金银线', 'LUREX', '金銀線', 'لوركس ', 'LUREX', 'LUREX', 'люрекс', '金銀ひも', 'LUREX', 'LUREX', 'LUREX', 'LUREX', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('氨纶', 'LYCRA', '萊卡彈性纖維', 'ليكرا ', 'LICRA', 'LYCRA', 'лайкра', '彈性繊維', 'LYCRA', 'LYCRA', 'LYCRA', 'LYCRA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('金银线', 'METALLISED FIBRE', '金屬纖維 ', 'نسيج لامع', 'FIBRA METALICA', 'WŁÓKNO METALIZOWANE ', 'металлизационная ткань', '金属繊維', 'METALLISED FIBRES', 'METALL FIBRE', 'Fibra Metalica', 'METALLIZZATO FIBRE', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('金属纤维 ', 'METAL FIBRE', '金屬纖維 ', 'نسيج لامع', 'FIBRA METALICA', 'WŁÓKNO METALIZOWANE ', 'металлизационная ткань', '金属繊維', 'METALLISED FIBRES', 'METALL FIBRE', 'Fibra Metalica', 'METALLIZZATO FIBRE', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('莫代尔', 'MODAL', '木代爾', 'مودال ', 'MODAL', 'MODAL', 'модельный', 'レーヨン', 'MODAL', 'Modal', 'MODAL', 'MODAL', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('马海毛', 'MOHAIR', '毛海', 'موهير', 'MOHAIR', 'MOHER', 'мохер', 'モヘヤ', 'MOHAIR', 'MOHAIR', 'MOHAIR', 'MOHAIR', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('锦纶', 'NYLON', '尼龍', 'نايلون ', 'NAILON', 'NYLON', 'нейлон', 'ナイロン', 'POLYAMIDE', 'NYLON', 'NYLON', 'POLIAMMIDICA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('其它纤维', 'OTHER FIBRE', '其它纖維', 'أخرى ألياف', 'ALTE FIBRE', 'INNE WŁÓKNA', 'другой материал', 'その他繊維', 'AUTRES FIBRES', 'ANDERE FASER', 'OTRAS FIBRAS', 'ALTRE FIBRE', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('锦纶', 'POLYAMIDE', '聚醯胺纖維', 'بوليميد ', 'POLIAMID', 'POLYAMID', 'полиамид', 'ポリイミド', 'POLIAMIDA', 'POLYAMIDE', 'POLIAMIDA', 'Poliamida  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('聚酯纡维', 'POLYESTER', '聚酯纖維', 'بوليستر', 'POLIESTER', 'POLIESTER', 'полиэстер', 'ポリエステル', 'POLYESTER', 'POLYESTER', 'POLIESTER', 'POLIESTERE', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('聚氯乙烯', 'PVC', '', 'سى فى  بى', 'PVC', 'POLIWINYL', 'ПВХ', 'ポリ塩化ビニル', 'PVC', 'PVC', 'PVC', 'PVC  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('苎麻', 'RAMIE', '苧麻', 'رامى كتان', 'RAMIE', 'RAMIA', 'ткань из рами', '指定外繊維（ラミエ麻）', 'RAMIE', 'RAMIEFASER', 'RAMIO', 'RAMIE''', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('桑蚕丝', 'SILK', '絲', 'نويل حرير', 'MATASE', 'JEDWAB ', 'шелк', '絹', 'SOIE', 'SEIDE', 'SEDA', 'SETA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('柞蚕丝', 'SILK', '絲', 'نويل حرير', 'MATASE', 'JEDWAB ', 'шелк', '絹', 'SOIE', 'SEIDE', 'SEDA', 'SETA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('粘纤', 'VISCOSE', '嫘縈', 'فيسكوز', 'VASCOZA', 'WISKOZA', 'вискоза', 'レーヨン', 'VISCOSA', 'Viskose', 'VISCOSA', 'VISCOSA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('羊毛', 'WOOL', '羊毛', 'صوف', 'LANA', 'WEŁNA', 'шерсть', '毛', 'LAINE', 'Wolle', 'LANA', 'LANA', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('兔毛皮', 'RABBIT FUR', '兔毛皮', 'فرو أرنب', 'Blana de iepure', 'FUTRO KRÓLIKA', 'мех кролика', 'ウサギの毛皮', 'fourrure de lapin', 'Kaninchen Pelz', 'Pelo de Conejo', 'pellicce di coniglio', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('毛皮', 'FUR', '毛皮', 'فرو ', 'Blana', 'FUTRO ', 'мех ', '毛皮', 'FOURRURE', 'Pelz', 'Pelo', 'pellicce  ', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('貉子毛皮', 'RACCOON FUR', '貉子毛皮', 'فرو سنجاب', 'Blana de raton', 'FUTRO SZOPA ', 'мех енот', 'ラクーン毛皮', 'fourrure raton laveur', 'Waschbär Pelz', 'Pelo de Mapache', 'raccoon pelliccia', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('狐狸毛皮', 'FOX FUR', '狐貍毛皮', 'فرو ثعلب', 'Blana de vulpe', 'FUTRO LISA ', 'мехом лисы', 'キツネの毛皮', 'fourrure de renard', 'Fuchspelz', 'Pelo de Zorro', 'pellicce di volpe', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('皮革', 'LEATHER', '皮革', 'جلد', 'Piele', 'Skóra', 'КОЖА', '革', 'Cuir', 'Leder', 'Cuero', 'Pelle', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('纤维素纤维', 'PAPER STRAW', '紙草', 'ورقة من القش', 'hârtie de paie ', 'papier słomy', 'бумага соломы', '紙わら', 'papier de paille', 'Papier Stroh', 'documento de paja', 'carta paglia', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('莱赛尔纤维', 'LYOCELL', '萊賽爾纖維', 'ليوسل', 'LYOCELL', 'LYOCELL', 'Лиоцелл', 'テンセル', 'LYOCELL', 'LYOCELL', 'LYOCELL', 'LYOCELL', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('变性晴纶      ', 'MODACRYLIC   ', '變性晴綸', '　مودأكريليك', 'modacrylic', 'modakrylowych', 'Модакрил', 'モダクリル', 'modacrylique', 'Modacryl', 'modacrílicas', 'Modacrilica', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('玉米皮 ', 'CORN HUSK  ', '玉米皮 ', 'قشر الذرة', 'Coajă de porumb', 'CORN łuskę', 'КУКУРУЗА HUSK', 'トウモロコシの皮', 'En épi de maïs', 'CORN HUSK', 'MAÍZ CÁSCARA', 'BUCCIA DI MAIS', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('聚丙烯', 'Polypropylene', '聚丙烯', 'بوليبروبلين', 'Polipropilenă', 'Polipropylen', 'полипропилен', 'ポリプロピレン', 'polypropylène', 'Polypropylen', 'Polipropileno', 'Polipropilenica', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('聚氨酯', 'POLYURETHANE', '聚氨酯', 'البولي', 'poliuretanice', 'poliuretanowe', 'полиуретан', 'ポリウレタン', 'polyuréthane', 'Polyurethan', 'poliuretano', 'poliuretano', 0);
INSERT INTO "bossini_fiber_content" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "status") VALUES ('人造丝', 'RAYON', '人造絲', 'الرايون', 'raion', 'rayon', 'вискоза', 'レーヨン', 'rayonne', 'Kunstseide', 'región', 'raion', 0);

INSERT INTO "bossini_origin" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "korea", "status") VALUES ('中国制造', 'Made in China', '中國製', 'صنع فى الصين', 'Fabricat in China', 'Wyprodukowano w Chinach', 'Сделано в Китае', '中国製造', 'FABRIQUÉ EN CHINE', 'Hergestellt in China', 'HECHO EN CHINA', 'FABBRICATA IN CINA', '중국 생산', 0);
INSERT INTO "bossini_origin" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "korea", "status") VALUES ('香港制造', 'Made in Hong Kong', '香港製', 'صنع فى هونج كونج', 'Fabricat in Hong Kong', 'Wyprodukowano w Hong Kongu', 'Сделано в Гонг-Конг', '香港製造', 'FABRIQUÉ À HONG KONG', 'Hergestellt in Hong Kong', 'HECHO EN HONG KONG', 'FABBRICATO IN HONG KONG', '홍콩 생산', 0);
INSERT INTO "bossini_origin" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "korea", "status") VALUES ('澳门制造', 'Made in Macau', '澳門製', 'صنع فى ماكاو', 'Fabricat in Macau', 'Wyprodukowano w Makao', 'Сделано в Макао', '澳門製造', 'FABRIQUÉ À MACAO', 'Hergestellt in Macau ', 'HECHO EN MACAO', 'FABBRICATA IN MACAU', '마카오 생산', 0);
INSERT INTO "bossini_origin" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "korea", "status") VALUES ('越南制造', 'Made in Vietnam', '越南製', 'صنع فى فيتنام', 'Fabricat In Vietnam', 'Wyprodukowano w Wietnamie', 'Сделано в Вьетнам', 'ベトナム製造', 'FABRIQUÉ AU VIET-NAM', 'Hergestellt in Vietnam ', 'HECHO EN VIETNAM', 'FABBRICATO IN VIETNAM', '베트남 생산', 0);
INSERT INTO "bossini_origin" ("china", "hksinex_p", "tw_n", "egypt", "romanian", "poland", "russia", "japanese", "french", "germany", "spanish", "italian", "korea", "status") VALUES ('泰国制造', 'Made in Thailand', '泰國製', 'صنع فى تايلاند', 'Fabricat in Tailanda', 'Wyprodukowano w Tajlandii', 'Сделано в Тайланде', 'タイ製造', 'FABRIQUÉ EN THAILANDE', 'Hergestellt in Thailand ', 'HECHO EN THAILANDIA', 'FABBRICATO IN TAILANDIA', '태국 생산', 0);

INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('ARMHOLE + BOTTOM + POCKET', 0, '夹圈+脚围+口袋', '夾圈+腳圍+口袋');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BACK', 0, '后幅', '後幅');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BACK BODY', 0, '后幅', '後幅');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BACK BODY+LINING', 0, '后幅+ 里布', '後幅+ 裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BELT', 0, '腰带', '腰帶');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BLOCKING', 0, '拼幅', '拼幅');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BODY ', 0, '大身', '大身');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BODY LINING', 0, '大身里布', '大身裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BOTTOM', 0, '下身', '下身');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BUCKLE', 0, '扣', '扣');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COATING', 0, '涂层', '塗層');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR', 0, '领', '領');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+BOTTOM', 0, '领+脚围', '領+腳圍');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+BOTTOM+POCKET OPENING', 0, '领+脚围+袋口', '領+腳圍+袋口');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+CUFF', 0, '领+袖口', '領+袖口');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+CUFF+BOTTOM', 0, '领+袖口+脚围', '領+袖口+腳圍');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+CUFF+BOTTOM+POCKET OPENING', 0, '领+袖口+脚围+袋口', '領+袖口+腳圍+袋口');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+CUFF+POCKET OPENING', 0, '领+袖口+袋口', '領+袖口+袋口');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+PIN-TUCK+SLEEVE SLIT+CUFF', 0, '领+打褶+袖叉+袖', '領+打褶+袖叉+袖');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+PIN-TUCK+SLEEVE SLIT+CUFF+PLACKET', 0, '领+打褶+袖叉+袖+前筒', '領+打褶+袖叉+袖+前筒');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+PLACKET+RUFFLE+BACK YOKE LINING', 0, '领+前筒+毛+担干里布', '領+前筒+毛+擔幹裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('COLLAR+SLEEVES', 0, '领+袖', '領+袖');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('CONTRAST', 0, '撞布', '撞布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('CUFF', 0, '袖口', '袖口');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('CUFF+BOTTOM', 0, '袖口+脚围', '袖口+腳圍');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('CUFF+BOTTOM+POCKET OPENING', 0, '袖口+脚围+袋口', '袖口+腳圍+袋口');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('DETACHABLE FUR', 0, '可拆毛', '可拆毛');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('DETACHABLE LINING', 0, '可拆里布', '可拆裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('DETACHED FUR', 0, '可拆毛', '可拆毛');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('FACE', 0, '正面', '正面');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('FRONT', 0, '前幅', '前幅');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('FRONT BLOCKING', 0, '前幅拼幅', '前幅拼幅');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('FRONT BODY', 0, '前幅', '前幅');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('FUR', 0, '毛', '毛');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('HOOD', 0, '帽', '帽');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('HOOD + BODY LINING', 0, '帽+大身里布', '帽+大身裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('HOOD + SLEEVE LINING', 0, '帽+袖里布', '帽+袖裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('HOOD LINING', 0, '帽里布', '帽裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('INNERSHELL', 0, '内里', '內裡');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('JACKET', 0, '夹克', '夾克');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('KNIT FABRIC', 0, '针织布', '針織布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('LINING', 0, '里布', '裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('LOWER BODY LINING + SLEEVE LINING', 0, '下身里布+袖子里布', '下身裡布+袖子裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('LOWER BODY LINING + SLEEVE LINING + HOOD LINING', 0, '下身里布+袖子里布+帽里布', '下身裡布+袖子裡布+帽裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('LOWER BODY+SLEEVE+HOOD LINING', 0, '下身+袖子+帽里布', '下身+袖子+帽裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('MESH', 0, '网眼布', '網眼布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('OUTERSHELL', 0, '外层面布', '外層面布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('PATCH FABRIC', 0, '贴布', '貼布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('POCKET OPENING', 0, '袋口', '袋口');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SHELL FABRIC', 0, '面料', '面料');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SHELL FABRIC (BACK)', 0, '面料（反面）', '面料（反面）');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SHELL FABRIC (FACE)', 0, '面料（正面）', '面料（正面）');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SHORTS', 0, '短裤', '短褲');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SLEEVE LINING', 0, '袖子里', '袖子裡');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SLEEVES', 0, '袖子', '袖子');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('TRIM', 0, '配件', '配件');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('UPPER BODY LINING ', 0, '上身里布', '上身裡布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('UPPER BODY LINING + HOOD LINING', 0, '上身里布+帽布', '上身裡布+帽布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('WOVEN FABRIC', 0, '梭织布', '梭織布');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('BASE', 0, NULL, NULL);
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('PANTCOURT', 0, NULL, NULL);
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('PEAK', 0, NULL, NULL);
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('PILE ', 0, NULL, NULL);
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('PADDING', 0, '填充物', '塡充物');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('FILLING', 0, '填充物', '塡充物');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SLEEVE PADDING', 0, '袖子填充物', '袖子塡充物');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('WRIST', 0, NULL, NULL);
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('WRIST OF SHIRT', 0, NULL, NULL);
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SHELL FABRIC 1', 0, '面料 1', '面料 1');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('SHELL FABRIC 2', 0, '面料 2', '面料 2');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('LINING 1', 0, '里布 1', '裡布 1');
INSERT INTO "bossini_parts" ("content", "status", "content_s_c", "content_t_c") VALUES ('LINING 2', 0, '里布 2', '裡布 2');

INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL727709', 'Care Label(Nylon quality) for all market', '个', '0.110000', '0.125000', 0, 'C', NULL, 'Nylon', '01PL727709', '01PL727709');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL690408', 'TWN original label(nylon quality)', '个', '0.073000', '0.083000', 0, 'CO', NULL, 'Nylon', '01PL690408', '01PL690408');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL731409', 'Exp-XLG original label(nylon quality)', '个', '0.041400', '0.047000', 0, 'CO', NULL, 'Nylon', '01PL731409', '01PL731409');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('Style label-1', 'nylon quality', '个', '0.015400', '0.017500', 0, 'S', NULL, 'Nylon', 'Style label-1', 'Style label-1');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL785010', 'care instruction label for jeans(nylon quality)', '个', '0.040500', '0.046000', 0, 'F', NULL, 'Nylon', '01PL785010', '01PL785010');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02PL787410', ' Down care  label for all market (Nylon quality) ', '个', '0.044000', '0.050000', 0, 'D', NULL, 'Nylon', '02PL787410', '02PL787410');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02PL671007(A)', 'Korea Nylone barcode label', '个', '0.140800', '0.160000', 0, 'KC', NULL, 'Nylon', '02PL671007(A)', '02PL671007(A)');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02PL671007(B)', 'Korea Nylone barcode label', '个', '0.140800', '0.160000', 0, 'KC', NULL, 'Nylon', '02PL671007(B)', '02PL671007(B)');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('Style label-2', 'Satin', '个', '0.015400', '0.017500', 0, 'S', NULL, 'Satin', 'Style label-2', 'Style label-2');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL731409AA', 'Exp-XLG original label (Satin)', '个', '0.059800', '0.068000', 0, 'CO', NULL, 'Satin', '01PL731409AA', '01PL731409AA');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL690408AA', 'TWN origin label (Satin)', '个', '0.073000', '0.083000', 0, 'CO', NULL, 'Satin', '01PL690408AA', '01PL690408AA');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02PL787410AA', ' Down care  label for all market (Satin quality)', '个', '0.059400', '0.067500', 0, 'D', NULL, 'Satin', '02PL787410AA', '02PL787410AA');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('08PL727809', 'Care Label for all market(Satin)', '个', '0.127600', '0.145000', 0, 'C', NULL, 'Satin', '08PL727809', '08PL727809');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02HT67120799', 'Korea barcode hang tag', '个', '0.114400', '0.130000', 0, 'KC', NULL, NULL, '02HT67120799', '02HT67120799');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT79251001', '50*130mm', '个', '0.102100', '0.116000', 0, 'F', NULL, NULL, '01HT79251001', '01HT79251001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT79261001', '50*130mm', '个', '0.102100', '0.116000', 0, 'F', NULL, NULL, '01HT79261001', '01HT79261001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT79271001', '50*130mm', '个', '0.102100', '0.116000', 0, 'F', NULL, NULL, '01HT79271001', '01HT79271001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02HT79331001', '50*130mm', '个', '0.102100', '0.116000', 0, 'F', NULL, NULL, '02HT79331001', '02HT79331001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79341001', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79341001', '02BC79341001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79341002', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79341002', '02BC79341002');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79341003', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79341003', '02BC79341003');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79341004', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79341004', '02BC79341004');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL689008', 'Exp-SAS original label(nylon quality)', '个', '0.059800', '0.068000', 0, 'CO', NULL, 'Nylon', '01PL689008 线口位于左方', '01PL689008_l');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL689008AA', 'Exp-SAS original label(Satin)', '个', '0.059800', '0.068000', 0, 'CO', NULL, 'Satin', '01PL689008AA 线口位于左方', '01PL689008AA_l');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79341005', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79341005', '02BC79341005');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79351001', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79351001', '02BC79351001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79351002', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79351002', '02BC79351002');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79351003', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79351003', '02BC79351003');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79351004', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79351004', '02BC79351004');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79351005', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79351005', '02BC79351005');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79361001', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79361001', '02BC79361001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79361002', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79361002', '02BC79361002');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79361003', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79361003', '02BC79361003');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79361004', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79361004', '02BC79361004');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02BC79361005', '42 X135 mm', '个', '0.092400', '0.105000', 0, 'W', NULL, NULL, '02BC79361005', '02BC79361005');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02HT76791001', 'Silk touch padding', '个', '0.083600', '0.095000', 0, 'F', NULL, NULL, '02HT76791001', '02HT76791001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT76871001', '"two-ply cotton"', '个', '0.061600', '0.070000', 0, 'F', NULL, NULL, '01HT76871001', '01HT76871001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT76811001', 'W/R contemporary fit', '个', '0.056300', '0.064000', 0, 'F', NULL, NULL, '01HT76811001', '01HT76811001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT76821001', 'W/R comfort fit ', '个', '0.056300', '0.064000', 0, 'F', NULL, NULL, '01HT76821001', '01HT76821001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT76831001', 'W/R pleated', '个', '0.056300', '0.064000', 0, 'F', NULL, NULL, '01HT76831001', '01HT76831001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT74970901', 'straight cut', '个', '0.052800', '0.060000', 0, 'F', NULL, NULL, '01HT74970901', '01HT74970901');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT74980901', 'slim fit', '个', '0.052800', '0.060000', 0, 'F', NULL, NULL, '01HT74980901', '01HT74980901');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT74990901', 'loose fit', '个', '0.052800', '0.060000', 0, 'F', NULL, NULL, '01HT74990901', '01HT74990901');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT75470901', 'low rider', '个', '0.052800', '0.060000', 0, 'F', NULL, NULL, '01HT75470901', '01HT75470901');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT75480901', 'flare fit', '个', '0.052800', '0.060000', 0, 'F', NULL, NULL, '01HT75480901', '01HT75480901');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT75510901', ' comfort fit', '个', '0.052800', '0.060000', 0, 'F', NULL, NULL, '01HT75510901', '01HT75510901');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT75000901', 'Contemporary fit', '个', '0.052800', '0.060000', 0, 'F', NULL, NULL, '01HT75000901', '01HT75000901');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT76891001', 'light-weight denim hangtag', '个', '0.073000', '0.083000', 0, 'F', NULL, NULL, '01HT76891001', '01HT76891001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01HT77361001', 'Expandable waistband tag', '个', '0.085400', '0.097000', 0, 'F', NULL, NULL, '01HT77361001', '01HT77361001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('02HT76791001', 'Silk touch padding', '个', '0.083600', '0.095000', 0, 'F', NULL, NULL, '02HT76791001', '02HT76791001');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL689008AA', 'Exp-SAS original label(Satin)', '个', '0.059800', '0.068000', 0, 'CO', NULL, 'Satin', '01PL689008AA 线口位于右方', '01PL689008AA_r');
INSERT INTO "bossini_item" ("item_code", "description", "unit", "rmb_price", "hk_price", "active", "item_type", "label_type", "component", "display", "img") VALUES ('01PL689008', 'Exp-SAS original label(nylon quality)', '个', '0.059800', '0.068000', 0, 'CO', NULL, 'Nylon', '01PL689008 线口位于右方', '01PL689008_r');


commit;