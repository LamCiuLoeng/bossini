-- Table: bossini_care_label_info

-- DROP TABLE bossini_care_label_info;

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
  CONSTRAINT others_drying_id_exists FOREIGN KEY (others_drying_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT washing_id_exists FOREIGN KEY (washing_id)
      REFERENCES bossini_care_instruction (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_care_label_info OWNER TO postgres;



-- Table: bossini_care_label_component_header

-- DROP TABLE bossini_care_label_component_header;

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



-- Table: bossini_care_label_component_detail

-- DROP TABLE bossini_care_label_component_detail;

CREATE TABLE bossini_care_label_component_detail
(
  id serial NOT NULL,
  percentage integer,
  component_id integer,
  CONSTRAINT bossini_care_label_component_detail_pkey PRIMARY KEY (id),
  CONSTRAINT component_id_exists FOREIGN KEY (component_id)
      REFERENCES bossini_fiber_content (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_care_label_component_detail OWNER TO postgres;



-- Table: legacy_carelabel

-- DROP TABLE legacy_carelabel;

CREATE TABLE legacy_carelabel
(
  legacy_id integer NOT NULL,
  carelabel_id integer NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE legacy_carelabel OWNER TO postgres;
