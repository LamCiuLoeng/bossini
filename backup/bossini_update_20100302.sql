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


CREATE TABLE bossini_parts
(
  id serial NOT NULL,
  "content" character varying(100),
  status integer,
  CONSTRAINT bossini_parts_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE bossini_parts OWNER TO postgres;