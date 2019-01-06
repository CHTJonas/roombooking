SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id bigint NOT NULL,
    name character varying NOT NULL,
    notes text,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    repeat_until date,
    repeat_mode integer DEFAULT 0 NOT NULL,
    purpose integer NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    venue_id bigint NOT NULL,
    user_id bigint NOT NULL,
    camdram_model_type character varying,
    camdram_model_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- Name: camdram_productions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camdram_productions (
    id bigint NOT NULL,
    camdram_id integer NOT NULL,
    max_bookings integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: camdram_productions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.camdram_productions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: camdram_productions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.camdram_productions_id_seq OWNED BY public.camdram_productions.id;


--
-- Name: camdram_societies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camdram_societies (
    id bigint NOT NULL,
    camdram_id integer NOT NULL,
    max_bookings integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: camdram_societies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.camdram_societies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: camdram_societies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.camdram_societies_id_seq OWNED BY public.camdram_societies.id;


--
-- Name: camdram_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.camdram_tokens (
    id bigint NOT NULL,
    access_token character varying NOT NULL,
    refresh_token character varying NOT NULL,
    expires_at integer NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: camdram_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.camdram_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: camdram_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.camdram_tokens_id_seq OWNED BY public.camdram_tokens.id;


--
-- Name: log_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log_events (
    id bigint NOT NULL,
    logable_type character varying,
    logable_id bigint,
    outcome integer,
    action character varying,
    interface integer,
    ip inet,
    user_agent character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: log_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_events_id_seq OWNED BY public.log_events.id;


--
-- Name: provider_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_accounts (
    id bigint NOT NULL,
    provider character varying NOT NULL,
    uid character varying NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: provider_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.provider_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provider_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.provider_accounts_id_seq OWNED BY public.provider_accounts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    blocked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.venues (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: venues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.venues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.venues_id_seq OWNED BY public.venues.id;


--
-- Name: version_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_associations (
    id bigint NOT NULL,
    version_id integer,
    foreign_key_name character varying NOT NULL,
    foreign_key_id integer
);


--
-- Name: version_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.version_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.version_associations_id_seq OWNED BY public.version_associations.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_subtype character varying,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object jsonb,
    object_changes jsonb,
    transaction_id integer,
    ip inet,
    user_agent character varying,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- Name: camdram_productions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camdram_productions ALTER COLUMN id SET DEFAULT nextval('public.camdram_productions_id_seq'::regclass);


--
-- Name: camdram_societies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camdram_societies ALTER COLUMN id SET DEFAULT nextval('public.camdram_societies_id_seq'::regclass);


--
-- Name: camdram_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camdram_tokens ALTER COLUMN id SET DEFAULT nextval('public.camdram_tokens_id_seq'::regclass);


--
-- Name: log_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_events ALTER COLUMN id SET DEFAULT nextval('public.log_events_id_seq'::regclass);


--
-- Name: provider_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_accounts ALTER COLUMN id SET DEFAULT nextval('public.provider_accounts_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: venues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venues ALTER COLUMN id SET DEFAULT nextval('public.venues_id_seq'::regclass);


--
-- Name: version_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_associations ALTER COLUMN id SET DEFAULT nextval('public.version_associations_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: camdram_productions camdram_productions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camdram_productions
    ADD CONSTRAINT camdram_productions_pkey PRIMARY KEY (id);


--
-- Name: camdram_societies camdram_societies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camdram_societies
    ADD CONSTRAINT camdram_societies_pkey PRIMARY KEY (id);


--
-- Name: camdram_tokens camdram_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camdram_tokens
    ADD CONSTRAINT camdram_tokens_pkey PRIMARY KEY (id);


--
-- Name: log_events log_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_events
    ADD CONSTRAINT log_events_pkey PRIMARY KEY (id);


--
-- Name: provider_accounts provider_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_accounts
    ADD CONSTRAINT provider_accounts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: version_associations version_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_associations
    ADD CONSTRAINT version_associations_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_bookings_on_approved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_approved ON public.bookings USING btree (approved) WHERE (approved = false);


--
-- Name: index_bookings_on_camdram_model_type_and_camdram_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_camdram_model_type_and_camdram_model_id ON public.bookings USING btree (camdram_model_type, camdram_model_id);


--
-- Name: index_bookings_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_created_at ON public.bookings USING btree (created_at DESC);


--
-- Name: index_bookings_on_end_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_end_time ON public.bookings USING btree (end_time);


--
-- Name: index_bookings_on_repeat_mode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_repeat_mode ON public.bookings USING btree (repeat_mode) WHERE (repeat_mode <> 0);


--
-- Name: index_bookings_on_repeat_until; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_repeat_until ON public.bookings USING btree (repeat_until);


--
-- Name: index_bookings_on_start_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_start_time ON public.bookings USING btree (start_time);


--
-- Name: index_bookings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_user_id ON public.bookings USING btree (user_id);


--
-- Name: index_bookings_on_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookings_on_venue_id ON public.bookings USING btree (venue_id);


--
-- Name: index_camdram_productions_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_camdram_productions_on_active ON public.camdram_productions USING btree (active) WHERE (active = true);


--
-- Name: index_camdram_productions_on_camdram_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_camdram_productions_on_camdram_id ON public.camdram_productions USING btree (camdram_id);


--
-- Name: index_camdram_societies_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_camdram_societies_on_active ON public.camdram_societies USING btree (active) WHERE (active = true);


--
-- Name: index_camdram_societies_on_camdram_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_camdram_societies_on_camdram_id ON public.camdram_societies USING btree (camdram_id);


--
-- Name: index_camdram_tokens_on_access_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_camdram_tokens_on_access_token ON public.camdram_tokens USING btree (access_token);


--
-- Name: index_camdram_tokens_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_camdram_tokens_on_created_at ON public.camdram_tokens USING btree (created_at DESC);


--
-- Name: index_camdram_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_camdram_tokens_on_refresh_token ON public.camdram_tokens USING btree (refresh_token);


--
-- Name: index_camdram_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_camdram_tokens_on_user_id ON public.camdram_tokens USING btree (user_id);


--
-- Name: index_log_events_on_interface; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_events_on_interface ON public.log_events USING btree (interface);


--
-- Name: index_log_events_on_ip; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_events_on_ip ON public.log_events USING btree (ip);


--
-- Name: index_log_events_on_logable_type_and_logable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_events_on_logable_type_and_logable_id ON public.log_events USING btree (logable_type, logable_id);


--
-- Name: index_provider_accounts_on_provider_and_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_provider_accounts_on_provider_and_uid ON public.provider_accounts USING btree (provider, uid);


--
-- Name: index_provider_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_provider_accounts_on_user_id ON public.provider_accounts USING btree (user_id);


--
-- Name: index_users_on_admin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_admin ON public.users USING btree (admin) WHERE (admin = true);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_version_associations_on_foreign_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_foreign_key ON public.version_associations USING btree (foreign_key_name, foreign_key_id);


--
-- Name: index_version_associations_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_version_associations_on_version_id ON public.version_associations USING btree (version_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_versions_on_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_transaction_id ON public.versions USING btree (transaction_id);


--
-- Name: provider_accounts fk_rails_07f393d2fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_accounts
    ADD CONSTRAINT fk_rails_07f393d2fd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bookings fk_rails_40fc3317ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT fk_rails_40fc3317ee FOREIGN KEY (venue_id) REFERENCES public.venues(id);


--
-- Name: camdram_tokens fk_rails_bf0aa722d0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.camdram_tokens
    ADD CONSTRAINT fk_rails_bf0aa722d0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bookings fk_rails_ef0571f117; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT fk_rails_ef0571f117 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('1'),
('10'),
('11'),
('2'),
('3'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9');


