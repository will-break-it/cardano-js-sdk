--
-- PostgreSQL database dump
--

-- Dumped from database version 12.16
-- Dumped by pg_dump version 12.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: stake_pool; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE stake_pool WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


ALTER DATABASE stake_pool OWNER TO postgres;

\connect stake_pool

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgboss; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgboss;


ALTER SCHEMA pgboss OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: job_state; Type: TYPE; Schema: pgboss; Owner: postgres
--

CREATE TYPE pgboss.job_state AS ENUM (
    'created',
    'retry',
    'active',
    'completed',
    'expired',
    'cancelled',
    'failed'
);


ALTER TYPE pgboss.job_state OWNER TO postgres;

--
-- Name: stake_pool_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stake_pool_status_enum AS ENUM (
    'activating',
    'active',
    'retired',
    'retiring'
);


ALTER TYPE public.stake_pool_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archive; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.archive (
    id uuid NOT NULL,
    name text NOT NULL,
    priority integer NOT NULL,
    data jsonb,
    state pgboss.job_state NOT NULL,
    retrylimit integer NOT NULL,
    retrycount integer NOT NULL,
    retrydelay integer NOT NULL,
    retrybackoff boolean NOT NULL,
    startafter timestamp with time zone NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval NOT NULL,
    createdon timestamp with time zone NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone NOT NULL,
    on_complete boolean NOT NULL,
    output jsonb,
    archivedon timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.archive OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state NOT NULL,
    retrylimit integer DEFAULT 0 NOT NULL,
    retrycount integer DEFAULT 0 NOT NULL,
    retrydelay integer DEFAULT 0 NOT NULL,
    retrybackoff boolean DEFAULT false NOT NULL,
    startafter timestamp with time zone DEFAULT now() NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval DEFAULT '00:15:00'::interval NOT NULL,
    createdon timestamp with time zone DEFAULT now() NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone DEFAULT (now() + '14 days'::interval) NOT NULL,
    on_complete boolean DEFAULT false NOT NULL,
    output jsonb,
    block_slot integer
);


ALTER TABLE pgboss.job OWNER TO postgres;

--
-- Name: schedule; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.schedule (
    name text NOT NULL,
    cron text NOT NULL,
    timezone text,
    data jsonb,
    options jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.schedule OWNER TO postgres;

--
-- Name: subscription; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.subscription (
    event text NOT NULL,
    name text NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.subscription OWNER TO postgres;

--
-- Name: version; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.version (
    version integer NOT NULL,
    maintained_on timestamp with time zone,
    cron_on timestamp with time zone
);


ALTER TABLE pgboss.version OWNER TO postgres;

--
-- Name: block; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.block (
    height integer NOT NULL,
    hash character(64) NOT NULL,
    slot integer NOT NULL
);


ALTER TABLE public.block OWNER TO postgres;

--
-- Name: block_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.block_data (
    block_height integer NOT NULL,
    data bytea NOT NULL
);


ALTER TABLE public.block_data OWNER TO postgres;

--
-- Name: current_pool_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_pool_metrics (
    stake_pool_id character(56) NOT NULL,
    slot integer,
    minted_blocks integer,
    live_delegators integer,
    active_stake bigint,
    live_stake bigint,
    live_pledge bigint,
    live_saturation numeric,
    active_size numeric,
    live_size numeric,
    last_ros numeric,
    ros numeric
);


ALTER TABLE public.current_pool_metrics OWNER TO postgres;

--
-- Name: pool_delisted; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_delisted (
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_delisted OWNER TO postgres;

--
-- Name: pool_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_metadata (
    id integer NOT NULL,
    ticker character varying NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    homepage character varying NOT NULL,
    hash character varying NOT NULL,
    ext jsonb,
    stake_pool_id character(56),
    pool_update_id bigint NOT NULL
);


ALTER TABLE public.pool_metadata OWNER TO postgres;

--
-- Name: pool_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_metadata_id_seq OWNER TO postgres;

--
-- Name: pool_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_metadata_id_seq OWNED BY public.pool_metadata.id;


--
-- Name: pool_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_registration (
    id bigint NOT NULL,
    reward_account character varying NOT NULL,
    pledge numeric(20,0) NOT NULL,
    cost numeric(20,0) NOT NULL,
    margin jsonb NOT NULL,
    margin_percent real NOT NULL,
    relays jsonb NOT NULL,
    owners jsonb NOT NULL,
    vrf character(64) NOT NULL,
    metadata_url character varying,
    metadata_hash character(64),
    block_slot integer NOT NULL,
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_registration OWNER TO postgres;

--
-- Name: pool_retirement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_retirement (
    id bigint NOT NULL,
    retire_at_epoch integer NOT NULL,
    block_slot integer NOT NULL,
    stake_pool_id character(56) NOT NULL
);


ALTER TABLE public.pool_retirement OWNER TO postgres;

--
-- Name: pool_rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pool_rewards (
    id integer NOT NULL,
    stake_pool_id character(56) NOT NULL,
    epoch_length integer NOT NULL,
    epoch_no integer NOT NULL,
    delegators integer NOT NULL,
    pledge numeric(20,0) NOT NULL,
    active_stake numeric(20,0) NOT NULL,
    member_active_stake numeric(20,0) NOT NULL,
    leader_rewards numeric(20,0) NOT NULL,
    member_rewards numeric(20,0) NOT NULL,
    rewards numeric(20,0) NOT NULL,
    version integer NOT NULL
);


ALTER TABLE public.pool_rewards OWNER TO postgres;

--
-- Name: pool_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pool_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pool_rewards_id_seq OWNER TO postgres;

--
-- Name: pool_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pool_rewards_id_seq OWNED BY public.pool_rewards.id;


--
-- Name: stake_pool; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stake_pool (
    id character(56) NOT NULL,
    status public.stake_pool_status_enum NOT NULL,
    last_registration_id bigint,
    last_retirement_id bigint
);


ALTER TABLE public.stake_pool OWNER TO postgres;

--
-- Name: pool_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata ALTER COLUMN id SET DEFAULT nextval('public.pool_metadata_id_seq'::regclass);


--
-- Name: pool_rewards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards ALTER COLUMN id SET DEFAULT nextval('public.pool_rewards_id_seq'::regclass);


--
-- Data for Name: archive; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.archive (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, archivedon) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, block_slot) FROM stdin;
bb2c7699-d462-4bf3-8841-f907b219b7bb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 10:43:08.848203+00	2024-05-15 10:43:08.851173+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:43:08.848203+00	2024-05-15 10:43:08.862857+00	2024-05-15 10:51:08.848203+00	f	\N	\N
12e352d3-0d15-4c17-9512-470cc8f016e2	pool-rewards	0	{"epochNo": 4}	completed	1000000	0	30	f	2024-05-15 10:52:48.220602+00	2024-05-15 10:52:49.77283+00	4	\N	06:00:00	2024-05-15 10:52:48.220602+00	2024-05-15 10:52:49.921697+00	2024-05-29 10:52:48.220602+00	f	\N	6001
4a33ad25-d770-4a59-b1ce-82bb925b2a02	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:09:37.508044+00	2024-05-15 11:10:37.498306+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:07:37.508044+00	2024-05-15 11:10:37.507722+00	2024-05-15 11:17:37.508044+00	f	\N	\N
05c57d13-24d7-4da5-b92d-2526fcf5ea30	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:53:01.710673+00	2024-05-15 10:53:01.715088+00	\N	2024-05-15 10:53:00	00:15:00	2024-05-15 10:52:01.710673+00	2024-05-15 10:53:01.734216+00	2024-05-15 10:54:01.710673+00	f	\N	\N
af961c38-9cac-4be0-b2c4-9d7a6ca6fc72	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:11:01.152668+00	2024-05-15 11:11:02.157629+00	\N	2024-05-15 11:11:00	00:15:00	2024-05-15 11:10:02.152668+00	2024-05-15 11:11:02.173107+00	2024-05-15 11:12:01.152668+00	f	\N	\N
227a9957-91ea-4e35-9f44-3e9d2861fa3d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:54:01.732175+00	2024-05-15 10:54:01.74635+00	\N	2024-05-15 10:54:00	00:15:00	2024-05-15 10:53:01.732175+00	2024-05-15 10:54:01.766935+00	2024-05-15 10:55:01.732175+00	f	\N	\N
e2718d35-5a2d-48cc-9eca-49eb22626c8a	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:55:01.764473+00	2024-05-15 10:55:01.774968+00	\N	2024-05-15 10:55:00	00:15:00	2024-05-15 10:54:01.764473+00	2024-05-15 10:55:01.798243+00	2024-05-15 10:56:01.764473+00	f	\N	\N
0f9850bb-260f-4f0b-b694-8ab9550e4947	pool-rewards	0	{"epochNo": 5}	completed	1000000	0	30	f	2024-05-15 10:56:09.624382+00	2024-05-15 10:56:09.869626+00	5	\N	06:00:00	2024-05-15 10:56:09.624382+00	2024-05-15 10:56:09.9599+00	2024-05-29 10:56:09.624382+00	f	\N	7008
da3333e5-0f79-4c61-98ef-d5013d20d7fd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 10:43:37.463187+00	2024-05-15 10:43:37.467322+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:43:37.463187+00	2024-05-15 10:43:37.474706+00	2024-05-15 10:51:37.463187+00	f	\N	\N
d3cb00b7-22d4-4995-b5c6-11068d10b03d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:43:08.859172+00	2024-05-15 10:43:37.471362+00	\N	2024-05-15 10:43:00	00:15:00	2024-05-15 10:43:08.859172+00	2024-05-15 10:43:37.475719+00	2024-05-15 10:44:08.859172+00	f	\N	\N
b751538b-6400-4f22-a108-8de704c409ce	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:57:01.812986+00	2024-05-15 10:57:01.819545+00	\N	2024-05-15 10:57:00	00:15:00	2024-05-15 10:56:01.812986+00	2024-05-15 10:57:01.840242+00	2024-05-15 10:58:01.812986+00	f	\N	\N
569e953c-6a51-4d9a-b78e-5db410a9438a	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:58:01.838072+00	2024-05-15 10:58:01.843996+00	\N	2024-05-15 10:58:00	00:15:00	2024-05-15 10:57:01.838072+00	2024-05-15 10:58:01.861128+00	2024-05-15 10:59:01.838072+00	f	\N	\N
6fab00d0-41ef-471f-8d81-9b1ece851a43	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:59:01.859289+00	2024-05-15 10:59:01.864525+00	\N	2024-05-15 10:59:00	00:15:00	2024-05-15 10:58:01.859289+00	2024-05-15 10:59:01.879314+00	2024-05-15 11:00:01.859289+00	f	\N	\N
a222d46c-61e0-4e92-93d0-1d871e51d743	pool-rewards	0	{"epochNo": 6}	completed	1000000	0	30	f	2024-05-15 10:59:30.215942+00	2024-05-15 10:59:31.966958+00	6	\N	06:00:00	2024-05-15 10:59:30.215942+00	2024-05-15 10:59:32.072827+00	2024-05-29 10:59:30.215942+00	f	\N	8011
4fb6cec5-2da5-4024-912a-736013931bc7	pool-metadata	0	{"poolId": "pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "2510000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:08.935775+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:08.935775+00	2024-05-15 10:43:37.537277+00	2024-05-29 10:43:08.935775+00	f	\N	251
9a75865b-6744-4337-8ca8-261c0bf3d194	pool-metadata	0	{"poolId": "pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "5460000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:08.964668+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:08.964668+00	2024-05-15 10:43:37.536857+00	2024-05-29 10:43:08.964668+00	f	\N	546
b4114f75-cc17-4ae7-8902-3903d887d6d7	pool-metadata	0	{"poolId": "pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "4700000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:08.956248+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:08.956248+00	2024-05-15 10:43:37.540663+00	2024-05-29 10:43:08.956248+00	f	\N	470
811288ba-293e-4d96-8a08-9386df4b6b73	pool-metadata	0	{"poolId": "pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "6480000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:08.979988+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:08.979988+00	2024-05-15 10:43:37.541354+00	2024-05-29 10:43:08.979988+00	f	\N	648
d100967b-1aad-420f-8261-fd4320482365	pool-metadata	0	{"poolId": "pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "7290000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:08.990189+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:08.990189+00	2024-05-15 10:43:37.544512+00	2024-05-29 10:43:08.990189+00	f	\N	729
258fe898-7f26-4275-8cde-4047b77a1c15	pool-metadata	0	{"poolId": "pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "8390000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:08.99794+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:08.99794+00	2024-05-15 10:43:37.545002+00	2024-05-29 10:43:08.99794+00	f	\N	839
648493bb-3fa6-486a-b27b-586cac6f5922	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2024-05-15 10:43:09.111691+00	2024-05-15 10:43:37.507272+00	0	\N	06:00:00	2024-05-15 10:43:09.111691+00	2024-05-15 10:43:37.685464+00	2024-05-29 10:43:09.111691+00	f	\N	2014
b745775e-340b-4692-977a-27bb983b4ac3	pool-metrics	0	{"slot": 3099}	completed	0	0	0	f	2024-05-15 10:43:09.186258+00	2024-05-15 10:43:37.500839+00	\N	\N	00:15:00	2024-05-15 10:43:09.186258+00	2024-05-15 10:43:37.765408+00	2024-05-29 10:43:09.186258+00	f	\N	3099
019f3236-1dfb-4217-875b-bd267125cb12	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:44:01.47635+00	2024-05-15 10:44:01.48361+00	\N	2024-05-15 10:44:00	00:15:00	2024-05-15 10:43:37.47635+00	2024-05-15 10:44:01.508205+00	2024-05-15 10:45:01.47635+00	f	\N	\N
01777438-3238-455b-814f-39a85f36e434	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2024-05-15 10:44:07.540116+00	2024-05-15 10:44:09.510609+00	1	\N	06:00:00	2024-05-15 10:43:09.160526+00	2024-05-15 10:44:09.652044+00	2024-05-29 10:43:09.160526+00	f	\N	3021
71d83f67-ecc8-4cbc-b66a-8a4f10f88d2c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 10:45:37.477208+00	2024-05-15 10:46:37.470167+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:43:37.477208+00	2024-05-15 10:46:37.48626+00	2024-05-15 10:53:37.477208+00	f	\N	\N
c67d8158-901b-4bcf-a63e-093bf137c39d	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "pool-delist-schedule", "options": {}, "timezone": "UTC", "created_on": "2024-05-15T10:43:37.500Z", "updated_on": "2024-05-15T10:43:37.500Z"}	completed	0	0	0	f	2024-05-15 11:00:01.9123+00	2024-05-15 11:00:05.890732+00	pool-delist-schedule	2024-05-15 11:00:00	00:15:00	2024-05-15 11:00:01.9123+00	2024-05-15 11:00:05.895663+00	2024-05-29 11:00:01.9123+00	f	\N	\N
ea868104-6110-41e6-9b02-80ef10979afd	pool-delist-schedule	0	\N	completed	0	0	0	f	2024-05-15 11:00:05.893917+00	2024-05-15 11:00:05.986299+00	\N	\N	00:15:00	2024-05-15 11:00:05.893917+00	2024-05-15 11:00:06.00208+00	2024-05-29 11:00:05.893917+00	f	\N	\N
66e34395-d00c-4847-943c-9176dc580eae	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:01:01.919086+00	2024-05-15 11:01:05.92054+00	\N	2024-05-15 11:01:00	00:15:00	2024-05-15 11:00:01.919086+00	2024-05-15 11:01:05.938224+00	2024-05-15 11:02:01.919086+00	f	\N	\N
bd9b9106-f10b-42f7-ba7e-9d8a1815c2be	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:00:37.500342+00	2024-05-15 11:01:37.488841+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:58:37.500342+00	2024-05-15 11:01:37.49949+00	2024-05-15 11:08:37.500342+00	f	\N	\N
c2ee53a8-ac9e-493b-86e6-04caf74a20cf	pool-rewards	0	{"epochNo": 7}	completed	1000000	0	30	f	2024-05-15 11:02:50.228783+00	2024-05-15 11:02:52.067659+00	7	\N	06:00:00	2024-05-15 11:02:50.228783+00	2024-05-15 11:02:52.222926+00	2024-05-29 11:02:50.228783+00	f	\N	9011
d5534804-b3a8-405a-81a8-a622396911ec	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:03:01.955875+00	2024-05-15 11:03:01.973295+00	\N	2024-05-15 11:03:00	00:15:00	2024-05-15 11:02:01.955875+00	2024-05-15 11:03:01.986922+00	2024-05-15 11:04:01.955875+00	f	\N	\N
643a7843-8c25-4222-bb6f-d0084d36c360	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:05:01.008343+00	2024-05-15 11:05:02.020753+00	\N	2024-05-15 11:05:00	00:15:00	2024-05-15 11:04:02.008343+00	2024-05-15 11:05:02.036628+00	2024-05-15 11:06:01.008343+00	f	\N	\N
917aa917-f404-47e0-9e26-200b4a6d1f50	pool-rewards	0	{"epochNo": 8}	completed	1000000	0	30	f	2024-05-15 11:06:10.236853+00	2024-05-15 11:06:12.172322+00	8	\N	06:00:00	2024-05-15 11:06:10.236853+00	2024-05-15 11:06:12.265581+00	2024-05-29 11:06:10.236853+00	f	\N	10011
1889d6c3-fc7e-4e1f-9b4b-f5b9c30a1a1b	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:07:01.059171+00	2024-05-15 11:07:02.064705+00	\N	2024-05-15 11:07:00	00:15:00	2024-05-15 11:06:02.059171+00	2024-05-15 11:07:02.083561+00	2024-05-15 11:08:01.059171+00	f	\N	\N
f94d11ca-a10d-472a-95d3-c61fccb90345	pool-rewards	0	{"epochNo": 9}	completed	1000000	0	30	f	2024-05-15 11:09:30.418931+00	2024-05-15 11:09:32.274245+00	9	\N	06:00:00	2024-05-15 11:09:30.418931+00	2024-05-15 11:09:32.377638+00	2024-05-29 11:09:30.418931+00	f	\N	11012
b6adf746-6ae7-4576-a609-307157a86c64	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:10:01.12702+00	2024-05-15 11:10:02.136812+00	\N	2024-05-15 11:10:00	00:15:00	2024-05-15 11:09:02.12702+00	2024-05-15 11:10:02.155041+00	2024-05-15 11:11:01.12702+00	f	\N	\N
8e53bc15-e825-4e97-b999-adeaad501a6f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:52:01.685053+00	2024-05-15 10:52:01.692908+00	\N	2024-05-15 10:52:00	00:15:00	2024-05-15 10:51:01.685053+00	2024-05-15 10:52:01.7129+00	2024-05-15 10:53:01.685053+00	f	\N	\N
c2925d0f-c485-4e7d-9d16-b150f223c64b	pool-metadata	0	{"poolId": "pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "13170000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:09.055282+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:09.055282+00	2024-05-15 10:43:37.540939+00	2024-05-29 10:43:09.055282+00	f	\N	1317
03eaa1ce-066e-4a56-a2ae-5c25ae0b54a2	pool-metadata	0	{"poolId": "pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "12210000000000"}	completed	1000000	0	60	f	2024-05-15 10:43:09.044395+00	2024-05-15 10:43:37.490826+00	\N	\N	00:15:00	2024-05-15 10:43:09.044395+00	2024-05-15 10:43:37.545765+00	2024-05-29 10:43:09.044395+00	f	\N	1221
4965156a-bc17-4303-b294-f437001a73a9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 10:51:37.478865+00	2024-05-15 10:52:37.475075+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:49:37.478865+00	2024-05-15 10:52:37.4822+00	2024-05-15 10:59:37.478865+00	f	\N	\N
cc7af9da-1997-446b-9889-81e7c2790b6f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:45:01.506743+00	2024-05-15 10:45:01.516159+00	\N	2024-05-15 10:45:00	00:15:00	2024-05-15 10:44:01.506743+00	2024-05-15 10:45:01.529849+00	2024-05-15 10:46:01.506743+00	f	\N	\N
6fb4122d-ab00-4303-9808-095f4125f21e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:46:01.528402+00	2024-05-15 10:46:01.540362+00	\N	2024-05-15 10:46:00	00:15:00	2024-05-15 10:45:01.528402+00	2024-05-15 10:46:01.552476+00	2024-05-15 10:47:01.528402+00	f	\N	\N
ed900d5c-471d-406f-a54a-ae75f641f6b2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 10:54:37.483833+00	2024-05-15 10:55:37.479424+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:52:37.483833+00	2024-05-15 10:55:37.491537+00	2024-05-15 11:02:37.483833+00	f	\N	\N
7317f997-58a2-405d-af4f-202cd11c7c29	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:12:01.170499+00	2024-05-15 11:12:02.185171+00	\N	2024-05-15 11:12:00	00:15:00	2024-05-15 11:11:02.170499+00	2024-05-15 11:12:02.203959+00	2024-05-15 11:13:01.170499+00	f	\N	\N
ee135bd7-3e43-4bfa-bef2-b145f554c3ec	pool-rewards	0	{"epochNo": 2}	completed	1000000	0	30	f	2024-05-15 10:46:14.632724+00	2024-05-15 10:46:15.573937+00	2	\N	06:00:00	2024-05-15 10:46:14.632724+00	2024-05-15 10:46:15.714309+00	2024-05-29 10:46:14.632724+00	f	\N	4033
18f352dc-be46-4a01-ad32-c2154232d86a	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:56:01.796441+00	2024-05-15 10:56:01.798219+00	\N	2024-05-15 10:56:00	00:15:00	2024-05-15 10:55:01.796441+00	2024-05-15 10:56:01.814831+00	2024-05-15 10:57:01.796441+00	f	\N	\N
c2c3ba15-64b7-4e10-bff6-0504b9cad66f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:47:01.550817+00	2024-05-15 10:47:01.569699+00	\N	2024-05-15 10:47:00	00:15:00	2024-05-15 10:46:01.550817+00	2024-05-15 10:47:01.586285+00	2024-05-15 10:48:01.550817+00	f	\N	\N
0aed4322-11db-4461-964a-5a56ec3ca83c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 10:57:37.494614+00	2024-05-15 10:58:37.485312+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:55:37.494614+00	2024-05-15 10:58:37.497176+00	2024-05-15 11:05:37.494614+00	f	\N	\N
8af0ec51-3985-48e1-964c-c16893fdd258	pool-rewards	0	{"epochNo": 10}	completed	1000000	0	30	f	2024-05-15 11:12:49.215532+00	2024-05-15 11:12:50.374327+00	10	\N	06:00:00	2024-05-15 11:12:49.215532+00	2024-05-15 11:12:50.513792+00	2024-05-29 11:12:49.215532+00	f	\N	12006
2174758b-c61d-4045-a5a6-490feb125275	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:48:01.58483+00	2024-05-15 10:48:01.593528+00	\N	2024-05-15 10:48:00	00:15:00	2024-05-15 10:47:01.58483+00	2024-05-15 10:48:01.616863+00	2024-05-15 10:49:01.58483+00	f	\N	\N
fb02c3b1-e6d5-40e6-ba6b-d62057b2387d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:00:01.877409+00	2024-05-15 11:00:01.888954+00	\N	2024-05-15 11:00:00	00:15:00	2024-05-15 10:59:01.877409+00	2024-05-15 11:00:01.921783+00	2024-05-15 11:01:01.877409+00	f	\N	\N
deb65dc4-0d18-4f90-a82f-68da57cff914	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:49:01.613882+00	2024-05-15 10:49:05.613494+00	\N	2024-05-15 10:49:00	00:15:00	2024-05-15 10:48:01.613882+00	2024-05-15 10:49:05.635441+00	2024-05-15 10:50:01.613882+00	f	\N	\N
f0c21691-b6b3-46bc-98d8-d123259edc39	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:13:01.200983+00	2024-05-15 11:13:02.204997+00	\N	2024-05-15 11:13:00	00:15:00	2024-05-15 11:12:02.200983+00	2024-05-15 11:13:02.212228+00	2024-05-15 11:14:01.200983+00	f	\N	\N
0f8b20a1-f82e-45ab-97bf-c7439e9ab154	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2024-05-15 10:49:31.229935+00	2024-05-15 10:49:31.657841+00	3	\N	06:00:00	2024-05-15 10:49:31.229935+00	2024-05-15 10:49:31.806954+00	2024-05-29 10:49:31.229935+00	f	\N	5016
b789dbe5-9a23-4254-8947-0c3ad2c89d71	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 10:48:37.489882+00	2024-05-15 10:49:37.469957+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 10:46:37.489882+00	2024-05-15 10:49:37.477292+00	2024-05-15 10:56:37.489882+00	f	\N	\N
99658032-c1aa-40ee-8be1-42538b85b426	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:12:37.510727+00	2024-05-15 11:13:37.497353+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:10:37.510727+00	2024-05-15 11:13:37.502515+00	2024-05-15 11:20:37.510727+00	f	\N	\N
fd05b546-4ea2-41b6-85b5-74ec300e52d9	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:02:01.935316+00	2024-05-15 11:02:01.94312+00	\N	2024-05-15 11:02:00	00:15:00	2024-05-15 11:01:05.935316+00	2024-05-15 11:02:01.958249+00	2024-05-15 11:03:01.935316+00	f	\N	\N
4b1dafd4-c64c-4950-abae-20eeb899cf84	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:50:01.632707+00	2024-05-15 10:50:01.637944+00	\N	2024-05-15 10:50:00	00:15:00	2024-05-15 10:49:05.632707+00	2024-05-15 10:50:01.66371+00	2024-05-15 10:51:01.632707+00	f	\N	\N
87f5c804-e4f2-4008-8e64-3489c98672de	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 10:51:01.661647+00	2024-05-15 10:51:01.665595+00	\N	2024-05-15 10:51:00	00:15:00	2024-05-15 10:50:01.661647+00	2024-05-15 10:51:01.687267+00	2024-05-15 10:52:01.661647+00	f	\N	\N
adccc849-d350-478c-8b52-d6f3bd639f97	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:04:01.984763+00	2024-05-15 11:04:01.993932+00	\N	2024-05-15 11:04:00	00:15:00	2024-05-15 11:03:01.984763+00	2024-05-15 11:04:02.010989+00	2024-05-15 11:05:01.984763+00	f	\N	\N
f9189f3c-1dc2-418d-aefb-15ebbfe519f7	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:14:01.210669+00	2024-05-15 11:14:02.224637+00	\N	2024-05-15 11:14:00	00:15:00	2024-05-15 11:13:02.210669+00	2024-05-15 11:14:02.240178+00	2024-05-15 11:15:01.210669+00	f	\N	\N
7a48753a-da79-4376-b3a2-7bbff88f0ac5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:03:37.502395+00	2024-05-15 11:04:37.491625+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:01:37.502395+00	2024-05-15 11:04:37.504842+00	2024-05-15 11:11:37.502395+00	f	\N	\N
b389edf4-ded1-4746-995e-42db9399f508	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:15:01.237836+00	2024-05-15 11:15:02.247623+00	\N	2024-05-15 11:15:00	00:15:00	2024-05-15 11:14:02.237836+00	2024-05-15 11:15:02.263538+00	2024-05-15 11:16:01.237836+00	f	\N	\N
54e34400-e5c6-4286-9a5b-bf44718ce978	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:06:01.033718+00	2024-05-15 11:06:02.043944+00	\N	2024-05-15 11:06:00	00:15:00	2024-05-15 11:05:02.033718+00	2024-05-15 11:06:02.062161+00	2024-05-15 11:07:01.033718+00	f	\N	\N
75544aec-4eb6-4875-b232-cadbc19fa2fc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:06:37.507841+00	2024-05-15 11:07:37.493324+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:04:37.507841+00	2024-05-15 11:07:37.505242+00	2024-05-15 11:14:37.507841+00	f	\N	\N
37c23767-5b2b-4f50-90d2-08ec90613659	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:16:01.260792+00	2024-05-15 11:16:02.274645+00	\N	2024-05-15 11:16:00	00:15:00	2024-05-15 11:15:02.260792+00	2024-05-15 11:16:02.292446+00	2024-05-15 11:17:01.260792+00	f	\N	\N
02692d34-2241-41f5-888b-cf9928abf130	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:08:01.080253+00	2024-05-15 11:08:02.090022+00	\N	2024-05-15 11:08:00	00:15:00	2024-05-15 11:07:02.080253+00	2024-05-15 11:08:02.107578+00	2024-05-15 11:09:01.080253+00	f	\N	\N
5753485a-3027-4b0e-a22a-7062e9199271	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:09:01.105334+00	2024-05-15 11:09:02.114035+00	\N	2024-05-15 11:09:00	00:15:00	2024-05-15 11:08:02.105334+00	2024-05-15 11:09:02.129072+00	2024-05-15 11:10:01.105334+00	f	\N	\N
ce203776-1beb-4d4f-aacd-71d33e343772	pool-rewards	0	{"epochNo": 11}	completed	1000000	0	30	f	2024-05-15 11:16:12.619731+00	2024-05-15 11:16:14.475653+00	11	\N	06:00:00	2024-05-15 11:16:12.619731+00	2024-05-15 11:16:14.575534+00	2024-05-29 11:16:12.619731+00	f	\N	13023
5d72163d-e35f-42c6-91cc-e7cc40f81c94	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:15:37.50401+00	2024-05-15 11:16:37.499743+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:13:37.50401+00	2024-05-15 11:16:37.560773+00	2024-05-15 11:23:37.50401+00	f	\N	\N
07ea0dd4-42d4-411f-a1e9-f55e3cdcf024	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:17:01.289751+00	2024-05-15 11:17:02.293598+00	\N	2024-05-15 11:17:00	00:15:00	2024-05-15 11:16:02.289751+00	2024-05-15 11:17:02.312696+00	2024-05-15 11:18:01.289751+00	f	\N	\N
8f623129-358f-4ae7-bddb-b712f81c712e	pool-metrics	0	{"slot": 13435}	completed	0	0	0	f	2024-05-15 11:17:35.013925+00	2024-05-15 11:17:36.518616+00	\N	\N	00:15:00	2024-05-15 11:17:35.013925+00	2024-05-15 11:17:36.778315+00	2024-05-29 11:17:35.013925+00	f	\N	13435
e51ecc9a-1e90-4a9b-a168-578811194d68	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:18:01.309889+00	2024-05-15 11:18:02.313406+00	\N	2024-05-15 11:18:00	00:15:00	2024-05-15 11:17:02.309889+00	2024-05-15 11:18:02.331687+00	2024-05-15 11:19:01.309889+00	f	\N	\N
48c1d3a1-f392-43df-92a7-25844b8f60c1	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:19:01.329013+00	2024-05-15 11:19:02.333029+00	\N	2024-05-15 11:19:00	00:15:00	2024-05-15 11:18:02.329013+00	2024-05-15 11:19:02.351113+00	2024-05-15 11:20:01.329013+00	f	\N	\N
059f2fda-8e06-4b9d-ab1e-dc56977cbced	pool-rewards	0	{"epochNo": 12}	completed	1000000	0	30	f	2024-05-15 11:19:32.026131+00	2024-05-15 11:19:32.575779+00	12	\N	06:00:00	2024-05-15 11:19:32.026131+00	2024-05-15 11:19:32.71489+00	2024-05-29 11:19:32.026131+00	f	\N	14020
33a4630e-01f8-42ab-b1f0-335a2f0d91f3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:18:37.564972+00	2024-05-15 11:19:37.502094+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:16:37.564972+00	2024-05-15 11:19:37.51387+00	2024-05-15 11:26:37.564972+00	f	\N	\N
ea2f4bcb-c985-429d-b200-379138a8e9ba	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:21:37.51702+00	2024-05-15 11:22:37.504821+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:19:37.51702+00	2024-05-15 11:22:37.518387+00	2024-05-15 11:29:37.51702+00	f	\N	\N
6c198ad1-da80-4ef3-a47a-8688b269862d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:30:01.569457+00	2024-05-15 11:30:02.577206+00	\N	2024-05-15 11:30:00	00:15:00	2024-05-15 11:29:02.569457+00	2024-05-15 11:30:02.593902+00	2024-05-15 11:31:01.569457+00	f	\N	\N
35d020c8-226e-4901-b2a5-bb5db4b4e340	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:20:01.348382+00	2024-05-15 11:20:02.351305+00	\N	2024-05-15 11:20:00	00:15:00	2024-05-15 11:19:02.348382+00	2024-05-15 11:20:02.36835+00	2024-05-15 11:21:01.348382+00	f	\N	\N
dae4fd49-c2af-4ba2-89ef-795420e7524c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:31:01.591005+00	2024-05-15 11:31:02.592527+00	\N	2024-05-15 11:31:00	00:15:00	2024-05-15 11:30:02.591005+00	2024-05-15 11:31:02.610675+00	2024-05-15 11:32:01.591005+00	f	\N	\N
81d7c43a-61c8-4ace-b49a-d253366c4115	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:21:01.365757+00	2024-05-15 11:21:02.375036+00	\N	2024-05-15 11:21:00	00:15:00	2024-05-15 11:20:02.365757+00	2024-05-15 11:21:02.391463+00	2024-05-15 11:22:01.365757+00	f	\N	\N
0b147d85-9f5d-4b42-9127-0590890c0f83	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:30:37.526277+00	2024-05-15 11:31:37.511934+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:28:37.526277+00	2024-05-15 11:31:37.524331+00	2024-05-15 11:38:37.526277+00	f	\N	\N
4eb5df85-2d14-4aa6-9e56-066b87cb646c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:22:01.389183+00	2024-05-15 11:22:02.402584+00	\N	2024-05-15 11:22:00	00:15:00	2024-05-15 11:21:02.389183+00	2024-05-15 11:22:02.423052+00	2024-05-15 11:23:01.389183+00	f	\N	\N
1e46a993-e64f-4899-86a9-bf2aeba90a8b	pool-rewards	0	{"epochNo": 13}	completed	1000000	0	30	f	2024-05-15 11:22:49.835188+00	2024-05-15 11:22:50.63092+00	13	\N	06:00:00	2024-05-15 11:22:49.835188+00	2024-05-15 11:22:50.806731+00	2024-05-29 11:22:49.835188+00	f	\N	15009
92b30870-b507-4988-89f4-acf3c8e50c2a	pool-rewards	0	{"epochNo": 16}	completed	1000000	0	30	f	2024-05-15 11:32:49.420621+00	2024-05-15 11:32:50.93065+00	16	\N	06:00:00	2024-05-15 11:32:49.420621+00	2024-05-15 11:32:51.059444+00	2024-05-29 11:32:49.420621+00	f	\N	18007
051b70a5-e9b1-46e5-9d48-1f020f0e1497	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:23:01.419948+00	2024-05-15 11:23:02.423666+00	\N	2024-05-15 11:23:00	00:15:00	2024-05-15 11:22:02.419948+00	2024-05-15 11:23:02.434187+00	2024-05-15 11:24:01.419948+00	f	\N	\N
a03023c9-0c18-4b2d-a5af-50571eeb7245	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:24:01.432624+00	2024-05-15 11:24:02.446281+00	\N	2024-05-15 11:24:00	00:15:00	2024-05-15 11:23:02.432624+00	2024-05-15 11:24:02.495512+00	2024-05-15 11:25:01.432624+00	f	\N	\N
a65ed53e-6568-4288-9150-6722ec59da2d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:33:37.527216+00	2024-05-15 11:34:37.513869+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:31:37.527216+00	2024-05-15 11:34:37.521152+00	2024-05-15 11:41:37.527216+00	f	\N	\N
f99aa8d9-d186-401c-9ba9-a38d6da3ae67	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:25:01.493845+00	2024-05-15 11:25:02.468472+00	\N	2024-05-15 11:25:00	00:15:00	2024-05-15 11:24:02.493845+00	2024-05-15 11:25:02.488055+00	2024-05-15 11:26:01.493845+00	f	\N	\N
af4bfc7d-aeda-40fd-86c2-4c90955cb55f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:24:37.521576+00	2024-05-15 11:25:37.506419+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:22:37.521576+00	2024-05-15 11:25:37.512005+00	2024-05-15 11:32:37.521576+00	f	\N	\N
71e242d7-9500-4d3d-9812-e01e92eb6539	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:35:01.657631+00	2024-05-15 11:35:02.653809+00	\N	2024-05-15 11:35:00	00:15:00	2024-05-15 11:34:02.657631+00	2024-05-15 11:35:02.674516+00	2024-05-15 11:36:01.657631+00	f	\N	\N
b441220f-5233-4fd0-9406-a35a91a322fa	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:26:01.485323+00	2024-05-15 11:26:02.49251+00	\N	2024-05-15 11:26:00	00:15:00	2024-05-15 11:25:02.485323+00	2024-05-15 11:26:02.510679+00	2024-05-15 11:27:01.485323+00	f	\N	\N
86abb4c3-419b-4806-9eba-6500ad0734b1	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:36:01.671502+00	2024-05-15 11:36:02.678358+00	\N	2024-05-15 11:36:00	00:15:00	2024-05-15 11:35:02.671502+00	2024-05-15 11:36:02.688009+00	2024-05-15 11:37:01.671502+00	f	\N	\N
2354ccbb-963a-4d12-bd35-6011473ccba2	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:27:01.50787+00	2024-05-15 11:27:02.511856+00	\N	2024-05-15 11:27:00	00:15:00	2024-05-15 11:26:02.50787+00	2024-05-15 11:27:02.520755+00	2024-05-15 11:28:01.50787+00	f	\N	\N
788d9452-cbba-4e8c-80d1-07369d85cc7a	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:28:01.519314+00	2024-05-15 11:28:02.533059+00	\N	2024-05-15 11:28:00	00:15:00	2024-05-15 11:27:02.519314+00	2024-05-15 11:28:02.565174+00	2024-05-15 11:29:01.519314+00	f	\N	\N
80e80c71-d59f-4957-b147-737522e10cbb	pool-rewards	0	{"epochNo": 17}	completed	1000000	0	30	f	2024-05-15 11:36:10.620859+00	2024-05-15 11:36:11.03717+00	17	\N	06:00:00	2024-05-15 11:36:10.620859+00	2024-05-15 11:36:11.173659+00	2024-05-29 11:36:10.620859+00	f	\N	19013
31746a08-f680-4935-81ea-8d7c168a9786	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:27:37.513671+00	2024-05-15 11:28:37.509801+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:25:37.513671+00	2024-05-15 11:28:37.523181+00	2024-05-15 11:35:37.513671+00	f	\N	\N
98d18eda-1755-4787-b32f-06e134973c28	__pgboss__maintenance	0	\N	created	0	0	0	f	2024-05-15 11:39:37.525698+00	\N	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:37:37.525698+00	\N	2024-05-15 11:47:37.525698+00	f	\N	\N
8468841b-3768-49ec-b98e-9a1668d94203	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:29:01.562473+00	2024-05-15 11:29:02.55484+00	\N	2024-05-15 11:29:00	00:15:00	2024-05-15 11:28:02.562473+00	2024-05-15 11:29:02.571403+00	2024-05-15 11:30:01.562473+00	f	\N	\N
acef607e-1340-4079-8e62-6623af2815be	pool-rewards	0	{"epochNo": 14}	completed	1000000	0	30	f	2024-05-15 11:26:10.03068+00	2024-05-15 11:26:10.728171+00	14	\N	06:00:00	2024-05-15 11:26:10.03068+00	2024-05-15 11:26:10.886905+00	2024-05-29 11:26:10.03068+00	f	\N	16010
2da513f4-acd9-48ff-b6a6-1a12c2158426	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:32:01.607678+00	2024-05-15 11:32:02.60965+00	\N	2024-05-15 11:32:00	00:15:00	2024-05-15 11:31:02.607678+00	2024-05-15 11:32:02.627543+00	2024-05-15 11:33:01.607678+00	f	\N	\N
7b350a32-1eea-4f5b-b4e6-ae0ed561c34d	pool-rewards	0	{"epochNo": 15}	completed	1000000	0	30	f	2024-05-15 11:29:28.424861+00	2024-05-15 11:29:28.832129+00	15	\N	06:00:00	2024-05-15 11:29:28.424861+00	2024-05-15 11:29:28.978979+00	2024-05-29 11:29:28.424861+00	f	\N	17002
a11a039f-8b14-463d-aaf5-e845c3882c5e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:33:01.62505+00	2024-05-15 11:33:02.625201+00	\N	2024-05-15 11:33:00	00:15:00	2024-05-15 11:32:02.62505+00	2024-05-15 11:33:02.641695+00	2024-05-15 11:34:01.62505+00	f	\N	\N
b3553066-2327-450b-b225-0a04a524057d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:34:01.639976+00	2024-05-15 11:34:02.640837+00	\N	2024-05-15 11:34:00	00:15:00	2024-05-15 11:33:02.639976+00	2024-05-15 11:34:02.660266+00	2024-05-15 11:35:01.639976+00	f	\N	\N
c558a446-7ce6-4f74-bd78-68d923984784	__pgboss__cron	0	\N	created	2	0	0	f	2024-05-15 11:38:01.712957+00	\N	\N	2024-05-15 11:38:00	00:15:00	2024-05-15 11:37:02.712957+00	\N	2024-05-15 11:39:01.712957+00	f	\N	\N
9ccf53e3-e083-455d-8e84-3ed08e5797d7	__pgboss__cron	0	\N	completed	2	0	0	f	2024-05-15 11:37:01.686369+00	2024-05-15 11:37:02.698998+00	\N	2024-05-15 11:37:00	00:15:00	2024-05-15 11:36:02.686369+00	2024-05-15 11:37:02.715075+00	2024-05-15 11:38:01.686369+00	f	\N	\N
fc039743-6370-4782-a481-94b7c8459424	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-05-15 11:36:37.523187+00	2024-05-15 11:37:37.513717+00	__pgboss__maintenance	\N	00:15:00	2024-05-15 11:34:37.523187+00	2024-05-15 11:37:37.523066+00	2024-05-15 11:44:37.523187+00	f	\N	\N
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
pool-delist-schedule	0 * * * *	UTC	\N	{}	2024-05-15 10:43:37.500947+00	2024-05-15 10:43:37.500947+00
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.subscription (event, name, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.version (version, maintained_on, cron_on) FROM stdin;
20	2024-05-15 11:37:37.521551+00	2024-05-15 11:37:02.709339+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
21	1a8efbda91398862197b280aa7e139977dc19344a9ef1242938517d098861ee0	251
28	38f0299f69b6d7c406dc74ae4f07539545471167c5a9545b08d2c0d2e4391acd	338
36	4a1b48c83ad2b8e7703a3e4d54d8be2453e42e0408d5fe1b4fc8dfd38d1ffd76	470
45	df4098ff6ae3cb5bef343c99aedb9bb596025c9d8dd6d3427de07beb608c3523	546
57	10ecb039fd6177d83f640c4133cd0343ca213519a274bb19227d697f2a9e24b7	648
63	3aac53e1ab790c4b12a0d3ec4fde370f85e8654590d55fba4e832734377b3c7d	729
73	421787807a39890e52c64be85218cb150c6203a8ad36b98aa44f78b4b816fdb2	839
81	8c5f8339ad6b04d3e429009db5af89fbc3008b3ee49a3861f99cf04ac149d649	953
84	cb30caf996a5e31da1b414acabae63db730b870f833df215a26a87e015a3e51b	986
99	4eacecb73577c8709d02e04cd7ad8a84b317a11b59b3aa9d2bb46004fb798de4	1084
104	56434e8ef6328689887a30f2a48f9b05ee86d2bb76a6f470a98a32aa9d972cb0	1116
115	ab30334ec76636356197aa6980db441e3f3362703205ffd133023d62ea33abf0	1221
118	0be57b08ab1c374178b0983f32c081ad3b949361449801469c1194da2c1d57d8	1243
127	e44307a1edadbef5dfdae4657b2ef90d975b2c59327ab54c10fb70fed2096f71	1317
131	ac6a779238c2490483b3f9c26f3a5b03604a6c3886e6830c7b3ffbd3f5d485c4	1346
198	164344af810ba3673056516ae210504e1125ca524705677107071eecf5556fc1	2014
300	6e3996edd1359c5f37d5f59fce619e0b956204264ab36df4961459e6195bee18	3021
301	b40a886218a36285905bfaec526a6b7c042fa696c8c52e9fadd956f93664b7e9	3024
302	41660e41ca0cd9212433f4ef143a8bd36bdc172464afe2ef5c7ced8b125d14dc	3026
303	fa54bc54b1ac90e7ba3940b22636c6215a5563ed4d6bccd6e16d1f01faa72412	3034
304	dcc782e8059072f9775ec3ed978def64e571301ac3b73ea92923bc1f9308fa4e	3045
305	6751b8c96167f6585152e9037f31c29ce617532d54c00974e826721937170062	3047
306	da31d78c3ac85b132feef1b656f1f6b0d313442d7b6d9d2a8af9e782ffabbe8e	3048
307	a094d4e7c2752c67622863ec4b34fa7310f2a095a833eec9efb5ef5aa85d96b0	3061
308	ba95cfdabbbdcdc9db62f30ae2cac4f5feaf1f21554f68649344d128f65ba697	3073
309	0f8572c87fadf100e54b0428ab429f75dc44d53e03710de4260f54d238ad21e5	3074
310	38fba198962498d17b096d186aede5690fc353c2a5cd00c31986b6939fbe0ae1	3079
311	f0d61779053347518737242dea0c698000fe99635d932510970def485e15c7d5	3099
312	ede932edadb7121f8bbf113a5bedddbdd53df4018feda75fbd7e61c24f5bc8c3	3125
313	86ad5b520ac4d1c5b67459a2b7caa444c556a2444b494daa4d325cd70af8f44e	3158
314	9371b578850d4c179fa8cbbdb66b4f6e224c0f0afd2f6807bfee65a1a24f3103	3187
315	4a4ca09f607e9b042f337c3dcce487b9e87be9c286a6879e714aa9ef49bef844	3204
316	379c10d7169e0db8e0c8187188c6718c231076febb2131d337ca55a2f4d7f0d8	3215
317	84aced0686f4f9e625814c843c5fa2060bc013e3b3082eb90ca2ff9984eaf6df	3234
318	cc7adc3c8c8920b26269e09de5341f7364df43f82e865117e2df681ea2f4b7e7	3237
319	2459b11d0a3fb0a450b0b00e2d053f6ccae1b4b97778464c0ec27bb468965131	3259
320	ce4fa048c934b2a25f3be63521cb6bb690c922f1a03f126135fee5273ab3d746	3263
321	8452fd4450b6c4e8251f626ff91979ce44903cce3a2d082da3c375e9987445c1	3270
322	f1097c747cf44c177d8e4c5e9e512f808a650fba24049e72a1ce0081fe57b305	3283
323	741a232a3de145690c148ae68d892197936399ba03845ab3d41f429d24700bf0	3289
324	d0e1433945b6545eede573daf748a0345b89050331c57f759cb87ae128eaf1bc	3294
325	f9a2dfd7460e9f217f5c9ff771ddba99fdee6bfa10dacf61bdbd1f199b752b28	3322
326	c8fb03392789638ea2a17ec596631e012a9b88c3b67f8086a4d3ac4b94ecacb6	3350
327	891aa93f8bedb3ee4bc378222a669ef519028493cfe1a091d72e51fbb17c9c53	3359
328	64f61f2564b54cd40a4fc36bbc938bbfd49fe3a1d9b3f842845639f175510d87	3368
329	966b9a6c90968f50b6d3574adf9c24f30da84691c5173ab0c5185591284ce629	3375
330	97d820c32f00ae5df99d6b7ecaffd75ffb5f5d9fff45f77c2b3c1fb18cada696	3383
331	4d357be1f9699bca6d3aa656245be7dd3c60f1ba0c88e4dcbd0355c63f1b4890	3394
332	984d2e9561a9b9b29b9d4ff016ad27c8a0e0e180726fb6558137bb6db0d8ebe3	3410
333	be9e3cabc3f3216f10bfbc6987b2af696e24bc39d8e9ebba347de3ce9942b173	3436
334	c5a1d831af300eced6a483ee75d1ee3765b19f02a34ba61707bd4a41aa3ceff3	3437
335	4c43853b4336f9d3ef99cac18cca10cb51a98128730cd68d98b44c9ef3f29f7c	3441
336	f149549de53a1532495ccc304b9627865dc3247c41f55fb3b769a8ba0a72d0aa	3447
337	ee79ec028f9e183d8c571030336f34c09cfca6d54b6a2b70b79e15171a1abc6b	3472
338	7f163e6f9473154fbeea9a8363c1882e91fd9f8edc58f163abf5fd2e5291466e	3481
339	857d371cf599dfcf9be604ba45cd5ce912450b9148e410fdde4f217a16e267b7	3482
340	c8e8f6ee8abce78b1abde1a1667e37f804ad50ab4d00e2e37985de6128fc1006	3483
341	1a08250713e6bacfc9ea479e36e612d4779ea85c39a7562a9f7284678ad43668	3489
342	9e5b99104f69d4aa7d61a60561e443f6795d29ec2d6f880640bbb3e503018bae	3490
343	b89caebcdb704a5fe61f19a2ad244a25a110d42ff9d019439721e1c281f21661	3496
344	9363b823111e99ea236ad52f7b2a328418e62e70954549a2ddb4076238bb028f	3509
345	3a77ab35f6830aaa390f4ccd1e6915ad098473566e75e1acf27be88d17e6a15c	3516
346	75ec89382854fc88e97a677260aab63ed0a0610aebe5e5d9f48d7278deb5299b	3525
347	6c124cd742201fc03966a0e491fb5f4e808240b5e5654887f3e0d48c10882fab	3560
348	a15f493496befbc81f90ee2488043c6498f2ea215f945886a050c27a5c972ced	3587
349	75b45912f5d247af93b5e52f6b03aa632378cc1e395eeada080e425a0921dc82	3600
350	e853fe26749c6cebc5593b459b0b10879197e8409d39f718c9b61c3e6806de3d	3610
351	bad50b99b2cb2626e44b2a5bf24f1e9dc80d9f4333fb564358c5d25160c1e892	3612
352	0d50f05de2ca994be5a00897f2be6401889c690feaa2bf1ef21b090a4933a79b	3613
353	87a2952c68496e97a6dcece683d2d865b5b24a60e11255512aa25fa93715a3d9	3624
354	5412d19e592933694574901cf0039883919d90ed611aa8ef19a3e815fbc0d8fc	3626
355	d780a3581ebe24ddfa65f6f7a153735531fa21d592140fced242c9f193d0eaf2	3629
356	faa719cf5f90ecab65e458d47a1f906f8a12a0890f63abd6b14f2e4a210ace94	3635
357	9746b16d3d2d534f8bb7a484a3095d84731f744efabb243a514ea43ad3b079ce	3647
358	5abf8cd724b78f1ba7be7b8ce3859db25f7e358deb71be9f71c7bcc657f4ccf8	3651
359	c4f0aec04e0d4d761f29acc98bc510d62358fb02274980fcb2eb49f6f49520a3	3662
360	52b6d9a915cf0e8967cf9a8768395803ba629daabfb0c63e9da3db2df46de8b7	3672
361	a5d7ebad04577be92e0f7b9a97db24120713a754070e90bfe8b8282df5d5e1fc	3693
362	f6a08a0f52665c19129ca3db31534c765a6ab60e46436ae6056133d626fc23c0	3694
363	99c9d740aa04b5579451d93a4d0b9b523a9fd319a5b90eb20846fbb1354a736c	3701
364	c72021c9e1ecd94f4692eef4e17d4cc56b3e85c3e17acdc29aafd8ccd5ef5eac	3705
365	9bd9b59521898a0655b16577ee7a852b3b2ea80619fc41668224edcef49b7417	3716
366	f50bbde0b4e8c4837a79c48a07d85e2127b31bb27ab4f2fdca92de51ff409395	3719
367	99fbf09b984337e9d0b6bca484d85d79d8fd806bf12d9e3d47c0828b680f3d6e	3720
368	3ca051acc3ed5c95e71f4766bb3cd413187aa8d3b901ca5f1856dd4f35eb1abb	3722
369	6b5df423c6a363051987079fd2706540b7b96c1850499b6e043dc85cee49599e	3726
370	9086dc13dae9774939af08ff1a090c8ed825405101d190ea8f6f22333f002d7a	3729
371	a5adc352aedff6e61bf4286c6164ddfa175513f0c00d79414e167865c3531641	3734
372	cbd9bfd207c3383fdf25900a29ea6286587fb308c84ea8e9f69dd22b147b2f9c	3737
373	39487fb60bcb2c3c5ba13c9f098d5c2d4f29dd138adfa604c351b218148a16d5	3743
374	74063341ef4fedab5bd8733a43b1037506a2bb36c382f181b47ee0153752415f	3764
375	6575dc11342f27af2e26d69d51168d69b769ea9359a08212134eb5a88524e411	3765
376	32b499cd1fcbdbcc32c7734ebedb4a3c0d5137c04568fd21890149c80097be09	3777
377	efcabeae55b427172eb92e7e158505c8fa3eddbb7b84f24539567196bcd91f24	3780
378	cdbb1f41a2a70044fa4c34c5e985a5a39c37bab36f684f232e35a8ed011e6064	3801
379	630dd32f4b7c6a1f85c9b29d3824f48c9480e0cd15dc4066a96291277747210b	3811
380	cd6bcf87874fa8a677dedf4d0c4039256ee4233df0379a6213faf1a365403c6d	3827
381	f6aafa0c380cdc0eb5f0cdc0a65b34998b05f182e933a0f84fe2f80ebb42b33e	3835
382	0f895968d98839942b1e2d51577dc2b253cfb2969d5598cfc585ddd1dd049070	3837
383	20b52622bcfc50c506b3b9e8ea8716c3f191a41f1f2789328437ed98a2f465b8	3846
384	4c35fb63fd021df1a82e77384bbb85c419cd26bb31d021ae43f24b21e68cc0fc	3894
385	048640c7098476d49e94fa5808ad71322c56adce1ef40dddc333e9dd7654abb5	3900
386	42a5581b497f1e7a9e3e768a978fa5ffaffee9284d96ef797f6bee07b71b33d4	3901
387	080e65dd480481902053361ea542897ef40a3295b69cce4d21ad837004a68ffe	3920
388	a18c2b7a0b81caa99e51e8872dc718b98f202c9260037df4eb630857c5c52188	3923
389	4a68a8e21a7d12ae7931d7790e3fceab790a474cfc03fdf868f91876462dd3c4	3928
390	ce10d2469a2bdb6973cdf00d36a0f1fab9c63cd8f44bedbd5fddc8e2311b669a	3939
391	efcde8938913b08cab740f9e337e9dff99f224b8a89afc95e8e5115f839e3c2c	3945
392	be3449acc9b6ff4d5f437c6537a294f1063997be7ab2216efc1a1484b19f98c8	3947
393	16e3561163c375d33fdf76a498306734d0b93210b53ce4691427542086c05c34	3959
394	a1b41b3b601f875fb21e2230b3b5f8832aaf9020ecf16f4f61e1e1bb996aa592	3960
395	1f7a6d52b24fcbaf47504ce3e48edccd99b84a74e11672af259594b8576c4bd7	3961
396	0729465aa16cc92d758cab40a7ab1374f124f5c42c0c5023fc4d1054cea141fb	3984
397	17d76dc4bc48fbbc347c243b908a4c81fff943c1d3010dbadf206013f0dde75a	3990
398	17cc5fabdc27175cc83f129671b7b744b6b507ae74ebe08af7056256625deacb	4033
399	c2fb032e49c754a282af092137c88729af068f11babe82dcf2125ab656921f67	4045
400	5e2ecb8420418d3dc9c15d3f3f7f7f5895b260c4ad99db6276b8fd056aa57b3e	4083
401	6717c4fb8cc8466c7e899a699f19b06c87d9b2cf36952aff311e859fec413d04	4104
402	fd2ee859ce2e6c281f4db70f2c5fc3f8f0eb51974e1c01c6108f4062e4e39155	4106
403	709282a24a3986eec10e83dd72e286164615961e3ad0affbceabd3774a8e88a1	4167
404	58e884bf7f6364ef02bc5e825a503c72fcdb1db0caf0b9c1e9d1a4a792321744	4184
405	3bf01478a54321711563f9dd360eb644d3617103016eb6412e4a7920ccaaece5	4202
406	d90960f66e5233cb0784c04ff21cf43223cb82b869e40e8e57d688d2e3c0e545	4204
407	65f1e09d2cb434484b99169b315beab5e5b7176ce72408da25f864cfabf4a837	4214
408	bccc0dffd304c6852373a740ec1f72e98995a45802d59aa61cf5b1a0567a25af	4268
409	e63fcd506f678d349717d923856274253185b24de4c3951287e7212b0fc56b69	4273
410	02b4f5dcc8edb033273016627c6f7a6ee330d9b4b34bedf218eaa8c2c29bf7d7	4277
411	8b1b712691d890e93f9b244e9baafa56eb2f1e1fff9c9e90f505e0cb2cade5cc	4281
412	b3c3aac428e6d9ce4dd9a72c5141067d45248e6c5a544ddb7ebf373d10072eee	4292
413	72620edd6c350e7f605549fcb05dec919ead2004673f768ea91b844e98800dbd	4303
414	89d290aa407c16d4fdc7fec73a7945a974e7194ba666d13293b49c782c5bbf2c	4308
415	d223b65bd108f1d537f78f46a3bc4476c052afc3bcf4e2370408f88f3a373b5c	4309
416	b526e0e47cb38907aac3fb25e3cf4a524e3deb06f520b0c2e0be7380e9057a7d	4311
417	bd198ddc881b5d4a35af54160029af8d2c26684092b1f0a81e778c3106e975b6	4316
418	56c164db5e0293e85fa6b3fb2e56b233424d3a4dc919dfb08dccb4d23874f1bf	4324
419	5e88efe07b3cc5dd097fcc91ee4bba5edf6ed51e8d2d923b7a578957c98466a4	4326
420	1b4d7ab12bde20ec996d20420cd300a17b53ec0d4ecec4a66f8a8e2df89adc29	4332
421	3d4bb2c097fa8e3371641871bca9501a00126720bbfd79b736bdceabfed836df	4343
422	90816eb2e8e2b671e427010e1dd4d7f1691efa3007c3ae82fac052b68e975709	4345
423	c0214c5a6ae4d87d0a9f0ad8dac85f1de24aa3d86e8a33ee267c116ed957ebd9	4348
424	59259942f076f7886fc7e62613a9408c63b666918918aabe4a09c0864e0fcdde	4350
425	3465ae77a4954fe3c637799edd948201fe1b3bc92995e4f18dc4dc282414799e	4351
426	e1fe2a32561dd5d1abeb4d0581e65aa53efd37e5d6fd3f6789947cbec1b4315b	4369
427	b072488dcf2d438550f51573c7d49dee9e90b9a21efa70d231edf4bf500af127	4383
428	dedd0d1abd8950f0d7115fb1e3bd2145e46e2d99ae3e8803dcb659843b4f990f	4392
429	bd6433fedf7ad999601e7757d8df85febd2109472db7a9c21f41ee95f71ae6d5	4394
430	9b1a9e82457f6a1862408b7deaa5863439e8976178c74d5f7545c16fdf04a963	4407
431	f447497badd88344bb887f353920cea4e87c4e466369667b55e3cf536793f415	4417
432	ae406b11f0b4957e7cc4664d4af6a368ada571638624e248ec8f5a7aae4f5f46	4422
433	83cd7126909eed0da05a0b8ecd6abcb74c4f5de10053094bd72a4f318162f2ab	4435
434	65183f2cafc02c0bbc281b75c6c9fd28d180556baeb25dd4dcec95555d3e6ea3	4443
435	fd2b560aa82828e7f63b0086aa206b9c0d9f9f6d189968903b06a2e5b4e8f754	4450
436	d4c095713f86f9091440b75c54f98a0ddede3339ac1af5914fa2412ad0b05062	4457
437	27d23c4791f2118137670bb14d73af72490df565aaa79b76858263b3f9f89e7f	4463
438	83c79e705fb5abee420c5905bb67539fe8f6d8475d48f41caa2dbbf76387d51c	4479
439	7567350f15150b3f9c6ae5454ef61718eb8a0eb1be8fd4215319f28b53c57548	4480
440	a92914febcc3b49f82bf45cb35efdc4eb4f67e2c400714a06af68723e9fe04ac	4500
441	27d46b9f681b4b6095ac88002cc1597269ba94eedc5a9dcdf3c96a240b132f2d	4520
442	f95e82756691a6b3276737b29142d40bad7acb3e37b1d7a62612098fe0282a16	4524
443	ac2f57fc66a6e5b9ab54dd07d51ed3d6a285d99530dbc6d405dc7217914f0f14	4546
444	a0cf127613e082a4d1258a785aaf0b4f6395ac11a495323db4f3086f45322584	4551
445	54290d92061fdc6e17f5d5dba841bdb3cfe2c2c33569681c890a3b74194424f9	4561
446	ecae49c54c8db88f3030fac3a9fcbf14417f94dd102c4e963a4f2898c8ec0d76	4579
447	5ced26de22212083d8db1e0a2675b39c436d22d9a1df1424617a9b16230ce383	4580
448	f317643fc62cf5369f4628d2c9a456792bb1696514bffa3951a36d0860f5ed6a	4583
449	31c6e2c0983186ae3adccfb9ea00e4a69fc5226d50f85d04165b48c06714afcb	4591
450	326ec0b8e2f7d7f8fa08239a71472f26d9d3f519330d8ef5407d0195239d49a3	4596
451	fd54d1ed9855b2f353a7de1cba58d9338033f3840b211a470bc091d3e71c94b3	4605
452	bf8670ac363a726720297c7221451c2761456109e258555ba0577b3841e4c47d	4610
453	06e3f0c2566a73cfc28bf91e191f6b00739df82cda47de5768ceab482e03b6a2	4612
454	3db4ab3d11d9af383aebaa074d645e96387f07b7576b8519ff7549a6338581f5	4621
455	82d5f3a1b4448aa57a254bd42deca6dcaebab74069039c9513b438f69d05f161	4629
456	9e0a34dfb30cdc546fc52fad266e4d59af7a8759889a18ed0a8419ad445e6cab	4630
457	694d97534255f053c685800768e07ace79c35ed30f93ba6a12f85f84996312cb	4649
458	f28661a993f25571e6790468422c8643823e0ce8937b5fb3889f5ed80d9823c2	4657
459	c2b655354f669d72908cda1930b3f63079a30e3582cd52f2b363ee672e34bb8d	4658
460	c6b9c6a12c4c8242cfa6f6f30712967d46f8e8bac7de0e9fa14331a7fc435182	4680
461	5a2272dca5725a83a484f8c305e4f7cd45a6b9684e6ff3aa84d52b84839a9389	4685
462	dc0a386c6b8d29d01b3e1273c39023edaa53072dc1bf95a62e2c33bef5e4f170	4704
463	7b52b3438cc015ebc410e6d490d23e35d75675c5884e30d5d3248b440e8c1a8c	4705
464	f7ff9085570a3f4357b31057c7242a778785c17720efc1a6898384cfd3879943	4711
465	571512160a394b6f645c346530fa650097155dfc3e5e6b64b2c8fa3fcd85cb53	4713
466	2345f766d262f965f4c46373c11fa284683b421ce9d40f25fb14deae4e946404	4719
467	d2ef3f7bde8b5e3520fb5e80ea0c499364b851470e5d805614bce4ed258a6190	4721
468	fea6997114a31d0c4e3abf2a2054f7fdcb3e15a0d7c412107ea20f108a37d6dd	4735
469	dab10c49159e4a8550e3df7b3b528327ea6fd73897c12b898a9eca4fa29b87a4	4744
470	2bfe2dcfff3d72f694c788a5747a278e923aacdca509e55c598c42bcf7b826be	4745
471	0d59aabe416d94b47807e94553f301ea060b874fac83c037385471ef901b22b0	4754
472	974848a5445bcbd3be25464b23ab8f9e0450592b374cb4e73e7679f0569446c3	4763
473	1e4f8fb78492ea9d602dd240bacdd8ada1982ff6af1d11f55e962522a7d38677	4777
474	8db39f64e172ce4c8750ac80d1830c2748491e8097d6db0e26a8f736c78804ad	4778
475	778fcdcae53a20684b1f84de1bbd9ab78450a9e64b58f44c3ae0e24d43367645	4779
476	428088945ff4671d5553b961568d8b4945f309d3d0861ce546554040fdea445b	4785
477	2453634e60c180ad1f538f9fa5cf11375a76a1e6a951ea2e3192887767a451a8	4794
478	7a2c3f6f33968c806e8ef6dc6531ec53f334f0f3ab4e75e0edb7a502d71b828d	4801
479	5f9f1bfa2293865088f91b3a30c5dbdf24b36334bf5cd6b4552612a25bfa456b	4844
480	57fa3e4dfa577553e0b597bd9106087ed91f68aff17938a8be3709b7d9b9c3be	4846
481	1aba7d8bf5ed61fbce653759027f653d20327607f59f3d0c36d0ef3b2f501b94	4877
482	061c5230ad6a6a721c097c320680a3a24f1a68b0df3127575b683b3dd6dc2e07	4878
483	709f8d31d646aeba5254ae984e3823838622fde2fbd983bc417a5922fd21237a	4895
484	12a83c07805bc1a4c06d16ae45f9643c3da68311bd5b744548f0d2b948661662	4898
485	8911ed6f79e5487d753e20a6c51aed4bda0e1c851686d713b7bf81c6cd269ed3	4902
486	2557afe0321fed34ec4ee3fe8e307beaaed563d6522da4f0c6d340ea957543df	4906
487	3483b34b27b41607fc52cd4e3cdb64c3e4d2e052752befa909e97c45ee7e3aab	4928
488	4c8d212c91d6031e1bb2dd8c0aa27e748ae6a67d78112d6ff3fb6372c18c8ccf	4964
489	7689ebf54268579f02a525bdf03486ef7e78f7a7d0a30fc07e8784915a37ba7d	4969
490	456d07823149de3210391001e3b9cba09893ee7b294f67c4982fadbd39e75edb	5016
491	2b6498a9733375137f6c52e6f44e684ddf45085a4e14aa15aac88ed38bb7cf26	5024
492	5886fe71676b7c4a94e71a76f879a862ff8c7cfc3f67becf7a5004312217a787	5039
493	4ef4eb0bc8a4e9e150d577e92b5a0b5713a7be8f7edff7aa7c69d367ebf1b7a3	5040
494	524f440ad76682ff63a38102586ddf994ab4e7f6b26cf200d5d448e59f1f1615	5048
495	5f24e1f0cd7f36a1a392e51c1c029e2c314e857d7108e9bef46ca0b2282d4a20	5051
496	a9864f1801821f719cffe04c90f931e05de4af64cb734e3adf8febe423aeb667	5069
497	a4a38ae27f6722116436b4b74e75f76e188571413931483270fc31922584f839	5070
498	f710b95d608c8e7e03a421897e264e3c1ffa8b49b9128a94fd8959d766b11935	5072
499	96bd64c5639113833a7cb91bd89ad3a56ba588ea53aaeb9db074f9cb41caa445	5074
500	9a187f0ba275795d664b6da4363d26e810dc0a98fef5b833b66d62787628829b	5078
501	fcc9cee36ff6789bfe7a98def66f220c8cc60dc082bed3786e4d247777fdaad3	5080
502	0a2e628c2b09114019258073417d8ac8f306de1d3834266bfa86ec130cd4ea57	5090
503	9d981f273a7c1ff88c970f75c72a1191325882351de76733df9bc3c11d154f7c	5102
504	148628f55f5a9dc159bf686d1d86f84776cf2607431155c7808cf66f2eb676e2	5104
505	28838cc75c3a445007364bdad01b52fc10173f0349e0f5eaa7e7d6f5fb53ef08	5108
506	db9817d041042e101bf8cb28c681a303969fba9e7875da7fbc90a7234977b5d6	5141
507	de65088f710a8d58e93f611d80a57406e481e1409680db78cfca02fe4663e475	5144
508	6027b631f2cfdb39d565d7b0a8d73f4bf3392d8c79b8e6be0a1d5149690f4848	5150
509	482851453cbb6867f6cbd9155fa176b0b33aa3481afa6a13a9d887e7a4439c41	5152
510	4ffa1f42245d955b46509347231ce8734270360a7d2f308d3982e887d4aa6001	5153
511	a310d0255c9a1b736bf8ccaf96ebe59b940bf656101e7712416e15b8246278ba	5157
512	7d69200fc010841d1206e9d81b77c82e2ac3074f93e9118f3d71fe352782b268	5166
513	a6a3084b4283a2b5636d76095590bcf648202282488ed9dc15844fa63d63a108	5190
514	f8917969d63e9be01a75505e686de155db965245382cc35e5b0a809a7e13a909	5199
515	ac301f9527546b2803f344b7860f90051744ca252191e93baee607a25a983ed7	5206
516	cdbf0bbc94210983cb8d94b531ddf147b2b4f4754605267d25ab5fb21c868dc4	5224
517	008199f3516d7a610e098e8f6a56c5ec9e45abda622bae6d1d4c956bbb529aa8	5240
518	b3609d5ea37e8208f7ac9f235cad6d2111acee1ba45137102b2a3382710a4de9	5242
519	9997df7452f1deff1025242edc5f8fabf3b8f9865a4c94ebe293c66dba399204	5253
520	14935fc3da3ffe8d92d89d08186b5fbcedeab0f60ce21016cc06bcc07a11524e	5257
521	30dadf66ecd341311741d0fd416211574cc17c3dfc9ac0692228123577979a4b	5260
522	a670bee7a43409b12223ff82539b64ecb37a8e455e243904f655ecba3e29321b	5266
523	36f4882991615eb21bac90fb4ad77730062151200d41e4d9782a14f2b477a76e	5282
524	634295d275dbc13d98a37a65e2e90e19211a0a3ad2e81c3322a8cd9a3cf953ed	5299
525	6d204ffe2e94dfae3ea22163b884d132b1c7346245bf4d3267e030c1b2843938	5316
526	6eb115c54cbbd1e9440a681c7e7a7b35bf6a2547f6e20341eab9b248096711a6	5318
527	56412c385befc934a24391137b46c9de9cbc541511993d12aef9e60deafb38e2	5320
528	15359f611e57a3cd705d4382e6a1ea48ecb2bba4532695323005079c389c4084	5332
529	cfc37f3806f9ddba0725fb8aef05f94cfd6aff6b7d1f33f81e5b2653754faa04	5335
530	0acb02becee59da076a4a5a92f2acb70d0cc2adc1db3a7c0070861415d6f5f00	5337
531	cb9d10c1cb5a975986b691927f32fb77646c47f041e03e0e2ded910080b59995	5350
532	0bc7b7797d24373eab7de3a81146f92bca313d9bbbbf081bc78459a6c5add6c4	5355
533	54382437f6f7cbc154eb6b66fb7d1943555eb831338491159d57119c54aa1d67	5376
534	5ce53a6158c8ece98e1f0330645dda92acefb7586c10640d6260fe47c684d67d	5381
535	dd380f44c4bd14531a383ea405c1bad65fea4238d17193737786c42d49908d59	5433
536	40f86c5e4e088655dc771252c3d71ba2b107ef1ec6ac8db53557da1f6f6d81e8	5445
537	c4f8263c9fb5993d60d1c1c1c8531ff9f6095f47022907454b43e69c4e2e5d29	5446
538	622aff1753c751e7ec88126369029105c922dc92d2723a11f04ad72052889a25	5494
539	e844c566a0050a107d43b589d02c2932c6811b19e939159a10fbf77a34c9298b	5510
540	9203b91926e51c513a59c11664f09b5ab13ab9f7c73570fb2916c0ad70cdca70	5521
541	10339ee11b69df9183e392ee46c0b550190533917201586a6c62b12c2c37dd51	5539
542	fc0716e67d6384ad882f08185b7f9bb2cf318edbbf2a56b487cb9966dd5e295a	5552
543	6d645d2c6d5bf8ab4abb225b6e2e82317220cb90494152b3c4568cbf4e26f02b	5555
544	72fdc7b530625340c2baf02ca1089f3e100c14ae28450f6cf9996fcc62ca07ee	5561
545	8e8a7d68f20be57ef1d5b00fe0db9baff36a9ad6cb7c08d886c2174f643a1463	5571
546	198e75f4be4e998bc97de99a7b8fb5d223fd999793bca91a911579c2896e7b3f	5572
547	5bc725e5dbdf3b5406a09112252177e3d5b88d9120cf5c6692ef61abd19e248e	5574
548	c22f209d0d962f3bd0aa69899d96ad563467bcd4bda17590252124bae1594bee	5590
549	9df0315211582fde218543a73c692b97938f9647363ddcdc0ff8e0cb52e3cfc1	5594
550	410933bf8661062476990b25fda0a3fbf0f89a20afa9e6187e0031f86a8b9e45	5595
551	88cc628adb160f74bc563cbbb1a43e910c648362217398c7fdd42e32f0b0a535	5614
552	b1a4dc77aed06a61995409b9286a2cdd4a00ab57e90a3cca89139fc1585e8d1e	5619
553	50ce7ecadab9563b8e8ed88ad9df6dbd975b02b99e149a53d861c8586cdd139d	5634
554	890792bb3e0bd5edff45d80b875cdc1dcd67dbcf95748c8d0db2cebcaad58aa3	5635
555	97f4a2ee283904de22a14a470c1194245ee22ecfbd4617584e0c05d623bade81	5637
556	b26463a358af59c317ae41750550ab862c33c8c70b08f6ca60c4f2ee868ff29d	5675
557	d642262e98b3a6a01236727a1901df9b4630d90ee768c8d71908161be1220852	5685
558	8cf0f1cec1d558168a820d13fe85ea4a26bca04ca8e81829208e615d9c00f9bc	5689
559	435a6d9424a199c5b43840e2f953fe9b1054be89b8b15c268b91d137929947d8	5700
560	9645a67a6619fb3f603cdf6b8fed046060be50c45434660a4ceba391e44e2929	5701
561	aa844356e9ff7ec36ec91196298ca9e346441b13ab1bf375b7cf23886ff4d68c	5703
562	fceceb37b79ee839004e56a39eadd5155db082ce2c5ed6b81176d4284e5ad2ef	5708
563	79ed6fd5abedb43b66c59f64a0b7b0e4e6fbb370b4f4eb9d95ed24d8398f1fcf	5734
564	d33cf37cfb88e911310f78546d4db0398126fd1cbb38d62f32e0b8baf46dac21	5739
565	37b7eca2e4be657e8aa647712dc081e2417c6600098d5757ed8b5b9b4f68666b	5743
566	859369bc7c13bc5f429227b9fc747c157b6b643cb49f5500315125ce71db14c4	5752
567	2960f159df5413e47025b8316ac14b895a71d3f4a459a5134ae8c98f292ad9db	5753
568	bc7bf0db1991277ed94dd1a008f6f1342bdddf87fe4f2b3d7dde6dd89d20b9f5	5758
569	2c1017b45a37741824c9e0c13ceae87caac013ad40e553ba71ab0895cf3208a2	5761
570	e089a997724fca1d20a015458258b13f8727d8ac8703c61af038932f112accc1	5764
571	44b6e6ddca6c212fd9a9a220cf4ac83c5c5b57564ef19377af9f6e4c22b80c66	5776
572	02c9adc4f634e7e12b267f14ca17dbf11e919d8ddd98eb8f28efdad77fc79b12	5778
573	eb29252bfff26375d10b64589c96f1de296fa6f8c02144e822bf556385fb8bb5	5779
574	51dd7392a86238501c0890f7e2aaffd7a39cf8abd9d244a9927c96b81ced353b	5791
575	383e0e64ce6319a5061a157fba570561cccc97370dd7488c9bc5f26b42e1ad08	5812
576	a44e799ee62da10abe7a49066058e206ccd22e0c69d5baef7dee803506a9bee3	5827
577	0951902aa7b12488598a273b192f0a7947c6fef12e329317b0c94b8f4fa1e9b5	5830
578	142a52ebd14b06a207e3da3cac283e5f35add7143a77817dac01844452c9e7ea	5835
579	ca98a210cfd05b71b249195f30e83d966744cbabd247a80e872b34733241aad1	5840
580	1339d884bd2ce81d0ed70c283811ca487f30c72e1bc0c94a859edf9f55159ca6	5847
581	e260ea69be0f3ab711d402df288024c17b546385562b0e05d68595ca57faf995	5848
582	8218869ce6d65dabff5aef73ba4f22fcacaba6d86f2f47435a14eb5082edfb08	5863
583	fe70e18e829e4c839183bc0dcdfcd2304f1626c3dbb50b441881c06e7d2c80a6	5865
584	96f7dedee9549aa62de90c4bc7f527556c8f8a05cdad163d375b761fdbca0393	5874
585	414cd9b18270ca92cbec5dc1876b060157b18512f2e992e3808de627ba0f4149	5877
586	0ab4a703125c6da5a113cf8515e4dd5b706009fffde5baa580c04bbedc5af3b3	5887
587	eda3f1b3d434245c3aa099ec55cf07b07b3c5c8aedfffe6d736266cdf64813f0	5896
588	b531e26193fe677f0172c5bc810fb16cb517b8e1c6c2a6bc83364c5cd7e9f23d	5901
589	650376ca1599f218eaf05404f99aeb5e56d955785b2d4a65b01bd8a564420716	5946
590	c401086234668c8a1af6222177fdc9557f49b45aa4491d5e83993f95d581c56a	5972
591	961d22e487b393153f3cdc4594c013ffb278ef73401fa9660ef684e6f67f701f	6001
592	045847267ef96124b1a53a26a661690d048d44d9d7f16320c946c0aa6308515a	6011
593	02306d88907f070a54bdb2a9f7b262c3a53a16c6505911bd833b0f6d6c3cc748	6019
594	2c6b28fd834dc6f87f1e67862b408b3f11836b951677066fad307f1f5181d9af	6033
595	afb07abde31d0b0338fb9c160156eac3b5487127a64ad2ffbb9c27fa883417c3	6042
596	0c702774b004f6ff2d54f9bb29e82af4ec76ad5de67df6193894a232a5122486	6047
597	c909dc84f50e01273f6bc1f98f68caeef3907dda5453b0f0daff57aa1c1d1840	6058
598	4ee336163cdd583c6cee9e503b962de81ffda7de3109ddaf7118cda84ec4fce0	6061
599	ee094b546f081982028c5a14445f774feefa3193b125c9f9cfec50b1b0daa679	6069
600	373f1a4b684ec85a67e54ae7fd1029cc534ac96eb9035294ca21a6820e86ba93	6080
601	17e663721b448e65f8f1e9ee800b3f29012baf829d5fc6fa98f800d2361cc3bc	6081
602	30d803872b3251b15653337d9e63bc6106da10f9e56d77fb22967e3f18cf15c8	6083
603	c0a4f0e9237bd82dcd6fa5d8ff3417e7a8f46d19e7be9de38ee2bcde60713226	6084
604	f09d9e183afd52e3684d30d03098729405dc07f0325daa5ca786d74ab80f67c3	6089
605	b11b40693b287ea4e6605ac87938013f963fcc2015943f1861e9569db62e765f	6091
606	84a5c480bb9db88968ff46f6f6881a7e836bc302aaf34f762627961ebdf5873b	6128
607	43f1f85e80bcbf9b05b2d8180587ad50a4a19b3dd7550500202b5897399e3f64	6148
608	3ebf20f6a100eef37160f4009a7de62bd97a0c3d3b0fbe9dab218b18f7346321	6167
609	adcf4327a68e48ecf973beffc3c695e10fadcf00b51c2714d33671b9404044f7	6169
610	dd6ef0234aad4f25808e6345a867b57f674347278e370afe6a96a12325e196f1	6171
611	26e33bcc503527628b5572c606a5a81751b5ca454924b98e19d3a7cf86e6edff	6186
612	b862e471a23e3e513cf4593953d0be9162dd13f89c18a9d1299c8def80fb9da3	6197
613	9c04324125b22157cc84b49094e6ba6fecc531611bf96372cdeb8e7b0a7b2a09	6203
614	4688c32993f8af203ef45eeab64e993b245129b07f9b3acaf8cbb9c537e0aabc	6214
615	588d3e098deb84910ddfcc82293e6426ec66230f78eae26e903d6bc33100a859	6215
616	171a98d2286a1eadc39ae36c155b09029d4867945a9de732cd9fe2ee8b1acfec	6219
617	982a98896b2351a4bb42e158ab3551d1026b6fd4c51ef15d01c1a4ad97cef95c	6225
618	529e682bff3bf7e914777dfaa6736e353c6d487d646870255c3561e6d7132557	6228
619	971ab6479ed00e674298ef71c067f06b65a5f2b2ae363a0c45326716a7ad996a	6232
620	3142e805952b03e65fd09c8c7d0270a1ee93416d4cb0410e21ad421c3e5244a3	6236
621	1b2eb0f61cb7f8e798bd38648d107e5984d2335aff119f3e4dc185ff0df98f77	6238
622	5d114ec71c8ca69310e9dfe0f2be52c35a57ab1fa9f56b59726d913d649b2540	6247
623	a8c75b3a5d47659758bbf97d193a5e698c20b1e8f9e89c122745ee75a97cdd3b	6267
624	7f6377f51712da01db7142be777c8ecce1748051fbb3eab943df73f9fee45a63	6268
625	aa891b3308a3d7d90732b1cf55ea859f495937b21865e0895bba74c578199bf1	6278
626	c754bc4fe046389aae8b7a818c6598b032942ff5457f3aaf9098a2a0107d6df6	6302
627	0e9345e6242303cea07671f5d1b56ed4d9b946f40e97218d90fd158a8636a7c2	6306
628	ad76a15c6d7cef616aca472a58b65ba32937442269dc73dc3d1fa941844ebc03	6321
629	62872598d455b7eebc27a93628e09ae13f0bea58e189b765304f81740488f7e3	6324
630	5fb8b1f22b7603830689ca09f537aa0652893fdd9240375d1d7e0cee7e495ed5	6335
631	b358fb662891b98ce90bc477f66d198b15a75e8bf79eaa55cc529f9c9ee16776	6373
632	d00a745ef61cfdf4687d68db1c08a5a43476330d323567144b2f99ee38891ac9	6399
633	246f7d35e157292640bc80e8984bb1cfd502c62e0d4d0053dc7cf9bbf68944e3	6400
634	5e80ab9e07ae458387fadbf43b73d96a95a067290d9041b0d1273c67d13c5cbd	6403
635	c4892164b48fae09dadaae9d9875b130a43274fd9d974c1aef76c391f98d3ead	6406
636	cba44ccaf2067e80ef9f6fce11a684bcc4fccb8004af5705ee74aaf01c97850d	6407
637	c9e69f3c1fe41cbf508d13eeda0eee8a196deba314658309b56149ec4276c1b9	6411
638	4bc57cf5858527979bf64eb059a2e9889f7c5151a3813cb12046d0cd6b24d7ff	6413
639	babdf95b431ed61b22a6e699803968eaf463f5fc8a0c1d6831c9e8911073437e	6429
640	99169eeb8f6d07129ee0748c561bc30a04b6d496fbc527508c40c29a0dec97df	6435
641	76387666c0fe0d4e41fb1037de7c0b62efb684cc3b48f2409602ea6c2ec6bb9b	6439
642	6284aa3053fb9d5f0213b4dc1220126b61f3a7cd24fac72d731367ba572c2d8f	6441
643	b07968da07b1b0240ba9fa775fef0c1b138110e1824a4d153e408d7cc5d46817	6454
644	c1ae6b3f86d9a8b7737efad1c380fd84904f1435d05bf44550d882043cf16d6b	6457
645	3b4bd582c0912878d04a8dc1457962706aabb401e1d732a696d676516059c728	6477
646	6955c9f7c7caeabb3623ce8ea2aa0e5174d70aa77aeb069aff45b9a0b72edcfa	6488
647	0d2aae3a1807f323d2676a8272085fe3ee25ed19348b4708912ad66b82b1b01c	6489
648	d9305d7405d324df6e8d803a6e4c718c5c7e9e655ffe9253f5fd9f5ee00d076c	6493
649	87057fc9a5ccc9e7a44ee6a304a5102928286f67e68861749dad2ae20456edba	6513
650	a96d1f71ba904dc489f5c2338cafc09766baa9c23c126e257282e851fe5590fe	6520
651	66a29ab252da76eee6241ed1c29215caaf4675a38532f90563f2ea8d39013435	6527
652	896de96a16f3a8cc6bd21a06f3551a7efed7f8a2881163147952052f1fd8b808	6533
653	b7188186598d28961e01b54217522eb4a7600e99c8db23cf5060aabdc185e555	6534
654	c7d5f117750c7e3e2edf57cfd3e83ec92e14b4a2ae3b5a314934af6129f824cc	6542
655	478df3cccda68ea2d98ce3a7bfffc33c54f47aad69cbd42d45d43621ba210b07	6551
656	4431bbeb89f14c2db27f788ca57e7dc2cbec4aa267491d7874d3e74bb2abc3c3	6569
657	10377ca3a0f9ab4e425c99124d5d3e226e288ab53d69abe0abd1e237e36c40e9	6576
658	1333fce0ac7e590da8927b59da661b4414d78f2d1694220a454cb706d5a7e0a5	6579
659	feec55b14534f9105cb36c0312dfc96423638e3357f1c23d55fb9c89ee31705f	6581
660	f4fafe2a6b6d6fdf6d47cdc7244b29e3bc1e163e8f2147bd45227d8ee77373d2	6590
661	18c7f3e9fecabeb622dc90c08be2b77e745881f73fef6a5abcfadfd53ffc4fe5	6593
662	ca55cc39d418e1446ad1305358d057bf7686338df09f0ad08ae50bd11231f989	6599
663	629c8c58186b889b24b92a8b41a808a9482d8f1508ca18de517420a37078f985	6604
664	8a7071a2b7600825f39bec876594b00390875a14c80dd637550e65fb88171074	6606
665	6c3014b334de6c49fb7f3868c7c9d8a51bc550025d11f1e584a46977e427dee2	6614
666	95eda7a09798a406c42b5fb64b15fb0ee927f26f92ea6c27a48f1cc387ab97ab	6617
667	a47f323c5d685783925a9c5088dfb454fe6bddbf4715e30b5f14304181788286	6624
668	826647a5e33608caf91033ce213eab87a67bf51c53ad136bef0d7c141dfc4930	6628
669	86a750757ae68bd75aacc21654567381673461b5391a469980b607480c9e664f	6637
670	01179a3c8c80610e98d9816a44bb63f02aff88348e12243717920dcd2917d9b9	6638
671	02c4eefafe9dc6f66b50b42dae6f02f3331ab46a1bb255153c340fd8a4a9f6b5	6641
672	fe99cbf9e93ac223631092d04a70d66b8c5a65d1ee199b3a7c4830330e194e9f	6653
673	f2c0cc60ab8a5ebf32460ada0289cbf15df481a7fbfbdf88ef60e2b5f7cbad63	6655
674	ca8613893f9bdf829e4e50607981218e7fc35182796b1e3f7a17f699bfa82cc2	6658
675	6fe0dfbb3c8427b075d2de917002fb0a1376c1868de6cab24ab9eadee2352c35	6662
676	f18518fc89f0e1ed8cbe8a1b50815f23c56400cd781c8ed0676c34dce3e5acfe	6669
677	a5b65a1b12a0e37b83f60ad164e035ab9226fad716cd792addf8969ac429cdcb	6686
678	803252f4ed5191c776c450406125382fe21d50b42368cf33339ec72a3bebe6e3	6689
679	2ae9b1ae878e94b48cfd8f8b8fc9130cd12fa4bcd389cf2afb376307727c20b6	6694
680	6068584cfd8036ae5bbfdc39f3c3d0ea330ca54e14aa5e7481e2d910dbedd396	6715
681	f5c7f0e200d491a7adc6e8459f14868ba6f9cfc7b19ed5541e3f720412756d60	6736
682	7d903c93f7c25ba0e9e44eba9fc1a936cb6fa5fc6ca8288cde82e47441266742	6763
683	1a3d322b9cfdaed4005d2e7e52b61e1e1a79f25e2b45ff88194f19237fe80fb2	6773
684	0ee984801e67806af670b70cf8db03f23569fa8cd7a7cedf6dd7f1b175162eed	6776
685	d5608e6c60111e09ab293f9d0f017cbced32baaa2a8775c5fa7fb4cb4650339d	6797
686	d5dafd7e930aa166728e707295a56101ab9a14832428ffe4efea01eca22ea653	6805
687	885e2456e077202a93b90362d2747673ae9e569df12d340ed78b644fe5f5ae34	6806
688	c3cc7efeab8345b5a816e68c0a3704e3e2cc4aaf5f66465d3e9d22fe043924cc	6839
689	a11a2a18150f4f7fc8eabee26d9e5ee1f88229392cdb26e146f92acebf04998c	6855
690	e12f81f9e82c4b72fcbfd1d376c4445ffbe93b89b39dc13594b095695b298138	6877
691	8349e2612c5d2171d073c5760b640ade46860bccc079da3275f924f0274a6a62	6886
692	d332ac1cbcc678f3d4e3fdacdeade5e0392a468b2257936471c86bc4a98df9c1	6888
693	1a7c992fbbf4d45816b10275dc5fface0e4bd56412d7ad6a9b6bf9a37d510a8d	6896
694	7c90697125e91e9574f464f13538b47c3584fab9b727d8183797efd7c44afdcc	6898
695	eaece849cbfc99ba61fd8b21c15dd3a26f330ceecb66d543bc6b78d0b973adfa	6900
696	48bebba0fea9c1776c71568652e9402d87ca2ce2d9a979f285b4802fe9376eb5	6902
697	d39cc7d1fa7729e1cef3e35f8b76ed2785046f2cf4cc4e508e067944236e45c4	6906
698	669ee0c1d1429787bd45c18b27d678a765e5e98555819d14782591662f421954	6910
699	547e3e796138065670aa5f45b53eb9876fcfad2f0695265c1eef2affce1658d6	6928
700	00b7937b8b809d7669047dd2f3ed2a02e86b4ddaa92e599e88107fed5c500435	6939
701	005c57b17c57bb02d8c4b2987af4d1b3f3fd41cf79836d44b84fe46548a9f762	6942
702	a9b636a57b507d3f4d25cf449252a33a99e5a77e4466ddf8002c66476e810a6d	6945
703	a212520404644e89d3cf092be55c3643615ad473b642b922da74e6ed39983627	6949
704	c546c6c898ae1296b68d864ed1a7db439cb26b92e763f3946c757c6e5d4719eb	6951
705	c78d5d83f17bd7fa403b71d5de28fbb6f9696da6e9a87ce48a5dc1d031ace5ac	6966
706	c0d57e7b5409c2ba4ec3e3b7ebb43cda5356a2306e14d6cfbb970c2da8bfb045	6989
707	1d1abafc946a3f663f702af420b006630fd884655427de4f5d270bfa06ef4576	6995
708	72df970b6409554036c02f0de9e809936baf4374bcca15523af5a7a4c1d99b6f	7008
709	260add92ee017307595fe0843fcb4b2056e43eb7ca72882c60c1933b054b9924	7009
710	b83bad390b717978ef5dc6eab0148c0a8b36ba9d7eb934d460f8fafa287e407e	7010
711	f8bbb5aae9a4ac819e12667c89da5a78e37173353de9f1828a49725dae5a56c5	7032
712	f5a6f2a37cb5687ace017505a8d5663cf853bff9e44b2e937ea4cb5fa332f638	7034
713	63fcb60d225c58bd8ac7636f40f8f038511a199eeeb3492dd65e9bc7e6b3f421	7036
714	e005cc19167ab1842ba61c5c8b250ac191a926d6872db366cf684a0192bf8db3	7053
715	074a3d45bbf8fa10944d68f1f60e79c3695c906c1894f0fd8480aa1972577c3d	7062
716	ab213271b6fd3bb361dcb1000dd7d1333d7872ce67c581022b19f7989d6a52b0	7063
717	1bc5a6567ace525ef349df05804d7f7dc07d291dfc9dfbfa68464cf67c11d900	7064
718	64be7803a24092e7171eb8ac978d9891e95df37e3b51db9ac18baeb04e4d1b1f	7069
719	a51cfc5d6341c7f524eaa2a8b5ae52b917bae42cf5fbc49c68cff977516fa703	7073
720	78063312f2755602cebfa153abba71874b2375a14f5bf0f3836f81291cdf6e03	7081
721	81eecf44cffa3a96abbf6295160c2d4e45f206c9e9e71826ca6c01aed0fdc936	7090
722	6f133ef1a672d1123c06d76be984851f5dcda073ad3ea9dc0f48d68fcde08645	7123
723	576d3454fd797b69758880578b16eade9734109859be5633e32dd5e2762f0f33	7126
724	6cb0a0a53da48dba30f2d5e60168fcbb956b39ac7bd4dca9cd9aecd9200dbd65	7160
725	9ff71f46c770337c455c26d7f56b3d042cd010554e0676a246566de781ba7f9d	7168
726	fc996f9b5dad4f6a36c4db482e630b5e3888d0d4ccf3b5b594c3089dae6c9c8c	7171
727	c3ae74dc50c6e5c3db88a6a0f43add6094a187087424802c5666940b4f4f4d8b	7176
728	4d41cc846552759f0648ee8c0d387e3e301108dcece300786fd5740446a5fa86	7181
729	d8dc74126554f5964039011524a6c17a748201eb0443d8d91c50ca18288d910f	7183
730	ad019346a582c100ad02348d3cf86b49e7bfb90f8a3b92f627cadc915c0a8316	7186
731	55914817e20cf2d467ff915300816e7a2a685593581a181fb92680e3b5dfad33	7200
732	c185e57fabc4c35f67b9f0908776bdbbf4dc46e3f4fbc9bd262f235f8dcf0b0c	7207
733	91b1821bb6d9dcd7542e743fea284cd51525e7bef0a4e895beb3432ea4c634e2	7218
734	ca66889891267267b1c95369836433d4ae4b6554f390ba776591831f07393d27	7221
735	eeaf4cf83047ee673916e81c63c1a53a6f085a7cd2ef6c83a6668901923a486a	7230
736	85c06011491189161d55320bc75defe0f9396161710859b13aa6b99f26fcd059	7237
737	fcdd005d69c46686de45143c60068369e2ee9305e83f19c0f8bb658329bf0d93	7239
738	418c96dac948ca725bd08951640f36dfe92200f9a493259f3e7172bef8536f49	7247
739	5624d510691b13bb1e6d6e93677a7b65e0df2237cb4c65b213aedd015fbab0e0	7270
740	1aac0e0fa9426df3b35b473528ff4666b06a0013802542479d900ac1740d4370	7274
741	9d6275794d6fc3e61c82c1bd443c5ca9643fca56fcfedb74a10c85ccf20e355d	7278
742	31089fdcce42c479bf28d53c60eb96b87b4d2b1f1822eb62c550f78089ecf457	7279
743	c34c22633fa29c4042e7036df860e617596798b7759910ae527b461897543ef3	7285
744	3862259cad9a749d61ee39a4a1b411975e15d98e8783e062463f17810f6e6041	7291
745	d79748a4d80520b16378f0188759cbf8d37f58ac4bc29d08324036b93ce151b0	7306
746	993e55b0bbf02cc75aaf2d82917bd4d89b02c8440f54ba3f667c3426d929a743	7311
747	8b0ee27ced58c80641780729f7721325331c5d85665a53f36256406b36b98e7f	7323
748	5b780ad7c9a304d0890d1326ce87e5eba961f84dd6e8f539a9f2cb02224cf284	7339
749	28eb57bd6bc8a8582e4b1188895e587ac49813d75f9840cd9ec8ef973be2c17f	7340
750	76c368fb30eb41c713fadae6f7ab92bc8f708c63f4f7d5375ab068d03fa06ee1	7380
751	8200ff74e1b9392263aee8d8d693ae3c2d1b47d254cff0b55931589edb1da4af	7382
752	889ff78e10261cf27e861fd26a4c576f0ee569573025c4d063feaf18aa839efc	7386
753	3fa062b6b449a13c3c95ab92f50e155223d138a9d302892f99416c4df8282aa6	7391
754	6004cfb11444995edb6dfa796b5040749c4744bcbb8cbe199d6f7b9d45de34d6	7395
755	7bf05a2a3d50b00b86f5ab921cf2a6a99771ec7388b41d614a625d450e1b0720	7411
756	3303c7035a97453d87ad5aac745328a85c0fd16ed898ed59cbedb9a9a167f71c	7429
757	17a8d1f219e9ed6fa5e8731cfe6f58572d2fa4c26db9214b632c6523fd9aeda9	7430
758	01e694c95915276984e85b9469f9915a1259ab8651910d1955529f8cb5d1f953	7434
759	f9b9b4b9c36ff2120720bfa76b27a1776184e0a50f18ba04d5520c22640bcabc	7437
760	79dbd0e727c10bed22d5de0b555747ce2f090ccaa542d0351f635395eb27bf1b	7447
761	3319b1d52d464f8db8813125017bb77ff733af9e744143d1ef6849d20a879a89	7475
762	200c9c34518af14a9cce8d4a4cf4040377c1ee4a00587a654e9984fdb633424c	7492
763	2671b1b4ac1aeacda29550f413e9f1879aa82fb8b52c764a4a2744a173daa70d	7500
764	3521942c0b8b44a2a02f3b729467ac8cd31f486dc2b59b8419df3fa834ddb5d9	7507
765	dc4a4359b026a1852536ea4f725fd8d532406906987638d4ffe6ea6a14cdbc09	7510
766	902d98268730de39708e4bd18f2fe51be197e3d93b8f144e1e0b80b6d3c30e21	7511
767	8f4e51b165ca0c9c8f1a841b4b49561634bafb590ae75537a4586329acb44dc3	7513
768	35cf0042bebd7e94ac7ab11fe65dd77465a69b4692de9d2f212fa6d7bf5746d9	7516
769	aa017a7840e7ecb55fd570f1af900c65f6d5e6b057d8a4b84b4e6c0edf97ed8f	7552
770	2e8ee294ff04787f3fb100fe2b68a0530dba8ef8cd9c6e77a2776473537e7eae	7565
771	0ee2dcafb98c8bab5655f1012f85fdfe5cc2099c4dc67008c11841f8cc4574bf	7586
772	8e87cfbd733b1b7f4df1cef72ee8a00424ab62f83c9d1881abb72bbf725c1b89	7587
773	31c316b12eec0e1a3758f636ccab588221c77a20378f868f69123d6d84918d6d	7592
774	7d6543e5064d3948d39a674e5de9725dd61ace9c22830bdb024e1c5473d6502a	7596
775	43b8c2faf6a69dc1ab8cc8b16cf5191950c272fe2b20a5bf25e7ebc046649fba	7612
776	60e6fa7d2a2cf34a175d77bf06dd696222fd5f1ab4baf8cc350faee8acc90035	7613
777	86dd678c3417c9a7fa5bc7c971c8ea468b4301ec42edf63d57a1e42cf0758b8f	7618
778	5ba59076a691b5d90d0f72c877d78ec33c5106e0b6b62e7b5bd110c232b5411e	7620
779	8cd691637b0794247241002b5263a7294fb65ffd843778a755437afc96e4f070	7625
780	f08908f4d62bd93d29411039471498b45fdb1420dafb739e733935b9a1942cde	7663
781	47077efa31671d52de15b6ef5861406213e282160c3247f9848639bf26c65379	7664
782	0d50340301f71a9fd57ce83b33afebc4732dcfb1534a75ab5bb13b479cad294f	7680
783	3b3ca3180347fa37a037f7a1cf938b3ec2091b5918950d914507fbc88ec7e702	7711
784	88ce03c52398d8cdd909b47cde85be62f22f427e46fbdce5b02291923eb47065	7722
785	ff22b305694c4c6e7defd4184bf7d9942a14f1dd543c880c82891b62ad9479c9	7724
786	4715a37c193eb5406265821aa520c5bcfb86caff4223d613ff48aab1e5a92a76	7727
787	7bb4f0d1772c08b7059a716fc8b5f38a7271b1da6879bb21a4bd8888acd0265a	7756
788	47a9c4e859f9ff88f3b1b8b9a6cb220949873370eba99b3c54dd74cc3c27e772	7769
789	bf2a4499a97c00861ffb7a030381d0b861ede22727516c2e3d8cc1d83db8c6c9	7773
790	cecb1b17f9b4ce63a6062caf7fd14c4f8485ec5a8b2757ae4f43896b3146a91c	7775
791	9255bb3fa21af2a6f96b4991c65d8013c4aa1ab78b135142fd4da34e01cf080f	7778
792	9a1ff8a2b9594b76055bd876c4fe722dfa867391d5b50abd1ccd29ba9d673123	7781
793	66d541c4842f85ba5f4f365baf3517b758c59550ad65bf07e4c1f5af4d5750c7	7782
794	087b4be5f2250ad2ee17d7afa8dc7d1932161c9fb6b3485ae55849d4f856cf02	7783
795	54f5b3510e913717d586c7b03934215da092c56437cada431306ef2a4dea3c8a	7787
796	6253627788ebfb496b4d633babb836cf74dfbc0b16950f8db04f448b63e3ac6f	7816
797	627e4a88bb1bb35c2b98a5fbe45fdeaca5ef6f2834975d4d408338203be9e0d8	7817
798	50967be32441086116fe7964391e559f860e12258819266b1e5bcc2413a6792e	7827
799	150ce5b5397a67868188c58f42ea0ebb3f9b55d2b520ae9d3dda2a0d2b6c4862	7839
800	099eeddcaaf30f244e55f480e09891340cedb2ad4a733dafb04baad6dc0e8b68	7840
801	f442758172ef5420d0e0f6dee657fb4df286058b9a6abf18e8cc51038a12aa48	7857
802	dd996dd82be86e11e5f524a9a9facf3b233fc2a5ea390c8a9132b91306663ce8	7866
803	889573e6888e32f8be3489d66a6e67ef4d6dfb57d6c45bac5d631e00a1772ff0	7868
804	3aa985655981c9ab8901f2eed071c93c68ac08c7a1c01bea4a44eba5cc8a1645	7878
805	2b291f86958165542e8cd771d90bd59a14f337adcb6331c437409f2851de0059	7912
806	cdab33ea9c476d9a3bb90fb8689081621ecb4eb901bc75a9dff60cc09e2007b1	7915
807	6611dffa6bf165dc0cd8b47379f01b88a3ff6e165ba9bdc5e409bbf968173594	7919
808	d26a2e449d6675f210cb5db0e579694754544d57d58c27c9e42da34f5ea768a3	7934
809	090a6b554cc2bd74cfa58458d2a37dfb9af705fd09e4b4d4deab8f45b18281aa	7948
810	19fe3028aadce2a179d40a9abb43406d62ee8c2dd8e483473513d9714e46998f	7954
811	54c14919b912c5c115e641fcda64e4fb7950d71f02b5ab85b5a8215484edf958	7972
812	192414718792b5c22d17bbc4b97fb90a332effb13dd0d4fcb06334263d701ea7	7979
813	2f166ec72c5933cf1a42b619b3ce63f874e10d2b62017e11ffc5eb227ed922f1	7980
814	0ab4264b5b181b92256168d5131f6570e027eec934c1f2ddd3aea3071045c11e	8011
815	1eef92d6b5a8c74da9a9040c154ea81810cf787f8fbe9dcca34399b92ea37f7c	8033
816	67209cc9fc583d0d29194f204945f969684d316ed29ff166864be0ad6949593d	8043
817	f58cb82b753de2640da71721e52492361078da7db71629c0a4126aab6de3be90	8047
818	be23a2df81cda86e1b18a770173bd4bed63632186da6ef74ad38b1bf359e7c9c	8069
819	65a4dea99919a6e07b5146cce5a2f03632ee4c01996b2399689e8fcaa6763d4c	8072
820	3b48aa621d98a3c5b3edb0346d1a72c5d0c11b8d5594acadaaff3333b3b3bee6	8098
821	e123cb0527bc285571940cefe15513fd9905d86c57eae509e9d0721421744de8	8107
822	e4f8201af72053d0cf574e519d63bb8c6f776b38a2f6f65be5722ee740078617	8110
823	8d6cfef4576881393a67385699dec49c103ac3cc31d1ac8838582239c9302842	8126
824	d7baac8f93acaf4a0ab9e3877faa4ae3f73949c24fa7e3f7a4f1babb2568afa5	8129
825	80f9e9b04ceade4a6c4d571b4de50a261836fc99b88f5215e4ff82f09be6a96a	8171
826	08f00ebdecb45159221c5005b0e0bf588a08673ce07cc2976cbe6f5ee13d04c5	8173
827	71f3ea274c157dcd25789d03331c78c276f8085a443a7b789cde68d283d2828b	8186
828	1130329cec11084a2ca570e77b5a2b3ddc205174fabd556ca1972fe6f89ae2a2	8201
829	a25965ab57a058d9caccda1a316ebbb186ec293c4095b23875d973b0eccafeae	8202
830	6d31012a45a2ef56ea3f922efaf78a9e6f07e549e249ff97c5af45150433eae4	8216
831	df17bb47cfb3770750f25dcf9772f4793054ef08543c61855cc15d54b13c26a9	8219
832	fcda5827cc4356c96d5a90bac588444a4b5115fd6f724a4e07bd8bd9cee932ad	8237
833	324d2b0ffe9ab1e12dbdfd21d34aeabee1a0d7e8f3590bc353fdf5cd2c03aa70	8244
834	4aa5927e242074e6e72a26702627b08b97c687137bed3168bc4c5933e0dbda61	8251
835	68a36b317c23d683b3d4b9ed4c069870d9b064703c371cf005bf8126e523ae71	8256
836	9c33d1951b9fcadad6303170772ed388706f2be0677bb5455dbcf7ec4fc42280	8267
837	21eac8c21b9619ddab608a0775a116bc92d5cee1e8e5260522b4d1ee7a73d1dd	8269
838	641bd564beb71b99281c6c42e011fab7749368580f4c9fd2ba69624d4979fc42	8273
839	b7c12966720a0ebbee4f1d898008ffe19c9e4201c6b766dc33daa200da9202b7	8281
840	b30384d124c7caeeee5141fd1cf269eb9f9758cdcd20cfc779922fbec429d23e	8282
841	17c09c4ad64978754e9bafd76e1eff61cd54690e2d7c5f89fcf8f4a8b068d760	8293
842	414b864ea6290682835ee2e06f2274839e62a48e5b9043df357569ba2e6770e3	8309
843	6a0bf12fe0e0ac13b8d6db603ad35b58c54130df0943bf3e55e16fbac1468388	8321
844	cdca3309b681bc511e6f4eb80628cbb142b7414b4700d09dc69021e315cbaaad	8342
845	7d7641820c548c991a2fc1706673ed4128e0f6f58ddcec65730f4ba1adf975c0	8346
846	d62945a49c29869321e3a086f7c2ba0660d0e745cc1be45b6b28151e06deaef3	8361
847	d20e1a9790ce8ff2ef2c11429a7b209f14ca173c363f192d483357f3ecb482ba	8365
848	e136aa84ea2ba2d4b0e1587526c8a061c45ffb90430fd56da0b499c5a77d3f1e	8409
849	94d0b6ea1677f37e02a634eedeb54e93315f0ec7bcde6a2aa85e691cbba09234	8415
850	372af42e28b23418962a98d33f153cd89d5cf53359319590f2bc508a0a571168	8418
851	f9c3f1752214b35166ce2ccef78ef73752bd71be4d9a6f6f8da01a8e15d0b254	8426
852	d14487cfd1cd8bd046625e7fc832af777700f18bc37a2a6f2ac2b66148887118	8444
853	4945d2bb3e3501fcd2bee95a266890012a004177950d8107bc2acc149bb20333	8455
854	e4ce99656729006d7d71d10950eae262aba41021f4b1deef4fbfe10320f2f1ae	8457
855	44ab4fb054c3f445c83cf438c68c7b10877a41309fe6c3ec96e39bc734f066ad	8458
856	1810e3fc53f86a76fdc2f31ef98d9846cfc9dda99f505ebdd275ec3a71609654	8465
857	e10518aa2cb5ba33309e54f6ee21aeb931d8623f104e88908d0a6b483f4d7b9e	8467
858	e6ca2c6e01f5a1a46677fcdf5b8dc5999b2c231794a4df45d51975d27d61a646	8477
859	41d8375ecce73a066c72db9e5f72eb3fe3eb70d38eafdb927bcce2734788ed85	8492
860	d3ffdb6a09994298f7191d423c4afc4650ccdb78721d7f72f1006bda12cd8db9	8504
861	f64533e4e2e74f1ae6e3155e80a6a368f16661eae0a5d32ae0e15fd0f0def7b1	8523
862	c05212ff7c20691fa2626e4c499635e01dbb68d03100a99380207d30bd5bb929	8524
863	7fcd12c95958d0e7f13f66f8b1554e6bd080dc0552cafaa8483df627c9c831ac	8527
864	6a3a5217dd484f0a4daaaa4ff667a65b5f62c67c06d3f1b4b957aa09f87bc530	8528
865	761782f756cf478c4a530604ba55f35412c4f6dcd01c9df5d86804c1b51f152e	8534
866	e44e09e2a41a9b0037f378e5cee9e6b81a4b61141f9120369f8d95ddda64a343	8542
867	48af03515fefc8446fb761980e8950b97f65ac4eb2963abdcb0d4c1563e58ab2	8556
868	bdd294482a25473b67d175fadf18eb204fd3831c515938cfca8aad91e959e0fc	8563
869	fd7e36ef5c50ae5a5cec3c1f80d4b9a42ddd8e9b0dc465b9278075110bda153f	8579
870	3826e4832e5c986129ddc2360251ba7a5df4b313a547de95dbb313459581dddd	8607
871	abaf053aba00ec7c8d06b62ca8749734af364cadb99c30dd2bdc02d719aa3040	8617
872	2a3445b384616c25d562705d87854743d419f5ce4d02ddda656a6b2fc6d023b0	8638
873	d22b771c992df8d9fae558448098d14361621b8077dd30c0a53193372f4cc86f	8647
874	7ea5b0fc581bd9560bbf5a3ec63ffb25f162acfc8a12ace0403f4ffbb613b046	8662
875	fc45fd447d65a138fc7748c85cf795ea73686d50767c471318282c566e22dd59	8665
876	9d83fa9461b7f77e0aa99fbbfc7b9a2a4a83d80fc1aa3e0a555b9fd6d56fab28	8667
877	8438fe2826686c3b0b231654e682a0f025d94ef366da99a6ccd0ca28847e5a9b	8680
878	a5d4d55848151234296c00c9ba343d92b6490c27dbddd01bf0015d39073a205e	8690
879	596d82faa651e0b72eaf61c54ed1415f8744b2c0c8b84d5afc980115261924e5	8696
880	2f350819b0cef23522ff776b5c816852ac3d85238b9a21cddb62cc09407fdd05	8705
881	50b6aa40483d6ec244d7d8137fb311eaeb4f860fb3b762f0d3e88853f3fb6de1	8708
882	0d46f58f718f31a5c6620b46809b20e354cbafeb1c38d66ff732de3ef4192ec3	8711
883	197824733597203235e420bf43030949ee904eb6766af50ba29522750d14b425	8712
884	95370b67b77c4bd9612803e53446b40e61788badc9471d88720f6254fc71c27c	8716
885	8803eb297c5fc25bee99f1ec59e3660d6b8c21f43dbb937133137f87ec0aca07	8768
886	eceec52570d69571929a45ff4871b8fb34353b91da911185ada2bbd65d0dc031	8797
887	dde6fbe63d467984324a7329b395cbba016026bbb5b1ae1e63febb11230f4136	8807
888	2474aed0c2e3e977a30b8ed3a1af9b0116e7c91ac989c9d3287f60d86c7e13b6	8813
889	d4b839a7c20e5f085277aadd565db105799ff46d0aad536cd9e4e1bc16ab3813	8842
890	5ebc668c2e2748080ea21a39148414a5738c9430449bb0d130546eae91389cf7	8855
891	e151e808643b48b4b89c2c2167be3c270a4af538f7063c9969aafbb0686fee68	8860
892	8ef8894b75ee636aa6d7fff7f95d896b06963dba46cfcb9c5ad02f8de81302bf	8863
893	26509e632ff20c10af452dfad75df68e2d4f99e22203de222ebca60d74736d75	8870
894	4120ffd5f61e7a96f778c0977bfec72e97878898bec2f35ec2ca25643ce8e93f	8888
895	2a0bfbbb95fcba53de342695ce1c963d2dc8e3ce563611fc9ab4edb7b654641b	8924
896	72ba407e7771c8132b7c458b1ce1325509263b77ed7b4f7664c948f29daedb8a	8927
897	fdf492b6dd388f914ee3bab653a6e88c41c604a5c166acbb7f9fc593f0e76d5b	8944
898	d0307194b776eb2ec3c67f9267940a1e9083d90be5cb0f924be9a7423ef5e5dd	8959
899	2cc87289f0f2c139daaec66ba29221d8d3710e8c4fe85f32da972f6a578502eb	8973
900	8ffa754e64838b8c38a41f25e7c9b56d592c645d39e398e8375726fc8a4876ea	8974
901	5dbbbdac87544e7a9aeca0d692286e2007726ef71adc86ce40db44ecc02dbb86	8991
902	cc4cea698508332738ea35ad8f47b36920a715461173b34735b60a3624b3fd04	8992
903	f23d31bc74c583f8adb4aee6adccedd2de870802ca418e5e232b9b073b96e0a1	8999
904	6ba065d5018aee91a8ce0c52fe0c7092d25708da1dffc129a6dea4c820959cec	9011
905	1fbfb9da8df42c80d2c46104174b113f328c1b16ab3caeb89f6c0562fcc223b1	9059
906	e37cccc43b6c55e5d29307e6801f3bda5e564c426bf3875406df64e66de47b69	9067
907	b36264c92567e5d3b856cae96ffe01210b6d20d114f35ebb71996a4cdf68afa8	9068
908	511db2c681d5ecd5c89a7f8ac0d1b4d3111e5fa40ffaa8fac3110b3b8f3812bd	9080
909	33623309cabea896ce75ed8f819f4d3c19698a5274f193decea26825a0c13d4f	9094
910	bb9b888dbbd168be10978927a89fe77b7eb4057dbd80d717cd343d9f99583973	9111
911	47834dce42ba884d6ed3810adc8520b15ac7b0b3854c98004ddd66e94c038b21	9117
912	083c469dd9474cd12816a32622c805e83992fd685dc2c553cc59af6daa64ddf4	9122
913	620fb7b44eddc8fe9d162f0ca8269cc11dda8394fd71f215e3711e8183d6a799	9139
914	ef0a5b164c6c9ad792b86aefd07a7b257c55545ac21f014e7220887e7314362e	9145
915	fa50ab6b244998c124586880250ff0fb16d6d6ea60422958bc31b4f0d856fedd	9146
916	78a3a31a36d22f542c813ffe7e44ef6d5c70c919c8a386672101c257d9aa5685	9147
917	8eefde856364c44013d9b14d206ce0eb7e9ac35629d1c3deba1a935100fb89d6	9156
918	1e82c22f27c582ea088513d3c367d8fda594f92c8dbef07b31bdeb6ba6a07dcc	9161
919	7f0e92dd151bdbba55e508f3a8403a349591561fd70131eb9e7d98e21302ce84	9162
920	0273fc074f6fc3204c2b697d47eb6f63e716f8af385739c2598b3bd350020a4e	9167
921	65b69bb24677e8275b226c48dcad67620715798600e0a6d66df578348ca19991	9173
922	307b61ea94c56a7d4ebf5b83a1b50b596fcd624fc8843776a3ca35277027d6f6	9180
923	319ec1bb00b02ba4543fb5832bfe5f02a03f2835ad10e191e5576e37a39b4782	9193
924	525db8180abfb3145cc876de8725ba509f24942abc0c64a01074eaa79724d638	9199
925	18580b896e3030a0977699641020b4506de2abfb4c9cccc0acb1fd3e2509d241	9224
926	96b795e3a725e2588bfde33fc3d3316f5e732845e57144cb4f3330213f413107	9225
927	2761bbd5a0ecbf06ed7f08c98281673b5fcf17777264dd7965148f8a2bbd302a	9230
928	473bdebf1590ae127221574e27485ce13da50ad9b98fc7d228e9f05dc7aeb677	9254
929	72e5388bf5f7d0bbd201c07d613c0fd88efb287cb55e92d6a23bdfa8fb5fec0d	9259
930	59a214c128c621eaccb9e3e16f4c55fc819aaddd00d3593a1051ad307f0aae34	9286
931	baac523608e2521e4134374e2fb263ada3bde0c504253adb5c99d793f181ba02	9293
932	4b20b501e60c11680e5a0819235e6135a90424bebece2033c896f9c39b4b60c8	9309
933	f1e01734b1defc31a3b9225788e6720acd42624ad88a837f5625c6bbc6794bff	9318
934	132db1f2ec3a2d9ab278ecb6a06d9da63edfb0e00a7ca5e428f7ce13dab3f024	9327
935	88adae687306523bf28cbc6134fa851944c5ccabb933efac8081e5164619f760	9345
936	5d6d53d629ffb42bbd125ce17f697be78e9554f7ee1510831ca232f2ac7d0ab7	9364
937	de8da56c2f9c9950f0d1ae1828e9f24a0aba3d28b1ede144de192f23926f546b	9365
938	ddb623654f41af3dc3f50cee091005d14cf3c0b504e9f4e6c31a3c35380b7516	9366
939	0a5ce0b29236563b9b3bb7e05824b8a8a226bde5ccef09185d57e28c2a8e6d47	9372
940	b7bc214c507ff047ed9a28aa6b4f8a3c38f232f39f9c7a63bdbf4f98e89d5ad4	9378
941	d617a49199e4a8bd3711ae625f0b7a68480116d670c8f1d168016e9f25eb243e	9380
942	24bba3d36d4101be41a7b87d9605f4396cbed53a272a3174bd61c5d9af7c53f9	9386
943	37457150054c0a6595eb1916d6882579bb4d35d15be7d651ff89c16dda57c71e	9391
944	fcf3e6d7b16849a81f1220fe5a40bf8b1481d1bbb435c4b16cfe3ade9447d414	9412
945	0325b10f1df941efbb5b9d4573336f5d29f3e6d5e708b65b1527ee1cd633d7f3	9473
946	2c378882238e256148453deb84a89ce86e4f48599e394949d2582dd224fe52cb	9480
947	57caa4f1cd6b7965b5c4dd1263e4e6446c396733ee4e7c2f56ef4cab4076d416	9481
948	abf1f063587512a5b9a4c412100733b827e272caf02a6c397e17156761f8a8a7	9485
949	30f51f77cb11a9d04df293e9a0894a1f19e2a0e672af73d4a47601cd0642e5cf	9510
950	8874ea20e3afc5e13ab416d2c0385d7e2aefd4105256bdbc494bbc35b1365ed8	9548
951	23bfd66123ed10ecca3280fd5316b1134f5b39a8673bf951de54b417ec1d3926	9596
952	89ce4b6a12f0ca7c0e84fb4474ca55c8e6439ab7186dccfa49ed94da608b604d	9649
953	12568c5d06946fd28190213f4079911d9bed6fe241c6bebb1fd98d7c1d8b409f	9652
954	311911c07f06aea13e45fe1bda60979061fb8ead04fe4ecd86f5fce3fcd67418	9656
955	ae722e1e5f6c8fd0a473c23099991058f1d37e0b2c61a8670c6800ff370dd70d	9677
956	f77b397dc9ee3f3cef92065708ce068b9afd6a085a1a902ffccf9f1c3d59c046	9689
957	168ae35303b570329825d761b6efcf7885f2163d2b7677678d3c9d96d61f6d2c	9690
958	903bc0a523f24d8b8a41519f8a3027310112e6ef45ebf21926f65bfd92d9f6d7	9694
959	e86c4ccf75fd37df017f8801e9f84f95d2c86923a4ea04d23c1b35bb47ace208	9710
960	453cbabea97b998a70185f371d7d31e8bfd6abf2f4023f46ffbe48007dffa41a	9719
961	901c1ae8492b2d70f612541776743fd88c55cc01bdabc74837d8192d6ae7bc89	9735
962	ff8ff2cd1475199ce3fdeb5b2f5983507f52de19cf2be72c8a95d7c77d3e6b7f	9750
963	0bd98952a051b1a0169cca8d62154cf2e27d40b38661734f4108281327c0bb14	9751
964	7238571e0b699466697eadb81364019b0ff35260ad23bc2a5fbde125556c563b	9752
965	2b116910a715e71bd1563cddb49b80b3edc8c4d20864506848b5964eb17c50aa	9763
966	4f0dbc4487bb3e2b7e8392c2744cdecc055b20daf4672a0d8f2615061f0c5420	9783
967	e7da5b6883b86a09e9dcb1ce538fcc1aadd4ef733f8f35faf98e97c9c7c906d5	9793
968	659b8383533a169afc3f07df64948e8415ba8bb26e0b4fc9713fda89dda4835a	9794
969	66d7a067cf0f1e6694d8b6c5c8a987fd3df6535a007985e5c9fbd77e436ea61c	9808
970	a0df3ee91051e5e8df170570b2a39c636b181b3a89c6dc39db5c244320cd414c	9816
971	457dc3965a7dae5e001c9bd70892611f9660de6f1d221ce43374e16e4ab56cc2	9821
972	fce925234b6edaa54d8fce41427b937d3082ddc2aa0c3b0d6c6c2fc3177f1623	9840
973	9be1cde097121167520ef09930a42437f1ec78d19066fa5e237a773a8775a178	9857
974	9ad1ccf04e0941f85cc736b01bb56d313cde4166fdb99304e88ca3ab83493724	9867
975	702dca705882ae8ef14f14b3287fdd2435ed9d64f29414842c37569f1fc04ee4	9886
976	e4803aee37a546a4d96b69dcfac97d355ac9cecd861ce8a710472acbf1faf9c7	9897
977	96956354a8657e340e960e2b2c152705921c9abbcaa54c2f50641eb4040f5e67	9898
978	9956b7949aac12a123fca0095bf14189178f7bd5bc215ff2b8bec8e4fb68c071	9912
979	b77c980621e9e402daa66664df5192e1b0b5ddf5a495bd4d30d18a5eab053564	9914
980	801f8160807d4b0546a4deb2163637801ffa634f5c55de68419fcf21df4d7f85	9939
981	5c61ec49bb8243c699cffcb137d3bd782f27d44156c4faa4549990c27d28ebaa	9944
982	0f7116c605a1285551b83a2d4237d052c2ba3c11e35ea3dcd85158671b89c76f	9957
983	3b8dce002447248c34c43c5ccdbdebe49ac1c709f0b61e9f9d079cdd131b2db3	9968
984	380e7e078ae48b799450e49ce3d41f1f50995f73addcb8f86ea69e2d62731d08	10011
985	b75dfe85c5906587bc88843a59ebe5e067321f4b258139cddef1a124401c228c	10016
986	2546043faeb59e9def1bfb2f45f3a42356871c77159f88f825d3be93b77cad7b	10024
987	7f69a1cc741f009b55572ea5246a9bbe130eecc690fed354e6b044fee561ef8f	10039
988	5dd48f7251073ce47fdedbb777ea70fe2f8e6f5da283a7c5c4507fd944322ad6	10049
989	a8e8c83c3dffa90f9136d15c42931e6fe41d0a5125fda9b318e75c1f2e53c970	10071
990	64f396c432e3dd32b9078f5929bb4a163a25e3e6eb6c5ab05ebc25bd4ae89fab	10072
991	71c4f226116c95ad418a48241a0137b0270e79ea2ff73937068b734f2e6a9d78	10079
992	f8f29c3d87398944dcfe749d0ea980d2392cdf3b96cec67a9b034a703a3ee6aa	10089
993	0f630b163dbd200f3270bde756062e07e8af6b08673c684efea7fa4c184736bf	10090
994	94e9000282d1d3b8a3dc80d848172958c62334756b4168a0dd7374b9454f8e0b	10097
995	8f3d8bf58e2e09ba2029c716cfe1317a18124f66594766be5e5a21a185dacb4b	10111
996	ad3cb4658c9663d8a3c4f0071ae279f962a3c15218c2d9b3b3016a00dba53707	10114
997	53bdfb2a746710be3845fc767dc6f5bb80b96c06f53d9ff2725fcc99f2d6ea4c	10116
998	a87509c411342290391f82291a0bdbddccd6c5f8a0c867cb0fc7c5618849ee8b	10119
999	9be13e440149cc981770b5b9ce3b6c79979cba8e8ec533c777c60c116ce4f08a	10122
1000	359340457726bba55f81de2da2b328b4994d2d97723dd6d731f95f4efbde957f	10138
1001	e6ffe494338b89b72f907aedfbc4c8e91f74a9c65cdf8cf23b68457b44155751	10139
1002	e630eefca6da6feee85e6e1b775b9d5dd1c67e7b6a1c3f9bf903f031fedd7aa8	10152
1003	266e840138d272360ed14c4e4d80bf919f387321b3180d0b5a1ea0c05a4020ed	10154
1004	2337d994f7792ef8f6e7f017f11e20ac57450704060477819538c8aa812100e1	10162
1005	df65c2bd7d6696ba61c7378ed4aab0c581345db476dec57d22b135eeab952c13	10171
1006	8e4b6bc5779d29c8a22deabad31e7910472141913155fed956e6647028262e5d	10201
1007	c18904207cf00dae7cf18887d901bc28f79e80bdc4fe918d76303d36e7cadcd4	10215
1008	62e817612855676ca5772aa3fd2256b43eb6e4f767d540aa756789407eafe7bd	10218
1009	40a30bd778dfd5654efd292da85199b4bcd157e9d8ba828efbb158746b5c883f	10232
1010	33ab2867cab25e1b56f8c9ae82a6f74cf957b0de8515ad8481b81f21705434b0	10242
1011	ac12c7d1a771a6824be607424fae5489822ccdef420a3ea7ee943ac597101f27	10268
1012	07121dec1f2964ee10737fc7cc6d11b7b7cd94dd60e200c6387914a2f1acfc56	10269
1013	eba12dfa86efe0daac5d77e7db831ddfb05f5303f12ae4bbcf8b2b6ecef86450	10271
1014	0576936120fc73e27c300463827934e760002ca86bf4bba0089439647b0c4d12	10289
1015	f7cdb90139902c62786429c18bffe14b6339f414fb02ad7e15b4dadc5ce308f4	10294
1016	1b8f387968df626a379c8d3f28962e6472fbd3a305738de330e896b0c5376955	10296
1017	f4499b0fb028219db5ba41de25f0d98cf24060f4481cba0cea153a1ae9d184af	10300
1018	31eb288a288807265a70a2954dd70c410084a252abb5d46a2fd8b98b6057b94b	10318
1019	739dbe791f1481e32db9875f28fb46a97ecc5d02d38b97aaa25bd8f26c5a1eb4	10321
1020	d412ccb87a6834426966e4da41f6a11cf18620160992962ead0f33aadaa45808	10337
1021	19c7f763332c70eac062e1beafe578134a98997b0c76178ee008029e03761cb8	10342
1022	d97a53b613c95239bc4a5b2f48f48edc3f5aed87603d91e07dd54772088e05dd	10357
1023	ce7052802fa2416763d03108ca1d56b1af73610c6302168f34c14f5386f4f2e8	10410
1024	9de0e05293f6acb71ea03b22f8397669d8669a5aac7ba19ab551d63b6018ea7c	10421
1025	d4083ba0bc32255870ec62d72f9f8145685069e40ca65e1ba62e3e60db012991	10426
1026	ebd32be7fc5522128e1eac4ff2eb52d5cf42a5a91341216c2555f2b5e53929a0	10428
1027	c961295ee66bdde82960cc6d28fc2729fa11cae2664266100338c08e359ee3a1	10431
1028	fad91255939c08a014a444c0d9c878dc20cb3d24f432eb4a5e031bc4a3bc2e92	10443
1029	6362c5a7b901bec432bff3918e426a2eadbf219315bd63bf20eef178f6a81e05	10462
1030	9ad2a19eb667f97021ad09d9b2fa77919168770a3030b546f2028d50d5f86bce	10463
1031	d32f2d6b126e38567de73553984294121ffbfa270eec0740fda8c541e6c3af7d	10480
1032	9c22e01c60b6a96631db90ac31cfeae52ec3fdf1d8d82a6fc7a229f8024be819	10482
1033	1ec3af925dc08bbf1a646e825ad517ac05773ce221b986d405b32a03bfd0e06e	10492
1034	9fedbbf5938af1101ebda346e67ae8b9be4d247dc9f658d615dfed9b9a781c3a	10493
1035	3164db787481e6c88794854ebf12b8dd03a900874219d8095eac605bff09349c	10494
1036	212a597ab7ee4cebf18a4a9f011484ba224e0f442dba0566d0927f8239eed7a7	10518
1037	29219bb9a56bb2d0a72c84676db599953164decb26a24ffa5e7811303d7a8a5f	10520
1038	63cf550f41da4cf39ab271e6663a663ac86871f8811ed67fc3602a026074f955	10539
1039	89a2cc9dc5133faea98025da77b8920bde3a3f8a9c090d1c2596db71f7a4f9c4	10561
1040	defe76d51c1357024c14d9424ad6170d2b5f6c3783b1f5120ff7fcbc26b031fc	10563
1041	f1fd5cce5479079efaa61763e6525a6c91c0e116a7463c52b7feae2d93352845	10564
1042	5598c1d0a845602f75b2f628cd2c1d4ebafd03122d9d9aa935e86d4eff195575	10567
1043	16b3afd3ebd38387e2a644be5eb699504e4716d31f85b493ec7b6b1ab63e9fbf	10577
1044	265b1fd5cbdb116f8a24387d366ecb4f664c0eda1b24cc85f7ec07de3c636e0a	10582
1045	f988f1a423228e83348eb7d4eaeab8fc9685b853d2420a2e63831cf3a8e0d6fe	10600
1046	35eb219a58e06c37fe593f57132ccdbd487392a6f24236546005a12ccf64dccc	10623
1047	24f53b5be05967f9c0d223936a6483eb07aa35fb6cf10582675e44e8a130c986	10634
1048	8e06b704f4f838b27d0e94be765033c8137201dc2a6fbd8cce5e30fd2abeecfa	10635
1049	c18e30b86267059979c36b7cfc987b5db4b4893221418a21aec337086ba9bedb	10636
1050	30fe65818e4bd92c693c02a71f3fcb38ef2c8d81305b59b394c317a8b854ac7a	10651
1051	ccc2ccacdd76acac49ac0d19bc7fa8a8819f4bdea0082b6d8b238929915dba27	10652
1052	404285676043897337657cebb714c6858e3f557bbfa9e4c0b57f20af1fd47306	10690
1053	211e24e6c218f835312e4c9145287fd1f8b17ba26de6b920af7bb09afacbb9b2	10699
1054	b32124ef4d6d72ae7df9bf96d1a8ca894aac8ec67011fbc7f7d0b30761db569d	10707
1055	ec0fef888553461a2baafad6d8713bb63073ef4adefd224e82df890f4bffa49a	10723
1056	9fe34371bde806497f92861e17d51667ede25260720753f8681b7d620d9d4dd8	10731
1057	07a4235e1484ca5709e6f77d1fc2d50a791ed133b2ed928427344d65a469d4fd	10735
1058	9f3448c10e40ad31ce8ed66802b19845fb758c8873e57cc3255c9876a1ba0652	10743
1059	bf0ad20bfa3c38ef285db4169a3ac499c978d4229416cbb968fc8d7535467219	10745
1060	f9943c93195bec113220703538a424c71ef3880081f1008b752c4e8f00b96c09	10753
1061	04af216c71d0c0349834e0e840a20e823f437021918ece282cba378c2aac6988	10759
1062	a3e5b17c15e17000e0e572b9dbf9cf02182786d9f3d755fa43379efa2b72f5eb	10766
1063	e045f8aaf7b30ab80501a64603c4fb91678513db55160a194533bfad9e5594b6	10790
1064	dc784c6f8307da0df0379f1e947e1b86d4bfa23c90ed45b005c3a33f4df583d8	10796
1065	38702aad72d30c4ee066ca0aba2aa2773e07a86747e19f197b2e2a4d5e4e6b4a	10802
1066	41691ec08d4d0023854d5af62b8a928cc8c7caa2ec88daa7327d2b1ee9fdc353	10808
1067	ad2f28bcb53c1b379458fbb41300d2d16e3953b6ff037603b6b1441df99393b1	10817
1068	2aabfcbbe6586448b2493f1594ad323c377e2942ee9440c73a13796095aaf2d1	10824
1069	268edb46fba46daab0470dfa6104220bed9063e969312219a6e53e82e74dd0e3	10825
1070	c5aefc0768e6dbdead6eae044bb0de924eb1655b7db20bfdedc4ab33049e9a3e	10833
1071	729837ca27e8df60c82c2d7f7776c751c25480f8cc41c7d749d72c32fe7ce5c1	10854
1072	9ca733352cdec7f52c75af8582a1c222d3a6349fa24b6260e9fad376ce9c58b1	10861
1073	444d9d348e5d90d691edfc5af21f15a8ffc3393c7e87bce043c62eb3e64ba310	10865
1074	5d41cde7a8d175cbd33d770e140c7515846a0cebcb8bb3d9d262c0c261256e9f	10891
1075	7bf89951deaaf96b96efbf5f676da0fe077bbcac0d238af9a0058b26521c818b	10895
1076	e8fe932ac2bb4fff3fe66314c180a3926ac3fa78000668a8e0a7b1c8a6194bb0	10916
1077	5e2b056bdc3f3b20a99cf3bdb8e552a9ab80d81e9350daee57c4ea4253f69609	10917
1078	8e5ee182ea5d5a3034057b4a47a4d7c81056ad0c2217c71fb1b38246787516ae	10919
1079	0d2331d8b659fae8398245475ddef04195dee3c4a18f982ca0e903646460614e	10936
1080	13d65f64598c945e55c1f166e76dc08241f0d16ba97a09ce3f7af6fd9fb5bcec	10945
1081	7e90fed4ab500aa471ac61c3c076a228fc435ad12e95fd7a5a02cf6457bf33d5	10956
1082	10108c6c7c27177ee382c83554127fb04a1febb93728915858aa0490433bd662	10961
1083	7916fc689bff2040d31bedac940d110e165f89b1469a0e2fb9eb05461da018b9	10965
1084	49f6c6c30bdb7810c821f20b54772b4059afc2c4a7f5d78c906afdc1c520d32c	10966
1085	6ab7b8d510203deb11e74df5969a8dafd8865d8b3b039850fefdfe234d2a2e78	10974
1086	eee40811e3a641ecd955847818cf052b2a03629ba86fd3353c38622e7e101d9c	10982
1087	55721f0790c3e7f8c72dc3a386fed9f92437265fd3214fb119f3b63ce38e1b20	10983
1088	ca9f56377105883b68046b7092b55f5d78a9ce50194e927ebac47eb17d05e0fb	10989
1089	4ff598b5de36a62f25a9858d456b44029f08ab2628b16fef34f7764f3b711d84	10991
1090	75855d85ddcd35edfe7de093ba836f988a4a3b0ae0b286d41308405a686d2e55	10993
1091	533d56df0e67e217ba5730188026cfa851e3b43af648580026090ff4fbf2c8e8	10995
1092	46fd34b4828e82acfdbecdece7fc5bbc8ce719446a083197b9ce976493c541a2	11012
1093	e9151c5015eb4bb955e7701cacb8e60ae1d02e7ff6ff700ce6005dd85162e029	11017
1094	7880020736b0df71158e48e33ec41d69e5400d916041b229378db2867cf023b2	11018
1095	4d7f998107e2e2f72751c9882c68f8942b58c874e9013ec7552343bde28fa32b	11020
1096	a0b612f334c888caba39d3383f672849169419c724adb98f9713dccf21600165	11047
1097	f67506ab0fe4c0d24027ec2f42e853bcaa7dc1f37a72c7d084d4946fa825afcf	11066
1098	a1027d94bf95d3ebaec8db90752742abda6c6958141090b0d599c88ed2b0d3ef	11070
1099	40f6207c4ae6ea61791826e3ee6a6283c20e30058f0170c5b91ccf99969b41f1	11085
1100	b628cdbac7deb1d7cba9c223fcba0600284395080b9343d7fef74b97507e1c47	11095
1101	b7521b633f542dcc1db87ac92e016d06ee6ebe0767082c652757232b6251e4d1	11098
1102	b6d423d9dc0662d3b3c07f8a649187d403bd21301830151b707049998d18d18c	11102
1103	29aa6d52752123c6cc9208c14098139f137ec0c05fdba5a7d6f193a89410aaeb	11130
1104	892d00a991796b219301868800aaaa034030f19cfc97c7cd1d0f55e736b7b427	11135
1105	845783cd94b3b2664bfd5b2d8d281fd652df538f9024c3aad1e3a059f799d1ee	11140
1106	7a269099474bd58321623962a2095fe0148dd9c5bb307fa08a9c52337caecf42	11153
1107	489d4f7959a2d19e77b16a29da0baea00bbe703f165a0e8b1f8e10d035812fb7	11176
1108	696a19b33c495cfa79f32ec32a69350391b96535c7e3a96fd63017aafd42b888	11218
1109	95f93709013a120f55eec72089e5cec6a17b154b7f95c51a8484a1c207bd4d07	11228
1110	9a71ae214e68c8e241cab56f3700b5e5e232d04e4b23e06e03e9dbf93b7c72b6	11234
1111	0ec00e365e99e9d0e5dcf2078fbe2fbfcb05312bb9765c2ca0902433f4bbd9cc	11244
1112	cbce9e161117dde054798e3eab2a8abfaa23be1f97c79ea2968f01c1bbefd5bb	11262
1113	7ac0ccb362d349c6d92dd8a224bb0f5acd79d478005837ca58465ad11439a5a8	11267
1114	da7b79dfa3f66eca44b4a692ba78446a7f1547f8fc67e143a391ae6b5f8212f5	11279
1115	27159699e618d3189b52a19aa9394f0ab9727145fd80625104b4cc4d6f8cf91a	11309
1116	a0ea2e2a3e4a28c46a73a6cc213d441b53d4dc1123cc27288a1e6f448b997050	11328
1117	757c0dd96d44b3b64582bedb01ac7a7aa200e9de67ad3f2c4089003ea019b858	11341
1118	366eaa24c9129eb8cb8f9e8b39e8829cd873d958d5dca03b05f3b5f7a547b1d7	11357
1119	5656e41f21c12310626c01dab65237e263123297fb38f84a2409ff1a83ab34ce	11358
1120	00c43baa2c2656d0f4eb6dc606e3b2c4ac18e130db3d116f76c736f8a201d7ad	11360
1121	da2a246378602c29e7a15ac4c52ddadc98543a63012c99d97aa4adfb271ed6db	11383
1122	3c8c2dfaeea37fa58c369bb0fea2801be28f2456b1cf1ecf705d52657a40a502	11400
1123	937a3902bd935589fa71560e7c91a7e9a13d22e27d6ec088103eeeeaf9194a19	11405
1124	7060aad41f3ca4073ea4c75cb9b921d8c1e9f1e90e6823f6b4ac5a57f4b8c511	11426
1125	0dce2d19974ec8134707154c24ed8835ff937b4eb9a92f51e62b9a487494947c	11432
1126	907618f8d590aeaca6ab1b39c0303d4b808e3fbb9d5228ebd51400b21607d9db	11434
1127	ecb1e554fa4505051c2c5a212b3d65eaf6785409941f31ace889a3337025f439	11441
1128	58ffd73b110fadd4422d2478b97c7320ee6a82d1c81bee7839df8e398cbcf50b	11465
1129	6a352430ef156449ff41d4d21bf76940f8bcc8062aa7e3ac7faae9e821f87c89	11468
1130	7f3d448f6731727e1bb8501d2398b1a12d8cf7119ba7018ad80c7ee3d94af286	11494
1131	5f34d734c2765f72d0a5c3a1ced90e716b5ccb4ea5e285630f29187cde7e6525	11516
1132	1857117af842cd24f6f234a3099aa53346f95dfbfe7543553f75c19d62bf22e5	11526
1133	d055a0303cadd1987d8c4dc9e226e6f4e4a807f8365aaec899cc16f080aeef38	11527
1134	f055c0cb3c8a15d7169fbad829a88a8b2f1046241a8529f912ce85b39ce28f02	11538
1135	407425a1cbd460722579fbb2be2893aa3ead3cf08364f63c0debe82c93b5c0c8	11539
1136	7572fb383250ce2c26709cf3b8f3309812a406a4eb68f70d34399a01ebeba6cd	11607
1137	caafc18444d85d9012a153714c99d8817db1d0309cb0dc29cc4563721b02eb6e	11622
1138	5ba0fe778b887b0d8dd68681241e7138785754c9eb91601eaa6358691a79e392	11645
1139	1babf4ac238bdd18ae1b9e0ad2efccf3ef07469b816460b6b0a383552c0814b1	11653
1140	9c20cb677f10bb4c4a813fd735ccf5cbb7105ef7f5eddc2d7e82c51178ff47ee	11674
1141	257e3cdf280a47fa0b55afc5204a36afaccd8ff3e8d44e3da7daa63725dd3c94	11680
1142	79aefa0e6463894c60b924588476b36628ca85fab3d6eba150b1ac4689680b5a	11688
1143	93948cc3fba7c596b9e21c9654a87ff1afd4dff1459614c440faecdece796b49	11694
1144	a4dc097fe36893d6f416b32eef889da2763f0e330eec27bc368b39a6735815c1	11714
1145	74e5710c1d160376195b8b4ac4433977fc97d2bf7fb2f9a96fce955d26d228a3	11739
1146	973ba94c02038a8157c9108036d4d4ab044896028fa31462282e574da5eea425	11756
1147	a22a4dad6cc421cd1adbea34931d7714005c2f66db67698000b8913897594d08	11765
1148	eafa35e6c2b63b094403056c24af1d5ea3256a405efed59673b09e5c5bce8c89	11783
1149	ca36e9f2ed831dac9af79b22fcc764cab86e286c9c3d0ca7ecc8a5e4f927170a	11790
1150	b9012fce552cb9b927518e29bcfe0e9ee29ef9bea4fa4a551737ed99495591cc	11793
1151	7f9cd542bef4b138174e4ce9160048e6ec824147d3e2ae2f54a0c8383df41031	11799
1152	ba0f14ed35b0084ba60d8e480e6e22714b04da8a0d51aa5a0be5589abc10272f	11823
1153	daa636a59118b80a1b606eaf0648f101fe5e30675c9a4c2cee15bf3a27347ebf	11838
1154	920ef0b8d4421caa960cca182d2b77a5c9d55f6e4de7a61b068455c7a1fb6beb	11851
1155	0e6a8b0725bfcadd5700937fc11ba489ddcee9f1b395d936a97543d6a311706b	11897
1156	e27f4ee76f6b6cee42ef01e94508b2a560fb943d980c30082ebfe1110470ff8e	11911
1157	8fa3975360a5f31619df509112b3352b1be0429ec0cb462286924b9e473ebfdf	11914
1158	275986f022ba1241f2dca19bf7b584341865f609f93b377de8b09943493f16b8	11917
1159	e63794206a3030d0ee57366056814d7c268c486207633bba31c6aa2fd0a07eec	11924
1160	f5734edbe30fd3a5aeea3b3c8ed887d42dbaf1936409a426f8e7d6a8b01172f3	11925
1161	c18826531107ab894d5e8aa3253bab5dd2886ce23426e4d59cfe182ed9d2eee7	11936
1162	b35a7b911f7456e2efcd265f486a424238079078480d69ae1ed02d24e00ec901	11940
1163	6f64218f8143b41bd02b87c79c6d02d3572df6ad50938de451fa40ca441e037a	11941
1164	b085d13e7d9aeb7c350847f9ad150fc16f92aa131a0190ace6ea740c46d76de8	11942
1165	43a64bcd05014c623846f6fdbe500c1114b233fb0bb311b837b0b6994ce33634	11948
1166	f9a093bda1adea76a17e522be0c4018d4b9addc77190c6725bb76f38842251e8	11951
1167	14237929ef2ceb2e36d9e43fbf57565abf3874b02a0549ea1a603c9e44131233	11954
1168	580bda8502d90fa4c4ed13aa559d49274b515a5f0a39b90db003a9d496acd68c	11960
1169	530ada4717916633ee0070256eeae34babaee71383b4e97d7a237b37e6d10c12	11961
1170	c43f9e5eb84185061085f1f0d866efb47a9811a75d2775f952ba5f2c4a351a58	11968
1171	4cc5b53f595803799cb71d3aa43413b18c55fdc6f154f1da6f5f965fa6eb844d	11987
1172	ee88c18e41893089ac2996913e86eaee37902185bbd96f90fd9bc841cb3b65d2	12006
1173	4e19f38762fe63350e97b035e51681e5f463b50b2dee1a3209252885f6570862	12021
1174	5ef77cb30f1ab3d54a419551bf4dbd7b0c1a0ddfa2e35b795a4628bb5cefe633	12026
1175	59091827657081c1bf34d91ef26f49e6ef3677e49b07ac10fdef930ef29fd74f	12036
1176	4e9d9ca2711f84b6d09fe8405de621d64d494f2a2beef449903d4b5aa6ac6fbd	12047
1177	50510ee8bf6af74a8d766a2cace56bc13ac1997a69fc97cf88f16371ef3df77f	12051
1178	462afd8f0e1b4d0cc730dbc531bc8b1d24ca4faf53f448c9ded4b22c7aa3cf92	12055
1179	757ce1c4d3b1f94b4ac56200d0c1ef0a8fa95ab219b887576d340d6be03798de	12076
1180	34a859ee4319c3e3a97c962994cb274b2ea21c8ec4d84dc779595d7bde15b6ee	12108
1181	3f182eb513f10fcaa576f2c949ac38615e22d92a0be4dcc9f56eb04b0cf4961d	12110
1182	ec148164ab27a2b0bca565a515bfcf79ac5607661486de3afa117e70650952c6	12114
1183	09deb0947bd6a7d655e8d77daa48953eaeab1a6e91c43e970ed79194beb50d23	12117
1184	028225fc190833da9e2eb0bff46482282988ef83128aee0128bc27cb211d98ba	12125
1185	6443a017ffa4fb6185c352e8973e746977fb7ede95ff5413d2f7837db0b8f752	12126
1186	ce6611fc3e4fdee44d17b1c551895e421be9ffd557a4a61c9f7eb415df1e13a1	12153
1187	557fcdb924789fd1562ae90c5fd34c9e9e735a2e7fac9594dff1970b44e02cb1	12157
1188	327a137ed0866fea8028bb900f16300eb1a081cb9f5bd846c3ced07be8183cd9	12167
1189	9d195a9b98d777260872ad13bf173fce249b862954e85dce47e5edc93f2f2935	12198
1190	b2d894c25b4a3c5b6f496a7738613d4fed7949af5f357ac2c2fab67eca13ed91	12223
1191	42b3c2c3c311764bdafba3dc058f47cef67924e46488d1ea30589fac2dbbe83d	12225
1192	0fe69680f3ac904dd2471ae23b5be4033a6793efab34d592fa7b62acb3ffaa4d	12242
1193	17bb81295f45d85ed1987b0f97dedcc825e212c0f0bcff968e361ff13aaae838	12247
1194	3c60ca4c58e806e9e8208572d9c78f6c89849ec70b97bfe08888b7da648f89ff	12258
1195	a96855d7f95af93b3ea1f39642ad5d9b78159c1a0b24e0b1d1c81faeddeab83d	12278
1196	37bb6f53850c43a9165e8a7509e56656688ee4b5212577098b958a6430d91d5a	12279
1197	bf61135e05c2797923cf8367026e7668490c848f03eb8acd98df7d3c6bf3d129	12285
1198	71fc3c946f48e440fcd0446bb46c8e727dbdcbe38748148fcba9677573610330	12294
1199	8fe27faf8e32d586557bc7b751ea2993ebb7edaa8b902455cf11903579ae06f7	12296
1200	056484f4a6bbb42522e17aa5a42b3ceae777a47ebfc0ac9bcd99104859c53919	12299
1201	b212ddbc7869bad04c240d466acfa0b09b66dcd5f322048abbac202fff98668c	12312
1202	55c4c497ff92782baa617d09612ec760dbd0d18d30e639a892d842a3a52ec6d0	12321
1203	758f43af2115c760828170ee3a5e444a131127676ed56df491be68f63175e652	12341
1204	9c9710d76ab26c82962d069e3a0affde48123921063d2afce43f28a016af7491	12358
1205	edb09c9841d0c1a12ea7508f92b1571083ad3c878a866e66f297ba6581109afd	12366
1206	26623d6f34f44ad921e2caef0da27cc418739061e06a0288a6b329bf510f627d	12369
1207	bf015009e6e8eee3e490b00e4e2419848b65992acf3bcadb594c0e9457ad099a	12389
1208	af32585049a0b832c6fd712189c113b2b769897d4deb545f269d4cef07530ef0	12396
1209	efb60003206c9c0ae9c9de17699297d4d36ececab5e9639c39168bda735c1ef5	12411
1210	56654f8d93c228fb2fa568839f7177aac4c617ee98c3470fb0d0306c8c96c83a	12421
1211	d6848a2eb6af2bd22084903c9193526c7ed27f758e35c211b444161d52690f53	12423
1212	0a6b6ea11ba8d9539f6d9e4b949a47c2719b8c568c36e5d65ff4a955597aec1f	12435
1213	fda90c76bfbc099b7da7ad24385a09608f39fe599cd4af5ac7b7e2443bd9ce11	12438
1214	debe8b1c2f4d6f4794bed6ce8c1031eda48900aa947c5520f91894a942db2747	12443
1215	f15a270bdfe8d3593836636ff0e3be4680c7f8918e713d06ebc42afcdf78e753	12445
1216	336adad84ac1e86c5f0d919d67d05bdf9d0acf0370fc1ccbfba4fbd5e9db20d6	12469
1217	5395d0acd844126404e443852a9c9f3eb2f7b27ad27edaa574e0b2092ff7fdd6	12473
1218	4459587bb8016e80a029fa3fcd0c9590402b6ed27bd3e8912861e9c27763b505	12477
1219	e8acf88b89029969bf0335cd98b57cd0a8a734ee5b3be63b737366098eb7f915	12489
1220	45557bacd56136d8c8e6004fb5dd569a8d0151874ce57ff2029e93b358d92c5b	12518
1221	bec069f9d1d3273cc4026d1a4546d210664c72b341a2772430b045c9950dde7e	12536
1222	878c2cc0f6ac400a5a6bab9f69ee30512f676b122d1503367b4152ee36790459	12545
1223	d909762ab14efd6f5093be8613881a8ae2799d7dfc849b984fff93da8a6f458f	12549
1224	8258e3ce1206d99633250f428790259e84399a945d18f524d7c58345853be1a6	12579
1225	4e7f049dba8057a31e947c6f2177c045898af3922528bddbbfad6093e67bc0dd	12585
1226	6fb61af401d4f62561bdc4eebf586a3124cb83076a24417a1598434a381a470e	12616
1227	05c42385a3a6eef330b0be1285f1f81570532f9af3dbb516f7bc1648957f0ea2	12617
1228	54807e7ee3e5975092bc943ce54996233341f38b47efd46ad771d066c6b44f02	12618
1229	939903b9aa9ed5fca4ea4c8c6d926e8670252520adc3229db2de13d79e0a6dea	12635
1230	baff35c9da0baeb1d75645848ec7301dea7b95cfc5b0810294a5947504ead17c	12642
1231	6fe4ba55218347b34f5cd75a9c3a8d389a4e07430ff9d37587a9d2d7c4ad61b8	12645
1232	4ca01d7f8868bece4ae89f629b4beea10144871a035a2dbf0bd3b37083d70345	12652
1233	89b678e9079b4f06f2cd7e1d0c9b28c7c9c1c4b09977d4b9aa38a01c6c6b8032	12655
1234	8d45ef2aa9e3029c60541079758388f8b9cca2b1b20e1809771248f21d91b082	12665
1235	1fe8dab6fc46c2c0bd1dab4068303ef9b27cc2efbb286df6c1870e7ffafaaac7	12668
1236	09ab35f1791e3978ea5fb63285ae862e1f5c474770d4eadc90a103d68f9257b0	12683
1237	3dd49a8f7ca47344fb6af580e8159a53785ebd4ebc22aef59c8277057194921d	12688
1238	66feb7d9e8dbba3345be1678f1eb5c412dbe4e52f17379243686b66fed7c3dcc	12706
1239	a84dc4b52e259c3864b7d9b00d34881de16dc0279128138138321f7b972aa71a	12717
1240	ad74298599db1c7fde570104e052bbd2fcb14432375118a74731d6771f8e9a69	12723
1241	55d6488d92aeaf16ce45eafe3fb81a56091b41cedb293e760f2a641225b887e8	12737
1242	28fce4ea6b21a052f80a5d47dec11b6f6156c27eaa79b9ac5e80b9ae07d831b4	12749
1243	25a6f9dabb65dc9179435a550db5a840a471f8f43b0a0efde5c6e12b3243748a	12750
1244	1326b8bc4190ef2c0cde9b515da082c575f33442001bf4e04dc88643d879a116	12760
1245	ee891d3b02df70aae46df8d1c8fa02bff13504d962cd0fcc7f727af431a41edf	12762
1246	3a72ad6480497ae7be49a2c40f2be093f2af78748c35887df1df0e5125d44711	12763
1247	31f69e19950c099ee00fad610a15e1395a2bfd36d2d74a848b83c13eddf0f31b	12773
1248	bac3aa4b16f58941894e16750d8b8425f2613c1dfdbd919f06d7d11845222b55	12784
1249	8541a43a4f2444326781ed9df982743318992c1c7b1dcb0e141c9ae1dc3a63cc	12786
1250	082eeaab3b644dd2a1f1c3f4c548131b0845df0e88c62f627bbd5a5adb851ed5	12795
1251	1edc97c41445c7b784224dca01084d4212a5be01ad38f23084540889a6850521	12803
1252	4bd5845cf8252731fd78b07c5417da52c46e5233be81bfea593cc4f0fff19034	12812
1253	f87fc9b530d5ab0e3b8b71b460c20d382359d66a035dfa4cd445af9beb82ca17	12819
1254	c3ff11e2e0fbaf8251e5f98f914bd328697fb6fa5a1aa22f181fc5570b9be6ed	12821
1255	8daf34bb97e0f54aed0c0f5247d81f2fbce89673f65f903ff070637af452feb2	12824
1256	cadb70cf995a8bf9d50cee0ab86398d6c4d6dc8775907244dd844bd8927eeffd	12836
1257	5b5452b37f25db2c143cee3661dfe2449d5d608fd084e6ed64addc13379cee7a	12840
1258	dfa66aeb2d034983e2607745161ccce0cf2423102a0d271d30be6f526373a355	12844
1259	b79479f80dc447f271c0f445ab445a3f0d393ae53a8e1a5cb2ffa505ff431f82	12863
1260	3cefd4dbae96568cac039ee9bb4bf340b6ca105e91fc21d59434ec9cb1471ca4	12882
1261	0b6c56d9d30f6f5aec026a942a41802058ae25f1bac20c96847e389fe751a38e	12884
1262	195a6cd41fa7cee9f96c3f7cdda038761d81c3618940f5fd729e60ec945f7892	12897
1263	aa383dde86dd8435adb6d5a5c25db23c52b4c93777efd8e951b134af9300fa55	12903
1264	b89235e845d6a002695593a26d22508ab60e75bf56450fe1fa5df625e7720d38	12909
1265	620ff0cdb08e248ecf37575fde7c12b206909f7fe758807b6b98c13354549af1	12917
1266	129793393d42e7f4213e7a966a7fdadad87cb5b0214bb7702d63a273ff3320f4	12919
1267	0d5bd4f073d3e65e00a93416eea1645cc39306a53a94fde6acd94352dffd48cb	12920
1268	f42b43a1f6b803760257e26b0ca3c4f2adc822883ce45b01f2ebc378c5d3d7ca	12923
1269	e9478d18111914bb7ec77441e173167b08b14ac6d72905972e65951e5bf29676	12924
1270	a665eb59cbb0993fbb420d4a2de5491aec3db68fb4af233ffbbc505831643665	12949
1271	57f18d5ff914637ad9bf887bc345686e0f4f8655547a4740707d3a93efb298b6	12961
1272	81e0ded67431780a5374622544029a5a0c0377e5127bd0c9b4e0633348da0859	12964
1273	8fd824474462de08a087167a7b6907613aa36be47cfb569caba6443cefaf5752	13023
1274	fea50440a2b915e577eeaed701ceecfcabf36d09fc63a84f420bf6b8ff80071a	13034
1275	ff1d6943e34bf368f2a1e242404735d9a49de433bce65513c339d27cdd8b5380	13037
1276	26122dc1ce3b48d40268ec2961586dc0c638cbb4bf8378d26124ec38ca11ae81	13041
1277	b5af966a5cb57de2c1c12f54d269b6c0b69734ac13732ac8a1c7223d8f9a57bf	13045
1278	77595f52ecb3db1ccc4c1b6ff446fca7527161dc80fb44d048ea5d69e4fd1036	13049
1279	14872b59d4430bbebc12b3584a57fa4d86fbb432be3429d3c9d2ffd8fa934a17	13051
1280	489b712e01ceef204b66442c79e8b90c2e0ea8108c4223895547118fd9becb30	13071
1281	28084b60d5d88ef3c221e7dbb4b73c34775da990ad9716638752314da03a3325	13083
1282	8c8cf5d7942380dc7652d59a798cb43726f3ed1bc0cde2631b16c1d475acd232	13120
1283	5ddd993b5d3c0ae2d49372e8ef0d4095091384eee11204c5577cc9adce4ccb20	13135
1284	41830d7be7cc41dcef20bc434e3a908c48454d37c64f7d10730be9c6afee5517	13157
1285	7e649b307417df69b51be5d7b49f38fb8af0358c71c89e3b2282aa7f8375c357	13168
1286	341d49bc7f75f88cfc5b381e0aa22d8f50e80377fd1f1b4e7caeb5c26c1d2eea	13175
1287	a721d9eca45ab0681b14e897a30bab1fa1bcaa826d26170fb045564dfbd0ab64	13177
1288	af927e58707c106f367e2f3431558aa1c1744eba1b832fa66a7bb511f6d2a08d	13179
1289	14a7eaa479098e78954b752a7d77d091823400b364bb0e3f4a2dd71ab244d5e9	13200
1290	b9b574a16ca0c1678470a5bbbf29cfb0a9f9adea6ba6e5de5ca6c010af02bb7b	13208
1291	2ce2d6366e73cd9e027ec430360f6cb0b000e56cc3c5e6b07ffb609a0d5d931a	13223
1292	14125c3c627963a5c900c08f0af490468a201e55b2bff9d66cf9ae0382787a0c	13251
1293	d3c42f8f9037f21350a32ac66d86256670205d06e6684e666179356cc1a2b060	13254
1294	08f9b1fa0856a016ceaafe906fa7d8c7959527a28841219bbf73080305da268f	13265
1295	3c5f8dbece028cd66cbf894d6dc406d7c33a5697fafb0e57dd837985548b8046	13267
1296	3b4b3d1b483dfa9c8c3e477bc12307fe14c3150e32d07557bdb3b88c4c8f9b26	13290
1297	4fb401cf5fdda272b8ac2f5e4c72e8cd8a908db0a8a886ee95da2e774e991b7f	13293
1298	72c145522faec276ca4903f43ced74c6c1258184c0c83efb63bdf82bb882a871	13300
1299	b34ec70217b32b554150a5cf130f910026885e0382a42a33a62b64cbfa4df7f5	13302
1300	31f4e643dbb77cc41f4fdceb9ea99f635b9c4c59aa75bb69ce48c3bb652a1d05	13309
1301	b0cb9e81184f77dd0716e14941fdd4c438f96436f79c17f5a149a7829a82f012	13314
1302	d2d9e90f579ca083bddafb72ff7bbbedf8443b58d469085a198a4b5e331b60f4	13345
1303	bf0e819a782b786dafeb72c4cc2b9a0adf54e9a372037fe8fb8108f95e2446bc	13346
1304	0fd6dccc2475ded74ea67d40cfcac77b65955a0bc956bbc8b709db7e4b874780	13353
1305	bb8d221a7faf0736b900f770b7ef18fa57fb08753c67962c0722ad555912e011	13359
1306	359987c76c0037a15d703d4a0ce9bd5a7f2ebe3baf7eaf14a46bc1c1b5bd58e9	13361
1307	397895117f92d29c2a1b255fdcf220653a89fde948d48cb981fd0412199e97a7	13370
1308	2e515ee189ad3a40644a45a2c5e77e00a22b9ca0d3ca86055bd6c86ad6145af8	13379
1309	1f61468222328b6ad41b0807bc26cee2a144d77645e40d3b16bff7bceb1a1c41	13380
1310	518bd5878b3d6df6e7b75e026d4d7267ae1cff9397b214854d4e4d524980061d	13406
1311	a0683b7aa3848e441fc6a3dddc8d9a3ee0f5c286541825e61ef074a612fb2b4f	13435
1312	fab17e974b9356c1256489abe840e06c8f4a1cc8a5e0165c8b172cb5ae7058f4	13437
1313	d90fb466c273478c5c6def254905856833fc515b029269159ab46410b9e4ae70	13452
1314	5f1a96a0ea63c5def6054e711a0cca59a4a51cb324597979f1832ec0d69522f0	13474
1315	1f54d263d98e77523101eca72bcaeb8ca5d72dd93bc477796c5d2f86701ccd9a	13491
1316	6e52aaf268e4f50830e95fb9ee2bb7699b5bffa4f264c5392657536cfb4668c3	13505
1317	1b513a4e770f4f85d499f5ae3ae266f957291891c5290b0b1521bacd242629c8	13512
1318	ea01b1c1024b62144523c067ce9ce5aa487872dab2bcda11962e7bf9ab019e36	13537
1319	32ec1d2e2b8e2a9b18f7d6c42412597db324665f4d707113cfeac1630d2e800f	13541
1320	5daeeff75b4d29832878933d2486a19921e2314b879aa8e78728a2412305d7d6	13551
1321	0d4d9cad42051421a87f70544f38f3637b79610cdb9ee794fe1d459bb46c45ba	13560
1322	97ed3742a5fc4df30d546419c3966076d8777879e1557f0630cd528a358e5b87	13566
1323	435ded8e9ddc0027df62b8e8b34ce4e2d293f4eb34c55d716dc716995cfb0782	13571
1324	6183d581bcdcd021f074edce941adce88fd167fe4d8a812484a67a5ed6f739f8	13574
1325	f9165709c195333f2e43dfd1bba9f6ffa5e4144961952ea6206b83e8add651c1	13578
1326	91774147b4d68e80b832d8752d0a7ba3a445cc7ae6d74b38406c20de4a003809	13583
1327	1ada29e70c42b78166f4ab78b1aedcc2cf641654a110148c75b07c25dc8c2a17	13591
1328	8deeb60196274b8afaa532e2ac504727eb3545103c5e7c170c80f01cd6414de9	13593
1329	316943b0a2840f0ea26a28951a62a620c1b80db8f6091eeaf5855c9c28c8c0a9	13605
1330	f7174d49920e5e47449a57caa2981cf0ad9a015966a43607d3cb54d59f837fff	13606
1331	b18772d8f8cccf65a48294df0484c518a632cad845c212d40f2700632a29641c	13615
1332	db03137decda757ca972e60d093289798e94f690d5027ed49ba9ad79b10ef054	13631
1333	49deaf34a69d794ffc3879d7d91718be3f40d15d5a36195475076cdf3ec4e6d8	13642
1334	ea56939ab20213bb9dff33effeb13f8bdfe5d49eb15fcae6b443ba72e4c97e97	13643
1335	8bacc3ec900b2add09c8bd9f54abfd8578863af708aa1d7acb2f66f329c9c579	13685
1336	58c53b9ca4255e086222f4a204f8670f3d6621ef245f4ef3d2f4b86c90c22006	13703
1337	e94736c095596fccdc0c98e4578fa683e6f41c74f8732a9e12a6b69a1e53c657	13721
1338	99570a6d2e776675932bbfe287ff361d0f9b824255b5ae8644320b3b774051cb	13729
1339	36e591dd4e4a14d27e9928844d9fd6a1b5959b7cbce6f901b3f9b59681849532	13773
1340	db32613071ac866e1066f6b44422087debc9ddb027a6bd88ee5d41445216a4ad	13780
1341	e2921ff7aeb0cc6d3a2d52e52f9d633ad611b062130999406b50f9d9c7cf77b3	13790
1342	b5129f99415258fa39b03e80f9de2492313c9db381d3da01e029a2679290200e	13796
1343	0bc14ee06c78e6e8d21284b1160f4023a6f9a7b05b0b906186a470c0fb426bf5	13798
1344	6c53ffe6ae50890a40203944eb89031bb7bb64359379b7af43229aea7e5a1b50	13803
1345	08d04203e90be07006e00839d175af26b9fa3295cb0cfba36803d14179c0defd	13808
1346	32569332aa2cf4c55902f64234fd686412752aca826c67a3e4230a0b2519b3b4	13812
1347	24c1036674e7b4936507822fce37fca4e00ace0b5c81d01ede8b91f98f616892	13831
1348	4a489907f9646bc1f93d094a1037eaa5360c0d699cb35f793168dbfc0193dcbc	13832
1349	1e05f52c9bdd63c61b6f5ff0858b8cd4964b94869decb5281ee017d6bf4741f2	13838
1350	ef44a13b2c45215013948020abdced568cc57cb752be04aa9a82b129ff19c8f8	13840
1351	785eccbb20ec9fc7c8b6756057c25136ccea3749fc2fe8d0fe3e80312842c5fa	13841
1352	676bed640f76fecaadc2025cf1640e0847f69aa688a9b5585e67ea0a9db4d1be	13842
1353	d52d91c3c3d431c0b158ccc2230ef11184c7e9eb6c8c32d335114a7ac9229cef	13849
1354	73f3f8497bcd9d1a7207e5a7643f11497f9c4526bb333d5b2592d134255623b4	13853
1355	573991637a870436f95baf52ec2f92cf827fb5d387ceb6e395668e42c7ec6024	13864
1356	201d7f233fb91bc7bb00886d8be2a3005ecd55db30ee5c8283069383b7036d72	13866
1357	53d90175d0245b99da546f220c66c4d860c895d99d111591fdffdd9877abc89a	13876
1358	257bb5d5e79977cdf8155b994275b2e96fb24026bc923671d7eff1d8f25ab1ba	13888
1359	1bd5b40b2e4ed602e5057acde267437ac5452a42c1e5783a120b63c5c9a2e739	13898
1360	4f5623bc86683a279f18032ef28f565ff666832e9dc9018262f55a1ed943c884	13902
1361	5ae67c73de2ee89bd9387ebe4f26365e7ea59a560c47fc307e5d2d4d896a591c	13906
1362	f98f8b256afaf0f590b38a6bf48ede8a19cff883a3077878b51052b511070107	13918
1363	32765ab7a5673d550613f80d69c01e3e786c2d19f3c7ac6127984b396bc5e1f5	13923
1364	3d7b395b7afc69f49730d9e0c3ee979a0b83939d0c77a9174b5a1ef9f3a58580	13928
1365	3edc6cfea5362b9ce7ffe66a967236e25f59b147a11dbfb30bddb1b149cd6dd6	13930
1366	e8656cd99155947428be61504458ff37c1270aaef2912055b07a6b17feb8ea14	13939
1367	b78dee1677c147d15971169f4ac6f4a331819ce3ad9d60979ac61f637c28a8c4	13940
1368	c9a25e8975645f1e4723ee04d44dabf91e5bbdc8e9158fac0f1e3ead09a3ae69	13946
1369	ba8ab757982d6dde799f1244fb11354a1609693e41d6b6d710ca6636ea5ba773	13950
1370	755b962e7b162a2c4bf5dac40644bfcc8a58badb422bc6ae088953bbe044bcc2	13954
1371	a7651d026c6ca389f1c779faece030d7deae1dd73f34073d31c2101ad9f47026	13959
1372	8b18f77babfed7649c5de1ef8c155775bb0dc92f07fe8814e48317f20a55aaf5	13983
1373	b5d3efae2182a4b36b6404cae3f59ff3d38ba52f2b8ec4fdd53ed4df555c8250	14020
1374	b93841bbb03d83e3c522066357c7536fa605a01e9bf03db06cf76e1d6c8a02e4	14033
1375	68410c4b1991121fb89eb586de00c4a429124b86570b2771418842b99672ff44	14050
1376	cde5138812de458952aca8a5bcd60b074676201642ad3463c8d48350d02e1973	14076
1377	2c78a55f89075506edf398405a495337a94d5e909b6d89e27f3b5c3a2d521891	14078
1378	cc15d73cc4a0d7144e5cc73a16489940254384e088dd37d00cf5b5b8ffe57c38	14085
1379	3bdc58fee19b71dbe366a25d798b7f12e7e881469170dc982a54a6f7ba041a17	14089
1380	59013120cef08f2ca6baa97b1975e9dfeb06d59b2b99641b6c797a7902e8c98c	14106
1381	56bd5c3628bb32a3a235f1f7f6db40559175205b88aaa1a42db3af6086aed088	14107
1382	1ecdbcc5a3b2f171eebe32e20005175e9a0d6e5500540967a2cabd4f08e8e1d8	14113
1383	e2b1064efb0d932df2fc62decb5155dd876bffd98735a6885749e7462646aaab	14115
1384	c76a0721d5b5ae56b8fa811a362b2c1999881481b3265d011b97141591a84683	14134
1385	7d1a6fc9902c5185d44375a930a1b0f6bee0330d113c87694dc19d7c48ab6b13	14143
1386	daa7e7754357da14d98cc5cd7abfec1e2acf24a4ce1993c86d799dc2e2f89948	14151
1387	db4ddc1e04b9ab02b980d7988833a7dfa4debf25a0c5c5350a4118f9f3d83060	14159
1388	c0113068921820a286971d442884809b43402c1b7bdfc5e834c50dbe1f839c2a	14165
1389	a626f602fd4273ba7f7fd68f75977c3de21d12d14e06e9bc8cdd37b48afb744f	14167
1390	2d6cd69f65116c319e68130be8564fb1ef6ac74153eb6f4b594bc6a075b5ec4d	14181
1391	385c91ea6a88f5ce4bff0416b7024a41a658b4c675d59835649a112d76273c9c	14185
1392	f5ae6361da07d0518867535e30169711ace09f88a15cc40a87204fef68e47753	14193
1393	02f8eb5ae4e729d0e3900cae26a83f28a37f71e4261303b0a4610d2f71e4d0c9	14194
1394	12ea2a58271c58ac9ab1d4c235141570cbd826b149cdf44ea9f944be96273be9	14209
1395	495eb74e2888b92d3b87cbd01dd973f795358edb90e0a6ffcdaa36c5b3113e56	14227
1396	4591f9c4fa9689d4bd2385170b724448c280b3284240ebf7de3793907beea703	14232
1397	ae4c66022134de1c430a9c08986902fd438e9acdb6c06cd35cb3f7ccb301e537	14254
1398	3fece39d21b5bf6615ba502cb771f17e823c7de136558aeb9d4b376205500cd7	14258
1399	a4c75fb8920ee9fff79e78b612ce0b0734aa4e2b02ba5937df372d7c748c7c7f	14268
1400	dcf586bdccd0896e6d8bbbc7f0ede39afdd3d468ddf68c1a2504da528be3d6e5	14282
1401	1c3a777b7d1904b998009857fac8b0b305c52108c24a2aee6fc543f6a1a5025b	14289
1402	e2300e70f10f81d9b315bce0d282081c46b505e1cfcf73188f2bd89620b1c38d	14325
1403	eb42a531ffeffdeebbf23ebd97a839356df5d43c8c33aeb1b4620f3be1f443d3	14326
1404	64af9b687bfdc4607218baebfcb4c2667ea64f55b2d5b51477f9375234517d43	14332
1405	475d20338d72a757ad965ef4619cd72d8b8d6122b8bc18ad5aa43ad79b94ed52	14355
1406	6dd2b90601653f387eb31a06da4ff8188e845a438a01ca21e8a51156a4ae034c	14358
1407	2de3146c3106d821f4fd737d069898e1ab2f25bf3bc6a5680d376b1060d2d349	14375
1408	d3d53a9a106a07c2b2c65885ebbc33e15fbf4cd1a550dc3bb6498c73362483bc	14381
1409	cc218195c7a46fca084586f0847d1bc00bcf4cb8e11e0ca7e40e931ae28f3406	14386
1410	d66de774ed9d5f13b948bd498d30082ac45ff4c14b9cbc00ee6d31ffb0823196	14412
1411	638603b1e7cf39e089da392f725a89252eaf834bb4f27bb55d4c42356aa12e32	14422
1412	079bce986106e53775df488196e98903635141a671c2f74d97305d3c10070bec	14444
1413	d6764f2f25fd43b1411b0c0767660f2a07ed51f98ce6796b43b219af0f122dc0	14446
1414	0c892a8b1d20e3ad112761bd0610de03c647ec300d46861b4d4472fddc63c4e2	14485
1415	32013a31ad50e445a9d0f92919d2953d17ff478ca501e442857495eab09c86ed	14488
1416	69708b8c3baf894ccfbf5952e597961778943864882812f27ee7c23224487ffa	14490
1417	e7ee0a45056e8c5aab4937046601dd350bd2a0f3fc47ea40ca4f2991c5f2f93d	14505
1418	86f7f4351cf7ba9035d97ca0dda901da8ade68b5128e476df230b82e0f5e0831	14508
1419	e3b7ac66482394b8ef19484c83557d0c2a53b26db46f88e70434a0a79291c23c	14513
1420	6ae45a8c653cb4329a0fc8a97a07625e2c928ac4dd6e2fe7fcd40ff5a8853c82	14528
1421	dbcbf8766bf3eeeaafbae31dbb22e8ff65d893d864a9f6751983e58c308a77f0	14541
1422	f252bc379fa1e09a7bd460f0f1eacf1d4f6ca4aea5c9a37ca39e57b15aca86a6	14556
1423	0a797c25a742e3d4f937e033f8219bf50685354b672ebcc8531a27fef16f584f	14557
1424	365c033eeb9b12461728cf41c91e358fc0c7a1743976befd6f6cbd17a0dc1f0b	14559
1425	ab541371c7107c15b1ca82cad54282d76500ccaff881f779c9a02bb50032da46	14568
1426	d8cae2f24ace8b230a9f4e7d39693dd7683ef5c069dcad3b4a9315f0b3036e9e	14572
1427	8dd84234a3a428a122cd43aa359820e9b54183e79c4b25b9d1787f289a52ba3c	14577
1428	2bc10d3497ac524b4c9881ac27419dc5597bff5788cd196e87cffb14118fa2b4	14581
1429	472ab2c8e1d1849fab55c9e7d9c3128fcf2a8087186f310167942acbfe4a7ab4	14583
1430	5d5cb3c2080a87525e81eeff1a39f344ddb612cebab155114600262079a8442f	14590
1431	27626a1b1193548e3c19282e4e27455eece2f01aba2bb437393eb2f8c4e34698	14597
1432	faf93fe27102824ff1352c860f503555fb253a88f1c71b6a09a62df4a41084a0	14610
1433	ce1b0dd9de1644df842ac636321d0cc4453eeb13a389d3b54062fd9d512753f1	14617
1434	0b40eb896655363d2c348d264d62d8c693801171ed690355056157832b00cfd0	14645
1435	b03e74f45e17779d178fd91083f31c08f60c64401fd2d46bd6091c5482fcb132	14655
1436	e1e3996c7e3711c88ea070719815881cc26049afa5d8a1aec49fb3aea9a5d773	14660
1437	dcedd85322478720cf4b0195f2639be406cbe8a54aed25576a12e440c8077062	14661
1438	6bd138c93fe8610ff33592bde69a5f9bc6b568d4dc50230a9a7ab424c89d613c	14665
1439	d4781f7267c3c73037d1a06a1db41b4fc99c27ffe4cf4e4ada5864a075084552	14678
1440	d42b5b72b245f3cbf28e1fef9d55bc8e8214b80a7ac954c62b21df46125e9363	14684
1441	1049d37cb45b8135bc60a32d4c69865019e8d2190763d0de5063ec6d93a0201b	14685
1442	e3ccf763f72ff17d2da56c44be4c77439c684fbdc0846ce859e6005e5c85d8ad	14686
1443	1f15e629550ee97e70a475e0d6fa0ca21e0f3ee146aaeba31bf81e449aa780e0	14694
1444	5a2086a9fa20259d75a1bab0c6b9aba0db05e01de1240f89997c2ff5e2d63b0a	14712
1445	eca15d188bf1f631b32c83aedd48e9b13e681d8f63e6fcd0c9a1a955020e9738	14713
1446	f8831c903cd5a7bb9a7eeea6740d53967df80be04a38c5bf88a030ca03ec2611	14717
1447	bafb2754761235ae5dcd794e4741e0a702d3f7e78a62578c4c47b68d84047696	14736
1448	250060126bc7968603dfe1d77079904ade6826b5d83331690c6acf65035620db	14737
1449	b9e0be161f344dd27e15d3710b3ea4f8ac535909f926ce1a0e4170abea29d213	14760
1450	05c6b3d749a36ad488802440c572f01f7292b7fc99841333ac277672940aa20d	14786
1451	664fc885e5c62c5ab997818e148d4e257aa756dde98b5e211ed86c1774256a74	14787
1452	9db973431d4ea789b0af2d85d9a25282b95c094d6fdf212ec4263020aa7570f7	14793
1453	820fe7839865cca74034a13a1c9f6e9895afd09237a930af75b598410bc0f690	14796
1454	b4b848c95474786866ab9952c448d4827a236a07bf465678b7b0a55b67ce98ef	14817
1455	ed2311ae2fd97621748fb7402f58d41b941933da91466f596338ca3ccbcba9a8	14822
1456	f17c4a1f952ac834542a6c611e45bae865febc06c669e375e02a7677f0f7e3d4	14831
1457	daa67f9474cf48408e75b25257e8af87553dc4b17408a74686dab3058f0806b2	14844
1458	d040ead9f7af6855fbdec188aaa0f3ce3ad0725e7604100cc8a19c76dbc39c11	14846
1459	9392e2597c9a75a2d7e5ca43e6cd9c7a5a427c96b3bb4b0b9b53a750b5fcb9ca	14871
1460	c718b2050e61cfa5dfc6d41e9083f42d4fee4fab317a5dac0699049215fff05a	14889
1461	83c3f0b21c4034c31f65121fb26bfef6bc580fbef67a2c2ace4029473292be09	14892
1462	31b9d78774976f96903cef9e652c3b5c0bf8bd0d06167d460a871c0dc9694c5e	14917
1463	a1be438fc23bd5fd19d778357ac6565f3ebb8c686b2d866a2baa17057fbe8eff	14926
1464	59526bab66359c8708909aa669aeaf066340386580707f87e8a0dd598636bf10	14930
1465	7619a57b64af8221a4d27e7093a8eb54875ec1ec4b663a4a4b9afb2a751efc2f	14932
1466	c93b631a327322bd5baf26a149810e846ff717ca28815f475c13a60f924cb0fa	14934
1467	67ed110b6bdea29b156567159412cd6fbedfd4ebf21907d7bf2503a961f3e654	14944
1468	ff253bb9dcb3f03534451741247cd6cc79c7330808e22529ebe0430c871d65b2	14977
1469	7bbfbe961279c400f962edba3061db1c448178b565b4d45233a45823e68024e6	14979
1470	79edfc02405c26a9536f505d93c6e3abb87e3f14089ddbbf48d91a312e44ba90	15009
1471	365fe3824c558418f7f3ac08b7749616ca6b1e24f758370ff2407f206faba9e5	15023
1472	fa26cf7ac51453af6a3546240e30d0981fcfd68014382aada7430bbe9c46aabd	15025
1473	31057ea2574de6b56ad6ffb60beebe656863892b2ca03c9b98b77ae5c4ccc0d4	15032
1474	ea221d97bbed24d62f04fbdebb320f288916691d10ff7507d007425b10ebd4f7	15034
1475	6180f975f9ed06f36bb4837438eac00bf910d7f80b4987311b5bb4001ed3b4b8	15040
1476	4b1d2000903f1ce0ed59c7ba320a184e13f0f39e9086c62ffae604f4f3eb2896	15043
1477	fd127ccee022d18bd09f3313356f31903c04850e840ea7ae668cf20edac13262	15045
1478	702ac8fe3e0e95e7f606595bac025bfb383c16a1d379c7948a30b0fa927e8327	15063
1479	9b3b07f020998714c028d508c808dfe54dce8f10ae15880487345815420bf2f4	15065
1480	c2787b23d904a0a557bf31227f91b5fc11107c18c7c576ebbee85289d50d0ead	15082
1481	9135398a24c2c48e700b245019fa9ddc857a13046e414a8d258fb893b222e868	15097
1482	e4cc4b11635e4d454b0ff993b19d2a979e4e3c251fbdf5ba536991f03bc784d6	15102
1483	a1ca57a256fea4a044b701ca96d905c43e179358ca2dbc6ec70e5cde8809608a	15103
1484	07735766da9a247e3752c4a1aff6429e5bb7faa900630ce7ec2307d8ad5195de	15126
1485	24db7df9e1d96c2441a06f0adf1b0e046260a6b609267d3eb949fb80690e0442	15129
1486	c51ff80ef0f3838e61182043c4b9741e1b31acfa8d6d559a1acd7030fa37725a	15130
1487	b988b46bcfe3842a4dea27c039be468d555961d50dcfbb669fff0558f936f07c	15136
1488	f4ba4df78d6453929b7449d86a3b2c722d94673f390396c2a7e1365c839cbba0	15141
1489	dce3095a12be5e653777d587723a2e9ae18c23370e63f7056622b0fe6dc252a7	15150
1490	d0a04b9b78a5df5f54723d1e92e53220a286909ae87567356244145614c2b6c9	15152
1491	9bffea81035216bf2949f99d7e894833ddf1881dc811dee557e577d79fc5bc90	15159
1492	ef90c40c29c4a9a107a3801450e112cdce3a8735ca6982f3f60853992c46aa72	15160
1493	4d11448b312e7df143a89d0c5bad3047e9728f0df79dfbfea7088ea5510353b5	15169
1494	e595330e046e6d097481f5695d743871942590907572f6a05e77aa9f9190f7d2	15181
1495	3ef0293396a8af8fd44add64c96414dc3be750b096d296d8137edd76d1444882	15187
1496	7b720b11a51aea6d7315064428e7c585163aa79d8d0706d9098ff77a76061523	15205
1497	283e43c33020d299c09520fafafd65e0d809167e722bc28ec85ac96d5326d2d9	15223
1498	53ae448d774d718e967f21256991bf4c7d21d046e481fa1dfafd76e86bae1f63	15228
1499	029decb489eea988c739b86a69f07828236fd9e72a369a765b714050b4954835	15247
1500	194e5ddb43175b32cadef76b5aa0a383a23438abe3bcf8b5e3fcbeda46b53320	15259
1501	fe5b560bcbc17996f76dcd56ede70addac4b99c6b19d14fadf801c3b49881919	15263
1502	c82208c330e24defd7c971ea7681fa3b43166fd82f74cfa3ab537644b2c93b45	15271
1503	ec1a0f16051929b61af1a756078653ac2c305b6d58d1f2faffc2b51620d9fa74	15280
1504	3d59887b739539903ffda869c065e9d371c7a4d9147f3bbb9a3f8ac4e2358f2d	15285
1505	ab2c33e1d1535e6322b8305a66958022fa3a204624e0c48bc66ec97cab909a3d	15324
1506	7d17929e69bf57e58469c64f16159f4795ab571a4687b539841f8ad216dcebc9	15329
1507	63ed56f79f1660156ae7f49464b7f71bf6ba1e405bc5ee0e7db8293007677a4b	15347
1508	b618977c5a6b7f09fe69aca676273fd819b637a135736175e46fcd257d7e32c4	15355
1509	27fe0666b6b9f6fccbfe8e43b82c62527208f152156ccd3456a7332b953b72d8	15372
1510	6ce541067900dc715951c1eedb79711317cc3ea58a6e8d0c564b93d70d08daa4	15385
1511	742164a6673b67e2602c96050d12987a03d331f0fa01394ee4e863605c772dc2	15387
1512	0e38f2ef1efc1c98b552a4f30e0e9b57df2beddb7258a2f165cd2c07d991d634	15388
1513	2c5fceaa61c1fd979c01fc0035efec09dba8b5533e87ea1f3dddf5e6c63c652a	15389
1514	321845e2b7b28f4b8a8fec30b4860356f2e1dfda822163567a6aacbd93b92656	15419
1515	482297d2e7ea4bad9b315c33f63992b89c3a1b45113f4210a385359d46532a81	15430
1516	91e1d2c8c444ae576b2a553a018009b7c46911efee3e5862a781560ed2526d72	15450
1517	1a2b8994aed366c7cc4ddc7d3bf7e84a4b5040debf82adb515e989b55757ae28	15472
1518	fc130576c9ec4b8084393a00ac2a3a19742ee3a6bd70fa0082943e07a3d6cc25	15475
1519	72e6cab6e330ab081b0afdc9163377f6db7c4ec4eaa4a2e9616b2e05242c1f63	15481
1520	7582fb6291e7a49b7e9bac3cd077353b9ea65a68ac1c0bb57fb2a179a5b5b90d	15482
1521	955e756ebb9738ffb13d37d2c92d6667d4bcfbfc48308467d8af687f8fc0f5d8	15490
1522	21726397a3c3528ab608cd5bdedaaa4df83d9c06982126b684433a5718ab720c	15505
1523	2c2f4dbb296f585a280c24323dc164ae23da9d800b1a83cd2749663287d6b828	15511
1524	8edfd620587cd8c58d0d70e2a61c3adfa2734e07148d6d4bbcd54666ccfb9936	15514
1525	6d91842abcce02e98946cbbd5d1fd0cd623ea41b9baec9182856d3dd4be30ecb	15520
1526	b95842a1f1bfe2cc0d3eb660f571867aa2d0947deb62a4f4612dcd46e3dca797	15521
1527	a6ac30088843988b553c76fc7dc092ee33959ca5b95510f2581d2d526d20a981	15534
1528	7fb069c88a4713d40ad0809a49a43ef70c4c44a63d9971da915baa59fc82f5fa	15545
1529	aa5a8e0659ee33a50a9693ccd99050abd4759e8cd5bbefd50f9d5119d4a2d6dd	15559
1530	84b0a47056530b35775cb4809c6ad3ae333e589f067db6bfeae856fd28fe65f7	15571
1531	c671b5a670c0a550e4f3b6ac270c115acc6a2eec2d39ab34f6392d48e743daca	15572
1532	bca771c7117409c4a9fe886df37d3ed8f30bb43a6fc35dc17ae4579c793d5425	15574
1533	4ce92a72986c1d00fe040b50faa96001ec01946e39be6ac45cdc4e62a78645cb	15577
1534	1ab76f65d37f46d01b7617cfd41bf89a8333412066c811f61926c05d2ea962c4	15579
1535	9175b81e5d312cbf64fe05f7f7cd7883f9d672dd6da4b10a36b10b9b91c1a750	15597
1536	da4231286997dc40feb6c157c8dedda8f9854a0e694f58559b1d0b4191678818	15607
1537	0b79e8879b457592e4502a44f6f31230520240be78625d7c483a3af82666df6e	15608
1538	c547756b035ffad9ec4463cc4b2b711dbe24f34d1856aff5261ce2d4f58c0a6b	15616
1539	dc941afb0e2763579a5f98953bc853d6058dac697ff9c42d11db84b7b984118e	15657
1540	151252a814db13693b65c2867a3215373ff5775ad6e7e24a6cc8ffaa46572b4e	15658
1541	3831962cf3e27ed21f2093ad27c5cb2af2a5b472a6e4bcf3d7f67908fbf6470f	15663
1542	564204fc58e824c5238afde34d8bcbe6ec2ef67a939446d489217c872b26e63c	15666
1543	a7e1e277f11014279273ca8a71b7c79b5d76a047559a70083903524576433a96	15670
1544	36a7d96886deb5079c53d75b1d827b37be4831dc4b4eaa5b37d98ff2a893c995	15678
1545	b416fa71edb7b3d4b5ea58e9bd81fd165374ee6f3a8c5868fa9e03ad3e3d8d03	15680
1546	f6c69524934ca244aee3ad01f1e948b0d96547b01b0d5019a3dd459ddc839649	15681
1547	5d789716f26af7fee3c5a4b6e1625693b963edc4c0cafad30eed8e1b360990ab	15695
1548	c089247ce1bda7a80689f6081fb19f42935cb0f2ecbe83245942eec8ece7e94c	15698
1549	2d2e1994a6cae59419c16c16d327745c4c5ac2a4dee93f851e13c9d282a73d10	15699
1550	9b18f117f08cfcae7ba0e2ab6745a33b47a590edc7b7ae163cf62b61aca4d628	15735
1551	b6b10e6afffda56e0380ae8d7d4b4d0faf3714005f8bc321447bbd4ea1541b0e	15737
1552	cc8e0aad0024c49004cdba1db681c772db213ae2d39e16567b99c911541ee252	15739
1553	6b76b76ea0c6865ef4a53723e2d4c9fcca222e36c08e48a1ff673615dff5d6ef	15747
1554	ea0b4d0e659fe41f215d60d6083791914fb6e7d1d0894573da99b826d68bda62	15766
1555	4becdfe9a3e3ebc065906fe0b76e6cf15d1d7326c17d7460db518dfe8331e07b	15773
1556	ebae0f714dc657ab7a419b95a122c66a8e7dc4a465e35973192f4e92d5316e51	15790
1557	65f98d7ea64275db437829f1fd78e4113710a194241193c22c927de73c670f71	15794
1558	2ce63e18d42b9f7b1d273586665cba01e3c253ee770ca738a4e8f9bb8309300b	15808
1559	8ba911157b0665218eadf31ad92da36d077defdbd8c352c91aeb33be59503629	15814
1560	87c764b37c2533889a0e729600b2e36755ce66eaa2a260bf68528fe940222fbd	15838
1561	960986d730701a3d6599e98515f754986289ad95e7137574ca3db1f1f71f4065	15839
1562	be5142579a9f6c3cea8766316f81b74a74fb0ba4ff709a70b04f3c511cd01dcb	15853
1563	9a15f82fe077ddfffe296e4675c190c139ec873db44218eae9b33f5c093ec124	15855
1564	a2308cf70a5cce5f6d5bf7832a7268db7c832097ddcd1cfbec51c415957b0862	15878
1565	479c05d65c12bf3105b55321d8d1a927986f50bc227eb9d5ffcf1d31d91cc63e	15881
1566	8e578c252be349bb6da6a38692d5c8e59b20e4e97206c3ba88743e2ef2dcc906	15895
1567	17a18b821d70d62e5522a4dcf0824a863727ff1667cdb26fb03378fdec464280	15932
1568	c5d2d8faed893afde267df0a25ef6c85085885d2d64bedfccc6cb53cf55e0de5	15952
1569	3977f1b93537ab96aa3e7e7f54fa0188cf858b16c5f879b76ae2f7f0f3e9e166	15968
1570	62c4febbdf9f27ceb848e8bb6cc9002934666cc58fac2df40b03e984c53f86e6	15970
1571	a92d0f309fac908b9b48c77feafcc32b52e7b7af12e256ffa0aa89b5d84bbf9a	15972
1572	c27850dd6cbe5e41223b22205b212033ba8b14c9f7143e692da893dbcd0a0e56	15991
1573	722ac1bcb483548f54c500e35db5d34e0a84b1a6d82b0234273e90b3f9d2132d	16010
1574	fc40090dca5242f0fcc48916023de51329da15843bbf8a2efe62e9865290f6d4	16019
1575	8f0e49b18b296b534032a4486c9c4213d4f4711c476eb08dfc195901da917967	16022
1576	ca11b34de6b19fc9b62ea820c9f92762e5d5e5faf569cb6edb02af3f431abcda	16026
1577	c7faa251d632fe02316afc3a08ab85478ce82127af2aa60f0e522fcd91ba8e83	16027
1578	4b4df6888875736ab7646d094f1d45e5479add4c92a81aeec2bcbff7bf195b6e	16034
1579	71779dd6f9c004e1ea9c3894ebea2cbbed536704e81045a6d9bba1c62a1df078	16042
1580	4bbd035fc4537439a28e3da26da66ad630ba553e25b405be60aa9cd03585b692	16055
1581	0c9ffce019acfdaf11aec3a0459625874e19c6f31aabba3604a74bea2d330eba	16059
1582	c80824f7152927ce472c6da636a1a37c4f2f290a0699b8878d5068a1ed4aa7dd	16069
1583	a2c10543334fe7a1130da9fad1c0c78b2556c4439a07e9aaef717576f75ef309	16075
1584	7587a6520d716ad7f75a5b6a146463fb01a1c66649d768a75a32d9a9ac8cc6d0	16087
1585	2bdafe8f3aaefddcebae3525439815f5bfc6f90060584647886bf2d30216c42b	16089
1586	0ed1cc4292a992b6d85589c13ece9d614fa70525770ee4f73c2650eb69594ab5	16093
1587	e75b9fff0a3c454a68b9f230eaf87f9c2fefef3677c598361815ffb55267d8a3	16095
1588	bbf3d1f5473af0e6341ce6bdfd15b23861a98910d85121577cc51f95e9e3d4fc	16096
1589	1a401f9382b45a18598dd1543f1f7d793f549e76884c3359cbb8c10d88b1ac01	16105
1590	58b6cd814538afaa73b5faed05baccd20969dfa54cbe72f24c4eac26a407ae7d	16132
1591	e131dff37824ff5aa1259994e45085a96857969d200fbf9ceb130a0ffb31d648	16134
1592	2db9e91a494110c7e0bc0268d5f418588c182d831526df370a54a81a564f5f97	16136
1593	f182e1fae70c66b67d89fde5a6b2e65527ddd5169ba5525ac97ea83db51e16e6	16143
1594	1a093b182279927502ebe94a2bcd0973318f13e6e6cf1b5888d94063495df77b	16151
1595	94da8f0cf8a9b5baf3a45ec6e3db65ea67ecbc4729d72398f4f3b843dffb2fda	16163
1596	e6e14408ad309f66aa404e79deda646615c76eb89e8dccd477f5898f5d3befad	16165
1597	f454699cbf72bd75309ef9a8f7b6fea4e4b238bdb74b13889920628101ccf653	16179
1598	492bf1a169ee662ff238596fd758e8066281450dba72d60817b57d5f030e9ef9	16189
1599	ba992890b53f8780f2517780d3a2ede5fb476530cf4b578dbec06205f3c81bf7	16215
1600	77bea438dc56be003f45286e7de562766ebb5b8413c51afed972d5a91b47d868	16241
1601	a5dfd4588d77e77b6c49e0ab8398c7693183bd19df825f93bab00a5e303af1ce	16249
1602	b86d5e1c990887ef708c5525c39634b5efa5ed44c0de9d0656e1112e6c29f0b6	16259
1603	0196eef88cb535d779f7b0fada116d87f9f4f11da5e58a8a10b2697328869b89	16279
1604	229ebab488a4b61ab1e06eb6958c692fa87e74fea158c133e6b46630248526d9	16280
1605	736e7a3c70e1c9c5d3cf6289bff00ea6692bc54cdb900782a1cdd9e3a1728b48	16295
1606	47b16391e44104ac2743ce6afc6981bbae7704099d62b360e7fae905271c80ac	16297
1607	303e30aca2bb180ea8bb849956cd5853aef0b8c4cb8806b2b5578fa608412f65	16302
1608	0ca36c7c3ba2d43e9e831a5f06cc3a62a2261d9cd0e86b9e2646c43f611a5aff	16311
1609	9cca8440b544e5e7ec82e73f401ff5ba3b593387a6a1661cf7018780bbfd446c	16332
1610	167bf0d69aa0acf5a3a02f36e4b92654d676ae40d58e673750ece9682c30149f	16339
1611	581a4fdf0da82ba53970121db29d3d0fcbdc252a950b73b365ea2be622306aae	16359
1612	b544f53476a66e40359dcc1295ceb90f19f598d5b737ee25dc513e127d14d723	16366
1613	07db9f7ad99f11dbb356ed11565a91a1e83d4013420fe8cc63e0c75da1774694	16370
1614	67bea20e39f4b7b90e870bd9424c1d80112c2dd465720b84b04c7a92d2939fc2	16381
1615	f25b953b5c577a8077439e24ef07e3d1c1135273ae17f9c8e1d38ca4f938a82a	16384
1616	a62b229efb5747282e255960495307ef9f3375191cd5bce49818041a737e541f	16398
1617	aa033132b6ff608e558d64e6f87c98b57631bcdf53b7c91d1666ac8aa012f917	16407
1618	9283661e635d183f3030d3542b912aa941eef49bf54cfa0e2c54426a5d234708	16415
1619	a80d3005807a53512b9b6112835fa5035fbd3c52eb6faaa73675884706acde96	16420
1620	dfa218c01881cf0285b3fd534984830bdcb93916ef0c81a232dafa93df733236	16436
1621	6b010b241ebf7b91726b939284752009db5c071752c1c3eb1d4d3d37c8917d25	16446
1622	e7832cd0ffff2ac61817309741dd1a2bf741d78eddaa58dce632af29852f12c5	16456
1623	fa3a46662bcdf84e3ac3c061151acadd1a537605ec911a9684640d191fb0b3ad	16465
1624	2e6e14a958373233159fc9c5df948100bb3f03d9974dba531d420f82747b36f6	16469
1625	16c3a57e538eac03f9264345bea57c1ea9ccc06a4ea5bda63a095c982bc5c157	16472
1626	cbb30b4b984136af2f22517a616993a9960e20a90b23830608df28ab08267f74	16477
1627	cc53ca6da196f0c536dfcffff81729473199cab2ce2cf1b3c56e4f942be1874f	16483
1628	fef52c62d817228c540227d970b638b6f17feb228f6b267bdfebbfe7f7b13737	16491
1629	da2041bd04c3ee9c54d07f531575978b294a690c64fb28f613058d04f43bbef6	16497
1630	1daeca556971571587a92098fc63017e5add25464975405471ada9d0509f1938	16499
1631	f7c905a399a126d82b50243d96d5421d85677ea313f1451ca39cb4e9067c0ff5	16502
1632	1565154d296b98341d9a9c9ec25772f80f874dd03c0e5572c7c5b225995aaf43	16532
1633	4c21fcbbcfe90502f00dff7ede3f08b437d9c5f05bba10804c8aaed20d9dc22f	16535
1634	f60479ee7aa2e76be04c12c01eb160cb5973d3cdcb79b3921107eef6abfc86db	16540
1635	d4a4a8c1581b1d11726255c048d703f39a9f94b7a23fca89d69038163c34a84b	16547
1636	41117287594c103303607bc23e1999dcebf57effa2da563f1cdc9b871d227e47	16555
1637	99d4b01215f0ea88fdf779c6b0e17d89f22ec28551315540e63d39508a5858ef	16561
1638	8f82959195478a48793b0b02bcb019a96658f556d295a3ca72dac4f3ff11b0a7	16588
1639	0b130383812bfb4cb6f8c5e906aea408ba703fdce9a1fda302e457a1de0046cd	16607
1640	bb6b4811b062ed642720ed272cdfb52e66eb54bcc858bf0c2c44f338156eabf0	16613
1641	ca79c934643f8b4d364b54290f81e04c914ca04f4fd22a4200cc93a15a87f11e	16627
1642	991e7ef7354f7e1e3e4ac80b250f983eded32464adc5295aa89b7afde4a54ce6	16643
1643	96bb554d4d233967e4ba2281ff2aa0fec4bfddc34f31b44a0bb1ea3f07e7464d	16649
1644	a6f647c62a7a02f9d2f85cc298ebde5604def308dae81f9c567058d5912630fc	16664
1645	e3a6ab8061900e594d3877e0afff63b9d431f892abb5d34344f2ada431c21864	16669
1646	ff66cd0517d48847a6ae6751746b6504c40b145c0bb85d64b495f74a7662ceea	16672
1647	f1af11b84afa22b831f2dea5c207909aea2267bb5c648fa247de55d23d6772e0	16681
1648	63e8301e7584568c16f7544f18e4b395bdc7cbf224ff71c3f418fbfb5151bead	16683
1649	3fbbf0769c8ce9ce58025b0d3ad98194237c8266a5650b35b5cb117f8c0e5cfe	16700
1650	1702a8eb763ac4e50116403584f35c004a381d50f31a85dba4cad002415c62e1	16728
1651	73a8abb866c2187dfc8fc73f18b664cd97a94537a75dc739c13756572ed5e849	16731
1652	088d748c9609150f9d75790c17a05d04737c5ce6a72b8a941eac62c9f4cf7535	16746
1653	69075d72ece07ab94a71c7269f800426b622addd933cedade93ff7c73036ba81	16750
1654	7d5bd93b88d0db52536ffdd794b27534beb8386e0b399948abae25fee55dd972	16761
1655	7ee1ef4a84f149f9a2f24efc5667402630cb9819c3c08977c8ec21748a057ed3	16765
1656	050a990bb69e3f2d07fbaf7ebcd805d180d87bdac18af92cbfb339d36e506d68	16766
1657	0cdfa3efd1a8760e2f31582d6e72ae483ea36d08bfaf45855fb212d439fe908e	16769
1658	bfc5d6372821eda0d7601270c24a3da7a02bf0127cce95520637202dd69c4c44	16790
1659	fa8a66a8b577cb0876b327276ad994ce959776af74495599c9506b019dcfc846	16797
1660	d09bd30d3bcb644670c88a655f4a160757ab457a032155714e635ff7815ea2e4	16809
1661	c8912d6a3b52a3b3831add4bb31280d8e41c8becb4d1fbd83e4333b5b0a1bf30	16813
1662	3649e143a09e7129daf01db7e0c714e6be988c2145d5d53f2bd0b4e507a4cd4e	16814
1663	e5af8eaaddbd8deae4e65ed41e59ad679f5fc1a776ddc41d6f399393eb977181	16820
1664	b885dfa2f6149934ddd2f97927b3ead233ddce8832a89bbaea56a3551f003ee5	16856
1665	573e6d9a74707c2d954f7dabefb7de161458659eb22d662f1eb193d6ffe7a6bf	16858
1666	63f5e3930faaaf677a89468ee1bca356947bbd183482b1c77569009d9ded5aa6	16863
1667	ef1dd30625d5db00ccbdae53a5636b92c69c2549bd98c4d13d2ae2fbb3f500c2	16864
1668	d2ccce6b4ac8b920331202cb66c0c2affd31a1968bad11b4bfe15c39a18e4151	16873
1669	1045604be1841e5ba5506d5e6eecfb5401b4fc2e715f49aedbbe5d50dc2106d8	16886
1670	9937ac6932bccd7f37da43ff0f3506fe21f5c44649854bba3261f2ac228c916c	16898
1671	740c63488eef128bd7f74f3e51b6a422c4a7e126977828d02cb5b0ae0659ead8	16904
1672	b6310e8b6dca01df560b5688b4fc3e26bb229273b5da4d69c17bce5c39bc16a5	16915
1673	ad6d3ffdc306c0aca4a0e1fead34ab44f89bab9608afa104c4817f0a67939f2c	16923
1674	1c4365dfb0354c3e6d4ba17870aba75ddf82516cb3b1c3396712d436bfe8a508	16926
1675	8a2fa195a0d688ea16520f0ffcf9403df1039d01d8ffdc93079cded4d3a8204e	16928
1676	9c51404bdd52e08f9f0f8ef7f6b17c44de77798be02bec59998cbd55ab78fa86	16957
1677	8fa059eab9c225af721ec1bd83bbe1df3ae00c330500d9ea9e5eed44b8b746e6	16959
1678	71baf185fdbea89ed3eba2487c302e93d77eb3850826ee8fc4e98acdd25e99f8	16962
1679	02c5109aef8fcd40e4242318c69d5c3b9235aa2e0056bfd79c22032e29f19a09	16984
1680	eccb7c364549d025f572c562ca003ff75d157da840669d44a841e33c64b5f7d4	16985
1681	518cfe6d7a0affbcd9e3592f35df8d58f6ad66c187ca9f2bdcd44cca53863184	17002
1682	851b95acffed6c4dbb5b6b6f1b8ae379e27e31ab887aceb4764b172a1d808939	17004
1683	dc4283aff105e414c4840975edff513b6d979f11d1da5af86adbbdbf1a9135da	17009
1684	da4c0cbcb38be493147a42f45b6a9a1eb13f4ac0cff1ea44e497dcfc04fd608f	17017
1685	88e7efc17d40d395cec0eed9e4693bed003efd114060b1750ef37da1a7c4d9ea	17028
1686	e68fcc5df6408c624bfb9bc3936e8b67a37614472565062eda081bc63b3cdd35	17048
1687	323bf9f136c8d44bcab578997515e9a5747d66b53f8496c1310db5203f21c7a0	17056
1688	e05b8c33abe1ab8e509dcf9d28234ae7d359420cb1a6398523eb8e9710b548c5	17070
1689	d9ad86057e093d0c0e8a602f8cb93180531f3a92d7d54eef5607e7437ba77499	17077
1690	804c767b36965c24f5fa826aa149e4d6b87c8df67bc770c9225cd7ff1fd80357	17101
1691	902a4eab4aac487ea065227588720f4b219a6a6016f66aa1b57cbb6053941419	17113
1692	f309ef5982985491198b3af4e02e92dc53fe61239d09713145f4d10d3b8bdbcd	17118
1693	4a92e381f7a530151bcf665bb2a888f5835c352568fe2a8398e3fcb1f0a03cf8	17122
1694	f73188e8b450eebe441e89b360aee108e4aaaad29321922f739a151c24cb8c10	17139
1695	64eb9c515f2a6e0e1cc1ef827606f9fc73f027d6674b793980b09e019c6908dc	17163
1696	7caf308ab54b068a0dc41d1ab8ccf3cf514816628d677e3f75a28748ecb493a1	17166
1697	93be99c832779b90fb29df894f354411d4dba28c78892b7a408b1371a9ef747f	17174
1698	69b0cca32abbef4390ca6510d6b790988bd9e32948d82023ac3022ebcede1568	17181
1699	12f6975588f0838e9eaa01ce1608a720b0825f9a3557a0daadd483d37491a206	17206
1700	2b98fb55cb3baac13006a15a7bf9dea83807803289fbd54eb7f638fe18605046	17209
1701	fd6c50709fb03f4b66df0ff5f1bb3e431551564c5e21cfe2cdd0f52111cf1192	17226
1702	00ca609096a51e304b4ca66232ac251538036e4a9836f1a912792c0e3c46d8b5	17229
1703	7a294bb16da1c5a4688d209ec90d0b102de11a30ec57acadd38e88c8882f92e4	17230
1704	bee942904702b7560eacd506fee60512c7f34142fc9855856d6a8939579588ec	17248
1705	7b9df7bfa759ecaaf08382910c14261cfe0189d6ac6204b03d54261a5d024b10	17252
1706	321ba381652a58a93153e85179c8acc48c9bae3a53ebbdadddf2e0934f8bc721	17262
1707	51db41b9f0ab77b9feef35260f61125d0da65d6d3f79bf914ac046eec00ccef8	17275
1708	ed49f2fdf0eea6cd7f0b589fdfb0c9a90dc3cdecb9ed87c33ed584d19885d15f	17296
1709	b4de967b312ea9e5bc95e024c75d57bf76d78536f059c67cb19e4bb78b48df4e	17301
1710	88e70e144047eee39d5df92b18e5b994f52ceb739d2ff5f724704ba2bc090268	17336
1711	3074e7e0ce2585624df6a5610b2fa7aa0eb6a65cda8ab265264860a8d1bf1a5a	17345
1712	c19a616ca65ce54b356a873a0dcb02977e6db6d90a1c080fd20c5ff54d066df9	17358
1713	80608712596a9639bc6620ffb52d613cd2a8fce89bc4ba13c6ac6ae710812ccc	17367
1714	849d94a9b6791777e39f73b2bf88d8334f97cedb0dc40a0c9bb07bba53f0bc60	17376
1715	716d798a37e9ecf934e419a8ac6bae777d91511749b0c2c56c5892a3a686ad39	17379
1716	2b9194306319ebef017a23b987e97d32404cab74c4addc145c6bfe7d97b40b09	17381
1717	be36e089171595bda99f31d122f2c4bbbab0eeddfd49861683200aaaa167b13f	17384
1718	db6be4826285875c415c8a704689446bcbfc583565691f7944eeb44a5da958b2	17404
1719	45ef449e177d9286c0c080fadb43148057b8cc6f98cd8440dda509e80adfb20a	17431
1720	2efe5247922b3ebfc1fd9932521a29d2e46fc53bb77752736bcbcb2f72fae6eb	17442
1721	43ab70c9412a4a1be5dbd1478f8f7cbecc88c1a80a5305d0e81b25d299954739	17443
1722	61ce2d44a1186dbfd246c1be0099a1a4cfdf1f05fada47186120c896f2430d27	17459
1723	44cde56deebcf6f87b610968e9e4692445cef5c603c2d53d35a39f4a6f8a8137	17469
1724	d5148a7cd358c694b078cf0f7695ce44a0ab237c441c7321b0ee002004e1ae79	17504
1725	ee3527a9b57324339b5b3881a246cfa7d334dd72fb3c88fc74b712d5dbfee0b2	17520
1726	ea1bc824a0eb46cb3cd20f6aba508b0585179ac02d8a36290b74d2025a86ba2f	17525
1727	353c2fac2c94399bf9ed6dcdfdd514392d5451c141a992f1affb89171d4262c7	17526
1728	3ea904d09ce7a687345b21ff179146542ebc061b565b0720fac3b4b9a866fc92	17539
1729	6232e6ed8cb869c2e6c95438ba6b84451b41efbf683273564d4660e9bf4929fe	17543
1730	7a78ca2750fe6f55320b9a141c6a6ab628b14a5422a571931dedbd96213f410f	17550
1731	9b04ad795ca17cc0eaf042c9c72e86f600484b051fa8cf0d08cc5fc1a8f36fbf	17578
1732	500a6f0526945bdcccb47862227c4b02c1e15e98ccad0f054093a450c2733960	17582
1733	2a5ddd84361fdb71980a7dd8cf89ca8d183ca29fa27d55f85c673653f3c32cc1	17594
1734	e6fdd5b9f637b3c2d4afbfe3f697cf9f72880c9477f71f3be3eecd1119157b88	17603
1735	b775bb4b5cc384184914c76c5073acd3c4728f8b904f6cb87c97ac1b12840519	17605
1736	52aba14b2277390f6ff4c98f2b39ca7cd8a46d57b46b6c715fa234594303cdd0	17617
1737	345a4dad0c98122fab770817df2505fc20c17e353a4a2e158df9da0f722b91d9	17640
1738	214000816ec216560ab3b93198e6a35701130770a8dd40c0952f106cfe45d275	17645
1739	512460eb55a3a7ba008aa60788a4f7b99227db901af3e76882cc6dbdfc20554d	17657
1740	7dd1ae33948226a23246ae736370c4b6f76bc6c2f1319235610bd15123fbfbf8	17663
1741	8998de71158c228a7765dfd4b3091936d1303ca614e7e01db798e0b0bcf6d6ca	17670
1742	b0aa83a87f528c07ba4849490d07f711c7faf5bba5c1b54394c2ca1d43c33a16	17683
1743	9b90a03cbfe22130585bd9f748fbbbde65c3c3abe1938f902fb3435b624cca95	17684
1744	7e26d5daf95c2afabc8854e14d015c1efa737ec6f64677ee1e41b49d884cdc16	17691
1745	a3b9899f239eccd0b75ec4efea4a41b838827f84430445b4db5613e93a8f533f	17703
1746	e9ea70103454188b4bb5cdecdd439fe20d97acb458b433e8e3cbb1b769298f0d	17762
1747	1d22a58e5fa299b20b3b36fe8d1df1055b7522c050acc96e11150fe44e6f95a3	17768
1748	1a3b4b84240e4a118a1db296f9622aef4ad13ed22c1c6fe383c24a612fc5c1e1	17782
1749	1d6aa0af73242a467e58f37e56bd42d2f4e4b7d98c06c025c05717a409331b53	17811
1750	92a024b4ccd39ca2b036de469ebe0306c4023baeab7a951e7da08c8f00949a2e	17813
1751	5a588fcde5c41ee4d3634746dd5f03fb8a4e94e5564ae0fda523126ffa0ff1ba	17834
1752	9fa90aa06374498b278de2504a5b745d0cc3015ce84d1401cbab34daa9e5e2bf	17835
1753	b2a4fecb2f2d6633c8ce8e70ec384af09e5402c930545572c1b011cfd011bada	17836
1754	34923b10d990386b7b0a7c6b27c40d8730bcf87fcecdbcf1dbe061a4c699fde0	17840
1755	518feeac7f4067e21a6a8c062ab38239c506ada70989185a833c745d7ea0f25c	17845
1756	cd00a30493a51d8743886fd39f8c0f463ac67ead364b5623fb8d5b972b119061	17850
1757	7dd3fbb155ad7f9d70c066f9f8f544169484df9d8e4390e68c9230ab06ba8a8d	17853
1758	442f0f19c1a16e6d0b5bacc05e37a45f8dbee4ce6254caf29b49414e4d5798e9	17859
1759	941035afaadb4421c4c23711ffc486772e673327c29a86350e6edde602c570e9	17867
1760	cce7771c88b0bfcbfdbce99362ac0897fd5fd35c0027ea494829b3cb69dde782	17871
1761	1340654411ead708ae97a5188e32e3213c9845027ffc6e25d25564dfa6ce3afb	17878
1762	42a7b72b8ddb5580c83f8ea9f36c04d9e85bc540c5d6425962f4fd7965a8c18d	17891
1763	0d56a1a8d5423205ef433a5fed32b522f42573fb9687864923133fec806237af	17898
1764	952125e6daa33c4b46450158aa8d430d274695f80000a55fa2cba0cb254952f1	17905
1765	23f46dcf7fb04b1e03353ac53c1a0d2f4c127f5841d54253c098aa789c5b3231	17923
1766	6b1c6fc7e15cf084b6d6e2434bdb70a8f48d557d81b3d8c8552dccacc9edc41a	17934
1767	d6c9289b460ea07e3c2383111f5bd0145ef2acc4e1e571eb281b54c03a58d4ee	17959
1768	cb7ab2f837ba120f81e2781a35c7489eb54baec120ae4a35c6180383d02809d4	17963
1769	b645c851f03fba41fc96272167b1d3a8ff0114064579c09182cc0bf13a6ac41b	17998
1770	218b98a046eac880cfddd623cc0a9aa93cf96119f0ef3da5ac06b2702435277e	17999
1771	8c7dc6b99e3bc3ae6682408c33fde57ebe06c10ea13ffdb641af45a0c3b6a723	18007
1772	86b775afd9b8ceab414a98c2c8fd66484bdff0602c96a5d2d334504f8043da70	18008
1773	0868b9a739a99d54f8ea52a99d01174737277e0298f550e594e34d3e558a108d	18017
1774	cf100ce4b05225a67badf435b1a28b62aa15fecfd3af4945b9ebe3a54cb44611	18021
1775	05d153486cda41ad5b7cdea667e55a5a0c1a875943988af6be59d1f4c0322837	18033
1776	a32b76ed83bdb86dad90f6dd5c306c1af8f5c7e5fc6b7b1d0c285c9f720b5fba	18048
1777	ccd4cfc19e0fad769c440fb89a6aa514efc54d872fd410637f6d1f2a562b0983	18062
1778	95b40f4464e9da90d70d57c512dbbc3ce92c9e1e43faa3cf2435d127c8f825ce	18068
1779	ed65ae61830bf6cc54de08efb34cd8f978171e9d4efd8932fa4d07f6ee82d3a2	18072
1780	4f4da5e57db25a4f345ccfddf5171e26cb1d8bf1ddb29d1d95cdcf2c9e3fb509	18098
1781	c5a27610303d1d35c00ac7f351b0000b8371ae374d7530ce6e76c574eec7a350	18107
1782	efa359250b924120642ba5f3b5f7bd8845f40828580fb0c00a8a92690a80c3c9	18109
1783	9329554254c290d2695e9f56bcce50db4a147eaac34394c70394ba7d6bafd946	18131
1784	f086cc487fef0b5a028ab635af5db459f0238880764e145d9767a290a82b6dc4	18145
1785	ed77e170898c80a02d8d201b54274edd0ab2b7dc1df8ff7ebcc1146ed29a7d46	18146
1786	8f9d964dae1dcb0408de28e421cf2006005a2e85f0a363480d3ff2dadc635bab	18177
1787	fda070967ad97a5d174a525c243bfeb3eaf4d2333f2d6badf905f12c94b7a217	18181
1788	ce078de0559cfcb849c158e0f2f27d4cc263e60507690ceb37d3ad65ada7b59f	18188
1789	65561ff80139f7bd69d034dd87bde335e9e0464f83482f351f6748b5f09c5d44	18189
1790	a55cf9f3fa3e9fb5e550ea37fc48d76d1c6f4d4776f2c2f55cca34299b943968	18193
1791	24d4dcec7a2cd1175f3cb72329e678495f93ed3bf32d022e3bc8965cbe82cc46	18200
1792	429b05997a766d6a10682a98ac47cd61c25e075b0ba7d93bb45f16bff07bdfad	18204
1793	22b7944c4b7eae7e997d8385e7c14fcc96b13fc081c31abe7d158390753ea28b	18267
1794	07d35f126d763a4eff8384601bd16afd9ce0923f8cf02def11946787a6b7da76	18273
1795	5cce82ebc4e9d06720e1964836b6751e5b27aebfd1f26f3d1d0a6ed2cd540172	18278
1796	7f6f832304618e213a51e02877f7f3fa86a2fe912d9444d5b73f207ff817df44	18281
1797	bd1ee42f2084479dce49ae46186e8cab6df15dcefb43816b2b94d23fefcabae3	18284
1798	44bbeb8a0f9e43b2150798757d5d732609f9eae6c4214ff2a9a151a7a2168b21	18293
1799	bc814f6a3cd016e0e547a7f4cf223c998ba9ae383fec6540d54cf49b527aac84	18302
1800	5f9d70006ea8fc01bf83d86a62906d206606fa2ae3ae3526e5054f3a1a1e3f2e	18304
1801	fdd4055f5a6726ed6e84a6ab08309541d637f496b520899ebd29b457900509d8	18306
1802	df1df13bc7a49dbcf531ca5d85547ffe8f5e3f9b5d6cc5043effb5f04cb257fe	18309
1803	0ba2cc04013d8b2bd3c3b0759d767ba1fc13ff73e5716b30d60104fc52cb4dd9	18314
1804	d9292bd393a0b613b2fde7d094b1c65558602fce33a020663525520cae5a684b	18319
1805	af0cf2d42c29b3029ebe5671c346c5532d0772cb8aa6923e35a362d9c65ce8a7	18321
1806	d88ac80ac0100d915bc4a39bf32902348d72c68b9b9925a4a5bf87ad82497b73	18323
1807	4115ce364a5adb883b1d74364fccc972865120933a970f16523650e85cdce3f3	18352
1808	123cbd915e7bc4a900c312c9176e8d376a17e1266e1f368158870cea3a822395	18372
1809	2aec31211898d34dd4487d1f8931fbfe8ce4cf18d5b200e3a023ba904ac8ec22	18384
1810	32e9d72b05accdd79a2848707f1e40797d06b7f186a504867efcb5d6c1491090	18389
1811	1500ee3d6cb11e15cb23930128dd40c4a18b1234ce84f6bc93c60367e5e5f1a4	18400
1812	397c8eeee5113f684459766493dd26a80af00df9590f6473651cd4846529c773	18423
1813	6bae76904f999a458b2a347df883ba5ecfeefe59f516683f811c1990a5a93833	18430
1814	83019770969f904fe99818966eb3dd1be4fe659a21758906e06eceb928fbc497	18439
1815	d3f63801429effb82774fcdbb6c296a64dcf8c68686eb256de989f30d8b53e99	18448
1816	78b28ba8005c9c1d7422bbe7173108401227ea4274abf4b38fc7d52bd39ea4e4	18457
1817	62612c4481c68c3c63de1467df58b9130dcf784512c1fd9de7aa7820182e5e96	18462
1818	a2316b2c1d42581dbd33ec9fc690ede04d507a6cecd8e0f31cd6b86299a17f4d	18466
1819	083e716e4fa8cba1a6ab940ec83621a6e0f9fc47cb66badb9211e895fd5f0251	18470
1820	68884c137ebc824d274ab23786f00e0dcd1a39d9e40eb935cb9a74333d55ccff	18489
1821	cb81d0d7a297c26f211ea3995e179c1ee34462df0127c42b84511a3072826aa7	18495
1822	b36ad90c3e8ba470bf74593f83883ff28670d9ea80b761868e435e600640ad9c	18504
1823	00a831fcf103d4825f7aeec7e872b52db93b3ab9a4c3fa15a2a48ee3f2bfafad	18512
1824	8311a4f7f1fa15da9cae3e92e51be8c182cfd1e9be8995320d7a8b0a8f3b331d	18527
1825	5401dcdbd8bc1c30650b2b7923c351c8b26953463a45c50cd550738a9d6fe053	18529
1826	165b4fc12d72c6a63bdde1e4df29bd5a10446fae8379d8f864f53190816af386	18531
1827	9ce5ae758c55353b6e0f018b161f8def118877cb87ea128093e37ceeb4b52993	18535
1828	80cdeecf3a9a7a50f40828f0b01d753df4af6c6a971492a026080aaec724e733	18555
1829	6826aa87a8f60c171a6ed2043df18696ac8244859f16b9a2dac371201a4496b9	18559
1830	c77246cfe38c76f807b63c5d6578cbbd3dfe1abd6b17358915aed6d70649402c	18562
1831	de97dfcdef119e3b0893f23457845b8aba5ac99ced799f0273232abfd0bce1b1	18579
1832	d5ae716260a485616dc9fbf1b5eeae4361f6ab302e769109ea11d3f54332557d	18591
1833	7a5dd6f8dbcee06ba89ad853d2c4c55ea66128ffdef8095985669e45d5fee69f	18595
1834	b2ea4a9f41a523896a47d851cb66adaa8edaa72d42b462a9ac99843fe2ba369d	18605
1835	5f91c8fe02ceb7973eec58ebb408ae6da2080e4b2042c452ebf2ac9d9194bf03	18616
1836	8c1db1d0a4cc3613a286789e659ac2465b0e6c0e699f4908e511b3bbb63777ea	18619
1837	b45579d12d43c0f9f93b3f747ec1d408d9ce5775d35205654b869ff9a76af99f	18623
1838	283394ba0f0008427f2af071430931207cee2ec2f93d1ea3f06a9ec790f1ea82	18628
1839	e55852621983d027f443e78e75d36d1a38c11c2ab1d64ef30777e0d984de2e92	18632
1840	60e9f3c22b7c729de00d53d6947d4fe001d30f713befeb98f28b1ae1a8746c29	18637
1841	a9ad647334d5e69f265502c392beb18e33ed0eb2cab56888518acbf80fb08b1d	18638
1842	8f249c9c2bd0573d2a4dc84fa2c97a6dcdac881ed83f0beaaf4b7d360c198b41	18655
1843	cef48823c3c2ff08bc00398dc03c88643bc0815bdb10fe89415bc69d34900b21	18656
1844	a308b2cd22628295c96625294e8d72de7d2e412b4e268e68557e11844efd713c	18660
1845	96dd0b49edd44b1dd29778c042bff31a8ef9ae9506be719858278f0ec3b9a00a	18706
1846	aa5c8ce76f10b0fb8fea9e7027c664c61ec4fa12ca8719f039100a337f339644	18711
1847	e63fa39d36509141c9c029533b518df14c9d11f6541de6a85c2c5d4eb4492a29	18723
1848	7a013502c632ebf7e3d18cc977ac482f2a36e3bbeb95e94d24676e40fbbe998a	18745
1849	b7d96079d9de11bca949f7ba4193b50636867e27bd80b44f8df8ef68b8f2805c	18750
1850	faf3c0a25413df0460f5eb56c01258a6bac86ecadae7f81296771913ead34b86	18754
1851	654b050b4737fafdb3676ad5a7f9bf5f219059e7804508b905f9481100c51d1e	18779
1852	ead3c06db2cd25b9ec9ac55fb4c00460aa77dd20738b1474d2340ae81b5b567a	18782
1853	9eb0680dcc9e2e9c953e80ce9db9829e23b87e5abd73bb13b92bdedb10fe98e1	18785
1854	b798425378853543cfbe5b2d7a91207982bffe089cf2eacc9a4b3a60389c4ffe	18786
1855	71062a9631710c507f01ffcd5f9fcfab53e09a87fe42fac9333a58dc8d49cf88	18788
1856	2691e6a1341aad2372bbce76016b8aec6d133037c2882ca73403b16be755a0db	18796
1857	db34fbc866e88d568dbcc394d82bc3c26d7cf39e5424d7c328d006d08c7db060	18812
1858	f85e89f03337fd6f1a0f42308955d81e9eb0a1a636005f219eff8c7b271d693c	18814
1859	6d1094e563a0f199fe8e900ba198bff8cc67b0c654d268406285234f89fd4841	18821
1860	b449f1af7b191bb93ef87ea29f81fe6d5e2ccd36a55cdfa4e6107b520e1e1a8b	18835
1861	6d9cfe98f9a9e51f182cbed98a5b6f1813252801291a28ce0f24a3a292fe658e	18836
1862	efad8583dd7cbf6364ee7aed5cfd58d5eb5c33dc05610ad5d4bf5bf66f9f37e2	18846
1863	6946a1b26ec8e958bdbebf2b0b059d3d23da86c6c54ae6976d9f5f0ef56543ad	18857
1864	0b5fd1536cd1833db1de37fc14709b14d817d3107435b4ba0043a8a2d87acb91	18874
1865	099eb8915e37059501a54731ff9f88ba555f7c46d6b90067b747dfae8175a635	18875
1866	c9ccc5628dd7789a61db149661e234ec914521fbb22eb3477527a33bf016efcd	18879
1867	a6bb96b5d4f11195349dca142f88f35d632c805ab34834af439d81fcfd180cbd	18881
1868	d85fd70500c9ae85993136b0d2085bb1e670531fea4d77ba6adc977b7045297b	18898
1869	43795959741628e22abeed4f13f4943b149a19754d7d1f8251b8f2f06146acb1	18909
1870	78ff391db44fd0fe5de39e5603c58189d79d3ec114db00a495bf0bda498ff828	18928
1871	4aa664171ba5249f0893d5b4f1fb70fbed2d9a87f6f83df7d4f029483bad7e2a	18929
1872	fa77b68b82423f83720f271cbda4b56cfe5fa64185c8c7f45fb815aad1f56cfc	18930
1873	be792afd28c1c0f3b5d87c3ede4895d60a4a78280b93fcbace2f0cfadf702965	18932
1874	da34a51a9a4d73777a92bb95b6d77ca9eb8abbf30f545948b0839263a162c268	18942
1875	c4a647621726e15b0b43dc8483a96902f5a759346724266bcca90b50f7882917	18943
1876	f3ef36537acfb302fec58d6dc115aa3f449b5e98c62d4ade2d212745cb005ceb	18947
1877	8e50f163fcf50f42a0f1aebd2825c5409198e8a814376559da0b22b9b7f9dd70	18958
1878	b7f7e51a57018aa3325531197057444d257943d112047e078ddd8bc2a2d13686	18975
1879	06a879405c14eb1612cf3268cec2b20c4328e2358ad26514f0f3f191825218ce	18982
1880	c2f41a1c3b91a5bdf947117e1f2cde49f108185c085323ac2971ceabc97bb29d	18987
1881	156ae36df29beaaa479dff013db3cc71107dc9532c2df39b771105867902845c	18990
1882	bd85fd96580ab9ded4e142c08e4b78562e21282537439896378eea0dd47a09a2	18993
1883	4ae303859e1ec43aa1d3682fb8f062897c2c2b851e53fdd213d8925bb36021a6	19013
1884	65efb0a102c2e827814a41ad94caa12d504cf2730b86616a23fd733a8a1ff31a	19023
1885	05e7a86e0646ade98aaf0aca4158486a17cc98666e854b7adec7ded6181aa68b	19026
1886	e53b10f5b0555e6e72b48733d74593ecd5c24992ff97067abed2ddc4967daba0	19035
1887	5d966dedf30a68de17e1d83f10cff8209a11a12fbcf446e14908dd53734a4bf9	19039
1888	e5f6dff4555d63c9a310c814ed029a0f7ce2d5664aec978dfb629bd97a43207b	19051
1889	520d20874f58364b0e06129eb2532b0e391eb619ced22360a54ae59074e77555	19052
1890	b3897b9a78fa4961f2ca47960e916ae444a21cf4ebd1605fae97d1376ee6b4f8	19057
1891	f371ea6c856c3dceec61c383a7dd64198a2d628f8b0a735d17696f25b06a0c8e	19070
1892	0b8e7f584e2d50bd6850caaef61d2c2fb00309fba01d230d7ed0d8ac86483a7e	19071
1893	d935a512ac7716432a207cf77678d4e0f386432679007d632151284354658f8e	19087
1894	d84eeebffa0c77ed43fe51b196ac4ba15225781e528e4a5d95b77e69dd802c24	19092
1895	d03db4351b8c94c9f90c9472b1ddb8f75c8715b82fd9ba528a3f6065d004e16f	19113
1896	eadc4b61e2eea7f1b72e8863dc41189886410ad4a65b17407b2ab9f991f134d6	19120
1897	1463a3ee74dd4ff63df7c457012e9c86f3eb75cf15e8da2ab9672a398e1c5701	19138
1898	51b87d2b43e0adb6d60b38558699ce1100f952253452e9f02bd8e815c5b1e8bd	19159
1899	6c0293c1c5d92671b2ce0d7d1a184dc0f4e6d69aea8b31edb61f6beaaf961695	19160
1900	6d6c81160f9a57ca8eb4a034582ad2b68913e3d19fe1efbd61baa04acb9e1144	19169
1901	c820b80bc9bb69d7e93dc6f3b9c2cd8e836bc68a188394a1a693ea0f498ab8bb	19170
1902	ecab084aa0f08eb5596ace18cbd41d0a92358209d157dc41900a0e4546cc73e0	19173
1903	908d781a91b2e406da3c48b791cf8880d08658aa80c2edbb5ab731e95a40dc09	19194
1904	bb4079cf811de059057c08bf51aaef164b8b99fb2bef071038a2c9ac6ab9ad28	19214
1905	a406b6e76533557c542c70721ace1dc13c4736dc589853150101b9c81d65958f	19230
1906	c221c7ad97d336b281aeade4696db6d279f31e9687b590039150ee450e6782a2	19234
1907	0da144129df5ed101be967f328bc856e46465c3b0529468c1941d8b6c57d294f	19247
1908	c0de92ce7b8ade2a8be3fa1222633f7b233b750f8b23413d290ca9c4e4990825	19262
1909	520669ee4de7dd93398ecf0820963ad8e320bb6c3daec213c46b419367e6c45d	19291
1910	ac279b37e709af7784e06ff5316bd43a381561f50199648c2aa200d18aaa4c1a	19298
1911	f7dfe674e4fdc8679e16f663a6b73db63963a209530870cfad1d5bd28e1cffe6	19300
1912	aaa67795e4dc28f4557b9457c363960887c828e91f07c6d38045962389d327fe	19305
1913	786f478c5cfea9c878304fb457c39d6adee6f6aa11ee0eec0d90f374c7ad72ac	19314
1914	4e896f4b8ca2ffabc556745a72d4761366284f9a8e3d088bdc96429cd65675b2	19321
1915	09d250645b9aecab9856ef788d4315aec0d09f1378df656fd8a658b63f296d1e	19332
1916	7fa8e2eac0f709884257938d5304173abdbb4a69f9eaa343ed5084f9b2a4226a	19337
1917	76b420633a98fb4a4c6f9d74b8cb3dc8bf1d519f034dcd3f5f1b805c5af6edd5	19354
1918	0d7efb68007c2f9f77ffe8159c62bf72dcaa689dfc8b2b481db6280b429aefd4	19366
1919	c52903f06d50765df46d054210a86b0141118a8745f14fc171fd1f904e233c38	19371
1920	78e06e2c3293130d288a9576ef8977e255f4ba73b10e97ca955ba89a46bd6cfe	19374
1921	d89b090e9899a3f13b914b2eba29ea1ef39749a5c218cbcfb6a733843a82a6f9	19379
1922	e5af3065fad4febd14b93bb4cd12453f735dce1e0aa1a2b463da3e8a41e41041	19384
1923	20d63740198e2630bbee803ca74277b39b38ed9e0047bd340b5c353f15c9c0bf	19387
1924	75bde6d441f886c23f430e523cef757e496ed1d81178f0e4941b2dd42862a3d2	19392
1925	de4baecb2e52102e8576f1d700bd9bb442740541961b3b505e882d93b4eeaf8a	19404
1926	f6c036f75fb0336324118d968d992c81ff5ba589e3e80337622dba3f51d1bb01	19412
1927	1c9636bf9c4aea4b3b23d380b17a0f1e454fc4e0b7634c5f794b1e32116d2237	19424
1928	a363d6a6001a5877fcd48b96829e905399c23e839a8f943874d30ed969f9a70a	19425
1929	43a0e5c8aa9e97ac7f4ade912fb3e6ad8f8bec461ada0dd6c00700a09d47ad12	19427
1930	07ad3ca7860767c7c16a374940d6c2d63b9e1502844f0a68628436c5a9e60026	19430
1931	f01fe5d1e251a388736df9f8fce95d8fcfc0824deaab5e224faa35932ea51ecb	19445
1932	7f774869014ea4841356d440f4f96bc787d59c96efa103dbb039b5235008c1ce	19447
1933	1315a6d44bc97b36c05b6261a26605188ceb9521d9533c07d0e8e29bab4c4730	19458
1934	1f9e3ae06944392757cd388bf1a53ea9e678f22f868813d19000edafd1f96dd4	19464
1935	4e78994b59b8d5416e7994269adf7ffffce5e413d8819f9c7d190543a7012f3b	19477
1936	990df38990522d7f7d8341b19c9a9e09a1386efbfd3649fdfeb6f94150dd90c1	19482
1937	297b4b80aabea49ed3e00f9aa2cde44a30baf54b45c915e87074378d92f9b808	19484
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1905	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930352c2268617368223a2261343036623665373635333335353763353432633730373231616365316463313363343733366463353839383533313530313031623963383164363539353866222c22736c6f74223a31393233307d2c22697373756572566b223a2233323463323063376364313835373932353235316664666261343238363838383866663637613335626234333565636231353364376465383562386536396635222c2270726576696f7573426c6f636b223a2262623430373963663831316465303539303537633038626635316161656631363462386239396662326265663037313033386132633961633661623961643238222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e7372686e327075373065646d66707437786434717a327271383864717072656d6e33666c336e336b373472327336717a7a7671736576646634227d
1906	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313833323737227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2236396161636361313364653462303432313330643864306466663066326462303936323063363666626334343037363437363266663332653331333833303632227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2266646436393336633363363934313835613734623438356137303665353763383031343831383736316366666366346533643166613666363734343235343433222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2266646436393336633363363934313835613734623438356137303665353763383031343831383736316366666366346533643166613666363734343535343438222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b226664643639333663336336393431383561373462343835613730366535376338303134383138373631636666636634653364316661366636222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2266646436393336633363363934313835613734623438356137303665353763383031343831383736316366666366346533643166613666363734346434393465222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383136373233227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303637307d7d2c226964223a2231623665386134316331643161323165626531306265333963396631393336376534303133653236306138393635643139373761656437353464336334343136222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223563633035663333383835316262626131643665333935326131343436346132663930323433303637313336386336366636336536376634346130323535376538633633376539323535643537623263636363383836366264373261656461303432646564393766386162363930346332633163356135643366383432343034225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223532613066633532326437626238653834643035373634323131396534376666346364666438613062376163343338303631366565316336313438636630346434383663613232636563353063343230343333323761386436346466623434623831643964666234663137333732326662313665313938303938326261393039225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313833323737227d2c22686561646572223a7b22626c6f636b4e6f223a313930362c2268617368223a2263323231633761643937643333366232383161656164653436393664623664323739663331653936383762353930303339313530656534353065363738326132222c22736c6f74223a31393233347d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2261343036623665373635333335353763353432633730373231616365316463313363343733366463353839383533313530313031623963383164363539353866222c2273697a65223a3633312c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383136373233227d2c227478436f756e74223a312c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1907	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930372c2268617368223a2230646131343431323964663565643130316265393637663332386263383536653436343635633362303532393436386331393431643862366335376432393466222c22736c6f74223a31393234377d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2263323231633761643937643333366232383161656164653436393664623664323739663331653936383762353930303339313530656534353065363738326132222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1908	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930382c2268617368223a2263306465393263653762386164653261386265336661313232323633336637623233336237353066386232333431336432393063613963346534393930383235222c22736c6f74223a31393236327d2c22697373756572566b223a2266373830613831393265633730386533333434636361643466376333643437323632313938396238633536313861373963363935313265666537356433636266222c2270726576696f7573426c6f636b223a2230646131343431323964663565643130316265393637663332386263383536653436343635633362303532393436386331393431643862366335376432393466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316365327070676e30397275757478393479386b657a7a6a716d6b6a6e79746d6771773270747939307a357774637a6876713534713271376b6538227d
1909	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930392c2268617368223a2235323036363965653464653764643933333938656366303832303936336164386533323062623663336461656332313363343662343139333637653663343564222c22736c6f74223a31393239317d2c22697373756572566b223a2263346430353839653864623933656230346438663339353132393765336365333635646639616335306463353533633436633731626333613163643738356662222c2270726576696f7573426c6f636b223a2263306465393263653762386164653261386265336661313232323633336637623233336237353066386232333431336432393063613963346534393930383235222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316832723363636e6a756b3370703272706a7530767261726375786d6164797670666d373579776c3536617877346e636b616a76736e6678686672227d
1910	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313732393831227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2263666334613239323831636137316463663834363365646535393832363533306638666138316438343561326238386561303362613761623061383061343137227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961363436663735363236633635363836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2232227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396136383635366336633666363836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613734363537333734363836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383237303139227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303733317d7d2c226964223a2262663337386134613632383766373561353963373838353165386534353364343266653437326532663364326339653664353465343037343362366261653738222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223236343761356139626432303030373366393863663331373338326331643363646538653535666264366134663236613261616664356439363931346332653830336336383632333961386539633838333436643163633238646335373430346438663561363034363434333130656237336465626534353162313331663030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313732393831227d2c22686561646572223a7b22626c6f636b4e6f223a313931302c2268617368223a2261633237396233376537303961663737383465303666663533313662643433613338313536316635303139393634386332616132303064313861616134633161222c22736c6f74223a31393239387d2c22697373756572566b223a2266323365316366336562636436363961323731306132633238366462343037323066666636636264626434666466396436363262646336633832636439383632222c2270726576696f7573426c6f636b223a2235323036363965653464653764643933333938656366303832303936336164386533323062623663336461656332313363343662343139333637653663343564222c2273697a65223a3339372c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383237303139227d2c227478436f756e74223a312c22767266223a227672665f766b313239336330373263336c7177656c776e64686a78356c72397430617a753961753365683939677a376666736a7970636e71336d73333337736338227d
1911	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931312c2268617368223a2266376466653637346534666463383637396531366636363361366237336462363339363361323039353330383730636661643164356264323865316366666536222c22736c6f74223a31393330307d2c22697373756572566b223a2266323365316366336562636436363961323731306132633238366462343037323066666636636264626434666466396436363262646336633832636439383632222c2270726576696f7573426c6f636b223a2261633237396233376537303961663737383465303666663533313662643433613338313536316635303139393634386332616132303064313861616134633161222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313239336330373263336c7177656c776e64686a78356c72397430617a753961753365683939677a376666736a7970636e71336d73333337736338227d
1912	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931322c2268617368223a2261616136373739356534646332386634353537623934353763333633393630383837633832386539316630376336643338303435393632333839643332376665222c22736c6f74223a31393330357d2c22697373756572566b223a2233323463323063376364313835373932353235316664666261343238363838383866663637613335626234333565636231353364376465383562386536396635222c2270726576696f7573426c6f636b223a2266376466653637346534666463383637396531366636363361366237336462363339363361323039353330383730636661643164356264323865316366666536222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e7372686e327075373065646d66707437786434717a327271383864717072656d6e33666c336e336b373472327336717a7a7671736576646634227d
1913	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931332c2268617368223a2237383666343738633563666561396338373833303466623435376333396436616465653666366161313165653065656330643930663337346337616437326163222c22736c6f74223a31393331347d2c22697373756572566b223a2263346430353839653864623933656230346438663339353132393765336365333635646639616335306463353533633436633731626333613163643738356662222c2270726576696f7573426c6f636b223a2261616136373739356534646332386634353537623934353763333633393630383837633832386539316630376336643338303435393632333839643332376665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316832723363636e6a756b3370703272706a7530767261726375786d6164797670666d373579776c3536617877346e636b616a76736e6678686672227d
1914	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737363839227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2232663166623666393639373265326135346635333462306435386238613762393362343533386335383630316363393061326537636339356337323465623535227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613238333233323332323936383631366536343663363533363338222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383232333131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303735347d7d2c226964223a2235323666656234663761643038343032373732363238363066373362336631346630383933303738376330316332356134346339626266323632306461613966222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223161336465333661313432323336353234646262363561373162653534303639613062323631663737626264306137613663376532343834396338326363646639616462303832623436303565316437336233386466323136333130383937623362666338633230326539363032626466346337626236316434653131633035225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223031613530393764333761333433613933323939666436613032306538653937373531333230646538346335623538363332373836343364326335363262383366353466306362626334636539346235353061663863663832646131373064376233373661346339306638636232623136326436383464303731396531613030225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737363839227d2c22686561646572223a7b22626c6f636b4e6f223a313931342c2268617368223a2234653839366634623863613266666162633535363734356137326434373631333636323834663961386533643038386264633936343239636436353637356232222c22736c6f74223a31393332317d2c22697373756572566b223a2266323365316366336562636436363961323731306132633238366462343037323066666636636264626434666466396436363262646336633832636439383632222c2270726576696f7573426c6f636b223a2237383666343738633563666561396338373833303466623435376333396436616465653666366161313165653065656330643930663337346337616437326163222c2273697a65223a3530342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383232333131227d2c227478436f756e74223a312c22767266223a227672665f766b313239336330373263336c7177656c776e64686a78356c72397430617a753961753365683939677a376666736a7970636e71336d73333337736338227d
1915	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931352c2268617368223a2230396432353036343562396165636162393835366566373838643433313561656330643039663133373864663635366664386136353862363366323936643165222c22736c6f74223a31393333327d2c22697373756572566b223a2266623539643934316264396631303138653333333861386134613363643332613766313962663765356233393630376364636532323664363634653931616634222c2270726576696f7573426c6f636b223a2234653839366634623863613266666162633535363734356137326434373631333636323834663961386533643038386264633936343239636436353637356232222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31686a6d3030373963666a307837726e67757935666c6434393367686a6c32676e3261357235796e38617876373963746365787073306b6e786a36227d
1916	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931362c2268617368223a2237666138653265616330663730393838343235373933386435333034313733616264626234613639663965616133343365643530383466396232613432323661222c22736c6f74223a31393333377d2c22697373756572566b223a2265303236356531633339373037666130613764316133376532333537353230326364316162333739646530613266613364326432313464646538653565316137222c2270726576696f7573426c6f636b223a2230396432353036343562396165636162393835366566373838643433313561656330643039663133373864663635366664386136353862363366323936643165222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137793534736a616c79327836797872687a6d72373870796d346630387868346d376d676737636e7a326a706d7234743963633773756c6134376a227d
1917	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931372c2268617368223a2237366234323036333361393866623461346336663964373462386362336463386266316435313966303334646364336635663162383035633561663665646435222c22736c6f74223a31393335347d2c22697373756572566b223a2263343234323863386439343434313964343132616237303061636363323533623361636233323961663662346232613566383830623765313063323138323538222c2270726576696f7573426c6f636b223a2237666138653265616330663730393838343235373933386435333034313733616264626234613639663965616133343365643530383466396232613432323661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134673832666565716d727279746b6b6836736b337439347561713767353936706c6b783235686c73356a7776356d6532363630716e6136673373227d
1918	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931382c2268617368223a2230643765666236383030376332663966373766666538313539633632626637326463616136383964666338623262343831646236323830623432396165666434222c22736c6f74223a31393336367d2c22697373756572566b223a2265303236356531633339373037666130613764316133376532333537353230326364316162333739646530613266613364326432313464646538653565316137222c2270726576696f7573426c6f636b223a2237366234323036333361393866623461346336663964373462386362336463386266316435313966303334646364336635663162383035633561663665646435222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137793534736a616c79327836797872687a6d72373870796d346630387868346d376d676737636e7a326a706d7234743963633773756c6134376a227d
1919	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313931392c2268617368223a2263353239303366303664353037363564663436643035343231306138366230313431313138613837343566313466633137316664316639303465323333633338222c22736c6f74223a31393337317d2c22697373756572566b223a2265336138656661343730313434333931343531323238666563616561653362383539393437316434396534656635393437633434363436626232666634376235222c2270726576696f7573426c6f636b223a2230643765666236383030376332663966373766666538313539633632626637326463616136383964666338623262343831646236323830623432396165666434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317772396a367a6c347a3368756435397a7378656471326c766a686e7a75736b3864347936726a3577773739636a3438776d6a3971796c617a7764227d
1920	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932302c2268617368223a2237386530366532633332393331333064323838613935373665663839373765323535663462613733623130653937636139353562613839613436626436636665222c22736c6f74223a31393337347d2c22697373756572566b223a2233323463323063376364313835373932353235316664666261343238363838383866663637613335626234333565636231353364376465383562386536396635222c2270726576696f7573426c6f636b223a2263353239303366303664353037363564663436643035343231306138366230313431313138613837343566313466633137316664316639303465323333633338222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e7372686e327075373065646d66707437786434717a327271383864717072656d6e33666c336e336b373472327336717a7a7671736576646634227d
1921	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932312c2268617368223a2264383962303930653938393961336631336239313462326562613239656131656633393734396135633231386362636662366137333338343361383261366639222c22736c6f74223a31393337397d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2237386530366532633332393331333064323838613935373665663839373765323535663462613733623130653937636139353562613839613436626436636665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1922	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c6531222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c222468616e646c6531225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2266396137363664303138666364333236626538323936366438643130333265343830383163636536326663626135666231323430326662363666616166366233222c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323334383435227d2c22696e70757473223a5b7b22696e646578223a352c2274784964223a2234373531633762346530616132646464623763333134393031396439663464393930393534633135626230393530333766356530323431636333386236333039227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b2263626f72223a2264383739396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c22636f6e7374727563746f72223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c226669656c6473223a7b2263626f72223a22396661613434366536313664363534613234373036383631373236643635373237333332343536393664363136373635353833383639373036363733336132663266376136343661333735373664366635613336353637393335363433333462333637353731343235333532356135303532376135333635363235363738363234633332366533313537343135313465343135383333366634633631353736353539373434393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303934613633363836313732363136333734363537323733346636633635373437343635373237333263366537353664363236353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031623334383632363735663639366436313637363535383335363937303636373333613266326635313664353933363538363937313432373233393461346536653735363737353534353237333738333336663633373636623531363536643465346133353639343335323464363936353338333537373731376133393334346136663439373036363730356636393664363136373635353833353639373036363733336132663266353136643537363736613538343337383536353535333537353037393331353736643535353633333661366635303530333137333561346437363561333733313733366633363731373933363433333235613735366235323432343434363730366637323734363136633430343836343635373336393637366536353732353833383639373036363733336132663266376136323332373236383662333237383435333135343735353735373738373434383534376136663335363737343434363934353738343133363534373237363533346236393539366536313736373034353532333334633636343436623666346234373733366636333639363136633733343034363736363536653634366637323430343736343635363636313735366337343030346537333734363136653634363137323634356636393664363136373635353833383639373036363733336132663266376136323332373236383639366234333536373435333561376134623735363933353333366237363537346333383739373435363433373436333761363734353732333934323463366134363632353834323334353435383535373836383438373935333663363137333734356637353730363436313734363535663631363436343732363537333733353833393031653830666433303330626662313766323562666565353064326537316339656365363832393239313536393866393535656136363435656132623762653031323236386139356562616566653533303531363434303564663232636534313139613461333534396262663163646133643463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538323062636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465353337333734363136653634363137323634356636393664363136373635356636383631373336383538323062336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830346237333736363735663736363537323733363936663665343633313265333133353265333034633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034343665373336363737303034353734373236393631366330303439373036363730356636313733373336353734353832336537343836326130396431376139636230333137346136626435666133303562383638343437356334633336303231353931633630366530343435303330333633383331333634383632363735663631373337333635373435383263396264663433376236383331643436643932643064623830663139663162373032313435653966646363343363363236346637613034646330303162633238303534363836353230343637323635363532303466366536356666222c226974656d73223a5b7b2263626f72223a226161343436653631366436353461323437303638363137323664363537323733333234353639366436313637363535383338363937303636373333613266326637613634366133373537366436663561333635363739333536343333346233363735373134323533353235613530353237613533363536323536373836323463333236653331353734313531346534313538333336663463363135373635353937343439366436353634363936313534373937303635346136393664363136373635326636613730363536373432366636373030343936663637356636653735366436323635373230303436373236313732363937343739343536323631373336393633343636633635366536373734363830393461363336383631373236313633373436353732373334663663363537343734363537323733326336653735366436323635373237333531366537353664363537323639363335663664366636343639363636393635373237333430343737363635373237333639366636653031222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665363136643635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223234373036383631373236643635373237333332227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363436613337353736643666356133363536373933353634333334623336373537313432353335323561353035323761353336353632353637383632346333323665333135373431353134653431353833333666346336313537363535393734227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366436353634363936313534373937303635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363532663661373036353637227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236663637227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366636373566366537353664363236353732227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373236313732363937343739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236323631373336393633227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353665363737343638227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2239227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223633363836313732363136333734363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353734373436353732373332633665373536643632363537323733227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236653735366436353732363936333566366436663634363936363639363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223736363537323733363936663665227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d7d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d2c7b2263626f72223a2262333438363236373566363936643631363736353538333536393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666343937303636373035663639366436313637363535383335363937303636373333613266326635313664353736373661353834333738353635353533353735303739333135373664353535363333366136663530353033313733356134643736356133373331373336663336373137393336343333323561373536623532343234343436373036663732373436313663343034383634363537333639363736653635373235383338363937303636373333613266326637613632333237323638366233323738343533313534373535373537373837343438353437613666333536373734343436393435373834313336353437323736353334623639353936653631373637303435353233333463363634343662366634623437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303034653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638363936623433353637343533356137613462373536393335333336623736353734633338373937343536343337343633376136373435373233393432346336613436363235383432333435343538353537383638343837393533366336313733373435663735373036343631373436353566363136343634373236353733373335383339303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364346337363631366336393634363137343635363435663632373935383163346461393635613034396466643135656431656531396662613665323937346130623739666334313664643137393661316639376635653134613639366436313637363535663638363137333638353832306263643538633064636565613937623731376263626530656463343062326536356663323332396134646239636533373136623437623930656235313637646535333733373436313665363436313732363435663639366436313637363535663638363137333638353832306233643036623836303461636339313732396534643130666635663432646134313337636262366239343332393166373033656239373736313637336339383034623733373636373566373636353732373336393666366534363331326533313335326533303463363136373732363536353634356637343635373236643733343035343664363936373732363137343635356637333639363735663732363537313735363937323635363430303434366537333636373730303435373437323639363136633030343937303636373035663631373337333635373435383233653734383632613039643137613963623033313734613662643566613330356238363834343735633463333630323135393163363036653034343530333033363338333133363438363236373566363137333733363537343538326339626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435393336353836393731343237323339346134653665373536373735353435323733373833333666363337363662353136353664346534613335363934333532346436393635333833353737373137613339333434613666227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663531366435373637366135383433373835363535353335373530373933313537366435353536333336613666353035303331373335613464373635613337333137333666333637313739333634333332356137353662353234323434227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036663732373436313663227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236343635373336393637366536353732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836623332373834353331353437353537353737383734343835343761366633353637373434343639343537383431333635343732373635333462363935393665363137363730343535323333346336363434366236663462227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733366636333639363136633733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636353665363436663732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223634363536363631373536633734227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333734363136653634363137323634356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836393662343335363734353335613761346237353639333533333662373635373463333837393734353634333734363337613637343537323339343234633661343636323538343233343534353835353738363834383739227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223663363137333734356637353730363436313734363535663631363436343732363537333733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22303165383066643330333062666231376632356266656535306432653731633965636536383239323931353639386639353565613636343565613262376265303132323638613935656261656665353330353136343430356466323263653431313961346133353439626266316364613364227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636313663363936343631373436353634356636323739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262636435386330646365656139376237313762636265306564633430623265363566633233323961346462396365333731366234376239306562353136376465227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733373436313665363436313732363435663639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2262336430366238363034616363393137323965346431306666356634326461343133376362623662393433323931663730336562393737363136373363393830227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333736363735663736363537323733363936663665227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22333132653331333532653330227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22363136373732363536353634356637343635373236643733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236643639363737323631373436353566373336393637356637323635373137353639373236353634227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665373336363737227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237343732363936313663227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036363730356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2265373438363261303964313761396362303331373461366264356661333035623836383434373563346333363032313539316336303665303434353033303336333833313336227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236323637356636313733373336353734227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2239626466343337623638333164343664393264306462383066313966316237303231343565396664636334336336323634663761303464633030316263323830353436383635323034363732363536353230346636653635227d5d5d7d7d5d7d7d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303036343362303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303064653134303638363136653634366336353332222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613638363136653634366336353331222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223130303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313437323430323539373238227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303831397d7d2c226964223a2234626234656337633832633132383064376338613964363034643764643635353531333531386534613565616437636565343136343662343534323365633039222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c223466376164643735326437383231626262616163666233303934346434633730383565346538316166633862396633666336366531613063346231313262363265626638313463343838313562643962336536643264643938323662666633316435396238646565376433346434613136663165323634396262306231323062225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323334383435227d2c22686561646572223a7b22626c6f636b4e6f223a313932322c2268617368223a2265356166333036356661643466656264313462393362623463643132343533663733356463653165306161316132623436336461336538613431653431303431222c22736c6f74223a31393338347d2c22697373756572566b223a2266623539643934316264396631303138653333333861386134613363643332613766313962663765356233393630376364636532323664363634653931616634222c2270726576696f7573426c6f636b223a2264383962303930653938393961336631336239313462326562613239656131656633393734396135633231386362636662366137333338343361383261366639222c2273697a65223a313730342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313437323530323539373238227d2c227478436f756e74223a312c22767266223a227672665f766b31686a6d3030373963666a307837726e67757935666c6434393367686a6c32676e3261357235796e38617876373963746365787073306b6e786a36227d
1923	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932332c2268617368223a2232306436333734303139386532363330626265653830336361373432373762333962333865643965303034376264333430623563333533663135633963306266222c22736c6f74223a31393338377d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2265356166333036356661643466656264313462393362623463643132343533663733356463653165306161316132623436336461336538613431653431303431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1924	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932342c2268617368223a2237356264653664343431663838366332336634333065353233636566373537653439366564316438313137386630653439343162326464343238363261336432222c22736c6f74223a31393339327d2c22697373756572566b223a2265303236356531633339373037666130613764316133376532333537353230326364316162333739646530613266613364326432313464646538653565316137222c2270726576696f7573426c6f636b223a2232306436333734303139386532363330626265653830336361373432373762333962333865643965303034376264333430623563333533663135633963306266222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137793534736a616c79327836797872687a6d72373870796d346630387868346d376d676737636e7a326a706d7234743963633773756c6134376a227d
1925	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932352c2268617368223a2264653462616563623265353231303265383537366631643730306264396262343432373430353431393631623362353035653838326439336234656561663861222c22736c6f74223a31393430347d2c22697373756572566b223a2266373830613831393265633730386533333434636361643466376333643437323632313938396238633536313861373963363935313265666537356433636266222c2270726576696f7573426c6f636b223a2237356264653664343431663838366332336634333065353233636566373537653439366564316438313137386630653439343162326464343238363261336432222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316365327070676e30397275757478393479386b657a7a6a716d6b6a6e79746d6771773270747939307a357774637a6876713534713271376b6538227d
1926	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c222468616e646c225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2265323230393864366565623066316364373339656434343165303835666138383936633764323830626664636461393534653063633261393734353935393638222c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323232313239227d2c22696e70757473223a5b7b22696e646578223a382c2274784964223a2234373531633762346530616132646464623763333134393031396439663464393930393534633135626230393530333766356530323431636333386236333039227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961303030646531343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b2263626f72223a2264383739396661613434366536313664363534353234363836653634366334353639366436313637363535383338363937303636373333613266326637613632333237323638356136613463346135343538333836313561366434613761343234323438363233363662373533353434366436653636353036373464343733373561366437333632373136323331373336363733363335363336353937303439366436353634363936313534373937303635346136393664363136373635326636613730363536373432366636373030343936663637356636653735366436323635373230303436373236313732363937343739343636333666366436643666366534363663363536653637373436383034346136333638363137323631363337343635373237333437366336353734373436353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031616634653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638356136613463346135343538333836313561366434613761343234323438363233363662373533353434366436653636353036373464343733373561366437333632373136323331373336363733363335363336353937303436373036663732373436313663343034383634363537333639363736653635373234303437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303035333663363137333734356637353730363436313734363535663631363436343732363537333733353833393030663534316630383232643437393465366431646463336330643565393332353835626663636532643836396231633265653035623164633763333762616365363462353762353061303434626261666135393338313161366634396339643864386330623138373933326532646634303463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538343033323634363436353337363136333633333036323337363533323333333933313632363633333332363133333634363533373634333536363331333736333335363336353636333233313633333333363632363433323333333536343633363636333634333733383337363436333636333433393635363636313336333333393533373337343631366536343631373236343566363936643631363736353566363836313733363835383430333236343634363533373631363336333330363233373635333233333339333136323636333333323631333336343635333736343335363633313337363333353633363536363332333136333333333636323634333233333335363436333636363336343337333833373634363336363334333936353636363133363333333934623733373636373566373636353732373336393666366534353332326533303265333134633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034353734373236393631366330303434366537333636373730306666222c22636f6e7374727563746f72223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c226669656c6473223a7b2263626f72223a22396661613434366536313664363534353234363836653634366334353639366436313637363535383338363937303636373333613266326637613632333237323638356136613463346135343538333836313561366434613761343234323438363233363662373533353434366436653636353036373464343733373561366437333632373136323331373336363733363335363336353937303439366436353634363936313534373937303635346136393664363136373635326636613730363536373432366636373030343936663637356636653735366436323635373230303436373236313732363937343739343636333666366436643666366534363663363536653637373436383034346136333638363137323631363337343635373237333437366336353734373436353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031616634653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638356136613463346135343538333836313561366434613761343234323438363233363662373533353434366436653636353036373464343733373561366437333632373136323331373336363733363335363336353937303436373036663732373436313663343034383634363537333639363736653635373234303437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303035333663363137333734356637353730363436313734363535663631363436343732363537333733353833393030663534316630383232643437393465366431646463336330643565393332353835626663636532643836396231633265653035623164633763333762616365363462353762353061303434626261666135393338313161366634396339643864386330623138373933326532646634303463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538343033323634363436353337363136333633333036323337363533323333333933313632363633333332363133333634363533373634333536363331333736333335363336353636333233313633333333363632363433323333333536343633363636333634333733383337363436333636333433393635363636313336333333393533373337343631366536343631373236343566363936643631363736353566363836313733363835383430333236343634363533373631363336333330363233373635333233333339333136323636333333323631333336343635333736343335363633313337363333353633363536363332333136333333333636323634333233333335363436333636363336343337333833373634363336363334333936353636363133363333333934623733373636373566373636353732373336393666366534353332326533303265333134633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034353734373236393631366330303434366537333636373730306666222c226974656d73223a5b7b2263626f72223a226161343436653631366436353435323436383665363436633435363936643631363736353538333836393730363637333361326632663761363233323732363835613661346334613534353833383631356136643461376134323432343836323336366237353335343436643665363635303637346434373337356136643733363237313632333137333636373336333536333635393730343936643635363436393631353437393730363534613639366436313637363532663661373036353637343236663637303034393666363735663665373536643632363537323030343637323631373236393734373934363633366636643664366636653436366336353665363737343638303434613633363836313732363136333734363537323733343736633635373437343635373237333531366537353664363537323639363335663664366636343639363636393635373237333430343737363635373237333639366636653031222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665363136643635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2232343638366536343663227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363835613661346334613534353833383631356136643461376134323432343836323336366237353335343436643665363635303637346434373337356136643733363237313632333137333636373336333536333635393730227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366436353634363936313534373937303635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363532663661373036353637227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236663637227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366636373566366537353664363236353732227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373236313732363937343739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22363336663664366436663665227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353665363737343638227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2234227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223633363836313732363136333734363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223663363537343734363537323733227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236653735366436353732363936333566366436663634363936363639363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223736363537323733363936663665227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d7d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d2c7b2263626f72223a2261663465373337343631366536343631373236343566363936643631363736353538333836393730363637333361326632663761363233323732363835613661346334613534353833383631356136643461376134323432343836323336366237353335343436643665363635303637346434373337356136643733363237313632333137333636373336333536333635393730343637303666373237343631366334303438363436353733363936373665363537323430343737333666363336393631366337333430343637363635366536343666373234303437363436353636363137353663373430303533366336313733373435663735373036343631373436353566363136343634373236353733373335383339303066353431663038323264343739346536643164646333633064356539333235383562666363653264383639623163326565303562316463376333376261636536346235376235306130343462626166613539333831316136663439633964386438633062313837393332653264663430346337363631366336393634363137343635363435663632373935383163346461393635613034396466643135656431656531396662613665323937346130623739666334313664643137393661316639376635653134613639366436313637363535663638363137333638353834303332363436343635333736313633363333303632333736353332333333393331363236363333333236313333363436353337363433353636333133373633333536333635363633323331363333333336363236343332333333353634363336363633363433373338333736343633363633343339363536363631333633333339353337333734363136653634363137323634356636393664363136373635356636383631373336383538343033323634363436353337363136333633333036323337363533323333333933313632363633333332363133333634363533373634333536363331333736333335363336353636333233313633333333363632363433323333333536343633363636333634333733383337363436333636333433393635363636313336333333393462373337363637356637363635373237333639366636653435333232653330326533313463363136373732363536353634356637343635373236643733343035343664363936373732363137343635356637333639363735663732363537313735363937323635363430303435373437323639363136633030343436653733363637373030222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333734363136653634363137323634356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363835613661346334613534353833383631356136643461376134323432343836323336366237353335343436643665363635303637346434373337356136643733363237313632333137333636373336333536333635393730227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036663732373436313663227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236343635373336393637366536353732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733366636333639363136633733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636353665363436663732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223634363536363631373536633734227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223663363137333734356637353730363436313734363535663631363436343732363537333733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22303066353431663038323264343739346536643164646333633064356539333235383562666363653264383639623163326565303562316463376333376261636536346235376235306130343462626166613539333831316136663439633964386438633062313837393332653264663430227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636313663363936343631373436353634356636323739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223332363436343635333736313633363333303632333736353332333333393331363236363333333236313333363436353337363433353636333133373633333536333635363633323331363333333336363236343332333333353634363336363633363433373338333736343633363633343339363536363631333633333339227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733373436313665363436313732363435663639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223332363436343635333736313633363333303632333736353332333333393331363236363333333236313333363436353337363433353636333133373633333536333635363633323331363333333336363236343332333333353634363336363633363433373338333736343633363633343339363536363631333633333339227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333736363735663736363537323733363936663665227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2233323265333032653331227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22363136373732363536353634356637343635373236643733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236643639363737323631373436353566373336393637356637323635373137353639373236353634227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237343732363936313663227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665373336363737227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d7d5d7d7d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961303030646531343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223130303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223336383032343031353134227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303834347d7d2c226964223a2234636564316462333531653638643862646236306164663832646339323734333830383063656131383337333761616464613532633137323438353832663962222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c223236323433366437383438626139643734613935663166663666396639353037386261373466656532663264323530356533656539363837373061383133333939383865386261343562363339653530613038626365663234303066633838366135626234313664656636333831383264646539303538636163393133363062225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323232313239227d2c22686561646572223a7b22626c6f636b4e6f223a313932362c2268617368223a2266366330333666373566623033333633323431313864393638643939326338316666356261353839653365383033333736323264626133663531643162623031222c22736c6f74223a31393431327d2c22697373756572566b223a2263346430353839653864623933656230346438663339353132393765336365333635646639616335306463353533633436633731626333613163643738356662222c2270726576696f7573426c6f636b223a2264653462616563623265353231303265383537366631643730306264396262343432373430353431393631623362353035653838326439336234656561663861222c2273697a65223a313431352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223336383132343031353134227d2c227478436f756e74223a312c22767266223a227672665f766b316832723363636e6a756b3370703272706a7530767261726375786d6164797670666d373579776c3536617877346e636b616a76736e6678686672227d
1927	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932372c2268617368223a2231633936333662663963346165613462336232336433383062313761306631653435346663346530623736333463356637393462316533323131366432323337222c22736c6f74223a31393432347d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2266366330333666373566623033333633323431313864393638643939326338316666356261353839653365383033333736323264626133663531643162623031222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1928	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932382c2268617368223a2261333633643661363030316135383737666364343862393638323965393035333939633233653833396138663934333837346433306564393639663961373061222c22736c6f74223a31393432357d2c22697373756572566b223a2265336138656661343730313434333931343531323238666563616561653362383539393437316434396534656635393437633434363436626232666634376235222c2270726576696f7573426c6f636b223a2231633936333662663963346165613462336232336433383062313761306631653435346663346530623736333463356637393462316533323131366432323337222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317772396a367a6c347a3368756435397a7378656471326c766a686e7a75736b3864347936726a3577773739636a3438776d6a3971796c617a7764227d
1929	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313932392c2268617368223a2234336130653563386161396539376163376634616465393132666233653661643866386265633436316164613064643663303037303061303964343761643132222c22736c6f74223a31393432377d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2261333633643661363030316135383737666364343862393638323965393035333939633233653833396138663934333837346433306564393639663961373061222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1930	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b227375624068616e646c222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c22247375624068616e646c225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2261663730323739323264313930656162663536313937386537656430386562353636663432646462613230343532323437386663336463303239373636353966222c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323232393635227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2234636564316462333531653638643862646236306164663832646339323734333830383063656131383337333761616464613532633137323438353832663962227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613030306465313430373337353632343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c33746b63393734737232336a6d6c7a6771357a646134677476386b39637933383735367239793371676d6b71716a7a36616137222c22646174756d223a7b2263626f72223a2264383739396661613434366536313664363534393234373337353632343036383665363436633435363936643631363736353538333836393730363637333361326632663761363233323732363836323432366537613665346534383731363734383632346135383738366437313539366134373731343636333337373934373331346134343465363734313636346433353334373236343732343535303332373736333636343936643635363436393631353437393730363534613639366436313637363532663661373036353637343236663637303034393666363735663665373536643632363537323030343637323631373236393734373934353632363137333639363334363663363536653637373436383038346136333638363137323631363337343635373237333437366336353734373436353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031616634653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638363234323665376136653465343837313637343836323461353837383664373135393661343737313436363333373739343733313461343434653637343136363464333533343732363437323435353033323737363336363436373036663732373436313663343034383634363537333639363736653635373234303437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303035333663363137333734356637353730363436313734363535663631363436343732363537333733353833393030663534316630383232643437393465366431646463336330643565393332353835626663636532643836396231633265653035623164633763333762616365363462353762353061303434626261666135393338313161366634396339643864386330623138373933326532646634303463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538343033343333333833313337333336323631333633303333333933313335333436363634363233323634333133373338333736333336333736353633333633363333333836333339333436323634333333313633333833353333363633303634333936343335363136363334333336353632363436323331333836343632333933343533373337343631366536343631373236343566363936643631363736353566363836313733363835383430333433333338333133373333363236313336333033333339333133353334363636343632333236343331333733383337363333363337363536333336333633333338363333393334363236343333333136333338333533333636333036343339363433353631363633343333363536323634363233313338363436323339333434623733373636373566373636353732373336393666366534353332326533303265333134633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034353734373236393631366330303434366537333636373730306666222c22636f6e7374727563746f72223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c226669656c6473223a7b2263626f72223a22396661613434366536313664363534393234373337353632343036383665363436633435363936643631363736353538333836393730363637333361326632663761363233323732363836323432366537613665346534383731363734383632346135383738366437313539366134373731343636333337373934373331346134343465363734313636346433353334373236343732343535303332373736333636343936643635363436393631353437393730363534613639366436313637363532663661373036353637343236663637303034393666363735663665373536643632363537323030343637323631373236393734373934353632363137333639363334363663363536653637373436383038346136333638363137323631363337343635373237333437366336353734373436353732373335313665373536643635373236393633356636643666363436393636363936353732373334303437373636353732373336393666366530313031616634653733373436313665363436313732363435663639366436313637363535383338363937303636373333613266326637613632333237323638363234323665376136653465343837313637343836323461353837383664373135393661343737313436363333373739343733313461343434653637343136363464333533343732363437323435353033323737363336363436373036663732373436313663343034383634363537333639363736653635373234303437373336663633363936313663373334303436373636353665363436663732343034373634363536363631373536633734303035333663363137333734356637353730363436313734363535663631363436343732363537333733353833393030663534316630383232643437393465366431646463336330643565393332353835626663636532643836396231633265653035623164633763333762616365363462353762353061303434626261666135393338313161366634396339643864386330623138373933326532646634303463373636313663363936343631373436353634356636323739353831633464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531346136393664363136373635356636383631373336383538343033343333333833313337333336323631333633303333333933313335333436363634363233323634333133373338333736333336333736353633333633363333333836333339333436323634333333313633333833353333363633303634333936343335363136363334333336353632363436323331333836343632333933343533373337343631366536343631373236343566363936643631363736353566363836313733363835383430333433333338333133373333363236313336333033333339333133353334363636343632333236343331333733383337363333363337363536333336333633333338363333393334363236343333333136333338333533333636333036343339363433353631363633343333363536323634363233313338363436323339333434623733373636373566373636353732373336393666366534353332326533303265333134633631363737323635363536343566373436353732366437333430353436643639363737323631373436353566373336393637356637323635373137353639373236353634303034353734373236393631366330303434366537333636373730306666222c226974656d73223a5b7b2263626f72223a226161343436653631366436353439323437333735363234303638366536343663343536393664363136373635353833383639373036363733336132663266376136323332373236383632343236653761366534653438373136373438363234613538373836643731353936613437373134363633333737393437333134613434346536373431363634643335333437323634373234353530333237373633363634393664363536343639363135343739373036353461363936643631363736353266366137303635363734323666363730303439366636373566366537353664363236353732303034363732363137323639373437393435363236313733363936333436366336353665363737343638303834613633363836313732363136333734363537323733343736633635373437343635373237333531366537353664363537323639363335663664366636343639363636393635373237333430343737363635373237333639366636653031222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665363136643635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22323437333735363234303638366536343663227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836323432366537613665346534383731363734383632346135383738366437313539366134373731343636333337373934373331346134343465363734313636346433353334373236343732343535303332373736333636227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366436353634363936313534373937303635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363532663661373036353637227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236663637227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366636373566366537353664363236353732227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373236313732363937343739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236323631373336393633227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22366336353665363737343638227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2238227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223633363836313732363136333734363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223663363537343734363537323733227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236653735366436353732363936333566366436663634363936363639363537323733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223736363537323733363936663665227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d7d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d2c7b2263626f72223a2261663465373337343631366536343631373236343566363936643631363736353538333836393730363637333361326632663761363233323732363836323432366537613665346534383731363734383632346135383738366437313539366134373731343636333337373934373331346134343465363734313636346433353334373236343732343535303332373736333636343637303666373237343631366334303438363436353733363936373665363537323430343737333666363336393631366337333430343637363635366536343666373234303437363436353636363137353663373430303533366336313733373435663735373036343631373436353566363136343634373236353733373335383339303066353431663038323264343739346536643164646333633064356539333235383562666363653264383639623163326565303562316463376333376261636536346235376235306130343462626166613539333831316136663439633964386438633062313837393332653264663430346337363631366336393634363137343635363435663632373935383163346461393635613034396466643135656431656531396662613665323937346130623739666334313664643137393661316639376635653134613639366436313637363535663638363137333638353834303334333333383331333733333632363133363330333333393331333533343636363436323332363433313337333833373633333633373635363333363336333333383633333933343632363433333331363333383335333336363330363433393634333536313636333433333635363236343632333133383634363233393334353337333734363136653634363137323634356636393664363136373635356636383631373336383538343033343333333833313337333336323631333633303333333933313335333436363634363233323634333133373338333736333336333736353633333633363333333836333339333436323634333333313633333833353333363633303634333936343335363136363334333336353632363436323331333836343632333933343462373337363637356637363635373237333639366636653435333232653330326533313463363136373732363536353634356637343635373236643733343035343664363936373732363137343635356637333639363735663732363537313735363937323635363430303435373437323639363136633030343436653733363637373030222c2264617461223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333734363136653634363137323634356636393664363136373635227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2236393730363637333361326632663761363233323732363836323432366537613665346534383731363734383632346135383738366437313539366134373731343636333337373934373331346134343465363734313636346433353334373236343732343535303332373736333636227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373036663732373436313663227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236343635373336393637366536353732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733366636333639363136633733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636353665363436663732227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223634363536363631373536633734227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223663363137333734356637353730363436313734363535663631363436343732363537333733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22303066353431663038323264343739346536643164646333633064356539333235383562666363653264383639623163326565303562316463376333376261636536346235376235306130343462626166613539333831316136663439633964386438633062313837393332653264663430227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22373636313663363936343631373436353634356636323739227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223464613936356130343964666431356564316565313966626136653239373461306237396663343136646431373936613166393766356531227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223334333333383331333733333632363133363330333333393331333533343636363436323332363433313337333833373633333633373635363333363336333333383633333933343632363433333331363333383335333336363330363433393634333536313636333433333635363236343632333133383634363233393334227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223733373436313665363436313732363435663639366436313637363535663638363137333638227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a223334333333383331333733333632363133363330333333393331333533343636363436323332363433313337333833373633333633373635363333363336333333383633333933343632363433333331363333383335333336363330363433393634333536313636333433333635363236343632333133383634363233393334227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237333736363735663736363537323733363936663665227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a2233323265333032653331227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a22363136373732363536353634356637343635373236643733227d2c7b225f5f74797065223a22427566666572222c2276616c7565223a22227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2236643639363737323631373436353566373336393637356637323635373137353639373236353634227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a2237343732363936313663227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b7b225f5f74797065223a22427566666572222c2276616c7565223a223665373336363737227d2c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d7d5d7d7d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613030306465313430373337353632343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223130303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223336373932313738353439227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303836377d7d2c226964223a2230333462376234633664366631393165636531386131623961383865333139616533643637323264353433376565306261383166303633653363616538616330222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c223234303038333538363534303236666133626137616162346533643330663636313333646461343533633233656434323438663439626661336538363362383031373039633561373165643734346336363736613936643236336564303861366161346462333432376365356433613166656436633461396531613332623037225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22323232393635227d2c22686561646572223a7b22626c6f636b4e6f223a313933302c2268617368223a2230376164336361373836303736376337633136613337343934306436633264363362396531353032383434663061363836323834333663356139653630303236222c22736c6f74223a31393433307d2c22697373756572566b223a2266373830613831393265633730386533333434636361643466376333643437323632313938396238633536313861373963363935313265666537356433636266222c2270726576696f7573426c6f636b223a2234336130653563386161396539376163376634616465393132666233653661643866386265633436316164613064643663303037303061303964343761643132222c2273697a65223a313433342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223336383032313738353439227d2c227478436f756e74223a312c22767266223a227672665f766b316365327070676e30397275757478393479386b657a7a6a716d6b6a6e79746d6771773270747939307a357774637a6876713534713271376b6538227d
1931	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933312c2268617368223a2266303166653564316532353161333838373336646639663866636539356438666366633038323464656161623565323234666161333539333265613531656362222c22736c6f74223a31393434357d2c22697373756572566b223a2265336138656661343730313434333931343531323238666563616561653362383539393437316434396534656635393437633434363436626232666634376235222c2270726576696f7573426c6f636b223a2230376164336361373836303736376337633136613337343934306436633264363362396531353032383434663061363836323834333663356139653630303236222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317772396a367a6c347a3368756435397a7378656471326c766a686e7a75736b3864347936726a3577773739636a3438776d6a3971796c617a7764227d
1932	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933322c2268617368223a2237663737343836393031346561343834313335366434343066346639366263373837643539633936656661313033646262303339623532333530303863316365222c22736c6f74223a31393434377d2c22697373756572566b223a2265303236356531633339373037666130613764316133376532333537353230326364316162333739646530613266613364326432313464646538653565316137222c2270726576696f7573426c6f636b223a2266303166653564316532353161333838373336646639663866636539356438666366633038323464656161623565323234666161333539333265613531656362222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137793534736a616c79327836797872687a6d72373870796d346630387868346d376d676737636e7a326a706d7234743963633773756c6134376a227d
1933	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933332c2268617368223a2231333135613664343462633937623336633035623632363161323636303531383863656239353231643935333363303764306538653239626162346334373330222c22736c6f74223a31393435387d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2237663737343836393031346561343834313335366434343066346639366263373837643539633936656661313033646262303339623532333530303863316365222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1934	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b227669727475616c4068616e646c222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c22247669727475616c4068616e646c225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2231323461306263656630393965636233363831303065336632326339383664363435313066623435373637376666313237396537336166626233663633353766222c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313931313937227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2234373531633762346530616132646464623763333134393031396439663464393930393534633135626230393530333766356530323431636333386236333039227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303030303030303736363937323734373536313663343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303030303030303736363937323734373536313663343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234383038383033227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303839387d7d2c226964223a2231653333363464316138343036393838656333333266643839383337386466323664316238323462313437623361633233323836626333633837633437633965222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c223035616462626661636433636561383337396665613933396333336635313830376564653065636363353138393562356162343030366330616363316364623037613164653936643234613938643662346136353136376135323838636231313331623936306239623635393330623233333961346137626637653566323066225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313931313937227d2c22686561646572223a7b22626c6f636b4e6f223a313933342c2268617368223a2231663965336165303639343433393237353763643338386266316135336561396536373866323266383638383133643139303030656461666431663936646434222c22736c6f74223a31393436347d2c22697373756572566b223a2263343234323863386439343434313964343132616237303061636363323533623361636233323961663662346232613566383830623765313063323138323538222c2270726576696f7573426c6f636b223a2231333135613664343462633937623336633035623632363161323636303531383863656239353231643935333363303764306538653239626162346334373330222c2273697a65223a3731322c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234383038383033227d2c227478436f756e74223a312c22767266223a227672665f766b3134673832666565716d727279746b6b6836736b337439347561713767353936706c6b783235686c73356a7776356d6532363630716e6136673373227d
1935	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933352c2268617368223a2234653738393934623539623864353431366537393934323639616466376666666663653565343133643838313966396337643139303534336137303132663362222c22736c6f74223a31393437377d2c22697373756572566b223a2265336138656661343730313434333931343531323238666563616561653362383539393437316434396534656635393437633434363436626232666634376235222c2270726576696f7573426c6f636b223a2231663965336165303639343433393237353763643338386266316135336561396536373866323266383638383133643139303030656461666431663936646434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317772396a367a6c347a3368756435397a7378656471326c766a686e7a75736b3864347936726a3577773739636a3438776d6a3971796c617a7764227d
1936	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933362c2268617368223a2239393064663338393930353232643766376438333431623139633961396530396131333836656662666433363439666466656236663934313530646439306331222c22736c6f74223a31393438327d2c22697373756572566b223a2265303236356531633339373037666130613764316133376532333537353230326364316162333739646530613266613364326432313464646538653565316137222c2270726576696f7573426c6f636b223a2234653738393934623539623864353431366537393934323639616466376666666663653565343133643838313966396337643139303534336137303132663362222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137793534736a616c79327836797872687a6d72373870796d346630387868346d376d676737636e7a326a706d7234743963633773756c6134376a227d
1937	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313933372c2268617368223a2232393762346238306161626561343965643365303066396161326364653434613330626166353462343563393135653837303734333738643932663962383038222c22736c6f74223a31393438347d2c22697373756572566b223a2233323463323063376364313835373932353235316664666261343238363838383866663637613335626234333565636231353364376465383562386536396635222c2270726576696f7573426c6f636b223a2239393064663338393930353232643766376438333431623139633961396530396131333836656662666433363439666466656236663934313530646439306331222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e7372686e327075373065646d66707437786434717a327271383864717072656d6e33666c336e336b373472327336717a7a7671736576646634227d
1899	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839392c2268617368223a2236633032393363316335643932363731623263653064376431613138346463306634653664363961656138623331656462363166366265616166393631363935222c22736c6f74223a31393136307d2c22697373756572566b223a2266623539643934316264396631303138653333333861386134613363643332613766313962663765356233393630376364636532323664363634653931616634222c2270726576696f7573426c6f636b223a2235316238376432623433653061646236643630623338353538363939636531313030663935323235333435326539663032626438653831356335623165386264222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31686a6d3030373963666a307837726e67757935666c6434393367686a6c32676e3261357235796e38617876373963746365787073306b6e786a36227d
1900	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930302c2268617368223a2236643663383131363066396135376361386562346130333435383261643262363839313365336431396665316566626436316261613034616362396531313434222c22736c6f74223a31393136397d2c22697373756572566b223a2263346430353839653864623933656230346438663339353132393765336365333635646639616335306463353533633436633731626333613163643738356662222c2270726576696f7573426c6f636b223a2236633032393363316335643932363731623263653064376431613138346463306634653664363961656138623331656462363166366265616166393631363935222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316832723363636e6a756b3370703272706a7530767261726375786d6164797670666d373579776c3536617877346e636b616a76736e6678686672227d
1901	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930312c2268617368223a2263383230623830626339626236396437653933646336663362396332636438653833366263363861313838333934613161363933656130663439386162386262222c22736c6f74223a31393137307d2c22697373756572566b223a2263343234323863386439343434313964343132616237303061636363323533623361636233323961663662346232613566383830623765313063323138323538222c2270726576696f7573426c6f636b223a2236643663383131363066396135376361386562346130333435383261643262363839313365336431396665316566626436316261613034616362396531313434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134673832666565716d727279746b6b6836736b337439347561713767353936706c6b783235686c73356a7776356d6532363630716e6136673373227d
1902	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2231663730346339313337373664613032613564383862313861616234626136323935643464643430336362626365656638366137353130393531303334626564227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393930343734333639227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303631307d7d2c226964223a2238353135316432393964636363643033396632353963663530326331623239656166616265346662353563623861386637326530356333623966653061333163222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226534633761656531666232613239363237616436666237323566623562326530613038323439653632623131306231343833333235343065626465393431616331633736376163623236653838376230386434303561323964623734376532336333323334653433393439393063613764333165636130346561616330333061225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226265373930393366616430336463373461313631323764653937376634643632633438653836633039383161303266313965363361643530643331656237316161316365623436333733376238353737383461316332326463363964376430363639306165326164663863623237326161653864656437643863646533373064225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22686561646572223a7b22626c6f636b4e6f223a313930322c2268617368223a2265636162303834616130663038656235353936616365313863626434316430613932333538323039643135376463343139303061306534353436636337336530222c22736c6f74223a31393137337d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2263383230623830626339626236396437653933646336663362396332636438653833366263363861313838333934613161363933656130663439386162386262222c2273697a65223a3436302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933343734333639227d2c227478436f756e74223a312c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1903	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930332c2268617368223a2239303864373831613931623265343036646133633438623739316366383838306430383635386161383063326564626235616237333165393561343064633039222c22736c6f74223a31393139347d2c22697373756572566b223a2266323365316366336562636436363961323731306132633238366462343037323066666636636264626434666466396436363262646336633832636439383632222c2270726576696f7573426c6f636b223a2265636162303834616130663038656235353936616365313863626434316430613932333538323039643135376463343139303061306534353436636337336530222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313239336330373263336c7177656c776e64686a78356c72397430617a753961753365683939677a376666736a7970636e71336d73333337736338227d
1904	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313930342c2268617368223a2262623430373963663831316465303539303537633038626635316161656631363462386239396662326265663037313033386132633961633661623961643238222c22736c6f74223a31393231347d2c22697373756572566b223a2263343234323863386439343434313964343132616237303061636363323533623361636233323961663662346232613566383830623765313063323138323538222c2270726576696f7573426c6f636b223a2239303864373831613931623265343036646133633438623739316366383838306430383635386161383063326564626235616237333165393561343064633039222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134673832666565716d727279746b6b6836736b337439347561713767353936706c6b783235686c73356a7776356d6532363630716e6136673373227d
1890	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839302c2268617368223a2262333839376239613738666134393631663263613437393630653931366165343434613231636634656264313630356661653937643133373665653662346638222c22736c6f74223a31393035377d2c22697373756572566b223a2265303236356531633339373037666130613764316133376532333537353230326364316162333739646530613266613364326432313464646538653565316137222c2270726576696f7573426c6f636b223a2235323064323038373466353833363462306530363132396562323533326230653339316562363139636564323233363061353461653539303734653737353535222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137793534736a616c79327836797872687a6d72373870796d346630387868346d376d676737636e7a326a706d7234743963633773756c6134376a227d
1891	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839312c2268617368223a2266333731656136633835366333646365656336316333383361376464363431393861326436323866386230613733356431373639366632356230366130633865222c22736c6f74223a31393037307d2c22697373756572566b223a2266623539643934316264396631303138653333333861386134613363643332613766313962663765356233393630376364636532323664363634653931616634222c2270726576696f7573426c6f636b223a2262333839376239613738666134393631663263613437393630653931366165343434613231636634656264313630356661653937643133373665653662346638222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31686a6d3030373963666a307837726e67757935666c6434393367686a6c32676e3261357235796e38617876373963746365787073306b6e786a36227d
1892	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839322c2268617368223a2230623865376635383465326435306264363835306361616566363164326332666230303330396662613031643233306437656430643861633836343833613765222c22736c6f74223a31393037317d2c22697373756572566b223a2233323463323063376364313835373932353235316664666261343238363838383866663637613335626234333565636231353364376465383562386536396635222c2270726576696f7573426c6f636b223a2266333731656136633835366333646365656336316333383361376464363431393861326436323866386230613733356431373639366632356230366130633865222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e7372686e327075373065646d66707437786434717a327271383864717072656d6e33666c336e336b373472327336717a7a7671736576646634227d
1893	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2232636235393564626233336366653034623435366164313963626636356339626233663364666130363761353063333862623439613132316435363764666262227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303531307d7d2c226964223a2235646638393664356166663961343162623136393564373865666339316162623239326539666631656165306534386139346465313161666636623761383533222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223663326138336561363261393337373865633566346262356239323136326438353063623163303065323863623566326665633235393463313737353362323737313433366265383838663062353036326238323037306163333737306333316535623163616234303630333139326238353736363264373332636433663063225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c223135366636376532383735383263616236646561316562656163313238386135356465313233376631613462663763313930623332666664373862306266376232313665316361633261336230663733396335316336663837303034396538363066383465306639633237636637663432316631646632623936316239663039225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a313839332c2268617368223a2264393335613531326163373731363433326132303763663737363738643465306633383634333236373930303764363332313531323834333534363538663865222c22736c6f74223a31393038377d2c22697373756572566b223a2233323463323063376364313835373932353235316664666261343238363838383866663637613335626234333565636231353364376465383562386536396635222c2270726576696f7573426c6f636b223a2230623865376635383465326435306264363835306361616566363164326332666230303330396662613031643233306437656430643861633836343833613765222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b316e7372686e327075373065646d66707437786434717a327271383864717072656d6e33666c336e336b373472327336717a7a7671736576646634227d
1894	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839342c2268617368223a2264383465656562666661306337376564343366653531623139366163346261313532323537383165353238653461356439356237376536396464383032633234222c22736c6f74223a31393039327d2c22697373756572566b223a2233323463323063376364313835373932353235316664666261343238363838383866663637613335626234333565636231353364376465383562386536396635222c2270726576696f7573426c6f636b223a2264393335613531326163373731363433326132303763663737363738643465306633383634333236373930303764363332313531323834333534363538663865222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316e7372686e327075373065646d66707437786434717a327271383864717072656d6e33666c336e336b373472327336717a7a7671736576646634227d
1895	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839352c2268617368223a2264303364623433353162386339346339663930633934373262316464623866373563383731356238326664396261353238613366363036356430303465313666222c22736c6f74223a31393131337d2c22697373756572566b223a2266623539643934316264396631303138653333333861386134613363643332613766313962663765356233393630376364636532323664363634653931616634222c2270726576696f7573426c6f636b223a2264383465656562666661306337376564343366653531623139366163346261313532323537383165353238653461356439356237376536396464383032633234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31686a6d3030373963666a307837726e67757935666c6434393367686a6c32676e3261357235796e38617876373963746365787073306b6e786a36227d
1896	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839362c2268617368223a2265616463346236316532656561376631623732653838363364633431313839383836343130616434613635623137343037623261623966393931663133346436222c22736c6f74223a31393132307d2c22697373756572566b223a2237396539663265316361306263303833613466393430356333613762333432633532376330656263663138363937363534646535393266663865656437376534222c2270726576696f7573426c6f636b223a2264303364623433353162386339346339663930633934373262316464623866373563383731356238326664396261353238613366363036356430303465313666222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3174797273376d7a3530616b30793677736e737030736b703376743079386b6e717a6e397130727376757430376d35377071716e73363672303065227d
1897	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2235646638393664356166663961343162623136393564373865666339316162623239326539666631656165306534386139346465313161666636623761383533227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933363530313232227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32303536307d7d2c226964223a2231663730346339313337373664613032613564383862313861616234626136323935643464643430336362626365656638366137353130393531303334626564222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223739363661363838366466323634333738386133396437366366373565356633333563303663383937333765386632323331346432303234656639343666663737373030386462343837376332326433356664303735636530383631626234303037616533313532323763613737316365373035376265363339343863343038225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313639393839227d2c22686561646572223a7b22626c6f636b4e6f223a313839372c2268617368223a2231343633613365653734646434666636336466376334353730313265396338366633656237356366313565386461326162393637326133393865316335373031222c22736c6f74223a31393133387d2c22697373756572566b223a2266623539643934316264396631303138653333333861386134613363643332613766313962663765356233393630376364636532323664363634653931616634222c2270726576696f7573426c6f636b223a2265616463346236316532656561376631623732653838363364633431313839383836343130616434613635623137343037623261623966393931663133346436222c2273697a65223a3332392c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363530313232227d2c227478436f756e74223a312c22767266223a227672665f766b31686a6d3030373963666a307837726e67757935666c6434393367686a6c32676e3261357235796e38617876373963746365787073306b6e786a36227d
1898	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313839382c2268617368223a2235316238376432623433653061646236643630623338353538363939636531313030663935323235333435326539663032626438653831356335623165386264222c22736c6f74223a31393135397d2c22697373756572566b223a2263343234323863386439343434313964343132616237303061636363323533623361636233323961663662346232613566383830623765313063323138323538222c2270726576696f7573426c6f636b223a2231343633613365653734646434666636336466376334353730313265396338366633656237356366313565386461326162393637326133393865316335373031222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3134673832666565716d727279746b6b6836736b337439347561713767353936706c6b783235686c73356a7776356d6532363630716e6136673373227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	13435	139	3	7847098778090088	81681115724613	9605561855153	0.0640267726031872	96.0699264264031	-95.0699264264031	21.6070405464793	20.57448279908645
pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	13435	126	3	7789722228070157	16994955342885	200262058	0.013321710060974743	458.35496892502	-457.35496892502	0	2.295634398725993
pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	13435	133	3	7847573184887329	77889728463387	9527035420355	0.061054845887058985	100.75235001719354	-99.75235001719354	21.222112191601905	21.398585101733982
pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	13435	143	3	7851789288363123	82714552126123	9669085548559	0.06483684475869522	94.92633504671257	-93.92633504671257	25.265670933228353	22.966930524698544
pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	13435	119	3	7839581283240305	75381660577721	9524022708267	0.059088865246805504	103.99852196354094	-102.99852196354094	21.0023469167429	20.374488111592843
pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	13435	128	9	7844170398306907	75708556769883	8391305200456	0.05934510694936709	103.6100902325922	-102.6100902325922	19.176860841119098	18.915159562360223
pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h	13435	61	3	0	22455833436691	300000000	0.017602288219390926	0	1	7.575593418669575	7.575593418669575
pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u	13435	62	3	0	43257437405538	500000000	0.03390788780969615	0	1	17.93531750015656	17.93531750015656
pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	13435	140	3	7794025466933356	21298194206084	300000000	0.016694858110031286	365.9477132904972	-364.9477132904972	0	3.6459795336337932
pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	13435	139	3	7849708433500637	80631013877285	500000000	0.06320363702781459	97.35346309110496	-96.35346309110496	18.99789294297871	22.192635196155774
pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	13435	123	3	7839888378907131	76298725073895	9078434627115	0.05980771781680408	102.7525475860079	-101.7525475860079	21.4691941314655	19.923950342947744
\.


--
-- Data for Name: pool_delisted; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_delisted (stake_pool_id) FROM stdin;
\.


--
-- Data for Name: pool_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_metadata (id, ticker, name, description, homepage, hash, ext, stake_pool_id, pool_update_id) FROM stdin;
1	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	5460000000000
2	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	2510000000000
3	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	4700000000000
4	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	13170000000000
5	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	6480000000000
6	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	7290000000000
7	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	8390000000000
8	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u	12210000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
2510000000000	stake_test1uqfkc75zg9wr5kvuesstnu8mknuanrv5j5x3l47c2s9t3rq5m6rwl	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1uqfkc75zg9wr5kvuesstnu8mknuanrv5j5x3l47c2s9t3rq5m6rwl"]	8f99612b1c55e74571714f08a2d5b27509794b3a43263cabffa6b59ffed87d6c	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	251	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz
3380000000000	stake_test1uq3l6gv5v8jes72zwmrtepwm5gukwmuclrlymgfntxxlc9c46hat4	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1uq3l6gv5v8jes72zwmrtepwm5gukwmuclrlymgfntxxlc9c46hat4"]	3979ca3e2d91a9d58fc279545e990aaa32728102a20c8c9d7d00ef911a39c5d0	\N	\N	338	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug
4700000000000	stake_test1uz0qhhheme53cqpk8fn92yx966z6vmuf7zmh44lm3ckpl7ged2v54	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1uz0qhhheme53cqpk8fn92yx966z6vmuf7zmh44lm3ckpl7ged2v54"]	dc8b3045359815eddd6a235bf3db14b9c908cd4f9f09aa8413326e9db3c8cac3	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	470	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64
5460000000000	stake_test1uqr9nydtvner45hewk5kj79zv3s6j2m56wtztxfy26tys9qk62su9	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1uqr9nydtvner45hewk5kj79zv3s6j2m56wtztxfy26tys9qk62su9"]	73c24c8b561023f49a09b3f7560cf56d530ca8024cbfe93b2b7390ca87260fd0	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	546	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j
6480000000000	stake_test1upc323cxc86j43agtlakmfzaeckparzgpr2dcskyaf3yeusz9zmss	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1upc323cxc86j43agtlakmfzaeckparzgpr2dcskyaf3yeusz9zmss"]	c1adb56cd843ed60b75bb0ffd198028dd39acb9e9aa89ff28997d25456ce07aa	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	648	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6
7290000000000	stake_test1up44ypv58c4le9vuqel9ltx4t7vqm2strdxhvew8tec6hucflcwsp	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1up44ypv58c4le9vuqel9ltx4t7vqm2strdxhvew8tec6hucflcwsp"]	f2497d970717fa816b6089b48bf91f49402b02047904267e85cd2a52f5c1c67b	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	729	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9
8390000000000	stake_test1urkrm0z32wtlnxxuxrlzkc87egetcelytqemqlygt6ghuss6aksyw	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1urkrm0z32wtlnxxuxrlzkc87egetcelytqemqlygt6ghuss6aksyw"]	6ed062e21f8a8cc0a9da6315766cc177c711f5fbdfdee20f38a92dcafea86a90	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	839	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e
9530000000000	stake_test1uzmsl38nhmwcaqnnlc774p46hkq9acsmt2vqhda3jl9a05ckyyeqx	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1uzmsl38nhmwcaqnnlc774p46hkq9acsmt2vqhda3jl9a05ckyyeqx"]	504ee57ab8d6418eb0e5f4a209c24f8683e491aeb45cac8bb9d308d7884d587a	\N	\N	953	pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h
10840000000000	stake_test1upjfx2tzext39l85l6yuwnp4pmns68wmkmrteex90tmv9yqhf5n8g	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1upjfx2tzext39l85l6yuwnp4pmns68wmkmrteex90tmv9yqhf5n8g"]	77e015daf6aaded6cdd8d3e63277fc3e43c1569522f4bc247d6cb219548508aa	\N	\N	1084	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm
12210000000000	stake_test1uz9as07pp2qemt2qvv8zve2y3t5fn2zk0esuqzjyxkruw7saw26ls	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uz9as07pp2qemt2qvv8zve2y3t5fn2zk0esuqzjyxkruw7saw26ls"]	b2cac47908b97d6faba5a8661c5559bc8822a9afee5a54266cf8bc7324644843	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	1221	pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u
13170000000000	stake_test1uzqm27smpens3rg7nhjm44vwhuam3cycrll2lhdgrnrqytsx2a3fx	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uzqm27smpens3rg7nhjm44vwhuam3cycrll2lhdgrnrqytsx2a3fx"]	2df047be2a4057f5a9dc3d9a9aeb2f423990cf999c4c8b501208093169104a21	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1317	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a
190870000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	19087	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
192340000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	19234	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
9860000000000	5	986	pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h
11160000000000	18	1116	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm
12430000000000	5	1243	pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u
13460000000000	18	1346	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h	1000000	0	0	500000000	0	0	0	0	0	1
2	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	0	0	400000000	0	0	0	0	0	1
3	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	0	0	500000000	0	0	0	0	0	1
4	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	0	0	600000000	0	0	0	0	0	1
5	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	0	0	420000000	0	0	0	0	0	1
6	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	0	0	410000000	0	0	0	0	0	1
7	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	0	0	410000000	0	0	0	0	0	1
8	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	0	0	410000000	0	0	0	0	0	1
9	pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h	1000000	1	0	500000000	0	0	0	12619091767734	12619091767734	1
10	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	1	0	500000000	0	0	0	5520852648383	5520852648383	1
11	pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u	1000000	1	0	400000000	0	0	0	8675625590317	8675625590317	1
12	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	1	0	400000000	0	0	0	10253012061284	10253012061284	1
13	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	1	0	400000000	0	0	0	9464318825800	9464318825800	1
14	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	1	0	500000000	0	0	0	7098239119350	7098239119350	1
15	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	1	0	600000000	0	0	0	6309545883867	6309545883867	1
16	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	1	0	420000000	0	0	0	5520852648383	5520852648383	1
17	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	1	0	410000000	0	0	0	10253012061284	10253012061284	1
18	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	1	0	410000000	0	0	0	4732159412900	4732159412900	1
19	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	1	0	410000000	0	0	0	7886932354834	7886932354834	1
20	pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h	1000000	2	3	500000000	7773227572018672	7773227272018672	0	9336442377557	9336442377557	1
21	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	2	1	500000000	7772727272727272	7772727272727272	0	10185865447552	10185865447552	1
22	pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u	1000000	2	1	400000000	7772727272727272	7772727272727272	0	5092932723776	5092932723776	1
23	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	2	1	400000000	7772727272727272	7772727272727272	0	5941754844405	5941754844405	1
24	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	2	3	400000000	7773227772189065	7773227272189065	0	5941372269083	5941372269083	1
25	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	2	3	500000000	7773227872191829	7773227272191829	0	10185209473112	10185209473112	1
26	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	2	3	600000000	7773227472189057	7773227272189057	0	10185209997233	10185209997233	1
27	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	2	3	420000000	7773227772189057	7773227272189057	0	8487674670120	8487674670120	1
28	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	2	3	410000000	7773227772189057	7773227272189057	0	7638907203108	7638907203108	1
29	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	2	3	410000000	7773227772189057	7773227272189057	0	6790139736096	6790139736096	1
30	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	2	3	410000000	7773227772189057	7773227272189057	0	6790139736096	6790139736096	1
31	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	3	3	500000000	7773227572018672	7773227272018672	0	5091176818749	5091176818749	1
32	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	3	3	400000000	7773227772015856	7773227272015856	0	12727941719399	12727941719399	1
33	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	3	3	400000000	7773227772189065	7773227272189065	1273126135822	7212168343589	8485294479411	1
34	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	3	3	500000000	7773227872191829	7773227272191829	1145846741004	6490918192218	7636764933222	1
35	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	3	3	600000000	7773227472189057	7773227272189057	0	0	0	1
36	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	3	3	420000000	7773227772189057	7773227272189057	1782226990161	10097185281014	11879412271175	1
37	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	3	3	410000000	7773227772189057	7773227272189057	1145846672238	6490918359231	7636765031469	1
38	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	3	3	410000000	7773227772189057	7773227272189057	891296245068	5048409890518	5939706135586	1
39	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	3	3	410000000	7773227772189057	7773227272189057	1145846672238	6490918359231	7636765031469	1
40	pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h	1000000	3	3	500000000	7773227572018672	7773227272018672	0	0	0	1
41	pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u	1000000	3	3	400000000	7773227772015856	7773227272015856	0	3394117791839	3394117791839	1
42	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	4	3	500000000	7778748424667055	7778748124667055	0	0	0	1
43	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	4	3	400000000	7783480784077140	7783480284077140	1124886700863	6372145242639	7497031943502	1
44	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	4	3	400000000	7782692091014865	7782691591014865	875074182027	4956541575264	5831615757291	1
45	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	4	3	500000000	7780326111311179	7780325511311179	1000341503587	5666388940471	6666730444058	1
46	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	4	3	600000000	7779537018072924	7779536818072924	0	0	0	1
47	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	4	3	420000000	7778748624837440	7778748124837440	1125553818127	6376038903809	7501592721936	1
48	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	4	3	410000000	7783480784250341	7783480284250341	1124886700838	6372145242497	7497031943335	1
49	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	4	3	410000000	7777959931601957	7777959431601957	1000654149869	5668104420131	6668758570000	1
50	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	4	3	410000000	7781114704543891	7781114204543891	875251509804	4957546431807	5832797941611	1
51	pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h	1000000	4	3	500000000	7785846663786406	7785846363786406	0	0	0	1
52	pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u	1000000	4	3	400000000	7781903397606173	7781902897606173	1625035268637	9206205912187	10831241180824	1
53	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	5	3	500000000	7788934290114607	7788933990114607	0	0	0	1
54	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	5	3	400000000	7789422538921545	7789422038921545	1096064590060	6208820020061	7304884610121	1
55	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	5	3	400000000	7788633463283948	7788632962901780	1217936056020	6899424695748	8117360751768	1
56	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	5	3	500000000	7790511320784291	7790510719998115	852449303806	4828333572571	5680782876377	1
57	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	5	3	600000000	7789722228070157	7789722027808099	0	0	0	1
58	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	5	3	420000000	7787236299507560	7787235798961605	1339919816931	7590779043158	8930698860089	1
59	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	5	3	410000000	7791119691453449	7791119190962089	1095825905007	6207467469976	7303293374983	1
60	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	5	3	410000000	7784750071338053	7784749570901289	1705836734953	9664137356390	11369974091343	1
61	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	5	3	410000000	7787904844279987	7787904343843223	852734430727	4829949705026	5682684135753	1
62	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	6	3	500000000	7794025466933356	7794025166736868	0	0	0	1
63	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	6	3	400000000	7802150480640944	7802149979822241	1548201771240	8770929617000	10319131388240	1
64	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	6	3	400000000	7797118757763359	7795845131245369	1033866292443	5849994137017	6883860429460	1
65	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	6	3	500000000	7798148085717513	7797001638190333	826973757112	4679387670280	5506361427392	1
66	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	6	3	600000000	7789722228070157	7789722027808099	0	0	0	1
67	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	6	3	420000000	7799115711778735	7797332984242619	1240696613910	7017820776615	8258517390525	1
68	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	6	3	410000000	7798756456484918	7797610109321320	826909157936	4679022725421	5505931883357	1
69	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	6	3	410000000	7790689777473639	7789797980791807	931031318766	5269555655190	6200586973956	1
70	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	6	3	410000000	7795541609311456	7794395262202454	1033980035585	5851273096314	6885253131899	1
71	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	7	3	500000000	7794025466933356	7794025166736868	0	0	0	1
72	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	7	3	400000000	7809647512584446	7808522125064880	1100162198145	6226060333475	7326222531620	1
73	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	7	3	400000000	7802950373520650	7800801672820633	826526051993	4672856825496	5499382877489	1
74	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	7	3	500000000	7804814816161571	7802668027130804	1101659177883	6229099708571	7330758886454	1
75	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	7	3	600000000	7789722228070157	7789722027808099	0	0	0	1
76	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	7	3	420000000	7806617304500671	7803709023146428	551154762151	3113378372943	3664533135094	1
77	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	7	3	410000000	7806253488428253	7803982254563817	1468629800941	8303913994539	9772543795480	1
78	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	7	3	410000000	7797358536043639	7795466085211938	1102519034656	6235249942649	7337768977305	1
79	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	7	3	410000000	7801374407253067	7799352808634261	1377474132224	7790015559963	9167489692187	1
80	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	8	3	500000000	7794025466933356	7794025166736868	0	0	0	1
81	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	8	3	400000000	7816952397194567	7814730945084941	861020200221	4867679737943	5728699938164	1
82	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	8	3	400000000	7811067734272418	7807701097516381	862384058580	4870631738728	5733015797308	1
83	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	8	3	500000000	7810495599037948	7807496360703375	957983329763	5412500839990	6370484169753	1
84	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	8	3	600000000	7789722228070157	7789722027808099	0	0	0	1
85	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	8	3	420000000	7815548003360760	7811299802189586	1054000263778	5949002264672	7003002528450	1
86	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	8	3	410000000	7813556781803236	7810189722033793	862109042293	4869080474206	5731189516499	1
87	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	8	3	410000000	7808728510134982	7805130222568328	1150281413584	6496029532996	7646310946580	1
88	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	8	3	410000000	7807057091388820	7804182758339287	575124169585	3248849805946	3823973975531	1
89	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	9	3	500000000	7794025466933356	7794025166736868	0	0	0	1
90	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	9	3	400000000	7827271528582807	7823501874701941	377562520538	2130467360847	2508029881385	1
91	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	9	3	400000000	7817951594701878	7813551091653398	661576403956	3732708164044	4394284568000	1
92	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	9	3	500000000	7816001960465340	7812175748373655	1322603425916	7468157942809	8790761368725	1
93	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	9	3	600000000	7789722228070157	7789722027808099	0	0	0	1
94	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	9	3	420000000	7823806520751285	7818317622966201	850515859886	4795050575138	5645566435024	1
95	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	9	3	410000000	7819062713686593	7814868744759214	1039127604522	5865195446230	6904323050752	1
96	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	9	3	410000000	7814929097108938	7810399778223518	850921109011	4801058446890	5651979555901	1
97	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	9	3	410000000	7813942344520719	7810034031435601	850638548028	4802054745600	5652693293628	1
98	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	10	3	500000000	7794025466933356	7794025166736868	0	0	0	1
99	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	10	3	400000000	7834597751114427	7829727935035416	1035055973829	5838896592832	6873952566661	1
100	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	10	3	400000000	7823450977579367	7818223948478894	950429959004	5359671003452	6310100962456	1
101	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	10	3	500000000	7823332719351794	7818404848082226	1295660374206	7309152825610	8604813199816	1
102	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	10	3	600000000	7789722228070157	7789722027808099	0	0	0	1
103	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	10	3	420000000	7827471053886379	7821431001339144	1123237360373	6330324677103	7453562037476	1
104	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	10	3	410000000	7828835257482073	7823172658753753	1554452886397	8764065427402	10318518313799	1
105	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	10	3	410000000	7822266866086243	7816635028166167	605216537695	3410910113886	4016126651581	1
106	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	10	3	410000000	7823109834212906	7817824046995564	1036891881062	5847154803864	6884046684926	1
107	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	11	3	500000000	7794025466933356	7794025166736868	0	0	0	1
108	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	11	3	400000000	7840326451052591	7834595614773359	550076884468	3099776219452	3649853103920	1
109	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	11	3	400000000	7829183993376675	7823094580217622	1377015105102	7760603788942	9137618894044	1
110	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	11	3	500000000	7829703203521547	7823817348922216	1101443455700	6208166906097	7309610361797	1
111	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	11	3	600000000	7789722228070157	7789722027808099	0	0	0	1
112	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	11	3	420000000	7834474056414829	7827380003603816	459229389083	2584586914247	3043816303330	1
113	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	11	3	410000000	7834566446998572	7828041739227959	550797287027	3101739203245	3652536490272	1
114	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	11	3	410000000	7829913177032823	7823131057699163	1285765727901	7241884336787	8527650064688	1
115	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	11	3	410000000	7826933808188437	7821072896801510	642863384439	3622584698229	4265448082668	1
116	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	12	3	500000000	7794025466933356	7794025166736868	0	0	0	1
117	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	12	3	400000000	7842834480933976	7836726082134206	1254172159458	7068037315631	8322209475089	1
118	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	12	3	400000000	7833578277944675	7826827288381666	807701889582	4548611498177	5356313387759	1
119	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	12	3	500000000	7838493964890272	7831285506865025	1076501119891	6060771319120	7137272439011	1
120	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	12	3	600000000	7789722228070157	7789722027808099	0	0	0	1
121	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	12	3	420000000	7840119622849853	7832175054178954	987119696151	5554023444647	6541143140798	1
122	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	12	3	410000000	7841470770049324	7833906934674189	1076365287747	6058197676212	7134562963959	1
123	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	12	3	410000000	7835565156588724	7827932116146053	538791229518	3031178888841	3569970118359	1
124	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	12	8	410000000	7832587500659522	7825875950724567	1346081834842	7582236382836	8928318217678	1
125	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	13	3	500000000	7794025466933356	7794025166736868	0	0	0	1
126	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	13	3	400000000	7849708433500637	7842564978727038	1157803279037	6519088865443	7676892144480	1
127	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	13	3	400000000	7839888378907131	7832186959385118	1070541335329	6024696849838	7095238185167	1
128	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	13	3	500000000	7847098778090088	7838594659690635	535249991243	3009109329731	3544359320974	1
129	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	13	3	600000000	7789722228070157	7789722027808099	0	0	0	1
130	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	13	3	420000000	7847573184887329	7838505378856057	981335760681	5516263506764	6497599267445	1
131	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	13	3	410000000	7851789288363123	7842671000101591	1248274466709	7016956838199	8265231304908	1
132	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	13	3	410000000	7839581283240305	7831343026259939	535672301955	3012085759586	3547758061541	1
133	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	13	9	410000000	7844170398306907	7836421956490890	980851784610	5519566129353	6500417913963	1
134	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	14	3	500000000	7794025466933356	7794025166736868	0	0	0	1
135	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	14	3	400000000	7853358286604557	7845664754946490	350983840699	1973794952991	2324778793690	1
136	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	14	3	400000000	7849025997801175	7839947563174060	1229517579214	6911699284092	8141216863306	1
137	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	14	3	500000000	7854408388451885	7844802826596732	790275724674	4439777231229	5230052955903	1
138	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	14	3	600000000	7789722228070157	7789722027808099	0	0	0	1
139	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	14	3	420000000	7850617001190659	7841089965770304	966217109441	5429156936095	6395374045536	1
140	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	14	3	410000000	7855441824853395	7845772739304836	1492318972852	8385370296173	9877689269025	1
141	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	14	3	410000000	7848108933304993	7838584910596726	1054388705963	5924612589421	6979001295384	1
142	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	14	9	410000000	7848435846389575	7840044541189119	877955144001	4937637020248	5815592164249	1
143	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	15	3	500000000	7794025466933356	7794025166736868	0	0	0	1
144	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	15	3	400000000	7861680496079646	7852732792262121	1089681887834	6126118474493	7215800362327	1
145	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	15	3	400000000	7854382311188934	7844496174672237	587848063165	3301193190609	3889041253774	1
146	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	15	3	500000000	7861545660890896	7850863597915852	923250262522	5182531687021	6105781949543	1
147	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	15	3	600000000	7789722228070157	7789722027808099	0	0	0	1
148	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	15	3	420000000	7857158144331457	7846643989214951	1007580497083	5656992026472	6664572523555	1
149	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	15	3	410000000	7862576387817354	7851830936981048	1174853583731	6595122903484	7769976487215	1
150	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	15	3	410000000	7851678903423352	7841616089485567	1511812706538	8492022318945	10003835025483	1
151	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	15	9	410000000	7857364147714833	7847626760679535	587560974082	3300004404952	3887565379034	1
152	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	16	3	400000000	7861477549374101	7850520871522075	1339360465143	7517552856686	8856913321829	1
153	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	16	3	500000000	7865090020211870	7853872707245583	1024011401057	5745811477048	6769822878105	1
154	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	16	3	600000000	7789722228070157	7789722027808099	0	0	0	1
155	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	16	3	420000000	7863655743598902	7852160252721715	1024386221540	5746671425602	6771057647142	1
156	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	16	3	410000000	7870841619122262	7858847893819247	1496206178961	8390920057554	9887126236515	1
157	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	16	3	410000000	7855226661484893	7844628175245153	394386532677	2212660912473	2607047445150	1
158	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	16	9	410000000	7863864565628796	7853146326808888	472704551790	2652315991684	3125020543474	1
159	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	16	3	500000000	7794025466933356	7794025166736868	0	0	0	1
160	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	16	3	400000000	7869357388224126	7859251881127564	708082944862	3976175967206	4684258912068	1
161	pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	1000000	17	3	400000000	7869618766237407	7857432570806167	586470805018	3287137463838	3873608268856	1
162	pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	1000000	17	3	500000000	7870320073167773	7858312484476812	502627354701	2817312445414	3319939800115	1
163	pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	1000000	17	3	600000000	7789722228070157	7789722027808099	0	0	0	1
164	pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	1000000	17	4	420000000	7872402189404713	7859940481418085	921243378227	5163703131557	6084946509784	1
165	pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	1000000	17	3	410000000	7880719308391287	7867233264115420	669873035907	3750872131814	4420745167721	1
166	pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	1000000	17	3	410000000	7862205662780277	7850552787834574	1340850883535	7521459082657	8862309966192	1
167	pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	1000000	17	9	410000000	7867329085425800	7855732891461891	1088737247904	6107200351947	7195937599851	1
168	pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	1000000	17	3	500000000	7794025466933356	7794025166736868	0	0	0	1
169	pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	1000000	17	3	400000000	7871682167017816	7861225676080555	1003636533683	5635094120368	6638730654051	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1hr2jx2l0eqg6tjf78cyxuexevz62qvt3wgyqx7wapqp5sv9ggzz	active	2510000000000	\N
pool1ltft20mlx38yrkhpmvph9c6weuysk7zc3umkfpt553pqkf7dfug	active	3380000000000	\N
pool138mzcag7c9ukry57mq0d4qg0qptpxqfpfmxehkx545mn6za7k64	active	4700000000000	\N
pool197rm3c6snsjng736lrrfyyk2jwt49h0tm2tzsxylr3m8v446v7j	active	5460000000000	\N
pool1pf30gvfrmagamuvyh584quawvw2vn53dns5dyzvxej66um9uqn6	active	6480000000000	\N
pool10393cv05hjlkvdag28vrjzkswykvv9c0vcwdm34jk22pk38rqh9	active	7290000000000	\N
pool1us9j40gu799whmh0c6ufj0kwqkhq8wlvx2x042xavk2wzk3k44e	active	8390000000000	\N
pool1a765vfkrk6v4k6p966mkv7xfnfj9lag0rfxr49njfs25c0hpu2h	retired	9530000000000	9860000000000
pool14x5k2pt85wtp9czuuwp39vaj5scfc4085ds04cunxl9gg3wk99u	retired	12210000000000	12430000000000
pool1ec4s3cuv8cle2q3cch4fdym7l6j38gx4wmjwu26prwa5qkalstm	retired	10840000000000	11160000000000
pool1a52pe4uafexv0qjn5w2g6dtygcgjcmmhakeadwehrn7tymgtq6a	retired	13170000000000	13460000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	190870000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	192340000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 169, true);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (name);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (event, name);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: block_data PK_block_data_block_height; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block_data
    ADD CONSTRAINT "PK_block_data_block_height" PRIMARY KEY (block_height);


--
-- Name: block PK_block_slot; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block
    ADD CONSTRAINT "PK_block_slot" PRIMARY KEY (slot);


--
-- Name: current_pool_metrics PK_current_pool_metrics_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_pool_metrics
    ADD CONSTRAINT "PK_current_pool_metrics_stake_pool_id" PRIMARY KEY (stake_pool_id);


--
-- Name: pool_delisted PK_pool_delisted_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_delisted
    ADD CONSTRAINT "PK_pool_delisted_stake_pool_id" PRIMARY KEY (stake_pool_id);


--
-- Name: pool_metadata PK_pool_metadata_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "PK_pool_metadata_id" PRIMARY KEY (id);


--
-- Name: pool_registration PK_pool_registration_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "PK_pool_registration_id" PRIMARY KEY (id);


--
-- Name: pool_retirement PK_pool_retirement_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "PK_pool_retirement_id" PRIMARY KEY (id);


--
-- Name: pool_rewards PK_pool_rewards_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "PK_pool_rewards_id" PRIMARY KEY (id);


--
-- Name: stake_pool PK_stake_pool_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "PK_stake_pool_id" PRIMARY KEY (id);


--
-- Name: pool_metadata REL_pool_metadata_pool_update_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "REL_pool_metadata_pool_update_id" UNIQUE (pool_update_id);


--
-- Name: stake_pool REL_stake_pool_last_registration_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "REL_stake_pool_last_registration_id" UNIQUE (last_registration_id);


--
-- Name: stake_pool REL_stake_pool_last_retirement_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "REL_stake_pool_last_retirement_id" UNIQUE (last_retirement_id);


--
-- Name: pool_rewards UQ_pool_rewards_epoch_no_stake_pool_id}; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "UQ_pool_rewards_epoch_no_stake_pool_id}" UNIQUE (epoch_no, stake_pool_id);


--
-- Name: archive_archivedon_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_archivedon_idx ON pgboss.archive USING btree (archivedon);


--
-- Name: archive_id_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_id_idx ON pgboss.archive USING btree (id);


--
-- Name: job_fetch; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_fetch ON pgboss.job USING btree (name text_pattern_ops, startafter) WHERE (state < 'active'::pgboss.job_state);


--
-- Name: job_name; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_name ON pgboss.job USING btree (name text_pattern_ops);


--
-- Name: job_singleton_queue; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singleton_queue ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'active'::pgboss.job_state) AND (singletonon IS NULL) AND (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text));


--
-- Name: job_singletonkey; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkey ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'completed'::pgboss.job_state) AND (singletonon IS NULL) AND (NOT (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text)));


--
-- Name: job_singletonkeyon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkeyon ON pgboss.job USING btree (name, singletonon, singletonkey) WHERE (state < 'expired'::pgboss.job_state);


--
-- Name: job_singletonon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonon ON pgboss.job USING btree (name, singletonon) WHERE ((state < 'expired'::pgboss.job_state) AND (singletonkey IS NULL));


--
-- Name: IDX_block_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_block_hash" ON public.block USING btree (hash);


--
-- Name: IDX_block_height; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_block_height" ON public.block USING btree (height);


--
-- Name: IDX_pool_metadata_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_pool_metadata_name" ON public.pool_metadata USING btree (name);


--
-- Name: IDX_pool_metadata_ticker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_pool_metadata_ticker" ON public.pool_metadata USING btree (ticker);


--
-- Name: IDX_stake_pool_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stake_pool_status" ON public.stake_pool USING btree (status);


--
-- Name: job job_block_slot_fkey; Type: FK CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_block_slot_fkey FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: block_data FK_block_data_block_height; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.block_data
    ADD CONSTRAINT "FK_block_data_block_height" FOREIGN KEY (block_height) REFERENCES public.block(height) ON DELETE CASCADE;


--
-- Name: current_pool_metrics FK_current_pool_metrics_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_pool_metrics
    ADD CONSTRAINT "FK_current_pool_metrics_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_metadata FK_pool_metadata_pool_update_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "FK_pool_metadata_pool_update_id" FOREIGN KEY (pool_update_id) REFERENCES public.pool_registration(id) ON DELETE CASCADE;


--
-- Name: pool_metadata FK_pool_metadata_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_metadata
    ADD CONSTRAINT "FK_pool_metadata_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id);


--
-- Name: pool_registration FK_pool_registration_block_slot; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "FK_pool_registration_block_slot" FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: pool_registration FK_pool_registration_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_registration
    ADD CONSTRAINT "FK_pool_registration_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_retirement FK_pool_retirement_block_slot; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "FK_pool_retirement_block_slot" FOREIGN KEY (block_slot) REFERENCES public.block(slot) ON DELETE CASCADE;


--
-- Name: pool_retirement FK_pool_retirement_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_retirement
    ADD CONSTRAINT "FK_pool_retirement_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id) ON DELETE CASCADE;


--
-- Name: pool_rewards FK_pool_rewards_stake_pool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pool_rewards
    ADD CONSTRAINT "FK_pool_rewards_stake_pool_id" FOREIGN KEY (stake_pool_id) REFERENCES public.stake_pool(id);


--
-- Name: stake_pool FK_stake_pool_last_registration_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "FK_stake_pool_last_registration_id" FOREIGN KEY (last_registration_id) REFERENCES public.pool_registration(id) ON DELETE SET NULL;


--
-- Name: stake_pool FK_stake_pool_last_retirement_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stake_pool
    ADD CONSTRAINT "FK_stake_pool_last_retirement_id" FOREIGN KEY (last_retirement_id) REFERENCES public.pool_retirement(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

