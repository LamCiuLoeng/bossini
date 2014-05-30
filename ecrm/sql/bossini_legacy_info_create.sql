-- Table: bossini_legacy_info

-- DROP TABLE bossini_legacy_info;

CREATE TABLE bossini_legacy_info
(
  id serial NOT NULL,
  legacy_code character varying(20),
  main_label character varying(20),
  size_label character varying(20),
  hang_tag character varying(20),
  waist_card character varying(20),
  inseamx character varying(10),
  inseamy character varying(10),
  cat character varying(20),
  is_hang_tag_for_all_market integer,
  is_waist_card_for_all_market integer,
  create_date timestamp without time zone,
  status integer,
  CONSTRAINT bossini_legacy_info_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_legacy_info OWNER TO postgres;
