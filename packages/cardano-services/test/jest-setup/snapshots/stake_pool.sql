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
    pledge bigint NOT NULL,
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
a95ef5fe-9c61-46b5-b97f-44d28ad50f4a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:47:01.733988+00	2024-01-18 09:48:01.721034+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:45:01.733988+00	2024-01-18 09:48:01.72771+00	2024-01-18 09:55:01.733988+00	f	\N	\N
7e3d219e-c6e6-479d-b876-cc49503a357f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:20:27.282853+00	2024-01-18 09:20:27.285442+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:20:27.282853+00	2024-01-18 09:20:27.29757+00	2024-01-18 09:28:27.282853+00	f	\N	\N
dd136c99-65e4-44fd-b4c3-4addc4130be1	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:30:01.908489+00	2024-01-18 09:30:01.922001+00	\N	2024-01-18 09:30:00	00:15:00	2024-01-18 09:29:01.908489+00	2024-01-18 09:30:01.937229+00	2024-01-18 09:31:01.908489+00	f	\N	\N
1a478b34-bd2b-4f5b-ab34-59545f894a93	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:09:01.702092+00	2024-01-18 10:09:02.718685+00	\N	2024-01-18 10:09:00	00:15:00	2024-01-18 10:08:02.702092+00	2024-01-18 10:09:02.727779+00	2024-01-18 10:10:01.702092+00	f	\N	\N
675a1482-3c0f-4ea6-9296-8fe895cd48a7	pool-rewards	0	{"epochNo": 4}	completed	1000000	0	30	f	2024-01-18 09:30:11.82442+00	2024-01-18 09:30:11.975607+00	4	\N	00:15:00	2024-01-18 09:30:11.82442+00	2024-01-18 09:30:12.120461+00	2024-02-01 09:30:11.82442+00	f	\N	6014
698ce5b9-79b6-4889-b923-a8db76eb2fca	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:31:01.933835+00	2024-01-18 09:31:01.943806+00	\N	2024-01-18 09:31:00	00:15:00	2024-01-18 09:30:01.933835+00	2024-01-18 09:31:01.954731+00	2024-01-18 09:32:01.933835+00	f	\N	\N
44e147ee-fa4f-46cd-b0d4-b5aef14183ba	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:50:01.361441+00	2024-01-18 09:50:02.370041+00	\N	2024-01-18 09:50:00	00:15:00	2024-01-18 09:49:02.361441+00	2024-01-18 09:50:02.380411+00	2024-01-18 09:51:01.361441+00	f	\N	\N
70c2cdc8-d249-4447-b4ba-ade9c29f82a9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:50:01.730019+00	2024-01-18 09:51:01.723345+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:48:01.730019+00	2024-01-18 09:51:01.736759+00	2024-01-18 09:58:01.730019+00	f	\N	\N
0e2ac107-ba04-44ec-b332-267d3c877440	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:33:01.976871+00	2024-01-18 09:33:01.993498+00	\N	2024-01-18 09:33:00	00:15:00	2024-01-18 09:32:01.976871+00	2024-01-18 09:33:02.009224+00	2024-01-18 09:34:01.976871+00	f	\N	\N
d6dd11c1-901a-423d-835c-e8b3ef50af2d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:34:01.007394+00	2024-01-18 09:34:02.019257+00	\N	2024-01-18 09:34:00	00:15:00	2024-01-18 09:33:02.007394+00	2024-01-18 09:34:02.026003+00	2024-01-18 09:35:01.007394+00	f	\N	\N
32120622-4497-4e53-9a3d-2419b0039f03	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:51:01.377223+00	2024-01-18 09:51:02.397617+00	\N	2024-01-18 09:51:00	00:15:00	2024-01-18 09:50:02.377223+00	2024-01-18 09:51:02.411153+00	2024-01-18 09:52:01.377223+00	f	\N	\N
523cacb5-0b4d-4c46-9bbe-73cd79cca266	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:21:01.684084+00	2024-01-18 09:21:01.688732+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:21:01.684084+00	2024-01-18 09:21:01.698477+00	2024-01-18 09:29:01.684084+00	f	\N	\N
89bc9d04-8a5c-418c-a806-ace20b7613ac	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:20:27.293061+00	2024-01-18 09:21:01.693873+00	\N	2024-01-18 09:20:00	00:15:00	2024-01-18 09:20:27.293061+00	2024-01-18 09:21:01.698959+00	2024-01-18 09:21:27.293061+00	f	\N	\N
4bead0ff-f1a7-4dc3-9315-0f1171bbe951	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:35:01.024176+00	2024-01-18 09:35:02.044903+00	\N	2024-01-18 09:35:00	00:15:00	2024-01-18 09:34:02.024176+00	2024-01-18 09:35:02.062196+00	2024-01-18 09:36:01.024176+00	f	\N	\N
1661d3e8-1e53-4a97-a967-79f15f89c4d0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:35:01.720166+00	2024-01-18 09:36:01.70804+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:33:01.720166+00	2024-01-18 09:36:01.720892+00	2024-01-18 09:43:01.720166+00	f	\N	\N
6d7161e0-90ed-4fd6-be34-2fd685fdb5d6	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:52:01.40813+00	2024-01-18 09:52:02.407226+00	\N	2024-01-18 09:52:00	00:15:00	2024-01-18 09:51:02.40813+00	2024-01-18 09:52:02.413437+00	2024-01-18 09:53:01.40813+00	f	\N	\N
b0c53c84-e4e4-4810-9be2-8674b5c974a0	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:37:01.073498+00	2024-01-18 09:37:02.080826+00	\N	2024-01-18 09:37:00	00:15:00	2024-01-18 09:36:02.073498+00	2024-01-18 09:37:02.097992+00	2024-01-18 09:38:01.073498+00	f	\N	\N
178a0a70-91b0-4dec-9cf4-844196af4694	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:53:01.741008+00	2024-01-18 09:54:01.726788+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:51:01.741008+00	2024-01-18 09:54:01.734446+00	2024-01-18 10:01:01.741008+00	f	\N	\N
b6b55035-5aab-4e66-a371-27a2f0775402	pool-metadata	0	{"poolId": "pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "5590000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.504321+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.504321+00	2024-01-18 09:21:01.759204+00	2024-02-01 09:20:27.504321+00	f	\N	559
5d185879-08f4-4855-bdfa-2d9bb5d9cde6	pool-metadata	0	{"poolId": "pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "2770000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.41763+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.41763+00	2024-01-18 09:21:01.759907+00	2024-02-01 09:20:27.41763+00	f	\N	277
5d708e4e-75cf-4cf9-88e6-b3a63fae7b5f	pool-metadata	0	{"poolId": "pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "4710000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.485135+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.485135+00	2024-01-18 09:21:01.760173+00	2024-02-01 09:20:27.485135+00	f	\N	471
d64217c0-bdde-4095-b4f6-95d94a9f4c9c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:39:01.117479+00	2024-01-18 09:39:02.133429+00	\N	2024-01-18 09:39:00	00:15:00	2024-01-18 09:38:02.117479+00	2024-01-18 09:39:02.147725+00	2024-01-18 09:40:01.117479+00	f	\N	\N
148639b0-9318-4baa-98c5-866a6ae0e5da	pool-metadata	0	{"poolId": "pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "6640000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.548425+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.548425+00	2024-01-18 09:21:01.767771+00	2024-02-01 09:20:27.548425+00	f	\N	664
6cc1bb96-417d-4379-ade1-7b58c1a5257d	pool-metadata	0	{"poolId": "pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "7300000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.569251+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.569251+00	2024-01-18 09:21:01.769341+00	2024-02-01 09:20:27.569251+00	f	\N	730
9945c68b-4dde-4153-8761-b3e22bec5fe8	pool-metadata	0	{"poolId": "pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "8270000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.604692+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.604692+00	2024-01-18 09:21:01.768311+00	2024-02-01 09:20:27.604692+00	f	\N	827
b016c901-0a4e-4d2b-9d08-810e0f5072c0	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2024-01-18 09:20:27.904551+00	2024-01-18 09:21:01.720397+00	0	\N	00:15:00	2024-01-18 09:20:27.904551+00	2024-01-18 09:21:01.935377+00	2024-02-01 09:20:27.904551+00	f	\N	2008
c7395380-e03a-41eb-bb9c-13b62c3829cb	pool-metrics	0	{"slot": 3094}	completed	0	0	0	f	2024-01-18 09:20:28.098448+00	2024-01-18 09:21:01.720497+00	\N	\N	00:15:00	2024-01-18 09:20:28.098448+00	2024-01-18 09:21:02.033144+00	2024-02-01 09:20:28.098448+00	f	\N	3094
db0c7a3d-5a69-4335-8aa8-e2a3fc2f7e7f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:21:01.696387+00	2024-01-18 09:21:05.695809+00	\N	2024-01-18 09:21:00	00:15:00	2024-01-18 09:21:01.696387+00	2024-01-18 09:21:05.713373+00	2024-01-18 09:22:01.696387+00	f	\N	\N
78cfb5f7-14d9-48a5-a022-77ab1de20506	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2024-01-18 09:21:31.762974+00	2024-01-18 09:21:33.720402+00	1	\N	00:15:00	2024-01-18 09:20:28.084224+00	2024-01-18 09:21:33.871321+00	2024-02-01 09:20:28.084224+00	f	\N	3000
8d22f51d-857e-438e-a302-40e20d6b3a62	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:40:01.144364+00	2024-01-18 09:40:02.157176+00	\N	2024-01-18 09:40:00	00:15:00	2024-01-18 09:39:02.144364+00	2024-01-18 09:40:02.172035+00	2024-01-18 09:41:01.144364+00	f	\N	\N
c0457a6a-98f7-4b70-9beb-605c6ec5b084	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:23:01.70254+00	2024-01-18 09:24:01.692203+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:21:01.70254+00	2024-01-18 09:24:01.70491+00	2024-01-18 09:31:01.70254+00	f	\N	\N
7c4a0ff1-be7f-4190-9d84-f1f2845d7ad7	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:41:01.167851+00	2024-01-18 09:41:02.182803+00	\N	2024-01-18 09:41:00	00:15:00	2024-01-18 09:40:02.167851+00	2024-01-18 09:41:02.195305+00	2024-01-18 09:42:01.167851+00	f	\N	\N
5ff14a0e-5599-4ca3-8550-e336b1f6709c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:41:01.730223+00	2024-01-18 09:42:01.714353+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:39:01.730223+00	2024-01-18 09:42:01.726108+00	2024-01-18 09:49:01.730223+00	f	\N	\N
ffaa8d00-2700-4900-9fa7-69b008d651ee	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:42:01.192542+00	2024-01-18 09:42:02.200138+00	\N	2024-01-18 09:42:00	00:15:00	2024-01-18 09:41:02.192542+00	2024-01-18 09:42:02.214856+00	2024-01-18 09:43:01.192542+00	f	\N	\N
4267b7a1-ed50-4eb6-a8a0-33a903680787	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:44:01.231376+00	2024-01-18 09:44:02.240377+00	\N	2024-01-18 09:44:00	00:15:00	2024-01-18 09:43:02.231376+00	2024-01-18 09:44:02.253189+00	2024-01-18 09:45:01.231376+00	f	\N	\N
a78bbb82-f6f0-4c47-996d-d5010d340170	pool-rewards	0	{"epochNo": 9}	completed	1000000	0	30	f	2024-01-18 09:46:57.637458+00	2024-01-18 09:46:58.403467+00	9	\N	00:15:00	2024-01-18 09:46:57.637458+00	2024-01-18 09:46:58.55303+00	2024-02-01 09:46:57.637458+00	f	\N	11043
072a1f13-5c28-40e6-9003-676f04785107	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:47:01.297061+00	2024-01-18 09:47:02.31092+00	\N	2024-01-18 09:47:00	00:15:00	2024-01-18 09:46:02.297061+00	2024-01-18 09:47:02.324168+00	2024-01-18 09:48:01.297061+00	f	\N	\N
bc19de8b-7a11-4e9e-9975-56a378bb68f2	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:29:01.881473+00	2024-01-18 09:29:01.894447+00	\N	2024-01-18 09:29:00	00:15:00	2024-01-18 09:28:01.881473+00	2024-01-18 09:29:01.911478+00	2024-01-18 09:30:01.881473+00	f	\N	\N
6a78e013-a503-4e61-a3b0-2bea00cc8045	pool-metadata	0	{"poolId": "pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "12460000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.734934+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.734934+00	2024-01-18 09:21:01.760514+00	2024-02-01 09:20:27.734934+00	f	\N	1246
f3205cbb-ccdd-41f5-a6ad-b208e3c27dab	pool-metadata	0	{"poolId": "pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "11040000000000"}	completed	1000000	0	21600	f	2024-01-18 09:20:27.700531+00	2024-01-18 09:21:01.701709+00	\N	\N	00:15:00	2024-01-18 09:20:27.700531+00	2024-01-18 09:21:01.768143+00	2024-02-01 09:20:27.700531+00	f	\N	1104
3197d7b3-950c-492f-9240-7f8b1dbaa544	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:29:01.710671+00	2024-01-18 09:30:01.700739+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:27:01.710671+00	2024-01-18 09:30:01.707232+00	2024-01-18 09:37:01.710671+00	f	\N	\N
a035666e-c080-4922-b53b-63fc8a25ff56	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:48:01.320432+00	2024-01-18 09:48:02.331003+00	\N	2024-01-18 09:48:00	00:15:00	2024-01-18 09:47:02.320432+00	2024-01-18 09:48:02.340875+00	2024-01-18 09:49:01.320432+00	f	\N	\N
15020864-65c0-4eaa-bf22-64e71effc641	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:22:01.709236+00	2024-01-18 09:22:01.716872+00	\N	2024-01-18 09:22:00	00:15:00	2024-01-18 09:21:05.709236+00	2024-01-18 09:22:01.733946+00	2024-01-18 09:23:01.709236+00	f	\N	\N
1c62a83b-1345-4af2-b255-7a0c2ff7fa82	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:49:01.339238+00	2024-01-18 09:49:02.351443+00	\N	2024-01-18 09:49:00	00:15:00	2024-01-18 09:48:02.339238+00	2024-01-18 09:49:02.36482+00	2024-01-18 09:50:01.339238+00	f	\N	\N
9b1fd6dd-f242-4c31-b421-0774890d2082	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:23:01.730989+00	2024-01-18 09:23:01.742132+00	\N	2024-01-18 09:23:00	00:15:00	2024-01-18 09:22:01.730989+00	2024-01-18 09:23:01.749982+00	2024-01-18 09:24:01.730989+00	f	\N	\N
ec266d14-5a45-4a41-8830-99a9e259cf46	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:32:01.952711+00	2024-01-18 09:32:01.968407+00	\N	2024-01-18 09:32:00	00:15:00	2024-01-18 09:31:01.952711+00	2024-01-18 09:32:01.979783+00	2024-01-18 09:33:01.952711+00	f	\N	\N
f277daa7-119b-42a5-a5d6-39e22b9afea4	pool-rewards	0	{"epochNo": 2}	completed	1000000	0	30	f	2024-01-18 09:23:29.211031+00	2024-01-18 09:23:29.786422+00	2	\N	00:15:00	2024-01-18 09:23:29.211031+00	2024-01-18 09:23:29.935986+00	2024-02-01 09:23:29.211031+00	f	\N	4001
3f78c941-b4d8-46a1-a604-3369fcd1b511	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:32:01.709402+00	2024-01-18 09:33:01.703692+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:30:01.709402+00	2024-01-18 09:33:01.716831+00	2024-01-18 09:40:01.709402+00	f	\N	\N
8f11e5fe-499c-420f-b659-7e43cf6dc027	pool-rewards	0	{"epochNo": 10}	completed	1000000	0	30	f	2024-01-18 09:50:09.639103+00	2024-01-18 09:50:10.4614+00	10	\N	00:15:00	2024-01-18 09:50:09.639103+00	2024-01-18 09:50:10.617385+00	2024-02-01 09:50:09.639103+00	f	\N	12003
e5d04e62-07b8-40ba-8a6d-50f8185750c8	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:24:01.74794+00	2024-01-18 09:24:01.766723+00	\N	2024-01-18 09:24:00	00:15:00	2024-01-18 09:23:01.74794+00	2024-01-18 09:24:01.779719+00	2024-01-18 09:25:01.74794+00	f	\N	\N
b0329abc-7d79-4a08-ac65-27ea924171f1	pool-rewards	0	{"epochNo": 5}	completed	1000000	0	30	f	2024-01-18 09:33:30.813354+00	2024-01-18 09:33:32.063818+00	5	\N	00:15:00	2024-01-18 09:33:30.813354+00	2024-01-18 09:33:32.199585+00	2024-02-01 09:33:30.813354+00	f	\N	7009
e772093e-da34-44e3-8f82-d9c52a2f8708	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:25:01.776793+00	2024-01-18 09:25:01.797275+00	\N	2024-01-18 09:25:00	00:15:00	2024-01-18 09:24:01.776793+00	2024-01-18 09:25:01.807252+00	2024-01-18 09:26:01.776793+00	f	\N	\N
47a35e75-ed41-4888-8bf1-cc974f6e50f5	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:26:01.804759+00	2024-01-18 09:26:01.821774+00	\N	2024-01-18 09:26:00	00:15:00	2024-01-18 09:25:01.804759+00	2024-01-18 09:26:01.83388+00	2024-01-18 09:27:01.804759+00	f	\N	\N
d36399cd-7478-436d-8373-0897412ad4b2	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:36:01.058709+00	2024-01-18 09:36:02.062253+00	\N	2024-01-18 09:36:00	00:15:00	2024-01-18 09:35:02.058709+00	2024-01-18 09:36:02.076759+00	2024-01-18 09:37:01.058709+00	f	\N	\N
6872171e-2e41-4d2b-a0e3-e15b0a12af59	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:53:01.412019+00	2024-01-18 09:53:02.418661+00	\N	2024-01-18 09:53:00	00:15:00	2024-01-18 09:52:02.412019+00	2024-01-18 09:53:02.429867+00	2024-01-18 09:54:01.412019+00	f	\N	\N
91d38e0a-f9dc-44ff-91d9-81c2357f3cab	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2024-01-18 09:26:51.432937+00	2024-01-18 09:26:51.869518+00	3	\N	00:15:00	2024-01-18 09:26:51.432937+00	2024-01-18 09:26:52.009737+00	2024-02-01 09:26:51.432937+00	f	\N	5012
17558fa9-69be-4b43-8085-0d67d788c8bb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:26:01.708289+00	2024-01-18 09:27:01.695654+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:24:01.708289+00	2024-01-18 09:27:01.707749+00	2024-01-18 09:34:01.708289+00	f	\N	\N
cfaab400-d671-4d82-90a3-dbfeb2f0266c	pool-rewards	0	{"epochNo": 6}	completed	1000000	0	30	f	2024-01-18 09:36:49.436632+00	2024-01-18 09:36:50.152799+00	6	\N	00:15:00	2024-01-18 09:36:49.436632+00	2024-01-18 09:36:50.291201+00	2024-02-01 09:36:49.436632+00	f	\N	8002
5a2e956e-f5c9-44ec-945c-682835c56ee8	pool-rewards	0	{"epochNo": 11}	completed	1000000	0	30	f	2024-01-18 09:53:31.234616+00	2024-01-18 09:53:32.524733+00	11	\N	00:15:00	2024-01-18 09:53:31.234616+00	2024-01-18 09:53:32.684928+00	2024-02-01 09:53:31.234616+00	f	\N	13011
17c525ee-5b51-4a7b-b374-a6db10549d61	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:27:01.830358+00	2024-01-18 09:27:01.844407+00	\N	2024-01-18 09:27:00	00:15:00	2024-01-18 09:26:01.830358+00	2024-01-18 09:27:01.856451+00	2024-01-18 09:28:01.830358+00	f	\N	\N
d59061fa-8339-46d1-af2f-8fc405d855ce	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:54:01.428072+00	2024-01-18 09:54:02.434559+00	\N	2024-01-18 09:54:00	00:15:00	2024-01-18 09:53:02.428072+00	2024-01-18 09:54:02.45163+00	2024-01-18 09:55:01.428072+00	f	\N	\N
497c3784-d8a0-4a85-b7d2-d1daf2ee5410	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:28:01.853138+00	2024-01-18 09:28:01.871344+00	\N	2024-01-18 09:28:00	00:15:00	2024-01-18 09:27:01.853138+00	2024-01-18 09:28:01.883249+00	2024-01-18 09:29:01.853138+00	f	\N	\N
4cfc90a8-9e84-4da3-b8c9-d16c92f8faa0	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:38:01.09444+00	2024-01-18 09:38:02.10615+00	\N	2024-01-18 09:38:00	00:15:00	2024-01-18 09:37:02.09444+00	2024-01-18 09:38:02.120367+00	2024-01-18 09:39:01.09444+00	f	\N	\N
2a9649bd-53bf-404a-9b9f-70e4ec9ec603	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:38:01.723538+00	2024-01-18 09:39:01.712585+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:36:01.723538+00	2024-01-18 09:39:01.726296+00	2024-01-18 09:46:01.723538+00	f	\N	\N
6491dfea-f4b3-495e-8c3b-4ce3d901dd68	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:55:01.449001+00	2024-01-18 09:55:02.452192+00	\N	2024-01-18 09:55:00	00:15:00	2024-01-18 09:54:02.449001+00	2024-01-18 09:55:02.462715+00	2024-01-18 09:56:01.449001+00	f	\N	\N
4b041e03-a098-497f-98c7-2eee194cbc41	pool-rewards	0	{"epochNo": 7}	completed	1000000	0	30	f	2024-01-18 09:40:12.225958+00	2024-01-18 09:40:12.242733+00	7	\N	00:15:00	2024-01-18 09:40:12.225958+00	2024-01-18 09:40:12.372084+00	2024-02-01 09:40:12.225958+00	f	\N	9016
a9e33525-b07c-47d7-b75e-f652f15aa08e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:56:01.461159+00	2024-01-18 09:56:02.473663+00	\N	2024-01-18 09:56:00	00:15:00	2024-01-18 09:55:02.461159+00	2024-01-18 09:56:02.482576+00	2024-01-18 09:57:01.461159+00	f	\N	\N
5b9e2f36-a004-455b-84f9-6d90afb81246	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:43:01.212139+00	2024-01-18 09:43:02.222078+00	\N	2024-01-18 09:43:00	00:15:00	2024-01-18 09:42:02.212139+00	2024-01-18 09:43:02.233817+00	2024-01-18 09:44:01.212139+00	f	\N	\N
4180f54f-ac79-467d-b7ca-24204376a90c	pool-metrics	0	{"slot": 9926}	completed	0	0	0	f	2024-01-18 09:43:14.218046+00	2024-01-18 09:43:14.312335+00	\N	\N	00:15:00	2024-01-18 09:43:14.218046+00	2024-01-18 09:43:14.516959+00	2024-02-01 09:43:14.218046+00	f	\N	9926
adaa5299-3e2c-4c78-9822-2b6ea6ee69d1	pool-rewards	0	{"epochNo": 12}	completed	1000000	0	30	f	2024-01-18 09:56:51.63809+00	2024-01-18 09:56:52.607258+00	12	\N	00:15:00	2024-01-18 09:56:51.63809+00	2024-01-18 09:56:52.727552+00	2024-02-01 09:56:51.63809+00	f	\N	14013
c0da0865-081a-430e-b9c5-3dd266c30a8c	pool-rewards	0	{"epochNo": 8}	completed	1000000	0	30	f	2024-01-18 09:43:29.82843+00	2024-01-18 09:43:30.320446+00	8	\N	00:15:00	2024-01-18 09:43:29.82843+00	2024-01-18 09:43:30.47837+00	2024-02-01 09:43:29.82843+00	f	\N	10004
2461b4f4-8cf2-4f2a-a553-9143e1b5b0ad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:56:01.737242+00	2024-01-18 09:57:01.727902+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:54:01.737242+00	2024-01-18 09:57:01.736873+00	2024-01-18 10:04:01.737242+00	f	\N	\N
72ff70ca-0793-4a50-a2a9-eaa81bc5a9cb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:44:01.728602+00	2024-01-18 09:45:01.718098+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:42:01.728602+00	2024-01-18 09:45:01.731687+00	2024-01-18 09:52:01.728602+00	f	\N	\N
ad99d3f8-430c-4d33-b0b7-b259dabea09c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:45:01.249731+00	2024-01-18 09:45:02.261984+00	\N	2024-01-18 09:45:00	00:15:00	2024-01-18 09:44:02.249731+00	2024-01-18 09:45:02.274257+00	2024-01-18 09:46:01.249731+00	f	\N	\N
3299312c-943c-468e-82f8-d0afbb070bef	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:57:01.480732+00	2024-01-18 09:57:02.490526+00	\N	2024-01-18 09:57:00	00:15:00	2024-01-18 09:56:02.480732+00	2024-01-18 09:57:02.504874+00	2024-01-18 09:58:01.480732+00	f	\N	\N
90bb0a7c-1174-4986-9aee-89de48c9a214	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:46:01.271151+00	2024-01-18 09:46:02.289767+00	\N	2024-01-18 09:46:00	00:15:00	2024-01-18 09:45:02.271151+00	2024-01-18 09:46:02.298798+00	2024-01-18 09:47:01.271151+00	f	\N	\N
58a57e36-62f0-4f3e-a02f-7de5518dac7e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:58:01.501909+00	2024-01-18 09:58:02.510822+00	\N	2024-01-18 09:58:00	00:15:00	2024-01-18 09:57:02.501909+00	2024-01-18 09:58:02.522903+00	2024-01-18 09:59:01.501909+00	f	\N	\N
cea1e69a-ae55-42c6-a949-c1453b4dc00a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 09:59:01.738976+00	2024-01-18 10:00:01.730147+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 09:57:01.738976+00	2024-01-18 10:00:01.737449+00	2024-01-18 10:07:01.738976+00	f	\N	\N
485fc2a5-b5ef-4646-bc73-fe704ea29847	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:00:01.540465+00	2024-01-18 10:00:02.548891+00	\N	2024-01-18 10:00:00	00:15:00	2024-01-18 09:59:02.540465+00	2024-01-18 10:00:02.554318+00	2024-01-18 10:01:01.540465+00	f	\N	\N
c0c6e1be-5075-4ca4-8f4b-5d7e21b4280d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 09:59:01.520796+00	2024-01-18 09:59:02.532182+00	\N	2024-01-18 09:59:00	00:15:00	2024-01-18 09:58:02.520796+00	2024-01-18 09:59:02.543637+00	2024-01-18 10:00:01.520796+00	f	\N	\N
609f3f2e-8b44-4d58-b3da-70a02d0dda8a	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:08:01.679459+00	2024-01-18 10:08:02.696678+00	\N	2024-01-18 10:08:00	00:15:00	2024-01-18 10:07:02.679459+00	2024-01-18 10:08:02.704033+00	2024-01-18 10:09:01.679459+00	f	\N	\N
1263d202-78f4-47a9-81ff-bbbed8dfa40e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:31:01.165731+00	2024-01-18 10:31:03.171594+00	\N	2024-01-18 10:31:00	00:15:00	2024-01-18 10:30:03.165731+00	2024-01-18 10:31:03.184881+00	2024-01-18 10:32:01.165731+00	f	\N	\N
d0261f57-c1b3-4288-a301-d5d44d727189	__pgboss__cron	0	\N	created	2	0	0	f	2024-01-18 10:33:01.20404+00	\N	\N	2024-01-18 10:33:00	00:15:00	2024-01-18 10:32:03.20404+00	\N	2024-01-18 10:34:01.20404+00	f	\N	\N
b9f21071-f1e6-48ac-97ed-40c5e0553066	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:01:01.552568+00	2024-01-18 10:01:02.568841+00	\N	2024-01-18 10:01:00	00:15:00	2024-01-18 10:00:02.552568+00	2024-01-18 10:01:02.586238+00	2024-01-18 10:02:01.552568+00	f	\N	\N
c519282d-c734-45d6-8752-84da73dba10d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:32:01.181617+00	2024-01-18 10:32:03.196243+00	\N	2024-01-18 10:32:00	00:15:00	2024-01-18 10:31:03.181617+00	2024-01-18 10:32:03.207231+00	2024-01-18 10:33:01.181617+00	f	\N	\N
39432e4c-7441-4956-9674-e5d01d3c7756	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:02:01.581704+00	2024-01-18 10:02:02.59057+00	\N	2024-01-18 10:02:00	00:15:00	2024-01-18 10:01:02.581704+00	2024-01-18 10:02:02.598812+00	2024-01-18 10:03:01.581704+00	f	\N	\N
6d0e19c0-fca6-4759-b694-3bc8ea25c4ca	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:11:01.745393+00	2024-01-18 10:11:02.760705+00	\N	2024-01-18 10:11:00	00:15:00	2024-01-18 10:10:02.745393+00	2024-01-18 10:11:02.769312+00	2024-01-18 10:12:01.745393+00	f	\N	\N
d139c292-e66c-4217-a9bb-00f85ec75594	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:02:01.739967+00	2024-01-18 10:03:01.732399+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:00:01.739967+00	2024-01-18 10:03:01.737671+00	2024-01-18 10:10:01.739967+00	f	\N	\N
e2d8c370-7472-421e-9762-c219aeadca6c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:03:01.59645+00	2024-01-18 10:03:02.607068+00	\N	2024-01-18 10:03:00	00:15:00	2024-01-18 10:02:02.59645+00	2024-01-18 10:03:02.615994+00	2024-01-18 10:04:01.59645+00	f	\N	\N
64c27b8f-42e7-4cdb-874f-3a030334d7ff	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:11:01.750113+00	2024-01-18 10:12:01.739611+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:09:01.750113+00	2024-01-18 10:12:01.747585+00	2024-01-18 10:19:01.750113+00	f	\N	\N
ab5ae2f2-af3b-41e1-ae54-aabd6857ac05	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:06:01.639634+00	2024-01-18 10:06:02.652485+00	\N	2024-01-18 10:06:00	00:15:00	2024-01-18 10:05:02.639634+00	2024-01-18 10:06:02.665951+00	2024-01-18 10:07:01.639634+00	f	\N	\N
485a6a6c-4db1-4397-b4bc-a306f2fe8083	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:12:01.767769+00	2024-01-18 10:12:02.784325+00	\N	2024-01-18 10:12:00	00:15:00	2024-01-18 10:11:02.767769+00	2024-01-18 10:12:02.793765+00	2024-01-18 10:13:01.767769+00	f	\N	\N
4518e42f-a661-4c4c-bad7-7acb34686f25	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:14:01.814961+00	2024-01-18 10:14:02.825207+00	\N	2024-01-18 10:14:00	00:15:00	2024-01-18 10:13:02.814961+00	2024-01-18 10:14:02.839918+00	2024-01-18 10:15:01.814961+00	f	\N	\N
54821a76-19e0-409b-9b23-af01eba7b699	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:16:01.85286+00	2024-01-18 10:16:02.859646+00	\N	2024-01-18 10:16:00	00:15:00	2024-01-18 10:15:02.85286+00	2024-01-18 10:16:02.865065+00	2024-01-18 10:17:01.85286+00	f	\N	\N
d4235bec-505e-4d3a-85b7-e00d50418e0e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:17:01.863486+00	2024-01-18 10:17:02.881485+00	\N	2024-01-18 10:17:00	00:15:00	2024-01-18 10:16:02.863486+00	2024-01-18 10:17:02.888008+00	2024-01-18 10:18:01.863486+00	f	\N	\N
a34c05de-ed3f-4a11-ab07-b83654455687	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:20:01.925113+00	2024-01-18 10:20:02.941829+00	\N	2024-01-18 10:20:00	00:15:00	2024-01-18 10:19:02.925113+00	2024-01-18 10:20:02.949836+00	2024-01-18 10:21:01.925113+00	f	\N	\N
eb88c485-658c-430e-833c-1fbf37dd984c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:20:01.75786+00	2024-01-18 10:21:01.745735+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:18:01.75786+00	2024-01-18 10:21:01.750974+00	2024-01-18 10:28:01.75786+00	f	\N	\N
c452a826-9216-4708-b737-e8a6fc3c347d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:23:01.984662+00	2024-01-18 10:23:03.003554+00	\N	2024-01-18 10:23:00	00:15:00	2024-01-18 10:22:02.984662+00	2024-01-18 10:23:03.012043+00	2024-01-18 10:24:01.984662+00	f	\N	\N
923ae135-0e08-4c3c-b514-b046ced75bb9	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:24:01.009961+00	2024-01-18 10:24:03.016138+00	\N	2024-01-18 10:24:00	00:15:00	2024-01-18 10:23:03.009961+00	2024-01-18 10:24:03.028556+00	2024-01-18 10:25:01.009961+00	f	\N	\N
db01ed17-ffd6-4a21-b2de-b611aa9adf23	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:25:01.026095+00	2024-01-18 10:25:03.039985+00	\N	2024-01-18 10:25:00	00:15:00	2024-01-18 10:24:03.026095+00	2024-01-18 10:25:03.053018+00	2024-01-18 10:26:01.026095+00	f	\N	\N
696a5cdf-20e0-49e8-8674-4705915c506e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:26:01.762563+00	2024-01-18 10:27:01.748847+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:24:01.762563+00	2024-01-18 10:27:01.762963+00	2024-01-18 10:34:01.762563+00	f	\N	\N
072a8c5e-157c-4c1d-a2fd-fee8a2246d95	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:27:01.071439+00	2024-01-18 10:27:03.083344+00	\N	2024-01-18 10:27:00	00:15:00	2024-01-18 10:26:03.071439+00	2024-01-18 10:27:03.09662+00	2024-01-18 10:28:01.071439+00	f	\N	\N
f6733389-7021-4035-9c46-7320a2c210c0	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:28:01.09355+00	2024-01-18 10:28:03.105195+00	\N	2024-01-18 10:28:00	00:15:00	2024-01-18 10:27:03.09355+00	2024-01-18 10:28:03.121078+00	2024-01-18 10:29:01.09355+00	f	\N	\N
f40248fc-a418-427a-95bc-f4d04d4fbef5	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:29:01.117819+00	2024-01-18 10:29:03.12989+00	\N	2024-01-18 10:29:00	00:15:00	2024-01-18 10:28:03.117819+00	2024-01-18 10:29:03.141478+00	2024-01-18 10:30:01.117819+00	f	\N	\N
2204b75d-6832-4d26-9e88-93f744e3f9d4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:29:01.766501+00	2024-01-18 10:30:01.751059+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:27:01.766501+00	2024-01-18 10:30:01.762761+00	2024-01-18 10:37:01.766501+00	f	\N	\N
0bf2c43c-d0cf-4a8a-922a-9c487eae2ee3	pool-rewards	0	{"epochNo": 13}	completed	1000000	0	30	f	2024-01-18 10:00:11.037886+00	2024-01-18 10:00:12.698317+00	13	\N	00:15:00	2024-01-18 10:00:11.037886+00	2024-01-18 10:00:12.820917+00	2024-02-01 10:00:11.037886+00	f	\N	15010
da886187-3d32-48cb-bc8a-fe0f9ff3daa0	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:10:01.725999+00	2024-01-18 10:10:02.733263+00	\N	2024-01-18 10:10:00	00:15:00	2024-01-18 10:09:02.725999+00	2024-01-18 10:10:02.750017+00	2024-01-18 10:11:01.725999+00	f	\N	\N
3e28e37e-9a0b-4e33-8c14-aba4e7f4f923	pool-rewards	0	{"epochNo": 14}	completed	1000000	0	30	f	2024-01-18 10:03:32.21547+00	2024-01-18 10:03:32.769129+00	14	\N	00:15:00	2024-01-18 10:03:32.21547+00	2024-01-18 10:03:32.945226+00	2024-02-01 10:03:32.21547+00	f	\N	16016
1d9d00db-ab29-4749-a545-f52bf720eb3a	pool-rewards	0	{"epochNo": 15}	completed	1000000	0	30	f	2024-01-18 10:06:52.012525+00	2024-01-18 10:06:52.855098+00	15	\N	00:15:00	2024-01-18 10:06:52.012525+00	2024-01-18 10:06:52.977672+00	2024-02-01 10:06:52.012525+00	f	\N	17015
8221d048-0924-485d-9ed5-04c2f1ab496b	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:13:01.791747+00	2024-01-18 10:13:02.804736+00	\N	2024-01-18 10:13:00	00:15:00	2024-01-18 10:12:02.791747+00	2024-01-18 10:13:02.817811+00	2024-01-18 10:14:01.791747+00	f	\N	\N
92aae7f9-afa9-454c-9421-82a0d2be6e9d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:14:01.749671+00	2024-01-18 10:15:01.741895+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:12:01.749671+00	2024-01-18 10:15:01.749656+00	2024-01-18 10:22:01.749671+00	f	\N	\N
9b118cdb-aa38-4b3e-a75a-8e0a62d4f4c5	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:15:01.837834+00	2024-01-18 10:15:02.843397+00	\N	2024-01-18 10:15:00	00:15:00	2024-01-18 10:14:02.837834+00	2024-01-18 10:15:02.85458+00	2024-01-18 10:16:01.837834+00	f	\N	\N
6f40258c-ba60-485b-8e6d-db111e698127	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:17:01.752176+00	2024-01-18 10:18:01.744312+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:15:01.752176+00	2024-01-18 10:18:01.755772+00	2024-01-18 10:25:01.752176+00	f	\N	\N
6d343c6a-bde2-47dd-a8e6-01a8bbca0688	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:18:01.886388+00	2024-01-18 10:18:02.903276+00	\N	2024-01-18 10:18:00	00:15:00	2024-01-18 10:17:02.886388+00	2024-01-18 10:18:02.912195+00	2024-01-18 10:19:01.886388+00	f	\N	\N
d59df173-6d0f-4d6e-8941-9442c00a0bff	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:19:01.909732+00	2024-01-18 10:19:02.919425+00	\N	2024-01-18 10:19:00	00:15:00	2024-01-18 10:18:02.909732+00	2024-01-18 10:19:02.926996+00	2024-01-18 10:20:01.909732+00	f	\N	\N
8aa0ae02-97a1-454d-adf9-42352b166f4b	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:21:01.947806+00	2024-01-18 10:21:02.963734+00	\N	2024-01-18 10:21:00	00:15:00	2024-01-18 10:20:02.947806+00	2024-01-18 10:21:02.971818+00	2024-01-18 10:22:01.947806+00	f	\N	\N
7bdcd57d-0f0c-49cc-a884-d89885f15e88	pool-rewards	0	{"epochNo": 20}	completed	1000000	0	30	f	2024-01-18 10:23:29.0246+00	2024-01-18 10:23:29.265347+00	20	\N	00:15:00	2024-01-18 10:23:29.0246+00	2024-01-18 10:23:29.364528+00	2024-02-01 10:23:29.0246+00	f	\N	22000
ef78eb1a-f8d1-4c6a-a7a3-22a9972808cd	pool-rewards	0	{"epochNo": 21}	completed	1000000	0	30	f	2024-01-18 10:26:49.620781+00	2024-01-18 10:26:51.356172+00	21	\N	00:15:00	2024-01-18 10:26:49.620781+00	2024-01-18 10:26:51.483818+00	2024-02-01 10:26:49.620781+00	f	\N	23003
0bf8e778-8307-419e-a319-15b880b9a800	pool-rewards	0	{"epochNo": 22}	completed	1000000	0	30	f	2024-01-18 10:30:09.027753+00	2024-01-18 10:30:09.444308+00	22	\N	00:15:00	2024-01-18 10:30:09.027753+00	2024-01-18 10:30:09.566925+00	2024-02-01 10:30:09.027753+00	f	\N	24000
19ba7c12-856e-4343-bb6c-d59adcd4279a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:08:01.744338+00	2024-01-18 10:09:01.73769+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:06:01.744338+00	2024-01-18 10:09:01.74799+00	2024-01-18 10:16:01.744338+00	f	\N	\N
217faa6b-d609-430c-a2b8-aca6c3f17fa4	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:04:01.613982+00	2024-01-18 10:04:02.623386+00	\N	2024-01-18 10:04:00	00:15:00	2024-01-18 10:03:02.613982+00	2024-01-18 10:04:02.636233+00	2024-01-18 10:05:01.613982+00	f	\N	\N
5238a5fa-f714-4159-adc8-5e2a50f5eb46	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:05:01.633584+00	2024-01-18 10:05:02.635311+00	\N	2024-01-18 10:05:00	00:15:00	2024-01-18 10:04:02.633584+00	2024-01-18 10:05:02.6418+00	2024-01-18 10:06:01.633584+00	f	\N	\N
f138334d-9562-4b46-9df0-daa2cdc37027	pool-rewards	0	{"epochNo": 16}	completed	1000000	0	30	f	2024-01-18 10:10:09.219771+00	2024-01-18 10:10:10.924162+00	16	\N	00:15:00	2024-01-18 10:10:09.219771+00	2024-01-18 10:10:11.057894+00	2024-02-01 10:10:09.219771+00	f	\N	18001
2ea73764-8707-4ed8-9af3-09ddaa012a17	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:05:01.73918+00	2024-01-18 10:06:01.735474+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:03:01.73918+00	2024-01-18 10:06:01.742133+00	2024-01-18 10:13:01.73918+00	f	\N	\N
ccb01348-f3be-4026-a187-ea36a0f10cda	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:07:01.66207+00	2024-01-18 10:07:02.674362+00	\N	2024-01-18 10:07:00	00:15:00	2024-01-18 10:06:02.66207+00	2024-01-18 10:07:02.681873+00	2024-01-18 10:08:01.66207+00	f	\N	\N
867266d9-6a07-42c8-8d09-f77669a1a126	pool-rewards	0	{"epochNo": 17}	completed	1000000	0	30	f	2024-01-18 10:13:29.420626+00	2024-01-18 10:13:31.0027+00	17	\N	00:15:00	2024-01-18 10:13:29.420626+00	2024-01-18 10:13:31.193939+00	2024-02-01 10:13:29.420626+00	f	\N	19002
89dafb08-305e-4a17-abf0-cca6b764086b	pool-rewards	0	{"epochNo": 18}	completed	1000000	0	30	f	2024-01-18 10:16:51.419479+00	2024-01-18 10:16:53.080984+00	18	\N	00:15:00	2024-01-18 10:16:51.419479+00	2024-01-18 10:16:53.201503+00	2024-02-01 10:16:51.419479+00	f	\N	20012
e3a6866f-1bbc-4ecd-846a-236a753dc377	pool-metrics	0	{"slot": 20442}	completed	0	0	0	f	2024-01-18 10:18:17.4082+00	2024-01-18 10:18:19.12034+00	\N	\N	00:15:00	2024-01-18 10:18:17.4082+00	2024-01-18 10:18:19.279449+00	2024-02-01 10:18:17.4082+00	f	\N	20442
f9f8860d-bb32-49ab-b119-9a4c3ff7f093	pool-rewards	0	{"epochNo": 19}	completed	1000000	0	30	f	2024-01-18 10:20:11.8414+00	2024-01-18 10:20:13.178126+00	19	\N	00:15:00	2024-01-18 10:20:11.8414+00	2024-01-18 10:20:13.312376+00	2024-02-01 10:20:11.8414+00	f	\N	21014
e04e59a3-bfae-42f8-a237-4989854a92bd	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:22:01.969974+00	2024-01-18 10:22:02.979014+00	\N	2024-01-18 10:22:00	00:15:00	2024-01-18 10:21:02.969974+00	2024-01-18 10:22:02.986894+00	2024-01-18 10:23:01.969974+00	f	\N	\N
1e35618f-abfd-4268-a78b-d6ab5638eb7c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-18 10:23:01.753241+00	2024-01-18 10:24:01.748022+00	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:21:01.753241+00	2024-01-18 10:24:01.759196+00	2024-01-18 10:31:01.753241+00	f	\N	\N
f9201249-fee6-49c4-89e6-dcfe11e73bc1	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:26:01.049886+00	2024-01-18 10:26:03.061567+00	\N	2024-01-18 10:26:00	00:15:00	2024-01-18 10:25:03.049886+00	2024-01-18 10:26:03.07382+00	2024-01-18 10:27:01.049886+00	f	\N	\N
8aefe0b3-9226-482f-968c-f7ccd8728c4f	__pgboss__maintenance	0	\N	created	0	0	0	f	2024-01-18 10:32:01.765803+00	\N	__pgboss__maintenance	\N	00:15:00	2024-01-18 10:30:01.765803+00	\N	2024-01-18 10:40:01.765803+00	f	\N	\N
6b17430f-8a83-4b3f-b38b-13643b697c08	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-18 10:30:01.138928+00	2024-01-18 10:30:03.154864+00	\N	2024-01-18 10:30:00	00:15:00	2024-01-18 10:29:03.138928+00	2024-01-18 10:30:03.169265+00	2024-01-18 10:31:01.138928+00	f	\N	\N
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
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
20	2024-01-18 10:30:01.761286+00	2024-01-18 10:32:03.200896+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	f7324241be49e999113f17949e27227637a9bb5bd04c6571afbb910b4fa8d786	57
1	11258d2d91ed660e216df5db6130689ff9b192d6ac20c74e96e25cef2facadae	61
2	969fdec886c171018b5f722930986e7de3a97cc4daae5e5283491a84cb91213e	89
3	95744d51b63bd8363d8b8f9d68a5209c37754e0ff4b479e4cbd1a06046fbc5bb	95
4	a1916d588afbbb11a4fb96a395fefff937bd3c8eb30ab78bf3542f99eb6f9dd6	105
5	84b5e6cb3351b05f64a12afea4baf23264dfec04bb0c01ecb35fcae628c61061	107
6	784551f2f840a254e72610d442785f935c1c0ea69a3e334b7976ac5aad665456	109
7	76073d44f7f0bc2f9b85477fa1480eafcdb96dfa873bfa91b3c586806bf1bfc2	122
8	d141adff32afd438c8970900451d8f88642c8e8d1958a9511c60d7a7a7cfd2d8	125
9	0d3f20649c87bac9f2b31a3297acc47f3456fe7b43e209cf803a69f4db3e99cb	129
10	8646bcce2ce2555cf0e0fa86ebffaf3a71e8b8c5f0b21fb42b431b73a03fb766	132
11	166bbca00262151deb3f6bc034da9f50ef8c5bfad241b8d3f58a0db947504fd7	152
12	86632b4aa508dc7b79e07da0490c7125903d74831324529b76b158e513b318ba	163
13	f35965db88e24691d54d49e8ead0ad5e2e4bb42c58886c184bc4ed5315478fbe	169
14	fb2baff4d143c5043451293a7b037c0e959b7911e17df6fe5031ebc6a8b870a6	210
15	ec38101849e99cf919a5401fa2002c0bb3af8a957f2b34b8a0d2c70cc84ac5fc	230
16	fd4a48cfa8f32ef238e90ddee6f43c7b971b1de145690a3db90e0f758d2d9181	235
17	140eebf4741c74c8a246ff4f2419bc3e6240f7fa6e5c9568ff9e41311c6adf87	239
18	381ff42ba89132531e44a109d360e0032147756b74c5dfb67ddd817ceebf2727	245
19	8f215d87433f0a8f6607d03c800b5a05a73c8da773e527846bcf06dc5f8b5138	267
20	edbdce870481ed03b10b8dbe6c4221dc32ca673aa775e64843f1b38dce29995a	275
21	b262e32c1b5836efde98ac00ad50926826c617d4790e780160a3d17fcd7add0a	277
22	5a8e02b3cf44fdc152e323cc7fa5fc4479996325b59af6cda50673ad38f1686b	283
23	e1202de871f24e55eac5c7e04c7382caa9dd1e825f3e444af29d015b9be3fc83	285
24	8988c1ecdc7f5204306483799574122bf36d762161344e76cc4bf43246dbeb1a	315
25	c39e6c8a0f28d01e838f76fdb13f8f5d8beb59ec4c4880a513cdf77790c94608	319
26	9d99d4aade9c86b3f0686aeba027ffd0e6f7114e345b2e8252b5c1467beaf2d0	334
27	2864776a147f9e07dac3ae6c953f60011df483b42c7dae63aef62d368157d09f	350
28	d8ff6f36daffe92968f3b1fcd64994d8d3dc904a8abba3a1111565578101ea4d	351
29	9c1d16a1c6f6dcf52e824cffb7c64b60813855a7769270261ced70167cebb4a4	357
30	af156551f30d92acb83edde7461683a107563ba1d6a62682c66a97a792c0f75c	362
31	e2e3755cc76d9b11a89212e84524bb9d9b1efe20d5d4a8395a4a175f988c368d	373
32	822ca9c22fcd1f14e6d57bd19213fad241881e9d24c5edefe27619471bafdfa3	395
33	061609f4c17d3ad7b976a1a1635ae4adb1efcb5cd218fab0f17cf7828f3a1136	397
34	ccd37af19c6b7d81041681c9112466ea8cfe3400ffc302aea4e6f2ea2fe4f74e	399
35	9e51143629bdba384fc50280fa7364a92ed46a16f82a58cf5ddcc2359e420bfa	405
36	fc26d8f2232a940fc9535209416bda505b4610290653736019f550ab4717e6e1	410
37	bf405d2ae9c385c807732ca8a01fbdc000ca68a7a55b2e3d599d495a036cd379	432
38	1b171e7f30edf819cd7781ba5a84d47f1dc956a5574155ca107e34348fc8d02a	437
39	adc128e2c7c4756b99e8f360a8eea5da3424ceb2af12ea3843d9ce0757d82529	438
40	8b72435f26db915ce69ed0754d81e82ce019457177065feaed76ac027f742df7	442
41	f8d5b1f00355d0270cd20477bb067c168d19a41b761108d84c65f1130d49cc8b	443
42	11be6534a53d95e730bac7ba0db179d8cedc3ab693eac6c2603750c6d982a9e9	452
43	443ea89ff22d274ce468d6edb4bcab5685b29d9f9b7f3f3341a7937862bb4cdc	471
44	ce10375dad8a651bdd70529fd58ddbb633970390ff7a3af0b30e25f3f43d1f4f	476
45	fdb6e51a873d66399cfdbfdd43ef86288370cc12513e592ee66dd9eb4bafb129	479
46	2fef81b9d76d79292cba1e74ad286ff95559e2580bffb60d05f012b04c2db116	482
47	05473c1a2f0b716e85eade007643e6159cc5a84d63fe91f5095909d47f55550f	495
48	047b960f969804227be902fb1fb4241466e1a097779756415f42939d91b113bf	498
49	07410df9ca4f4ccbf353c24f24908d09fcdb4656d3025fc50aa7868e2430bd2a	522
50	00d360509c33f5fad67e4ec6bb8df7892ed07ce1e055616ce6167b53ea418a30	548
51	32d506e5fd2afa7fae6b5ea7ab35f80e3cb85b53186f034b66cb836554960720	559
52	3a3758bea606b467705966336299d4f2cd31872aad706708a7b29f0f33d80ced	561
53	cfe41e943169e679d011bf6a8b3c77f31864130b5c9b2d2e34c9f30ff55921a5	565
54	b4b1a66fcf2b222e1e3f6a3f2debb4ee1a8c29c7240663fb8e4cd26071d70a11	568
55	c9bb9594150db0d3f3d8e0e9b124df49226bb2e3e3024267a67351a6b2f0dcc5	569
56	f6c8f4846eaf78bf98757d8c3f34d37e29f358541673cf0cf53c05bfec3c471b	570
57	c66c8231d8c51c58aa396aff70f8520b17971667f26338e5989af68724bb337f	590
58	5ac84360600da6f398d213bbdeba3e9969feb2b7d51c6d83c3397e1597853872	591
59	0496eb31b0eb59065f449aee3b8b3256663bc3f8348585ccc9b4a2808ff1dcbd	598
60	6757ed06b64d5ae5c75641dcdc68c653b01df204b5145acba4de388d68c1fbe7	599
61	d9be8515736a3f6563a00a0f686a3d5900fe894193f857e6ac09659474d07322	623
62	ba4f643b10c251f071d43738531d52f3d2076a96e3961bc5516d9e19cbea2db7	624
63	7167570ccc60cdedd2e9407c59a804e83bc8ceee3f544cb93953e6f7806baae3	625
64	1b9cfe6cc2fecd7c8027b8d17e0b01a0d738577b274d41ff3455f185d8afd397	631
65	95f1ef9a904ecd3419dd36f0e508d0de39d2edd8ec291e7cedad08482de76e6e	636
66	8b5a6dbe708f0b48e2fa1b8cf9d828dd36135995ad1be7812549bdcb503d69fe	664
67	eaa7e27a03ddefaab620c97c6628530db86471f7c8c1a455788aa734a34c727c	666
68	d63910249473366c0f7b7d6f608e414663fcc10cd813ed10d68ee62bc0a7ad27	684
69	cd26ad70d68973bfb529ae3da995a9d089c26f50c32c7342d1c8fcc63fcde773	689
70	ba9df498a46a46964cae0b5fe740ec25d3784a17e39946223302e66cabfddd0f	698
71	a202db7cf109a9b7ee7413c63addf80f98dcb28ba5eb71d6638f5ba62896f038	704
72	e786b4c9c3517c9fd26c9c5f59546bf2e6ea02abfac039cd2a558c1bde04cd5b	712
73	de433515e284043afad8ab296cd021e76c7cb26ddbe674712dbca61072012ba3	723
74	d644d970c465627acd221cd65e31bb5212706edc50a202c0d6087fa1532e0e6b	730
75	1b1885e23ce4eb247631ee923aeff75c8962eb848343dc98c776a98c0e629290	738
76	1d4d6003e32bd4af5866c84a8ea94edc4c0ac04b232bf4505a71a77e862130cd	740
77	0d29e88b564daa7b7ecaff5c538a91a90045a6f329cfa19e2819c3e94bf20ff4	744
78	206a7abb9e3bd67dc429dff8c1a4bdbed2ba91ecf40bdaf48d8fa1a179d3667a	757
79	8e73cd181959db3b3330150668bde2024154c3d1dda8abdcd4dd37e0771b4cb0	760
80	fb16c9d4a777b347ba4acab452263c01681f86c58bedd5c70c848e0fc969bd0a	761
81	817d99fb0911b6ccb017d841986cb458a29fe3b04f5a0e239be0e79354c99c47	763
82	b0ce8f96d7b528ee1b2ce9d18b4329a56b1cde0b7c8f4b6f07c51ef104a08e8c	788
83	1e1e355a11014e31d79d552389b3ce8f2a5eb4eeb732f9583a375e91d70ab81c	793
84	cc54ae25821807f8e07f156ee396c175c549ed23f395e010b8f32a9265729af0	797
85	3d1fcfaaf832b9c4331516e3ddc59ca973477c20ba828b5806777222754cd9e5	827
86	47b50435733a856a8e0229ea4b14eef941f02cc997e9cbf3dffc85a0b7f57799	841
87	bb50c53d7b191da09ad4c4b00a0bb4cd81a6810997a54524022f2ec4fd2daf96	843
88	af1831fd55a60ce58c3fdc5dcbdace58c2399b6ab72d8f66f0cda35320fb84ad	844
89	fa45596d6932906f0a510242899aae57a4e514fe7b79115dbe7175a48f3115ec	856
90	f4ebb83a906309aadf1c4f97d92194244c4536bd8bd9680e5095a7919cc8772d	861
91	ec8b6c9ea338f072f42acda4f3d86cab481c36c6a909f2dcb7bfa482856b9ff7	864
92	556cf45701183081c95b29bbb7a2cef0ae1a6fd020a6619b5057da7bda46d41f	869
93	2fbbfb8f8b792973a99bda25d5531dc046f1bef73ea74585c815c8d077f949d4	882
94	56ab0591ea3fa60c8d4fb022c5fdb22c0b281ebfa2f41011ffb075d4331b3a9b	895
95	a7f12f506ffd3b128ef1a006992d559b7203450b2971c593e7ecda352a2b9888	898
96	6ff07d92f3b3934dd8516713bbf68c947bbdf4738166e0ca4b5e1591b102f59c	901
97	5dedb112d2c766fe37697c1f118b45403bbd4ba1c40694ee79a34e3d03377581	922
98	5375ff777f0d3bdba35b37906a0a9297ff3f5da3d18058e9f2e0d543d3aec3cb	927
99	f4f5974dfa7f4fcc8bfc648f82a8b14569be16b8d43c0705c8024b4995c4bdd5	930
100	ea9177bd1353f062595f2aa552a10af9a34f42a13c3b49502b0056c4a279086c	943
101	a6519a61c6ddc36736b78e50c4548f8b88e6fc635d5db39212ad178f2a92139b	961
102	0d4eca545f23a7c59f87a0e7f1a55805101cc8561760fc5aadbcffb3e9154bd1	968
103	893265a655c6c96ff1f3d7653e60c50827f81e4aeaca4debd941aef9914dc12e	970
104	7b3f5adea5b1d69b38257a3c93d4967932afd86bcb81f36070c4fa91a5f46194	977
105	52a6567a38f8c9734e557ab6db1289a2ea1b3579af4f1d6feb1732522a669f73	986
106	d0bc1dafbc3d120890040085be352640c84c343b39d58ca5d2810608aecab5ab	1001
107	558a6f3eb91645508df29e1e0ec4f2189070f6bcf0fa1a21903005ee8b407372	1011
108	fdd3c646b5248c8a94022dcd726b67f0e1d061d92878ebcc5ea02203917ac71a	1017
109	1be12ca228f676a61d60f0cb997021f9fc1b85ef97ee220b096a6da9773398d2	1021
110	5def1f38d0d539e727d14faa452c7ce2b69ffdd4c0f83a42e90fd73d7f52da8e	1026
111	77db64b8ee622d2f132b5b6d296d978d459bb2d551cdceafdd00c91b64fb8797	1034
112	f56460f78be9582927360b56bb5ee72b4de5683451469798e8d6eb6f60cf29c5	1043
113	8adefe8412d93f9e158de5584153c7211774becebc41e42f3cb5411a8cdc42c3	1057
114	70642a4d70d0b150d4308e1bb67a191b78a3f67b26809267d22d185804d62b2a	1060
115	f3c49bf33363af43f6a34817cf26d567d6982aed5f9c7357170038148fccea9f	1067
116	430dee604d283ce40415ee43e5d6f7c73ea0a911370e80e723bd05c28fb46679	1069
117	6a1993a763ac667c8a46f62177f0d8c5e70c438e616cd3134e82c346ad67cae4	1095
118	62830d5b7bac3c5bc59f9bbdb122727c72f9e05618449dafd18da4930813f213	1097
119	95c3260346cf95c6754c1ab304f385e4dc6ee2d7ed556c932bc706979093bfed	1104
120	ff1d48834c531cb3c551096581b2aab0f3da65699d507f068c3f75e3b5f285c6	1110
121	088771fe69e76d6a498befb6f14b020590b83a05477e3f17911e4ba531f1dcbb	1119
122	f6c9f2b5f52f1a4fed7c93825371e9836e839f5c123afda508d16050c70a7124	1127
123	d52e081829a4b9af00e1afa86c81463afc797ad0cbbeba39a4479b1072d6db16	1131
124	8115527132ffec932b5a442f4e804c1d5ccd8d3087559a18a725a71c851839b9	1141
125	82d970abfee1f453acfc2dbf65a564d1daf52999a97a60081983892d7cb3a65f	1143
126	00078baf97cc0ac48d83644313377cfb450233f851b4b2aa7a57e2e74215f681	1148
127	609b0fbc6b27bf0c33d07bc077735823a8f60e09fe259ef2be04d5abbb04cdf8	1186
128	ad4e319cee28be14de29d71bed7ab236431fbca5dd68a9d329e9d7d575c7d8f1	1210
129	a63ff032691497ee34720e1a04292a5167d0f9dd9237dfb5bc7a2ba4a6270ff7	1228
130	b9dc523e21a7c6c9109cf32ac805f81ba3699857c42886c0f844989bee1b5290	1246
131	0cdf271ed3b23786f9aa54106c07ab10dccfb9f2676afb225b73d52e1dea9fea	1260
132	3952094b2a674ac6b6e76ced390f8321ae02cec9d83ddc27cf45975d37b3679b	1272
133	642dcd3b47489902481b4ffb07f2e3bf2f60314e3b55b648cfb1f29ea330ede0	1296
134	f25ec308584fe6e99944e6bce973189cffca9081b8e9cc21643fb36d9eb6c191	1308
135	8e67d998387ab47297206db399dbc8b6e261c35f47f873301de5e434a24922cd	1324
136	83e2ac2cc62b39d1e66210e40f047370b56174b16b59b3eae8e8809c42f4262f	1325
137	26c5866d25e8f0986ccdbd95aad31f35f93e01082f51d318647e014365e0b0f5	1327
138	f00459051fa2eede59c5108463f63f7a477189e1cf077847f08ff9e48d2b7c8e	1337
139	820acdfd5c46ddecb99c269abfa005a23d71a47eda9c2f5f75505e9bb2b6297c	1341
140	3c5a41cf7fa05f7e262a35c76ec21c2abeab67d7e064f252cce1fc9b176fda3f	1345
141	21984656fef256cc13a6f342fd14fcfaab74700a88c5f162a04f202eaee06b41	1348
142	172d05647e726bfec74b5d4cd3879b16b2d1205165649ef0108e40cf113b66aa	1404
143	5a84a7a81fda1bf92b5f09bbcbaffaae1ca262f81c9faeb93f910cfcfbf02167	1405
144	31d614887e78b979386b5ce53af27a611d13055bc66e5ff1f37947e153bb0c12	1413
145	c1f6f7519f7126cd30e6eda712755a692bad377ba4fb7028ede11a4bf7b1107f	1414
146	668c99ab28990b0a07458c84fc4c99140606df64da016c2f06eb24230d187fa7	1422
147	7f2557907f0eaef518930d51d88a05a7c0b62f68dd22144fba2b772bf479db7a	1425
148	2cc5f473cdf5c5f71a9d06c5f7c23cc08a46741cafc0934d3cdd44e659513642	1426
149	79e445ac7bafb39c1e32a4dbe79accdadd7d3c1c439e8d5d4393382b94650747	1453
150	b762773f5cfd8f5a730258215e05d3f8f80f9e0718cda681171a25819aef58df	1461
151	6ef41ba7d472781927f75e3ca54f066e67fcb81d01e60e8a292062b9639454f3	1462
152	9fb620779809f19b25e5c37d54e60353b6a348c842be868436cabf9b6f348d80	1465
153	5d3bc39fc61f178d47affe1c6042a2f6e9ac8b67d18450ed41cf58894f93bd1f	1469
154	b56c1f1932dcf3e173f496c5e12f3d69a74b0629cbb7d57e5a6679be2f89efde	1477
155	5f70bb3b451fbe7dad4e03cc33f5cd0e032302f455d2ebe5e30251841c79a71b	1489
156	8b26fc33454ddd97059cf4dc879acb7ebc33e5bff1ddb29ba75c7cb384baa2d4	1524
157	84263e015d1f5b6f4acbada64b2ba296d0a8162c3b024766664da054dead7366	1537
158	9cae8241c17830632092aa16d423e1470041d66e7941f4c38c3bb7fce53010b5	1546
159	f4bd6b0ebd94550e1d2e27e20b27afd2561c8510396566de5c3fe404cbb26244	1550
160	61ee4985ca8569cdc96aa9ccce75a181ac73797879858736857a16ed0326fc62	1556
161	032ce34f2181c2f23731e721c3fae36b55c1b3e0240928733056de5335e6b12e	1557
162	29911e6f28eedc7f2b2df305392927545c5769664c90bde402602341b178ce14	1573
163	ef5ab16650c9071bd4d2a648d301da1572709668286a06b657a0101a54770a3d	1595
164	e979ad6eba11f32fac1a8769cec5aa6453cb701a618b80f955c693fbc0047f92	1599
165	462fd925ea7c08f294d81b4dd0b55cc0cb26501fe6b709e4fc910089a5cc5c8a	1613
166	e6744637133d29100f8f770feea4ade43a247c230b86a80169f4ab45b15871cc	1632
167	0116e8c329a36502bf0b2beb339e15b7d5e8ccf3ffd9c5eb109eef96ad706874	1642
168	ebe1e3818e072b32f2444fe2e07900fc8d593884f7a46c4ffc87465c6299a8fc	1643
169	9a9878da1ac201ebc09c347dc5b0794204710672de5b04967ccef8d2ce35d6e4	1646
170	37fc11042f0c18ce99699884dc484e49730bbbc021f56083efc64f80fc3ec5c5	1655
171	beedcc152319fa31e525fe727605fb3318414a793e486695a7ae22d08b4cb2e0	1656
172	8e5dac1503d8c71e82681ec3a6681d29a6f42699cb5ac197224300b2a5555d20	1659
173	a1fe522d4f798e271e17b7442bf5e36d68221fb3a8cc3c0e8c66b74099fa2ba1	1666
174	bad563a66525028d5edfaef133c769bb692570557e85ca6be5ec3ad648b8d1a1	1671
175	67051dfb722b7fbc9e3bf7e8bbed5d47cdf3c6c80ec2a85a30c45c85c2f4f09e	1677
176	dd22d4bbc2300a8652ec2657b33403b56cc94aed6c9d5cef4a8c254805975352	1686
177	df167b11201d6bdb5ffb215a69cb120a446251c34bef6909b67095e30677a1b8	1697
178	7b8bfe5a5b69aeac81457e75fa92de89095e2efe4b42f9aa3de14a40469860ff	1704
179	044039b6d2416e771c69f50b8b27a5c6d4cae92a3cbf36000f4792db04b1f6ce	1706
180	a52dc74e2016e3a4adbbf83811f76906e3094e5b7e2216bad4c0e8864f7d2c32	1709
181	703b093b4dcdfdd7c4fe78344b066be761db5988e35a8323b4a6c43d2f56416b	1725
182	1e17b246b4622d9291ca08ff7b67ef01e72f3965a7b6f1d10c3800a22112235d	1727
183	ba9c6d1657d02b04540c284993f4e597fcc19d4a7741db4b46eb7b7efcb506cd	1745
184	75784200187560b5774915445482f0094feaa3685c83b348b03bcc1e2eaba89a	1749
185	be0884f73ffaaada986d043be340d262ade5f1946eaf8bdfce437bfb889af235	1750
186	1a0a9100546745cfbe48f59f16591123e7b25c55166d88885707113cc5d59788	1766
187	6b83bafca4dfb6ae24dd6c64ae379252a0a9eb2113895073bf996c83e45ae80f	1775
188	e41fab4167ff6df73b286df321290b3dc2bf4a701234a3dff449583b8497501d	1778
189	8ec3810cd810001fd15c66f8901f92f36c7b25c2b12b2e087068f475b723f2db	1787
190	2a42a9e7126a86d7c08fad86ec625d32e56bc98efa528e31d53dd663853a6165	1823
191	ececf6b1b1be0a25d00b81367a0fa16d0cf5d1bfc222518b7c2d0c83cc438210	1838
192	78265dea2067e489ec90b7c4d787f46aa1fdc0f64f6ff355da016bc8e8abea81	1840
193	67ab1859e2c549f70676471274aa163c14dd908b7a284cd965571a7274d61f98	1842
194	970385733620ab2cde33bdc9226f0c3a1bb9f7f75733ed9cfc193226542b3364	1871
195	0ef2207c99a2b2a1ebd98b2f299200d1e477db9446f7e2796db684b70ecd7984	1874
196	c6baa653196a9ea1f34cade5570b72cf5e1db9865f05db590da8d13ed1e26399	1877
197	eb200ea0bf0d3a8cece331447a017cbab71e3acad200fd3e97800de99cf9d21a	1894
198	cb996ad6ffb4b5e9673f8eb719b66a22d79f16d8e5b1d52bcc1dd1f0761125b9	1897
199	c879565654bc3ad3db214fc6c4d55633183f8dbb1efb8678222175836bbe1e07	1903
200	d8000c55f97cce3f4e31de886d3fa54ed8c33cfcddeceb91c67edc74d1ec08ca	1907
201	b65249ae51af5894ee0e247c1bc820eef2af982d11b8ed4517fabf710ae47296	1917
202	84bb252521b0db5cbb7d5602535e0a16737f80766078bc570b84492ca72001c6	1922
203	e9b1135bd15ffb04f50f23191e799f0201304f80d00d11a239901139a26a1bd8	1926
204	3b9c77acf37ec9dbcd73ac268a4a5bd7abae7492dc9192b61be0011eecec0c7a	1928
205	c311c21c2e450e4c102ae4d2bc62701ffd58f1c0296d7655bfcf1f8a2998479c	1940
206	5f3550c1cef3e038fdf8d073ea840def537e2ee0d9d715a470584bf7c4cf8b31	1941
207	d12d562117003e9a56bfb070cae66d0c87a3f2746480f9b348177defedfcd586	1944
208	e574c7002e3abc3c8ac639ca847fa0b19e79634e7e0e4d80b0e9a21ba1ea2481	1965
209	f0e9d3936d376fa4e4f528f679cd1bb05fea5354f3f75877bebafcc356034581	1974
210	d66146be819bace59f69e9add2521040ddb0991f97de6ae1cfdb6108ffa643f3	1976
211	c6849465db0128e9fc9ea731d0c597999ca1fd22379abe22e37b12e1e3167dc9	1992
212	68e2cad409a9235b29e3cc799ee806de22cd1fdede6f082f6d88c1d73f998b21	2008
213	d2e3552314587a3e0d02766358390606bf1cd83f7d7feb6767b79012a5dd352f	2015
214	4ed3013ad3b4c51cf33487affeff1cf1be7daac4b79b323d58281d451f5e7a4f	2024
215	a4f82d95f0ddf124561044ffcc730e10c5a7184c8a520082f8378da549e0e90b	2041
216	cf0a00f30e3f17a58c0461015ace131574bb341cd8623442b739d839e12b4971	2052
217	a7e8974c648011153fd69d01ef7b89438cd05751829eab44cd8f146c5f6f4540	2058
218	2a7334169c7754b44718a327c97464928693ed86b3de47ca3b09bc300683365e	2060
219	cf10ce11bfbee1c339f4489dbc3f2ca1934b3da6ed3dab607fab01f9e4fffb9f	2066
220	8c2c5d21ca4407db203d3ac7d9c05a03d4843f7cd81efdccf66366f39027465d	2071
221	86b8aac7284a7bce90b57751c3e1f4aafb2b0e2ff5ef6a20e574dfe366c6afde	2073
222	fd7038e0e61aab8d4e5de2c9c5b804a59377335592dbb37d504f48936d6e6304	2088
223	8922f76fcffbd8a26d65ef3ed0428ed46bdecb2f6a4d99408d424dd235b00d3c	2102
224	0d4283932fa8f8d5aa9fc5244863947e1c2400d9d4f35708ff20b179b1aa9c17	2104
225	7e19e6e31bf7cb6cf31d21cfa72159ffe1c5a31e76343e3c2c598b37aa2faa26	2117
226	70ca421590c59158f2c7c66ec4100bf1fa2cc728ea40192f5343a553c8c84e67	2138
227	2d1ceb9f5a41ca900fc4d82033a0f37918a29a054a6b938b8a2b58cb97b48d14	2142
228	bce655ca408b37bdf716021b3d23dad4c76fbd6f0f35e5b9b7ef56cde448d397	2143
229	eadf2a497b2f4ee42e59d5167ec1fc8ed3d03a489850758df71ff9f8e97b9913	2148
230	f76e4b83331b195de8fc889da505590973d365eb34cd6e7d3de52e5c1cc9a6b3	2159
231	2fa70fd2e16d50ae9d6dd41ea2a42ba646b2c19bea904ad7cd3543153c637c00	2161
232	5f515428d6a0ea178bc79591bd21ad219324ae82f78fce1491a956ba5f8e800d	2189
233	7aa178af1edb1f3834ae8cac8674727beb076a19302c2e0bbcb9a381c1bb05df	2196
234	c9ee7b12c32b29c7ab71b5f85c2bba3f5b7b3d021c6082772eda457d99a665f6	2198
235	00b1bb6e957bc9b6dd124f7a6ff0dd1117390d05fa0636f9160b90013a671d87	2218
236	e04893a731c4bd4f13519f8eb77b51505ecb93abce5a2ab3b3fa4bca4fa4c229	2219
237	8bdaac8fecd704198c95b1d52e7eacb29d3e3928275985c394c50465b5bdfe4f	2228
238	96fee96a1259f0b677d67e6b2a431fc43eefcff1270a2fab37682a3a5bacd8cc	2232
239	80413190bff6f5f7a51f2811945c92768db47cfac56eff47707d2f1d281b4676	2244
240	89399c7b9c264f2f89c2aed0953e1e638980aadb64612b0730f741f22824493a	2247
241	3aa7ece0e835177e706004012cc1cccf3ad2483e52fbc9a24cb38787b22f5912	2256
242	cbabacb31b0e532b2736c8bdd5c2ab01c37c405bb52e9a1c9ff26e7ecadae4a1	2270
243	2c0fc660563a891f9a1b7cb614ae5bbcd22007e62713f6f5133206041b84f1c6	2287
244	a2697c28627c595120820e23b08e1c4d527d8e985658082457c4c4a86b6fcdf7	2290
245	ae8301e02bb9cda9d80991a87010ef0ad31884f04a149a1c4d95dc8407e4f3b2	2295
246	97c43cc2233180d8dde6bfc603652c113e7797cde65481c06ae83a7cb6c1af61	2303
247	8f91b8f7f07bc2a5f72c6aab1456b98853006c7f89bd3e403cfcdc7b727f06f2	2304
248	d7dc166134887f227534e469a32e369369389a14af0436573a345fe2b1a08045	2306
249	4130a069b4654dcd786a1bd12437ac5f5c4c833f7d355279e20253a5cdd1e646	2310
250	0eee9fd14fc807f865a3f434e0c9110d75980738542458bd454d2f47c7ee1a2a	2334
251	95923f4602b796d2638749ee56af609a147b60ba36795125627596e4c2ba2f2d	2337
252	c6f8bb2b08f2d6d2d0c64ce6a53077d1f490fbd66b26ef0520b4c569029deb2b	2338
253	c8d32725bd77c09325ab5f94c87beea437ee63dde7fa6ddfbcedfdb4ab53b8c5	2386
254	3fd91fb07179e60a2a6afa5e753371a1b58354c447ea302dd90ce06e785218e0	2391
255	684d33db007943a66da2a6219e71f331517ced38e7588277ef67c07e53e0a179	2400
256	01da23052f00fd30cd817bc7a0be6b294810fb0190a610c966b72e9bc2f26861	2404
257	3e89fda348d010b8bd069e91b188ab116c97cd74a9dc456b983a3a51aa2d0dc2	2432
258	cab51319abd9ec2b90bc62a306b5529499d13e5ff21d38acc2125e99fdc2f64b	2437
259	af6f08add6a9b4b9903736b245b59deab20125ee459ea0833f20b9e53ffe7399	2444
260	d89ce51ff13d16ada3bf810ef558e650fe625a2d3180c8fbdc522dbba939b0b2	2460
261	445eae31fd626dcca7045d73dbb099719ab120fec58d1f4985f238761a8e5077	2465
262	828264c25ea992bbbd9ea6db949c223888cf1f6e92469ff6823c757e75fa6528	2466
263	fd6063bd84759b1340cddf4fc57674f7b9a7f57727ecfc06a1c7627f59ae6de8	2468
264	39e1395ad8d627bcc68445be38539d8f4b00952efdf83120eced6cd4ec25bd31	2474
265	330a0f67b80c3d36695fa69c5989d3e2e12429b353186bd2840eeb352f5ab90d	2476
266	acccb306ebf524e8985eb0c7c13ebc5e92b3d9167b735699777a572e93d99711	2485
267	902c6b19a9697dba3cab64e6e41a6fdbaf3fb18eb5a114ceb7c0e23fc3629678	2491
268	3538ce81925963730d627474fb623e50024b0159ad8ed949fad84e182741140e	2499
269	4661b81c4f2884312af95d46be919f714d7e4adeb8d6053bd2133e9152d19d96	2501
270	32c9648fdb457b06b356d14a7ec62646535cbc00fb0b0aaafd7e4007cadfd4d2	2505
271	adae1429e0010a394db910290a77361ddbccaadd4d13ba8fc252047cc1f39bdc	2515
272	97f1bd61df93635c252d848a071914f3b9fce86aa4bd2aa43ec802a97b8bbdb6	2516
273	da75a9fdea309e2e866130aa4110fc37605902a785212982ecf32c831b3cd7bc	2518
274	db6468dd52605b32f303da44b0fe259c60f9ec641b0cb4024883a9dbf396f955	2539
275	ffb6c2ee0744fdfa3985385ffe460c230f93fe54c3d1df5efedd726d23f721f8	2568
276	5af19b06a26640b13f90393c2a2cdb045fdac73b367be7f9daf7fc0accaf4feb	2581
277	58f6b1a55c3f1e34e00f0342f8554bb3a370582eda877d45c7b76ec5cb65a2b5	2594
278	b64e4e5593ad9b15d07d38c02bf4078b949e463a63f9c97954fea71ca18cd97b	2599
279	aeb3f5cf4608b5f062ab4b99345f7335c9ebccca21289a4347bd939b90a7e739	2602
280	86df257fb3d970e091bc6cdc939f293aa10eaa8139d2ebaf18a63a06f38fc69f	2619
281	aac0d6c41d84ac70c1a0d965e432a94ec5a408f30da93192ccc0d10cb15a78e5	2636
282	b1e440c74635ca893e4c7fbdb63af4e81e905d0e73cf8eaedf735b6b305b1482	2638
283	59e3096a438b0bb6a8120dda0aee2505e94651c75d455df750dfadcc3c67d6e8	2645
284	90e8d84e03e112a36cf21db7189a41944105032ff716cc8eceb3758ca46e60d9	2654
285	c9b2ad7f2aa2f7cfb627e5580331a8d107182574a701fc8fd1cedc2676cc3868	2669
286	c54e76472d2aaebfe1cdc2efc7de3d90a44e081ba2e28acbcb902c3656daa3c8	2697
287	2a2e9e09382541796d84374f6894b07200218a3ffd01c150fe1f0a432bb1d823	2703
288	9c58b6485a5b0a208441ff3b9197630dd46e46f770998a7a682eb619b6e75b6f	2710
289	363f161886a8998a8fee0d3cf811bcf378af18c3bbc2d82e743be1a36c0dc375	2731
290	af846e6c34e5e8fbc32034d57022882d9ebf31d86dc4535ae6c673741e408214	2737
291	55ccbbdb0df3335d64a4c50e0994d6a331aa34b49d565402fe870aac151252da	2738
292	d2ab0b3b52094f54a9fa7b6138a7a96afc0ecadc1cb03585cfdbccf29288099e	2766
293	d33af5cc2eba39dca1a0bb83308c2bde7e5f3a9000fd8905e9befa08089a962d	2788
294	e0872218c88ca1fde067604e8d2489e0b0338cb642a6aaa8b154611b9f27e63b	2816
295	34f2fb503e288e12acd341cc86633d68d139bac05ca0a53c6b4d46941bcabb01	2838
296	b9b68550a9d081d2e89f096dde946030f6e2bc02bd6811b0f966868b5f21b637	2861
297	50011eea06911b6b0f941a471ddc31b2a51e7ffe6cf130952b529367baf4a7b8	2875
298	e68fbb0e7d64b227b9a3e6706dd60307e14b0fd9ae2ce8ef8ccf7fa6ff05f830	2877
299	db69efd056c64e5a1e516a81e5ed63111d397014cf87490732b5301ef4f59c0b	2878
300	cdd7cbe76581cbcac13903db0b8863be30a831e84e428acb0e63e87d9cce8809	2894
301	221666d934d405b9cf221537f9f6c54a2a177fe527ba9878f73814cb0246c7d8	2895
302	c974e6fe94587b70f41f3a8514de2a9dc549e53acd686d701d228c03f2f7a368	2896
303	09aac58df161dc849c022ae0e42763f7bdabd16ec8806ddfdd7c533c08305799	2909
304	3dd298efb1e7b40776e4c7a1c17afd38aa9ff70703dedcef5401c76ad75d003b	2920
305	9e4f746347b565320f649b8440b6cce1177aabf0e24776db14f46c0107c59479	2927
306	722d784f87c396d46f56dc5c2b3b9d552eca042e3c1de2f478097f342801dfcc	2949
307	29faead646397f7772aaef1960ee90de85c2968d2f32f54e3e4c935e6daf5673	2955
308	421040a40da9788416e18424c366bc0a7d7260fe9a46edc0340aae350d3dad10	2969
309	63cfc7d0ceae6ce3a8c37ff9785718c142955957969b462df6d605a775bf5bf1	2971
310	41bc45ab73f5de3dd1a8cfb40bb2764aee557f36b2aaff323f072bbaca8e4e49	3000
311	4a8bff0955c3ea42fa15db37078b212923ee9ef427df3476046abae9fa0b531e	3017
312	faa0bcba155119a7fa5e2ef4f19fb2c2e56505371d1f8ddeb3d80b2e4401695f	3019
313	4563d7f0f24f605aff6de2caeb427daa6692a3fcf08ed47d3de7033278958501	3032
314	1ff0d8119e7f57c9a0580134fffdf62c3042c81680c9adf6f82efc4c68739fc4	3059
315	d4f7472b4c9cbedac4e51ecfdceb999de2dae5b9047e6c10368f9f52d3351432	3066
316	20fd9616c5d0b13ad27d1543f89966ffe56a3715c8a9b895971c2cb0ba0d6cf5	3094
317	11ff3571bccf36ad69bc90797c4c2fc69e17fdf5afc514f73fd55e9ee9c6eb82	3099
318	dce2e8ce65f4094abad4b0be8f02c853fb7520cc47c47dab2efd19928c066beb	3102
319	11f9612179bbc16caed0fd753355e151ec833e893f9545150df700df5768c025	3104
320	39e6a6f0ed61acc377eeff144698132c5f5a04a7a91f903f20f88c914baa3385	3113
321	ef7f118bdf69cf7c9306a33b2e82b00bc4106854150aa52651650578b30aa196	3122
322	f4f3ab69dc99cb3222adacf9de746bfe17464b2c53eb0ab34c28d3377eba4bde	3131
323	3d3ddce2093f07ba7f25f5fd99c3822e73aba7a262cdc4144ee6561e261f8b30	3132
324	4c2889bf90a8903b6ca5296ca8190cb0d685118e3120249ef7b1639705bb4194	3136
325	b345be025c8f2250a94666f2bc6422447da31a4af27de948c6ac312362cfc7cc	3142
326	7d2b077503369b6a8d778a160f472ab9f1583efac3c02f6644b111a435f73eba	3146
327	16fa13adbde734fdb2d8ddb5c6cdc8e2c01300f54dfe4aeb78e1f18d2e488208	3154
328	8ba7d1af9f00413cfffa8a7baab189bc350e1271204fdc9f2202a9826b491cb8	3165
329	4dd1b9581cb16ff3c3e1d2484dc3b9971f2013540dbe48cbd2c80705205e50be	3168
330	429ad6cdb3f10ac12aa69982878c87b2dfa6733e0ea80d87fd2422b88202b253	3170
331	cb72cdea93ab55efaca2b74f7c39f9121c2be18c1113754cde209b596d6a1621	3179
332	88d39eed938b6f8239970358931b19a440519ddec5e46a760c3a5f90f4d42df5	3188
333	d80d82e4541e8a82ea52266291db043eaa82053a1b2c56dcda8f8dc69ca57e40	3192
334	ae42d6f478bb80d03a91619c71c91b7ea46cae0d6c225880f09c78b4c206fba5	3194
335	a6aa1dd338d7cce45ae4273759ff2db20fdbf9fd9b48a2f6a2725fc0ff8c4dcf	3232
336	10bf2147ec74ca0bcabe45ee25227ef8f14cb120355b6f93b2bc5ab0b339f5df	3235
337	d3b5821c7c3aafdaaf160c2e3102c14f63784bb46ad411d3d883d5f5144b8a28	3250
338	dc9636e43a081be06f3bba6b9dcacf3e537ad76e95ea853fafee9142b0acb13f	3251
339	77d113f48a8242b2d19bcc7df6ab7051c8e1d518cc7d1eb688a54247ecbebef3	3256
340	706b33582792bf370d83ca4e8a792101f05e35117e6bd6544ee5ac1b809ead10	3271
341	6b46b0ee6ec284d19da5e3e339173e698848e44b9bf45282f4ca5dfcac7ff836	3300
342	cec318d334be4e8d7faec36ba25dd047794404ef4e6741b983436fa5c357669e	3322
343	5954eb9133bb356df58f74899eba75f477e37efcc06c7f6084437582e9240af6	3325
344	165ae5cc6b6b8dd811fee648a947967e7f3cc203d780ba1e934302cd27455108	3331
345	49c486698b212281c717f4bbbddfd077e68eae6f1baf72b74e411fb64e33dea2	3343
346	795fad88cb8ef5a9893d9e10e53b51764390bc4b20029dfbf593a5e1fbec4880	3355
347	9ab08fb28cce81c4978fd6d75e1a3bdf2d06bdd3d86ab17a1b42abc042892e30	3357
348	bbe636b7c7c2ddddc9df8d0721c3edbf5c5e97a63a562d97c8bce843a9abfd8c	3359
349	d6ba71b0f73270a5e439d477c44be72ffa9d56159dd12fdecf05236d2777526a	3387
350	41b9bb78adbbe3977b2feb097a349b5703da5d54e88ce37030d0f63aa5e510b7	3398
351	6a581e9a602488d180b0d960c67769b413f75583defd7b503e683a7fab976547	3408
352	d4c463aa0c4427cd45444c396dee44ab86afd4342ec28f61abfd3b7e5d688515	3414
353	6913a3550c12c9edd05c1caa41da511e827a4ed78731fccba847f7666cf36c40	3441
354	884fcaaf2da8b5ca6d3c68dd2fd9681f94cf1a34a1a9dd8a6b0dfa9a28614d7e	3476
355	5994a2469f87dd1f312e3718a62293782d7b0ee2049ef0f3611cbcefb4d10a79	3481
356	dfdff4b216d54af6d3221df58f51159a06263ff6f9bca314583f792219a5343a	3493
357	986b2a6cb585bb72c2d2bb49be6f9d3fc3b89b07a1edecf5c4be661c14acde97	3501
358	dcec4355e9bad4eab80cf04698203f547e6bfd4cb7a293c50723002e1f3bf3ca	3525
359	0169f18f90d48e387f65402e8e4b21a4771564532a515db974fc48a570266ee0	3555
360	f949585c29a57d35bfae2f35dc21ed1ae35e44bd9e3bc4e393150d039859f759	3557
361	0b6f20c68a040176b6c6160a80b0dc79462141c07b96d377b77467bb86ce1590	3569
362	f50368f5c4c67a2e72914c2f79d89f7cfd991ef60a084dbca7785107cac94a67	3572
363	08844b944df91290e2bc9176e7fc404db86c5e89099f61d7cf01683ca1de1a81	3610
364	cace9eae97ecdcd715810a9b972bfc1bf141ada0009f73ea288c5980401f15a2	3631
365	d42cf15c42c1c2deed948d4c7931dd2fae964da20654b22f4cb2bdf23103056e	3634
366	1c185e5fbfd12f1c5227f6e0e9325c9e4cbda5e67ae39b84a0ecdc3c879d6866	3641
367	9509435be6830bdfc98ab6471e2f01a1df6d2e0b2f01e7adb144ddc2471032bf	3645
368	18f61f85db7317f6e1d6e6209802996c3360db04c543c08072b8fb9f1a8f0ab8	3654
369	92ecd39c266993f99da8d883585011633938cb5858566bc8afa2e1998a7062b2	3657
370	b2a3d69e80b0f5a7dff1903520f06a32f820a4256625903bf2a99afd419e22fb	3675
371	c7c729fc194bc6e478bae847bd092fda4254552516a7c013aabb34d2d173568e	3680
372	dbe3ffe4c5cd2e975f84181d8e8a6616c7b4d8d2d43efe26431c834263948532	3686
373	5a087ac0f20db1918de6aa25ce4dfedf683150fdc58356242e8d511cdfcdb62b	3690
374	61d5593e1614589fcb77bf3b87cc3d9492991b26ede5d63e3109f38bf109bb1a	3693
375	fff67982de6c4a89fae1be9f7c33322cb9e2ea76773892a65452bfe3d2fb015d	3707
376	0d073088b9cb791b03ea9428537247af756c8d61551bfdfb5d2a2a8574f0305a	3719
377	58932de1a431152ca65084f6183aed71eba0b3f9454dffab0e2d36c2c61c65cb	3724
378	77f8200a00744572097dbfa0bcc4736287512062c398e8442db69976bca09ff3	3736
379	117a6ca66e99e2d06848ccec224684607321e3845ed7987f4376439482508acc	3761
380	e512d57d1d1255e83932f26630b1e8bee1082a05d1a710d46efe2b033e2bb6a2	3769
381	74e44c80bc5e253866ba91101d60b71317acf93a1385bb13d524afa9207f7f44	3770
382	05de55b3dd2bdf6d54beb9b79b727935188adbc1407dcf37a7ff4df27e4cb221	3775
383	67ddcde71874de74243ced5037422af1cd251166dc235a434f86427412876215	3777
384	ef6475b7073916a28e2ed3458f4519d8239027c9d65eb483ead1cd9f328fb634	3784
385	3d69cbad2ef15249527e9bf8c11947da1d4f63ffe57d7035d2b6879ff3a23ed9	3794
386	ea498c55b9be5a6e91e19ccc88ac0dc1d13081c7f91e16ccc41d92666f28b0f4	3798
387	ff49573e0b174e188ce5a3308da51a0d0b969b26f130271165788a3ebebec544	3801
388	b440e1e35bef909baf7d9185c52a9341895bc8aa139e7acb4974a028566acc89	3803
389	a5eeaab351e465d9513b3d8b076561fb4f0ab876cab712aadd20c62c2d254e57	3811
390	8bf36cb9b149a00201dd96d734d5192ddcd4e569d5ff36a6f3f0f88a9a0a9c21	3818
391	71c37a5b26e8d21538cdfdbc20e2b4cfb780d4dfd316efc7523215c5c934fa8f	3822
392	5ab5eda0f0b831b7fde86417e09a808653d44e570479bb4a8175e696f011934c	3847
393	9aabff9c439fcffe73965a23d189145ee9f773f92438468afffd20509d576d99	3857
394	b2217b3a4c80c222e3c859453ded075f7c9c026184823a25fe944a7b4ff4a70c	3860
395	a9353c0c83614019fe290e4d7c620d3772ab9d7d8ed84c786e745d99bc4c3bc1	3877
396	cccdffa346127ad4fe3d33e3ec9a1a07dd42458b0df95399302d31fe57c0d817	3879
397	ec2e779cc588b223b282ee1d521e03e998f747fb86112d19763c85a7ddf2b8a9	3902
398	d8bcef67e0e7cd417f37af74fe56fa227db7901a361985274d5503fb766681df	3910
399	372bf33b8729ee6e3cb04c643d26ea922840195361705e1d805782bb6d76ccb3	3933
400	23d39de111c610dc208b6e9dc8555b09f32158c7501ed34ba4723c5ca070c1eb	3945
401	3ffcef024b81cee8c7b58d53cdb84fa3ae579d81c891dd4ebc17f759206c8b3f	3958
402	7cf6713743b491e5c25bb1bdc5155a0db87c429a924b4080f94fe145457969ae	3962
403	65571526fd9b2d65ce979e40ae02f59e7688d02b3a42f4061b25c38dda00a72b	3974
404	50d73fa188104ca096c58f29b08dd82fff437a3b4fdada9a976b138ec21b8981	3976
405	edbd086a9583ae1953738c37e045cff339126c5471d4601409814e28e5a56f00	3981
406	eec14be0cb404733932f8abaeead27e9daff2c7f3a6cdd360b77e40ce7fd6818	3997
407	9f8cfc97f48d66dba493d5de378145985179822836b9edc10c00976466b0f737	4001
408	f188b3d1d0f5071ecd5f53f5708b7b07a04194c08db6ad1c9f353df5fa95007c	4002
409	942db8c5fc81064e96e9e43d5dc3975e122a84ac553b16ed97ab66d09c10131b	4010
410	0587ec498738bec1a3964dfeb7f81affa6e1189d1595afaecf502e401d2af8c9	4011
411	d86e5cfb4fae163886c140948e89201465282401872533105950d1218e0907eb	4024
412	05a5f1bae9463d639c7299f5e9c20749c7c92e6a8ed51c0fb6d15b9d635ad670	4026
413	0ef59e2a3862cc6693947f7d4ba2c1662ba2e780076aa9b669dd3decffcc9913	4027
414	f5b8ed0009deb5822048d0eba26d055679ce7308c83071d6050a0bfbeafbf6fa	4034
415	ff4e106c49f839f94ccdd4d12b730256a618a5fc535a2a5ef4e0c6c67b90873b	4035
416	dcb135219c3ce6871a6fb50fbb3198d93936977e69098fbfc90bcac8c3ca894f	4043
417	bce665532ccd38febef40df300de6bd52e0aa62fba7bc5b44f4c2d6fdbd0a1a0	4047
418	8e962907ccc9c21e520bd0f42ab8635ec52b6eacb06c634997f6b83bd5962ba5	4050
419	ecc385782f98b0189c955365acddc401700d2a5f776ef6b0ae31d60e07fbdcd0	4062
420	5bf7d3aade5702ee45a51216e7707ab33ac11ddc7866db906514bfb6d4884ced	4067
421	e756226786f9975c175b1198b09b205dd81abc62e1d3ec2c2f79588a6bb93f82	4070
422	7c732e3748011f7562f345a1065b5eca81679d133131e89cef1f91e0d8c7f8e9	4085
423	14254268dfce60864eb3c96fbb483808f585d71292648bed8fadb38346331c51	4101
424	b92309ceccddd604e7e7543adc7472c55ea1a42dd66f0d15bc262b9c42429df9	4104
425	5eb161f786fa9050ebca0744683c3e4dabb89c3e931744d090b5cf19c6caefc3	4105
426	bf938db4e2ce0a396e33a949e19b8296b642142769a54fbceb79267505b36f21	4110
427	6dcd8478e4618bce211a460fb9a686c66082cb52f4330d4e593ace341990ad69	4114
428	fa25f5521b7414a5c7877a42b68e015acca74eb71050ef8bbaefbe01a5a6a5cb	4125
429	290d06dfd01052bb7a692ccd3d1f5beab6f0be34e0f10d8b76a035b6d3072e33	4126
430	dc42159ec987903920534e72a14e219813ca6a8a2348681712b2e23b157e890e	4133
431	ad55452a171f2d5f308046b6ee0405d614119bb373872090394973c49a4e3d99	4134
432	d8e43f1d611f412fbfc184c14d67912732bbf8fa14a39301d32606138a882176	4144
433	a51ebe02d509a2fed5a8455642cdb64ad70a7e6bc15724093a62565ee1ab0c4a	4145
434	dc41a2cfacfb37bf04de52a601a7426b504633a2e127ea716ab1de187ea7fd32	4150
435	6f0577e9cb87b9044f0f60fd57d2de332212be0c7ee6ddf3d80a45ac1eac485b	4163
436	47d73801236cabaf50b1d4dd3601c335c023ad5256c6ec67593ab0f5ebf685c3	4178
437	10c5e93a52acf93b1cf9055955accb6c3820559f632becf93034ccf103e4386a	4180
438	2450c23aac7ddc91c132d4cbf4e8c9c24a6d39ab01ceab93f9e2c9327b2a0d15	4183
439	ce326dac881a4492e212db7586747652f0d83755e600a29f53a142fb9b2d405e	4192
440	13a30c4d41e0a4af8c1ef3c381b4a1534bdf5dada6995cfc4bc2b72d833dc49d	4206
441	300590408fc719c40f24b7fd5de800a8275da0e2630ab5964faaa3155cdac721	4227
442	0482d26edbacdecb9bbd63159379016ec8deed15c0606f08e4610cfd3ec8a999	4234
443	ab7dc31c8fe6d335d6c499bf4b43f8b6d7b9146f4f6c859d773baa981a204384	4252
444	28f2b12cc973470f2897c0f36c5978e240f7784105c811e3b31bb4bc035713ed	4256
445	b293e95a7e0fce251a2ba46f0796b45bf1d3e435966001a78d5faed6a369e937	4265
446	6f7d6d530c83dd3fadfe28ebd682e1da35aca20a424715f63531bbf20ae74224	4272
447	a7f20c6423819912aed613bd0a4c09cbf5ac1a6a7d21efe25a4c4f21bd45343c	4283
448	c1e414c23b2fa92b5724d50d0a0e592bcb1414aec13b2661f9f2a362dc085db9	4287
449	6dd3f41d8c8b0f71e2c7addcdee61c8b95628968f8581698f4e8d9d205aad92e	4291
450	263afd425a1a33e8f7a2587ddb0f390674f1cfb5c74d2bcbaf53f87a8dcadbb0	4293
451	1034adccf1bbab916254f0b16b2684cda3a5eae6913b41a73f64f2074abd6592	4299
452	d4523c04cbd1c4afd13af769915f73f5d7e108413c88d686b30cc283e84cb261	4302
453	9ade25d62ab5b6495e43719f880ab462030f99772f82ba011c3638e8fbb2b582	4310
454	17be284511191022c147de97011b606aa498f60af09930b25124ff23a72a3b04	4312
455	e5be00c3be80b9404306ab50e1c45e59bc910387ef53f6578011bcdbbd34e2ba	4320
456	5b6f0a2ea2dabaa51d2832236304ae537ea25027e3e33ba70be6b6e0fe874bc0	4345
457	6a9e2d3d1dc3286edd3076d292b887a15e0f6c5b704e8b163eb96df946c23097	4351
458	5dea3d96e8cd4c8e02e25b525e6e0e52976bb01451670a7b0e42d59fc0924588	4355
459	7fa2290c865871690a1e6ff3f0fe818f4ff6ab3332f955c7b95fdb3a67e59a20	4391
460	141aa7200b20a2a1f0398e5b42fe515d2671374b4ea322b667231b41f7478b1c	4396
461	4054a06faf85a12e41ca2bd497e8b11d37a675796887aac6ec7b047058bf6cac	4399
462	e46f1217d492e6db4d272def69c7e17233d1e0594b4e1c737838022aeb04f695	4400
463	5547f6c27c88ee4eab4eb18c1442ade6b34d084836f7a77d861ea7cb21cdd48d	4427
464	96fa2a104392bf733008b48e0cfc1e1849c000f0856bc55a140c473ceee03e62	4451
465	f5e6560612ea53674593f9f7417d94a866ab0844006f0f53bf6dafda5429cae0	4463
466	ad2dce3fc3e940b45ab51a4a18ce4f1855107a0dfd511243fd6593ad7cea0b7b	4467
467	da1bd64568f336b476a0cbcc28e3041fcb1f1fc93d2e97738cc1886f9fe07858	4491
468	3bf221f4a712587f2e2aea5b5bb7d2dc06fbcf361784b048d6a76299d93d082d	4494
469	b0a95a587253db03a3b35707cce83bd9061bd4cb9cab12eee8648b1848e4beab	4508
470	b0f1b7f8789afdf811361f7b794c43db49f0850be73743e0071f4226db817b70	4515
471	719c1b1484cfccbc38d62dea5738b97d7325243685b7ed13976a4369efc04453	4536
472	e37db8868c64bcb47a28a50266dbee68f7d886a3aebab67e432690364943b955	4555
473	64641ceb5f64786c99a5a354e6efaf673cce3f55872d8f2eb38cc51cd640988a	4559
474	ba8209ee04513bb8edeefe7e4816c7d9d7c16ba87ebf88c33e7aa0066a4456fa	4561
475	69bda7563e55182cbb475a908ab9bb2b05b6d5cfc098609a1fad48162e6bd5c4	4573
476	d863a0b421aa3e6be3651ab63e97e4633cf24ab0a0de4e3cda02448ee320ed6b	4577
477	a7d2bbd618f159c1d351ccb0aaf29ce28522a8a9067beab0b568f00f50202ba5	4583
478	cdad0cc54d4260304e09a4a3dd7b0f618b423a36b305fe8a04125812cae2727c	4587
479	a2b1556c70968f10e0056e8a5fd2756c7f705ade38280807c784b3e0290c9248	4588
480	323501305b61fb52a964dc501106ad78d67d016eba54135b23ad3dcb2c3edaf5	4624
481	c0422fa71f1325587ad2565743dbe4939b8971abf7b05bdaa428260817a00964	4628
482	44d021ea1350fd4ba79e75dbe7f52e381b6586e615eb88ff186a87bacdbe90d8	4641
483	dcde7a2edcf21c569733e56e5ec8d68b9d09a603b29e2280e5a1db31b4fdf97d	4646
484	21361173ec8e72e685aa5878f85cc25c8bfc2ffa916ec4b8f8efcea0527d71c7	4649
485	ae221f903dfaa7b8f68a4dc5903744017f270c2813aa390b710ecadd4afe15a2	4651
486	5464dad8fdba3e3bfaff9d4405c2f74651d1dd7803c44518cc91a3e2adee86ad	4671
487	ff7a72ed7f62e01b5e9c9bf977f8ff020ec4d118cced8cf36c196e0bd1d97e93	4676
488	3f18103ae3dde4cae3ef65122979ade5c032857f659b1b08a5e3041f2875ec9f	4690
489	9220459127b309d6b7abe5f81c8769e3d4055d6294a165a251a6dc6f0e50d016	4694
490	f1f83dafc69cbbdcdf0f88d9dcf76d6b53575cc3b7ca0343964618b6853e9ffe	4712
491	218585f4812291463dd0b800ebeae5def6cd3f15386f11852068d9736bb877e4	4723
492	3747c9f9b8096ee8c68ea97eecd9776e43b8c88c23b69cf2fb601b12d3abb9fa	4728
493	0bfebd0d073da6448fff76504cf230c2988c72db76b04f1e5c63e0af2766db7c	4734
494	83a12364b980bc58b6be97d87ec7dbbf0ba311aa19aef9368da3b4c4c3373aa3	4745
495	7a19741f636f198ef39b63d6474b6c7ddc95b59208113f545e7362447b0f1e71	4749
496	3545c4348634f515fc5ee414eaa77e47e30c3f31f98c67324d0d14ce89aa2d23	4771
497	bdbae2192039b267dcb67b49d319166c609dbddbcf493dff550c47a5b060d426	4795
498	3496dffaf4a9f2e9d90b35dda0f91771a22704faac01f1a1c552efafea9d74ac	4804
499	f81dab5d57fddeda7cba1adf6be078432966e4e21f9e09c89ff915211e175206	4823
500	5580d3662666dc07bca58506c79ce290c59019c889747c20da55e99ce91c8e86	4832
501	d22319920fd4ce88ef80338716f68e15c2aa0b9727cd379335b698ba2ce661f3	4836
502	a29e3caa3a7d7f92b6a7e1d473b6f9f0d8692491c3eb5fb21e5298c2c6e40bbb	4839
503	78425dbca42493287a99e4c86c679be23565e7af0ed269f2c41b228edebcd08b	4856
504	307a9033744522876229c9b4fb35c8fd57acb28da1bbd35d393ef401714244ef	4861
505	c5641d20b056f120cf569a4afa902c47766df4e649d98fd6ff34bb2c3ce40715	4882
506	96f3cb87f6435f0be9a871595c07d7e667adff723055f7b7388dad8cde26be10	4884
507	90524ec999d985dfac768a0f09c2efa5f416ae082937382660682fc761fa23f7	4887
508	5a8012e82165c9d0772e12e5eae279886a628c90484d8355e8b6d30e4be2dc4b	4893
509	a29791fa5b4020451c0159c6e9f04b19161f7b7f8a76add35c58381b8a47d401	4894
510	19b3bf6e417c4b7d0c4d01aedba90ace0a2695054bc2cd59f0dfa8f2ae9ae6a1	4904
511	64fc5226f3a4128a5130aee7e7a6e3fbc17a150e14f250d41d3c2737c8e2893c	4941
512	40fa195574e4c4765c866316a1e0304f050c1c285986ef4e9da97fee11557c8b	4955
513	c8ddb1f7dfb2fdccc42d1616830be49a52166ec57c846d53ff85446546816879	4981
514	96dc9953b6fead510988222137dbebd755b28384f10a8681eba4be2e62035a63	4993
515	df3f7f103ca9ba5fc9f1baa20982365790e4631ae3d199d0cd132177f8f3808f	4996
516	e7e780b55feaec1b8fe21e5f713f87645eb2d6286e901cd214b3a0c74b5b991c	5012
517	539442e1dc77119cdfbcddec867f54471ad4922aaec41482939b1291471742c8	5013
518	ff94d0b00261bd7fc9988080b949f92ac6eb8155f32b39639037d3f3de3cbb7b	5016
519	a1985dc6151ee065ab4126d82c9a2224c61acc2d94fe1f8d51bd593ab7c67479	5019
520	061d036156214666e85fb9345fd5654c81b348a938ff2efd657c6f24ab6667c0	5032
521	40dc77bc96d2e7ed5d56b6710b34085c1cae8140e33b1f2d87ba416be5361cad	5037
522	a4cf6176e81c817d35808e704ebb90bddab132276b8de78032c8ed7b287f2fa0	5048
523	533551b4502a3c47322b310227ca2d21fd2d8197af4b862f279c2974ab35146b	5061
524	dc198a2af1e0fbd8b3f1666b3672ca868adb5c637c7f1f8a643a5d74a76df7ed	5080
525	3f678b1086fb6332f10fa893c316c0a5a38a64b1e54db0fe70d39cc03cd8c33e	5084
526	a6b7b05084f09ab45b5c7495ccf502ab55473256808bef4d66435dec1e75d4e8	5090
527	ada27796e2d2b46edfaa4556ed8a2f26442dc446bc4fa163f152a19271e117b2	5093
528	e93f48a11a568fdfeb7eda7a0fa0813a281e380159fbd0281d4bf3aba81e0514	5098
529	3ea52e8a3e7568442f8415e94b141109cbcb2f558f8e763c951cd0fc9ed25f06	5099
530	98e3ec7be36533e07168a0752add98d15636ff51d65c220f622b2ac59ddced06	5100
531	ff90ebbec292ec0ef234f5bb2bb2c62a05412499830cad7da95e2ce2e7aabab7	5142
532	325060a1278730ab166bf5ceaa81428925e263a3bfdfc7324ca61e9b3b9b299f	5153
533	bbe15baa53de7c8a48afebe72b0b3707228e59b56becdb38927088bff164f694	5154
534	44e95ea0222c596551e753a339198678b40a5f919a300576738133cfd4743762	5171
535	314f3ee047af9bc871ea924e286b652a40f90fb064ed72fafcec30929268a472	5172
536	95fc7272c93e2bb4a2540fa313664cdddcc55badd13c8fd98542012c807837e6	5177
537	1e7c34d2e17dbcc3827d91919581a349b9b70aae208595992165670390a396e9	5178
538	796515df52337fb33879307067e6de6dacc3fe3f4e1288d6f3cf2558c65acbba	5188
539	e67ffbc6fbb9270a481cc0fe59b6e818899e3a4363f4c2b80acfb5423b1cef4b	5192
540	63a6682d3bc4a1d447fe995f19ed2caaac324dedf00ae5a46852698ea104388f	5212
541	1c5f13a9262bf2ba1fc9fd31d36040c6bdd7134c783761174f84535999335cd5	5236
542	c680fe7cda7409a17293b6dd09da86fa7c2b48e1b5a8f3d36b72d618163f71a5	5249
543	26b438b461c3cec2666bdc8be9e37b0944f1e606810fb324e6e5164ea20fe500	5259
544	76763587de06a54ecab1ccab5b98765f417e10cfa8e5c89dbba62b98137cdb21	5262
545	05e1e4d033cd9cecf16a8f80ea059877ccc3cc3fcfe4f933d41dfdfa8258f3e5	5281
546	506a57f74d6208b43d6afd7d239eee9cf8f3aa9f15a6ee58d63b815e8bdf6987	5299
547	9f012fa8355d8e06b16b14cc86ce78e09d5a64296f37d988bff0605a97adbde0	5307
548	573539002ef66c7e8c0c7f81e13e85320ec2285cddaed1a86587d97c2591d89e	5311
549	edbe1e99d9fa51eb9296bbacd1819ff52770feb692a4f1c7cd4c3e4ee8031696	5313
550	22f88ef75877a995b6f6b893f9fe16af5c3f44f1f4e21190b305ca206bf8a94d	5322
551	528de7e8baf3222d4f5a5da276fb4dfc2c15286f167a796e614c95989a3e7cba	5334
552	56135a257a8ed86efdbf76ffd7fd31dd6af77d1fe2b0ae2c34a28ae6f2f6dbc3	5337
553	8a8491b228b47c76d8e84663a1ccc8a27ee042b8b9d3a9f3ff6f28313b2fa3dd	5345
554	4d7941c8e0f95f0a613d68728e4dee64779cc91f086c2e4373472aea4526becf	5346
555	c283b4dff7e66d9344ebd6b4682b55acdd997e97ce8d2794be616fe3a5286343	5413
556	64fef92696be43ddd2d469e9fa2cf1def1d1a510a76e4a98d1b83997ee5be5dd	5430
557	20df1c5e211bb12b2f8acbe42977aaa14c671072abb95193b6ff77cbc49c3675	5478
558	9d3afa6075d070aa606f4b0b1097365e77fa6388786b3f75da7d7f6c420c5d61	5496
559	5193a73db48d87314520afc98f180b511e65eeae695e1230866f1c082121118d	5497
560	1c0c18b6c62a042ce5070c260bc91a121af52f7d10ed12ef26f86afe78bd9834	5498
561	17d2f86fea538f4663af4e1cf3b54c638d06b21b5c10f91b6f3f1e309eea6329	5509
562	11602e7aa8b3c997f19a2c3d98c72cb565f7bea3abf5c8a150795b3597b827d3	5562
563	361241c5fe2e4cf5e98c0eb65dc59769a7068a1480ef729d0a87c0755c8c796a	5573
564	72bbad0626b36f5c075a5a735eb03b0ddb42d1fd0c0289383125afb196fef843	5576
565	003e27db41ae68ea2468b21643ccfabed4feadd68c064b94ae9ceb57406b71d1	5577
566	a7e3450d3e5f9bf939502976223599621ecf616db0f657e1d1982474b2c94785	5578
567	b315cf6261aa55f81b58ecf0c38f97cf12eb56117b244abe65f154a8af585b8f	5583
568	79ce645f99fc3e92cc02df7b11ae1842810a32c7e8501308c98e4affb2fb8ddd	5588
569	4182601977f1a67dd73d8b8e0207b4b0d89c089be2fdabba33e5f38e8941d78c	5592
570	26adfd179d83bb4158b5f34414e49dfc47e529c7fe7ffc03c4814fc36092ebb4	5605
571	6fd9cb37cb90730ce579fe3b552b5c5e56d09d715a07141b7ea0cd82ce2df037	5615
572	359114ae6cba195a4aa7e967593f1bb8f508afbef11d0b152205066fa3161a59	5631
573	7556789cea975cf489cec242ceb72660166f2510cb05b939413412e9f8239260	5644
574	b34a379b95466e1d6b32da7088ab79347458d96062037a52225fdd7432fffedb	5654
575	e318a7ada8090c09842f59869f58f50c25fba28853a824c29f0227884d2d907a	5655
576	0cfabaeac9b7d29ac3de593826184f90993e617efa90d35995d1efe7a3765b72	5666
577	0012b345c52fe99fd476cc038411b5ddd7d452b1d601e71775dd6b186b43c07a	5678
578	ab55efaa0ba3f6a72d8bd840495dfa78b0665e5aba3c71f771098fa40723dff4	5681
579	6ee23418066ee112863bf27a833352cbac6295f0c089c89261b4a3391f5cbdca	5693
580	71530ceced84c825244a94e8810250dd1cfd280a789c88c14929dbca893c09d2	5708
581	9cc4bb690f3e5c64f248631001bd1b7f98b698f2da16537fb48181bcb207ea6b	5709
582	51a891610209d3f4889070a52db5e170c8b9c7a972c5b71659fcb7222110a050	5715
583	77b52e2cc87d39588b269ec87bdb99061b557ceed3a8fceb393ed656031895ac	5721
584	b8a2adeb24f98b796b6683ccd6e2d96fc424cb6214f96ed82e677920ea27863c	5730
585	7c9dea07ebc3ba0b69fa7b2b6bc20b4d2c9d0d8b9e258e7dc1ca277a9ffba6c7	5743
586	d3107142a94eacb5e2898f2c02d76fb1a977450c445f38887973aa94b85fe72a	5765
587	fd95f32f68cfb010af57f79f69032c012b6bf84031864f43f192695496ab65dc	5789
588	935b3727186ee3d5411869ad09e84754d5856445f199d46524dfbe42e4e52631	5795
589	a6c081c3a464232e5840f29d3d1ba8ce6ab4c34b1d02f146d991e13252ca0e1f	5796
590	52c596466782ec4c139a550c23727a79d740dc98abfe3188514ff423dbad1aa0	5801
591	5c1a26858cdf264d050f0c1cb2ae2636f46c3e5c7443112e44b9e5205edd912b	5808
592	e7c83a8d5291016ca0bcbccdcbb5febb876061e4f73cef6217f525e4989d7b48	5815
593	86aae35c582d3afd7a6935622fd4e02058507c17009edcf3fc7dae4eefe509a5	5819
594	ceb4c54fc0b192289c1fbb7f7a62ade9702f5d3ed3cce5552d052a75c023dc2b	5825
595	157fdf59e29248e8d6e031cc145278637ba31b5048c1a770773ff0533e36a626	5855
596	365941a8f8bdee75f601a13881eae6fbe075d5aae268584b3cf92c0472fe5a5d	5856
597	b0e56189ce1d74626cfead6b629beab8591f7ed6c0f30fff7efc606b806b7a82	5876
598	8d7407945d2db41beef7a78c13864640156ff95cae76d43819fcdec13966c255	5877
599	a1ca3f3e6086d4ccf9d0ecca066010cc93245917ea49e378be1ee0f78e62c6ea	5878
600	425adf9a06170f0551dc6ad4af6094287e61c2e492c6e9cd5a0f294e2cda4ede	5889
601	112dfe918eb5fa5793eee7b4f512398c6f79c6e38271d318dec4e25f8572adc6	5892
602	130c100ef43935ed52824f6203868e9eb989f93fd033c341f564e78f6199b4f2	5912
603	6e041c22300de0911c4115ea44b8a3561af0b25f94a0b12d102e8ef332f6180d	5956
604	010084336d426b016ee14b65c80a76aa037c0d638af55544531dbf1bf1bde98c	5962
605	589595ad30f0899e612d82c81ee8dd512ac9c7ca5b041d6bec54674dd902a387	5981
606	643ae8f61ba83280499408912a53028538ca97afd0131b9bf13d88c6cdde6a31	5999
607	b81118cc4fdbb188d2905598f5c84827445a43f53d90b23985c063c533eaf261	6014
608	8ee151fa0b9c87b0b244995a5a22820a041a543f78ccaa11fc2cd6f9176f9a06	6019
609	3d60f6be0b426a7f2a8b82d9c23e2512525286d14cbb8cbdafac07d3e175d3f7	6022
610	21fb87be34aec6b1d5aa5ec2ca9fe62b2a7f130a0ff47ea2f0b0d74e3db3f6d7	6025
611	46bec0fb9484868a9d0ca1003f9becd633afa1b3dca09482978a3469536f3095	6069
612	b0cbde3f252480fc5cc8dea6af47cf1d7ea19d83f31c90a0ba6376f3c4c7e36d	6073
613	fe63e492fca638307873ee4adc55600348286b8c5fbb376e8c021bc5da40253f	6086
614	38224bbde9d252a0fe1bf2961e8b3df0a5e35141dedc0e6218d3e9f93413ff26	6091
615	3d2215f81e8dec10550937f55415216c55be070cef44c967a05ca3f2294163ec	6094
616	171060a480676ebf98d6a7acab09afc117618b820912269b7c3037b390ecfe8d	6142
617	1e1ed57268e4d4ac1a1d656f9cbef1a61c069740e3a25238b926c0362cfd15ee	6152
618	9e7a0d788e57b43ca6af9c902319315a2b80ab826d2389475cb85c74ee29d1f1	6159
619	5f1e632474ae9de2dde40222c1ed71b1c64ad43c0f7e8182a35bc39e35bea16f	6163
620	d130482388c4a9035586a77d3e25e3e021797aa2cf231bbf57bed5847837e912	6175
621	69f10dd743a7edd8aca696f642ff323831b3fc5bf0c555ac3f0361aeefae22bb	6191
622	8108db9ac1629e6e9d5bdba674c82d097f524ce7da5e5d17f381a7e0581cd4ef	6193
623	c39b26d7e0ca710599c5f2f56f95cc880f295aa13492c7325daafcd08fbb4fc3	6194
624	2420c4b3b477c903829e76c85457ad01f7420104a2f8aacc2ea006e7245737c6	6197
625	697b2a318e330851949da59eeaf8157192c60acacc8f01d39fb8f2750d8c72c1	6203
626	b712a8a3f725b04e3c6327dfaf3a35226b8ecb82f3b36783cf3a96cf622bb35c	6209
627	5a4e1df5ee3b8f4a9942d91b9bc8ebbef96db3c2d6c159d15102e4db7fa8ab59	6211
628	06a2225717517e25e2eeee80b3dedf95c260db391b0c680c7dc293549b781ef4	6228
629	52440e9d2326fb0be8e434dbdada6065bee493c605f66d64bd389eb3723a0549	6233
630	fb792445a434090acdb63393789627198499275a373d39b20c67729d3dd07387	6235
631	60b536470890cda2c770d13494d62db51d63845239e1dc0f121e482f4d47ff24	6236
632	3b85ced76c44a7d2e2fe529a9e5399b05eb5c621c398e92de993edfc752170cb	6248
633	0efe777251d439bd81758e26cb484a2c2578aab347836a7771c78893b7c3e532	6252
634	d89da9da1ca24b2f4f16c048e0204ddceea78f06a15a1d1f85bd2c611d25d836	6259
635	d8d4be0bfd30d100c60fe1047fc225809d4152a91e7b18039bf7eb85c75e5aed	6263
636	9acbdcca276579cdfe336b219fc895fd1557a8a6d55cfeee6d0c70feb3698e9c	6286
637	6908ad2eac98b09c7bb9832c4bd485da5770703d8714b9278164e6a4317ba081	6287
638	90b9451671a84c87f682b530729bb0064d24bd87f11f3653b0ee9450297f4dd0	6297
639	676633938e54b7f60e1b83f30251814a6006b9ad6ffc262b4b250ba3c39740a3	6365
640	358ccf6abd7742c6a8a58e9d2b03d48c991d3fda52402df0474a7f5a842c7032	6386
641	c567cbe9dd0d8c7a6b953ab22444b789dae1025c0ff29046a599ca03a9277414	6397
642	7627dc6fdabdcb8510f01751edd9a6713f50d5a24995b6c1895f45034d2ba966	6412
643	fe981221eb1a916b189f570d26036cdb3b091fed30c799cc1009aec2ca39bf5a	6414
644	8c29e9d39cf7e0110122ed25ebfd2ef476aa614f0a112e3ba054750b279dd7df	6438
645	a6123da8bb03b37010d92ba8726a497d74dcc2a19e061e98104f15eeaadf3520	6449
646	e907da2576d5bfb11c69e6573362cd93c5a15711508a00f7248fed2eb9c045d3	6463
647	41258bd34dc8855705a65e333dbb92cbc5544506c0aa731bb64c3a5b03c468fc	6464
648	480c8ba29092b4cf01658f4c58e3412b84bed3d6519a1d118c32182c0a5c6e9d	6466
649	e88353d6bc087f01719dcaa9fd8050b8d5857cf946623ee9f18a87381ad1a758	6467
650	ab5a916c95dde8e629f061954b7c478bb7065d2d594994a27d204b059c43253c	6475
651	ba0a6bb6cf141f1c4ceada0a902e5a4e2d9c1c9ecbcde7c5ca752fb8928580e4	6478
652	e985685be3ff00d69b422ba4cecbe593c3eda1304723217bf24c8d74427fb697	6488
653	0893618a79713ba1c5006dd23c81edcfc77d04fe5d9b6618f68de7f68d7e5c0b	6505
654	c5d93f20be3965097a961737d74429a465035695e46c4e64a24edb45890f0082	6512
655	8a5799918485e00ad8bbf2ac17f281fd7644cf8e7cb4252a6e66109e6c7d7bfe	6516
656	987e36c38f9036a88c67370a297f86a48cdb9256866de3c8c0b898b1e5114a84	6524
657	af6f8faf7e7678cc15b25f33cc9df0914038ec81d4f1eabe2d1483d12153cd12	6530
658	9887b1794d2e5c43a3cde1560505f8e3539ef2b49e3949bcd603c3d5138d91ce	6531
659	a0707ab11c84ee3192b065cfc6936a20b43f80d6a28fef620f7e5950188c5e8f	6550
660	213dcf34d07753d84b003e448f594cdd171c5f67bd0f7c048b83003ab83f1b9d	6570
661	92c99c8995a2e4e189a65855d4a70c0b0295fc6260370c7bf67f77d007fb4b2d	6597
662	97ad42ce025ee5e75e3798693d2faa6d06189d17c14dd02a2e1a8505a008c2dc	6605
663	e86e40c82db447bbfe4c823df52efcfe61bba2f51e62775bffd604bb1de24842	6613
664	bde003a8c780690b38dba46a625a4044b1eea6900a9e3cd215be909a03517e3d	6644
665	921a7c698b4d6133f9ea3a0e24b902d6b7eaf9e6bcb22f76711d335df3cb10a7	6650
666	9ed86f4a623e23a074f7c74d81a24da85b6095c52ace5274753dc152710ae55a	6681
667	bae5d24545a48e076a6e861068fe1663e2e1d986d73d63083817a6dfdf4d2be3	6684
668	e416542f2cd6f1006cdfc6c6187ff447d0db7c77bd013033f0868a16568aa844	6700
669	e6c935d51f2975edad7cc08c5dfc0fb412566672ba97e571b954d4f9beb4d93e	6708
670	962ec69a8790a2044317eab03cf7bbc34e6fea7dafcc03482024bd6284ae6e93	6724
671	05762296af9f54bade61c76e4ee2306f83e41f3abe1aea26c12fbba866a2ac78	6743
672	c1830266ff574154d42c12b8e9aa571597dd02de006289699e124486d9d9ec4d	6754
673	9c9964967434633f64cd68f7fd9aa1e0f5eafd53150e4664a6c3c0aa1df43817	6756
674	6caa7de0f628d65dfa9442e15305eefe03af56ee0fb1bb6c8d1a56cdae6eca26	6761
675	d9598e83d9c83074d3ed3c21a448868b7fd4d71e67a0ec924f049680b7b642b1	6763
676	1d1444ba45933e7ad050113b07b4155ad5ee835f6892a0e7c23fd2f2ff45aa08	6765
677	30dc44b14f22272eab219d1a47bcc740af59ea2c2ecb167bbeef8f45c7b27ea8	6779
678	449139f6b18dd680ef5eb539ef16c6ceb0529003e0486779095d82e929cf9720	6808
679	de7c60435d552336ec86773dd0ebd83a8db3deb104549289cc325b0b79664c67	6815
680	0ed18ae019e1998a24cefcd7f1201699e7d0cf88563a9372ce9e5ac89adc83ba	6819
681	35f34adf96472d645320233147efa3f58bfebe50f73b27f87e78d45d35c66d5e	6833
682	7213c30f6fe2c089879c01f24e5d11cb6b18ccdef6b126dd410586a116bc850b	6848
683	247dc9eb4a0643a14c7f8aa8d6f128b898785e22db0ba00619760ee52eb298e2	6876
684	145c2f6cbc6dd75893d3125aa80ce107321f1317f8692ff6a9a8e96432f837d8	6886
685	e5661d07c041a6d49bd5ce787e8cc16a75fe420ac8714cf70da90c4ea8fb5564	6890
686	a78e232e8b09cda3f5eeea713bc36047d1f9e47605988b75c2b6d32ade1c2e8d	6897
687	9dd35d1a0a61bd01be240c8907dd324ec2931891e214a1b0c0ceb5b280c06a9f	6899
688	ceacc143010398751eaf86933bf59f9986aa5df0a8b4eee4d051c76971724d8c	6933
689	b6fb260cdd5a532dd0ff1e146be0cb78bc5e0f4384f4de137b1aba0564f3d219	6935
690	2610cc93e265f05f3203e3cb8c23d9e985372cea73ddddbfe85cd3d9876dfdaa	6941
691	2b313d990fc6b7dfdbff2891ef3b152c4bbb590198c0cc5742e9dcc89fcc0e11	6944
692	c24c5296a36d30d3b1128b7fb14ad2a86aa7d9d722f174584e34cd6404b78b03	6951
693	f9b4069030532a2b7f02f7fa75f35bc4f48c51418bb341e35a7f0508c2d7bd63	6955
694	715b10be5b87ee42152b3abf2b57f634ad9942926a4a7bc2accc1620b5eaf175	6965
695	42d1deb6e63b7830abaaf42586a9ebdeddaa7c3702377524686c1a06a209ee21	6969
696	b4e7dca3e0cc344ba24b46bd747c0130d804c271d699208868ae19da0d742a18	6972
697	f76cba784b01d74b5c3dc7a92159feb28cd7c51dd836483eb7fc7ca85f7617a3	6998
698	7ffcb426c0c746fbf72e7c31c85c140fad0c27bf4a7825f7e36b145c63280a0c	7009
699	aec0aa234bf724856485253a941c03f27029c441cc7912472674ded9f8e6ea33	7011
700	ed59249075f47d100a5b52c1ca96e1e7fb298a262c6b4ab477aa1feb426e07a3	7029
701	6255d51e4aac904ef9a037cad3c90dd82d250ed9b75166ae75fc5f1ecacac3e3	7039
702	c08c41fe62026b09f047a41e575d6b48bc1352d19379857d0e586340e07e15a3	7069
703	ed469c38af4ce98b5ce887435f4e68062df2292b8ce8f82b3041d90c3b1e568d	7079
704	5cacca235ab1ab84f7c5d2184410682be85622887be05745e152f79e006d2b35	7100
705	004973e46ae00fae6adb03e33039116a7c942b1e78c5130ebce63b2c7ef129ad	7111
706	231f7269f27a1b68599167f13c9fd59934bc7398c76b309d3a0ba2301397d83c	7124
707	fb1f93b768b4cc900b25f32ba6649fa97c4062f919577b635e4582418da1d13a	7132
708	4d2f77458657f38e4619bab82640ed6e60b2b5bfa745591943c6f01231cc39cf	7136
709	9cd0b1b5a02c5f9671891253f1a6c0ffd459c53c2e3fc2e2197a32975991fb81	7141
710	264c0bf1ce90e45a4625c2aec0d8f028db14255ca42db101a075c55d826f4309	7172
711	20fb91cb22097f1097042619b2d0abf7a1a22fbdbd454bb3e37a46aadb35256c	7182
712	94849d166ab26344f3a2d1e39aea11c4cd9d59a9b12356b108d367acea9fa062	7192
713	d01efef157a4ece343764661e919121e6ac94f9cd8eb81c3645c198459b0c64a	7195
714	91dd29f7fc1e36d8bc251a269d04d3a9e688dfae1168fe047968a321a57be293	7220
715	1c79b0ee6f0814e2cd3aeadfcc6fb1e8d803819d77544d031d143328b17b97c4	7222
716	28f8f87fda606a84fdd9dcc89a03abc8008300d023360d99cc5ee1357c5e2efe	7238
717	443dd06e3a03cfeaa234754970b5f005df6052bf016cac5538e37cdd462c15f6	7242
718	4d7fe28a55ded6c56f24afc4d1c24919ae9052e7da0dfba8a8b4bf11a3bdb401	7247
719	b1c4b702ef4814c04b0ce6c5755026cc71f3df9883cb1453e5027b753b66fee9	7262
720	d26fffb01e73f0560d20b6599ac2884f571a9cd12b4e695e6dc2a5b4074d8af9	7266
721	8496288abb9b75e2dc823ce35708d126f11e112ee6db7b180de97f4659b2b420	7305
722	9487448877cb30acc34bc600f7f1703252f391b15cf01e1e794cbba2c2fbab8a	7310
723	70802eca291e1a9aced9293d03ab5898d1780002a922d17cf5724df74d5d220e	7312
724	c22b0fa2213288823ddd455ccf7908959c56211152727ccaf2f2be2a0ff027a2	7320
725	f1ee5e5f6bdd8f41d1b6fa0aac6c7807dafa2e0da86c6c71062a992744d3dd0b	7327
726	83c918b4481e27174faea7a6ce48286fbde97b45480ed8ec26411fcfa046ddd1	7356
727	0588becd01153a3ccafbc3816f571e39ad0f70168dc607bcccb1122a48d9f885	7370
728	a3fc8fd6a89cdf35b2a495870c1ee52e69e5e803e651da4c353c1912542229f8	7372
729	ba84a4f6358f41b5d1a8f46358fce017e050d5c8ee169dfe73ad7b9b1802dc56	7384
730	34cefef65f2fdc087876282e5e300e55962b2a5e9b44fc6127214dd7eefef3ef	7390
731	1be0c3cf106aa2c5fff22ca2c1df081f4c1b14f00f800669a0dbe7c2f6060c58	7393
732	de2dff07ba419a6578992b2b5f1ba4c4cb81ff7420f3ad462d4acf342951e0c8	7412
733	923082832ef2833a6f2c79bf24d9af72345eb4d4fc0fee4ab50d468617f99912	7427
734	1ccc344afcaf0576d3594fed61d393585d5d07eef5606ccae6b60157a8ec9f8e	7441
735	f5dece5a3575ac42d47aadeef8714659853fdc1e57ff3bc663d6387013d981ca	7446
736	8ec503e66ee63935b508b156fd9bb95e08747308755a29cc427a28f593bf7de2	7447
737	40fde31a1a1700dd72331b4fd30dfd666158ca9ab2f0b5aab607648fb8d7d412	7449
738	4c792800baf12ebb172f56769427fd4a61c01c75611cbb7d01d35d283d73a6c1	7453
739	2d83dbe0f2ac48a4408a31002b6691a0df68cc023fa7e1ee3077e3fdec64504f	7476
740	a5b8c966ce93dff1b5595bc26586801fafd88b2b9ec812a4f04483b7e96459e1	7493
741	9a9cad57a2916df59c569f160919cb39166f901df58ebc8f88c8bacb658dace6	7505
742	3f72b81385efa9da2b3edc8e3666ebd8f3dec1d7456980ef04930ebc5427fb39	7518
743	75256427a9cd728cc945344c116463fbf69284d51dd85870d7760e3ec1f589e5	7525
744	e9c70d2ba2f3f7fb0abb76e221d4f26d83ab738e1eb1755d2187e7befb04ce09	7532
745	c38071fae26c6d01e0c45ee41c0c6e22223e4470dc37e324397e3e357877fc30	7540
746	959550866c82c94e5acc429d2a29a55dc6aee6242b12c865c42664eef3148c36	7551
747	7bd3cad99cc16555f05214c50651ebe11726cf09ffcb7d0dbd072fc0ecc340ee	7571
748	482674c1495241c9817bf87449b28d0d5ac061eff910dbd9ff8aba4d44f3e04b	7582
749	840a6ee1f642fe8188feb1e06a468e06bff42690f636d76bd41008c8212dbf8f	7611
750	629266a69f82e8bb43117896c1e9f81bd8dc9ccc6480313266e0453ab74a6321	7613
751	38744b3a5ab76a6b886bc9376e16c189ff12c03fa9271e1f8f0feaeda8ec17be	7633
752	812246a9a0f9f5cf7c544952f696bd17abbd2ed85b4f79cc2b999580311cf963	7636
753	c332cf57b40f864bb23d53d143d9cc3a01f48b41afc758332e67ddde8750e3a8	7642
754	7939bf3ae67e955995fcf767fe5b90e00679437341c6ce189595affc87b43d28	7643
755	a445ca8ce26235764ae21b05c73b952f7d458226429388fada95d09b51c5c739	7645
756	3769c766c29b318651eddb0de4583fe89373055c110b08535086965b93d53ec7	7649
757	fdbcec77e994604a3f2ad43ffbdad7f07f2092a3e1287719533e6fb3eb9bd7eb	7664
758	561c0e008a93c5845d4cf1617a3ee7a2846c9648820531b78b923e8fc7277f89	7666
759	a02e8e1eed419872da77f957dc8a4afaab8cfe8bce4c00d078f65b6c5ed6f85c	7683
760	c404446129bba08e0152c2c378596a215dcb02035787b49131bd8f3ee0d3dde8	7698
761	883f810880b578252aa020b9d4c933ba6f678c75735b1620f6cd711af641835a	7708
762	325d949163a32bdf328e02a716af5a9ae075e1ba7e6899d371035e39476f98c3	7715
763	05fc1ad458261042c7ff04630278d373d4c3f438d965ef26e52f46b8c4d032d0	7734
764	abcf675c454b96bb53e24592ff4db2e4cdea66d818e75a9d87e3dfe060a2ab08	7749
765	5ab3710da901c745f0315c3dcf6befa8833e25302ee34360850d1288c073a907	7751
766	a27cd3c1eafd3225e668b015dc6ae9da1966d4ceac16e1639cff9bbee3e4c84f	7756
767	74e6299b485e764ef25534fe0b0856685b59dd6b84ac1e193a61c38c3333b50f	7760
768	d67be37619933e644f5506e5aa2bcc19bb5f7d7ee865451a746e6ea58ed30db1	7767
769	b83288d2515265a7b3a1b29e0c3e9de286ffbb463309556e800a3b9c980748b3	7786
770	8750d1353de48651501cf1244b7065b48fa8a5d0ab6dc968931c4e1414f2ffc9	7818
771	cffcdfb95003796c2cb9616d40a1893e1222efbf026c35d5b431a5985b051584	7845
772	7823f5c1772f16b190672983aad52eedc7ca3a8de44c15239f21d5fdfa8566b5	7846
773	fa15cf34827217c623838bcabcf37abe304063eaba980981a94e0803d7d34fe0	7850
774	c41b125094c0f0b075589878b4fdb0685fa4ae1d64f45b69d5adba1205ac81b6	7851
775	957155027cb42fe295e1278ea2fe3bb6ffe317132c31dcfa32f3dfd5bd16e423	7861
776	db15d1ead4e4a3b9510a718ca3b3f44c18a6abae58945cd68edc0c9463b8deac	7867
777	37f2cc1eba8e493f5fe3aa2b80cc3af9571c88657a556508fa816fa03bb89200	7869
778	20211dc254d0f1c020fed8e29b3096b80513716be71797e93cbc541a295f9e83	7874
779	2754b8707cfa7ac61616be84b2f6ecacfde93bdb003dad1952efb32e99029412	7881
780	a0c193475049ab875a63c8b4290da7ac6451ed3b1e4fb29580069e91cc72898c	7890
781	0a1f815c4dfd8a1b6577302e61703f5acfeb9089b4183b2c4acf81f642c4c370	7891
782	e301a43644e01350ab9efa11ffb9a1823af404bfa1c40ffe998acc1e76148f35	7923
783	58e00683988ff5d04677f3d849c8a09f8f568ffaa78571e202dcc5ed3f2d4884	7924
784	85c6741519375c1a2bd69eb156ee61a46127ae216fa42c71fa87dab43fd61b1f	7945
785	9a1bf25550ab82ccd9a68d8458fd94ae496f3c87eac747a216255384bd5f4879	7947
786	46b953159e93f717cafd6917c2c6c876c58deb59829a22597375627d21a1294f	7963
787	32c3835c81f591413ed60ecaf71a0e49e494f439ab20e52017155a92e62f36b7	7972
788	bb376722e7708ddc9dfd690fe64a7bd26c1dd496242d94a12a3db3919adbb4dc	7975
789	2ccc1a54ac57433d9c246ee4e5b51eeac53e32685362100a0fead40fdf00b07b	8002
790	d860ee08a588108ce06464f3ee2aa811f06b90d9df3bf82a7ae30deba48c84d7	8003
791	08fcd4204bd880403580854caff3d6fe05672d386cae4a0b26c61fdf8732afab	8005
792	68a107f430a1bb9dbbe7ae797a077b005bbb93f510c0a24d6ab20bb0158a7512	8019
793	88cc0955943f43f6cc00db5f05a4d07c8e68e7d936d0f91b8ba8e23a97d2f384	8025
794	edd95f61a3c2c8c239d49b1317e9ed1c2c2f47e29b0343c374240cb2be619eb8	8030
795	4c3d74918cdfecc463368cf8ef6114cfcc6473e6a631abc3b84d9f786bad3a2a	8071
796	911d1f9bbbecd611de2ff50477c1c1df495776058da340b27ba58ddc0f474a89	8076
797	d8375fe7686ccc09185171f2ad2cd9aad4fb75c52998458d5c7bc082636982d1	8081
798	1a21986596ed318e66b5dee513b41958e703a1bffe40d9dd2502da14495ce20c	8096
799	de67d39e5a156cd62d019347de5690fdd149e2303d0c784373b704c2ea864216	8099
800	c0c968f317f77825454919aa698d78fa97e1773cd16904ab8154b63a51ade1aa	8105
801	7c6e2f25043faa9711c75386a8fedf6fdd18dea82a6f77f4222d42c3b665e202	8124
802	b773f4eecc363decf135d954e0fd63bb66252214e0710ef79ffee2fc8e9f2ddc	8136
803	03fc0f663db7d4d6704ea64b715c748bef0159d9153f515b9e8e54b56110743c	8149
804	dab9aa86dcab39e3bb08c7b7ff918203bbb8ddecf3ac74e48bbb5c28186ae868	8151
805	8667345bf5f7511fe7dab185860f5a0ae697f36446b78cc5ecbdba3750489678	8156
806	dc64d3c73fc9cc0f4640ca65a8ad3e6664a6a3499f269fd0f9c140199f33e158	8190
807	4038538e44710154a6cd6f8d8971f23b7535cb323faf9bf4de5afa56c7b64b57	8201
808	e8d8ebf90de858775e8aefe8e4f80de3efb8c0bfce82d64752af8afc07006233	8228
809	a4af9fbc66668383c27ef1f725bd68b2d28d5c4785f51e2af35acbbc2b6c6074	8240
810	06d33a3d09aea3da2aa8de61987cfc6d482bbf3c4a39f92b528291ecebbc7769	8243
811	7859ea8e58080ab1ab4137dd025d174aea48323e15ed0a7a4dd0c64630da0329	8248
812	ba9d761f26637be6e626e98bd4295ac209551cf2a1b729eb168275d3eae46838	8258
813	b221338f8daecf656684ad602b5743137d650a7abe6d5c7739deb109caed22b0	8271
814	0d21db474d81fe505713247a4d926f27b2015bfb32b6b4ec8634440fbed7d8f4	8283
815	27cef5fcd7ffbccff30ef4933c5422dfe096824e227bdb1dff738d89b2f61255	8285
816	f1f5aae89625472044932ba7e41ecd46b4430f5b8aa55d38bc8a211e6b4e41c2	8305
817	8d138fa69bf7d53e0e1c60b3e619711032883256d39475219ecfdfcd700efb65	8311
818	350629bcf5f229487c1b40efe97ec940e976504a7c6f7ba3f5d36aa6d18f9232	8331
819	fe3e389b586ba8f4fde2c0748e2db46705a2b2dfc52ea8e2ba20eacdef32640e	8332
820	f39aa64f69edad7a9c39895498df50e8f2d6a0f20f4f2a337f5c5b7d57da3dff	8343
821	b48b087242fa1dc0eecbc8be15980a5bf1c209f887d87bfdf31ec0ae01296d0e	8360
822	603550e0a62bc4df653d5772a1155e978e8d9d1f3d0af6578aeeffa996a82a75	8363
823	443d191c0dd2aa4f2e7d6672561257473aa0762148125e2fcc4d625b354e89f9	8377
824	5d5109c073fb28c3c5e323e73122791b411eb68c588008d9ef8839aca2b5dad7	8379
825	a905d046029e93c0abd4f9b557ee2e99658123d7c8bfcb56debfdfb7da1e60dc	8387
826	1a577334432f64363cd0333d0261e060d529cc8a570a69d4ee6ace5be4ceea52	8388
827	407ba4650d4f3b1268a8b40368ef6617803bbdf813c3cd350cfc98ff812d826c	8399
828	849ec44762e4c8f09284096a7428a31389005c9ed3c9edd45558b899eadcf5f5	8421
829	ef4fd52448a45329f3000ade50c2b66fe5f32f1ed81951c64d4de548317ce7ff	8423
830	e96ee8d93c6cb0aaafbb1fdff5dc73b279b3f041cf5f309dd792c842319056ee	8434
831	65b072ee152b889690528df351bc04d5a6d8649bed3f09b76642668e4dcea2cd	8442
832	2c42faa7b8e5674428c1140281f32b47c165a7e247d15d46c0b8c680a286150e	8447
833	04244f7e79ff1f00852a545c33bf68b52dd0c50efacdccd2123d4739efc325b7	8463
834	954535cd6dd01ef050008febb2212f1211ceef250a7f1348d059146d2192c0ec	8477
835	ff08f18f5000d9cc82a2db5f2c58cb10395c1023693100df41dcec33bd0df9f1	8489
836	9596eaf38f49d74dff0f95954e8d10fc3794c146ae73ab060a4f81061d3cfb3e	8495
837	138a94da6acd5550cc0b6d73faad22b098757aab1fb60073f7e37f19b91e1d3c	8504
838	7f947ab47fb99352738104e113e509db01f6f213376d956cb0b9efd3ec3da341	8521
839	07ada113d9a06650788444becc825c3929c317f27b97f4e30dc0b96885cfd9b7	8537
840	f051b412ac180352769aab349764015cbe7dcffd493112f32503cfd101e502f3	8547
841	e745dc5d9339badbd368662b856776741bd25b3b97ae35c096dfeffc061adbae	8551
842	08aab72e0889c33f0ce34b14e32712afbf9066ca898173859518d212b69ff39d	8563
843	3ef4ba1cf4ddb90f920597a188e516ffa0ebfb25d48b6ad29597c84fd555a53d	8572
844	964919da24246ba7a121b0db0b3d0c6900eb6f3b3d2c015e86ea5a9fa913bf97	8592
845	e97986901c9e1492b19620c4c8438bc1db8f6aff975bc51791f15aee7ec907c3	8605
846	2f55537c154bc4ed83b45b227d1dca6374767613cedc27d3b5677e979e24d3b0	8631
847	fb8ddf07ed1d4ba56dddfd10bb17e8dd5d791b52a0946bb98eb143ac2d36a397	8637
848	7beefb6e7d28087e8afb0a8f512147d1942040e998df47c5d913f8d531e10c84	8640
849	98b5d5f7bdb96a2bee8e73e75f73cc05524448025b6f761943982653a9ce1007	8644
850	ef322d573c4f5d1e2447a707dd375329155be745fba0aba05bcba3cbe762e960	8647
851	0fe407185b7a2ada669b87759d33817af799fc33c70d663aca638168657ac65e	8667
852	f863d4e755ace6f6e91d90cde8a8742f9a2e5d5568703e28f62f6b0270d233b5	8669
853	1b462de35eab4a322bcb316a22ce22194a2ea42408c29299f7a406d5e12ee540	8672
854	cb0ef311a6208fa1e409f23b16bcfe05eecebb20f89a1991eb22e9dbbb5f2420	8695
855	92e56ab2843ddc492e7f2977f96cd48abb142cd5bde83fad51ecf172a2e8fa60	8702
856	69d903321dedf798143b6d761473468a6864bd3ab03dc7d84375b75625805952	8703
857	8c0bdb8ba9ebf131ccfc8445b9178a2b6adac0a515d9b45568378d63821ef8be	8707
858	3ebf6403ccd903ef5dba3d9ed77f508e96f013e686ba2a6c611d00adcf787ed3	8711
859	79786ab0733111de24656cae86286ac9745136eb283c6c869c8cdab3b2fe2084	8721
860	81390968f23491a5e5c9f6a627d91325af8a650e8203d3fd75a5ee8e7e80f338	8722
861	3662c12a83d3ee553a834805bf66ea277adf4a769dbd00d45a596d050a32d737	8731
862	63ee0927bab600dda4a421a35c74c038848ac128b6549f6e79ab1396e16f01c7	8735
863	a9b16f266d61967bba31c63635ab7dd0c008c972f76e1961123bab56a6e6b6c2	8739
864	8fd0f02ddaf38e52e356e7cd8139a22d5de8dcd6d3f9685635ecf84bfac53f44	8749
865	959e8acef547d62660f912fc2b28b9640a3c96253de43e172a3ac2a7def3387a	8757
866	54833f4526fccfbb191732af22e34c2326f93e3515d8936b325cdfb5a131726f	8762
867	1dcfd4568a1d86fba9c85224882eb5f5cd4e92a182be2cf73302d099ab7b85e2	8764
868	815ac65883f72affa352fec2387796c4259bff1fac357764c5992f4f1be47818	8778
869	ad408815ffe852d4b234ca05fa8f3ea07f7c1ba0b7f482d78ab478901e61ac99	8789
870	4bfc7d40c9f45b600f86b9f4a349956963772edccfcbc3a211cc8f266af68528	8792
871	d1a88d59ad1d784e83f7cfc59172a5efcf0e83b23c04dee0df3fac0de67e0f2f	8796
872	0f9cd58b76cc1dec1e316bba2e6166ea74713b3448442d907464b7970bde2a19	8815
873	fa3d34390622939fb80eef709d22b5614542cfcb0d43e3634d46f1ccadc83dfe	8827
874	8656636bae6cc9b0239b39ce4a8065cf362561292155f0b36f2bc2e0dd5214e7	8844
875	55d13c9e248a25499a755092d18ec03cbc182914877f705a859e0038e2f59c9b	8857
876	860491b3ab691a48ee219f368a0a062a82fec7db2208557289b1be4af37a9402	8863
877	93c37f71b50cd22b4dde76be2e04f130cc107f2bf231c314b278b7787706d3e4	8882
878	0d99af1b21fb060740e2a1d0b3ed8fc929bf7b41f4877d0a9652d80f09c5775c	8884
879	f2287e3c8439c068c9d7ff54ee742d643c1aef5da07b4fbbc2ab4c00265e2eb8	8907
880	a35fb599e2ee30b2d8d1c12068d572a796f44e69cfb32bab65728b2278624bdb	8913
881	b9672f9a5b46667b044f16e03b4216ff664c084055f4bdc150ced3dc6b11242d	8919
882	83f37df65f69a8c15020c51f70ea7c2a90065181ccd735cf8ee2fd246433f06e	8922
883	d24ce643be2c154e36922dc4da7dbe9ac248fb0e8093285cefd2596568ffdcee	8924
884	c006c569cfafced43345b4af80fc5ba64997361383a3e6806a63ff21d8e5b29b	8926
885	68b49f94a00514dc174ae71edc0e014620089760b84d681a795fb42226d87aa8	8930
886	a38b1edb3517bcd1f34c2e53b7af6b47114ae3693ff2c5af27dbffe12fb37fdc	8951
887	3138fbf6d6cd278cf9dd614515cc608e33c6e0c83eb9e589547a19faff6902ed	8960
888	adb9a5d1e615b899a2a42133b3521f2a1ca5b860670afed1cb1d53375573f19d	8970
889	2119b1e89eb6aea1a22531460a52d7f42b8e52ec2d30fbebfdc8e28b0c3b4476	8978
890	a0bc9cbb9eed17233f64fa388099b405fa660badf1cb0f9f41ece8000c6881f7	8985
891	03a17ca8ab94625ca2f70462af403c50492ac41a964f31e1315c2e3d91757468	8998
892	90fa05d5c1970eddd9210cc3827187aef91b5a06a7804cf4247ae7f2b1fd4fb0	8999
893	39b9d5213f966e7bb8cec90df11ac6f18683076bfefbdbc4e394b62b18407a9a	9016
894	9e9635ddbad657737353c3b7c92be157406b97afaa6d49eee33ad0f16cf5b841	9021
895	ef4068869981b5c13a2952c634af1b2e066b928e99ab61e4fd7e97585857565b	9023
896	b0de56da725d0c92bde161410b8e2ead2a0051bb81a9597204bc726c277cf769	9024
897	b6284c786e761be3a8507ebee032b35ad3ae912452a96a3991b9eb27e440c7a4	9025
898	f1148529cbe22df7af78efba9915db64b9007fe8ed4b2c1e1484863ee2cf0848	9033
899	a173c00be2edacac8a1e5f28536664fa38cb6c077c1e15d494f2e4a53db7511f	9053
900	ee99dbc91d935415453997b9cafd7e0c11620ca5f612beaeb9b9887d411162a8	9057
901	8f026d23d1af8208f96dd18ac67b283ee790b569e7e7e0db47d3ec91610bec5c	9078
902	e34b21e6a8054d070ea3f710a473d8f002c2d8308402cdcace8356b3e30d4950	9093
903	71e50e9a32fa7659c22e172bf7f8c6b9b373a7b8da629e24743a50989a3befd8	9095
904	863dfb5a6cad62c375a4282ffa0725fe3ea66a18c56e911ff2e67abae058286f	9102
905	9f692c6502bbb94dcbecee58b5ddd5dbe98b20b9778b3c4ec0350cd7d84ef2ea	9116
906	f0f01badea429bda3e4b69cc5d42fe2d7d8ffa72d667840184fad503efcc5f11	9140
907	848b834b0d0601394feec58b935c2cceb397b73155514424b4e207540a16c308	9148
908	d6ad60f5a198c2875388e334c8d412418135d7e7143fbfbe6abb2fe6c52dc62a	9150
909	514b9a20d7b3aa1b616704375e65f9f7d2a39a9aba6e5ef2914cdba3c6a1b56b	9170
910	b6157050e963e750546f52a885f60d2b7d829e194717d2adb880033c5c1f3c56	9177
911	52621d4fcb434c95a35615b088d3729c9a5a609591bcac179c1e15853270c31a	9181
912	17de0346db5f2032cc62c0bada0fdba9ed47c68b7d086df7d153e7154409e3f1	9183
913	15f6fbf04cba3c62be90d9844082dfb2b97382faf2dfc567ef4d6d9f08537195	9208
914	94aefcfcf30d105de5b1d7fdd0a222370e4024cf95ff0c76c78f8c77fa0ee485	9218
915	e691a697e2df4440379998ffa11e8f0b0205cd683f245f6a817ad03e02b1254b	9223
916	8db3171dd9ae1bf97563e13e76edcbaec7e75e148e75c261a118f3e18fd637cd	9226
917	f6231040671b1748e222a101f561e22af9d1022fc37c00a5c34fbfa4af90ca80	9232
918	10b14ef0c61ec3cb8815b60db3e3b0ca92543ac4c1cf4a06fcc39be38c373b7a	9234
919	8444c2f4f0651cfe4a14a2519b921ae652e9ca5f5ff1c961c8575d7cd07adda7	9244
920	f8cd71f8e646362f27e14b2733381cf3385f2354df3a3228769e56ed3d01a1c3	9246
921	f7244837723c610390c62a92fb5a5ba3881194dfe6ff60f15619d72bd5f7471f	9251
922	c2a0e58030a7aca6255f407fc5abab43273e4c95185409c67beefc80424a186a	9274
923	92c6c4377c50367abf90cae2cc80c6637cb28d192612b6709f82e85f076e9004	9283
924	b2ee68db024dc8c0d1008d056db99873afd286074735e36f340ff3efc6a26a85	9297
925	8342e1c8d3712dd36ffd30e3cae4100caf8cb748a5025a9b24a922a60c00a78d	9299
926	943b2f45510e115b653dc602a256e26711d37696196844efe37bb0d717271806	9306
927	548a7b692ad6927160bf281320a7b6483f108d49272d669178d0b1328afc484b	9308
928	1c79a1f80339d3de546500eea0c6549adb8c5634d9353f1e9d59fd0af977f3da	9327
929	667ae10d695e88e4f034adaf99d98049ac3ef4ce3755dcadfd7ae907e6ad7136	9334
930	9c694d0a4e1bcffba11b6cf72703d3a2b69dd8dec9849bea88963cf60b4e1ac1	9336
931	d8dbdb0632972629b238fe634dc8dafa7d9a0e353563f993f72ba02df7512730	9337
932	6ff0546d800b945b47b5666dcdddd8ea3000e31c3ca4d787cf950307f6fca69d	9356
933	a1bfc9ce7595871ba011b8b4f774b1cfce6449c4bbbf726dbf4230b18117622f	9358
934	02b78a802fc3f141859901ff70b8a2957ebef5f2d2ff82ec7c189d57506904cd	9385
935	95a38322e1da1973c0a3507b203c96088eb63255a38731b21bf803c29d9f6df9	9392
936	d980101fc56a32ed6abf486f5db906a1af8ace2fddb67c17df7d21399348ab7e	9399
937	c025515f6f8b32008b452e5e01adcf0b9468de4ba8eeac847ad9767b11a79d03	9404
938	821389b9ce9d09f49835c07d8e7ebdbb34e9d6b69d7b02f8632c14476226b5ca	9415
939	f07d535a5797f98a465db53cc4ef07be76f349924a3451d72d862ef1f53c644f	9416
940	0a1ab51d25328ee64d4886148f3422b5a2539ee44afd3af1b3aece477d300ba2	9421
941	9105eb6fe9199126855f0573315722603ef896153602abb65fd1ebe5cf62ec7f	9431
942	a2c6d4ca1048aa43c151710b7a08f38cfffe618f4de8b9363ac09b5bd70fe6e8	9435
943	c144b58b167306e923da961dcafa94e185717176d20cf618b1df0eff4cf00742	9448
944	b1be95365be3568b2ad81e0d3d342b34e9f855be9df647195f05d2e89f8469a2	9465
945	54068c5f30de9161a77dfa077725d9ca87fee8ff9d31ef7dadf892c1f0ced1e3	9468
946	b2f76a1958ae5b9d1a335123287c1b662faf4e788d18a3d3cdeb096145d1d78a	9474
947	0c8945770b96681bdb2d621a930ba58d94c163bef887c6db8dfecbe4ce258eb1	9481
948	4797039971a9bd19b79a50e1091a160375250e9510f0e3d5229d8dbb4e62bae4	9496
949	8d8586ea36cd50b6b0de31e86805a6c39f3ffbe7a249cef05d2ce9e0c4f166bd	9511
950	86235015642150590e4f9a7efcf213f860c61ddc1213e1696bb5527ca23f684a	9516
951	57ba0d8ea264a870d929f3dd145adb75de378110f8c4dd0c2f6bc95362cee72e	9549
952	757509040b27a5c12ace4c449cc9ae4fdd7c610562d9021f0967179f600a8e38	9551
953	b4ef290fea74e59ea398cc52f5129f4ca590ab4cf0298e0b6fb32f4b95b13587	9560
954	0a0010650c20607abfd1109babe630e7e7621e30ffa364c5344d3375dd70f627	9565
955	8b1f7c42b478711446596646c4e6b2e335b484070a5c05f7f9fbe1b44c1f41e7	9568
956	485e63b2bbc2f747298b7dd158eb8020afe78dc95906174814b4518c7945a018	9570
957	e8655ea87b89adca956460fb399eb4ab967f185464e1eb9886e4923f588afbae	9599
958	43aa3d6f04d3ce4545b30d56c28272b234c649d509e90fbcb2bd0946f976d56f	9602
959	2de6d4c12672be6b556b3259d79a711533bff7d6232a315e5d64c247cd247447	9613
960	9f521f1a1132ab2c9a530817e0df413a72d92fbe79170a8d0b7d95b24a2193bd	9622
961	740f6360c0bb99f3d1555a7c5ad65542363a39f163fa575fa2f50e68eee3ae5c	9628
962	4a5efd8c206e5a766db44117b31aa29067eb5444ae58116cac1707c0fb444886	9631
963	77f8bea540019215010d800b6efef35ef479c199db7701a6a87dbd1adf37949e	9643
964	ad7064d17c78311c3e29404d154041dec621f1cd857b65a0ed8dc7ebcb3188ca	9647
965	35c209e54befea87e1528b701f59a9763d37afd5ddcaa3378eed92c91517e714	9652
966	d07d4f479977d7d7e3e8f3c50edc3e992aae4bd5acd8990d10138acd99939a28	9654
967	5eb29fd5f48064e9d61b6ebefa505ce61530b9630e5503a221432f2bbff8a281	9668
968	ecb2796d95ab3f4c321ee6f076d7baaeb843bf85b1f2567c8fa0d51c70040d2b	9670
969	bf8ac6c84bcf1c5ff73e1fe3057997fef663469d351017a5786fab7fbbe1e56c	9677
970	9f82755a942136df9f20d23ca69c2adc2739b947b14eb1df66bd446e529db594	9678
971	47013da097bfd20f1a458229fe499d3ccdb5f77bbcb5fdc2519b860075067baa	9681
972	a24f52230f94f741e2decc24411d734b633034addaccb1651da17e2ebb9a7e4e	9685
973	aad8c554333729e1c435f899926cbcc13e5b8a913d3c8d9be1f50a2fb9665728	9703
974	5b875b9f849b6c22a754cab2b9cf29703171ae5884ad982263982b6bc52e8567	9742
975	ef64caed9422c32832c7188fe7e8962c7d7c3fa2b04d278ac4edaf2bd1d92851	9746
976	5054ff6b4de958de7599c3d8b9bf3b4ab693ed74c5826ffa98a46f12c564ca60	9780
977	0aaef4b7799e5daf0f0c37ec58a7113bec87937a4d6c02adf1bf474a175641e4	9784
978	1e1d97ff3e6dc29605ea4a62f11d00daf3f41f7255c27a060fbe8bbbcf01b0ac	9787
979	c89d9c1ca62e3aa7fde0622425d3c8da309ed46be060c2d3eccefae778110b76	9797
980	f35caaa711f23c15f58e52c38942273567998f5cb7233179f3bb9011efa8e438	9802
981	fb84032ddd1922398aed3c0e1cb23e844c9efddabcdc92f6a95215ca7b0fd365	9805
982	17a858380c28694051195b8819c12656473c8a572fbcdd9d071aca9d37322f15	9806
983	d3b3d821dd91365dc2b690457573c620e85e99c18a8eddb53b4eda4ceee6d28d	9808
984	aba59a1ed2785728003a748233230ac1ff7d6bb6960cd80e6aaf965122aceffc	9812
985	8e23a63736bc8a96ba5f8de1996f5d98d80e2f3e55a16b1d67fb12410f4eb963	9814
986	0471b64255edcc3f2daeeabae6fc41de0c6a98e4c4b00d7f6fc34b39e4120af0	9829
987	9222b3efab2bbc8ff30da1af839cbce2557cb8234dc46866c80795562d7f7316	9855
988	c497c26f124232eda6c1db2ccd82f9f6c452747ef35fa7339e001687d8cfadbd	9860
989	b75681f3383a536c2a06437f4d4a94b50e1892ecb6cb07cadcc9c1dd773fc52a	9861
990	2eec674b827516fd41cd43b0d8afe85799b6a1d4bc4c7304447f631fb3aabd89	9863
991	408c4e1c8375681dc62d53f31deba0b872b27a27598eaa6217e4a4f89439f1bb	9867
992	cbac1d4404b665b9093a3d60663b78d65681cf836cdf2b1693cd84c779a893a1	9868
993	52dff19bd6bbb29d8faacd257e4d78f8778e6fa795ad98960af19408d27cbb5e	9874
994	f4b0cc64a52947b7c728f4eac5aa4156ee04bf6087441b75ba40755834d501cb	9906
995	cd28384e9a7aa21b1d9cffc6c8a5df221c309c72b9b5c33b84a4a57a8b6b3191	9916
996	5d4ee14d8a8b2078306ff7220520e3d4f3b90b8b1df18be8a66ba3f756686edd	9919
997	04e2206cf946587eda7a42d14fd897dbd8bdc8bbdf996eb121b95ba3b28ae2a2	9922
998	738877802e09ee78489e16de28ae01a29eec8ec8270ac9ea777432c559a36db2	9923
999	afdee12971d15ecc4811950679e659852e83f7fc253b487bffb15f15af63433b	9925
1000	7062815da15db16959c0314e4f9cc044c7f4c23da9feda9856dc839c21d64541	9926
1001	3c8f46e526026e475366d9a6e9fa57bd6c6812f2b5dd55edcde3718ac284274c	9935
1002	e2336802968ff87cd12f52eaa036bff2b552beceeb0ab3a30efdeae166f26136	9941
1003	165e914e88bda0342ee6367142b94497beb6f2fba2d52952cb056e154f1e4140	9949
1004	04ebc7c43e7246f7ce9777385323436687e2570e16d4762817dc1c54a7eaa199	9951
1005	263ef142f8707e5d2171793272e1e9b13ea6454f0ddddb2afe2834030e1d389a	9970
1006	1a14151a2de6c61527d1c684b7eef2565ccca8656833907b1e15c34bf360a203	9971
1007	2098159bc5e5b9fdc3524fcd0ab252f5c3f473cc382148ff8b744d61d2e2b32e	9972
1008	c4f1a8a31b38289aad1a3424be692589e88f0bcf1e61009c4889e0e2fc6d8929	9996
1009	ede882c99b16fe4eb7ede535555304871e35c4309b8f5396c051c492bcaeec82	10004
1010	ba43dc73f390c403ace8e51d90975febc3a0b95c05a824edcb225812ac97652c	10005
1011	94db41b98b81695ad296a6653ad3c3fe8ece80ca8dab30558d44817b9be1f3b0	10008
1012	6fa8459c0b60f7f97fb90c5b826a90136ff91ac8e8c3a1603ba1a441f66974ad	10031
1013	086d1cfc8dd1dbc48caf9270842d12723988d2cac9db3f956498c193bc9b3e0e	10042
1014	e7442eac836d5f82277d8834c1f2c91ea0cf30f89a839932b9c76eff3785b005	10043
1015	57b2d660e46457f4db1abeb6ecdf7ea5f4c05b73417b771f955566aacc872ca1	10054
1016	09ba6cf7df61949ff3b822b9ccd3e8e3e078be2f9c747bae03c195fb2ad3ace1	10089
1017	a0e585d6d220c1e11e4f20d66b05307640ff3476f516d0d3413f4de4e196c2ba	10094
1018	798aa048ef2f1b87b336ffea49d9af0f9359ba8025ee7482fa6c0b706ea48c96	10095
1019	ba46d699c096a867e139b2178c7d5387becb7103f624df3559859189c8091eae	10111
1020	47e41766448701936024620c8a33cc042a7b4949e1b98494946787a74bba21a3	10114
1021	b0f6eed1c811eeaa1d45240a09420f675de61942f745a4063b9ece24308dd6f8	10119
1022	ba2a277155fc0e321b3cccf53732bfb51ca792172cb3a879634692107cb667f5	10154
1023	c4d851781db89d06adad10d37c3afc04b9ea0162ad357ccc46d266406dbbb72a	10169
1024	42e26a30321c4d126f00d0d94ed91cb4d3ad6514a7e51df4c80f3efb8cc32066	10179
1025	c1785c3b7ef0825ada7da8f62d2806c7b2d42d828f49788e4796803d1d1775f3	10267
1026	0ee8cf5bc44c11627e6b0f8b49ef6efbbafc1eab32b7ab026c79ae7f88320b40	10289
1027	99e94d153877af870b300cfc29506a5d2bc4f21f9f40b8e35f276ebcc9053553	10296
1028	178b644615d41c38629c2209e2f4a3d9765c1a003f1370dcc70fe65e2ae8cab6	10307
1029	b63b61275777bc2112c81ec24861cfd7742c63c1df6ececc5c7d019d87393871	10308
1030	6cabc901b68e40d99e4f06accd5125c543b1a2f752644bf4f9c246431a10999a	10317
1031	6cb93dce0fd4013321d2e8638453c3a90b90a636e92f00932794cbc0ba95a885	10337
1032	7469075e6abdd2ff265e803cd6412baa30fad5470f85d3e87a6e8df2b788bce7	10351
1033	795352e265dc3f8b51e7286ec359d9a80bf2d243cdd631664af84ea495ec0688	10371
1034	0319bde34baec5b2c5569fdce75299f94cac15c77de4e6361fe9d6536de0c01f	10392
1035	e92321e49ccc63cf46b8ba9c11f05e811f35230a50374354b0a4cb13c2fa3427	10397
1036	12a5dbdce6c212180805f1a16f160ba4a15d2a3e25c90821f5fe52b0b3985992	10407
1037	dd4030ca607fe77bde57a4caab3cd1933340f531687d32c4b131e3f85bd7b28c	10409
1038	1bbf7e33da6dee707c5c7664a5928c83b827ff676013b579b33d325aa2ca8e4a	10422
1039	258ef17ba134e51ce188de5cd74e17269c14a3d974dbfe229c6bc549172870ce	10439
1040	e032ad0c282f73c00b46c8746251602a654008311b2ce8718de668288aa5c996	10441
1041	15a5a41cff1e7ab98a8e5a14368ecd20b94d17572e5cd18837d379dc6cb88430	10452
1042	67f52bfd5132adc1aabc853cde129b981e0381ead284ab0f23dc8a7f33490cd4	10454
1043	3434446e01b2c2d12d378f75497c664f44aa6adc0a27e4479ccb224891825de1	10459
1044	5f19bbdec93eeb20b283849703b84194f9738bd13837fdf237badef9514eddc8	10464
1045	1ef8fa2447c8cbf231f699e14ad2572f7c07a669e1bbc8cd8c606ca42d843f5b	10471
1046	34df8392d72ac9a4eb46d2ebfb304ddea617633143b24e992847b44344ce0408	10477
1047	202bf9437ddbd10a76f37e0e7e7f3dc793ea1216d50366956813d81dcb050458	10489
1048	46a47b2476ae3122011c50a5737dc93ed684603ee2d15379d57e5f29e1be4c02	10502
1049	48633b72fde6fc92c8337de431845736c8e41cdb896295b0927d52b6515c80e9	10506
1050	d3e22ee55c1120202a3a72e9314472d4c78ae20f4a67da499374c794aa044455	10517
1051	cc8555337604b3716b44b68b2d979f20ff7c0eab18499c40fc986f41bd88cdb5	10548
1052	6bcaf022ddc96e708f4ba8eda6d73c94fdf8d270ffcfcb1458254567e765b469	10552
1053	4686822a216f297088cd960c83c809d5eb8070212493b4c009835fc626bbd048	10561
1054	9d111a439f0ca915cf2d3a60ac15c1bda59119f38c836998520d615239b0a6a4	10594
1055	82aff7d4098f2eb252c7cb01ce3a37e587581754c732bc394d3341a15592a72b	10607
1056	cd49d98707d949b1f7b29c5a47444531443004ba148f643246a80568144a6efb	10614
1057	461cdbe5346b9990f6783db14e4e289d3182fac9e69ac45e8b24e5b7fdcb742a	10622
1058	f15d8e7c37f7ab8b0e0731f77093e136ac554a36d99688039f23636f4ff005cd	10631
1059	673ad33e2cb90b64335385929ce4b6ed94c2201ae08bcc87dd57fc54702e2c57	10640
1060	23384940df419760c2e16f7bff94be04fd3cde62f5fc2376e3ed4d65adfab00c	10641
1061	61282e8837feea85436379d482e73c1bf5148988b18c3af085ee2852103bd593	10644
1062	68b837229931381e55ae32734e2f7431f5a8222ce7bc986dfb6b53d65f92dc3b	10647
1063	26f95321cc177e6fc47958ddf159c92667e2ffc568f8d8a3621412d84daac9cc	10661
1064	0f83298a66b698e2ea48b4ecda077e9185192b560fdcc63d907bd52e88feded9	10671
1065	1750a8e490a4923ebe1d17dce5e993d72cadc98c2c3066263e48d24337555d4d	10673
1066	0f5877ca733418bcf92bd5f1428d8e6580c0c5b6fe87b3718a364acd1240f3ac	10679
1067	f9d76fd14807ca7934074dded36c97830c5811b1a64d149c7ddcf03b52252008	10696
1068	259929b5f0d1bb4bb29ec47903808f224a37b863040634b2be80f4476fde3ef4	10704
1069	748a2cdfaa7b383655f77f1e56640e43f88f28d2263d7d194083bd37d08818e3	10705
1070	d3ad420eb77e967efc91ad40201888f70a205d34b373193d8dc6f419e2e92f09	10711
1071	bbd85f783828b860c50e146fc4618c1441e994020e95ce4bf445d9bd7f16efce	10724
1072	bbaee7a5fb91f32fbe9be48beb0dab483fb85e022d259ea6812c846a3c9edcf2	10742
1073	bdbf91cbc9614f490f7b91dc42770479c786bf93819dfc6e21e25a9e311e6683	10748
1074	ea9f203416047a9e709beeab2a1e73447e2fb106f88205f8657df9e26959a85a	10750
1075	ae5b12f42d2ba51820d9f90bbf586888ae5bc0c811477e869045b20c958053df	10751
1076	7f3daea6f69deb78acc214c919e6536578ca29941fae3171b5be0b38760531eb	10753
1077	3afe650a9fd5ce6e00a6697ea1a0a5524738f5842fbfd566cc133eac78922562	10761
1078	948367f6a7530f374bb7d24d579bf0eb1ecc14c77ddba11f806977d4e5d4003d	10775
1079	c3de10f1ff697642716bc9f2496798b79b514ad4616bd0e73a12a802736ce1d6	10776
1080	f624acfb4175f2bf8e627e649d386347343c3f0bdaed99d8ad72bf1a3d070bc8	10777
1081	947af33f6005e07d2d30a0b6cf9a23b3c55ca35e29ddf690f60c154fb2802b65	10778
1082	0d9fe097bb770246baa3fa4020eee9e24da97554a5bbc6acd5595d30c3d3c6a9	10786
1083	e3883e337146725110946c0529e30db2fa66f13248b9d8ea06fda425abcb492f	10799
1084	d9a804720723fe3665aee38a99898c60c0e6299abdd4a3dcb5c92caf1d6d35d3	10801
1085	2d1a6467a323e9f4f15889cab21efb68a4feb7b1322cf73f8563905b4df9d5b0	10808
1086	1420ddb9452ad88e1b73325a2bbdf88b8d55d19e7adf023c220e3c0f3665b1f9	10816
1087	4ea81da22da7428e3171f8a088874e3fa7f8e035ad5c574a7fe3ba001a5df16c	10842
1088	334ad39b9d4b2b8dbfc3f9c85b0ed9eda4ee4b54222d691d9b886f2c4dc848ad	10854
1089	fbb1a17c69f778d71a034d50034f2613470d32731b7167a27affc6068266549b	10856
1090	f98529e3bc754f6abf27967c947abba0d4e560da8aec3112cef76f69cd4c9521	10881
1091	85689c0748e68ac02203b70907210c8c7c985075bd46ea163768396701674b6b	10894
1092	452bbb456639761114ba14babd51c4a1c6443067247bd94cc3c3dd008ff28c0d	10911
1093	a1767e93840b9ff3ada7acd168987c62a2dff00ef45dd552a84649b6996c9332	10922
1094	7f684aaf1006f735680318239af3fd26bc4a97d2bd3fff635de52127a3de496d	10927
1095	0b612cc143dfbfc9db9abef721a2f42f41b6253fa62beac8c649400a4b31d016	10930
1096	67d2e5899ab6f775fdc9b3bf9fb3a78b0997ddda9f76e0a890645ecdb2f57cd6	10942
1097	edd7035eec60842a23f3b46b2c4be251ec70b39f00dd91cffc2727dd13ad2075	10953
1098	9f7a724186ed317610f66bef08d29903cfcaff5f5331fe742c3e841a6da49aa1	10958
1099	c92b11d7f7e76b63da2f585a90d7c1fbc67833cf717a09f147d34bfae55d412e	10995
1100	183fed2df7d4caa400270a2e5bec41ec676a3547e5a15f105c5492c7cac47a85	11043
1101	309fa01acbd2b0b74d35b6954df35b72449bda0f5daa18ed2251b1fff5524347	11048
1102	41561aa10365d11189bf9a602b07ac630db608b615f53f6a00323190106b674c	11069
1103	d70bd5040436cc0da9ec71b912a83e0301d1f7387090c6973c47ddf2d6c885f7	11071
1104	202fe1a7a8addcf65a034a4bfbbf81617f4f5df73a63e0f36813a979b207624d	11094
1105	b82ccff23546620410be70827c6fd7b90a5f98a351ee35eeaac30b3baaac2890	11101
1106	05ea5879adcae4d17b9c2795ba0457c832287c979d83845293e82be6edb555bb	11106
1107	01cb81af47dc5a95148d6bde0f974ef18200a20300eb749a520781652f56601a	11112
1108	fc4234a6e6f198803c278efe579adf48cdcab9dbf6cdde0c6320e02626a2472c	11121
1109	50866951748396fe9b11b12a2e57198b6241c102640298b86d0e11d4d61b65c1	11141
1110	d36deb341af53036c578cb756a6e9b93f3a75489dd067d03ac03b8b9570833bd	11146
1111	b816622646725de086aa7c5b16d3b30b7212d6197060bfbf4c66f6b669124361	11151
1112	d4938ce0f9b781acde0b524e16c262917660d2b1744e86711b8ccfb58b414359	11154
1113	fc4c0f439eb72561244939f07247592c1f0d1a2c40596ef887f0aaf4fed7ec2b	11195
1114	6f0695e827331174b0f0f125f8a53075a8a1ebebefbf6dc0ac093cd24f9eabd7	11203
1115	827945ee32c9893c6c89ce5fc9e05062cdf4e55a2e02898dfe00ef80b25aae24	11218
1116	69455938dd0cd4a0cd569199f54a35514c831ce647187da4d979e70a1c0104b6	11224
1117	1e3974591397251e2d365657848d2833f145d40276b0834fc3937d99b334c597	11228
1118	cca9480367b9d1869e7fb4f50e66dc19090bfbfd39e105dde8c590173e8e5077	11247
1119	452c45f99e046dcb3f1344e68840c2e1d8e42d4384f4bdaf9d42c600b5b9218b	11253
1120	6367f4408066496e5fc680fb21fdbf27241210d6996f4a5445075318ceaaa495	11265
1121	b2c09a7368a6ad86ac70252f57887dfed72c32d278cbf1b4d9ce3ea7bf042535	11289
1122	89bbf50b049914978436b070990c6bb0fb83d9ca88e9597da5e6b72730bc125c	11293
1123	0b132774161a8b312093ebed3dea6626575b717ee2f3358fa708bab505e80512	11298
1124	8695f94b54f3274ee92ea143952e40e13c916a6de9bb3fe5386750d17e3e8046	11304
1125	69f80c0f7c45abeb1bee7d7ad44f8dfcdaf298d2ca04e1fa82919e4ab5a3a8b3	11308
1126	ecb0ec70d0d41cb312e08a82ba9e2349b11fc8148d6d44dbed432e1bc29d97fe	11324
1127	9344e2ef36ca38a5256fa108f2af5179c5dd780afbca69ee4c9963903d31c43d	11355
1128	573214324181d114db4421269d563a08f0d651e905423a5f4c92a645ec015c69	11420
1129	f911bd05ca31c1b21fbe12374f0c0586d5b79d001953a0568ed59b2c1deec1a3	11459
1130	1ac71d885da408efd5589d32afe5b0d9538069d699127035fa792848e680a6c9	11487
1131	ca175f157afbecc4bbe1823f6b8f4cdd9ea441acaf9d2fbaaf6ce57061a5fb92	11496
1132	9b29fdc4acfab9df8fd23e09950aa7332c9303089602dacab7e32d719a47277a	11497
1133	c4e495e5c3cbbb0033dd5716440a36f0d3634b2caf5196ceedc7b6e989acee53	11500
1134	413d729e128036c8074452c630b3c9f399102325341cf935ae5e05d78a26261c	11511
1135	e3d4f2c0f2a87422ebedb6f37aebc55378d4758a5cd843dea8d53af1cd9e7463	11517
1136	3ea903ed65e36cff0603b9a8777114b3b97a8342774e8d73a78fe2ea17f3467a	11524
1137	a26088b8f00af94afb827092133e5192517ea9294676ae9ca6b5ee9e69942be7	11558
1138	552fa36792c0256b32d71005c3ccb08d757efbb117cb2185d1f83ac5a220f47c	11567
1139	115a9ae72a74f0331f242fcb748651244f4daa059ff2d94448bc25eaf2a499d5	11575
1140	8a5cc917a49adc6b9ffa331e525e383392b5610a3acc9646e3c40c0a52eb77a2	11605
1141	54acde306151814081a73d595f757a78add582c1ee2eccac284ff7fc78feb803	11606
1142	e92ce59723b44be9c3c7306fe44bdee847e1a9d63bd3b55f1fbabf4d2c715250	11609
1143	9634dd920e74f9377001274ad2b2d48deee83d97372a150082beb14287772e5f	11613
1144	f8dbbd928a2f3125071d248021ebe761ef6d7f0f997bab511bc9191dbc43e4f1	11625
1145	198f905f1b86e8717e98ba72f8b4bc4ffa40c7bd9751e476478f570e0be03dd1	11627
1146	3f3805ce3c8fa9aa728c83109b79c0533750ea53990adb79afad2a637932ebf4	11629
1147	296b7f03a8f114f52c79d1bb8fd4f97299b0e71509efd510f60b4ee23fc55a49	11642
1148	66f00a500c722535ed9b49615e91495fa5586a5507b397345d951a94d2aa93fa	11656
1149	78c64758d50759a85c718102c8da9169a047978e351688b50d3c8d69784e077d	11670
1150	590ac07939dd7d6817a0d579111fb332fb50dae62f14d78f168986ce65f29887	11690
1151	c7202f411534ab7ecffc1c8e5f5aa06bf9ac2f50b3a9ea8fce98cd50d7fe8576	11691
1152	acedad12fe1bb68ef3e165797876f7413b77922a68caac8e3f65dba8cf7e8111	11699
1153	19fc76861e68a28658c0a35e56de1fb9e9a213cf40972eb30f2687be47c9b475	11714
1154	5f75162d6542577e621501f0d35ac95dcd9ba7841bb86790b2d9ae2d9f5b85ad	11728
1155	13a7bc41c950ed95951442076ec8fc09890492bcced0792c5f90a9f584923484	11729
1156	ac0c45d776e911e195236371730d513e5cb74bb8a8f2fddf9675171bb5617dde	11745
1157	1d418013d9e6aec7d95aef0e555813e3a5b4f279886c01da5abdbbd5acf60ffe	11769
1158	838f5dd2efac23d1f1e7c0cd12e64e373f3c3619a509c1c4c6e70704e97bf8c7	11785
1159	01164e48d55df69ac1701591a29d047a2a4875dc67930522beb84db22613c4c6	11794
1160	12d0a0d3df63df2a270a4bb82c058c4a1117a06d907300db010179f34883731a	11834
1161	bcf9562038bebcb596e5096dc52781f8a1d3bc08c9e55cced42cc59f67948af5	11849
1162	a7ec7c841beeb50f9d5aefd665a96b20594a31eb2e3f231f38afb21e76709722	11883
1163	55b62a980b1d0f820f4633b4043b5f79fba40df4736bca4dc8f4d7e3e26c9b5f	11921
1164	59ea3fc3f4d9e6360e3f094a50efa3ed8721a388d02770628f92fe6731f7785d	11930
1165	3da790c3d751d44ceb705ff2aa0f71b961ef35277c393b39c6be5be5ebe66d8a	11941
1166	dfc635448be58d7cfcf7792a87b255e42a631d87ba62e52c7d60b63beac4d53e	11953
1167	0ae9874066cf51a97d4384dfacbfc6c605d3cd7cbfc75fdfad7b3263bbb9a18d	11954
1168	6311c974f8f80a090585a06b2ec745fcb0fefa8125c7cdfcb0c93b47a50503e0	11971
1169	3ef7787247e3d2b52b73d7cd21f711a5175367bd85eb0e92840efdb56a15125c	11973
1170	cfe3a8af67e701b6b31ebc7b959822f0a9104b6d5a537b290ac468c90ec245be	11980
1171	ac403d8148297324583012add7919a6961ffce79720bf67f481652dd7ff2f320	11981
1172	a5e38c77e8a8b5f5209b083a02bfaf71af3ac22fe45355e3af7c031bb5770cf4	11988
1173	afc933d4ba9c14b958c2ce6c984c26f77fb53818c04730b4ecf11c75f1a7b9a1	12003
1174	880e34684d94ff49ba656e80e9d03499df2fa8cc575d6a446f42e2f9e9035e89	12069
1175	9137dabb7100e185a2f499b71ed0973ead3887da532a04c02c9279913f463837	12076
1176	1231f70b3a3a1b8c3c12ab564e15d5a15f8c5a91a0cf0562073854a4b06612df	12083
1177	baffcb2cd1a93c242173d7955f7e917ad1149d1db8f743808d57b385bbee0b00	12088
1178	34454a9165e74dc2afca30362b292075bb4aeeb5f19dbe7184b8e43602eb0505	12091
1179	9a6f18341314b208f809623134f2d0845561809d5d23ad3e69261a18e746fe56	12097
1180	dd9e7b2d8bfd5da787ca99c5127cde567ba40971c029104e0f8257953613f652	12132
1181	8e8040a177655b382f8e37ba8ed8bd3dd562957161267c8b6daec045757650bd	12177
1182	0cc7561876423aa61f391df79f21a719f7369022d045ca9d2581c5044edd6f99	12187
1183	fb627fe520c0dd09a4c4cfc3c07c6473f3b60b0bef465a8197533ebd837fb83b	12193
1184	7106829115ed7260f1e7091767bdac1bb1c9e99d693b8044260370066e6950dc	12197
1185	18bff4c44b886d42f5567b35dfd3c0c37ffa2f645d8f20c765e98f2ea4dc0976	12205
1186	ea9a4441ee19088d5f5a7aa8571218ba1d68a7331b0d0fc1e76b4293e43f6c83	12221
1187	0bbd80d01dced7d4008bfcbf451ad65f6e314898fdc59f9676ce17813e58a2e0	12235
1188	990822ff551bd6461a14d82dec669862ebd547eb8830ae0a8b5ffec5eff7809b	12243
1189	776d43f9a24b016af6149d653f8014212cec2d6e709cd488ac2c8e4addc07715	12244
1190	b6003e45f02c6a01d4ba5c9a7aed33ecb9009d6b4b0df9657819f76af9059647	12247
1191	f4f11b16d76b26068a7ec300ea979c07f6eb490150b8f61858cf11a50101fba6	12268
1192	2eabcdbcdecee8f216c12def9dbd5380486be826c711b9de9ad9ff3400f3f369	12283
1193	5debf7a9d218aff99ca4f7e900016a4c4a536cc9c8ebc5cbdddb5f5b443795a0	12302
1194	6a3e6b6910ce11092a2fb14983e3dbc78f095a4fe5bcd4e29f1ab27b3cf5ffb0	12304
1195	303cdefb077d6d1bfa7ba97049edbd8fc476df5b577f02539812c3c9c6eae1f9	12311
1196	1a9ce13508bd57f9dd22d979638e0b087f1aee9c6103170040c0c55c995d56c6	12327
1197	76152b20653043beb7f8ea88cf25c472c17f4983c2e68f6a749f7479040e6a45	12337
1198	b3f93a0d90f57cdbebb4a8056784573b483df6e118754dfe58be679e70035602	12352
1199	fa273044c578dea921900b4b781e0a9c78f1e65ec3188eb7c8e6e9bda11718b1	12356
1200	c0fcd10c28ff1fee7a9d67ef2d66ff00e3c7798d857800d3b91757b30a1e7295	12362
1201	dd7f03268b2bd53bc2c6f57dbff5387a03b51de7b09931da13a98f80cb708c45	12374
1202	1fab20623de49e33adbb1e9319338a63a3d42f81a251882e73edf42e0c17838b	12381
1203	a11d3c2e1371e4faec838485429e078d34eff182aaac314b8e05ae6839e46bf5	12394
1204	0b6715bab36140df5c5386d17585e6a116d6c2149411c14f1a5ec121663d8fc0	12400
1205	4a3c56d56b27839123c17665c25a2e0b667229c2df6839d6265ffd396a617e29	12407
1206	572aa69a5c2c137f58a2fc98a6a069fde213f7c0d340b0e871fd04ed970a42b1	12411
1207	4e7baf894aea7e1d1415691a00896b46bbc189db87a006ce028332bd11b185e7	12415
1208	2ff52ebfc02301bd40b0e668a7d3f86405ce637d255c5501d8032bca4cd40951	12418
1209	c63ece35d9d5a7258993f6768e4dec45d3201ffb9849db638cbc8d5ad4323c9c	12421
1210	d55386465cb9e8803fba6e8a501e6fdde679adae6efa453ded1ed2659b9de0e1	12434
1211	8dc8653a2f72298889d61c5a2dd07b1ac8bf81415cf877f3f8a343934c7f012b	12451
1212	d20cb16d036367f3725432501333f2e1f36af52f7f6bf43b275a40fed375f1ae	12455
1213	32b3ae8bac0d1dc95b0c763273dac74b961c0a20305074f4d23dd8a8862432d8	12469
1214	b7d81f7087ae6ebbf20c2ab3913d7a4678bf660100e226f026d5df6f5cd54f27	12472
1215	c2f9ededdfee83f94b499c72bf9c862eb62edef7ec0866d9a28710f0e16976b4	12473
1216	17fc009e142bed2768360e831eb90b049c61c5fb15a39196e26b995889e35984	12476
1217	807d198fedb662e1db8713b6a89301469e97b3ec80472757b927520a15668af5	12513
1218	5be74e63c4a76a2e8fa23fd124ac78f960945e9ae2ca4b57da41825c1c41f1c1	12540
1219	171897e2782b90005cbf41e30b3acbc33eceb2524a204335fd83fd698797e7f4	12541
1220	13b8443f0f487c6d6d564a036ffa4f4ec66e43f20a0be36c461aa62139c1056a	12583
1221	d585b6c971fb2a0edcaa839bca02b5c14c944deb9409ce8fceb25392706b7c5f	12584
1222	e361a562b5cc5109d153a3cb8eef93bf1f26b3024abcb024248b127eef444ed4	12589
1223	70c8ae1c4403d6ae967f7dc652145acf6e4792a3dcbde5e3c0b1411e5fb93277	12616
1224	50ae659aa7fab184a728e12bcd8ebef3278af59831c2d45325e7d5fafe059078	12641
1225	8c0becaddb23d7899fce7f7e328d401e275a6aea110f849bf1c693cfb2fdc449	12644
1226	2cc78131d021adc429f1eb672b79431170f787a21037026b71a913a117e57906	12652
1227	bda187415bc7c82fec41c3127877f85a199061fa4158b57b8b3fbd63a5429951	12653
1228	ac2ba4dbab2f98a4192bd670acabe6f59c7a10fce7298879709aa6fe920ad060	12661
1229	faa270bcfc717622ce3d7d9634444b3a3c574ef8deffb5a421f0fa10b5cb740c	12664
1230	a52dbbfd64e8d5a8840f0bbc26667a06c471414ed8c3f505d5e9b4b814e919ed	12677
1231	c613fa2445d01711c24f497491dfc89956152364dbc40f5db7269a6a558ae3a4	12678
1232	386b836270b2fbe57fbe33a27af02506f4501af675495e8874ff62ccfed7abef	12681
1233	124b694a4960c26c759a3558d5c865214ac2b2609024a926449fbf52d5c89ad9	12684
1234	355ddb7415eba33ac1063cabddfdb49d11d5aa87f892ec482c25ce148cb4bae2	12693
1235	9ef6783413736318d2b3932b6a586f8461e426f8bf6a857738f0b8b6653f69c2	12697
1236	104f095e5583c4b531ceaedb4b64ad4ed931f562de5f83f39d36dcae06fd37b4	12706
1237	80939fef6831819d208b0b650207946a6740d70e3a545ee41d6030f63cd596f2	12749
1238	1b5e8ee2bcecdb2f492c3ff2baad10a0bc659734f34b4d26e82475af8a9a2ae3	12755
1239	57e174c224cbe708204f1673107c02a245bed4e16dc2ad528a84f8fe7590dd98	12783
1240	b8950658e62de41be51ea5c629888b5ea4ddd29cb6b450bc703a0098975703cb	12786
1241	f67b3ab77cd94b71a07905bde3a140d188f87d5ba12cd664a8a4f8159cf85e65	12788
1242	8b27c12b2bbb7ca9798ec02ead947028e0c68de2cb673c3e25b768dbb0d33c97	12813
1243	bd7027d5535bad817b39ba604ea7c89390cf1e4f663bf4e62a8068a5a8213c6e	12817
1244	64e1c4cc1f6022f841d8c82bccd4aadd21ba4f9ad7cd4dc474a4ba2bb6fa5e59	12818
1245	ffe13f1fb8ce37bceb76ba1f8b9660efb958155a930e6394089e0d650580423d	12831
1246	f2c938b268819516773ea66dbf50a7d93b04d13389b3ea9df04f0c7133f940e6	12833
1247	4f7f818c1c938543421d315e63311ce99a38b0648ef6cc84a5b1ceb4b91e6827	12857
1248	a8b3f3fd6f641b39a2f85c27bb2366593cb765b1b7d9477ea202bd6a37505823	12858
1249	30020a70726fadbbaa01454ea962da6b3360da0213fadaf2d57b3b62b3db1ab2	12862
1250	6804bfec9f83d604409f09f48752eb6fcb13f781df02c949bb1a9247db90bb65	12870
1251	f19689654a273c7e57f807ffb7de492b32d08a09f31ac2b25fbab49592f986d0	12874
1252	8044628f4619b48e59ccc895f0ee75d8a9b9f6a57457c6729642d22a2b81aca4	12896
1253	c24aa3577853e9ed4df832f276ff285b507902fb57e6dda080a03f4176471f5d	12906
1254	c18b2e0a9ee091089da85d9d7b2f6de9536df5dfe6ecacebe9b25bd342b5460e	12908
1255	2ea749ed782c538832e891711448bab2d5b088abd74e88c8904b4d0441b2f50c	12909
1256	34e4a187b094e1b1cdb8e0fe5a83eee00e55b63d6052c487fbf2a77cff4e94d1	12947
1257	42ada3b26eb2756e455d6207b90c38d9daa6070d17376c77e1ceebebfc1ec97a	12965
1258	7c94b0193c3a4b6c7577a8f7d7613f0ce75340b3a9fd6c450f69e8b9d986715a	12974
1259	e86bf4a4a3e8556fd9070c42acdd82431ea4412473f1b42e609d353a00a51812	12980
1260	4e6f139467b4e8d8dcbd1565c85d924aa05b3479045c576f06f437dcd649e425	12985
1261	d84a97d2c114f078bea2538760ad8f54c37ac2406b92e87276f129056332d6cf	12990
1262	02a25affbe64373fcf92f449895750cf2ad124f958b928bf064e4c191e686e19	13011
1263	0bd14b5657c51a7324a0f027faa74532a14236a41f5d1ec2840ea2573d89fb1d	13017
1264	946de83c601ba01b89b5fa2c3b67e531df19a65b7c2d488a8e00f0f224884ac5	13020
1265	a57bba249eae70c93cce714df04778a6f8ee098cd870282fdbc75f2583ecff48	13023
1266	865ee93d4a3865171755f8a0a77acdf5dcc231e09c708ae7b5cd684a35f4dff3	13026
1267	8ac630c4783a193702211a01efd064ebb4326a19bfc06575bebcc739cda3e636	13039
1268	e7b1136450f704960e8c5ec31d1aeb25cd6d201c04b44a1d2391180da670d97b	13045
1269	53bb83cf31a6d6946ac097fd8887f3e5d8014fc406d736ec966f37570c527763	13050
1270	9acd107ae9d80a48489b5ff139e18b5b65c959141b8a04c69c0b2f6a1f19a23a	13057
1271	dcc3382be3c98cd7e48fb044efb605c5d7212cd80bef816ddbe1c98c49c086c2	13061
1272	138ea7289aca30f3b118e310a1d6bbbce103a5197d5ed87ca3d0ffa6c3b31237	13076
1273	37c2c2a490b7e3a199ea927981783d71f5a1fe2409d8e31399301062e6effe48	13087
1274	90438ee3171a0f12b7af409bd1864867a940654c521df517fe8cf2fac4da6f59	13088
1275	4bb8d9c48fba5be4d2676d45a3ad0a8e898045313cd24155e0709033e47a218f	13101
1276	955f309644768c2c1316d9740a669270397ef12e5197db8942c1810523373830	13111
1277	3a48dcc6338ec8bac1d4ce5600772a50425778f6fefa4928a7de41dd68b3e15a	13117
1278	6c9c4dac87a4f6a8a3dc1c4bd090d5e9f79097a07c4c7734c6ff3f547272c72d	13124
1279	8e4242a1373f52ecc568b2bbaf708f04bdc9b8d0aa9660f2e947d536a01a9849	13140
1280	65e778d83e667f6cd1083ac40f9591841c4f8203befff25785dc59ecf9410f7d	13144
1281	31f37a2d1c85b9cb567a1713825a3a4b5d6b5dc9f9513a4eef8b2b6d0e6a81de	13147
1282	f8a75244ac04d0c21176bc2981456b9f6dd33ccfc3c6ed4e8953fb08ab77e12a	13151
1283	3a8bf207e943ebdabf64e7e6fa863e789d98a56c4b2ac11247ce9c3ff4218158	13175
1284	5026a4e3869820d4eca1ffce171ff052d9f43d53e604b43c09f3dbc9178da1cd	13195
1285	5ce4776e135215f25ea2f6657662abecfe178dd86dd84ebb0a1d9d64d8a0bfc0	13202
1286	466e287b96d9ede08bae962710acf020d0f11a366c4a89cd2c803f76e84f9815	13209
1287	751ea20a4a0817c7ca4f3e7f66004a1806b144dbcc4f4d32f2260ad9a66543d5	13212
1288	a39c41a22978a5721cb04cfeea4a64719787dd98f4ef2f3334a600af67431f10	13213
1289	36860140af2ffafcf90dad29f73b78507c09d9eb6f80f9b1271145622962af44	13222
1290	71c21652490636d252f7419ef062f601ed1faa91ec5bd673c3cf1c0bb8384080	13225
1291	627bf24fcb795b7ffc9e9b3e3ff1b12b5be28e57ce23e8b077bb0c8db829019e	13226
1292	c6d1b3b8910f85e64ea8d33999f06a7e25620486d98592da1fe0b8741c6e748d	13245
1293	dfd92137b40055ea581cb8f63fd3ac1df5cc4790edad9e6708475df0d52af324	13251
1294	c43481bc34ffbde77d1d7416336c2803d68ef4012b5a44eee876b7996a3c63b1	13254
1295	30819456140cc4e694a52b86ffb3762aecd6ad0431f9561a62e7e52e867e4591	13255
1296	9ccc3fd1d3875dc6bd6d093b1f17e4ff1f0e91f5ef91cdd05d938dd9055206c0	13260
1297	192c0a19bf6958ee9bb8778cfb19374f8ba135be510b734576e55516828f56b7	13266
1298	29039ee7d07f3377bb656db1db4afa45b1c9e14935d35319a12de7181bae6574	13270
1299	71c462e1bc349149caf7bdc45425fe121379f13f29ce886f5975d891c0d8feff	13279
1300	333814c445e6592e633f43a13fa7ce0be8a120c6c72b0dd8e5fee1ee983f7e85	13284
1301	28324c115dae84fbb83e7823c09305df460cf3384a5745fad766157bc9e8746f	13287
1302	c713cae3fde990916daf7d22c4a1cc4616a6bc3c02553786947e1d63dc32f754	13292
1303	d900ebd297a51e80224e0a235c8889feaf84a664331194f500838face18db8fe	13302
1304	6b8fa973a007b4af50f3ed13ad4bc2c3c203e5d1a6a9c25d9a848251fc95e2ac	13320
1305	be2a6d2f5a153eb9f9503c732b822f6459d89326cba814fba91a53bc47dc76a9	13324
1306	2023509c3145627242d02b0d41a24831644c25a6c9f7b9b1dcf90049cdc5073c	13349
1307	8f839813eea2dd7959053aecea6b2bb98cf08079c3f4f1eee4d90dae4f8da024	13351
1308	428cdb675bc96ec7b9b7bae8764e30e2a8bb6147944dedfd0e3eaf886d171f63	13357
1309	e49a3a8882927351d52f549804c672eccebcb6dd4793c833302b6ac2cd7b5f4b	13360
1310	cd1fd600e9b7faf6ccb09c55e128d79774121961226b4febf3a12b58960f637c	13377
1311	84ddf809c1dd96a8f08a2bb3fa2e1fe53548137f7483a2dd80c15142179764dd	13380
1312	37318c3983ac76dee4b32687060005d258110dbca6321bf3d28154e6c346fef0	13386
1313	e498da6e2663f6a9ee966a5828a896a0ae835435189e8e2ef95a47118b0ef912	13413
1314	2e33962a4dbe11da11f414263bab35999834fa7f8c3473c8a9b32153e19fa526	13421
1315	7d22817fb5f0ad4fc1fa66d771f0267803de0ee1721900d2e31dc749727b1631	13434
1316	bf11566874b1121cd6396c9eb5a238f54bcb61a202fce872d59a02ea3870bb2c	13451
1317	836926a1ea48825121b9f00e77786c8aec321f66e3d5b61e1c4018c88997a46c	13469
1318	48cd0ada7484f3368363b47e0116158c2b934bbb1a061b89173455485d5fd609	13472
1319	011e04fbbf5b12e8444985fa4d5120df7ad125c34a9dab3d9b244166242f7a35	13482
1320	0a3f65b0813887942fba112b851de43bbc40d7b5e17f2ea201fbd6f5e9252c97	13484
1321	4d95882c30ac17e70702bfc5e6d35a9101b113b7eea592bf057d273bae7d82b1	13486
1322	48f51c4c1d0931ce9b53c169350829b4022b80a680faafadf8041773d86ccc73	13494
1323	f65bdbe9688d7ef3f997e58689c6dc1852998f2e692a7f69e87e474cc9d494f5	13504
1324	c11a46fb258c9a65c492363d0fcdf32150aa710a0bb4565f8cef3e3c4fffe6dc	13515
1325	4651b83f1e332d66709f2861068caa975e4099f15c95e88c88530cf8e81d6e34	13520
1326	9b476e0854cc1ca8f19f0941cf7f8dd27a389160cecf43fe43e9353abc520aa2	13531
1327	80b905fdcdd0910d37d26e785315908aba0dbd86bdf027599992afbb274d07a3	13536
1328	81050c1b5fc82784f9267f6b098d247361ce85f39f3d493874c3255b0248e1c8	13537
1329	082ab1a73e1a652436e871bac6df73a4f88286d25d89e7b99c0221e9c8aa182a	13545
1330	0df03677a7e6037f17aaf93a1f732472dbfb8ea70388a8895cbecf806b2700b0	13552
1331	81c19b58dd02c5ad47273e1d422eb51ba7a5786b9ae51c0f886a1345b926015d	13562
1332	789da1954d6a6c354970b3f32651d94f8a3a9ce7081f4ff9ddc9103d763bf6b6	13567
1333	9cc7817724f0d6cb135e63ccbce69dd162812e16a10fcf5db21f9aaea232ec6f	13573
1334	fc307911c2e5845fa1899e14df28d2c2bb2164b0e9fc390bdbee7285f45f166f	13584
1335	1517daa32ab342f98329a25a39c6543f35b82ef50eaa45853edb26029596a3d1	13596
1336	6d3ee2145ffa1bb1a5797476509e1ac7de0b13a6b6dc52a2dd19271b9882bdc3	13598
1337	7d5e44deb30ba7a7422d1f7820255ff5e392bae2fb5165e4ac863cb5a746f21f	13612
1338	adb37e4522a178ec2d9fc93d048684a4e16c57c4887abd07ffe832eb658d9d8c	13634
1339	1f7c32c018ec49dad869ef02ae598a2ad08a3921c586f39c520e0bf1087d3744	13653
1340	3ce039bc9d87a30a7eb84c0e400092a360fa2e547764c1367d725da13d550d59	13665
1341	9099776897578baab222fcf05b1b0701f44336024b1a157869f981eeb713443c	13668
1342	15c2a7d1a545c39ae9449f70af84d632cd6ba13e7ce39cb1d70d5ed53265f9bb	13672
1343	e7fab0575b684199df76cb1d99a6cb5d4661fb30e320d18be464e69800e32334	13687
1344	7de5b5e3ec4856752c846cbd31158d6fe2693889f2025b2f1f31e992868b92bd	13690
1345	5ad587226e019bf69779d1d42b032e6dd220bcd1a6c36a9c51764904ea4a5157	13705
1346	a03fe620a4536ba7249c0755a6561e166424dbe410414ce357119f4fa1403b28	13718
1347	bee883b7844f8222597b94075c639fc9e6f2719241f5a699cc2beaae73fd64b9	13742
1348	d2b4edbe93b909415a43ec7ea84b892b9099c01453923199f6294a4eee534ebf	13743
1349	1204a3b555c45024d4322fdd4e891f32d5e2b05f28bbf9fa8842699251b0bf5b	13751
1350	504cf26faa037e12c8254cd071cd0caab9220dd2660f2c684b9a65eaf9897f9f	13769
1351	f0e1b1339583eed40d4fd98bf04875282ecf345cebb901fe78d4666497ad39e2	13806
1352	085fc4b95c26e87ea64ca26b729f801facd8f1cab82807442a4beae4ea494929	13835
1353	a1d697049eca1a30510d72aa4ed2f471db7af6ff14b5e728e119170b4c337cf2	13866
1354	b44f7b6de7392a228b98c7adfde7f642acae41e87f70a8fb04db5be172e4b424	13877
1355	3805bf7ae36ccaa704d71b686fe8dbaa783ff930d4bf189ef44e39b94192a4dc	13888
1356	6d6dbe38719c24ba14d734e1e835b3ae19822ab1b2fe4d52ee7380bcb4b72210	13906
1357	fa7657a32466d1bf32e225bd62d08da75716aabb6ebd63bf4bbb3ed067a026f0	13907
1358	6add219f9700f0fb527f62e9a5cf92fb5068f7a29486e922bb11caa55c292fae	13908
1359	7b6d24ad5c953d8f87870415ef2bccf739d7d99bbb3466a456fb87410191b855	13923
1360	c8fd5e1c540ebb80898bbb68745f2b26b7bbc82697aaaacb44244730e440dc47	13946
1361	5569fa4dd7be144103c02ef3f08861cc7ad2377e6d2e8f48b0582b8f1ec9a29b	13981
1362	2806d1d0264cc53065f7b2297f1fb88d6543ccf7b51f60fbbd7637a04a39f1e8	13982
1363	5f8d6545031bb5da589b72ffef254df65e054570309f3a9131d08ada87d40da9	14013
1364	aa8f261835596065ef2c0040b599aaa444ffdbbc742a8cc425b24b532fc17eec	14024
1365	71b6fe36ebd490ec26f28d8e513fc20944c3be95fd0279aeea8ca92f75a981be	14044
1366	a7e93638e4a6a55bcf9b43f46a19cd7dd43deef4961a147a9d92a29d965dfd8f	14062
1367	06e1f587aedf04cfb59c3d78936fbcfed32e306dc8e45ec6c3172b177ba28a8e	14091
1368	ffaca653e513faafdb298ab8d04ae244f12c37518fd95622f40e5552e217b7a5	14096
1369	8b08e29c1378c106d6ddce21f7ee53e1c061f551989317d35abc638c37d94c53	14105
1370	28d5c242b7824e7c1791613a4366c2b1dc0f0d5459c8692557e644bdd13001c7	14113
1371	954fe100df4172b2128241c2e977fa8c1153a24f213dbe986d9f83bc4101900e	14115
1372	277eb25896f99747eb59d6110f5a8b9dc7d5ee40f4d8b8bde1a07501f1505ca4	14121
1373	4b0f49fb44312bb6721b318b31367b0ca4b48e394d811ec2879f18d3e382a038	14133
1374	236fcc70367c8189900cf64d9b7e9b3f04a72b8a015156f9267572b93d4651e3	14134
1375	feac2792943424f401dd37075c17ae037282bcf027cd31cd60c07c3b550fc16d	14173
1376	cc821afc0d478ceb504eea58bef0176c134dae6d91c95185cefb751c87904cd1	14181
1377	0aec2ae3c6ed0981a4a665b9770832529270fae2379316d34e3c5b48d66893b4	14190
1378	78cf5ebe1b07344ad82bc8b245ed0b016f921fc63d09b0e1ca73a51c94923bbf	14193
1379	0163f83588c8e5883d2991195e8ebf91760fa0e4531b3d241070b17bc94bcefd	14202
1380	eebfc5a5f97a6c0e1efc72113aa2be2a4807c9eae1fa91261e560a4524033ab0	14205
1381	22422127e33066e6d902ae9273bedcc84384875792fdbb1960edeb94181e5c68	14213
1382	3c9704ccef7d4437fbe397c52fde6c77deb2fd79c7f72e855a67aaaad61929fc	14214
1383	14fb77554eb8ac1bc8cc4189fd5eb04e3084579662f8151bb54ce1978543bf7b	14215
1384	430ae4ef43bf444c70f0ee6cbc21dca6b6a5c9ecb1fea3caa28666d6931a7a28	14225
1385	82a1d7e504b5e2f1f67f84da5afbf141e51959c49e134346e90a501af1867685	14240
1386	1c8a5952bfe8fe032d8570276558f561c707cbfaee0a87582ccf7b816ee8116c	14242
1387	a961d4807870a761b7b075c0823cedd9daf2ca9eeef719a249b220f482af32b3	14255
1388	a442f073850372cf4e65a8c5d47f3f76460f0e26c93f718b302353b9dd6b321d	14262
1389	3552a5f78c9ee0308ac3332271372178904fd349e4266afc4937fc54abbabb27	14292
1390	2189f231abcd9f6d78005d59ea7313cf8d0aa19e869a8d3adff8c82831907936	14293
1391	f982315c02d5be97e7aacbbe932b3f144ef852b59fbcf6854b9849fff916f7bc	14299
1392	142c5d4094fbffe5b6afcaebe24e2ff30f295037f992682d5de6cda1d6c0e7f6	14301
1393	0ef0029ed4a0d507d0dfba5e53fd03f862ec0b44641269e19912555556e879f1	14314
1394	2d6b297bb1d7d6fd85e839fd1da6b16e14bf965fa203279c229474d4e5e3fbd2	14325
1395	a4db7f52bbf92f44f55e12539759fb31c62fede23fd744e799eb8d095c1ccb3e	14333
1396	4e4997995579e1495789a7499cde486e840006de129c9600499e9f2c38bf8528	14337
1397	eace4ebbaa16af35fa19af3b6f99c9510f5d83cf597d2e5e2178a0c227ab98dd	14342
1398	b5e47d005aa74af0cd49bfaf351df429ae1d0702e56769e21a8f6b0c51b1276c	14344
1399	83ae4190667b98a8b02344153f8d6e62071628bc4916c4dc7253bcdd247d91ce	14346
1400	53e487401833cd0c649843b38a16017d62bbab223825d420751c607a053c977b	14353
1401	4e29df130a9c8e3813dc576af77450546b6da70c1541e2e99f3e32a53257f68a	14369
1402	4009e647471a942cbf36271f31d62fb4174364f84359e50dccc6a63f7c50bfa7	14382
1403	636e6fef4537ce948a34bd6295f8e6868739192be96df15f018bb8a2c3ab6934	14386
1404	ecf386e59f65153b70ca7718300d0aeaeeb0fe7a090388c40099b92493103ea0	14390
1405	73eb463cfe4b1eea1e1b230dac276d77b95e7e4fef8a31c4c15b1062a4fd2293	14428
1406	3e4cf972b4a542bf88f973cce6bc757a0d2ec9b884ffcad2f342fe856da2821b	14439
1407	d33275f7ad754cca93d1bad68dbce8bdae4083d6a2e1aa8c54681f214dd78987	14449
1408	a57bf9ec8eae72d1b00fe3dd6a7b79004268bcb1f03d6c038f28a4603f5f2c15	14451
1409	065cf7cfdd77faee041da1772bf8ad95f8f74ab15b0912145b0f851d9d1962e5	14465
1410	8efa7bfae7661a2212a47e63105e3dc614a1f2a0a766bf95136c58b325c55f76	14466
1411	a7d4ac2904c6a1422b818ec8afcc377625af1de3b9a85128f486e1632eac5670	14480
1412	1de922bc9ea057cc92b90e9e928b0f5079b43f9f3a4008935dec9e4473de84b5	14488
1413	f8ee2dc124f3e34690bee570fd2a607c07b7722e94fea5ccb708d0cf0dce4dd5	14506
1414	25e9b28ed99fcb36d3ec36626464833b6ef39cd5d6bab11aea955026f2438992	14520
1415	57d621047879ec940786e2fd23ab65e462d98384b6a8f27c28fea0ee29d63ae6	14530
1416	6245d9487599dd2276c2e38521b6a5f8efdbc13f1e3c6a086da6deeb158589b9	14543
1417	2ef00b015f64752e48c5fba0fe4c7f8a5c58b73ba2babbb790e7c75e5623fdc9	14564
1418	a3949f68d6c563926c441ebf89b019dcbe8bf3f890b1f15637019cb15faa5e51	14569
1419	cf4fb4a3259d06c882637bc3042f8c56a5bfaf94c386e4e6cbca750b39ea31a2	14596
1420	9830c871dbca4213878244f037333417177573923cc9029392c45add34264a1d	14600
1421	4c7091149dab6fc94e18a7df4d13492a2262636baa71dd819f02d864748237b4	14617
1422	7115a83af5b587a2bcfc31e5ba36dcba4c3832b3d00d712c49b01bcd73518dd7	14618
1423	32fa226791073b1100926bca52acc2a0738d6b0b5b8e0587447d3e2e416cb8b4	14619
1424	98db026918c86b975bd7bf7ace5f927918417ee0acccfade20af1d62560897a3	14620
1425	7f7bf894ffebb5fdcf116cba549b68d8c586be41d3a56932bdeaccab848581ba	14621
1426	cc404b42c59698bd8df788553667e5d62111207789c57acefe68c963eb74d02c	14626
1427	a33a0182890bbda1af9e25ada3ead5696aa3fb4a2e9a07496ae3fbb4227fd55d	14633
1428	2dbd8176c9ddc8b295d288c9451f74d0f576b72ff46446fbd02540b77379a642	14641
1429	4145b2b164fe6208e11d00b4ca8acdd9ef92627fdff0d3c3f80e9da22475c418	14655
1430	530ecd03f3aae4026a1cbf0deecc28a41cbaa12b49b9a4a16a223196b6852941	14664
1431	e20c48009c598c034bf885f943112f21c7af1ed1736b42f63387c5764095ae2f	14670
1432	627ea618aff3b1b1f66cd646ea945ca68e233c55e9a9ff90366c470afb741e53	14677
1433	91f4dd45141db88d0f0a38ae6cb4dc7a54445f6eaf20b813c248956f3aabbe26	14684
1434	a68173ef4093e58116c6b438e9c8980714889f71a48c371599b52cd9db1a70e9	14686
1435	aff96ca1dc807d22b7001ac9af17cf1f52f0d033000344f14fb01d74f94d306d	14696
1436	915445c8abe68364e7f710682c408629fbc2345e016b94c77749324c45ac74e3	14698
1437	b4c658a7c1d8472fab0499779cb070f924fd5bc8891d534dbd796a83bfb01f29	14716
1438	6326fa976d22d5ba18d4c12ecc2efbe5c585348d78b07619c02bdd07a533de62	14726
1439	9ebc2ec80974fba6189862cf129e86f35841295664e0048ee9ef1a3f20f2e27a	14734
1440	b531da80aecf9b66f61b3e0529bb752b04842cfdd7becc39036bb2b04ba8a6ee	14740
1441	3938f70c0fa200c99250619006e0443ede9ef8f21c2b55d8752f70ccd2b44e98	14742
1442	0a44477aed1b98bab871874e21c94823249279205754bdc39378f6c617c5b13a	14754
1443	50d9915f0c1f24da2623d83fc5d2ae51137d3a6d99a92d86acad43f16eaabac0	14767
1444	12a1cd75df9e2b76eddb035ada9631f47ccfacfad5d9b46a01e39177abb7a10d	14777
1445	01821867b439892c8bde98d7834d942be3133071c5f10a1c6f82f322ee070de2	14778
1446	729e0c1b11e311a2147ce6e592b5d2f18072fc156e0e37fcbbe38bd1489e7b94	14790
1447	1581411b13bc6e59675f4dd15b6dde212a340e0fac090f487b4e0b26627349ec	14805
1448	be101b14fb989d9502b40245be79495c1a4a0db6312abae80a0654ab96805845	14815
1449	9138a5fc8d7787ec2c8375f4b273dbdb9f3073ff80a34f7920dac7f990c98726	14817
1450	93eabc304511584f4272a82c87be8e83456c2290290c587257f93ef2d5279c28	14828
1451	c19932425401ee563f7baec6cac6ddd79e6399d06b85ea35207e7e01367db201	14834
1452	4234668a84104b38ba6e73bf80b11d34467bc0fbf61ea1f4204221b8ecdd90f4	14851
1453	af9b318e18cd640aecf89242928c5b80270b358c2568318cdd61f45015763f8a	14852
1454	6c76dfce73901b28eb6cbc758c0f4201472953578b7548f9844c99e7d5b610f1	14882
1455	dd2225dd60a1412e37ebf9c0071fe61b4f798c66b417156c93ef33eae52d185a	14888
1456	cfae44a8b2557830f892656032ece0982052eb07adaa5a939f56bf10c104653e	14890
1457	3fca2f21ff3d3e6af0cefb75a1c4d1b7c5b1a373499b52d5e9d87990cf6eec99	14935
1458	1d5f6bf27abd98e26f38c40ded9d2df1d29efd1b7a126b9683cee0852d56ecc1	14955
1459	cd9e2478e0edd9c71b256e9c22ceb842854485a4a42d1c3566986e99597b9d4a	14984
1460	ddb870be13545831d1a56b6ec4a47589f05ca5ebef7089773dc961644ecda964	15010
1461	e386d2faca8b7b8d2d1a44b6c47c9c2894c65b97f1cfabbb6c595822cd1db413	15029
1462	994fc6e3ccdd42111ced299b7e0976c036cbcb7e9010a64db233b5ee3511075c	15040
1463	8856df87a8a7aad5f5915cc9ca82aaca5265d199ac3a710fea4bf177d053aaa9	15059
1464	91960a9d496882e767826b4e36edad76f88c8303f70ca0bfdbf7d5a203c3bc08	15070
1465	f81eb5b81c351b8f61b60fbd8e808c0971ffda7ec27b1d9475eaf076a8a25318	15073
1466	d4b9567740c91bf073fc79a56f88c388798d3ff89fd2513b678bd94bce7d738f	15078
1467	e0a9a539c38d27a21a6a7d98d20b7e2c1a2a03e07c9e7050cab58c337f85c158	15098
1468	55e88a5ee7e1582b24f794ce033695e3d15590e9e64d64eae23b2ff2f172d842	15106
1469	abfa8834045999872017f1d0fbd01f2ba7e80acb886465eb41a3e7b1729ea3c3	15122
1470	7251f302ab61d876ecca4fb162803bf1d95cf7419e0ce24b1ded56cd0bd8bc9c	15139
1471	9db91de7e4b6f27634d0103592cd4094c2f03d2b343127f1fcda8434cd8f3c5f	15155
1472	ffd5e6a4f4573d99be4e6bf2cad38f52a81e1dac14997dc3364bac16937a7ba9	15160
1473	58567bb64f620307e52ab8e7dbf1c2584a3562c66326b7693dc35fbacdff0cac	15167
1474	0cdce12e585b7117748d991b22bcf74d92c3c660adcde84ac10560eb29ab9d9b	15168
1475	fdb29d8be4dff4902217a65b7a3a3b4be147beb562438d95982356e262488ae7	15172
1476	398d147dcba364c140312cbd038a2bd6a09fb654dcaefdddf2cd853de79d4099	15179
1477	a79fa727c3579dbbd57fab5faa1ceff8a8d87da49ca5f7f77d1628e3f8cfbd13	15185
1478	f83b1436d7171b8c152810f495bfff98ae803adbad581a9bb3c943c8d730b4df	15192
1479	a27690eccc71e1ecb627948566b1480ae2c969e2968cde6b15b94a6bb896c52d	15195
1480	7abc3ff4a8da3cff4549b5df0bb5b42990d55c460888071ea1af1c80c5a8ea3f	15200
1481	b7396e7a02fee77adafb0249567cdf1080fe37ea2f928b0ab07b38bcd504781a	15201
1482	f2cb12873a05278d3dd58b08cfa43c0e56f5c9745814c7dc0f7c7aba10c89d28	15208
1483	6746319e4202b9c5e2c33f6390fee5866e0eded7a43e8e7be7ef2b6411c07a78	15234
1484	5ad4201ef8aea6ed808e6bb9a51da2ec80e6fae313d47c803557e7c55f57b0cd	15272
1485	ecaf7ae1f1138222987d8bd5ba8fc3d3c7ccfbb085e7c27701ea1a381f4daebb	15289
1486	b3af74da7fb6f9f31a4ad1ebe457a72608f595c71dbc2f810e36b837eef7a466	15292
1487	8df38e161205aa2d232fecc09aff92b95df584e14d97747c5d73b6b8f11d8bda	15312
1488	3d1696c7cb5737d88fc36cf45d5b1f18b8b29df7709f1035f97348390132106d	15323
1489	f04dc5436131384ca9201777d14193ab0f0293c97ece656cdc71bd4933c72943	15329
1490	674dd81e56f7cbe5fc4c2d95123911f7abe48d79779491d1bd7165454af99ce1	15382
1491	3ba1d8e4303667a9b2c50f8c9c43f3496e23aa349ed6dbf6cd3fc3c94895f4f9	15397
1492	d4c4cade691a3976b95894c467721d445aad48f41a53251e0f8b1b0a6a1e2106	15399
1493	e51f16a3747755f6fef755f62685a9e202d74db3c514b03a1f28c7c5209a3437	15406
1494	16b99c7598e65ce1779cdedbd45b0db6d3e28b01a5ef7581b7dcbf15b56af1d2	15414
1495	8e31589746f3b6d57604797644fc76f5467238c0f8d0e3022f901216eae01920	15435
1496	19af3aa51fa8ecc8ac848011b5e5ab5d4813c8b0c78127918acb9e224a3cfe1b	15437
1497	82532019cf8b22d7e843194a1469d3e20a296336d333ae4dad520c021f73ac06	15441
1498	e2991d223beb4da7c8aef19ea796d4817ad8bd722ebec2e5040511a19de94703	15461
1499	d330afc4e26d900f4731e44b6f9584e22f66540734ea224fbd46f115d5210a50	15462
1500	16efaf0151c66aef0a7ea5c393d84235dee0f5368a254b963f4ffffdc8db354c	15467
1501	135b2978f7144612f287dd2475c7b0550acea57fb641a7d25858f6e44bac9752	15469
1502	39598250dc769f893101b0e2ca0b828701d5dddf88ed093c9df643d1f6330bf4	15471
1503	b9daef2fe7ba959e846df7c650ccd736da0ec5e15ca6e70a3a48cf3ffb27af2e	15473
1504	edd3cda495b73d57ec8889929f2fa3159d45a8c2d4faaf102001dbb6b7081900	15475
1505	ddd850619a4f2f16aba606cd368148ee4271e14446ed73a06d49d9cf67f073d2	15480
1506	dfb7765cec8c691ba6009cc82d923a42180c28bb26b3c5853dbcf2b42ca1558a	15483
1507	2fb6a9b751898e78ed9b1f8697cc2c3fcd32f601c33e9b23701fc863377d96e8	15503
1508	9a22b0bbd2633bf5cdf0859593ca73266e1e0fc481e8333f5cad1f9cb87eabd5	15512
1509	2bb072dc40f777f01665ca4ef49416d58c24a981762d0f17b1bbf357c56ca549	15522
1510	fcbb35ca0a2eaee5b6e6b6174bcea3007cae2029464555f3f70bf4d41dfee92f	15526
1511	a07df793011488e3eecec027e35fccca958c153d6fcc5afb53e167223376ba89	15546
1512	18c54919c46a617eb8489cb041b26f0af76ee4df5844c56c338776bae89565ac	15549
1513	558a759e6411c0bc4668792f4195fe23df3ac1ed3b009724df774818b61e47f8	15564
1514	5b16b5d5732aaa58c39762b05d97b101cd0fdde45b23f66725daff5d3a89cdc9	15574
1515	fd8ab021b807de8f38e27bf148dc893fce7e4fe65d9ec64d31d751ea1a483868	15593
1516	de07aef9ff80799f4d76fe9303cd38c6e6834284526903cd8bad126ad21eb1c4	15601
1517	2a86e02c475bf53ab0ea106c21436b79b2e9d54271e700f3d10f0e5a07a583fc	15621
1518	e16852441246a2d665977fbd81d4091a98483f34a44499d03f819aaecc891325	15622
1519	5c9803f5f7409dfafb57170282e949bc8cdabfca3af4510f0a29c4791c528dff	15625
1520	cabfb47bb0e99f1f4a8af0059d7b4b87f18d76dbc9c50f7e6cee71e5e7a99b69	15626
1521	912a26482de643562dcf8b80cfb0751cc1c8429cada6bcb54522db7dc20d1f2e	15629
1522	8d54a9e953ffa9a2d60441cc267ff566ca67cfdb73e64ecbcd3925531d781a6c	15673
1523	0450d10ef41280ed9c175d484f96880ee02576fbbec73efea9689cf14f287df5	15680
1524	219fcb80b11d090f71b78e2220c327f93d9da415616a4d158b7614014875fb62	15683
1525	3f43fb50c1e4a591ea0c486f97ddb4a03de7100a011105cb902f30863397d611	15685
1526	6a99db632b914094f37ebbf5df9f4558b8d4cc86975b49c6f662ea429861592b	15701
1527	c8096211046a2123a59140e94f675bbbd36e7a306fda644d13eaafa9a7e56ecb	15727
1528	4a431e99308fb8ecc906da7ca22f179fe0d948b7a461ac8c02f934bb0bcdb091	15736
1529	dc13b49f2833907bab2ee96e85d36054ad97890683c8d78338b52748042c21c3	15746
1530	642df000db796b4a9f613a573bcb3b69561456dc601f855611be8e1fcd94c5bd	15763
1531	b06ca6d9001339d00e487740a8f73a98f7d6b92ea3be7a155a473f762c5fa24d	15771
1532	39eddf4d0c25ba2927e924db889b20bd2d05736ac3c2f73187071130e3524a58	15775
1533	998929307a7bb4a8505b8dcb64537e0c4581c561ea5a0c87580ec6479e402c7e	15813
1534	517c57107860c3e5bf4be8492ef78b50e76f8e217c295e3d6b9a4c963dd5163d	15816
1535	6616fe3b7c50a506bb0a18673013d2be514050d3b8a029f0f6769b0fc92036e7	15830
1536	3e43e88be46dc7b5257af4f28da5f6bb111f4b119c51dbc536aacf9769807d11	15838
1537	4553f6f7829686cf5de4145f7a132d2ae639471daf553fafdd02e9fdfe877164	15848
1538	7a6f57867fc52048d375de27924e9048035d53959d0bced294e44d94d19e4840	15849
1539	96d85b83acdf149af2430f30fdf9ca0c63158a5fe91c9989127788caef99fda1	15862
1540	dd5d682d82c0682c1132db6aeff0e1ee7907abd521fee3cbc7e3110b1659f805	15878
1541	9c9202ea18e8881c82d6afbee1e28fc7f39facc0b8445df7be8a6f8c1108be6c	15883
1542	dde51e0ece3c4a3c07c338c3a5cfe97dfbf54c50a244d5b9d2c84936fb195fd3	15894
1543	50af853a688e5218fd495ba1846434d3d463e42926e42c55f6fe3ee425d88928	15898
1544	1a3959a5ad94f4cb7ef3d1ee8233cf38f3d3facbd7c6381934a5c497f44b95b5	15905
1545	a66ee8741c474a57f981e60900ece65dbea81418033a58ba066b5f06741ebf63	15909
1546	35e66637df6a87f502f34a2b98044ec67e6cf3f74694239d7f8547c7a4e5bfa3	15947
1547	25834ed991601df6a275c5c91a6433ce1c749d8e59fa454b32fa334fbb559861	15948
1548	88c245a6a7f4293bef715f98383512e0c15578b75f5a014b29d38145213f31ee	15977
1549	c54b8c1a533d0a2761fd068d0a017a0eb4ac8db642f4f4285790fd6c0b57bfde	15990
1550	1b3f6aaee7f1efa808b883ee076cd18482622e5b740fcc5487df0769d9878c72	15996
1551	218d1e006b252ce3c4083d415f988f7480435abc8aafa0aacb3b58fa6effa827	15999
1552	fc29447ab906865491e199e975f6e9dd2e2ddd34e6cfab9f8fc475cddcefbb0c	16016
1553	4ef65c88c06307783cfeb4fb9371b497957374ac3360bb2e55c192f9c6828113	16019
1554	f043bc2ffb5a715a4f6b6852de200bc72850c5620d58fa208c5e2ea777a9ba41	16023
1555	f4402bacbe0cc35a2afabbc6b26a300c0fd1a458eccadaf8fc498d3c422264b2	16024
1556	b4b9c02c578c01596893cd5ab36ad31cd761a4034cbea4f8d3d5121d04b6b8d0	16029
1557	807b156ba50e9401ea91c5f79e66b6fbcbd0acb34acd01efd1611583d1607bcb	16038
1558	de2f31f7a4061b6ade78ebd8c241d2f33fabf5ab1fc10a59d57df500247c29c4	16042
1559	2c7e98b82c2605a44f7fac857888fce2a2901729390b9e4cfbde8073b8552621	16049
1560	35c74495b2cd982c2bb02f4e11358084c00c1e28ef23d4ad960b9fe528a564fe	16069
1561	5472d3e5f7982571125c0807875c3480c042c034c7ce33292e70b3170eb65a13	16071
1562	18af38e2c90bbbd9a3b292bd6fddb98324da264050da754818244b09f9f9333b	16080
1563	264d9e2dcb97b6770a73c81c257afd7f902b1ec39f3a4439bd49dc10aa10d31d	16093
1564	d52e16dd8ae6f50060e8ca9afcb3b6247f9f12223420027101f8d59a80714179	16104
1565	4f381e5f70c349731118966edffd455a09fbb701322f10c394be6591239c161b	16129
1566	e9a46a9c09081c34e5917eccae0d1aa2a8f939234cc71ce454004eac5e09fc6b	16147
1567	6673d3762e3b1f173c497a77eb4937fc946c72f0427ecc16ad7e217bbf553aa4	16149
1568	1e734f861b46b40911f276a0502236b1e252d1ba331f041f175c2529131e6675	16150
1569	2fa0795d9fb33bc20d317edb1c807d9777c766d407d61191fadc3880ea400df4	16152
1570	51ec5995370cfe4d6a1b13090cfadfeb3e4ae7dc32e8bc1649e3bb10c49dd307	16176
1571	fb9806ef35d2f7895aedb6c7c0d8d25d8a078e1bc1002904aa0003d64b1a3cf3	16183
1572	f1aa2705e6d45695d8b605f9155ee013ddea96a43d42b2d644d4b44cf420f220	16184
1573	98bf3335938c20cc16a4a62d82ffc8670f4afe227ac67d9ec1d6ffd399ef58e5	16188
1574	87baab3e39127e743b361df2a7d9184d0c18612d3e52c6e229a2570ade23141e	16191
1575	c2630ba06fe633e0ccec7e458ef1eac149478b6276ab6257f4e605dbd27d2d74	16193
1576	04fa59533155c24aa6498a270a1bb88b9fc80c06addfd4b101e146dc323c2241	16197
1577	dca08f56e15c77efb2a09597187f1a3ab3214518f64eced8191a70159705886c	16198
1578	c8ec8ae172a22eafb1f35793f3b557a9490b12338a5173d09bb236cde51b9bc1	16218
1579	1a3a1d478e56c0bdbf5062c1651cda804f950399437639d5f04d78f91a6dd7b8	16224
1580	1f631c7c88589efa1f10f6618e0ffc9cf275b75869412249a20a2d491ba70e3b	16232
1581	1f4cbfb0fa859612506efcdf7a0f936a4613bfd70f435ece61e4109b365fab92	16236
1582	9b1491e752adc039e63de320f7c7bc4b8bf5d5f223731bedba94964fbaf2b551	16239
1583	a53737b5d5b448d011ae0585078ca14638e06710cf5c584c1d98a24399631d85	16253
1584	bed0c644da15781820400966db6fe9779d12e9989d15bd8d6942f2ccbd802f39	16254
1585	5f14e1af0325535f0427e8ae0cd1104b74ce8eb95bf48598e937d0435782bfda	16257
1586	9a09277eae7521dbe1dc65230ddb7dcd0811995de5b0d562d8671a14a940d8c4	16258
1587	0bac225e44c6e9ef49349b56b8e1a1bfcdd4535996f127de1e7d0240d990a19a	16268
1588	3e4aebfffd99d061808b668ab4149b13a840212a942a9a8212e29aac1ab5677a	16300
1589	61708574095ab52cd2f6cf1ea0abaf9e10b6758718e9f3f33e97a4147157d8d9	16302
1590	49522b87027c41209c2a971c9aada82cb95f7735f7230d1c02b61c535541ae6f	16303
1591	9aa243a0ca0e7321112672185c935e969897a600ddc330398915f10a861653d7	16311
1592	1d3058a750e3513d09791e07ab3563d155d4b6d812db4fa16010eabf1a4551e4	16314
1593	e3aedc43885e53c11f3b1d406f59dafcb7d0bd03a17f84ef0047af5114015f38	16319
1594	3e1a990209230aa5a0c12482f17ea231842afdb06224e51bb83d735dd69fa08d	16320
1595	cc6f3170568cd25fab10f9b6c4226160bced839bf4670d0744a1bf8adec79028	16340
1596	3af4b63372836b44ed2d7c6094639b009ff10717e9439e8636aa31daeaa9e9c9	16348
1597	471ddbc05d20f466bd8f53a157b70d92647a943a44fc2598dc2c40d4d548ca29	16372
1598	d3399a7c63942ab760704ee288e62c74faa8fc18cc728f8d6b4fbfa9c72d268f	16378
1599	5d2ec26fad3215397d41939523d01d3f7690c8449b4a2e1eb24a331937adf28e	16384
1600	a4f94b0eb4c9756cb33a0cc7287f0f32d789118454ec6b8859879e3f71233b3d	16402
1601	115ad758f1c3a221260bcb6bf6957139ea0793ac73551d4e9cec54205ed83977	16410
1602	e85e3123fba9aebb8d303bc59e57f96dacb56546fb984c0c03a3830cf585d0c4	16416
1603	e6613c3fbf61fc7f9f7f434e580c73d63069c84041fc3205768ff65c065419e2	16425
1604	550bb618fa0b66064ff07e143065488423b2cbf84283526542df80cfb4f6955e	16446
1605	6bbc8fab3e556de19f89f9de8d9f3061d0a15752237cf32bf71aeda14355f8d6	16451
1606	5d06667ca15608db534b823b50715432bf2f7b06af32405fe08a287b6860bfc6	16453
1607	c269b2b1f65ae9d58d703710fd504ad56ae0c945a980596170a14854b67a1af9	16485
1608	f41ccb1852f71583a6e0da4569c49ec7704dd8cb25ff70e46bd9fd0c3bd981e7	16488
1609	2d6dd22647c1d41ac55467d882eb0ab896bde6b2c3cde4d06407f8df07464cc3	16491
1610	62362a5f52a73f67894d164a0fa1602a74929c01c2e4617785550e522ea6d94e	16501
1611	5e6c10160dadbc5486bb2d77516335c3e57bccbedcc2a476cc921b8ff9bf5718	16524
1612	714ee4d3bd04e4bc6e7f643b911f3f9b519ef2110e6d0d2fcb8554fb58f1e859	16537
1613	5cd0d5d98f0bfdaeb5918b23c6e6b401a1a38e10c30cde80f6cb2e9670a23499	16540
1614	4e9d158591b1d456f262a5ffb9e8ad3e8bf0d18d3c0d8e292d5ea713459b3079	16552
1615	c4f32de21a5a4877807d34a57706cb55097da5e2e4a30cb1fb3ff86d51f50368	16554
1616	23b5906071c82fc0ea71744631f6ce5330b1097b78edf1ca33024f59654a0253	16566
1617	825f2a0197aaecbac52d6c16e3490d3acfb7b1ff2d1d4ff5fabd4afd0115cabc	16594
1618	4bf5c1d20f113254f04cb87fc791dd565448965e021dca463aca915f10a8b7b5	16596
1619	0a6499f39ed1f5b4cd6ebe9e2d9255c2f6729e8aa46e904e2b0f05dc6734ad6d	16601
1620	238d3c50a7f276aa6f3ccad2e45b173405c3a319ad56938cf28553ae2e462ee8	16623
1621	bc68ff7ef3cccf328b83c6c51abe4a3b7b508905b1f7be6636939043a856eacb	16638
1622	01d8a8e17ba74fb4ad46035413c385ec7b4b7e6e29f6a714b3978aebf1a7e081	16646
1623	f306731e9321286ead3c034caf04fe8743eed9622a26a3b97e32be72a26eeeb9	16660
1624	09fe6a64867d6752ab0e05dab6332dc936012a164c56e8d866d0c04fb6e71fe2	16661
1625	fc0a34ad8cb9da62499ecccac92f85988c74cb2ae4e884b0e3864a3d0dd13cae	16666
1626	c8b4453f8817a08bd1cb062fa7ffffe4a9290d8b3553eebf7bc0782f02b4ffdd	16667
1627	b9912da547a55f407c9dcc4eba50dbb5fdcb2193da62127b17d5022da0a246ef	16671
1628	b4f320d84dbd517640c421079fa8594a0465b5a53343dee32008d86f88f84b90	16679
1629	6f35d86b5956ef174b4e4ca2453de091f2b13af62762230f540fe9b0b0926469	16686
1630	f3c20d959f88054c5208180db3f94f61d61115fb928726dbd212bfd59a694d2e	16704
1631	50b35082cebaa6116ebcfe81f05079bd53e8aaa7e78fc108862d75f1b949524e	16725
1632	9617a589a1286a440e520e1922ca6a5250037284b8590442c532f3f502b9f1ff	16748
1633	9d072fd9ccd818cd2e74790d14ec39c5a005af6ebc282a27d3f702dad7f7a11a	16749
1634	dded761b513efcc1ea0d975b28a28cb515cdcf7ba9f6182d5affafebb859eb7f	16756
1635	eec062ef799096c9f10a93844db1c9d9aa964109a467d7e8410bfbc34a88d85d	16757
1636	a5119f81d3dcc66e98efe90f39037d87295eddb30a6c4472f0145a0733f7b845	16764
1637	3604b5a03afd92b21395e4e9a74ba3abe6fe04410f338c4f6a13e8e32550fbe6	16784
1638	b369efbeb28fb637bae8bd582290550a507b6e4d08a969937b90d397db71a600	16793
1639	4a9b8b318438e6f688b37541b3888e2d3bb3f45294232271ebf19043d6ba0733	16800
1640	8267fb52a7beb2b4d8e67baaf0e24b9cca001aa2f24b198a019071fc39dbd5d8	16804
1641	0d3444fae39ebfd6049f8d6705ab2bb8d823b9f40ef8b6da6074d959adc2b4ac	16805
1642	0d9ff307a2876ca68c3e057930b80a7d34522517576913fedb75a3a8c479d96b	16814
1643	15fc964d04ee3cda8467f322cc0e36d60998dc6e6e52ff24734054a66b00cb44	16820
1644	4ec557f7d44d4152f4ebbad5139ca2aeea0f3fbb7ee9c68967cfa6f3b7568c8f	16827
1645	40465748d201b8e172722ea9dae1a72fe87fc1eaf6af5d25030f29ec6d418906	16834
1646	63365de61be7844665fd8215cd02633f568d2bdd21d6b754eff6e7e198d501f2	16857
1647	ab1b989df7f3437e7f2895ecbfd350b0521857efe927e6706b687064b3c3077c	16874
1648	e6698616a2be9160e5ae56678c23107226581a3815b12faa687db1199e07fc01	16875
1649	c2096efc29efa127861c5cdbb67124cc23b1fa28c2ff4e96ec5d79ab3b025196	16892
1650	3218e8e681313a75de7048581e230e33496ac26521d3562e79812ede00dcf0ca	16895
1651	e93571139784c989650a45b9c732e0ea641efa3fb61b152459ca7f5410429b5f	16906
1652	6414189dbe3341efcc5326f1bc391a9848ef69a8eaafba5b3b607d6422cf4157	16920
1653	d077c5d025ab6dfb9931c7f2692706e7852cbe8f521973b486c7b70864d1be9d	16922
1654	477938493ba0cd2dd322f2101ca4e36a3d0487d4247f2b585f1eb4fff5ffec7c	16926
1655	e6277ce54f406c02f0983a9b3fb9d6cc7bad3c5a650d5cd6fdfc2ae1ae6fa997	16960
1656	e7ea7a49c5c0f044e904d81b966061ee06a0341ae1a6bc8e02ea144c84247c2d	16974
1657	ce74ffec801a2e68cb630bf372864c532556de17b66a731373291e126088c9a7	16985
1658	9b3a1689245796a6cd2e954922e935d92426cf44fe8f55fc50e55ed64c2fdf2f	16995
1659	bbcc7d5a8d85c511f350c3cbca9eb7d662bfd00a5e07620e0a31533d919b3364	17015
1660	5f1a3709169e925caccbf8c8dd0c7d213360cbee283d611433b908a3d7c5eb57	17019
1661	3cf97ec4166792e0bcd918e5f8271f3fd5f6104a468c833ae03e0a03d34f4d16	17031
1662	adf94765cea900eb54a5c014da39225646314c1b861890eca40fbb9de9a080ac	17043
1663	10a5f459242054ac4e7207bc9b663976b554acd3f6acc0043fb3a4442c880274	17057
1664	7602d0f8691ce8ed89ab4c1ff4062bc9e73825c9f4e26eee254dd6a4388a971c	17082
1665	6037151359594e3152944e0135ff907a09ef3a99400b21409f236aeca91349df	17087
1666	363689e4d6b1cf9336c881eb11612c8484a0aca84f5831537144428a9ecefc01	17097
1667	2c4b2d18b9e6098a25b87d3f9d0c5021cfa6703c16b1acd0e6c9c192b605f536	17118
1668	47c61689aae5a4998e405c04020d911fcd8bf06e16b4d56ba8672085e8c1e718	17125
1669	70b8e8db2168885dbd66260b1388d2254b17358eaf1fbdbdf6bfe6209aea4dc7	17126
1670	c40943e50754c8cfabd22fe4c395973679d419add0f5210216938f8289603a36	17142
1671	598ffb447e9b8c037ce1cf0834e2f09d62239479b76cfe06cfb201dcd19553f4	17146
1672	c3cd49b9469c4978949d19d58af85d54935f4e13e9d659e121698f7ff2789b49	17152
1673	ae01c521db72863ed150779ec4fe60cbb40303354cfe5e634f7f998645b325f4	17174
1674	db241d43342eb2d6110488ae6b8e5e0c0e2f5fd55774d2a999fef4e932198c56	17180
1675	593934b7875bd196bb48f841c908d2de9fda975362edecfed6ab5d549b531277	17181
1676	a89e556e2a6d1505727c393e5d2c995593a17d3bbef429ba4827a2225b4d1ed1	17183
1677	9b15b2b1b9dd93d9bb8302e608eec6f1012478cdd5169d71afe95158289317fe	17187
1678	31011c6cb1a3dcb531d0e563504accc1186b8dc3d21534b725a9c12d14d28ea4	17196
1679	9c8ec7763203f1599cadbb016ea9b01e603e92f61fe8a420216ecbb90ed227b6	17207
1680	4cfd36e68b0a7b8627807287dab04f20a8f6b7bd075418995ae66935bb620665	17222
1681	917420f010556848b1f2b01b03f3fa1e98b12018f62effcb2a3fe12783de2152	17223
1682	69f8bb099c1b7e219701d28cc448e310e806636f577a419a34e6390fd99d8709	17233
1683	c5d0b93cf6c8466c9d4b49eab5fa73a7f29ef1f64037bb9a68be9692c6311556	17236
1684	46ecb7774a92f70a125b8d0e7eb4e524185d89a21d31e82bcf5c6a296b08f0ee	17250
1685	5dd45db9885783d50ca401bf54129b7b070d4daaf94efa554454ec816a337246	17260
1686	b465118a252a137413662a65776e360f871c595cfb97f9a2559825c4baf56afb	17270
1687	1f60188b77b0d71a38878f0d25c9fecbeb5662cf90677ad6de64ba67e76733f4	17282
1688	906281fb3145d226addbc264247d38385ede3926d33ab477f3a5f2ec89def076	17293
1689	7caf6ec0355cfa7a51a412af9e117ca602abf357df9ab03204c7b9f23e395790	17295
1690	ae5bad254f027ebac75e61b7904713465e08f4a8956465b34dce7d0f0d93519e	17307
1691	773868df8dc851fb02bc4810dbe99fc9535c184e95a830487a8c68da2b73f300	17310
1692	b360773d989c0f90e59842b564228c98c494d5462dee235c99b517535c86f224	17317
1693	b2160f1df858bd6bff1e5fb7c8c92e46a228302f76f68d0c6d0269bf693cd10e	17330
1694	639154d71e0ea084b6afa90a7d179566bfbf713d571543a74269a49b34a6460e	17336
1695	641322de535ecf1ee7198f162251e9027abc74749f734aa8ebc44378eac1ce39	17350
1696	b5ac43035b5a460f3b7b75e5f6e25ccf52e557ed1995f81b31c6e420ed5bb2dc	17352
1697	5ae71f8f2119afd269fe9d31daff24236abe58bbf8edd3d589ab5c2b8b2c1c19	17363
1698	709d56c902678afb5fe2c6307471a40ab41db3d1747f5d2c1159400e54e06e8c	17368
1699	114956db4a7b32638b43f0618694f9152928cd5b490009bc3eda38d289e820f5	17399
1700	7a6d7a3b8186ab2f9ae02aa795e5368b65206c9bcd003914549d681c5c17aa9a	17404
1701	35e2102d5324b727e754736737dee87f4445ff1ea3b03e8a684bbd13249299fb	17417
1702	1da16bed744913b23f758d12f0ddb6abaceaac8f58dad9b46eb3c7f6f051193c	17435
1703	70ea31ba9efb85cc6b2e1fcf3507667119d29bdb111925110b8deac0adba7511	17443
1704	bfb232c1607be3ed23842ba450bddddd6c75a5f174b2a151ae06534dc9da81ac	17454
1705	4cab21bdf305e5ef6f0c17e01933f1436d542071aac5aaba633f09e631a0d781	17463
1706	498ecb065f450d4fa4e8bc4786c911280ff778a35b1182bfd898755bb4d7d5e5	17465
1707	e234201a4b45c8d7e3ea88af4afce7547281773e492a8e5e7d56d9e59c3b575f	17481
1708	6487f2590c70ac957b36c9fa462db809cef3272a8602c5544acfc0628410ca39	17493
1709	7e76a1b77cf9dee54966f3cc81f2b0fc98c8b9877f4e0e6619d4fb0fcc21cc84	17505
1710	570d06b296b5301006d2c17a7d6112a445c38c538e42be407d4914b1b6c15efb	17530
1711	76a3620242dcf308ab560f44de0e1eaa078092b290b4af893e4ca48794d7ac72	17537
1712	abadf3ce124a5241a823fba1c77dac888f473d345011855d8940f14d5429a472	17558
1713	14f1820b8cb17b7f8398640929da6a87dee7df9789326ce1b0ac476ffd868d01	17561
1714	8f5020fe115fa13a8bd730c5a91f78b88d3590e36b37def99451df4d51c9e066	17562
1715	0b5eed6318cf1477a90b7ac69fc0a98184758970e754c79a36af3fd38ba889b5	17565
1716	f354ee923cca850570880470e243905c2c75eb620b8aedd0a78a82d0dc05caef	17575
1717	746e59c1080f5556b17bb278e06539105089b1356f684d4e1ebc251b5f857e55	17576
1718	9447a7b8c94d03e8ffe992c4f253fb052f019409e19c127ddc8e8407ba7396ae	17586
1719	8953490f1cd57c21f5c724487ef6252584594664a35e7d0a7282d7e476d16c77	17616
1720	50880cda327fb6acc9bdedb717b2f5c888ddd5c867dcaab7511a766077037ae6	17618
1721	207646d11d16aca2e203cc295d1f4a76ff190eb0ce34a2ef2cd901d92d083b2a	17623
1722	cb94dd127ac19aeadd27dd9741e0ef8c2be7bb4f33f502c821bb370a918cb5d9	17645
1723	2d345624264b609f7d4edca4cb6be6ca48b4205e34c7b139b8b1d2abbe7ead06	17654
1724	d5d189101bfdf3392d689e3e1bc52a63108d329a8aae64c8382190f55fe91fc3	17680
1725	ed933bbfa435b7d8e8c2bc467bddf88953277a4379e89fa29600e157dcde9ed4	17695
1726	c6ccb8713a7d3d21a3a87c565b21913f518c898645457f7f594157470792eac6	17698
1727	d00f417cdaa51d4740699cd623a87f3f1fa5eb34a7039fc0e09f58827193d930	17707
1728	10d2ae77ba33b30f6523d90aa298b86691b21c27b2944e68e770a7cee7a210c4	17711
1729	69be8d404a17ad7e08302d01277154a820c5875ab7d25144a302555a16be4735	17736
1730	b583acb8775a6b29ddda7ed2ff21823f152883d905460203a23b1fae0a18fc60	17768
1731	8461728aad7994a06d46845b236bd0faa352a23caac3f64c042c1d5aa65bdfe8	17769
1732	479eda29ff0156bd5d7c7b3ab54bd9c1362020db2431db081504529d1a512b49	17775
1733	17c81e5052c025540a581ed8e4a7958edab5d00700eae9dce77b2899a2c9a24c	17795
1734	e2d6995e6587bab40905426e6cfd222f430cd09f8845dcfa3850e228125e126b	17808
1735	799aeb9901c4e8b26b784c03cff2416449f8044e3f509c7877d1bd19d65aba88	17833
1736	b7599ef6942f33325a43d1ada9af09fe806f87540d7c3fcf1db649b4f208e043	17834
1737	d2110edf8bb38171600ddfb7bc29d13087c11e290f685b455acb3ab7d78fcb21	17850
1738	63bd28c8fdc62298e96773830c28ac0263b4872e1eb736ec4d35d64dadd6bcb4	17856
1739	7aa33be2a1b292514fe946b08b5ead1de2fb04f62f0cef7551222aaf13cf64bf	17864
1740	95d08f338f7381b0b3aa8f19ab57bdfaf72c7a8f2f041d26b2278d5e377dca38	17876
1741	ca20ebc1b2a6b9c14a489da69ca12dec7d12a48167891bbc7d23c63bff1cf86d	17878
1742	238b51ab60b3709df302114c2ece2aff68e34053872e71fa15247ce91d18f7c5	17902
1743	462e70b54f18b04893c958a8b197ae10b393524d0a72a49d63761577a4b85c3c	17913
1744	ab9353ae7a5d97dfbce154c902768807027f60de67b2ac7ace19f93b07acd466	17928
1745	29ea5f40bc54637bd079b446a814554d786b7424b9cca386be5760b09ebd7de4	17941
1746	ae347df0728765742a789286f2f36d7a92ec10ebfcb7e12c0994854c83f3d7c0	17945
1747	77111ade98142190e24f76a346647a4dd5312b9dbc474a673d9300f9d49ec59d	17955
1748	bd6994dcfb6b732712d58d303cf10659fa0d3eb76c333d172e9bf2afcfb824b2	17989
1749	ed033f24668de71d05509b6b2101d94cacc67b3854c3ca6cc9f35944b1b5702b	17997
1750	fb531f03c55810d638a635604072c80862e9198f445d2f903a120bb3e7d5c2ad	18001
1751	cbb44dbc5d2bd6865ecd6b45be3701d9acd6a7bd9b55c8916fda71d3f62ef191	18004
1752	086e5fc246006d9c01291b2abd0b212ba38b549e945105822fb7b417ad2279f3	18020
1753	906dc8663f7c73acbc6dd386a98121d5fc0c1de90028b2e8185e9ddac866f68d	18029
1754	90d96d0a40f478b9c9e7f0c16b757e0f67e0a6d8b5005c20292b7e501ef676f5	18030
1755	69d0f585a516020ee1b17c131be565c6117056abb93132bfdb59e7f18c727226	18048
1756	db4af51d335c20aa33b4f7ef931792a3b075b16312b784f69640436bc676b321	18051
1757	91f9f842cce455b1452379d4b5d43a920e87b9f65703f49c128417d31cf38618	18059
1758	9ca3799dc0c1ad45d708d02640f3020db37506475fae383c89121e3ae47ea18c	18079
1759	dfa7aa3bf8108725fb5cafc217e824cfdfc7f78032c4b0f3abf7d94d9de462eb	18084
1760	bd806972373608d0d9e34fb9c8040a70450b2855ebe5656288892876ab54e2cc	18095
1761	30644700b7843a086faa452b05e4d818772e5a2979cf6ce6262a8e918905e385	18124
1762	a98d9161675e151cb0589fcc16a789b6159879dace057264f909271834701bec	18127
1763	02b62ea3c887cdd01dce3bbd2ca34654ae30ca12fe026eab94c9bacf1cd9dc0b	18148
1764	21864d01cbdd96dae37808de4cf49703039a276ecf7790bebbcae82bfec805c2	18154
1765	6b18ce6447782e1743c714c574adc489f4bd7ed701a99454da82a62424ca4c49	18165
1766	8eadfd829575630dcc33a2221849bdfcfce528874790dbbc42f67df9b13cd565	18170
1767	fdfaf90d2e906607bfb63d6a749a26bf5f18c520a64935540a0c9c193230d34c	18174
1768	aa79e62d924259590aba7375e129ff530441cae81aa2447ececcc3c4d218cefc	18177
1769	a0c321de3860186389751632d4a8095e750b97f2b26a4b4a65e37ea9169473a0	18185
1770	5237294cc01c18ea5f777f747337d7f546ecebc495da39aba60981f1b98e4146	18189
1771	c3a9ff607ee3a748391c19879ac1169cc42a0086a9c9db1e207ea4b085ec50f4	18190
1772	5844da4f37e860714a40ecb8d675d5722609bd893abed2b5ee23bfd1da587edb	18198
1773	f6df682b2bfe3cd02c93bd290f8612d03cd6c30212e239a0666e25d0600eada6	18206
1774	7bc4e3375fa05b210e4e6d7db40263d395a09516465a7f0f606512163b355505	18228
1775	506878703a7f9043f0fa9a07d3074c7d408816b6742cf97402b58eb12b42eb12	18233
1776	4094a9343a7dd842c49c19cee8de49d573e249e92a36920308dbe4cb48faa1bb	18236
1777	91f329a4752fdc82778fefdb35d8c8dbb6fa95357789f050df975c4b410bb441	18248
1778	f085f86938c85cc77be249eb6eb779866feb1fc2d75cd723590b14cd753545ac	18265
1779	3805708b5d8dcde3b245d8eae2f7d57411cbb410e0b6ff99e74365131db51e17	18280
1780	88757d802d8ccd75ca2a8d5a4a2b0c0e1a902c81cc56f110706180d6c1c6cbcc	18284
1781	9ad80c72c5646d38bcd57e40dbf243899ea4a38b29332345f4d98b5f45bae4f7	18293
1782	d0de64ebb3bafef818f5224dcf5d20c64b0fe3ac4c730543b2449163988e7b14	18297
1783	38f599a505fb373de35e935d00c018b1ccb2aa99262b4a54f3c22b52208338c9	18320
1784	82e48efd70290d02e0cd9959b3fb906018d28150138c2773cdc4910306a780cd	18325
1785	f4a78588410db47359fee2385c0ec782dbdd18afc459747c018a76ad7d851b6e	18361
1786	9f8028483be83f6db2252643d371ae39a3fc6bedd9b51c5ee4cd28d0dbfe98c7	18362
1787	9b493b383e83104cda3e51d738886f83bf24f302dfc983a45cb5c6bcc25d2c4a	18366
1788	7ce5225cabdda8cf3c5223cff24e7d50bc2413ba7222aeda05ca544a96b48e6b	18369
1789	9c15e9fad9786d3bb39a3c3980f745c34ef1df466dd9a639a24811afc54ccdc5	18379
1790	e46534e0d543c8ba6295c63ea62e0ad72120d446c9c6b53235515e8f36b873e2	18399
1791	da3e70dbe194223556596af2a4a88499034be7e7479575f4c24a38d0fe3c98d3	18405
1792	dae1365ffe43981f6d170120ef922ab0e7cd7eede297af5f41c21b3b6b486124	18416
1793	05befa4f4ee1db2384e1599b6f15cde4ea7f45cab11c86dd90ebb06ae92adc48	18424
1794	5a82e0d8278db0f131779bef404400a055cadaa0a5f7bdc3e14455c3e3868bec	18431
1795	19798dece83850bbb2053200c1b968bd86b264fdacab5bbc3a1c714f43591b22	18440
1796	e211f414adbf15d28c03ef68ab1d21e501e74bc6caea9837069f5fb84e662457	18455
1797	bc64dc8e412b76f4bce3952bb81e8afc5e0f4aab1f36255fe8876fb1ed1346f4	18465
1798	5c046fa022722777fcd304310e759c781e6acdb6eb928fe9c1c0694bc9b6741e	18468
1799	7641882450c09874261dd1a71a596ca5da3bade953532133312b16cd6f7def8a	18475
1800	b1091ddc2d8429266567a5326836f09284355ef41ba4ddfff185c31cd12e01c0	18479
1801	251a742bc098c2e5e4ec5bffad181d3ccf7fc918ff5cae1279812062938783e0	18487
1802	8fe7cadca5138728d353d24bdd98e6977092859fd9ad961f12ba69ec286926a4	18501
1803	3f48f355f705af93bb729a726051b5b337adb7ff3f534a8765d137a071791cae	18519
1804	c6e051759fbcd5c71f064a281416d5a1cbcebf361812186fbd6d0d0ed27de9dd	18522
1805	5ab2599b5f92e1a10dfcbb32be00e1d4077fd4c71fe98a250bf989e24937bb65	18529
1806	35392c6ddfad39e377edac00c2a56d57d2901a0e9f152e2f0ce4a7ad8b04a939	18535
1807	a01d1c99eefbec89039d3af5ac60b4ab8d9c11f011f3ce5c419197a5461eb0a3	18555
1808	8a9333cc13c43825b5e5f56796252e22fd02e49e097979281c1550a3ed2a6be6	18566
1809	c8407015a32bc351d07a03ae3a1d2447b8f916b3a640ba5ff001100bbf6e178d	18609
1810	9d63ea1c5f718364c17726358d9935583d447941495a586f4ffa25ca6fe03158	18629
1811	98cb527fa594ab2111c82482d09da5a8d05bdc7344c719ebfd4be8b2e7235c71	18631
1812	78d5e3ac9bf560b0a7b17c61c44e08ee2c0be083d2f88722208c65d6439bbcb7	18635
1813	ff696225ae5eae68f77bc66d7107e0c42d8916f5040c1e6a2a2f8a7866226a5f	18637
1814	eb7049ebe1248f7515d1e1ca43dbca5b7de77bfe1feaef4d7eca672d2cf39d30	18661
1815	498d01d6decdfcf99033367e0d1c8fae4b10befe537c3eb6f30ce993b57a860e	18681
1816	d6ef01383b76a049f27e1dad74a343c1462fd85a6f7c385a768147f360327d4a	18684
1817	544baac20ca65714fa3305042983fb0d61dbf5e20ae4f735127f9a000d203650	18686
1818	d5cb0ca5add1c9caf49fccea04e98584224c50eaa695ad3e502f4ad531502024	18695
1819	0f81bbcd496d30b0f7d3af3ecdd667632903c877437d9927667d83a2f917d444	18706
1820	667434b66432fad9ee5d5c47cb90b5d69f247dcf0a0ebbc662f77dc07441c23b	18711
1821	227433c33f779b0a53ed889c2e3d92b10503bd4b18eabfd9fdd3e4f4554b8619	18723
1822	b3c3e945b58982b98d4d445b1c86ae4dbb1a069e7c026450cfc9d8245e7629fe	18735
1823	a4d2a9d37f24bf534d5f6ff9e51ed9a0ba42a6454025573a18698e1c1cbfdc1c	18739
1824	76b3e95cc68b470e39a465462b49065e586bffcb45a69bbc102da3ef5c7ee274	18757
1825	c3cb2907bc46975ef538739106638568f1e48cef576faaa91a56496a54888bbe	18766
1826	8639f43f15a65c3cb4147219ed06c79413b4c12b248f162e919c8e8f1d7dc6bf	18768
1827	54ff71d1964f86cf574c1c1949eb84c8dfa209af2fd12c56d7cad708be252ce2	18777
1828	5715cd4d0d2ca1d51537bac872550cf5183fb0fad3be5872c69474ec8af26c51	18785
1829	038ba68517201ae7206c28da6e87ff5c0452d55bbbcea64d2e76de9133f0bf88	18788
1830	b2960ee6802a7e4dc058af27164d7026333945590515060010e248e2ae59c26f	18817
1831	7f321f156dd8d9fc9f76e58234bbd86fede6d6851469c9df9168dada8499a9aa	18827
1832	89dfc956ec306a6c274959b8d151b5c801c6da348d4391edc3430c87c5354c59	18831
1833	c49244c3c166c6186901b390fa67d88e77a8abc384a2864c3a1ce0e3fa9616f7	18842
1834	53171305e192fc092c6f3519011ced206f8dc288b3820e9af422ce1a5d803db6	18855
1835	fc741b2c4ca92dc02fe21bb8340b9f6dfdf9e90f1e34c639557d27ef4d990cb8	18867
1836	85c3c80c8b762003c4a783c70226854e169ad5e98affaed41eee6d1c9a056300	18868
1837	e05ed906a5df75eadae4520b7c1d6838bd9f02479126064c4dc16b28172aacdb	18903
1838	67c268cc50895175f8aca7d7bc977f7b68af39c01b693b6f9ecdbedc32225a8a	18910
1839	bc76c7294d1fc76aeb390c85fe3b3f8e85455b5b57aebc73631ed404c32c474e	18919
1840	bbf71a75cce81c4e98edca07bb2798a849cb9caae9c2f1e36a56804aee03a5e3	18921
1841	f5ef343dc53b12f489ff2f2f40248e7325c7b2f650d70bd6b0b1ffde612ae465	18930
1842	189540e383f00dd1f779ef8abe2f40355ed3cc49d35850774a257771e2034870	18935
1843	0e1b68b5a2b4b4c68df92ab95d45b026750f4c773574a2e4c428b829996cf8c0	18936
1844	7b5b06cac08c68bbb45533acbdba6a73ea528ccd7536a682129ffc64e2e7279c	18945
1845	c0ce1a159850edcac4f553c182a208cdd995041735aa77c34c69266fea2702e5	18964
1846	28570b0a65975563ab1146dffe0c9da611f5a8d2640aeb244a24c180a9be68c2	18965
1847	68f310d29e2ed83d13a5331d23c18cd7bc713aa9096cb7c074690e6203fffa3e	18968
1848	a854c73cec4c7caebb750d0945896c1232e03aaaf274cc42bc322f1c31b18fec	18975
1849	a6781235e301f68f0f5dfe116a3e9e257ddae0a1ff8417c894a03a47b83b435c	18997
1850	3baaf090e56ec00567d2dedff3083dfbfe96a0ff8d764a4942135f79e6d02fa2	19002
1851	d6b997e396c68e217bedac59167f26ced8c7471a64f80536c5f2e86c982053a8	19010
1852	69a38472bf0bc67f0efbf6995166466f745e5d16eeb12a0020d195e6b9f4284b	19015
1853	10e9c005d81cae0e93f66b179bc3084498311c84d2f5cab9e0e29e45530cfa21	19039
1854	5a88f13d62e19f1df9db1f8f082920e0035db20379321f1a138565cd7deb3107	19046
1855	7417c0d411f11d118aae4c1fb161ee5c728f48ae37a32bba9a66a61343ec3b0c	19060
1856	912e6db87a3b705a1e194991b37265a7a005cc74d704cb72765295c41a4a024c	19066
1857	0f3f506f085916bc98a4dc0f20c8dcba39ca0ba64b77f95deb91d3d060bc45f6	19068
1858	a40dbb27c4b3a3b8192521f3f3081bb959c955087a351f76dd92dcd68e1d4c13	19074
1859	6a817180190b4c967e40d85d853965ff0ccfcb80e6ec7a95eadffbcbaf93083e	19112
1860	016bcfc9450a4281d3d59faf84179c3008d80279e0b879ad71a98f1f7a20d598	19115
1861	e0a80fb752720665cff7182a2a4f050e32c91e5f1a7bcb463e504dc7c5fd7e32	19116
1862	f0d190c7ba7477816609f96977a2ba2a5dcf7ce592f1e7f12a2042f7d393890b	19118
1863	78effdd57620c400582d6f76844cb9528c7f62bc071127e74baeac59931ea755	19127
1864	7d96d1fa43d73f18a42133e5b1af9e35fca0c97d62df7383f4c6869a5d6e3442	19128
1865	ed1f179818cdbbf672618ba4264475dfe6cd29429623510a3a5f16b17279dd12	19141
1866	b1e17feb9c025927b684332ab09af69a69f8c25fef23b6ddc68d26ae34546c9c	19142
1867	e53e83af2a26aefb8572252156f544a1c436af7446d0414bb32d7aba2e828af2	19151
1868	ec2f5752f9067244d9e73ae5d60640b7d033db27d7d2f44df1066c1017bf3035	19158
1869	371acf177c02e6d6f898c41cf347043eba11c36d3c46c08e7012074d6e27213f	19160
1870	f6c166b05e13794c334a570fbebb5f7a91070835dc2eca23fa9ac882431328b0	19166
1871	e76c9df0648df76a97cc07c0b1d6af8f17cd982237fbce54b554ae853f91aea4	19173
1872	2085865906d9fc1a963f3437ad7c82cdc2bf36e68c3c342525e75200bc42b054	19190
1873	caedf58226e42abcec806c965f25a13bdf914b74395c0cf29ebc6ae1c4a6ad8e	19192
1874	49658ab33edbf3ff86cedf57c62aec12a9ef1fb727e80b1fa7515a3b77eadf36	19193
1875	d036b53e54ab30a88bd5dd84a12c030992c8a9206d59ced1b6cebdf50185cf24	19200
1876	e7efbfb4b3b30d6257b0c751537ba25033c1f4d135cd236bae765553b5ee42af	19208
1877	8c001409978c03c9afca8eec5e9c2a36a0306f701b028600fce2d2bca8f61ce6	19221
1878	605f75790082b33cd9c0a1496862a722b420dd45cfc9df2274848b9339f62838	19227
1879	c42991f5b24ad81955b0445be057e9b8757f578f431b3228275a35dd71b60702	19234
1880	5ef51459a5762b9c0779f352ec4bf24e1706db87287d95c41e61a49e124c54b7	19251
1881	55214c9377a0ebdb00642e3b0628ab387f9e742fb3d84a8c44a5d18b3914fc4d	19257
1882	ef3a8ec32232e0355c60e286f9afcedcd4b585d448352f50352c7f0626cbd171	19263
1883	597df8c1319f3ec9ce49b969d0254ad6eae8088576241243691ae51d474783fd	19273
1884	579dce2c2c56452bc0bedadc4f628d66f2f857234e856ac2bbf34ba971481c05	19280
1885	fb7501779952c4d7a59a4d9e501ede9c5cee41084edf50b44371da6d36e39ec9	19281
1886	debe80d27578c5c53c0ba32f5f36dc7532e19aaf13ad4132cdddcb8ec58aa38d	19285
1887	855d49d2255874ec0afc4921468b01539a4b8c083005f6186974f8cc452d3396	19288
1888	19d1725296ddbe1729ce84b8451d86af0daf24856fcca9f5d1ca6790316e8267	19305
1889	0351ffa8763ef5b5f41700560bd1ed9862bdf877cb00824d3dc88da99a480bba	19306
1890	cedc86349c0b2faaa7d944bf0289f92b8c248749fcbc9f91375c69cca596deb2	19315
1891	3edfe3c75c90e688380e2dd6d89e5455066078fb910d5f29b352a1dbdd964d85	19329
1892	0c5d9ee76724ed1a41fcc2aa9ba7ad580416d59dc4e910147ead5112abced9a4	19333
1893	994a166c5a1600d136b584d0600d8150aeb49597fc1e6aeb557019804f1509a0	19341
1894	6fc638c6012f02947f6bbbd3f732e933160ec5765a91a392c921214674cd4965	19343
1895	399a6e923b209187d971d22f05ae76803d02f121a94d74807d69668ec1abacb5	19345
1896	b46f66ac8bf08ff76414fc792d82f97c423e72d45d32ce7119f9c6d199844630	19348
1897	03823c0eb07f7d433ca1cc703d00de4087b979b333016a79eae23fd2d69f9dd8	19359
1898	b26d3ebf1a292d0f12de83d4820dbc776d1b297a4d3d95ce9e07c274958661db	19362
1899	1bd857e854c288eb2252c313352950506b1abd9fef64c46f69afb838b5487ab3	19371
1900	61ae33be9e1600183966cd8fe3ff3d6fa6047fca7bb0fa5b55498733b5ef57ef	19384
1901	4d545d3050bf8033bf59992c29f4aad8516c950d70250e07bb2221a9712af028	19388
1902	7abdd600268f1ea4b673791009e1fc2bc80584095fabab9cd4162f3ce4f53278	19390
1903	edee018649abbbcd78c51df36fdbe16f18b69266231b13228b434248995c18b9	19399
1904	abf27130be37c0584ffa11683f53a6454a8b4cbb8e7e05e45fa7612543e1719a	19414
1905	b57ad667f974fddc53304d8be239e6f7d1e513da3dcc11f0a942988832e6ad68	19419
1906	2c9120ff39a3ded7a6e4d4fa8510256b4f3f3e53de0c633ea11cd4f62e00f453	19424
1907	679e223b2e2b239c9635ce46c905c0144cfdbbf9100f9931ef9d6725a1ca8f0f	19428
1908	cc536a90b40b8ace052058cacc0dd39e8cb3783afe1f4c1634523600140d7d1b	19430
1909	f0337dc7c9aec1cf4c20520127f0508ae7364ad48330ed3efa30769f8b649d09	19481
1910	eceb2700307c3b2ace42eed1eb21decaf30fd912844ae690aa9cd23bd84972ad	19494
1911	68f3c05ce0bb04819c4c3cc60318651221e18a4fcce6c71e58e6d646c1b53005	19501
1912	8a7bff6d8f1a15ddb03522233d593d62f40f914f75e962daf0d06a188769c2f3	19506
1913	004eb82eb2ffdbdecafc03d272a8f9caa2aa9a30cd3282257aedfab16d9cb2ef	19510
1914	878bec2f58d45b93a546f5b1b2527d00ecb32a4613b2123778fcdc08b55007eb	19516
1915	380e76721b6a436c570aede048da9889f34282785d08233b9dfcef90e50715df	19520
1916	533b67b41f5b0e9cd109261a23799fe30ea191b625102e795ccf5eed74076780	19527
1917	bf582be754aabe88f294d5defffd4f879e7c390df7a32829f4492d0ae38ef40f	19545
1918	8c359b323ddcb914292a0e40df9d565b2cc342580b222a98d39f28cf2ea5cc67	19548
1919	b99b75ef0af3981e94caa1f81698b5d69cf871b223545943be5d02366cb8e0bb	19550
1920	a271100ce46f4b9e4a6eb1d767663d5c6c153371d33f5eb7e45008d420cd9e53	19553
1921	53a1bfbce12cf8b132077504cad910401f964c5d7a2abcdb15a90e2d900e96c3	19560
1922	4aa15940dbf398e61e60842e45e8480a2842d80bef999976e71e6fe52eba894e	19563
1923	2bb4724c290f427ffa9970e3c55e1f9855ca03f35e9cba5a514ed4ac17ba1e00	19590
1924	237b28f386d9eaeb4d1ac40816b6a85c8496cb3d94e43e3999873286f8fbe6be	19601
1925	1b7280f3ea3aa4fb4105094d6228dcbca3ddbd47914f1405bc90433bdc6dc23e	19626
1926	7f121d7d4b3080b35dbe138e588010dbc3e716b24ee52715d5c799566f5e393d	19646
1927	ff2af64e499f32f86cbc5b127636f042335646043c1de0fc45d33da11c954d8b	19650
1928	6cd5e203bcc49db64e38380b3783c0505990e6268ac0a4acdf14f818f1f2d54a	19668
1929	108f0902ddb23901a444898fe8614ddd7c4bf0355ceda534aed4649cad7bbd5b	19674
1930	88fc990beaf13380a8dc33cbc4f06cee28013f8b25dbc5ec171f5c876b8ece19	19684
1931	d76007d7316d326e99511939265fa299c38b1f8691089a4090edaf6a6aa28e90	19686
1932	ce0cf35fdb9913f86499e2c014c1ffec23e662be8de85f1ab3e120453ebbb44b	19695
1933	4c930212d726064c5ff9909a33c174a0e975aca276c2d10362afdcf03ce9e3f5	19696
1934	44d85ab9570c0b17487e3de0dc4d9cf7954b02c5f40349b7bea798ad396fb87c	19699
1935	e0d4d06a96c6e3c2b0d784d6938a87ee71998bedf857d5f8e63d0417775b573e	19701
1936	10a5c2bbdb39e89caf6654708d5cb29ba3d5f1ba1c0985d29ac6a0a2f7e96cf3	19706
1937	bac0759a6691a3bee110df31294ddc669468c76e67b61388fd1aa0d3791d16a5	19717
1938	2a2c4b31b97d131995fbacbb3143a8f1481a1fcb88ade4f61dc2b817deb16490	19723
1939	6d7a9492a19dbd764bc2aabd62f369e4df804ee42e8e8e663bc5d2a76fddbecf	19735
1940	0801ca5d89ebdd71e220b1842092c52236137bcdb97b501b78aeebde6dc476ac	19738
1941	e37f4a26bcb8c011e7d0dcdff73a10effac7c644fab7f74fc13f7faf28154d00	19739
1942	2bbf14368291becca9d0a48e7fbe47af9bd0243c86dae3536d514911420db662	19745
1943	799e6994f603a3fa2ed8a69fd6a3872879929684b4f7de608b36197d96607dea	19765
1944	c06aaa647d269fa633fdac01eb563d982c8e4ef0d119bd508437ac7915b219f5	19795
1945	77769e1a9d8180db335fc4634320632aab8bb786d4b4d7c3cde097e93eb5a8ac	19802
1946	82f527e10d34f0a602886080b6ab6fa33bf089cc31f4c914dd63345f4370ac40	19805
1947	3001d4fe08ecb7c2f689ba40825f399b219f914ced8c54fe25f510ac0da8d527	19810
1948	107935fbc358fc30d9bcae3c8103e06e42799c2ccaabb8ca92d9ef359370ddf5	19828
1949	3581bd6209be9985c793d6eb3acd4c161b936355ef2b37e6472494ee4dd83780	19829
1950	844cd70aacb0b2583478ff45a9badd52bd179a69cbf47411285db96222408243	19831
1951	897cf6dd06df0e689ea35805d375e65e127624a10a1b481151b803ccae212f47	19832
1952	aa5cf4968f6b5811fffb47d73da3447e81fd24b4e7dbe2c8c46eff4153805360	19857
1953	22918cbc0bfb8211a705f057feae4bfae74c7aeec74aff471915032a6b1b676f	19889
1954	1cfee81c9ad3534c2a0df634e323177023281e40cc9ff006eac2c54d23b6e848	19901
1955	05653473a94b8bd001805daed6ff0fc143f04257e01516f1f08e638485411335	19919
1956	3437cfdba7b21099d0e81a688efad0a390068959257cfd2d43b5ad26f6a29166	19938
1957	fc308f8ab762805a4154335f63daf1d8264493044d6931cd8925e404857be905	19946
1958	74e1d13e2491aeda0eef74597d7aed423f633a96c602a5b0a6db4bb264a3e904	19947
1959	d0c4cddfdeca417477d3a0c85d27c18ca821af66c5722bf903cbd54eea07095d	19948
1960	1a6586dd0d6833b631569178b1433e72d88a1cfdccd80ca4777ab4ce44e5c151	19949
1961	dcfcb8250b0cb02f923581a36035e7b0ed0ede2414eb252128ed88088d229974	19983
1962	47c62633def920e2f3572374da50e848f68a0303cbc5560137b5753b57ed18ae	19985
1963	6fa493ca2eb464dcf47f500053f6187549f4562f95c82c2754e4bb53867a2dd8	19987
1964	3a38c27c20bd5bb2c3ede214687cb705527862f440dc8288f400ac93511b36a7	19989
1965	29f65b04823059fa3c6f93c78943c9a882208f1217c519a5a00492147a11c4ec	19994
1966	0e274b31c8228b278fe9680f37779152030727d823694303079f61723979f641	20012
1967	bedc2e1536772dd871be425a33f8a1086740d672f5c1c19fd597219ce4430059	20019
1968	e45a542471343ead0c0a3fddf4fc80dc3d420aa69c929e49ec570f5e11eb300b	20027
1969	10aa726f4253700410e8761c745af142b1b79b5764d8431aac42ac91274980fd	20030
1970	5a4eef15029e8cdb3e1d9e32c12c4304e13611cec0d5e58282ca1abe953a0d5d	20038
1971	9baa9ab85fa24b437093e2ff0cdf08320074dfd2d7e09ba60e76f14fb34b2663	20044
1972	e1044a9760274a4039e688c6069918547e3ec11c371a9c5175225ec6bff57d96	20045
1973	79449e8f5d5cbbb35be7508bc1c64e8840c1937e0298a896a0494543cff9d1aa	20075
1974	f79a8e607d2fc634f8b26d95842bb11522e87f73107921490aa4c2093d002238	20086
1975	8d5d56ac001447a91336d09de2d6d9903177b9cf87224d18d4ab919900bbdfc3	20104
1976	4f04966e48529dd1f43fc66b6eff4a1758d50783b922846510f3e7b493334732	20106
1977	20645b0bb7f74444fe05292b62ec41cfee4c25f57ac582e3ad264f9cf53af76f	20155
1978	14105b5214c97fe54964b644a510fa64da6442039f3c900be19317adb39866a6	20157
1979	c94ceb7cddfe3dc344647ec6af83062547394624b3577ac235e9490ec1f8a549	20186
1980	36a45372720ccfd258b67efad03b94a3a5103e2c3dae3c3c828b9ff2790d4b19	20211
1981	bf63b316d84da699af244baf60f252f0f0e25e663b3148fc225ea52e687b58eb	20220
1982	198040324b48b554009e8f188efbf97bd4efd9bbf2f788caf6e7e5756441c9a1	20227
1983	0ea983731cc8e71171d49270ad6ba291b3a2b3de3e8648e67923feae37eb5ca7	20242
1984	b7cfa327b6f406518e2245e6f0bfa0f5bfa3f2e221616e68474b5b5999ee436c	20244
1985	9366dd2b4939d8f37ad77e86a0ab5795d0294cfcdc73cc4c03ce9984fc992fd6	20262
1986	e1d49c8c5a25e1eb402f325d272def89446b3d2cda5597ef0a041bb44a42814a	20284
1987	279ed33bdd16b75ae78654a63916b6d5d4ca98e293150edf7bb5fb7d65b5eb72	20286
1988	7865fadb76238d6bed3c44171287d5581212c316067837bc828a0dfbb7b3edc8	20305
1989	e54f0a3877029fea7449877483b645c1b735f159932fde753154f659008a860a	20317
1990	878555b6602c2fc85d7ddd75030e6b57f33bed3f0f288532d507676065a8ec51	20330
1991	5b9382d07aa7136c275ebd99ffb0752cdca4a12008af7dac2a1d0d5259e33ac1	20331
1992	40a2cfc60bf1892a9874648487c481821088ac18a97599008439d0f40a6a2e0d	20352
1993	aa3369196ee6ca0512f9429401522660f0b0c91f57be1cbcc3dbc8d88ae4116b	20355
1994	5765eada8facb6d90e4862fa35433e3d2bfa1ba9a442a37adc03d00587ac6aac	20365
1995	1121b3f5393713a5fe8df3d4f8e036f0d491123d40714539d9822afad32fdaa5	20379
1996	993eaf362b9415082c7f8040a5cc5191dad8baf93fc58874f6de4020af686241	20387
1997	2898b6c0f010706ab5499f6b1b977b70725545f3b7a888ad7d68943cdb4b94c8	20392
1998	0e512ddb980d6869bc68f7a9fa079b67044186f7131526f1e20d8ca14da9817e	20393
1999	9b5abb3111d0e0c5535d4ae3503bee56f8404fb5ff35520d17add46ab0510fee	20424
2000	ffbd4766324430087be80b457418e6979eb081ccecb192e34de132d4f94b9bcd	20442
2001	2c2500f074f9767ccf3ff80129e69147756310b5e70597377bd2073ee3c4d9cd	20444
2002	ff077abcc801174f17a42935f088a076eba200fef08b5966df4e30b18918d2e2	20458
2003	9cf48057f27f049aed1cd61cd89929d453a63057a1dc3e0a53360d9b835d626b	20464
2004	4f69b36c2a05cace2d776770554d8e2e268f25df2e54c42f8f00f1b36479b473	20467
2005	71cd8ae20241f2c53e882ec8dcba6f367aed55a5dc78b3dbd63ec29c1d279008	20475
2006	0957de3ea58a9afab1fbf04f9f415d9e8b8700a1365b2737248a2bb234adec5d	20482
2007	d2f19f128de7eaa1caed45c5459657362a873347eab307f090cef0ec270204eb	20483
2008	7a3a13c1533fbc679231957484f6a0c617b6680089ce6ea810f618b84881b09d	20489
2009	6286b0b776cae8ac1ceb754a2c702e881389e2e5d789b3ec4398d3c688804825	20490
2010	95fbd6e7d2f58e9974ece7f8b31893114330d3dba01319b78603e054d00edd24	20495
2011	bceb09ddda2546d9e201a8558c72b6ee0dc8e43b4df146eb34763f7a5a04da7e	20522
2012	0b703ce06b41201902650a3aee6a22cf9225a91fa6208e2cbcf51cc5d2d8e79d	20539
2013	e225c6f5071baa73e77695b6ee3f9ab03077c4a095d48b3f56f0333d3c6aa206	20543
2014	5eb50dd80a3773ad45d482da45e03886f304f4657bc7ed01249cdcf691e55fca	20545
2015	fc39373764c1b9f3dc1435d8096a07ca19643a9f4ea8d8f6a53c8e20c7c1e623	20567
2016	555683008b97fd6adf28b027e8225b4cfc117e3799eae0b8b0263fd2ed1a1f86	20572
2017	d9bbf20d0c9e02e887e2253675b0c39bbf08a19e25e3b8211c3918c5e1af889d	20592
2018	2e20a19391aa3d3721aa010ebe9286593e8e7a7cd18f2fc8c59106dafb0d697c	20626
2019	5a14724ebf0367b96348e52f3caff38971a8e4fce79631ec2ef30a0143dd9d17	20632
2020	509f18fda6eba2f011c36f8d86399075f1391e3bfb8033fedd2fc39d5719d270	20645
2021	64a8c705d12b3b8ec161df3594e8d5550361ede2ab7cb2f7dbb03fbb6f2f2080	20655
2022	d6fa086267da73d4b2cb14a241ee7a8a7a9d2784a216217699374ecfa722006c	20661
2023	4103e42cdb8f6a0f6c16c08164ff249e0a50d7cac43d70ee8bb340e75285e394	20662
2024	eb2da1ac7e38c9833b5b689d77f830a6d6cc7fcf7521a5b58e21832500fb4548	20670
2025	736aea8096ad215e7dc43259dcb87f4515ddf6a3bdccd5ad8b7f9d1574008a6e	20688
2026	2853cbf2094fa43afb4e1add6cad31ed2d07de223f4d60a2b25823c51b1fa0c6	20689
2027	caea4e459875e76f13ab070c34e7eb3e051db332665ed38661ce1922550fc18d	20718
2028	e1571cc5512766b75e0dd1f60dae7eeb0156f56e5704ee87ce76ce0f9f1b2aaa	20723
2029	db4fa66568562cf2265c23429ad4850b59250d4dc8d9a2632d076d21f04385a2	20733
2030	92ea751f24dc1905a0c735a386ca1cdeddd872cd647a2fc971cdf05a068f0f66	20749
2031	2d3364ac14f54277ab6bb1fc08f8754032175942f4333f02ab8d7388d3c91eb2	20753
2032	781f0a0cf1a63f3860ff7b8b6d6a2643654326473e6de046568dd3d8f8a62839	20778
2033	6e31c775db5b33c31af460fdad93c563b8b3fea6cb4a7b74bdc0889015e8bc7c	20780
2034	4db75519d063570aff26b6cde7bb6e37c8a012365a5db8bc44ef211022befcd9	20786
2035	4c644a87e7658a10ebe7896858730b7c43a9a119cc80e13f5e7fce4f8af4b292	20787
2036	a4e203f217a456076b76d2e788fa285d5695dfd40e0bea98a3a122579a7a6c54	20792
2037	1c43d3b8cfc4a5dba062c4567119e7b7c1d4ca4907718659235ffe33ee25deee	20803
2038	72f25bf42abf4051df8628082625a162dd1f1952a173945ea4beadbea49e7817	20814
2039	aee0ad43c6d421b708158af494346b67d23a5e9c985bef66fe33a2e15e3174f6	20818
2040	d612eb7a42a25283203b3965b64472d7f5ccf9ea7347cb9f5c5a3d6d861f5f43	20839
2041	6ffd2f62202b608cd7580ec28f428e8702e4f1ca13969a14693f7399e556b59d	20853
2042	991258900e2a187854088875e7d63c6783e73275be3bb55d1e14d5e1231979ed	20861
2043	9e3f0cb735edd5bb81e06b2e6d20c03500ce3ceaaf33bc97918b3c6441c7a4b0	20873
2044	326ea8427ba8739682735c4f74bedbd3f638a4c0d66d49d3c4f182e95e68a165	20879
2045	ced29345994e5b0dab57c003794f94b3da62bde38f4187addcaf1db8c8e8673e	20884
2046	c8011a602699e65f4ad5895452ab91c7815060253132e32c3affcb0de6d89def	20887
2047	3e31dab0ebcbb858733c837ea0fc9b6829ca38ab95e3aaf90e4b89a0d3d5d343	20892
2048	2c497f41fe50d8c1cc0a52f8ca9fc3c3822783b9048a9bbcd9f599a41301507e	20898
2049	edafc19f7bd74e123f53662c0a1af5e97c11f01333072b8daf6421abfca64609	20900
2050	205e33e5b5ecfd37d85a30792ea073d6ed275e315369d390722e35673c471782	20904
2051	f53e2eebca0103d1da31e788aadc982b934d56927e98dee3ec7f4140c773d827	20924
2052	b44d7f51afb6db37313f0acee59a26cb410782f79c1e782e5becd08285bce0e8	20928
2053	74f658e9e36b1c295194993502e25662021ee36ba42b7a72f25e897134b1997f	20942
2054	3215c4beac009c114b90fd4ce476a497d77b19362356ea34c1836697e1a2912c	20967
2055	ef3001e2b9b0da0882d56beed0d798a6d3f9870309666b3ab0a708ead4a4be28	20968
2056	92be81f13112bbbab7f2eee47972e478734a60b3e4df9a273963918619a6b6e0	20997
2057	c64ea017299436dd4002fe4e1549705129e5561f57ac6199d553228e9a056de0	21014
2058	542424c27860d0311b83802ae0fb753aebf3af04ad52221a456931057dcf68ee	21020
2059	fb316c4f8bd304e37d301950fd95b3457d794d11ef557e4b5a11722219af26d7	21030
2060	736945b701f153423c4d6f39fb6c0a6cd365d32efe5dafadf7890f0775e26aec	21031
2061	808406162fa4c4ea0c2492ae9cec01c0afc38c7228fc22b9930b5c95cbb452d8	21033
2062	e4b49d588c86c2bc433e2aa0590c1da9afa39cf36c6471140d6d47781c1d0083	21034
2063	5d5dd688ce23c7c5f1d9101e36e1a016ba8d7fe6e78145ab61d16226d66726d1	21041
2064	1f40605484a7d05511081d48b6efe121a5d4c9e61cb7a173dc7ec4f82e28d30e	21059
2065	5b405e9129cc3cbc2f611a390054b5574db7e8055569c1a4eb5173aa0dd4cb50	21074
2066	d25e064ce71013b567700a860d411a44968ac976e2e04c058ec2789191c2125f	21089
2067	91f25f8635d20d1fcb59a58dee5509a21f89597961ae3f297c151f8cf9e97189	21090
2068	0dff392534d289866c46f2a64107734ea34d78d69ea15c9ca3bd5b761f1a6a50	21102
2069	07f53c47e42acd3d64903b49930f3b6e6405cdcf957f12fe4c3146381a2901b1	21106
2070	9164078a583932c2e0face2aa93973bc845d745399ea6b43757716dcfa383093	21113
2071	9cf22504d914adec8ce46cbc600b7bc7e0e89154c9a771f877dbd35b3274fe87	21124
2072	30d92a705551f8b52a76d0e04194138189431115d95200e4ce3001c0830f661c	21128
2073	ccfa024cac8acbb3d9563a05752837c3e14d992b4dfa583820fa2b5afa547916	21137
2074	ae7327b238d5d1e678cf8552d9f5c8f82553fbc634acc0bc91afdd7be93c8294	21139
2075	02a626fd83d6f1142cfe7fb75a5a68f1c6b26e669208e101a6a9fc50b7da06f2	21151
2076	63e0798c9c646541bc47212b7d75e8624c9417a9862368fdfca8e8b959dda47f	21158
2077	9c719e69a944525ef298cee1342877e86d0046d363a2fd425b8f2c33a7f76b6f	21165
2078	d8fed0dc925b5716985f42484215844a3d253c70f84414a0bca0873cc2c2ea0d	21197
2079	8108219ebeef79174613ae2088c71e148f01732ebef7ce7aeb1047b136d15c21	21199
2080	6b0a79bfbfb2b17b4694a114f728adc72d18e525dee8565a08b18927794436bf	21207
2081	e519258706ead2f82d1d28887f1f263cff3b66282aa213ef58a1b4bf6a2635f2	21232
2082	d17f1e954a453e47753b5778851d2c0d2110ff42e97b216e2041609b2abfe4e0	21233
2083	8ad0da8c7dd5d47dd39f4e457116d440ee2da623e009cdfa3b4a1e3a5f75b073	21243
2084	c7a72f8824457bc12ced127d4cbdae2e83e365b1765c114602e0cfe79c7e96f9	21264
2085	5e944398de97666fc698ca5301e50f5ec8a6b7e0f8958179522b3c8bc65b8bde	21275
2086	2bc54dc88fbeb47f1197fa43d941c704d7f8a5905ff92b60020762a22ef5d302	21280
2087	6236e26187098b361e61c28b45c91558e801e0475a7d4454424fab61ceec3293	21283
2088	dd312169b4dd67f9bf087c157bea689d885dd0e2bc1bff516f608970977ecb24	21285
2089	3a3e26d0401c4c13f180f0829a39c6bc704380b93c0e7ab01c13a5b4f6ae1848	21294
2090	67817be46fba110812be1cd3b3116176e47f089240d4148eb67fe718b1ca7d86	21316
2091	8f9d2adf5327c8fbe6f9040695be207a2df649797d45fab4d33b42670c127c1e	21331
2092	82c31408701bec347aeb19896350700d62e64f9f5e12ebc3c155f52f63cf7e0d	21333
2093	9777e318326de46cc0100300270178cc5cfb4a55b1a9fa24eb72ee923622a265	21337
2094	98b38c4faf772e1004cf681758b34c8c511aa308d7921c369927f72fea3279be	21343
2095	248052be13d83178ff8e7ae5eefcefdfbe7cfd35f4b691ef1dac40c5c6ff236e	21369
2096	1978d40c995c4f35755d0ed05c26707d81144ca9640f423dc74d5acd4dc53b65	21390
2097	9b0a82322a7a20198b053a5628c341662a6e49468609592a10e80eeed0e593b1	21400
2098	74a76962b0214202bc464482eb5274aa6fbd5b5fe02b144b0898fd4d2a8c071a	21409
2099	cd32a56a382f7eee39c217371b7f6035664bf948437edb673f3328b03a73a13d	21414
2100	707777b56288404f01a40775dc9f8232fd7e761524f66a4cded87c0dd7525208	21425
2101	0c5e45327ab7ff3c89b2a28a228001588e0cd3da2fcf3928d5de763521abb0e1	21435
2102	6f42a5c09f064d9cacc64e89228b9428e1efba2fec3807fc7c47b90012bd61f1	21436
2103	799cd8917985ec6b82e334cbc2e3aeac8f5e71671257f405797fc883da50d321	21441
2104	b1b5961b3656c654e390e8941857373baf13188ffb8abbc520ff865169c53c09	21452
2105	5e019f8892203d9d802345fe9863f2b9a2eea294e429b168cd7d3a7fb2897926	21456
2106	c8a20016b7838aada27171939af21178b6d808fe8b592cb0990e5d9287b6e4d6	21457
2107	38d9410f9fe72f0325f552f07f80268c75fe0d15184788a13ccba0c2d33bcc03	21458
2108	52c3790c96cd8244c29568fab6c9c8033d768f43120edac9d063782eedd2463f	21473
2109	b7497f330f55d4c0c050af7870353904ee68905ef1d0092682b0ecf92d6c5218	21476
2110	96dacc9b0a8dcd11c74383afb0bb906190b26246acb1a5235f1d27f000e19804	21487
2111	09031d7422ae8b19b9dffe77fd08ec3ad168e40324b5235746de56069057cb7a	21488
2112	e3c02a71b57b183f3446aa38eae0e87c4b66a9c6f8ec87a8395bd06aeee8ec0e	21490
2113	fa50fc6167da4a727f7e8ca63f69370d8daa18d6d77252ad908539ace529aca3	21493
2114	aecf69959cca611ff8553b739e43b91a692998821030971ce0e2fdd8d41d6520	21507
2115	cb30c5f6f2a8eb72ae190fbc5ae7dc9c048b120e7b65252780e3956e6ba30f4a	21509
2116	ffa5d229aed081cf11e68a2d31408693c01e69150f731e9433f3ddbe829eb532	21522
2117	b5cfea6b18cbddf8db054319a97e8b00f7840cd23f08f9f6b786dd4614ef7ebc	21524
2118	d58f7928ed5c9bfceb9cf9207b9103c0eaf6519d5ae6a9f9561b68126f327b41	21525
2119	436e6f59d3be1a522d3a37be0a55b11e42d72f5f3ac12e6567e7bd1afb562ff9	21542
2120	e2f5829f5255eb404edffbe59caa1309794a360299e15886b60aaa7f1140fc01	21574
2121	3c102f31f8dd3e3c38ee91e2be3d63de226102e9e5048d59f57272f9dec13cb5	21579
2122	dc791ac299c9b3616657c9e0f309bf1f9b7dad3ba9ce4baef2a44077382102d9	21584
2123	70343dd896378d4f7f1c09c9f40f6a158c753fdc2faebe754440440cc440e2b2	21594
2124	706d51dfe7e8a042315b537f5eaa4f3e5ea21ee41513db1143899acf2ffa9e89	21612
2125	56504f485b8b5a4bf25c60e65168f8fcabda550405e36da27af011d67e12c2b4	21617
2126	37ab2c3b2bc4fcd373e55ffbb9de3dee477f12634a8b3c20719a436f159fba0a	21627
2127	030f4c5858e72adda043ff50df9729bde00e0eb32eba9c4823f199e29d88ab47	21661
2128	88733d416aa334b4e97866f697f74bd5cb3213212d47db293278d6c09ac83494	21664
2129	2d1d0d91b15e42db472d937e10e21496b07696fd603cb3b8f5d4734909a4b270	21668
2130	1ca854d7012991f7735a3cb2c5769acc3c4369374b632b55def35ec49d48e104	21675
2131	48709fa3f71d4b02cfcb39e66fbbbbcd395005364711da81f1391bed5d2877c0	21678
2132	1663cf037a5473660fa68c29d05910f7c6058e561ad7a24ccd0a364e774bbad6	21680
2133	89c25d79efe677fb2da39ff5ce65426186606eee03fd1e47336b96f4d64243ad	21688
2134	0f3a90098a8080b5ff0e44bd187688660566aa3539c6b45127d6620aecd8494f	21694
2135	656af2bd31a71dc09bf35cf73f656be52eec41fcb2608e2709efe58baa90a7f9	21697
2136	fade3b578fec7a01e31c35a5340001641ff4e52ef4c2b92741b0833c652e1049	21706
2137	e480563084aaaa41215d8a81131c57476eb19b33d68c288d8504e2002be46909	21710
2138	ecf59a3844c16d1298c3f4adebdd52e3991a55daf7601a2c8329e075bc0898d3	21713
2139	cc9c28bd2bae7f522737070bb1b958cf27e5000a2ab0eccb1ef1d5c068bfc394	21727
2140	c314cc39c90e74d12ccbe327d377e322d7e6cb1e21c14bbae2a54b9eacbfeebf	21732
2141	8e1e854b9050651bbda91384b778fb2fd8428cb5a02e011d1e5c709e69a5d3bd	21734
2142	b542a29b7060322ad0aaf6e72da22408165df49741fee989f8d1811ecd2ea7f7	21771
2143	6fcb3f2c647d3c3c7e47c414c098fd015edd5c9bf8129c9f4812cbed915b52eb	21773
2144	19d9e9da6304b00669429b333380083691347e16bf48b62a610e2c2f41646629	21778
2145	bcfbf9761811d9a6e55eaff396e12a844afc17871dc3a7960a5e2a88c3057c50	21780
2146	7dc275a3e12e22d9e492704d22a88f45a29cedb92533454f6601e7d89e6b221f	21786
2147	48bf3d2ff3bd259efa013ff751c869a9b8f2bf18fc3f8e52a14a6ce78221a20f	21787
2148	beae213cc5dc4ca6db40c2ec32048effcfc44d1b8fc760c847e1f18e7d1a3cec	21790
2149	4011b8ef25830f8393faf85f766226c452fdd4aa64332c31aec3a734a894ddfc	21806
2150	7a6ddc66c98fbb5bbf29d161d0d94dda9e1f37bf7f1ca447e77718b3309043ba	21830
2151	a00cba135df235536069d4b2c5f7d2eeca807eca0852d4c993603c4a39443f9d	21872
2152	5b2013ac9e8300ac592a70b84b38c8551cb4216253052a181200dbc4f29ab41b	21896
2153	c11344a5d52213970db75c0c85c20078c89dec3f62188b8905c54553891c3d73	21898
2154	bcff739e65eeae3cb168cfa343051448bbc14062ab4775dfaa8ac6187514c936	21901
2155	1e7f4006cca8495f61622d769df511717611616160d220245dcf41e7af01f62d	21926
2156	8c8a31675cb83d30ed95df5041686443bad672d3a6ef7c9543ed3ddbc04f66ce	21950
2157	875d97ab5ac0205fa898ac9f98a8e7782b3441b6256d66209b524abd6a5ecfff	21951
2158	3cc99f28e8dd3a89ed5a394ae3481b7c78344ce9fd822ab21d6e5efa15e3d535	21960
2159	a5ba8df0110d689d1934e5270c70b9a96c26c8a483f0a200a6a6ef59dc53ec34	21967
2160	62f15adbc02ea2ed480f0cf8ea3490e0adfc36548430a1c8f5a3dfd23c646c03	21980
2161	21439c9ddf4f362e0406557609a1c1d016872c9bf2e35b7037e80e06d3be8515	21992
2162	4f36f1cb68d48d301f508c21004aab6f289a231f6fb8a58ec91f6afedfc74722	22000
2163	37b1e6762e61617411f8a6e7e37db7b943bb677913666cedc67ff238c313b9d9	22006
2164	470828692d5851fd7d42c82fcd90efaebcc28e6b8fb1b22a4fb4c3130427456d	22008
2165	cd0fd7565f9d948c8ab8b0dfd654a2c90efb291fb4f6282bbb5127c645f2b39b	22011
2166	1c956fe245f2e6789138f2a9652f48c270ecdb0d19525a000b644764472e7355	22056
2167	9329a1061b94defb29bd0b4254974e3136cb76502fae5ef60ec9c3e16388f532	22066
2168	f18c2b362429be5a6fa12bd472e7fe165f2549d6bded3bc881bf93c589762ac3	22088
2169	6a4782adc38740d5dfbbaaeece9f37922458d92fc7efd4e9caefbaab6a98ab12	22095
2170	cf65a16dcb9c929f0064413e1db4a4c63dfda1eda1a61a0e862f99d98e1b381d	22099
2171	7d5059a8e1769b58de0fae6efbc3db50cb4f8cf3ece591e27a72e831ec6f1d8d	22107
2172	c9ed561d65b1722b296c5ae7f70926f940302d0aa2fd069ca0c4d874f93fbe59	22113
2173	97d8d0dc1f9c78408adc8f753d94a1e3206d5ae5bb2cc3c23bd960d225a0c70c	22118
2174	419c43c3010c4cd1bfb1603064fac752da47b62e16a80740f931ef2412f5b441	22138
2175	0002260f7cd73a490967c143b5c659a19d123d3058d7755fdcdb14cdac2c5413	22139
2176	4ac2e14d9716fecbd073092961d979d09a324f0ef23cef1a7472b9a66d79d5bb	22140
2177	ee4448497226060ee463dea27ccb15db3d2dcbecc82901b2ab86008645861fc0	22152
2178	30c4635118f53456b42a0ccc46970fc2ef7b55d4014688786c97ed2fbb006e04	22157
2179	ad76bd874070cc72d872e0988b5a884f650401ebc2d311fd21b8e2ec8a9b9d7a	22158
2180	cfe51d313290b60be7d6893f9b5e1e4dcbb8ee26851b7a9a3776fe7989a78d41	22165
2181	e16acfa720702b00c6ee1409a5a20bab7861d558cb40661bb07ceef940d68028	22175
2182	3389a5b9a66218a4dac4e86356c51e16fba71347aa582bab6046d9c23442546b	22192
2183	c05c214187d8e0fe7817196ae21dcb88b3efbb57a4fe926012a6c82a7699e3a1	22195
2184	1d79472f786bf235ad119d2ba946bfbc0179f982e2f796b71bf90266ef4b3b17	22196
2185	646722ffe6cd584d85c02e028633a2ea9b2cfed74e8114c2d554ea9834482771	22219
2186	88f66ad1353d45ab2c598f2d9385e1d2384489c6ea7dbcddbb140afb3de8894e	22223
2187	921134c5283b19a4325717464cc8c4b2733e0fdd3ac5bbcee0c5d8eb59f4e476	22229
2188	b3c897d44fb12a6e7625ad52724099c1507b59822b1e1b4a0dabea5d3a908a30	22234
2189	9bc3f4318c3a676615c5944025688ce4d9f844d103ae39cf606d55e7bd76d3aa	22239
2190	b2174f3aa3e3af01b37b9ce0a4151142ace7f86279051b7898edae2f6498376e	22256
2191	5b815e32ad1b7fc4542984a3bff0888433d3b3bfd01b57ee2c436363445323c5	22266
2192	1d24457bdcda1dd36bdd9364a38aa9159948f14e5fc684b5cb668acc4d48cf73	22277
2193	af23e767a7cc781658becdff891da1b9288efc8548e1c7c6453d34cc95980b58	22278
2194	a0631a7dfe644b2cc733b4bd47c780a0f752764ea31b9dccf738b12282e8a2d3	22282
2195	febd73d5504f17d7ed84783900adaa40ad0632ea85f61af2ae29a3855a1bb082	22300
2196	0d8f9185b45d6075042893aec1be3e2110ec375b03a23c5172f0c1294f08a747	22303
2197	8af5a1b3a0c38a40c633abbc7f6d1da7594073d7b52c3b31d355ce3e99fe4352	22337
2198	2275fb0d0d65e9f4b50c29bcc4b83f7c9854bc3198cae1455e3c895d2597a73b	22348
2199	065b649d8960de36a14e4bac4b94abc036f3661db1365c6a5bfbef24753046ff	22349
2200	1dbfb24db494ee372a174ab9592c79cd1a84fd7aaf62aa6432f3842c6c6933b7	22363
2201	0c1594316489ee5cf9adc7b23ab996074966be8a6534a623a445e98563ad38e0	22368
2202	753ab3313a81d6f2f14cb12378c61f2175071afb2aa6b568e6ca085b9d10f79b	22372
2203	b4fa6c3f36cb64ee9b6af4c22dda21e9135e5627dab7aaa617a25d31a724b06a	22382
2204	e8d20852efce5a60f78abbaa006c91f2adebf08367ceafaf2a60869788177bdc	22386
2205	2ef6663e646f9274b9b144e2541f4c55c7194950455156d12e61b750b479f8a2	22388
2206	4f8e3a12b3a27c94609c6430280a4432a94f068832bb93cb0a4c27582132ce87	22392
2207	ff3768c8eef7e858715fa9c1c472fabf8bcb9c2f1892cd8cd49773d39c19bc07	22411
2208	ae56cdafd107d2c403fda5f953e1d35f193a88dcccf1744c7fdfa31239c479f8	22417
2209	aadab3a84cb0305ea1dc1358bc0f014d4d140f54d42cf48c32f4e64170c93764	22424
2210	0b947c3e562ba7a0a931b147c8089338f1e1b8e7991eb20041b39f122285194d	22438
2211	191d759b783717a8bd330ea60afa7e4706bf27f5ec6c17e34cdf338bae8c8ac9	22463
2212	237ec38a2e84cd9a4aebb0ac18ff30ae76eec49c3ac81bfa4ce57d7905436ba5	22467
2213	593f570444ffed588de88a0f62b0f4164b65bb0b3296339c4acf93492228f426	22471
2214	1ac80040c26bff3f194b68544775de0e66942fd85dd1992f591c5ba26396fdcf	22484
2215	98142af2f4dbc8568d30c61443b24a20050c52f27667bf78018e9fd1e3281be8	22490
2216	8bfb0b2601c39a467481e70e8953f8944d734d9b209ca085a2f3a680418249d9	22493
2217	fa193b624f7ea94b678313d1afbed3e16d91f924ebb3a97001c182afb3c4d8c4	22494
2218	c46abac40a0ed03a3835192428ecc50c389ce7461b9be8cd89213d0f84c7180b	22506
2219	537857f631e54198ea3d04ce465e73c1c2eafe3bed4fded43016a47feb72a7dc	22510
2220	2f71daade87a833f6596d903520ae338ca616b416ed504984aaed73957967fcb	22522
2221	4107cb9eb6d0a03e8db789f5612ccb99bb67c837a92a62ff1c43cbb349377cc1	22529
2222	dfcb7c76cb5c58b3a68d2a5db53c2d8f422a842716f00e781f00464e2faec85a	22552
2223	0af250b224953164aad67bf771dcf5fd051e97b9f52594a43058c0830e86df2f	22553
2224	3e57ef69da10fae48b5ec366a3fd8b8beb98241ab946659e357f2f905a9023d8	22570
2225	eb344ee0a03fb275c9371ee71924c6393703b279e9f84946d80446e17c722657	22571
2226	95c6275d3a756936abecb0892473e77bd2f6b9cc5f8bd626d94917acd9f659d4	22578
2227	edbe7a2018547ddd31a9fc3430394d46d16f0d09950871d259db570b0cf645f3	22584
2228	710b5b1a832d698d0111de8dc801e8300bdbcf1f1e130da0fe803b13327426d4	22585
2229	8a2a3243c31fc76394434479749a86d181c0c9ed8441ecab3707b87c95545514	22587
2230	17a7947a36501ad49b0d29d3f3101adecedfa332df18df1c0579b65d8bc04726	22590
2231	fb565b43f58080a972f49fc5dc5f1652413e54a8e53adabe4479358a15d361c8	22592
2232	15f4b58994c849506f8e8b7cd026825715a9099b1e6fbfa69951096479dddca1	22601
2233	ff364b42f96883a96d2f3687b2175795a672277e83d892176cd0552db31457af	22602
2234	d38491cdfe0c023ffcdfa7f7f6f27ff3bc8ebdab47d08591131c623e49bfb006	22624
2235	43ae327386988ee30d1e9ed2879e655197d75a278ac797a0e0907720293be982	22629
2236	339174683dac735adaa463d3210c3f0ab5a05870f054c200fa944517b4b64c49	22631
2237	77e6f8d164fcdabe21e0190815fd43c62740a00e74567a329e124127f5638bf6	22633
2238	31d5fef1e2bae033fe2b882773cdb8f98e44642f3001a0be2a17a4f30b8fa471	22656
2239	c132a49fb6151772791e275e23c4048bad0940d8f81aa30a71dc9b19485e1594	22661
2240	8f0b3325b600193f1811cdc3384c37b736d7c7a1d779cd486a99869385105aea	22667
2241	e843bef5a72ea92d87b8f9100e64f3abd7ce29b765b8832d613f42a8c33b8344	22675
2242	e757a242a03879c96efd5d2a0fc69dfb25082728bc9a67cde40d15142eccb886	22679
2243	e47ea8f379bdc982febaec136292c1e49cd313175cf3091f985e5240b56ccf89	22684
2244	ce0b4fe9bf7f69033ee1a7278346faff2d652463ac333f9923842ceac182ed48	22685
2245	e0ff3dd186cace771d0f803f13cb394f08ef085fce975f83ff85d3ec71719f0a	22691
2246	2cfccea84298a5a18a46cf82cb233915340d9a58e1552dcb71ca9db74fdd7691	22693
2247	c8c857be04c4693656c509b0b35977625617a23e5927f4fc1482e6e4923c3c92	22717
2248	020e01b60047f3ec2dc6dae21c167e05ab521d165837eb1debacb69fc2b93f81	22719
2249	939eac080230be88dab5f0d6381d7c9f4fb926749ac82f438f625a200c4728e7	22724
2250	b47cd498087c90c2eae7fda5ae13385d3b53642e7ee7fa5a088ae48a5760ab6c	22725
2251	6e1b245e944d436d7373d8e11baa7e65ac2074ae8398c970aec17d75da27052e	22727
2252	2e9e6d32aced77e89b7fbd49089335b67ba6723472f1e4b7590d99120a296570	22731
2253	538f60d3f1ba8455209f4ad27bce9500727262f0e270586904c78777ef3c9033	22749
2254	c97ff6bdacac8cbe8b9bedc669feb9915b34d60973ce4beeb38868363cfbb74d	22753
2255	17fe61fa0d725d52ef9e2b8bd7e11f9478672ebf4de99be13f9c268d370221e8	22756
2256	53aa9a4e535ae2d99c0266dadcf52401e758c4b9da54d8f2f15360504ed5c799	22757
2257	36577c64787b101e67aec69ebc4c7c43f61efb2ac6ffaf3a69bdb5c6ac8a5f94	22775
2258	9c8ef1c40aa4b794bd88a67a9557e38258812b90f589c6c6d22acc20de977454	22792
2259	055722f7bcc36f5080c5e0b43adadcadb3b284dddaca03e11037bf35f853ffea	22797
2260	e2630362218d13259b263b5641b61ac5906490f16c32b1511308c0adc495129e	22810
2261	89b3579d54ce6de47816a4626bf9bad550dca751709d62baf974cf079ec7a66b	22813
2262	98a0498461965ccda1c135edd2e08cc63f8214688c18996330efc1aa68b82bab	22822
2263	17cb5f188a03fbde8884198369490e4ea50a5bd71f484740897c7c071b159ffc	22823
2264	c8795a3dae9e82c5fe4b785c0a2530f8655eae9d64174521a33f048a6978da85	22841
2265	307f32f3ec41c5ef9ceb7dc4952cd3e216b9bb19b40091d850747d4a730abc3c	22843
2266	cbdb2f6229b0e52de984a58d2f5356c0938fc3a483b45f7061cb98d5fe96e84a	22854
2267	dd5f5ea1478c4be5423af75c44d0e3ab62ef2d7d8429ff519d232033be102eae	22861
2268	a0d51f46f07a49c8e9912029a5e310ad9890a22954e3865627b3983a02b3e4ec	22876
2269	608c932cb33f3c6b032e30a9f3e2cf0e0de6da82455c39ecb51eefc1d4714b66	22889
2270	2f1a64c544f061d470135e763becbc21ee625b5a63fc1f1024ecc45d6d418f98	22903
2271	a9de8c842354f5e62de7144a810c6e780d672d832c68f6566e0660e2bc6e77cf	22923
2272	d0a59926e530bcf8a5ab8134bdc15e279624e744a9d57485458112b5219fac6e	22932
2273	3b2de840bd193b3c19d72243fcbbff26b9225558c2ad8144fa8833742aa2b6ef	22952
2274	c1033c375625a0009c13a3390e121e692e160237b054ecf74ba090ff722c2a8f	22967
2275	dca489eb35923b67275457f0be2b6cbc01085a608f863df8e17b6bbd56b11b07	22968
2276	6b21d025035aed614aa701e446df8ab440c3bd72ee73744d53f110c808f302f7	22970
2277	eddf7660ace3bf7c8030255b2f07b524af54ee172df8020ef1004bc9f255b305	22977
2278	27cc69a348cd831eee7981efb5b3f076677e69bd842e97fb232b0588f9e256fc	22984
2279	52c42ea7647fa06b34316a737bdbac29b85becc1c8901d36ee81182fbf64ba52	23003
2280	daf7e7cf718515bde19377c2f6cddee46a14f89833aaf94ec963ecceb8b16bc3	23021
2281	f9d2917bc2d76a76340f50003e14d404fa22f913c0a10a739a51a261268fae41	23028
2282	34c830a06c1b6797673b7760346641da08d34059e2bc8610b98123315a9bbeee	23031
2283	e5bf25d7cff3165d0a608cad6a933ca2792a2d0b17af32b2961cd7b3e1182c89	23032
2284	2c4ccbb1eac7505c99a58070585db66263657c7ae0ba29fb0833231294a0b07f	23037
2285	9e429cb5183cd7d9ebd8580b5aba1457ceb3c1b049075960b84b2695ec378644	23041
2286	a1f0b3ebebb51151b2b8f3f83e44946a15803b505e089d5bc69a4e1560d1312f	23044
2287	999ad4ed95b06b0ec9f3fd247c7d0aad9f076146d2065ed8164a91c187d21366	23046
2288	29f5b389bfe1cabbe7775f087f9d73ca3e4b6d56bba94a92514c923b3dad441a	23056
2289	e87ff21ed6e7ba448db2c9cf9d7d87183efca7ae371eff4ca24e30ca69bc238f	23057
2290	1610d22d4953145a82b3aa82f9c9abdf259c3656eaa9306a5a53f3d41978e67d	23066
2291	10aac3a26b1bd34d9afa2aed3bdc3bd9952caf44a9667b89d350709d805c2a5f	23076
2292	38743ebe38f49386c9f4d11b9f2f65a3100efc7047b81ce15cb325359dae1121	23092
2293	99940ce283f4048b315c2a5e1f2b4654f355285300907394b5e46802d214f17d	23094
2294	04dcc7961d88ad49b16dda23b8f1ef40f803636726cc539ac67170665c66a933	23100
2295	f364f018601347b1129c6fbd47033366e7348558d2d1fbb92089084b87af6580	23101
2296	b644c6fb8cc7459a40b12023347d50b9366d92afae49125230381aa5ba763cdf	23114
2297	9516fedfed9edf611f64878d23af1e6c33d00ad9c63e8a21843446294c535142	23118
2298	d8ad3e6623353eb87e21131cc7650cdc385d386433065a577c7849a5faf1e4b7	23119
2299	4af52f261b3d90f5e9566dd9c7ec64cdff95373eeb4e7073bdd041fe7355cf95	23121
2300	eb4a31ce4b7498bede80134ace843be16467e7bd1af7e9dbb37103909eff80cf	23127
2301	93d464a640ea8d507e6b161adbb16ecf1a7c4fa13112d497462b75831e339ace	23137
2302	b2f7e4453857e41ce79e6380f8c002d9a370ca3895996712a2bc8053b20a1f1b	23162
2303	5d821c46c39d45901ef48f0f2ef0f76119cb48ee3ee43f12da7f1e06831c6de3	23164
2304	fe3aaa18f382684129b0845a5ee32f342468f33a639390f782749ecd77891319	23166
2305	21c466fe14c5e0bdae646bd41f329c1024778f0da7ec73d08b766ca4dcd8f3a1	23168
2306	8f70fef3e59f741ecaa90321828eacc1f77e0e4f74cc3101c4de1f82fc286841	23171
2307	e19c6f5f8af5002e9791d32a858c6974cd678a54f19e0620b748fa6ac53ee8fc	23172
2308	5537126fd702ea233b7db133343bf64d2ddc23e6254584593686e0f363d3bad4	23190
2309	763352ae57f9426695aabc0827543e3ad4887480540ccffb8fc842c45975cded	23192
2310	55aa2d115ae0cda02a6b03e39790556dbad2f4b6a0b256b3b7d6162e800fee17	23193
2311	a78ae556e0fe7dbb3e48177d406bd7f4109397fae73a55ceb3e49b2872fd14d2	23204
2312	e9fb5b2d908ada6c425ae3c0283fd2de6bf572ffb104568784196c33e1013789	23212
2313	d2785e3e6f989858aa038deb954761d7afd290e37ddea35a1badcc65701fee51	23215
2314	8a70ce2b5ce03a597a03d4095c3ed3a8be976014a46a96db2c10cac3b0d9a743	23227
2315	7dee63d295a53b39713d64098912fc5cfe8d6587134f1682383799a743d6a29c	23232
2316	25bc3aefdfd15e9cca28ffc687a1b6f78a81cf1e90586b4fc42094a7f8e938b8	23235
2317	3be2ed1646bca860ec6eeb43b143e2667eee1ea71d37e8bf8c1ab91a78cd40e8	23242
2318	578e56d87bbc465e44e1a6a228f6c4e60fb876fbea681aabf232949a27f1893e	23249
2319	bb031ef55eb4b3d91ecce7232603cf963f9eb965920dfaa2bea0c43ea189b1d6	23258
2320	c0c91d955b0e1bff74778d6fceb74547e89a1b408bef68a34d08176043ddb80d	23271
2321	6f66e1e2cae5658d2937504641e9bd9eace6cb625714bd24d66e8bd60d3128f9	23277
2322	436d57518b7e01d38a6137fb175748e1cf8d7d0d23d26232082927395891ba76	23283
2323	d76808d0e5034888d8fc91df0c617d4695b6bdd9568d84606f247cc0651e8525	23289
2324	bfa2077754b81b84b6d520626ac0cb9eb92fe0fe2e13c475259d5d4f3222a558	23291
2325	4df833e8d340c9edae30f7f69cd350de578e47184f680611685e4b9e94068a5e	23300
2326	b76e8436c87a350e9cac582453a8eef9d20a913e0d0805fc9b5d7755e55ecc17	23302
2327	e14738cf8f1f55bf8201eb77f4643398d08a615b4b51bccf6275a0a1146eb9f9	23303
2328	2492636850ae6085c3f2cba9b207e421059a0b21163800e9282d86cf4294e722	23305
2329	395e515a59b714120d748f2b782ef0e59422d961ab26e93f2b8f09b085a4c4fb	23316
2330	794948fc0eca797f31f0d8255ffcf5e019c8b55fb661ff404811ae3779c0d35a	23317
2331	58cf42be91b1821bc75b0978633147abf10e7be20405b936c698674eb3cf4c45	23325
2332	cb62b4b69e003ff69c09e4ab74d72ee701ff9f9cf159f9aa547c0c69e8058c47	23329
2333	cd875f91b63cbec82c702b969eaf0fb2cb3e0a5037bdd28081ac9de4521b75a4	23333
2334	e40ca9e003a217f7341582f60535ea23fcf626f950b071b360b90da17aff5311	23336
2335	e47a8fd476973392a09e46a6d73d8ee531659c502919c740c9746ad47986148f	23345
2336	3a986b066f90e5a954c9a90bdbcaca2dd9c158df908d350cea0785953156795d	23353
2337	e69f11faf8d07f2ba6eacde64c7625a4c833493b60fbffef846dd94dd27be671	23356
2338	31f9ab9fdcf0b2fff28b3f1d31d95d608e1ab4d013d58e28d9563b0233f14fcf	23365
2339	4cc19bdf4ab7b81e3374b32dde4f8db87ece31a45a72637d7a2a67d3ebcbad9d	23384
2340	d4871eef3a6482e3b631a8e0028d327e03b5bf95e880ecfa6b8ddeb20f08e580	23388
2341	05d47570a7638d3ea0e4db3fb4c991ffb2f20b36fded40dcf5f2d2dd04bdd8f9	23392
2342	7c9bbc57ba67e5742af6bd40b3d9213f1678855f7572ae41d54703787ce96a6b	23405
2343	480e65c33acc684d9a43dce66c804f2f725481b9b873d4ba2cb712086955b6ab	23426
2344	1c3bb1c639f1c7f06775909b8e187ef66ca85456923691dae8cf91dd55ff08e9	23434
2345	7d4816e4ab463387d9885a7444a74b19913dc515584134c1aa51ec0751c0061b	23440
2346	694b632e88b573fa6572de432a5bba29ed56bd1ef23e3c51850469a64c8b782c	23446
2347	a9d7e7a52e96212db14e273a67b7a3244418c23d06904e13633dfbfe842c55d7	23451
2348	6984b65bbbf97f9fee9ce3e2df2b9f087637b3dad1c2f34b635a30d7dd391342	23454
2349	7ab0c0e13176c433cbf89d2826b6018ea8d499c95bad02e721fbc99ce5bc4fa0	23461
2350	a0ed26e340c05286fd5cf7ed77060767d7b53f82d6e2d79e9f97494476acda3b	23464
2351	d9c79d0b35d5867c0e4600cf5ed8ab08c1ef98b4037bb80c56ce41383aa1c9a2	23483
2352	fb926c07481d84a2d3ad700387a04c70a1d3750f07ba8cf1439ec1d9cbc7c528	23491
2353	63fb0cffb414c12fcb1ed9a53bed3e3df547f4ab4872fe2662a3182b80f831ce	23498
2354	a90863dad823eed2a5942180f6f17015939815ce28c6fcc5b1fec6f27a4198b3	23499
2355	f78a3627520ee43b21a719c4190ec0fc33dfd50799f3b3323910fcac87ef33d6	23502
2356	165533b96a309d065cb7ef32da0f9371a7670152ec97ede395c1274d5deb680f	23505
2357	3c9f6ec3a2c74b18203836fb018e99b4be6801173c662685a083dd9599f0e779	23506
2358	566df81243ebd72c19b6941ebec709efe80afd853be081c4f4831c7a0faf1d17	23512
2359	a8e3130fb24016cbc4949395435848c53738b35266e3c807fa8ec36d944b0d80	23526
2360	ca03c52672b249532fa2f89a5f9ac217cf2924ef750937d8c3559f1ba854886c	23547
2361	4e2c19f6705fbd3d56105aa61d688a4371f824713d358cb4d49c13458bade604	23561
2362	65e1d857991c8fdaa6765b5ac21ae5bafb6984a499449080ebd3fae701266c6b	23564
2363	9270e94c8bda1a380471812ae31dd4883eac383ef2986ae6788dfd7a71be68b2	23567
2364	cb3b3d6e02918be15a27c6dc180a17e100d2adbdcc3d91daf6b40eb2ed00a403	23600
2365	ab488b8b1dce7745a8676209842ddff64dfaecac4fb82233fae9dda5c557facb	23604
2366	df88464accf1a7ecfaba3520d70790dd501672fe3d4aede88148b5d7d8d50f5a	23608
2367	8d91ae2b54cb264415ed214deb846e2bddef746bf210629bc8883e38bc2ab58b	23614
2368	f5f620fba68213d1295a4018f5abbc02e3563c314941617c6e3868ffa8dab2c6	23619
2369	29def8afe6cef1b84037f42e690b00f4d52a8354cb239dedb0192c52d767ee09	23633
2370	b1914039ad2a657b13775b5d3527f69a810a28fc6dbf63def6a670deb8363159	23635
2371	07add384bb11ac0a20bb3e372ccc9122cf6268f5b243354d7a05fa612d379bb9	23649
2372	16e2b0a06c68d7e175351eacbdfcc1ec005dc53bd3314226c013e186dbd1e5d3	23662
2373	b9f18eaae5f42b2568ce4ba8cd80be46691cabaa5bc18f1ff1e1f3650e878e47	23666
2374	1462d64e31d3e9a2f8fb4af328e20a8272b73b64d93af53f2a8c22845cf813ae	23675
2375	81aca46b2beeb8bac1315fc839d83c05435fb963ec2f850f0e7dc66f34841d6a	23682
2376	6bb1aedde66fe44bc2b7d2f7a3b2c45cf4f398f972efb0e11e26355801b2dbbd	23690
2377	47ddc8059b91977c064c3075bbe8463b56bf564937d5a305d86ffdfa63c67ed8	23694
2378	4504ad196d0ed38e5378a29b778af592b19e34583458d3d20eacf101f44efcb6	23715
2379	fa44486ef8aba9ce654a769b02c32acfd770a2329a4dceafe420a7dd34b9e28c	23743
2380	69a26f244aff67bf85cd598cb8c0cd972fa276acc099cd6fa9a91a498520666e	23752
2381	e45a4852df0a1a65aab7652783dac9d4da5c6c6d5069718888f59be4b08a4117	23757
2382	fa0654786dbeb65f20161749afb0bcd08e018caac7117653fdd90c9d3a22eac9	23762
2383	137f3e7e91ada8c6093434b597c3c9ee5ef22bb68bc40e9778b0ac5319009b82	23769
2384	bbdd7ada510df1da13b10c41986f0d3d3504d7390688ad9c612bbcc1beaa18e3	23778
2385	f73ac83cef9b6fda23d4f77f28df91854a388be05c79f06383c98e3c866d181a	23781
2386	29c5b0e3949a73f71030ae53871c2752508b012ec79cb305bc5fffed2ea7a8a1	23790
2387	92ebf871803f307a0981d4a4ac9094550b0858a51fa59d8cbc7dda5a9f2624e1	23808
2388	41f3bbfa0897d2f37e5c95dce9dc4121d42f95e22069431705960b599e0f749b	23817
2389	45be6f98cc496d6095c7d239af9c25c3b9cf87e0faa7dc53427026b3681499bd	23823
2390	1fe2445a44a8572b1bc4ad44e26dc2617b66ab2cebe034fb2f94f6c7832edb4f	23825
2391	d95fee3834b6663206fd5922ad83c0a82ee0caea324c117ca582d2565d697e25	23827
2392	7b9a5d7cee1926ad4675d6ead57747e8f4872c950f07dafb869779ac5e5cd7e5	23840
2393	e64185e1c4250fc022b2478014f6306e8d1aa36fb01ea3c1bedb0a2d11f68d54	23850
2394	46dd2f8178e50c4dfdcac529c8105576006e8a578d638abceaecbed8f439aa6e	23853
2395	13fd8d07c1e99f229723220ee3fbe5588bd12377881eac877eefa342a91ee4f3	23866
2396	ec093bd4a682b07085a4b4096ed4f032a59dc4e7066361d701ed50c59edaf4f4	23876
2397	b3b0c4b6fcb2816b556dbc0e18e32762258017af6532b409bedc43b316c627eb	23879
2398	b2273755d5b7d07dda9126a24a376e73bbff0e38019a1c8b897316f057688ae4	23882
2399	0e0bb7f9e32db983ab3b51fa919540940d73dbee3fc910904bebe8c62da33ec9	23884
2400	ea24714f3788c4cd532fa255884edb6b6c1457352ba974a63ca4e89f152c0e4b	23892
2401	b2d76512b46e913f8ef7f04ec234beccc64bf17d7eda50d15492b586d7d8c1f3	23903
2402	a4d257ce3d55b34523150311311d4e481a9989b315ef13276dcdb6158c56994f	23929
2403	2909ca200c205a9d5b140fb5201915c18c870266563335a11178f0bb54faed57	23938
2404	42717053338cca21e750b48e856c9493a27540c8fec0ded1fe71977caea58275	23941
2405	978f1591451076c9577301a7576c4d6250f9784706f05cc1a5160698a2c9f391	23942
2406	3281f5382763da29f13dd14660627e19248f8a08915442eeb380fcb6ae97c757	23949
2407	96a9e9ec15e88f92866ce9ab969ec3479035b5e8fc21a2e512518dc0244b80ec	23950
2408	bca04b0478394f5ebdb983ef2e5c1108f089048c933b1a99efc7c078d1ef470c	23954
2409	2ef80f359fb8b32d700091f92479f369adc6e910a4d19a3369c974b3d5ea2a2c	23960
2410	8fd9bf1acc53e66ecbc401af641f24d0a5b657478afee6be7f670937ae1652fa	23966
2411	fdbd957610d5a1383abfa6ee06bfa874325dc75c4d4b0d34e2f645188194bc82	23971
2412	f2560d9c0d873b0d4e6ac10ea09e98eb0c1145602ced03252e659485b69c19ee	23978
2413	af7fc3a804ce727044bcf872f483baea4bd1decaa6455750c62d1119e5ea5d80	23983
2414	57fb7da4de7b9c7aee75fa4df274cd5634dadae5612569ed2f17311b780a8eb9	23998
2415	6a3527bd62a752fe3cfbe42fcdb6071927aa2b6146f5e358350afec300e98129	24000
2416	333344994704830644e77a1d712bcb392a898a7c265e69b958a7437efe4ecaa2	24018
2417	3dc17cfd885db6e20877128a6aac7a00545d6059d2d576bc834b121f3065ed72	24019
2418	7d2f67d624ad7f17e40128bef727be92f883be8bb26007a8289d9d395942cd00	24029
2419	3889bc151fca1bfd482cc0e2858934bc823f5fc40146db1b5947524a6fe02278	24030
2420	69be96a9856f256ce5d34e59fd7ed3df75d743ced3e956ffdf4cd662f0b026d1	24037
2421	498ce7748a55d364500a9510334571caaa91e38871c3579ee7c585d257b069c9	24056
2422	fb0868630e31d7ab5bbc9d54da5709e8dbcae52c40ae01744f9e1919b8f30082	24058
2423	78b1bf9b1076e277511621abfa4844751d58ac254c6f15524b90093ee81ca540	24077
2424	7acd5dcfd9915ddc7345133b83cbb3d82f24a442a4bff64ad744b67b44726641	24080
2425	7781313be5a91221cd3d1501bd52a3ef5e4595f6c185992d53c61fd520925b0b	24109
2426	b4d67e86937671b73f4191c1eaa0939b0027a468396de0b13dbe6bad0b56dde6	24111
2427	e6e45d35cecbf0914111aa83446fa90eca3ba628b8b594feb8153614459b8564	24112
2428	7f80d8fc1b7e4c9109a6204009d3461c0f0e6744b14d85d6c5a9686bc7ba8f4d	24122
2429	e72498fe9cb7ca9b058d615b1edb30d4b1ce151a0e95d28c77b159bd7e1fcfac	24153
2430	ea5b99b461767b97fbaef761b0506e89fae5b9d7182ad6343df8a971926c0a47	24169
2431	dbc7d3da106af884d1e8552da9b4739b0e9227d9f98b380a82a3f67fec85789d	24189
2432	8b6ba7d7af666ae0a6b9bd0015770e8cf98a811aefe44dd9aceefecb4cd31d3f	24198
2433	d5e232b233e7381f63d046fdde2ffb3d59b9158f01f02f179d10f400cd5c28f0	24201
2434	edd0b9dcea099b6aeadc707c4924c0e9919cce8a0743769592282cc402534b66	24206
2435	a07b200396f6ad5c12d282968e9f566b6fc05b8580fb08ec8a96534a333fa3e1	24207
2436	505c32d6c80856cf5ab757880a3130b653d14b89bb04759c18b331a8d8ec5d40	24214
2437	934e67d6dfc9f41e7e72cdc010954407ca25210df23521a31df1ae7fdecacf24	24218
2438	e6a00346c2b89ef35dc6c2f8c21f56e7d4a8fb9ad26363a5f8d62a8793119565	24244
2439	55d7d8ff49a6432536dd04d2edf7f3a5520e8fc29fb5ffdd96bd77d9d9571d7b	24249
2440	4268d99c4dba6161a279180105275e527de06267170a060a8e42431a02fafc59	24255
2441	6dceb4659c3ed849565c3bee72c096392ec349eb0271765ab19fcc0a38e544cf	24277
2442	90e999265960dfca273301ca8ada8b0eeade0a6ee6b98abe59fe668f7278db74	24285
2443	021c01e0cbfd278d279009b8ce39ce9d79031545c6b9904a54e8e6742f70e624	24305
2444	3746e29ee49a0849e4dffba84484b47dc63ec408e4b4ce6d585e02b4d38f94b7	24306
2445	4fc6e4f122aadc74c262743fb0a04355f4d3c8ec002fb8eec4a253530d128bce	24311
2446	750250cbc643deaea5a09988d4eac670e40cbca10e99e76a7bb7ae5366d10d7b	24313
2447	d44afb61b8d0a92f5b63dcab22b81af67fab89061762a1207dc63cbd2322d387	24315
2448	674c89fe368e29bfd2fb3cca83c1bc9e106bc68630fc57fb1eedc6b6bf275556	24319
2449	e4e1b2322691d73c1d5f17811a612ab033d63a592bfe68ba05d53a049e4b3505	24332
2450	27d0c8a918a45243df4b224acdeff5e5d3672be0fcd36c995cc5d07daf6da3c5	24341
2451	53608fb061440c9138bf7d876467da2dcf21712ac2b784051a4bf925b3418668	24345
2452	5a3edaa88de0caff1c1462e02c20b1ee206ea1ee3ae851c3c42839edf783e1c0	24358
2453	a46b9ffb80da23a1f17a9527b13db6ef29be2f42c7c8eff803f45139fc84b9e2	24371
2454	a75e0df3714d1a991c67b42af1006a5539b47fb2340fadf99faef19328f9fc81	24375
2455	9275477b5424930e84810607238d9783bb8067da683f0dfc0de683f9bbb2763c	24377
2456	948b599e8d417c8c2dce6a846a94ae975198b6ee3911bb2238942c9e2984d98d	24381
2457	7db1c23d997eed1c22e0fda9ae0296895ae917b83775893b1e3f1739d2e6feb9	24383
2458	fa65cb21c1a8a67ba8166fba7f6b5a4147f9e351bd4138fe752eb04089dba077	24387
2459	22e9e7dd16400d21543351b1595d673782134898fe86979b21427710bcdd4d7c	24390
2460	fe2e814288707a1d3a755ba879ab86742dba7c27487233f0356bfa447a51172e	24400
2461	39b792fe33032b78ffe8bb81302977b64988003a240c2420f491e54dc3ab41f8	24411
2462	3512f2418458bf81699dfe75b97bf01d8f11c5c8e7f62390997785372f2db472	24419
2463	a8be394506ee145cf9902cdaecf8312d3a2e5dd1933859bb4587b56bda4ef27a	24468
2464	bb8bca1f1b759d7a07e714063706e41788204b5f247457ad6bbbaa1ea4090e13	24475
2465	9b9564864fc3865bc20427491cdab9bef4db4dca4edea2b9a0b4a90f051a0fbd	24478
2466	6ea958a48f058cf63f012dc726fe71d32f8fc4a0a9754380552c729e5666b4ad	24480
2467	4021675aa37d95dfed45b920b92f34012e6d55f5ce63468220769a06e2bcb09b	24489
2468	16c2c4adc0e4b601071fa1e3e91bd1a1c4a2b2065ad0e7edca97e6618ed77246	24493
2469	10737248005d1787ee8d496039787e72c350b31135b9c6abdca4b72416d7086e	24494
2470	a57fa0526e639c2fb9b28f089520b398a57c3baa59efd71ed87a0f36efb34c84	24563
2471	91f0c45ef2fc9dc71eb8c4cc3b50c496b4f485ab12cdf9f96d2c777133e0d484	24572
2472	4069dd9430e4452ca6d2c6e780880d0c276067a7041dcbab204fb00f7c2f4f1c	24591
2473	d286cd9eb1372e1318372e43cb33470f91a94a91fbfbf2b050f4c6acbbea7717	24610
2474	851bce7f7bf80329d8a7bac815f9548828761fea8c203ea33955a9777d3b2af4	24613
2475	163a6bcd57c7f6890f887699b6bafe40d2f66edae23ee84fdf5d4a6302451548	24614
2476	e165dbe974010733a3ca4af60b8003e4ba6fad4d50039e9a82c084edc5522994	24615
2477	7e079f9024d0ff472b3882b72f7f44b56cd5a5e3c5be8c8f7eb43bfd5412c7e7	24640
2478	219cc961a82644edb8b1198397667784bfa8fbf83acdb3e6559868a385b0c4fd	24646
2479	425fdb7ab753d10997210cd475f6ff39995dd6596d738f5bde4e3ba8efb75b90	24648
2480	7f89300e94f642f37296f28d0137b9efe948edb1d416173ddf51a701fe23f52e	24673
2481	a91a56a819c428928e9d6dc293fbf77caf5e2d1dac80882feb890e80c1411af5	24680
2482	e055ceaee3bbf3553d4e1b43e265a10e00b22cfc0de4488216777e996d325e94	24682
2483	fe14e57166859159332273245ccbc11164dd2ea0c36e430810aed231afc99ec1	24695
2484	8d64082e3c0ff8b2b4bcb45b48317ad0fa6b0b3f916259b4f7d6ea7549b116a2	24698
2485	4c12abda028f09c41a3f5bc9da2051a4fb0e4a75d8a10c2dbe63a493d43ad27a	24749
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
2423	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432332c2268617368223a2237386231626639623130373665323737353131363231616266613438343437353164353861633235346336663135353234623930303933656538316361353430222c22736c6f74223a32343037377d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2266623038363836333065333164376162356262633964353464613537303965386462636165353263343061653031373434663965313931396238663330303832222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2424	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432342c2268617368223a2237616364356463666439393135646463373334353133336238336362623364383266323461343432613462666636346164373434623637623434373236363431222c22736c6f74223a32343038307d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2237386231626639623130373665323737353131363231616266613438343437353164353861633235346336663135353234623930303933656538316361353430222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2425	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432352c2268617368223a2237373831333133626535613931323231636433643135303162643532613365663565343539356636633138353939326435336336316664353230393235623062222c22736c6f74223a32343130397d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2237616364356463666439393135646463373334353133336238336362623364383266323461343432613462666636346164373434623637623434373236363431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2426	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432362c2268617368223a2262346436376538363933373637316237336634313931633165616130393339623030323761343638333936646530623133646265366261643062353664646536222c22736c6f74223a32343131317d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2237373831333133626535613931323231636433643135303162643532613365663565343539356636633138353939326435336336316664353230393235623062222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2427	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432372c2268617368223a2265366534356433356365636266303931343131316161383334343666613930656361336261363238623862353934666562383135333631343435396238353634222c22736c6f74223a32343131327d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2262346436376538363933373637316237336634313931633165616130393339623030323761343638333936646530623133646265366261643062353664646536222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2428	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432382c2268617368223a2237663830643866633162376534633931303961363230343030396433343631633066306536373434623134643835643663356139363836626337626138663464222c22736c6f74223a32343132327d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2265366534356433356365636266303931343131316161383334343666613930656361336261363238623862353934666562383135333631343435396238353634222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2429	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432392c2268617368223a2265373234393866653963623763613962303538643631356231656462333064346231636531353161306539356432386337376231353962643765316663666163222c22736c6f74223a32343135337d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2237663830643866633162376534633931303961363230343030396433343631633066306536373434623134643835643663356139363836626337626138663464222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2430	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433302c2268617368223a2265613562393962343631373637623937666261656637363162303530366538396661653562396437313832616436333433646638613937313932366330613437222c22736c6f74223a32343136397d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2265373234393866653963623763613962303538643631356231656462333064346231636531353161306539356432386337376231353962643765316663666163222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2431	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433312c2268617368223a2264626337643364613130366166383834643165383535326461396234373339623065393232376439663938623338306138326133663637666563383537383964222c22736c6f74223a32343138397d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2265613562393962343631373637623937666261656637363162303530366538396661653562396437313832616436333433646638613937313932366330613437222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2432	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433322c2268617368223a2238623662613764376166363636616530613662396264303031353737306538636639386138313161656665343464643961636565666563623463643331643366222c22736c6f74223a32343139387d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2264626337643364613130366166383834643165383535326461396234373339623065393232376439663938623338306138326133663637666563383537383964222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2433	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433332c2268617368223a2264356532333262323333653733383166363364303436666464653266666233643539623931353866303166303266313739643130663430306364356332386630222c22736c6f74223a32343230317d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2238623662613764376166363636616530613662396264303031353737306538636639386138313161656665343464643961636565666563623463643331643366222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2434	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433342c2268617368223a2265646430623964636561303939623661656164633730376334393234633065393931396363653861303734333736393539323238326363343032353334623636222c22736c6f74223a32343230367d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2264356532333262323333653733383166363364303436666464653266666233643539623931353866303166303266313739643130663430306364356332386630222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2435	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433352c2268617368223a2261303762323030333936663661643563313264323832393638653966353636623666633035623835383066623038656338613936353334613333336661336531222c22736c6f74223a32343230377d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2265646430623964636561303939623661656164633730376334393234633065393931396363653861303734333736393539323238326363343032353334623636222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2436	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433362c2268617368223a2235303563333264366338303835366366356162373537383830613331333062363533643134623839626230343735396331386233333161386438656335643430222c22736c6f74223a32343231347d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2261303762323030333936663661643563313264323832393638653966353636623666633035623835383066623038656338613936353334613333336661336531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2437	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433372c2268617368223a2239333465363764366466633966343165376537326364633031303935343430376361323532313064663233353231613331646631616537666465636163663234222c22736c6f74223a32343231387d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2235303563333264366338303835366366356162373537383830613331333062363533643134623839626230343735396331386233333161386438656335643430222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2438	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433382c2268617368223a2265366130303334366332623839656633356463366332663863323166353665376434613866623961643236333633613566386436326138373933313139353635222c22736c6f74223a32343234347d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2239333465363764366466633966343165376537326364633031303935343430376361323532313064663233353231613331646631616537666465636163663234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2439	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323433392c2268617368223a2235356437643866663439613634333235333664643034643265646637663361353532306538666332396662356666646439366264373764396439353731643762222c22736c6f74223a32343234397d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2265366130303334366332623839656633356463366332663863323166353665376434613866623961643236333633613566386436326138373933313139353635222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2440	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434302c2268617368223a2234323638643939633464626136313631613237393138303130353237356535323764653036323637313730613036306138653432343331613032666166633539222c22736c6f74223a32343235357d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2235356437643866663439613634333235333664643034643265646637663361353532306538666332396662356666646439366264373764396439353731643762222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2441	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434312c2268617368223a2236646365623436353963336564383439353635633362656537326330393633393265633334396562303237313736356162313966636330613338653534346366222c22736c6f74223a32343237377d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2234323638643939633464626136313631613237393138303130353237356535323764653036323637313730613036306138653432343331613032666166633539222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2442	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434322c2268617368223a2239306539393932363539363064666361323733333031636138616461386230656561646530613665653662393861626535396665363638663732373864623734222c22736c6f74223a32343238357d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2236646365623436353963336564383439353635633362656537326330393633393265633334396562303237313736356162313966636330613338653534346366222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2443	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434332c2268617368223a2230323163303165306362666432373864323739303039623863653339636539643739303331353435633662393930346135346538653637343266373065363234222c22736c6f74223a32343330357d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2239306539393932363539363064666361323733333031636138616461386230656561646530613665653662393861626535396665363638663732373864623734222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2444	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434342c2268617368223a2233373436653239656534396130383439653464666662613834343834623437646336336563343038653462346365366435383565303262346433386639346237222c22736c6f74223a32343330367d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2230323163303165306362666432373864323739303039623863653339636539643739303331353435633662393930346135346538653637343266373065363234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2445	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434352c2268617368223a2234666336653466313232616164633734633236323734336662306130343335356634643363386563303032666238656563346132353335333064313238626365222c22736c6f74223a32343331317d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2233373436653239656534396130383439653464666662613834343834623437646336336563343038653462346365366435383565303262346433386639346237222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2446	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434362c2268617368223a2237353032353063626336343364656165613561303939383864346561633637306534306362636131306539396537366137626237616535333636643130643762222c22736c6f74223a32343331337d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2234666336653466313232616164633734633236323734336662306130343335356634643363386563303032666238656563346132353335333064313238626365222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2447	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434372c2268617368223a2264343461666236316238643061393266356236336463616232326238316166363766616238393036313736326131323037646336336362643233323264333837222c22736c6f74223a32343331357d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2237353032353063626336343364656165613561303939383864346561633637306534306362636131306539396537366137626237616535333636643130643762222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2448	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434382c2268617368223a2236373463383966653336386532396266643266623363636138336331626339653130366263363836333066633537666231656564633662366266323735353536222c22736c6f74223a32343331397d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2264343461666236316238643061393266356236336463616232326238316166363766616238393036313736326131323037646336336362643233323264333837222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2449	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323434392c2268617368223a2265346531623233323236393164373363316435663137383131613631326162303333643633613539326266653638626130356435336130343965346233353035222c22736c6f74223a32343333327d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2236373463383966653336386532396266643266623363636138336331626339653130366263363836333066633537666231656564633662366266323735353536222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2450	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435302c2268617368223a2232376430633861393138613435323433646634623232346163646566663565356433363732626530666364333663393935636335643037646166366461336335222c22736c6f74223a32343334317d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2265346531623233323236393164373363316435663137383131613631326162303333643633613539326266653638626130356435336130343965346233353035222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2451	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435312c2268617368223a2235333630386662303631343430633931333862663764383736343637646132646366323137313261633262373834303531613462663932356233343138363638222c22736c6f74223a32343334357d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2232376430633861393138613435323433646634623232346163646566663565356433363732626530666364333663393935636335643037646166366461336335222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2452	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435322c2268617368223a2235613365646161383864653063616666316331343632653032633230623165653230366561316565336165383531633363343238333965646637383365316330222c22736c6f74223a32343335387d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2235333630386662303631343430633931333862663764383736343637646132646366323137313261633262373834303531613462663932356233343138363638222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2453	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435332c2268617368223a2261343662396666623830646132336131663137613935323762313364623665663239626532663432633763386566663830336634353133396663383462396532222c22736c6f74223a32343337317d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2235613365646161383864653063616666316331343632653032633230623165653230366561316565336165383531633363343238333965646637383365316330222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2454	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435342c2268617368223a2261373565306466333731346431613939316336376234326166313030366135353339623437666232333430666164663939666165663139333238663966633831222c22736c6f74223a32343337357d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2261343662396666623830646132336131663137613935323762313364623665663239626532663432633763386566663830336634353133396663383462396532222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2455	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435352c2268617368223a2239323735343737623534323439333065383438313036303732333864393738336262383036376461363833663064666330646536383366396262623237363363222c22736c6f74223a32343337377d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2261373565306466333731346431613939316336376234326166313030366135353339623437666232333430666164663939666165663139333238663966633831222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2456	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435362c2268617368223a2239343862353939653864343137633863326463653661383436613934616539373531393862366565333931316262323233383934326339653239383464393864222c22736c6f74223a32343338317d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2239323735343737623534323439333065383438313036303732333864393738336262383036376461363833663064666330646536383366396262623237363363222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2457	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435372c2268617368223a2237646231633233643939376565643163323265306664613961653032393638393561653931376238333737353839336231653366313733396432653666656239222c22736c6f74223a32343338337d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2239343862353939653864343137633863326463653661383436613934616539373531393862366565333931316262323233383934326339653239383464393864222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2458	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435382c2268617368223a2266613635636232316331613861363762613831363666626137663662356134313437663965333531626434313338666537353265623034303839646261303737222c22736c6f74223a32343338377d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2237646231633233643939376565643163323265306664613961653032393638393561653931376238333737353839336231653366313733396432653666656239222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2459	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323435392c2268617368223a2232326539653764643136343030643231353433333531623135393564363733373832313334383938666538363937396232313432373731306263646434643763222c22736c6f74223a32343339307d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2266613635636232316331613861363762613831363666626137663662356134313437663965333531626434313338666537353265623034303839646261303737222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2460	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436302c2268617368223a2266653265383134323838373037613164336137353562613837396162383637343264626137633237343837323333663033353662666134343761353131373265222c22736c6f74223a32343430307d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2232326539653764643136343030643231353433333531623135393564363733373832313334383938666538363937396232313432373731306263646434643763222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2461	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436312c2268617368223a2233396237393266653333303332623738666665386262383133303239373762363439383830303361323430633234323066343931653534646333616234316638222c22736c6f74223a32343431317d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2266653265383134323838373037613164336137353562613837396162383637343264626137633237343837323333663033353662666134343761353131373265222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2462	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436322c2268617368223a2233353132663234313834353862663831363939646665373562393762663031643866313163356338653766363233393039393737383533373266326462343732222c22736c6f74223a32343431397d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2233396237393266653333303332623738666665386262383133303239373762363439383830303361323430633234323066343931653534646333616234316638222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2463	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436332c2268617368223a2261386265333934353036656531343563663939303263646165636638333132643361326535646431393333383539626234353837623536626461346566323761222c22736c6f74223a32343436387d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2233353132663234313834353862663831363939646665373562393762663031643866313163356338653766363233393039393737383533373266326462343732222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2464	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436342c2268617368223a2262623862636131663162373539643761303765373134303633373036653431373838323034623566323437343537616436626262616131656134303930653133222c22736c6f74223a32343437357d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2261386265333934353036656531343563663939303263646165636638333132643361326535646431393333383539626234353837623536626461346566323761222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2465	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436352c2268617368223a2239623935363438363466633338363562633230343237343931636461623962656634646234646361346564656132623961306234613930663035316130666264222c22736c6f74223a32343437387d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2262623862636131663162373539643761303765373134303633373036653431373838323034623566323437343537616436626262616131656134303930653133222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2466	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436362c2268617368223a2236656139353861343866303538636636336630313264633732366665373164333266386663346130613937353433383035353263373239653536363662346164222c22736c6f74223a32343438307d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2239623935363438363466633338363562633230343237343931636461623962656634646234646361346564656132623961306234613930663035316130666264222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2467	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436372c2268617368223a2234303231363735616133376439356466656434356239323062393266333430313265366435356635636536333436383232303736396130366532626362303962222c22736c6f74223a32343438397d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2236656139353861343866303538636636336630313264633732366665373164333266386663346130613937353433383035353263373239653536363662346164222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2468	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436382c2268617368223a2231366332633461646330653462363031303731666131653365393162643161316334613262323036356164306537656463613937653636313865643737323436222c22736c6f74223a32343439337d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2234303231363735616133376439356466656434356239323062393266333430313265366435356635636536333436383232303736396130366532626362303962222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2469	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323436392c2268617368223a2231303733373234383030356431373837656538643439363033393738376537326333353062333131333562396336616264636134623732343136643730383665222c22736c6f74223a32343439347d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2231366332633461646330653462363031303731666131653365393162643161316334613262323036356164306537656463613937653636313865643737323436222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2470	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437302c2268617368223a2261353766613035323665363339633266623962323866303839353230623339386135376333626161353965666437316564383761306633366566623334633834222c22736c6f74223a32343536337d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2231303733373234383030356431373837656538643439363033393738376537326333353062333131333562396336616264636134623732343136643730383665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2471	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437312c2268617368223a2239316630633435656632666339646337316562386334636333623530633439366234663438356162313263646639663936643263373737313333653064343834222c22736c6f74223a32343537327d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2261353766613035323665363339633266623962323866303839353230623339386135376333626161353965666437316564383761306633366566623334633834222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2472	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437322c2268617368223a2234303639646439343330653434353263613664326336653738303838306430633237363036376137303431646362616232303466623030663763326634663163222c22736c6f74223a32343539317d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2239316630633435656632666339646337316562386334636333623530633439366234663438356162313263646639663936643263373737313333653064343834222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2473	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437332c2268617368223a2264323836636439656231333732653133313833373265343363623333343730663931613934613931666266626632623035306634633661636262656137373137222c22736c6f74223a32343631307d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2234303639646439343330653434353263613664326336653738303838306430633237363036376137303431646362616232303466623030663763326634663163222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2474	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437342c2268617368223a2238353162636537663762663830333239643861376261633831356639353438383238373631666561386332303365613333393535613937373764336232616634222c22736c6f74223a32343631337d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2264323836636439656231333732653133313833373265343363623333343730663931613934613931666266626632623035306634633661636262656137373137222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2475	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437352c2268617368223a2231363361366263643537633766363839306638383736393962366261666534306432663636656461653233656538346664663564346136333032343531353438222c22736c6f74223a32343631347d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2238353162636537663762663830333239643861376261633831356639353438383238373631666561386332303365613333393535613937373764336232616634222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2476	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437362c2268617368223a2265313635646265393734303130373333613363613461663630623830303365346261366661643464353030333965396138326330383465646335353232393934222c22736c6f74223a32343631357d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2231363361366263643537633766363839306638383736393962366261666534306432663636656461653233656538346664663564346136333032343531353438222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2477	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437372c2268617368223a2237653037396639303234643066663437326233383832623732663766343462353663643561356533633562653863386637656234336266643534313263376537222c22736c6f74223a32343634307d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2265313635646265393734303130373333613363613461663630623830303365346261366661643464353030333965396138326330383465646335353232393934222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2478	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437382c2268617368223a2232313963633936316138323634346564623862313139383339373636373738346266613866626638336163646233653635353938363861333835623063346664222c22736c6f74223a32343634367d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2237653037396639303234643066663437326233383832623732663766343462353663643561356533633562653863386637656234336266643534313263376537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2479	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323437392c2268617368223a2234323566646237616237353364313039393732313063643437356636666633393939356464363539366437333866356264653465336261386566623735623930222c22736c6f74223a32343634387d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2232313963633936316138323634346564623862313139383339373636373738346266613866626638336163646233653635353938363861333835623063346664222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2480	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323438302c2268617368223a2237663839333030653934663634326633373239366632386430313337623965666539343865646231643431363137336464663531613730316665323366353265222c22736c6f74223a32343637337d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2234323566646237616237353364313039393732313063643437356636666633393939356464363539366437333866356264653465336261386566623735623930222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2481	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323438312c2268617368223a2261393161353661383139633432383932386539643664633239336662663737636166356532643164616338303838326665623839306538306331343131616635222c22736c6f74223a32343638307d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2237663839333030653934663634326633373239366632386430313337623965666539343865646231643431363137336464663531613730316665323366353265222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2482	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323438322c2268617368223a2265303535636561656533626266333535336434653162343365323635613130653030623232636663306465343438383231363737376539393664333235653934222c22736c6f74223a32343638327d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2261393161353661383139633432383932386539643664633239336662663737636166356532643164616338303838326665623839306538306331343131616635222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2483	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323438332c2268617368223a2266653134653537313636383539313539333332323733323435636362633131313634646432656130633336653433303831306165643233316166633939656331222c22736c6f74223a32343639357d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2265303535636561656533626266333535336434653162343365323635613130653030623232636663306465343438383231363737376539393664333235653934222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2484	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323438342c2268617368223a2238643634303832653363306666386232623462636234356234383331376164306661366230623366393136323539623466376436656137353439623131366132222c22736c6f74223a32343639387d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2266653134653537313636383539313539333332323733323435636362633131313634646432656130633336653433303831306165643233316166633939656331222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2485	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323438352c2268617368223a2234633132616264613032386630396334316133663562633964613230353161346662306534613735643861313063326462653633613439336434336164323761222c22736c6f74223a32343734397d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2238643634303832653363306666386232623462636234356234383331376164306661366230623366393136323539623466376436656137353439623131366132222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2392	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339322c2268617368223a2237623961356437636565313932366164343637356436656164353737343765386634383732633935306630376461666238363937373961633565356364376535222c22736c6f74223a32333834307d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2264393566656533383334623636363332303666643539323261643833633061383265653063616561333234633131376361353832643235363564363937653235222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2393	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339332c2268617368223a2265363431383565316334323530666330323262323437383031346636333036653864316161333666623031656133633162656462306132643131663638643534222c22736c6f74223a32333835307d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2237623961356437636565313932366164343637356436656164353737343765386634383732633935306630376461666238363937373961633565356364376535222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2394	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339342c2268617368223a2234366464326638313738653530633464666463616335323963383130353537363030366538613537386436333861626365616563626564386634333961613665222c22736c6f74223a32333835337d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2265363431383565316334323530666330323262323437383031346636333036653864316161333666623031656133633162656462306132643131663638643534222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2395	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339352c2268617368223a2231336664386430376331653939663232393732333232306565336662653535383862643132333737383831656163383737656566613334326139316565346633222c22736c6f74223a32333836367d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2234366464326638313738653530633464666463616335323963383130353537363030366538613537386436333861626365616563626564386634333961613665222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2396	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339362c2268617368223a2265633039336264346136383262303730383561346234303936656434663033326135396463346537303636333631643730316564353063353965646166346634222c22736c6f74223a32333837367d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2231336664386430376331653939663232393732333232306565336662653535383862643132333737383831656163383737656566613334326139316565346633222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2397	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339372c2268617368223a2262336230633462366663623238313662353536646263306531386533323736323235383031376166363533326234303962656463343362333136633632376562222c22736c6f74223a32333837397d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2265633039336264346136383262303730383561346234303936656434663033326135396463346537303636333631643730316564353063353965646166346634222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2398	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339382c2268617368223a2262323237333735356435623764303764646139313236613234613337366537336262666630653338303139613163386238393733313666303537363838616534222c22736c6f74223a32333838327d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2262336230633462366663623238313662353536646263306531386533323736323235383031376166363533326234303962656463343362333136633632376562222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2399	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339392c2268617368223a2230653062623766396533326462393833616233623531666139313935343039343064373364626565336663393130393034626562653863363264613333656339222c22736c6f74223a32333838347d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2262323237333735356435623764303764646139313236613234613337366537336262666630653338303139613163386238393733313666303537363838616534222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2390	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339302c2268617368223a2231666532343435613434613835373262316263346164343465323664633236313762363661623263656265303334666232663934663663373833326564623466222c22736c6f74223a32333832357d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2234356265366639386363343936643630393563376432333961663963323563336239636638376530666161376463353334323730323662333638313439396264222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2391	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323339312c2268617368223a2264393566656533383334623636363332303666643539323261643833633061383265653063616561333234633131376361353832643235363564363937653235222c22736c6f74223a32333832377d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2231666532343435613434613835373262316263346164343465323664633236313762363661623263656265303334666232663934663663373833326564623466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2400	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430302c2268617368223a2265613234373134663337383863346364353332666132353538383465646236623663313435373335326261393734613633636134653839663135326330653462222c22736c6f74223a32333839327d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2230653062623766396533326462393833616233623531666139313935343039343064373364626565336663393130393034626562653863363264613333656339222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2401	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430312c2268617368223a2262326437363531326234366539313366386566376630346563323334626563636336346266313764376564613530643135343932623538366437643863316633222c22736c6f74223a32333930337d2c22697373756572566b223a2231643834376464623837336563633534643934656266303331643062386635346330616333626636633464366466363063613333623361343663363331376662222c2270726576696f7573426c6f636b223a2265613234373134663337383863346364353332666132353538383465646236623663313435373335326261393734613633636134653839663135326330653462222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138613077633675377978676e6d77687939756b376b7038706b6a74347a706535717761716d713933396e6378357730777a646c713979676b7471227d
2402	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430322c2268617368223a2261346432353763653364353562333435323331353033313133313164346534383161393938396233313565663133323736646364623631353863353639393466222c22736c6f74223a32333932397d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2262326437363531326234366539313366386566376630346563323334626563636336346266313764376564613530643135343932623538366437643863316633222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2403	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430332c2268617368223a2232393039636132303063323035613964356231343066623532303139313563313863383730323636353633333335613131313738663062623534666165643537222c22736c6f74223a32333933387d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2261346432353763653364353562333435323331353033313133313164346534383161393938396233313565663133323736646364623631353863353639393466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2404	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430342c2268617368223a2234323731373035333333386363613231653735306234386538353663393439336132373534306338666563306465643166653731393737636165613538323735222c22736c6f74223a32333934317d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2232393039636132303063323035613964356231343066623532303139313563313863383730323636353633333335613131313738663062623534666165643537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2405	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430352c2268617368223a2239373866313539313435313037366339353737333031613735373663346436323530663937383437303666303563633161353136303639386132633966333931222c22736c6f74223a32333934327d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2234323731373035333333386363613231653735306234386538353663393439336132373534306338666563306465643166653731393737636165613538323735222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2406	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430362c2268617368223a2233323831663533383237363364613239663133646431343636303632376531393234386638613038393135343432656562333830666362366165393763373537222c22736c6f74223a32333934397d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2239373866313539313435313037366339353737333031613735373663346436323530663937383437303666303563633161353136303639386132633966333931222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2407	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430372c2268617368223a2239366139653965633135653838663932383636636539616239363965633334373930333562356538666332316132653531323531386463303234346238306563222c22736c6f74223a32333935307d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2233323831663533383237363364613239663133646431343636303632376531393234386638613038393135343432656562333830666362366165393763373537222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2408	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430382c2268617368223a2262636130346230343738333934663565626462393833656632653563313130386630383930343863393333623161393965666337633037386431656634373063222c22736c6f74223a32333935347d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2239366139653965633135653838663932383636636539616239363965633334373930333562356538666332316132653531323531386463303234346238306563222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2409	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323430392c2268617368223a2232656638306633353966623862333264373030303931663932343739663336396164633665393130613464313961333336396339373462336435656132613263222c22736c6f74223a32333936307d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2262636130346230343738333934663565626462393833656632653563313130386630383930343863393333623161393965666337633037386431656634373063222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2410	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431302c2268617368223a2238666439626631616363353365363665636263343031616636343166323464306135623635373437386166656536626537663637303933376165313635326661222c22736c6f74223a32333936367d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2232656638306633353966623862333264373030303931663932343739663336396164633665393130613464313961333336396339373462336435656132613263222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2411	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431312c2268617368223a2266646264393537363130643561313338336162666136656530366266613837343332356463373563346434623064333465326636343531383831393462633832222c22736c6f74223a32333937317d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2238666439626631616363353365363665636263343031616636343166323464306135623635373437386166656536626537663637303933376165313635326661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2412	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431322c2268617368223a2266323536306439633064383733623064346536616331306561303965393865623063313134353630326365643033323532653635393438356236396331396565222c22736c6f74223a32333937387d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2266646264393537363130643561313338336162666136656530366266613837343332356463373563346434623064333465326636343531383831393462633832222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2413	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431332c2268617368223a2261663766633361383034636537323730343462636638373266343833626165613462643164656361613634353537353063363264313131396535656135643830222c22736c6f74223a32333938337d2c22697373756572566b223a2261616432376365393632646637336266376334323435626530636361353333383263376665653961386261623261373866653038393934396263326630613536222c2270726576696f7573426c6f636b223a2266323536306439633064383733623064346536616331306561303965393865623063313134353630326365643033323532653635393438356236396331396565222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31716d32747a71326a7139736c6472776b367575686a7973753378677938686776326b6d613961387875767a76746e6a723275307374386b617a37227d
2414	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431342c2268617368223a2235376662376461346465376239633761656537356661346466323734636435363334646164616535363132353639656432663137333131623738306138656239222c22736c6f74223a32333939387d2c22697373756572566b223a2237303632363133356434323163626564626538626465363832623430303862303733643365396432376663616232393734343233666537623636616565386362222c2270726576696f7573426c6f636b223a2261663766633361383034636537323730343462636638373266343833626165613462643164656361613634353537353063363264313131396535656135643830222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317779357736706463306137776e386d70767474656d666466767865776d78776c79346d6a6a6a706c6779646c7975367336677873796d79363475227d
2415	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431352c2268617368223a2236613335323762643632613735326665336366626534326663646236303731393237616132623631343666356533353833353061666563333030653938313239222c22736c6f74223a32343030307d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2235376662376461346465376239633761656537356661346466323734636435363334646164616535363132353639656432663137333131623738306138656239222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2416	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431362c2268617368223a2233333333343439393437303438333036343465373761316437313262636233393261383938613763323635653639623935386137343337656665346563616132222c22736c6f74223a32343031387d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2236613335323762643632613735326665336366626534326663646236303731393237616132623631343666356533353833353061666563333030653938313239222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2417	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431372c2268617368223a2233646331376366643838356462366532303837373132386136616163376130303534356436303539643264353736626338333462313231663330363565643732222c22736c6f74223a32343031397d2c22697373756572566b223a2264626239346163303062613863343763623533326466343763626264343161646235346464623666656166353662643534363031353334323061306538633362222c2270726576696f7573426c6f636b223a2233333333343439393437303438333036343465373761316437313262636233393261383938613763323635653639623935386137343337656665346563616132222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3171723366747a667166676e767037797775377977356c703965357a756734766b656d727537686a6e706c6a353934776c613074717479656d3339227d
2418	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431382c2268617368223a2237643266363764363234616437663137653430313238626566373237626539326638383362653862623236303037613832383964396433393539343263643030222c22736c6f74223a32343032397d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2233646331376366643838356462366532303837373132386136616163376130303534356436303539643264353736626338333462313231663330363565643732222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2419	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323431392c2268617368223a2233383839626331353166636131626664343832636330653238353839333462633832336635666334303134366462316235393437353234613666653032323738222c22736c6f74223a32343033307d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2237643266363764363234616437663137653430313238626566373237626539326638383362653862623236303037613832383964396433393539343263643030222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
2420	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432302c2268617368223a2236396265393661393835366632353663653564333465353966643765643364663735643734336365643365393536666664663463643636326630623032366431222c22736c6f74223a32343033377d2c22697373756572566b223a2261326237376264663538326337373235326639326237326339333764303264303731613064363839616632336337306134623938383732643833313732633432222c2270726576696f7573426c6f636b223a2233383839626331353166636131626664343832636330653238353839333462633832336635666334303134366462316235393437353234613666653032323738222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178377a6b71346b773832687463783772363974373466796c3565726166706e6377747166397163733535796e323675366873657365716d746879227d
2421	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432312c2268617368223a2234393863653737343861353564333634353030613935313033333435373163616161393165333838373163333537396565376335383564323537623036396339222c22736c6f74223a32343035367d2c22697373756572566b223a2235666263633431343336636334346465663832666631623936636534613337613466346334633061343431626264303663366137376461393832376637353864222c2270726576696f7573426c6f636b223a2236396265393661393835366632353663653564333465353966643765643364663735643734336365643365393536666664663463643636326630623032366431222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31747572356478396435687a6679377936646839656e6d3333396d657870766b6a796761763276356b6775636b3776676636737171743264616a32227d
2422	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323432322c2268617368223a2266623038363836333065333164376162356262633964353464613537303965386462636165353263343061653031373434663965313931396238663330303832222c22736c6f74223a32343035387d2c22697373756572566b223a2262633363376666316466663238663933313164323930613763376631373432663837376336663264616636646636363335663731653233363939393438386163222c2270726576696f7573426c6f636b223a2234393863653737343861353564333634353030613935313033333435373163616161393165333838373163333537396565376335383564323537623036396339222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313232386b67346b6772657a6d30783779766468737a376b727a323278307a67637073396a39757075796374746e7571746a367571676d3834667a227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	20442	179	3	7868186923403962	98204936396794	12154144439888	0.07652659215162522	80.12007554908234	-79.12007554908234	15.995239077044076	17.104189324214182
pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	20442	228	3	7890086457482328	126672784673586	16731128590207	0.09871027755935315	62.287147770641695	-61.287147770641695	21.439196624402303	20.76758097124844
pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	20442	210	3	7785201313000080	12474040272808	200222435	0.00972044611467504	624.1122477350775	-623.1122477350775	0	1.5249394511865206
pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	20442	190	3	7876388665113674	109696364352402	14653675715587	0.08548133366121095	71.80172936097135	-70.80172936097135	17.60261225721037	18.287124530413394
pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	20442	201	4	7880273095874954	112477735979467	14961662672222	0.08764872870199074	70.06073715169295	-69.06073715169295	21.173595942473348	18.812135503607724
pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	20442	228	3	7894453276290726	129934976239099	17338000064667	0.10125235347339687	60.756953245320176	-59.756953245320176	22.88209769293881	22.112510878859723
pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	20442	215	5	7896328459351255	127434940445355	15320535655147	0.09930419051365223	61.96360614879603	-60.96360614879603	20.17770808865136	19.556100285123616
pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7	20442	60	3	0	13338660275393	300000000	0.010394204733453795	0	1	7.7161935240835025	7.7161935240835025
pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm	20442	62	3	0	45727125315518	500000000	0.03563304654205898	0	1	25.32723169544575	25.32723169544575
pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	20442	214	3	0	24230769435815	300000000	0.018881924658475883	0	1	0	3.8759835108022007
pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	20442	215	3	0	127587888227214	500000000	0.0994233756885759	0	1	19.920066762227517	22.530454659420204
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0
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
1	SP4	Same Name	This is the stake pool 4 description.	https://stakepool4.com	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	\N	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	5590000000000
2	SP1	stake pool - 1	This is the stake pool 1 description.	https://stakepool1.com	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	\N	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	2770000000000
3	SP3	Stake Pool - 3	This is the stake pool 3 description.	https://stakepool3.com	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	\N	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	4710000000000
4	SP11	Stake Pool - 10 + 1	This is the stake pool 11 description.	https://stakepool11.com	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	\N	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	12460000000000
5	SP5	Same Name	This is the stake pool 5 description.	https://stakepool5.com	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	\N	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	6640000000000
6	SP10	Stake Pool - 10	This is the stake pool 10 description.	https://stakepool10.com	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	\N	pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm	11040000000000
7	SP6a7		This is the stake pool 7 description.	https://stakepool7.com	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	\N	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	8270000000000
8	SP6a7	Stake Pool - 6	This is the stake pool 6 description.	https://stakepool6.com	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	\N	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	7300000000000
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
2770000000000	stake_test1uramyxkgqxm6dvjt6a58uw2yfkxzsn9xym0g0e78hmeuj0sc0re3p	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1uramyxkgqxm6dvjt6a58uw2yfkxzsn9xym0g0e78hmeuj0sc0re3p"]	ffd47dea2f2481abd4b51560158dc88f95a774936440911d8460584432c3f8fc	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	277	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92
3730000000000	stake_test1urdjucppev4qkr9u86wh6mfeyq9ey0frktk39lfn94j3vhquldye9	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1urdjucppev4qkr9u86wh6mfeyq9ey0frktk39lfn94j3vhquldye9"]	b3f26be4230cd928d9aaa1e8bc74eda8b4335ccf2b480d3a5f7ac85e38643646	\N	\N	373	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8
4710000000000	stake_test1uqjfvrqufx5xskzfdgmt4qsv6e8f0ufsqesg9mm04d6495s7smm5d	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1uqjfvrqufx5xskzfdgmt4qsv6e8f0ufsqesg9mm04d6495s7smm5d"]	f09e623440a78456dacf78001751705eed9443396691b4195c371a51994583d1	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	471	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q
5590000000000	stake_test1uzn3h4jfanyemlasle7zxklc4hwpchlgavcw89l4mye5qlq7gk5ml	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1uzn3h4jfanyemlasle7zxklc4hwpchlgavcw89l4mye5qlq7gk5ml"]	18cf115b96b8e5d8608e62f3b79f15206017256d02adc4083b59ec5da124aa51	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	559	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv
6640000000000	stake_test1up07karqh9fvpez749l6svfvd4e0ffs8taflcz0glph4hrgqzc0k5	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1up07karqh9fvpez749l6svfvd4e0ffs8taflcz0glph4hrgqzc0k5"]	e3707a5a0780602c8f814d8362a96228b634f7740ca2bf60ac75d409396f4c4f	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	664	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc
7300000000000	stake_test1upt5lffrzcpz5mykvz4xffaf0a3a2zcam3s3uqk8frmkzgsymxc8v	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1upt5lffrzcpz5mykvz4xffaf0a3a2zcam3s3uqk8frmkzgsymxc8v"]	0e73f55cbe377bb7e671cb2296c5ea4a26ff821f8b90c6ce7317e1e39a49ba65	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	730	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0
8270000000000	stake_test1uruhj9e8rgpeqze888np42ja7wxk3qr30r2ty9pue6uxhdgc4x76u	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1uruhj9e8rgpeqze888np42ja7wxk3qr30r2ty9pue6uxhdgc4x76u"]	8065a37664491d9d2d9f695657b668add09b301984fb1adc8cfb841f3200f731	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	827	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy
8950000000000	stake_test1uz5s7l5w232mnhkqk4v73dxt77hqanz7fwvn3qyffjcd26qkw60ar	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1uz5s7l5w232mnhkqk4v73dxt77hqanz7fwvn3qyffjcd26qkw60ar"]	589c98d439ff42499775dc3411c3ec62533ffb76495004f99506221d739ac084	\N	\N	895	pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7
10110000000000	stake_test1ur9ln0j8n4834k82l5f78sgml6v8ede0kqexqp3rp8hy68qsfqtug	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1ur9ln0j8n4834k82l5f78sgml6v8ede0kqexqp3rp8hy68qsfqtug"]	ee6a390cbed54afc5199643854c285492f9baecf52ad1043ccaa284f29faef3f	\N	\N	1011	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz
11040000000000	stake_test1uzurcn02efx8s0p70d4yrewdvtqmwhm3yuv0ln5vagw9slqzekn5p	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uzurcn02efx8s0p70d4yrewdvtqmwhm3yuv0ln5vagw9slqzekn5p"]	d024d972fe63d9459dd38a50e3c71fa9b49bb080838f6d15dce5b3175fd87390	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	1104	pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm
12460000000000	stake_test1uzu7nh0cz53g5xe00wcw928djg9wamp0pdm9xzytjf4tqus5wq225	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uzu7nh0cz53g5xe00wcw928djg9wamp0pdm9xzytjf4tqus5wq225"]	f77fc241b5e28b360639d141f24c4ddbf4f1850b31a148ec5be621c597201af1	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1246	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3
230660000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	23066	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
231640000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	23164	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
9430000000000	5	943	pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7
10340000000000	18	1034	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz
11310000000000	5	1131	pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm
12720000000000	18	1272	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7	1000000	0	0	500000000	0	0	0	0	0	1
2	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	0	0	400000000	0	0	0	0	0	1
3	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	0	0	500000000	0	0	0	0	0	1
4	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	0	0	600000000	0	0	0	0	0	1
5	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	0	0	420000000	0	0	0	0	0	1
6	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	0	0	410000000	0	0	0	0	0	1
7	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	0	0	410000000	0	0	0	0	0	1
8	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	0	0	410000000	0	0	0	0	0	1
9	pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7	1000000	1	0	500000000	0	0	0	3328637822268	3328637822268	1
10	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	1	0	500000000	0	0	0	7489435100103	7489435100103	1
11	pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm	1000000	1	0	400000000	0	0	0	8321594555671	8321594555671	1
12	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	1	0	400000000	0	0	0	12482391833506	12482391833506	1
13	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	1	0	400000000	0	0	0	8321594555671	8321594555671	1
14	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	1	0	500000000	0	0	0	10818072922372	10818072922372	1
15	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	1	0	600000000	0	0	0	3328637822268	3328637822268	1
16	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	1	0	420000000	0	0	0	4992956733402	4992956733402	1
17	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	1	0	410000000	0	0	0	8321594555671	8321594555671	1
18	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	1	0	410000000	0	0	0	7489435100103	7489435100103	1
19	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	1	0	410000000	0	0	0	13314551289073	13314551289073	1
20	pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7	1000000	2	3	500000000	7773227572016780	7773227272016780	0	9509723163617	9509723163617	1
21	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	2	2	500000000	7772727572727272	7772727272727272	0	6916607199492	6916607199492	1
22	pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm	1000000	2	1	400000000	7772727272727272	7772727272727272	0	12104063066287	12104063066287	1
23	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	2	1	400000000	7772727272727272	7772727272727272	0	9510335266368	9510335266368	1
24	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	2	3	400000000	7773227772190781	7773227272190781	0	8645202653386	8645202653386	1
25	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	2	3	500000000	7773227872193545	7773227272193545	0	4322601271081	4322601271081	1
26	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	2	3	600000000	7773227472190773	7773227272190773	0	8645202987039	8645202987039	1
27	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	2	3	420000000	7773227772190773	7773227272190773	0	6916162122708	6916162122708	1
28	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	2	3	410000000	7773227772190773	7773227272190773	0	4322601326692	4322601326692	1
29	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	2	3	410000000	7773227772190773	7773227272190773	0	6916162122708	6916162122708	1
30	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	2	3	410000000	7773227772190773	7773227272190773	0	6916162122708	6916162122708	1
31	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	3	3	500000000	7773227572016780	7773227272016780	0	9324427846712	9324427846712	1
32	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	3	3	400000000	7773227772013964	7773227272013964	0	8476752369822	8476752369822	1
33	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	3	3	400000000	7773227772190781	7773227272190781	1271844818888	7204907550741	8476752369629	1
34	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	3	3	500000000	7773227872193545	7773227272193545	1144693555694	6484383478824	7629077034518	1
35	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	3	3	600000000	7773227472190773	7773227272190773	0	0	0	1
36	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	3	3	420000000	7773227772190773	7773227272190773	1144676486998	6484400645668	7629077132666	1
37	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	3	3	410000000	7773227772190773	7773227272190773	508936827542	2881764120309	3390700947851	1
38	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	3	3	410000000	7773227772190773	7773227272190773	2289063974015	12969090291318	15258154265333	1
39	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	3	3	410000000	7773227772190773	7773227272190773	890390823215	5043335835525	5933726658740	1
40	pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7	1000000	3	3	500000000	7773227572016780	7773227272016780	0	0	0	1
41	pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm	1000000	3	3	400000000	7773227772013964	7773227272013964	0	5086051421891	5086051421891	1
42	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	4	3	500000000	7780717007116883	7780716707116883	0	0	0	1
43	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	4	3	400000000	7785710163847470	7785709663847470	801728704151	4540917379398	5342646083549	1
44	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	4	3	400000000	7781549366746452	7781548866746452	1260343332629	7139732493164	8400075825793	1
45	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	4	3	500000000	7784045945115917	7784045345115917	801900100224	4541888233993	5343788334217	1
46	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	4	3	600000000	7776556110013041	7776555910013041	0	0	0	1
47	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	4	3	420000000	7778220728924175	7778220228924175	1260865546509	7142805035859	8403670582368	1
48	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	4	3	410000000	7781549366746444	7781548866746444	1145796802388	6490635766516	7636432568904	1
49	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	4	3	410000000	7780717207290876	7780716707290876	1145927811676	6491321485222	7637249296898	1
50	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	4	3	410000000	7786542323479846	7786541823479846	1602954615182	9081195598476	10684150213658	1
51	pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7	1000000	4	3	500000000	7776556209839048	7776555909839048	0	0	0	1
52	pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm	1000000	4	3	400000000	7781549366569635	7781548866569635	1374906862900	7788812219992	9163719082892	1
53	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	5	3	500000000	7787633614316375	7787633314049419	0	0	0	1
54	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	5	3	400000000	7795220499113838	7795219999113838	1348749799157	7640702261298	8989452060455	1
55	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	5	3	400000000	7790194569399838	7790194068843750	490981771592	2780018848163	3271000619755	1
56	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	5	3	500000000	7788368546386998	7788367946053346	1718010199634	9733176129657	11451186329291	1
57	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	5	3	600000000	7785201313000080	7785201112777645	0	0	0	1
58	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	5	3	420000000	7785136891046883	7785136390602013	736768040005	4172920438401	4909688478406	1
59	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	5	3	410000000	7785871968073136	7785871467795092	491254173389	2781562457684	3272816631073	1
60	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	5	3	410000000	7787633369413584	7787632868968714	1104666182983	6257505689459	7362171872442	1
61	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	5	3	410000000	7793458485602554	7793457985157684	1103832268865	6252836846793	7356669115658	1
62	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	6	3	500000000	7796958042163087	7796957741536264	0	0	0	1
63	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	6	3	400000000	7803697251483660	7803696750938407	1327597219355	7520837693668	8848434913023	1
64	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	6	3	400000000	7798671321769467	7797398976394491	604580749564	3420027147304	4024607896868	1
65	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	6	3	500000000	7795997623421516	7794852329532170	1330013557359	7527160411402	8857173968761	1
66	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	6	3	600000000	7785201313000080	7785201112777645	0	0	0	1
67	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	6	3	420000000	7792765968179549	7791620791247681	1451478675842	8214899905988	9666378581830	1
68	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	6	3	410000000	7789262669020987	7788753231915401	967762502300	5479388252856	6447150755156	1
69	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	6	3	410000000	7802891523678917	7800601959260032	846454984802	4784948672162	5631403656964	1
70	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	6	3	410000000	7799392212261294	7798501320993209	483552347344	2735836377570	3219388724914	1
71	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	7	3	500000000	7796958042163087	7796957741536264	0	0	0	1
72	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	7	3	400000000	7809039897567209	7808237668317805	1362124523071	7711213891465	9073338414536	1
73	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	7	3	400000000	7807071397595260	7804538708887655	584837042298	3304717041326	3889554083624	1
74	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	7	3	500000000	7801341411755733	7799394217766163	1559497928713	8820264502030	10379762430743	1
75	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	7	3	600000000	7785201313000080	7785201112777645	0	0	0	1
76	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	7	3	420000000	7801169638761917	7798763596283540	390244363252	2204753382110	2594997745362	1
77	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	7	3	410000000	7796899101589891	7795243867681917	1365091280244	7722375513932	9087466794176	1
78	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	7	3	410000000	7810528772975815	7807093280745254	974720549297	5505000034354	6479720583651	1
79	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	7	3	410000000	7810076362474952	7807582516591685	487217985420	2752829980218	3240047965638	1
80	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	8	3	500000000	7796958042163087	7796957741536264	0	0	0	1
81	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	8	3	400000000	7818029349627664	7815878370579103	645739261715	3650281945547	4296021207262	1
82	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	8	3	400000000	7810342398215015	7807318727735818	554433489285	3131494532001	3685928021286	1
83	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	8	3	500000000	7812792598085024	7809127393895820	739244873214	4173784544459	4913029417673	1
84	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	8	3	600000000	7785201313000080	7785201112777645	0	0	0	1
85	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	8	3	420000000	7806079327240323	7802936516721941	1201629708753	6788909097171	7990538805924	1
86	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	8	3	410000000	7800171918220964	7798025430139601	1663751585792	9408450489978	11072202075770	1
87	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	8	3	410000000	7817890944848257	7813350786434713	831599430094	4691954192842	5523553622936	1
88	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	8	3	410000000	7817433031590610	7813835353438478	831073755332	4692803414788	5523877170120	1
89	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	9	3	500000000	7796958042163087	7796957741536264	0	0	0	1
90	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	9	3	400000000	7826877784540687	7823399208272771	896015867833	5060213514857	5956229382690	1
91	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	9	3	400000000	7814367006111883	7810738754883122	1060681355464	5989768530695	7050449886159	1
92	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	9	3	500000000	7821649772053785	7816654554307222	979168065255	5522879799829	6502047865084	1
93	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	9	3	600000000	7785201313000080	7785201112777645	0	0	0	1
94	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	9	3	420000000	7815745705822153	7811151416627929	898001529254	5066711396383	5964712925637	1
95	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	9	3	410000000	7806619068976120	7803504818392457	734876877191	4151048203097	4885925080288	1
96	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	9	3	410000000	7823522348505221	7818135735106875	979217837564	5521273748753	6500491586317	1
97	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	9	3	410000000	7820652420315524	7816571189816048	1386279096235	7826130069114	9212409165349	1
98	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	10	3	500000000	7796958042163087	7796957741536264	0	0	0	1
99	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	10	3	400000000	7835951122955223	7831110422164236	1116232671582	6297158419162	7413391090744	1
100	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	10	3	400000000	7818256560195507	7814043471924448	1211420816917	6837929309261	8049350126178	1
101	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	10	3	500000000	7832029534484528	7825474818809252	1025019538684	5773991601544	6799011140228	1
102	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	10	3	600000000	7785201313000080	7785201112777645	0	0	0	1
103	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	10	3	420000000	7818340703567515	7813356170010039	839219196482	4733347839634	5572567036116	1
104	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	10	3	410000000	7815706535770296	7811227193906389	279958770906	1578189624780	1858148395686	1
105	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	10	3	410000000	7830002069088872	7823640735141229	931987113825	5250532563890	6182519677715	1
106	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	10	3	410000000	7823892468281162	7819324019796266	1024621669797	5781460631492	6806082301289	1
107	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	11	3	500000000	7796958042163087	7796957741536264	0	0	0	1
108	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	11	3	400000000	7840247144162485	7834760704109783	550378929707	3102121803428	3652500733135	1
109	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	11	3	400000000	7821942488216793	7817174966456449	643227568384	3627995327890	4271222896274	1
110	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	11	3	500000000	7836942563902201	7829648603353711	643160874428	3619886809869	4263047684297	1
111	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	11	3	600000000	7785201313000080	7785201112777645	0	0	0	1
112	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	11	3	420000000	7826331242373439	7820145079107210	459737277252	2589425388621	3049162665873	1
113	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	11	3	410000000	7826778737846066	7820635644396367	1194725427191	6732644231417	7927369658608	1
114	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	11	3	410000000	7835525622711808	7828332689334071	1010610818261	5689675544769	6700286363030	1
115	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	11	4	410000000	7829416345451282	7824016823211054	734700690653	4142037187541	4876737878194	1
116	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	12	3	500000000	7796958042163087	7796957741536264	0	0	0	1
117	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	12	3	400000000	7846203373545175	7839820917624640	816011813179	4596907765008	5412919578187	1
118	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	12	3	400000000	7828992938102952	7823164734987144	999076855470	5631257198981	6630334054451	1
119	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	12	3	500000000	7843444611767285	7835171483153540	817409410813	4597414044609	5414823455422	1
120	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	12	3	600000000	7785201313000080	7785201112777645	0	0	0	1
121	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	12	3	420000000	7832295955299076	7825211790503593	1090378942873	6139662430689	7230041373562	1
122	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	12	3	410000000	7831664662926354	7824786692599464	545326823092	3069985262144	3615312085236	1
123	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	12	3	410000000	7842026114298125	7833853963082824	908303711655	5109255077940	6017558789595	1
124	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	12	4	410000000	7838628754616631	7831842953280168	1089277064114	6134923185637	7224200249751	1
125	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	13	3	500000000	7796958042163087	7796957741536264	0	0	0	1
126	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	13	3	400000000	7853616764635919	7846118076043802	1062105098375	5978295066863	7040400165238	1
127	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	13	3	400000000	7837042288229130	7830002664296405	532171340870	2995473575024	3527644915894	1
128	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	13	3	500000000	7850243622907513	7840945474755084	798034813119	4484534183159	5282568996278	1
129	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	13	3	600000000	7785201313000080	7785201112777645	0	0	0	1
130	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	13	3	420000000	7837868522335192	7829945138343227	1153244859107	6489180075775	7642424934882	1
131	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	13	3	410000000	7833522811322040	7826364882224244	1153270000363	6493394632419	7646664632782	1
132	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	13	3	410000000	7848208633975840	7839104495646714	1064074135107	5981177507172	7045251642279	1
133	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	13	4	410000000	7850434791107009	7842624368100749	443016305361	2491672782925	2934689088286	1
134	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	14	3	500000000	7796958042163087	7796957741536264	0	0	0	1
135	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	14	3	400000000	7857269265369054	7849220197847230	792405866299	4457615840708	5250021707007	1
136	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	14	3	400000000	7841313511125404	7833630659624295	441157245689	2481456431107	2922613676796	1
137	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	14	3	500000000	7854506670591810	7844565361564953	617443578027	3467342838471	4084786416498	1
138	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	14	3	600000000	7785201313000080	7785201112777645	0	0	0	1
139	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	14	3	420000000	7840917685001065	7832534563731848	617812616536	3474053086595	4091865703131	1
140	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	14	3	410000000	7841450180980648	7833097526455661	1323422763979	7444265450345	8767688214324	1
141	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	14	3	410000000	7854908920338870	7844794171191483	970158225565	5448463143184	6418621368749	1
142	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	14	4	410000000	7855311528985203	7846766405288290	1497379707671	8421799448006	9919179155677	1
143	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	15	3	500000000	7796958042163087	7796957741536264	0	0	0	1
144	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	15	3	400000000	7862682184947241	7853817105612238	780550436466	4387889957865	5168440394331	1
145	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	15	3	400000000	7847943845179855	7839261916823276	521391902517	2930705871043	3452097773560	1
146	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	15	3	500000000	7859921494047232	7849162775609562	868724248867	4876004349990	5744728598857	1
147	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	15	3	600000000	7785201313000080	7785201112777645	0	0	0	1
148	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	15	3	420000000	7848147726374627	7838674226162537	608547731952	3418795044473	4027342776425	1
149	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	15	3	410000000	7845065493065884	7836167511717805	1129888075207	6352401343664	7482289418871	1
150	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	15	3	410000000	7860926479128465	7849903426269423	1389852331512	7800538325166	9190390656678	1
151	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	15	4	410000000	7862535712342842	7852901311581815	1041216163121	5850166074404	6891382237525	1
152	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	16	3	400000000	7851471490095749	7842257390398300	720127406057	4046813827521	4766941233578	1
153	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	16	3	500000000	7865204063043510	7853647309792721	1519773684120	8526198068563	10045971752683	1
154	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	16	3	600000000	7785201313000080	7785201112777645	0	0	0	1
155	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	16	3	420000000	7855790151309509	7845163406238312	960482342368	5391945182557	6352427524925	1
156	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	16	3	410000000	7852712157698666	7842660906350224	1120507962754	6293562405448	7414070368202	1
157	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	16	3	410000000	7867971730770744	7855884603776595	720092775427	4036851513536	4756944288963	1
158	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	16	4	410000000	7865470401431128	7855392984364740	1198582250540	6732179522164	7930761772704	1
159	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	16	3	500000000	7796958042163087	7796957741536264	0	0	0	1
160	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	16	3	400000000	7869722585112479	7859795400679101	878476079258	4934273433430	5812749512688	1
161	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	17	3	400000000	7854394103772545	7844738846829407	842222167063	4731558457216	5573780624279	1
162	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	17	3	500000000	7869288849460008	7857114652631192	757951191113	4248956479667	5006907670780	1
163	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	17	3	600000000	7785201313000080	7785201112777645	0	0	0	1
164	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	17	3	420000000	7859882017012640	7848637459324907	926796204151	5200081595533	6126877799684	1
165	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	17	4	410000000	7863980608739558	7852605934627137	589655628931	3307234545960	3896890174891	1
166	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	17	3	410000000	7874390352139493	7861333066919779	926297537516	5189291668076	6115589205592	1
167	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	17	4	410000000	7872888817159515	7861314020385456	925488326194	5191267258261	6116755584455	1
168	pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	1000000	17	3	500000000	7796958042163087	7796957741536264	0	0	0	1
169	pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	1000000	17	3	400000000	7874972606819486	7864253016519809	1260802878295	7078020351353	8338823229648	1
170	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	18	3	400000000	7857846201546105	7847669552700450	415146021113	2330139698999	2745285720112	1
171	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	18	3	500000000	7875033578058865	7861990656981182	1410482637291	7903117281239	9313599918530	1
172	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	18	3	600000000	7785201313000080	7785201112777645	0	0	0	1
173	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	18	3	420000000	7863909359789065	7852056254369380	913291749383	5121680216617	6034971966000	1
174	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	18	4	410000000	7871462898158429	7858958335970801	746936892909	4186029170030	4932966062939	1
175	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	18	3	410000000	7883580742796171	7869133605244945	1244472200498	6964500475147	8208972675645	1
176	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	18	4	410000000	7879780199397040	7867164186459860	580452141233	3252249455878	3832701597111	1
177	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	19	3	400000000	7862613142779683	7851716366527971	1338146745072	7511127555586	8849274300658	1
178	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	19	3	500000000	7885079549811548	7870516855049745	774650668873	4334016041060	5108666709933	1
179	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	19	3	600000000	7785201313000080	7785201112777645	0	0	0	1
180	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	19	3	420000000	7870261787313990	7857448199551937	563823723556	3158565418103	3722389141659	1
181	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	19	4	410000000	7876376205700063	7862751135549681	915846203722	5128340413675	6044186617397	1
182	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	19	3	410000000	7888337687085134	7873170456758481	1267423651988	7088759983627	8356183635615	1
183	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	19	4	410000000	7890211703766800	7876397108579080	844039429488	4725426533980	5569465963468	1
184	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	20	3	400000000	7868186923403962	7856447924985187	625856077895	3509350282656	4135206360551	1
185	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	20	3	500000000	7890086457482328	7874765811529412	1125988776745	6296723029595	7422711806340	1
186	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	20	3	600000000	7785201313000080	7785201112777645	0	0	0	1
187	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	20	3	420000000	7876388665113674	7862648281147470	500922322482	2803797949210	3304720271692	1
188	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	20	4	410000000	7880273095874954	7866058370095641	751123190869	4203513718152	4954636909021	1
189	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	20	3	410000000	7894453276290726	7878359748426557	875841627442	4894185208125	5770026835567	1
190	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	20	4	410000000	7896328459351255	7881588375837341	1062164957836	5942632338093	7004797295929	1
191	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	21	3	400000000	7870932209124074	7858778064684186	823110219958	4614503584338	5437613804296	1
192	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	21	3	500000000	7899400057400858	7882668928810651	940281465593	5251738806762	6192020272355	1
193	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	21	3	600000000	7785201313000080	7785201112777645	0	0	0	1
194	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	21	3	420000000	7882423637079674	7867769961364087	940922885330	5264433176070	6205356061400	1
195	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	21	4	410000000	7885205008706739	7870243346034517	882030565309	4933438710797	5815469276106	1
196	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	21	3	410000000	7902662248966371	7885324248901704	587815549366	3280599593049	3868415142415	1
197	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	21	5	410000000	7900162213172627	7884841677517480	704520289150	3939046891025	4643567180175	1
198	pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	1000000	22	3	400000000	7879781483424732	7866289192239772	831991401061	4659132189596	5491123590657	1
199	pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	1000000	22	3	500000000	7904508724110791	7887002944851711	727802598006	4061900160909	4789702758915	1
200	pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	1000000	22	3	600000000	7785201313000080	7785201112777645	0	0	0	1
201	pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	1000000	22	3	420000000	7886146026221333	7870928526782190	624316201967	3490702767595	4115018969562	1
202	pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	1000000	22	4	410000000	7891249195324136	7875371686448192	780189295643	4360258004176	5140447299819	1
203	pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	1000000	22	3	410000000	7911018432601986	7892413008885331	1143445452641	6377036865413	7520482318054	1
204	pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	1000000	22	5	410000000	7905731679136095	7889567104051460	675093338056	3771799789112	4446893127168	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1uj06pf5y4rsvud4h3p3v4p5xlkqkqqms6hjm4tmjxanhcvvsl92	active	2770000000000	\N
pool16kuq3l6rgw2ajrqjfwfgsz4x07z9r6x3dj48z844qmv97v6u6w8	active	3730000000000	\N
pool1q4knjv794camd6cwzq9k2dkt7ukttxnpp5500pwz3qscyr2vj2q	active	4710000000000	\N
pool16wzssm6fywpfd5cl2dnpqcndzqm5gz6zn3cp5rx683lv57rvnpv	active	5590000000000	\N
pool14e7t0epl35th50jug7puc27klk0u0pjulwetzukgupmcygttutc	active	6640000000000	\N
pool1922y82shxaetaaz0r2ayh8t8pxdra92eak53t8p3ytcr2nwahn0	active	7300000000000	\N
pool1q2vgpa5mf97tv8f9aaqrlpzh5prz9xfau9rz99d8ptulg0n9jgy	active	8270000000000	\N
pool127l3zt02uqll4hy93uf58xwd8jr5h29rcvglczd4a6w763nhhc7	retired	8950000000000	9430000000000
pool12992632nchh7q9gee72h69d0y2u00fk03ejwrkt85zng6gu8ygm	retired	11040000000000	11310000000000
pool1psaglmqh577hvdl0wzm5f67hgcxwe49jlh7z0vnu34ac2yfp8sz	retired	10110000000000	10340000000000
pool1z4fd6a5l5jhxd5akgthvavthnadeghz0cm60s8fgunl75mx4jh3	retired	12460000000000	12720000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	230660000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	231640000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 8, true);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 204, true);


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

