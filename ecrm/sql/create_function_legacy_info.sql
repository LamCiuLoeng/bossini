CREATE TABLE bossini_fc_legacy_code
(
  id serial NOT NULL,
  legacy_code character varying(20),
  status integer,
  CONSTRAINT bossini_fc_legacy_code_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_fc_legacy_code OWNER TO postgres;

-- Table: bossini_function_card_info

-- DROP TABLE bossini_function_card_info;

CREATE TABLE bossini_function_card_info
(
  id serial NOT NULL,
  order_info_id integer,
  card_type character varying(50),
  item_id integer,
  qty integer,
  active integer,
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


-- Table: legacy_function

-- DROP TABLE legacy_function;

CREATE TABLE legacy_function
(
  legacy_id integer NOT NULL,
  function_id integer NOT NULL
)
WITH (OIDS=FALSE);
ALTER TABLE legacy_function OWNER TO postgres;
