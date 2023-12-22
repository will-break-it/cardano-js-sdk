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
ab9c97db-c832-49e7-9ba3-391b7dcc2a0a	__pgboss__cron	0	\N	created	2	0	0	f	2023-12-22 09:41:11.863925+00	\N	\N	2023-12-22 09:41:00	00:15:00	2023-12-22 09:41:11.863925+00	\N	2023-12-22 09:42:11.863925+00	f	\N	2023-12-22 09:43:09.183079+00
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, block_slot) FROM stdin;
c5c04e5d-68a9-4f52-a7cc-4c390094e9a0	pool-rewards	0	{"epochNo": 4}	completed	1000000	0	30	f	2023-12-22 09:49:37.031691+00	2023-12-22 09:49:37.37253+00	4	\N	00:15:00	2023-12-22 09:49:37.031691+00	2023-12-22 09:49:37.509933+00	2024-01-05 09:49:37.031691+00	f	\N	6015
015ded70-7065-4125-88f2-c7dbe82fa8b6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 09:41:11.85716+00	2023-12-22 09:41:11.859537+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:41:11.85716+00	2023-12-22 09:41:11.86758+00	2023-12-22 09:49:11.85716+00	f	\N	\N
dbfd5102-937a-4bb8-aa79-6a90a432e2da	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:30:01.35425+00	2023-12-22 10:30:02.37069+00	\N	2023-12-22 10:30:00	00:15:00	2023-12-22 10:29:02.35425+00	2023-12-22 10:30:02.377672+00	2023-12-22 10:31:01.35425+00	f	\N	\N
4b3c432f-4ef7-438f-a5d3-134f927e2513	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:09:01.850244+00	2023-12-22 10:09:01.864802+00	\N	2023-12-22 10:09:00	00:15:00	2023-12-22 10:08:01.850244+00	2023-12-22 10:09:01.876967+00	2023-12-22 10:10:01.850244+00	f	\N	\N
f346e1f3-3b9a-41d7-8df5-3a499d727354	pool-rewards	0	{"epochNo": 5}	completed	1000000	0	30	f	2023-12-22 09:52:55.209916+00	2023-12-22 09:52:55.469748+00	5	\N	00:15:00	2023-12-22 09:52:55.209916+00	2023-12-22 09:52:55.60001+00	2024-01-05 09:52:55.209916+00	f	\N	7006
f98a71a1-1a0c-4c6e-8821-38d431aa92ca	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:10:01.874372+00	2023-12-22 10:10:01.888734+00	\N	2023-12-22 10:10:00	00:15:00	2023-12-22 10:09:01.874372+00	2023-12-22 10:10:01.903803+00	2023-12-22 10:11:01.874372+00	f	\N	\N
da016d2e-168d-4121-b18e-85947334a293	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:16:01.027506+00	2023-12-22 10:16:02.037844+00	\N	2023-12-22 10:16:00	00:15:00	2023-12-22 10:15:02.027506+00	2023-12-22 10:16:02.051672+00	2023-12-22 10:17:01.027506+00	f	\N	\N
6ca28c0e-1d5b-4c50-a80a-e34f3c1b7613	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:17:01.048475+00	2023-12-22 10:17:02.060673+00	\N	2023-12-22 10:17:00	00:15:00	2023-12-22 10:16:02.048475+00	2023-12-22 10:17:02.072067+00	2023-12-22 10:18:01.048475+00	f	\N	\N
156321b8-05b9-4b7c-9e62-e411c37deab8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:18:09.231974+00	2023-12-22 10:19:09.21971+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:16:09.231974+00	2023-12-22 10:19:09.229797+00	2023-12-22 10:26:09.231974+00	f	\N	\N
d04f35c5-173f-4e26-9091-a5efc0c56a05	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 09:43:09.173775+00	2023-12-22 09:43:09.178574+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:43:09.173775+00	2023-12-22 09:43:09.187758+00	2023-12-22 09:51:09.173775+00	f	\N	\N
b3917249-5884-4193-b146-2e2094d0dfb9	pool-metadata	0	{"poolId": "pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "2110000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.232231+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:11.976019+00	\N	2024-01-05 09:41:11.976019+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	211
e94971ce-419b-41b8-aef9-bf1e565f9b67	pool-metadata	0	{"poolId": "pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "11340000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.23934+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.191011+00	\N	2024-01-05 09:41:12.191011+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	1134
740da84d-d733-4061-99c3-45903294280c	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2023-12-22 09:41:12.367318+00	2023-12-22 09:43:09.19284+00	0	\N	00:15:00	2023-12-22 09:41:12.367318+00	2023-12-22 09:43:09.448961+00	2024-01-05 09:41:12.367318+00	f	\N	2003
9efc7324-032e-428a-a0af-d83f0c57c7aa	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:43:09.184939+00	2023-12-22 09:43:13.18516+00	\N	2023-12-22 09:43:00	00:15:00	2023-12-22 09:43:09.184939+00	2023-12-22 09:43:13.192929+00	2023-12-22 09:44:09.184939+00	f	\N	\N
422b0ae9-f973-4e61-bf6f-2335daa5d203	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2023-12-22 09:43:39.220148+00	2023-12-22 09:43:41.203282+00	1	\N	00:15:00	2023-12-22 09:41:12.517726+00	2023-12-22 09:43:41.32994+00	2024-01-05 09:41:12.517726+00	f	\N	3034
2947220e-472c-4e38-8a1f-86762d6c8063	pool-rewards	0	{"epochNo": 2}	completed	1000000	2	30	f	2023-12-22 09:44:11.208523+00	2023-12-22 09:44:11.216155+00	2	\N	00:15:00	2023-12-22 09:42:55.813254+00	2023-12-22 09:44:11.342712+00	2024-01-05 09:42:55.813254+00	f	\N	4009
86464ff6-17ad-4cf7-84f5-4c9c2593de65	pool-metrics	0	{"slot": 3473}	completed	0	0	0	f	2023-12-22 09:41:12.583135+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.583135+00	2023-12-22 09:43:09.523515+00	2024-01-05 09:41:12.583135+00	f	\N	3473
71eee0d1-7335-4cfd-84ed-66df59414cd7	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:51:01.370588+00	2023-12-22 09:51:01.385929+00	\N	2023-12-22 09:51:00	00:15:00	2023-12-22 09:50:01.370588+00	2023-12-22 09:51:01.39878+00	2023-12-22 09:52:01.370588+00	f	\N	\N
a0308f2f-d473-4e2c-83e7-0a2255c02cc9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 09:45:09.19077+00	2023-12-22 09:46:09.180061+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:43:09.19077+00	2023-12-22 09:46:09.192196+00	2023-12-22 09:53:09.19077+00	f	\N	\N
c4fbd3cc-2618-4507-9308-29036c399ac1	pool-rewards	0	{"epochNo": 10}	completed	1000000	0	30	f	2023-12-22 10:09:34.41945+00	2023-12-22 10:09:35.992219+00	10	\N	00:15:00	2023-12-22 10:09:34.41945+00	2023-12-22 10:09:36.096289+00	2024-01-05 10:09:34.41945+00	f	\N	12002
fa577a92-1b43-40b0-9576-5d00ff83ae11	pool-rewards	0	{"epochNo": 16}	completed	1000000	0	30	f	2023-12-22 10:29:35.426318+00	2023-12-22 10:29:36.603128+00	16	\N	00:15:00	2023-12-22 10:29:35.426318+00	2023-12-22 10:29:36.754076+00	2024-01-05 10:29:35.426318+00	f	\N	18007
9a3ebb84-2afa-408a-a194-90b14401d9c2	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:53:01.423887+00	2023-12-22 09:53:01.44248+00	\N	2023-12-22 09:53:00	00:15:00	2023-12-22 09:52:01.423887+00	2023-12-22 09:53:01.456286+00	2023-12-22 09:54:01.423887+00	f	\N	\N
177cef3e-ad8e-452c-858b-64949549407a	pool-rewards	0	{"epochNo": 11}	completed	1000000	0	30	f	2023-12-22 10:12:58.233957+00	2023-12-22 10:13:00.091732+00	11	\N	00:15:00	2023-12-22 10:12:58.233957+00	2023-12-22 10:13:00.194508+00	2024-01-05 10:12:58.233957+00	f	\N	13021
4118a3c3-d812-4b21-8b4f-d56372807594	pool-rewards	0	{"epochNo": 12}	completed	1000000	0	30	f	2023-12-22 10:16:14.623607+00	2023-12-22 10:16:16.185658+00	12	\N	00:15:00	2023-12-22 10:16:14.623607+00	2023-12-22 10:16:16.271377+00	2024-01-05 10:16:14.623607+00	f	\N	14003
a9ea59f2-ce6d-4500-91df-d120251f1e4c	pool-metadata	0	{"poolId": "pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "4020000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.233497+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.040653+00	\N	2024-01-05 09:41:12.040653+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	402
be005625-2575-41e8-af0a-a8e5113b23b9	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:52:01.395973+00	2023-12-22 09:52:01.413336+00	\N	2023-12-22 09:52:00	00:15:00	2023-12-22 09:51:01.395973+00	2023-12-22 09:52:01.426631+00	2023-12-22 09:53:01.395973+00	f	\N	\N
64680fb3-d164-4853-bc7b-193d0241acb2	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:11:01.900319+00	2023-12-22 10:11:01.913159+00	\N	2023-12-22 10:11:00	00:15:00	2023-12-22 10:10:01.900319+00	2023-12-22 10:11:01.926055+00	2023-12-22 10:12:01.900319+00	f	\N	\N
7733036e-653a-4e23-ac6f-423f2e871f40	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:31:01.375795+00	2023-12-22 10:31:02.393818+00	\N	2023-12-22 10:31:00	00:15:00	2023-12-22 10:30:02.375795+00	2023-12-22 10:31:02.405561+00	2023-12-22 10:32:01.375795+00	f	\N	\N
20de0fbf-4d81-493d-93bd-09617248e714	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:55:01.477743+00	2023-12-22 09:55:01.49631+00	\N	2023-12-22 09:55:00	00:15:00	2023-12-22 09:54:01.477743+00	2023-12-22 09:55:01.502899+00	2023-12-22 09:56:01.477743+00	f	\N	\N
4fbb3f58-7b3c-453b-9440-4180facde113	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:15:09.230689+00	2023-12-22 10:16:09.217381+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:13:09.230689+00	2023-12-22 10:16:09.228884+00	2023-12-22 10:23:09.230689+00	f	\N	\N
4089ffce-67ba-4e00-8c7e-df128500f746	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:56:01.501277+00	2023-12-22 09:56:01.519009+00	\N	2023-12-22 09:56:00	00:15:00	2023-12-22 09:55:01.501277+00	2023-12-22 09:56:01.534745+00	2023-12-22 09:57:01.501277+00	f	\N	\N
cf84ae08-a9f6-4f0a-88f3-1272fce55216	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 09:57:09.201914+00	2023-12-22 09:58:09.200478+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:55:09.201914+00	2023-12-22 09:58:09.212791+00	2023-12-22 10:05:09.201914+00	f	\N	\N
24403ab3-3cbe-4fa0-a9de-0ceb38ce9da4	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:18:01.069297+00	2023-12-22 10:18:02.084453+00	\N	2023-12-22 10:18:00	00:15:00	2023-12-22 10:17:02.069297+00	2023-12-22 10:18:02.095462+00	2023-12-22 10:19:01.069297+00	f	\N	\N
7c9811ba-638b-4cf4-91bf-74898399cee0	pool-metadata	0	{"poolId": "pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "4830000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.234309+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.056293+00	\N	2024-01-05 09:41:12.056293+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	483
16cf55da-692e-4b43-b3e4-b5f528c8c25c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:32:01.402898+00	2023-12-22 10:32:02.421902+00	\N	2023-12-22 10:32:00	00:15:00	2023-12-22 10:31:02.402898+00	2023-12-22 10:32:02.435562+00	2023-12-22 10:33:01.402898+00	f	\N	\N
1eeb3508-8706-40ba-b824-730d7b50bd21	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:54:01.453624+00	2023-12-22 09:54:01.468303+00	\N	2023-12-22 09:54:00	00:15:00	2023-12-22 09:53:01.453624+00	2023-12-22 09:54:01.480387+00	2023-12-22 09:55:01.453624+00	f	\N	\N
8625b3d7-14ae-4f85-8a56-15a614e2274c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:13:01.951408+00	2023-12-22 10:13:01.963398+00	\N	2023-12-22 10:13:00	00:15:00	2023-12-22 10:12:01.951408+00	2023-12-22 10:13:01.974823+00	2023-12-22 10:14:01.951408+00	f	\N	\N
863d3616-aef1-46ea-84bc-85d6e66d9251	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 09:54:09.207332+00	2023-12-22 09:55:09.193589+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:52:09.207332+00	2023-12-22 09:55:09.200123+00	2023-12-22 10:02:09.207332+00	f	\N	\N
f0470e12-1089-4439-bcb8-16d6ddeec0ec	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:12:09.220474+00	2023-12-22 10:13:09.214183+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:10:09.220474+00	2023-12-22 10:13:09.22734+00	2023-12-22 10:20:09.220474+00	f	\N	\N
d833e27d-7e06-4bca-b886-e6361b35a9f0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:36:09.233418+00	2023-12-22 10:37:09.230393+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:34:09.233418+00	2023-12-22 10:37:09.238795+00	2023-12-22 10:44:09.233418+00	f	\N	\N
4f7b68b8-5a96-478f-bb92-3af4b0681b16	pool-metadata	0	{"poolId": "pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "6970000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.240941+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.091843+00	\N	2024-01-05 09:41:12.091843+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	697
9f7b6c2b-61ae-4418-af7e-2b77afa1a240	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:45:01.212466+00	2023-12-22 09:45:01.239067+00	\N	2023-12-22 09:45:00	00:15:00	2023-12-22 09:44:01.212466+00	2023-12-22 09:45:01.255119+00	2023-12-22 09:46:01.212466+00	f	\N	\N
c38e4089-3917-4915-bff2-31c183459d5b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:57:01.531647+00	2023-12-22 09:57:01.548339+00	\N	2023-12-22 09:57:00	00:15:00	2023-12-22 09:56:01.531647+00	2023-12-22 09:57:01.560397+00	2023-12-22 09:58:01.531647+00	f	\N	\N
54c5e61f-6b05-471f-a9c1-778113c3a267	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:12:01.923136+00	2023-12-22 10:12:01.939905+00	\N	2023-12-22 10:12:00	00:15:00	2023-12-22 10:11:01.923136+00	2023-12-22 10:12:01.954412+00	2023-12-22 10:13:01.923136+00	f	\N	\N
743609f4-1948-48d4-a132-e2379b48602a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:03:01.693715+00	2023-12-22 10:03:01.713944+00	\N	2023-12-22 10:03:00	00:15:00	2023-12-22 10:02:01.693715+00	2023-12-22 10:03:01.72663+00	2023-12-22 10:04:01.693715+00	f	\N	\N
27a47b29-033c-47f4-bd5b-d5236152bc50	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:34:01.453663+00	2023-12-22 10:34:02.465805+00	\N	2023-12-22 10:34:00	00:15:00	2023-12-22 10:33:02.453663+00	2023-12-22 10:34:02.478874+00	2023-12-22 10:35:01.453663+00	f	\N	\N
a7c1562a-6be4-436b-ba9c-35cf5dd49d86	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:14:01.972081+00	2023-12-22 10:14:01.990406+00	\N	2023-12-22 10:14:00	00:15:00	2023-12-22 10:13:01.972081+00	2023-12-22 10:14:02.00471+00	2023-12-22 10:15:01.972081+00	f	\N	\N
a1e316c0-4d0f-4d46-b3ed-04f4bddf9ff3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:33:09.244388+00	2023-12-22 10:34:09.228758+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:31:09.244388+00	2023-12-22 10:34:09.232182+00	2023-12-22 10:41:09.244388+00	f	\N	\N
ac554f2c-fd2b-44c7-82d7-761872415514	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:05:01.751825+00	2023-12-22 10:05:01.763007+00	\N	2023-12-22 10:05:00	00:15:00	2023-12-22 10:04:01.751825+00	2023-12-22 10:05:01.775728+00	2023-12-22 10:06:01.751825+00	f	\N	\N
bc95359a-c8c9-44b6-a598-902afeab8b19	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:15:01.001791+00	2023-12-22 10:15:02.016725+00	\N	2023-12-22 10:15:00	00:15:00	2023-12-22 10:14:02.001791+00	2023-12-22 10:15:02.030203+00	2023-12-22 10:16:01.001791+00	f	\N	\N
c8d72349-0bb3-4c61-9238-45973fb3eb0e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:06:01.773036+00	2023-12-22 10:06:01.790291+00	\N	2023-12-22 10:06:00	00:15:00	2023-12-22 10:05:01.773036+00	2023-12-22 10:06:01.800835+00	2023-12-22 10:07:01.773036+00	f	\N	\N
9c42f08c-9fee-4d72-af7e-373613ba4c5e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:06:09.220311+00	2023-12-22 10:07:09.209466+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:04:09.220311+00	2023-12-22 10:07:09.220248+00	2023-12-22 10:14:09.220311+00	f	\N	\N
564dd678-f43c-4e3a-b7b7-882c0fc918db	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:37:01.525225+00	2023-12-22 10:37:02.536593+00	\N	2023-12-22 10:37:00	00:15:00	2023-12-22 10:36:02.525225+00	2023-12-22 10:37:02.549632+00	2023-12-22 10:38:01.525225+00	f	\N	\N
cee0afe7-a4e9-4b1e-af56-3c5d56a94a86	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:38:01.546694+00	2023-12-22 10:38:02.559236+00	\N	2023-12-22 10:38:00	00:15:00	2023-12-22 10:37:02.546694+00	2023-12-22 10:38:02.573383+00	2023-12-22 10:39:01.546694+00	f	\N	\N
7d19db12-41da-4ff6-93b2-55f243452fde	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:39:09.24153+00	2023-12-22 10:40:09.232838+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:37:09.24153+00	2023-12-22 10:40:09.24542+00	2023-12-22 10:47:09.24153+00	f	\N	\N
ae1ba53a-8993-43e2-891a-1ff0b45e4b39	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:41:01.617574+00	2023-12-22 10:41:02.629449+00	\N	2023-12-22 10:41:00	00:15:00	2023-12-22 10:40:02.617574+00	2023-12-22 10:41:02.640891+00	2023-12-22 10:42:01.617574+00	f	\N	\N
643b7a72-34ec-4172-9791-8cd558fac277	pool-metadata	0	{"poolId": "pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "7670000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.242459+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.107849+00	\N	2024-01-05 09:41:12.107849+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	767
5b473db1-b6d8-4f5a-ac67-f26a2cb6bfe4	pool-rewards	0	{"epochNo": 6}	completed	1000000	0	30	f	2023-12-22 09:56:16.428685+00	2023-12-22 09:56:17.581849+00	6	\N	00:15:00	2023-12-22 09:56:16.428685+00	2023-12-22 09:56:17.701879+00	2024-01-05 09:56:16.428685+00	f	\N	8012
0613d740-3f8a-44de-aa35-9a5a232ba663	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:19:01.092675+00	2023-12-22 10:19:02.109241+00	\N	2023-12-22 10:19:00	00:15:00	2023-12-22 10:18:02.092675+00	2023-12-22 10:19:02.123678+00	2023-12-22 10:20:01.092675+00	f	\N	\N
c3159ba7-eb59-47b1-b309-0d8cc142fc4e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:33:01.43269+00	2023-12-22 10:33:02.44451+00	\N	2023-12-22 10:33:00	00:15:00	2023-12-22 10:32:02.43269+00	2023-12-22 10:33:02.456226+00	2023-12-22 10:34:01.43269+00	f	\N	\N
a9ac5843-b67e-488f-a176-8fd7ea97ed1f	pool-rewards	0	{"epochNo": 7}	completed	1000000	0	30	f	2023-12-22 09:59:38.42572+00	2023-12-22 09:59:39.663647+00	7	\N	00:15:00	2023-12-22 09:59:38.42572+00	2023-12-22 09:59:39.798272+00	2024-01-05 09:59:38.42572+00	f	\N	9022
24965688-0650-40b1-ad59-63cc980160fc	pool-rewards	0	{"epochNo": 8}	completed	1000000	0	30	f	2023-12-22 10:02:54.829758+00	2023-12-22 10:02:55.774037+00	8	\N	00:15:00	2023-12-22 10:02:54.829758+00	2023-12-22 10:02:55.897238+00	2024-01-05 10:02:54.829758+00	f	\N	10004
1ec28dd6-a96c-45e0-8ec9-a9ea3b0cff17	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:21:01.146071+00	2023-12-22 10:21:02.160219+00	\N	2023-12-22 10:21:00	00:15:00	2023-12-22 10:20:02.146071+00	2023-12-22 10:21:02.171367+00	2023-12-22 10:22:01.146071+00	f	\N	\N
88dd2d39-ebce-4446-b079-66784e2ecce4	pool-metrics	0	{"slot": 10036}	completed	0	0	0	f	2023-12-22 10:03:01.233915+00	2023-12-22 10:03:01.776635+00	\N	\N	00:15:00	2023-12-22 10:03:01.233915+00	2023-12-22 10:03:01.969681+00	2024-01-05 10:03:01.233915+00	f	\N	10036
e4608fb9-6ba4-4fcc-8eb1-d94567873399	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:22:01.168821+00	2023-12-22 10:22:02.184697+00	\N	2023-12-22 10:22:00	00:15:00	2023-12-22 10:21:02.168821+00	2023-12-22 10:22:02.200087+00	2023-12-22 10:23:01.168821+00	f	\N	\N
0abec771-5d70-48a5-bca8-894779dc300b	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:35:01.475775+00	2023-12-22 10:35:02.490846+00	\N	2023-12-22 10:35:00	00:15:00	2023-12-22 10:34:02.475775+00	2023-12-22 10:35:02.503521+00	2023-12-22 10:36:01.475775+00	f	\N	\N
9d5a7e8c-a440-4c92-b802-fda65ff6067f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:24:09.237548+00	2023-12-22 10:25:09.22442+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:22:09.237548+00	2023-12-22 10:25:09.235474+00	2023-12-22 10:32:09.237548+00	f	\N	\N
a5d8a816-c551-46b5-be2a-ca9fed2ccde0	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:36:01.50061+00	2023-12-22 10:36:02.514205+00	\N	2023-12-22 10:36:00	00:15:00	2023-12-22 10:35:02.50061+00	2023-12-22 10:36:02.52838+00	2023-12-22 10:37:01.50061+00	f	\N	\N
e319115e-ddea-4e81-b2ea-6324f9e77228	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:27:09.238408+00	2023-12-22 10:28:09.225882+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:25:09.238408+00	2023-12-22 10:28:09.237574+00	2023-12-22 10:35:09.238408+00	f	\N	\N
a52e6b26-e1c6-41ba-a002-01e9ac65d47f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:42:01.638036+00	2023-12-22 10:42:02.652818+00	\N	2023-12-22 10:42:00	00:15:00	2023-12-22 10:41:02.638036+00	2023-12-22 10:42:02.664689+00	2023-12-22 10:43:01.638036+00	f	\N	\N
96ed43cd-747c-4d1f-a4a2-6bf54cb35897	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:43:01.662073+00	2023-12-22 10:43:02.676123+00	\N	2023-12-22 10:43:00	00:15:00	2023-12-22 10:42:02.662073+00	2023-12-22 10:43:02.687254+00	2023-12-22 10:44:01.662073+00	f	\N	\N
fa92cf60-56e0-47c9-8070-331705d72bbe	pool-metadata	0	{"poolId": "pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "5860000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.243558+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.071779+00	\N	2024-01-05 09:41:12.071779+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	586
7f05ec3c-6a11-4329-b564-4e3bef02e0a1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:44:01.191384+00	2023-12-22 09:44:01.205646+00	\N	2023-12-22 09:44:00	00:15:00	2023-12-22 09:43:13.191384+00	2023-12-22 09:44:01.214327+00	2023-12-22 09:45:01.191384+00	f	\N	\N
ccfa426f-0040-4302-88e9-0f55e0b2a27f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:58:01.557499+00	2023-12-22 09:58:01.576886+00	\N	2023-12-22 09:58:00	00:15:00	2023-12-22 09:57:01.557499+00	2023-12-22 09:58:01.590341+00	2023-12-22 09:59:01.557499+00	f	\N	\N
8fa9f720-1b68-4d0e-a51f-86854d520416	pool-rewards	0	{"epochNo": 17}	completed	1000000	0	30	f	2023-12-22 10:32:55.632651+00	2023-12-22 10:32:56.70129+00	17	\N	00:15:00	2023-12-22 10:32:55.632651+00	2023-12-22 10:32:56.83093+00	2024-01-05 10:32:55.632651+00	f	\N	19008
3050ed5d-23e8-451c-a8d8-463f6cf78df5	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:20:01.120563+00	2023-12-22 10:20:02.134451+00	\N	2023-12-22 10:20:00	00:15:00	2023-12-22 10:19:02.120563+00	2023-12-22 10:20:02.148865+00	2023-12-22 10:21:01.120563+00	f	\N	\N
49b51da8-de8f-4106-88f4-297e885c0eb3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:21:09.232855+00	2023-12-22 10:22:09.222438+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:19:09.232855+00	2023-12-22 10:22:09.234561+00	2023-12-22 10:29:09.232855+00	f	\N	\N
69080f46-113b-4961-9a28-29e362c8d90c	pool-rewards	0	{"epochNo": 18}	completed	1000000	0	30	f	2023-12-22 10:36:14.432163+00	2023-12-22 10:36:14.813228+00	18	\N	00:15:00	2023-12-22 10:36:14.432163+00	2023-12-22 10:36:14.954622+00	2024-01-05 10:36:14.432163+00	f	\N	20002
70a78973-55a8-42f1-99e1-02db1e920623	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:27:01.287986+00	2023-12-22 10:27:02.302541+00	\N	2023-12-22 10:27:00	00:15:00	2023-12-22 10:26:02.287986+00	2023-12-22 10:27:02.315645+00	2023-12-22 10:28:01.287986+00	f	\N	\N
8883b6e2-67e4-4499-8db5-674e784cde71	pool-metrics	0	{"slot": 20085}	completed	0	0	0	f	2023-12-22 10:36:31.011942+00	2023-12-22 10:36:32.823023+00	\N	\N	00:15:00	2023-12-22 10:36:31.011942+00	2023-12-22 10:36:33.002082+00	2024-01-05 10:36:31.011942+00	f	\N	20085
d8454b11-be22-446d-be86-ee25085d2ea3	pool-rewards	0	{"epochNo": 19}	completed	1000000	0	30	f	2023-12-22 10:39:40.215302+00	2023-12-22 10:39:40.935985+00	19	\N	00:15:00	2023-12-22 10:39:40.215302+00	2023-12-22 10:39:41.060755+00	2024-01-05 10:39:40.215302+00	f	\N	21031
991f78cc-868d-4379-a8b4-df8cfb2b03ae	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:59:01.587521+00	2023-12-22 09:59:01.602476+00	\N	2023-12-22 09:59:00	00:15:00	2023-12-22 09:58:01.587521+00	2023-12-22 09:59:01.615739+00	2023-12-22 10:00:01.587521+00	f	\N	\N
8dce3474-8565-442e-aead-e1122262b0e7	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:46:01.252475+00	2023-12-22 09:46:01.258264+00	\N	2023-12-22 09:46:00	00:15:00	2023-12-22 09:45:01.252475+00	2023-12-22 09:46:01.270544+00	2023-12-22 09:47:01.252475+00	f	\N	\N
1665a1fc-9611-404a-9c66-428344ec5203	pool-rewards	0	{"epochNo": 13}	completed	1000000	0	30	f	2023-12-22 10:19:34.238408+00	2023-12-22 10:19:34.282092+00	13	\N	00:15:00	2023-12-22 10:19:34.238408+00	2023-12-22 10:19:34.383826+00	2024-01-05 10:19:34.238408+00	f	\N	15001
58ca8017-9aba-4f85-8338-bf78db7784ac	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:47:01.267649+00	2023-12-22 09:47:01.283767+00	\N	2023-12-22 09:47:00	00:15:00	2023-12-22 09:46:01.267649+00	2023-12-22 09:47:01.29171+00	2023-12-22 09:48:01.267649+00	f	\N	\N
023adc37-554c-4982-b3bb-19f84d82677e	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:01:01.637116+00	2023-12-22 10:01:01.652291+00	\N	2023-12-22 10:01:00	00:15:00	2023-12-22 10:00:01.637116+00	2023-12-22 10:01:01.664134+00	2023-12-22 10:02:01.637116+00	f	\N	\N
ec1bcdc1-ba7f-4193-b809-d67f33762bda	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:39:01.570384+00	2023-12-22 10:39:02.581713+00	\N	2023-12-22 10:39:00	00:15:00	2023-12-22 10:38:02.570384+00	2023-12-22 10:39:02.591177+00	2023-12-22 10:40:01.570384+00	f	\N	\N
168491f3-fdc6-43a3-89aa-61aa5a1cf583	pool-rewards	0	{"epochNo": 14}	completed	1000000	0	30	f	2023-12-22 10:22:54.418588+00	2023-12-22 10:22:56.387948+00	14	\N	00:15:00	2023-12-22 10:22:54.418588+00	2023-12-22 10:22:56.527828+00	2024-01-05 10:22:54.418588+00	f	\N	16002
f3b79f8f-3e41-4ce3-a07f-9aa73dc2ccf7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:03:09.219859+00	2023-12-22 10:04:09.20721+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:01:09.219859+00	2023-12-22 10:04:09.217732+00	2023-12-22 10:11:09.219859+00	f	\N	\N
81169b79-95ac-47ac-8fd3-51785a90bf81	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:40:01.588979+00	2023-12-22 10:40:02.608627+00	\N	2023-12-22 10:40:00	00:15:00	2023-12-22 10:39:02.588979+00	2023-12-22 10:40:02.620626+00	2023-12-22 10:41:01.588979+00	f	\N	\N
65902af2-77e6-41d7-948f-587e2d41082e	pool-rewards	0	{"epochNo": 15}	completed	1000000	0	30	f	2023-12-22 10:26:20.627599+00	2023-12-22 10:26:22.50449+00	15	\N	00:15:00	2023-12-22 10:26:20.627599+00	2023-12-22 10:26:22.599397+00	2024-01-05 10:26:20.627599+00	f	\N	17033
baaa7471-dbb9-49d6-b2bb-87e3b246b9ae	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:42:09.248386+00	2023-12-22 10:43:09.233131+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:40:09.248386+00	2023-12-22 10:43:09.244542+00	2023-12-22 10:50:09.248386+00	f	\N	\N
1b885471-df12-4c9d-a045-87aa3890d4f9	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:50:01.34654+00	2023-12-22 09:50:01.360901+00	\N	2023-12-22 09:50:00	00:15:00	2023-12-22 09:49:01.34654+00	2023-12-22 09:50:01.373395+00	2023-12-22 09:51:01.34654+00	f	\N	\N
89443a0b-73bf-438b-aafe-72ef9b26efc0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 09:48:09.19479+00	2023-12-22 09:49:09.184533+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:46:09.19479+00	2023-12-22 09:49:09.198311+00	2023-12-22 09:56:09.19479+00	f	\N	\N
4ac201ab-7de3-441a-8d16-73bc3afba7d7	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:23:01.196791+00	2023-12-22 10:23:02.207821+00	\N	2023-12-22 10:23:00	00:15:00	2023-12-22 10:22:02.196791+00	2023-12-22 10:23:02.220655+00	2023-12-22 10:24:01.196791+00	f	\N	\N
155f727e-2eec-4539-ba96-e5b3cdae9e44	pool-rewards	0	{"epochNo": 20}	completed	1000000	0	30	f	2023-12-22 10:42:55.426075+00	2023-12-22 10:42:57.041144+00	20	\N	00:15:00	2023-12-22 10:42:55.426075+00	2023-12-22 10:42:57.169213+00	2024-01-05 10:42:55.426075+00	f	\N	22007
ab9c3694-6bdd-4a79-99e4-0db900176cd8	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:00:01.612954+00	2023-12-22 10:00:01.627001+00	\N	2023-12-22 10:00:00	00:15:00	2023-12-22 09:59:01.612954+00	2023-12-22 10:00:01.639798+00	2023-12-22 10:01:01.612954+00	f	\N	\N
4ff66294-5f6a-4516-9d24-ba26137047d5	pool-rewards	0	{"epochNo": 21}	completed	1000000	0	30	f	2023-12-22 10:46:14.424366+00	2023-12-22 10:46:15.154692+00	21	\N	00:15:00	2023-12-22 10:46:14.424366+00	2023-12-22 10:46:15.301326+00	2024-01-05 10:46:14.424366+00	f	\N	23002
ddfefb29-3242-47a7-9c82-9d69f709cd77	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:00:09.216017+00	2023-12-22 10:01:09.204057+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:58:09.216017+00	2023-12-22 10:01:09.216791+00	2023-12-22 10:08:09.216017+00	f	\N	\N
511b7c69-6801-49e5-a986-149b14ce0d34	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:02:01.661203+00	2023-12-22 10:02:01.681884+00	\N	2023-12-22 10:02:00	00:15:00	2023-12-22 10:01:01.661203+00	2023-12-22 10:02:01.696697+00	2023-12-22 10:03:01.661203+00	f	\N	\N
73ea3c43-290e-48ec-99c0-5ad5724f51f1	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:04:01.723884+00	2023-12-22 10:04:01.740716+00	\N	2023-12-22 10:04:00	00:15:00	2023-12-22 10:03:01.723884+00	2023-12-22 10:04:01.754899+00	2023-12-22 10:05:01.723884+00	f	\N	\N
9b6b3aaf-1bb6-44ec-add2-30fa0f4e80cc	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:07:01.798095+00	2023-12-22 10:07:01.813996+00	\N	2023-12-22 10:07:00	00:15:00	2023-12-22 10:06:01.798095+00	2023-12-22 10:07:01.827938+00	2023-12-22 10:08:01.798095+00	f	\N	\N
76562159-9445-4357-8ca5-14e95097a348	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:29:01.395821+00	2023-12-22 10:29:02.347961+00	\N	2023-12-22 10:29:00	00:15:00	2023-12-22 10:28:02.395821+00	2023-12-22 10:29:02.356438+00	2023-12-22 10:30:01.395821+00	f	\N	\N
172790ff-6982-49ea-bdd7-8487c14ab4e0	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2023-12-22 09:46:16.432267+00	2023-12-22 09:46:17.278366+00	3	\N	00:15:00	2023-12-22 09:46:16.432267+00	2023-12-22 09:46:17.406975+00	2024-01-05 09:46:16.432267+00	f	\N	5012
a8ea9e88-c510-499d-8a9d-44e48f6540b2	pool-rewards	0	{"epochNo": 9}	completed	1000000	0	30	f	2023-12-22 10:06:14.009963+00	2023-12-22 10:06:15.878646+00	9	\N	00:15:00	2023-12-22 10:06:14.009963+00	2023-12-22 10:06:16.013975+00	2024-01-05 10:06:14.009963+00	f	\N	11000
a3404eb8-fb68-4472-b6b7-4f1ac72f46b7	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:24:01.217817+00	2023-12-22 10:24:02.229806+00	\N	2023-12-22 10:24:00	00:15:00	2023-12-22 10:23:02.217817+00	2023-12-22 10:24:02.23976+00	2023-12-22 10:25:01.217817+00	f	\N	\N
8258122b-8f67-4c70-9d1a-5fe08ca8902b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:30:09.240788+00	2023-12-22 10:31:09.228831+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:28:09.240788+00	2023-12-22 10:31:09.240807+00	2023-12-22 10:38:09.240788+00	f	\N	\N
85897a03-8c70-4b63-9a79-0c34eee1634d	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:25:01.238079+00	2023-12-22 10:25:02.253434+00	\N	2023-12-22 10:25:00	00:15:00	2023-12-22 10:24:02.238079+00	2023-12-22 10:25:02.258805+00	2023-12-22 10:26:01.238079+00	f	\N	\N
267333ee-8d26-4c4b-9d9e-4deffb923ab6	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:26:01.257126+00	2023-12-22 10:26:02.276309+00	\N	2023-12-22 10:26:00	00:15:00	2023-12-22 10:25:02.257126+00	2023-12-22 10:26:02.291104+00	2023-12-22 10:27:01.257126+00	f	\N	\N
a9bf2855-3568-49d4-bcfa-f3aab4d11142	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:44:01.684536+00	2023-12-22 10:44:02.697509+00	\N	2023-12-22 10:44:00	00:15:00	2023-12-22 10:43:02.684536+00	2023-12-22 10:44:02.71142+00	2023-12-22 10:45:01.684536+00	f	\N	\N
81fd7f56-8d57-4551-9e86-abf51b613938	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:28:01.313081+00	2023-12-22 10:28:02.326501+00	\N	2023-12-22 10:28:00	00:15:00	2023-12-22 10:27:02.313081+00	2023-12-22 10:28:02.3985+00	2023-12-22 10:29:01.313081+00	f	\N	\N
3769587d-5830-4a20-90c8-6e68e6e5ed05	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:46:01.729708+00	2023-12-22 10:46:02.742571+00	\N	2023-12-22 10:46:00	00:15:00	2023-12-22 10:45:02.729708+00	2023-12-22 10:46:02.754968+00	2023-12-22 10:47:01.729708+00	f	\N	\N
1ebf2863-cc79-4655-b446-9fec9b44903a	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:48:01.290193+00	2023-12-22 09:48:01.313576+00	\N	2023-12-22 09:48:00	00:15:00	2023-12-22 09:47:01.290193+00	2023-12-22 09:48:01.329481+00	2023-12-22 09:49:01.290193+00	f	\N	\N
fd14d5e1-793b-4686-8b76-8487dcbe8a70	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:08:01.825204+00	2023-12-22 10:08:01.837722+00	\N	2023-12-22 10:08:00	00:15:00	2023-12-22 10:07:01.825204+00	2023-12-22 10:08:01.85331+00	2023-12-22 10:09:01.825204+00	f	\N	\N
fbd1aeb5-8d77-4e3f-a034-904a6571e522	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:45:09.247695+00	2023-12-22 10:46:09.234987+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:43:09.247695+00	2023-12-22 10:46:09.245306+00	2023-12-22 10:53:09.247695+00	f	\N	\N
d8be3d38-7232-4e58-8812-e9f17a1177f0	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:48:01.776053+00	2023-12-22 10:48:02.793436+00	\N	2023-12-22 10:48:00	00:15:00	2023-12-22 10:47:02.776053+00	2023-12-22 10:48:02.799294+00	2023-12-22 10:49:01.776053+00	f	\N	\N
0c427397-5785-4116-bde7-a5b96dfaff9f	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 09:49:01.326401+00	2023-12-22 09:49:01.33772+00	\N	2023-12-22 09:49:00	00:15:00	2023-12-22 09:48:01.326401+00	2023-12-22 09:49:01.349363+00	2023-12-22 09:50:01.326401+00	f	\N	\N
cf770cf9-9933-4ab9-b29a-90f711ef0e36	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 10:09:09.223257+00	2023-12-22 10:10:09.212173+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:07:09.223257+00	2023-12-22 10:10:09.218268+00	2023-12-22 10:17:09.223257+00	f	\N	\N
9611a468-6552-4a21-9df3-816553002982	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:45:01.708404+00	2023-12-22 10:45:02.719195+00	\N	2023-12-22 10:45:00	00:15:00	2023-12-22 10:44:02.708404+00	2023-12-22 10:45:02.732414+00	2023-12-22 10:46:01.708404+00	f	\N	\N
c2df3697-ab64-466b-8819-08cdf9ad768c	__pgboss__cron	0	\N	completed	2	0	0	f	2023-12-22 10:47:01.751841+00	2023-12-22 10:47:02.766129+00	\N	2023-12-22 10:47:00	00:15:00	2023-12-22 10:46:02.751841+00	2023-12-22 10:47:02.779453+00	2023-12-22 10:48:01.751841+00	f	\N	\N
c243b85b-245f-4c47-82a2-1b953269aecd	__pgboss__maintenance	0	\N	created	0	0	0	f	2023-12-22 10:48:09.247952+00	\N	__pgboss__maintenance	\N	00:15:00	2023-12-22 10:46:09.247952+00	\N	2023-12-22 10:56:09.247952+00	f	\N	\N
18c57a49-5f3e-49ef-be80-30424ff966f4	__pgboss__cron	0	\N	created	2	0	0	f	2023-12-22 10:49:01.797471+00	\N	\N	2023-12-22 10:49:00	00:15:00	2023-12-22 10:48:02.797471+00	\N	2023-12-22 10:50:01.797471+00	f	\N	\N
61f7b19b-a57a-4e93-b6d5-faf339dd79a0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2023-12-22 09:51:09.201597+00	2023-12-22 09:52:09.189902+00	__pgboss__maintenance	\N	00:15:00	2023-12-22 09:49:09.201597+00	2023-12-22 09:52:09.202522+00	2023-12-22 09:59:09.201597+00	f	\N	\N
f7b65eb3-c1d7-40ce-b531-06b840e803db	pool-metadata	0	{"poolId": "pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "12450000000000"}	retry	1000000	0	21600	f	2023-12-22 15:43:09.235353+00	2023-12-22 09:43:09.190308+00	\N	\N	00:15:00	2023-12-22 09:41:12.225301+00	\N	2024-01-05 09:41:12.225301+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	1245
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
20	2023-12-22 10:46:09.243921+00	2023-12-22 10:48:02.795607+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	feb0fa350bb7763cc9038ad240ee28fcb122ecd2c0d59626ae354cdb8b78c124	7
1	3666ea5b3efd53917493954f78bb3f41538cd23350f06f14cbdd3cdcf0d41aa1	14
2	9f60092786318288f37bc1e5b72efe7dfa6e9e73bb27ea40eaa3afff1aa933be	17
3	b885d632eb72a03573e6593832930adc4d8049795da61e775cb363d6e417f17c	24
4	cb11560466c56b4202cc4398bb349b033587a92c7fac291de45b79355bc50407	31
5	29fdcd28ca0e8cbda86641fdbe8afb5d38660a7540762cfe1d60274fa0880957	37
6	d72791424293d0b794952afc178766dd5fa79c43aa5e8ca8c542050e725ae0ba	38
7	e33d0b3ce6a436a8a7d0872d4c8422cb600581aafda4341f88b8129b06e3d8d4	48
8	6594d4f976b75a3adc65eeb6510a8aa1f72ce6047e5bc76d61ca138ee918739b	92
9	1c101c3cfa3c99f820f4f6a6b451c7bb9f1ee1cd36ce6139ce99b4962036b1d9	94
10	46ab41a663ed7bf0b0c79c1ca758f0db9495dad4edfe21ce0ac9bf77e66d197e	108
11	7495718390cb467278648d53e7d7a7783134a5b93ee18d6eaeff82c5469bf572	118
12	f1518842df65159edd7d4f2d466ecf1de5cfb5100d85ec36dc790ef34b002455	122
13	dc622aa92353124328b7e7229e2bacc0fafd17f38e95db34d4c3e1df2fdfa1d8	124
14	5f9ed46faeb137a479ac0064156c32fb4b0648a770c9ce590d3fecff27d9ced7	130
15	a8d79c5236a35c8355039ba9ed7a15b7ee2a878ab4b5373239275173157c76c1	132
16	4a2993c3730491ffb7f7f9bcac32ac47aae54ee7496bf01e1aae38b2890358c4	146
17	1f02f0959b7479e4ae8a8e252bb37a82d13f8bdb11b5f72fa622af197c290e95	149
18	5105c91b3879ad81dbb1f044cacdccbf5ed87e7e479ba955e295069c5c65b2a1	154
19	d9ed5e15a0bab7f2d1c208b5b079bb32f2c393cd0fc94f220c7757ee8792e338	161
20	026d2494f94e07fe65553d765f9dd9eb4f6e98301baae74570dc66f8d4b410ab	184
21	91467c1230d298fdad9828df3d044e163e8a0e07b588580beb3571007c4d3306	189
22	2ee9f1a18f1012e1d6a4a4e9fba4bad72b07f640648b57b62be059793e6be3af	200
23	d326f312ffe35166457e507bc24e1cc23bc0820936960499b133c23ef9dd9dc4	206
24	509fb1794a8c333408d2e2292b47f0be49f228f5327b663a36ca6878c0b3de57	211
25	e0a4131f6383cd41675969f1a75f3a109e5e44ae2ef60ce87d871b67c26c6e58	247
26	8637ab54476292dbeb6a2ad7403be41565805272d9858016ca3709c82cd14430	249
27	ca5625fcc5dbf5ca272151f92578a083fbc14a40abaab2e2d5b259afdbe83379	257
28	08345a5f0302bf1823e5cf21855f2ad155a4fb10b5e477f84d67290916e746e7	276
29	41b22cfc58e84d012af629edecaaaaf7e3edbc4ad053eafe1501398de1503c17	278
30	97ca91189e24997701163c79cad120715a08b674de7ac672352b1cf361eabda5	295
31	862dbbe2ca906a394a917d1d3d85351077a79b1d407c25c21c39bf1d76a8ee58	301
32	1025a87165358bb71f93ede045421f9b4704de7c0dcb34c20be7ba345b32b3d3	326
33	4f087ad47a02bff7243d2c2a8d07025cab97d2a6832f047289e51569ddc3feb6	328
34	26fe825930707dc06afbc30298fb2dc9a33672c8c52e86ffeb65606e20f094ab	330
35	c76868abcfd08b4c65372ad1eefe1d0818383154b49e0cd31864c8aac9c18e33	331
36	5d3f28926e0812100c8fd281b1f8e68175aef0f22633603e733ae5bdcfc0cc1b	332
37	fc90cd4b452bbea61566b649154cedf7ec1ade39a408861da465c5c44be1a382	342
38	3e52078d312b6d0267e4b850835fc0da8e7a2e072c99223f8abb0805f617045f	346
39	4cdec0a5a8813783a5446b9982288970053c48c8d4223ca1470aa8f78325c7dd	351
40	f6d6ad81c7b89d0dda292ab4c60f37246fd8f8282826943df68611ebd404c0bf	364
41	54ab406b87d0b4a502c92c175a2a1ebc8ac7041fd7f24b9d1f153860ed5b53a6	366
42	978c0baff0de260625b75794bfb546c91d87b76a52530727207cacd59c1581e3	369
43	e7efcf877da37475ef45d4eeb9f6db428b2a4d11c709758a8fa7d2b6296c521a	384
44	697a07fc7e4afef5bd80e419009d741950cba1c55976da53e55522233dc5223e	385
45	fa90299902eada00976418c78f0fbe1e637160fabc4019364c9719255b78cbca	388
46	a9fc5bd0a32958f711b0810df6699dc31b4deb5eb638e19fb73d3de81b9bc6ce	392
47	870cca2879620bef2aae5b260fc409cde5650397f2ca7a824e08e5c97ed13982	393
48	ebd9c39ff74e64dccc85fc94aec0b7077081367ef2763f02de053d158f57cdb3	402
49	70bfd171b6f14240bd5b43116846deace4cc24572db9c8899d0bea76d4065c77	414
50	49c083b51613a7edf3143b67f8070a1d4afaad77885c78122030571257b21a9c	420
51	3c1423fe34a976e27d554fa812db1dbe02632cb2f07c8d4c5c2ecfffae8969a4	430
52	28ae214fd670bd74eefc8998f38d0014d9e41eb691dbbd89aafdf4218c4c7020	443
53	549e9211a1fe3075e99222a87abb8a088418769728ac608071e31c9669edd3ca	473
54	09390c435b4e74d6becd84bfac55a75e77ff7be907ce13b5bc0c59f0256e0758	477
55	69a4bcdc0f9c6cce20816f3bdaabe1236d073f60c8e0775a5301e7d2128155ba	483
56	00fef73e05f1893e4c8cb68318564895a35c7567ef538d289234165cd65bc817	508
57	22baed31d6b1c5264cbbf2f69ca7f70296949fcbede7075a53cb0445a1cf196f	509
58	889561b9a642bf66e263105e14078257c8a7547983febe2ad66584249d0377fb	528
59	2eea0add1b99ca7661ce1c72c3962c549a199ba00d275703c869bac49da8d7ea	564
60	7105124fa5c32f2b95e6061bd4c0a427552d8743d92a198fa360f0bb78321011	567
61	43a3e2ffba3f47cdb0583ce9340277936bb0235c0227a7ce0a4109ed7d8a48e1	574
62	a2c8f82f4c20d93781fc36c481bc40ee752fa8ab0e4b9c22760b96e60241ecf3	577
63	74328a2ff4374a475e51ef97fff3292b263424737f1b18929d6fb99176ad7eeb	586
64	c992f3eb627636caf31b40dbb3000343508a267c7642a6736a588d2425e3b07c	593
65	279f1ea42358773533b66d20b6fc1cf824c536e96a9e365d2418a8837c6111e3	612
66	7bf7b066293104c942fbd3d82af444ade2b0bfb21296808859aa81de625a7b0c	616
67	1db20e4601886324b0c64ccc0adafa214948f933f6a7b57d706c399993361708	626
68	f861970b4d8d0538f6b1fe037429147de8d6cadcb44b169d736bbb93e233b200	630
69	7c32671a8bef421f9f32c5d6a61f4c3bd5d5fdf18a06447a80630c7fec14144f	631
70	d89f7409806b4c21823bbc6c39809bb600e045824fa9eac36bf3e3b81df580e9	637
71	8f40a33da644d67026352c7ea12d00709c5baaba12edb1474b333a8a78d1a37b	682
72	1dceb032d40bf8fd0f369131bae821937b90697cec7083a25be764779141dcd9	697
73	4f20c81a3e965d7ed34bed478dd3b55efaba653f9568e2996228eef2318e69d1	715
74	58c782b83d39fbe1dc68ca3a9710ff2e08fd9e8c77bc2f55c6883902159ba711	723
75	92de5e471d615cd93b90cd6ec38d8ad51d715a2d6462559432780d4b82dbc548	726
76	fccdc60632f4ff0c0b5de80e512181a1e2b3ceef4d93d525000ff5de4a6acd97	740
77	257c869fd6386fd54db9bf536ddf5234e39b03dc5f22ec91b0744baf13c85f7d	748
78	9779bbd62a9a023952b8c2ea9136c16540e5930bfa9218c6beb19293020eadd4	752
79	65120c87cacc43a925ab5e1739a4a93d420760c3ef84a4e6bb92880d6a35daab	767
80	539ee448d44470d903de7536be2df5d794eb41ccd0f0e82e4814bfe153de44f3	804
81	54552fc38201c803cfa9e8a13332e7187401a9c7d9c6b9bb129aa399094d81b4	814
82	22886c7d83949599bb40262dac8c9e1c1b1c94cce4351ff0a59e59216540d92b	815
83	a7c8983059eafd2a8b04181850285c06d682ce21c8257874ccf215d37a174ae6	826
84	8c6e911358f202251cc55b3429ea41423109799d787ea7abb7933c0c1c58c50d	827
85	eb00c2d9654c44e60289d4fa909e47d3426618dd3d03043f92496192674af73a	835
86	f0edc273eebae12d562900380a590d14296cd03847909e69e0c47a1dd0ab8813	846
87	af5ec95eaf05df16c0f65de05b1db917defc309af8863c8a10324627e17db6ba	867
88	323d4f47466381040ecd3725db5ef89ebb3d67fca3d33d7c24c040fb2e8575b8	875
89	4430f46753198b0295508e974af858b7ad752ff49ba3a616e52a0a94f42b615e	889
90	67b3faccf70f7e1b1d98f89a59883bf6ef14612a395779b9e8f44e78bc1cdddf	893
91	c12c486fef9d672a5e2639458aae187d1392acba0764e1706ea0e6bea268eaa1	927
92	a95b059de1fef987f404334146d2b2cc0cf565d6525a16d5b78676d1c2ce1f47	938
93	9d07218f8688f344833ca01186cf126cfd1bd4ad0cce207876f06fffc4eb1f23	941
94	eacf9a28e3a76a500da93e02549cd053a8e4cc6ad050a8c2b895db51f1f7c57d	961
95	06bf1a944b908c793435e91feb7ebeafcf98491fc851bec64319f7c8ef11afd6	964
96	96d7151902d848d77843c57f5c67a727690759254fd4e8b15ab027a8b31b75be	966
97	fdc468dcd3e9e7a3938262a2f32f6b6353e55fab67ed6b8ae593e6f31dcef558	979
98	7457bd5239a84010125304290a8c444863a3ac6acaca04552b1181e52a3d1ed9	983
99	878aa68bb30eb02a09f2a3f43a0bd5aae5ec419aefad3316ad605860f148d15f	989
100	1ddd4d116079347111d0ffc040f117581ae0b9776b2a9aaffa2ec7e1fe9e7ce2	990
101	fbbf1c3c9356b4bb5bb520982e33153f664d78f255b6a31fea35809fd0e6b742	992
102	2ed1fc23aebb043f05e2a3420f239ef5cc0d6084f9461603a22df4cdf2ad61a4	994
103	0e71b75b1942a8c278fc585f3c25f290ead1b350d3062f6b991f1de4fec5e806	1001
104	cdb4fed83c6bab14ad481bbd46861b46dd54d093d58b06100631c4bdb36583c8	1014
105	8ba2fd779b6875e6c95ff56063be6d489d140da9b4bb0465e50a38c984a5cd25	1019
106	bebf9a94e4398e0860d011fe43dc30df940e2884d4f0446720a1b4267141f7b7	1021
107	fa50f2c348d8d4bfacf7785898cef03cb106c5b726054838ed624e099551e276	1034
108	178411644c07d9a6f0c91916fd88a31f0e47ee636e69a59cb9b719459c587271	1038
109	2b1feaf1d835c3a8afb90e298e799ae92f14c93e964caf45a2265d7206bb486e	1040
110	7fc950ccd31843c91a7d5035c29dff3c2b6c0e1131fe73b6cfbe0e689f8a7e4f	1085
111	0d2bcb1be4fbc1be3a62664152587b3e107d164e13e6b99a68eb1306dd64a2e0	1098
112	08973e27573ed01698ceca3447751545d55e93219056297a48579865a06a0d97	1112
113	214451963b38bec0ebf7455751d2b94f175c7c39722952700de517f93af8908a	1115
114	7e3f86e2fcac5f38e40d9dc7301b20fc553858984a3299d53234fb8f7674f94a	1134
115	aa2690f567d17688dfd7cb458bae9299cf6a3f3555ffd9dadc7832432cf69375	1137
116	b8be7677b9e151125587ec59b85cc62aa761835659750923c5f6512c7bde9cd1	1140
117	ba99d5c0d2a5a78eca95097d1ef3924777f59137af9bc9186943d8ae20ed4507	1160
118	1a442fbd3944226312f26d1d33c6afaf30f4e3f7ab5c0c072dd00ecebb1f4af2	1170
119	e8048e4b6e18eeedc429e8938abf9fad9cf28967997049d8775332de6eb4e313	1175
120	74a45dd91c2c0f86371c37f6edebdab8c7e68f75fdf76a68bd8f81460d62c834	1185
121	21f2a495cebbb2159edbd56f88a4be88aa4bc08e72a8921fef6ea07fef7108f3	1202
122	137d7f8d5e3935b73b506f8908b74bef9213837f4497207e4d594216f02305e9	1204
123	78ff959aa27a92ee2879f2e355a54bd97a019a1a573fe71ee125d339458b7944	1206
124	d19222e89e81451ab0d1b2a54812e9c5f73f3211f19b4f2db985452e4c13902c	1209
125	4abcb02a551cc5fe201bd1f89b5e328f1f616bd2b94e1dcd3101d211dd623a1c	1235
126	88c88c13d595eda53c29fa2e0007275e2060feab9f0d84bf1a89e14e9e9549a1	1241
127	25e1a1544a8726a0031b4c6bafa87793247cb8f84b1ba8a92d975317a598e6c1	1245
128	38f5f6ca0a1518ab788c4c14853ca88d4062fbd3c2f13b91a80cf7c5fff3ca88	1246
129	9d0f081f71659be57a4aaaae14c59f23323d47632a1d7af99a040d4dc7cba605	1290
130	3e657fe1e4d1c2e8284b096845d1dcb7591c9b9e4dd3c250b7906a354877612e	1292
131	1086a21de9eaedda0c8b855315799c2fe9da2bc450daff9dca3e088f75ce9bbf	1300
132	3e5cfca0de4ad9a8d32543fcd4dff3aa02d971d9f26ab3a096a59f5ea98d58de	1326
133	af2f80a23669a45c4ca3f7edf485c4d52e92921a2fa8cb5c9e7dc5da0940f7d1	1331
134	7ddb08c1eb24fef1b6c3575b7f0fe4f405d54a8413b32259c55204b49a296f0f	1340
135	762dc57f8c5421b7e53a8bc33b67d60191ae5129d4f9b8006154412626e0c304	1346
136	f959a8b7202ab8195b697b59182e56c8fb397b11a10446d8a8db769efa7cc016	1348
137	6eba96cc0aff7b8a27cedd9d5c3cbedc0dd12165870cecd4b27d8a2e1e48b752	1379
138	f1be7e8225d5e0c653d6dae57c76e8119e58d4bd2e3048545475d3b480fa8ad1	1395
139	a9c855e98aec497a0e9dad63b55f5a408058aed8586be6e657c879c97d4e4c0f	1402
140	17b08c226742d866f47500b4cf02c781812c1b2e8bc595738d75bd0087dd06e2	1413
141	f9da6d4beea56c7673b51c143f9ed1e1cc756aaba554bff449ac36aa6cffd561	1415
142	d96e9507401693ab34ccd29e835a01277e6a55bbf50a5bf3a84e70a22885c68e	1416
143	c7326ab10e81fdc97e43603ec2f3217cc2adacbec4c4ee47f752bd3426fb7900	1426
144	d2b827e21e0b8d9aeada46437c15ce1220ca648c6eaa71e2a4cc80f9785063a4	1428
145	e874449d19e99121dadd8c1bbb43c682e465ee623dc5bc918dae5a51b3cd4ff5	1434
146	4316f71bc7186862d71e81df3d7ac1fb0283194336852d5d9d3c01c839ffe652	1465
147	3047780d671b1ec31b51b555efc3274c8b5d11397d52e94cfb4a8668d03e22fe	1475
148	62247e6b37bee2ad413f437c89c22ac7228a643cb6e296d994a0927036f66cf0	1491
149	bcb9c6386f6c387513f01237aecdafec05e137767c45418e9bf6e5df6441dd35	1493
150	0175d80098e8963408dc6428a472a7e908d9ac12b7691fc5dc5db8a5caaa2ed4	1504
151	2a4679566cf782faf923129ef851f0cfcf603454b04c09ccfd90da5a43d01b4d	1514
152	e6ceff94d0d38502c461b5292e4d988a48e280ee0282c900ee649db02dba9aea	1518
153	05f51ba9bc5e2c86aa237725c583ac6d93b71e234c2753b9402da3b7195ad653	1526
154	8c0be3757ef76a35b97df3ba0634f172e5782cd9a2a0766b8255a7987d611820	1532
155	6408762f95740b5280574adc8e3d6b4b2444e3b517039b6fd1b6170de59f30f3	1547
156	421a89c3eed6fa7c9e5caf53b765845f8d3289899da97f003b39d40e0647d7fb	1558
157	2aa62f78aabda260119ef1e18acd86c84028d079731003dd6f6b2f8f3c23821f	1571
158	cf86c35e74c43b191928ef9e2fa9a7beb221f573918d7d7f24ab437a847e44b9	1575
159	c52ebd7d5a4a1838cc6d89e27b652bd57cb6d170a1398c9c03e6bd0bf66632a6	1578
160	2397a84c898f88a08af6a85d51af630d5873b6441920b73d220981d57e55275d	1584
161	66bfd16a2e61d493d0d6655ec66e8f2924b54f67f1d08a0614d778951b0ed4a0	1610
162	3c760d3e83f56913971b5995ffa61e510d57405149541fde02eb92e56630bbec	1621
163	0fa53a22e3a7ff50c4da5ba2c1296ebd0152dddac97e7aa2e8622fc8262c38dd	1624
164	7d98f123e49edc2b8618c1f92412894db336336a3e435b691af1df5c880a8c78	1625
165	559bc93ae938f16d1b4eb780d510ed121a5938ef2ace08eaa82c59051c7ffb79	1636
166	33247ce27a594ad1850c619ee8cb65a08cd904e7ffd2d01e6a8ae708a4919306	1688
167	b547a5eea84fa342376dc82ac90c0140fe8e7e26e5bf03c0cb98ee28ea8eac61	1696
168	58e15324bd55eef677df00a82609710dee76baa69ec61d0306674bfa781d3429	1698
169	8d438e5d4625692a9237e4485347cf1595a7cd65616d556907e6882190121f81	1712
170	4ca74295c33be98cea51a0c0504ef7c45beae78b1db1e4d6f0e8233cc95d62ce	1727
171	b0a9548ad41ebca32570f6e93ea1c6f80aae366e0c9bba8392bc3a24c28e39b0	1736
172	f2d40128e636f0d6545cfd8ec9d54cc4e4860616756ac4da8fead78e34e73afa	1748
173	d6193c1a92c28f300368cf400b6c19cd2a489c97f38a9a2981169260ec4dc871	1753
174	1de444a38253bc8596a38e6ee5a8ac1c72c501890fce7d8c3385e5de735fba2e	1771
175	47800ee3480e2db932cc21d8a4d5dded9b6030f103f27a284307800334f9a92a	1792
176	adbfecfe93998fffd84ef555027d9b53cedbd646817279e6555dec3250807a61	1797
177	66e99eb60cfacce55d969d2b3db8be16637738adef9c97cdc650ef61972cc3d1	1800
178	090f02d34e7268056d879c99f9ecf4b6d324f94eea161bde97e30ad8177c2ceb	1806
179	aa90d3385f3220ec49630dd550310574b3ef1c343f0c24efd2a7773fd9ef40e9	1807
180	c7f23ee12320d5b19597a29e114cdf65fa83399d5ea328da783bba5264c700bd	1808
181	7e254f1b7aa7b48aa1e0e761ee9df62c1986e9c55d8172a5cd0ba5f24a42c468	1834
182	1b7863528dca84453e33de46ec54b2b6f53a37a1212c70ec1a282e822e49fc75	1838
183	e7129313c754adba190f6461e05aab7a4e9132c69c15e21de489dad6d80ff840	1842
184	c0bc57cb312a458eba38c56439f363849c3efde8406c2715a12343ae6049b9c5	1853
185	27c673e33e68b815b95d7c6cea2efecc41b210f74d1597a5bd7b2000199fc667	1858
186	af4713dd50b74504758beec30fd473c279b2568a21e58a03b644900815454489	1859
187	4c683e55d9e361c0f6a845f453761372a4569ac5698fc6d2c95751d2709ed4f3	1860
188	224ae06d6bfc1c7c952d1349c116cdcd6d46a87bf0cc21dfc502290ecefcc80c	1861
189	36f978731f63308d97f1ce4c233e76350255e9ae708aa00be55b7362ef442e1a	1863
190	aa95388493f14cd79714b50c7e3bb27bb03033078f228bc5f08148296901d545	1903
191	89bc4aa58747f5b42e45bbcfacce89689c3a3cb7dc321858cbae75a440a52d02	1911
192	0bd6151977f175af3c4ad9c7b046a60be76fdc82f5ecdc388cef08f6ccd4e027	1917
193	929d62113af940eaba468695641a62f74e5ee14aba13fe8c6d9d4638cbd1cd0c	1931
194	d0a2596759d9753f52646cc7407701d37dbc847d9fb8f420d2e98afe02b48937	1937
195	ac8588eeb0de12c32804f9fc56a99fd0dbd9079792f9e7d2a7cf3b407ad67170	1946
196	08ac4febdc1a024f2c84cd0ef25bc8047f1cd48528c728ec8757786b12f8550a	1962
197	ad6a2c2cafb875ea6747168354fe6fd81427e8235c1436806b1fff519d827914	1965
198	9499a64f75c5cbef6b6ff5e9b434394a2c1264cb2426abb9358334aa7a752927	1971
199	66d4862337dadd9315683a1e488add32acfeb79ec8ecc3398d3265e739ee419a	1982
200	7b763fbd229b018bcf55e88d0725dc4e59381745ccbc41a1a15d1137f6e02c32	1988
201	8630c55ade27aa66d4683ac2d1cca61df0e365c59e48a6799a1a89c706024b41	1993
202	8640a632b07ca79c9ed49640b11be9db918446e767cc68b32d3b49df9ee2fd37	1999
203	3d82f1f502e6a45a89688ce36b4b57010b8e20cf98f5c57ca23a860a9bf60d78	2003
204	0d85b7ef83fe414ff8e910cb11200a7d8ff0034ff3ef68ae28a98815c9ef7704	2007
205	c9030e9a03b24c20c978187eec830967e43afc798fc884a40336dbe41f9fa4a1	2011
206	781121c59fcd9333e4a0809d7946b50ac1e317bc025ee18ce3a99da749260a7f	2033
207	89afd0b4959ae713d84db3076c7739cab956f9275554d9568989f4e726b0a3ad	2037
208	ccf55cc63279c69523eeeef46fd9c1f1627bafee9361c972ec3823f32a5772a3	2041
209	ed374e9f13477e77a1bb4b990220e9dbc102ce478e1119afb6411490d65dd57d	2043
210	905e79f7e382a419f9bcda0e8a125c9ebb9df0356ebfc61d0b4276c7b822bdb0	2045
211	8acaa308f6c1976ebef8827f96ebd58b7d89854fdd62a5527d5548ed86cdcd4e	2068
212	5ffadbbf91f3e4935f805623d181f8cd6a763d3d79b182a5744550cc792940d7	2128
213	647123cd12e279c6db0e5b374c104221eb11f6f53fb7ceb7566f85442f90b105	2138
214	c28fe8b5bb7f260abdde069db832f598224dea55feeb6d2fd9c4d5acd5f5af0f	2190
215	bf4b0e99679a179402c8048578b6676a2a56cdc65dd9522c2fd78654e1a10e9c	2191
216	6e9aa882bb2b39790244bee4c3b51bc15e58b341c6bafda29213ff7fb2474ee4	2200
217	fff97df4d35c684aa0d57a74f114c02248b667864060d670b0473e975f581584	2209
218	57e797486377481b08d5631c1323feed6d0ebf670c77e898af4c18dacb9c4b9e	2214
219	b6b1ca2ef4d3d4b380cb422efcc9ca75d343a9a1ff8a8d475946558417360a47	2226
220	d5a639a03901f4daf998c71afa910f331cbab769dfb0389913a785d48294d8ac	2249
221	df57fc79eaeb89413fdd94b1407285c8714accdcbbb5a6abc5b7ef4b19bc3c3b	2250
222	ea5cf429883a0f686d5b612f69bd1ba642536c20bacc5aadafd83e3e763ed048	2256
223	0d603c2d9e3174c4b9193be303969fef54d9d8087ed0f2ea707e29e346ed8c42	2260
224	af63cf7d9a3d428b01160d555785ab96ae075f445ec8e078786617a2127aa51d	2270
225	b4198ab7b3da7484fd862554cbdabf77501ee3ebbe9257e3517da07cf42b947a	2271
226	25afbf3982aaa123bee64cc68e631cf6cc59ce0b15f3b4c10d5c4fcd564f7c18	2295
227	16bbae17d1e08cbde1b8b332677604604837b5958b2a08418b7930a83a71e6e0	2316
228	9f8a36121d5908255d13835d3b1a4490c7dd7533af08838a04d6a89ec0194006	2350
229	af351d2f0c0a82a8209f655d3b93bb05a69d0093984cb61ed77e6bb09bbde0d4	2360
230	866a168c017303e03f0b474beab35b8aeca4003b80c2d624966f71ae4f400552	2366
231	06bc21e8218eac1b92d8615a7ce9646f03a4920a22440befc138ebfb1c653e25	2388
232	234dcf0900b0404813c88ce7b638fa1b022a9daba92af0bafbd1ee3e6a051709	2401
233	e1d0583fd3f12f6386e73265d588fe0a82aabe05fac66d9c785876598d73bd70	2410
234	5fdd8dacaaea7a672615c2e9254f56a35ee0d7b0ad1c0f7e101fdbd7d21567df	2442
235	51eeed53cf2a251c83fb15477e212195333d09ba997faa5c7045ba094afb4414	2458
236	0e808aed6af648aed4f057423ab268dc6171a08a6f9306107d8026fff8c71971	2459
237	1a465a330b55d8fdf2db620e175bcc69a87dcf6a72c1bc7f884af98b91776149	2470
238	13926ebf4e1cab530ce83b3f5990c013d4238c9bda6656a999041bde97d5b1f2	2477
239	793b8657d39a2416c531c430fc814ee116cefa0da4a5dd85fd7e0e384381ac31	2482
240	cd70e14b3798ff0cf371035a5a592860af63054b4aca243e7e6f4a1a56e7e03e	2487
241	0580d1d49b26b8c4f4473c2cc94fb95e9f54081278105d6bec077a2d06f326ae	2495
242	0dfc64a41a7a3b2852034618e23108faaf8f18ec05802d27015122b493d02e09	2498
243	b08a3ceae04701eee46faa7b45e3de3c0bfc02d0b19983c77164b3bbe5ad7d75	2500
244	00c3795be19be2175538742c11875f0d11b0693ae0e10af326cde7309129e498	2502
245	df0b74f141b58495ddac848c5503db26adab17aaffad733a1f2a57c260a8760c	2504
246	b8d0ac4578c7861de73944a14673d53b2ec981c12d3f8f6197b3d242efc87ed9	2524
247	bbf764251fedae3439bf314504c9f1f3ad354b4a3fd98ca6bb2082add8a6431d	2547
248	03d04c747852024cec1099b0d1f8d7ccccd5126fa569da9fd80d686d356dbb47	2557
249	cf4e23a6f4362b59b6974170d9c2517f2f66b86e6d55cd8e0b3fe114b2e88e92	2578
250	35b32e1098ec8584885fd9f694e2fd3d6f5de586cfdd873b58166631025a6cec	2582
251	20d70d022d4e450f3bcadd514d39edfba39695da6ed7b65b71d6735ec76caff9	2597
252	f38ba776b86272fe99e0bf71fba742f20730da5753278b3cb987b2a77f0b8f20	2601
253	4ed3681128e8779e32ce4a6c3bbb983a6005fe30b81dd10b6250eda98b8f6454	2607
254	280074878e1ce44517584cfa5531288c40a863161b605b4b3af61aefef9d34e1	2609
255	0cb797d8bd5fbc0d2d7a7655602d28da800e1c47df6cc7ff52d588c1cf9fc81a	2610
256	f9f6e870dcb43a99c7e693ffba2547d5e43a89c809b079aa92b8ac7b1af44d85	2626
257	44d27356ad4666e513bb0f5c4e5f96d114ef3a060ca113aee2d70723299177bf	2627
258	092f7c22f024e0408ee3c88e30cbbcff6eacaa05dcd8752c04e0390560a69611	2630
259	96568f0ef73b5f833f1940e949d426737b79985f6c3311752ff02d98b7977f22	2647
260	ed9513c0dcf9b8cc8b432464f9cacd59a596cf7b3d31b4b309f54d73e91d0e7f	2652
261	529c57f47f4a12a13d6ea414b22f4a116d656c7c5c1a6bf783dcf7dba8a457ed	2654
262	446d8caf63d1d7c0a5cb98ce5eed9217e4f502345219249cedfc6bfa409411a3	2658
263	a29138e44633e0be343d6355827333aff0cb55e4d129b32fac92a258943812ed	2663
264	0ddbebc96f99d9f2d89e03e619967095dafa61bcdc3d2105551503d3c302f09c	2664
265	782cb8663e1b350730de2188ac80025069f67a2e588360df9e20ffa87829af7f	2681
266	558fa44ddc4d9c2e0b64c16ce3417cad8c1bc561aee25505a045412e9be718d4	2690
267	d124bfcc03757ca0ceee25815b381166996203422bef03d5d14f30c5a682cc96	2693
268	b1642305b5bb5014722928776c36d1313852754534f74b4c6769af5aa096cb14	2704
269	c6a016815d61e79184774ab309e53ef2f7a3f1d187955be43526ded8605024a3	2717
270	9754e24de90526dcf68a2ec01551bb6ae16f5d43b85f770480f802bac0d74176	2725
271	1b8716d208a5c801a93579a45e9aa974803614de1f720844d5cf0483f333b4a3	2726
272	a812980c9cc812ce4733a3385ec4871dfd94dadc78862089c86953955355e7c1	2745
273	1dc648eca838f6dbf3e9746dd3f74cbf88fb819305bc35b43365ff9a65b2db93	2747
274	9c0d84fbe0d6b0fc5589d5f7254d856a3dac89f0eff9ce0d6d36767e8b425553	2752
275	6be2582fd0fd96d13da5a8c8e9551fdc2780c6b7b0c70abe259197aea08cbca3	2754
276	9574ec42e6a777cdb5e98b1543ddf429473ff147a8a48a0aa7e44dbb98490e91	2791
277	ea9ac34765d606b75ae8f83223f749c47dd7609fb87cbfb3dc6373e626a20d72	2830
278	8baaeef1988d59ffb35f3975e03221ce83035813b1960f9df16938ae33e86c96	2858
279	6a284d1477e64d5f5dfe57228f8a4e1ec2189d391c71b37f714a82d8e69ac9e1	2869
280	6e9876ccd6af38dd328b26875b54ef83f82f5830260509028d706f38ebd55b09	2870
281	0c3dc64dbc76be7589e1be726f3dfbd1457e23be7793c6ba235a3cc9a7d3f81c	2886
282	a499dd0138842f0a08e40ddaa434778b24b85a4e62958099bc557a5f36ed0d10	2892
283	8474a5547fd123377df5122b5b4d46afbeef904aaf2f6cecd6ca3170d6437eaa	2894
284	fbf7f6a85bb64c5b7b1584550b4e55a01b56503f01eb54e429fe999ffb1fd2ff	2896
285	95d0e2180b416413f74ce155f7aba8358a0b95574b4b30c177b51e8159e7f7d8	2923
286	59f28a9290f0e6c0679d0d556079bce7a9d0d327ce15bcbf5b0aa78282ef9a95	2931
287	5d2f4b8b0ec58ef7f78a90d9b6fbc85e4500312e5d7d36438a0a6442893b2a50	2933
288	17fb1a931e5710db141f0e1406b5573d6689737973d9326408e7fb21bca86729	2938
289	5947ede95fab8a67fe87dfb3e57736b0f926f09bc69e7cf866ff64fa7610c03f	2941
290	bbf433c6e3699f1c4c6fa0e878bed890cd18ba8bac2fcf987f7a4dce1a1c13a1	2948
291	19008fbe340e96ade1046e3eec7df1b601416b319bfaa420ebf966e1d35234e8	2966
292	42a3a5026e08763db124336e2ddf1be2366133ccfa043a09768bc5e0d5e0baba	2967
293	fd6b82c2c59f0ec3599f73349e2a7b1d9c53d315b80b474f286895e67a2e2acf	2972
294	831237c7967cc0a3309f2465f1aa9e050f57bb05e986a0d1c608eb0167ec8992	2993
295	25483548de3f3173062f98565b1ef10029012f566f4799b850c2bf8c5b4a1df8	3034
296	7bfac22ed49d01a6dc604ebfbc7c684feb5b26220d4773411fa917189716d5ea	3062
297	92abff12d49a584b77f48ca0014eb422213536f4c0dea7cd9bdc677b5bf7e899	3065
298	c1eba8abc7c2d9b0ac0380d2ddbc5891fd49200fa6ee80726fd7b9ed4aed3cbc	3067
299	2918c6a1c3d1bd21f3958af714f47532655f148f7efb90f1344ce146f3b0b3d9	3068
300	6a6b3825a0e516c169f74cb6d189bdaccfdf08d5fac085720a72d89517797afb	3075
301	10e2e2a9d73cc455b9b8ab9a69a1bf8f33e50656ea2165e9d95d46dc768a1bb9	3088
302	72dc9a6a2d1519faf6773885d7c5e519209440cdf868b477f12bdf6ae8166bdd	3089
303	e5d17bf2a75ff4ec18a301af4a814d23f381b2466a56e2b9c8810a3e3da54742	3111
304	66243cca3d3aa3050ce045f58ac4b615c8c0bf678be36fa358fd5026a7615da2	3123
305	64dee5729fcbc704dee868220a9eb7e174aadd1c4676a46936558d4187125a9f	3134
306	a7b74c704a614116a6650c3c235ac0f6b275a3722db52bb8c14871c39bad7ac0	3152
307	0d672f3b48ebf62d7373562be9922a9cc808fc35074bc1fb0fe05a916d969e61	3153
308	afb19686ad3307699d9c073c620a6fdcc78971e21b47b56644ba898ff7891059	3163
309	7b5e972985dc4ba4af631c40b42c091c199c6b36872afffb5218d9ae3b6a01a1	3170
310	c9c506b9f19e2e40e655822705aebdc392dc4b26ae8d7ff4288031e59151533b	3190
311	117f12ceee094708e82aefb9ea251cd5c2a0ebbf6c2200aa1a4f04b714c975bb	3205
312	724c221bcba34e24162e19d034764974a2a95905d86dfdcd59f75702bc4e01ee	3209
313	8253c4582d682f8be348406eaaab5ddc70fd3b1dbdb4dddcf2f5f294e62b0ef5	3210
314	3f446f2f8554e842176d388441be65faf87928ca6c31f080783f6519003b3f9d	3238
315	82137bbc9352a415ab9e41ca1b94b9c1d5be91b2a70f39dc4514c499a52a49f5	3242
316	c95539b2fe8a0c8a1b0c402b383af5a520fa2624b296bfc712e482bdd9135fba	3247
317	90c3f333769a2e5dcebd24ad9b0d4e1eeb727b8c3dc533eba04a3097ca69fb4e	3253
318	4687a3e4c20e390997de7ea5b33be3f2e26a8f144a984e2c62a2d921ce2a69e4	3258
319	80a459fe363894d43be0ea27e02948a8c61706af1d1a93b8b159e8ff704feeee	3271
320	b9a48bda37a13353bb1cdfe266902245e040bb18c36c555f045896d62192cdcb	3275
321	836fae02ad2ce15c50b02f694fe7629fb6ac8140fec1fd7e43df596e20f31d73	3286
322	36657167a8834bbae8be33031cbfc730cfe3907adf8a0dae1dab9c270bf9e17a	3290
323	88b0c050795f2fbec97c61ca3720ee59ac9917ac3afcefbc2005da475a7fd5d1	3306
324	93bf88a25833b0bea226c9698105a6233b912ddbb00e854676160e8605cd9448	3315
325	c08c854072a37d5cb4e543e5a9f2cd7d65dbd732b64cd4b4a5e3a64bd1605643	3329
326	11cbefe20e39473adf067d83952e071e503b977959f483af476937a0a3bdd81d	3339
327	4d5e252418d80a4b9ee951d62458c0ab4f6afc9d715b487c48393607aec78886	3340
328	2cda7e1088f9065af94f2aeb4371f0367f3d145e0a2d3b05b32270ec4e355e3a	3341
329	4cc5cef4cb6e2ba8ac6353e2e85c786588c12c22e13d700144d07e4347b4ab82	3347
330	05ef2cc3d8c28193c578a6a8ad5c45989c48286accf05e4199689a39a271f3ee	3348
331	6370bb836898d6ddb9559bec18f701512a94ef7eca5b30b04ea1e94fc7fd8f48	3367
332	d776a6d418cc6400d8cb581cba2fb272cde293398818b41e2b1aaaf51d2b2082	3384
333	c9e4a69078862bbd914e4e2688c928343e4d4067eade078d080106acb682c94c	3385
334	b392aed19983de9917f99799cc6c9bfce6416c2fe918bebaddbcd885b8cd7c87	3391
335	6bf91ca2736a6417e370b65de922b2c8ce033436c8ad51173e9a7ada891741d1	3394
336	6575a7894f7f4c12f00561e6fb09991a5f755637b560287fad533bbd9cdc0ad5	3398
337	3aba5c57fddbc7f72a4a1029dfa99c7a48b2f9c211050836eba649622d3c8909	3401
338	f64da617474bc0987106d716290edeffea0791b2e936ba79dcdb211ab8f57d32	3412
339	3e776921c7a92dd4b7536894c7e177288c9225e54f301d7d9d8c389dfed8e51a	3427
340	18e265b5a4de40bab36e1f5b2d51d15aa244ad000a889a4ae7d646f9edcf3c69	3466
341	1cfc756160e8dbdab2b6b276b8626f199c9564f35518ac543f891ae8f82211ca	3473
342	93373383a7a9670d51894390d142571b8109c77094ede9143f3c4b100eb4fd94	3519
343	67ad4228514a96e335a1cfbfd7df4741757bf8a288da2b6b1945270d222431d6	3521
344	f811ecc930eca69e3407c64bccad6fe903d3cbc3dc8063ccf6c533d006c335be	3537
345	8547c18cfb9bab9d9e81fb1519bbde5c934e06623ad903c9bffef8744ccde87a	3540
346	58d88c7dd91f271e50c60862aba6bf92596d71d9f165810de1272161af4ac49e	3554
347	b040f3168c2adc1cd47aa4d2b048569c738b928efaa58f54988ef1746735b2a2	3563
348	27d077d4531bfb757fd5daaefa37e3b704e7275ca37109b5dd41c16bcb778c92	3567
349	ed3cd34b7d0a318c8e133ba5ed6ca159aac82ce54430421f5a207b5749efd6f2	3588
350	32c20e38af3efaf03696858f98b62cc942e75f94f2c56ee60d479c3a34af8a60	3617
351	136c8d9648d50be764a868fb3e856acd0abf17118869764fd90a03c10bbf5b8e	3635
352	b5e7231eae9da6bfa3341326ed7f6106a87da413db84e0b573f62f5995ed130f	3639
353	7039ffb8427ef96e23ecec58096fc3540b0cb5393f687ce23e6c4cf62b35b95c	3660
354	3c8d4de03298dd615bb01243ed9bcfb62cb08fd3888dc05b8ab1b09fd5830161	3673
355	b1cfd60563aaf8eed8476d20708e2a0477924284012f706dac94b02718a9979c	3674
356	6272655889d23e78a2c6b5540b065860bfdc324adc397778082b3306b9fcdeeb	3697
357	40142d0398eeda5d7ab8d6f73925ae4cae693c574378d7069a51580df354e9c9	3698
358	07646a92cf3d6ab7e9d3c7dc18b8438af9e82b46493fd2360ce9c5bb83c210ab	3700
359	d2dc4396e6a88663dc9718a05d3a691e5ce0bd386c872ad14529bda7309599a8	3706
360	ae042fef79a7e02d5d80218023e7c030c5d89e1ac40286a8c7bc9f33511aea81	3708
361	1306bf59cd11ee4eba0872c227de6236a3202c403b64457b4127845ed0982251	3709
362	a0fafccd592f08d6c6423e3bd7c17dfd0acf3b6626606dbc3776175aa54f4ea9	3728
363	b65f440103f487c6f2f00cc9115b714136442c27ea7c0888f61c6e786e58a0c4	3730
364	26b8cd70d724c9122bbd0d9fd5ff6705ac7fa5d30da2252f7d2d1a7393943b03	3732
365	a561419474e1b2a9ccee4c71886251b0eaad2f03b845e6f60668d8ef2955614c	3744
366	2ed6d8754b3e3a41a7652c0d70ae3fb89b1e0cb6ce52498c31ad456342047d87	3748
367	0014a6c0706ea5676d0dfb5226d68bcd75fcfb3979153b14dc4670b584713182	3749
368	712d79689db5dddc214868b64c420002de5fd6c69ee593f7f4466e302a10de7f	3769
369	0031b16ab171f16019065c5d9718f0dd9d4eb4c22039cabac62b5eb42773b8ea	3772
370	89324186945f1ffa16da4f0cf59ef825c18ab9eeb2139994d862309d7e457c34	3777
371	e90468731f5c12a152aee88b4865e4a3fc2b6ef1ba078f70bbca2e1717c4a969	3778
372	eebd89a28089e9cc608278753f6919051fc4744a97dfd1a3f4e1cbcdbb5b0cce	3781
373	2f5780058fe9631c7e215300d1b4d11ba07c3614ebefa69d107f61aa6410938e	3786
374	74ad3e851cd7734efbb6dc6199389f1f719a8d2efaa25afc8813a9b658ef7bbf	3802
375	a1f6ea2c4b8c9425145f5f99823a0b2efeef4e988621ef7295eee8c270dbd872	3803
376	da968c2a52e91ed679df56a9800cc5ace133dcce76b4a4cabc3c9732f2f9d66f	3806
377	90423a3d41b5be2424daf96786fdcd013f34a2a78664437cbe27b05c6e9830ed	3807
378	624c0ef12fa876f09e7a41e053e3d311cf7369584a75d195dde69cee7c411165	3824
379	d29771753210804954eadc595913321fe454ff3ebba02963b9e304d7a62bcdb4	3829
380	a585818544c1fb56d324ca80e8c7a931e664e8de9cf332c8ae8cc009017c1030	3831
381	0dade55b2bce2a145df153c5a1e862df94eea90a28b7adcec0e22ba71b0c919e	3838
382	1058131b2d00c7512d1c9e55be68ef4ccbad11cf6bb43ebc069b7f017c720403	3851
383	33f24298faa4de9a2e8d75a3381c72a1ac2d45acea2e4e7ef3e856edbde6bab3	3890
384	008f7ca7d8b21d1b701dd3af9d1a15e268663de530b5fadde0f9e5bedeb1f693	3893
385	e8184e2ddfdf5b98e3a9df5db00e1c0a98d67050904ff91dc80429942b669cad	3896
386	a7b740297f3203e048201f7cdacd60e336e843fda0a20ea6efef62460744d5e2	3923
387	810cd123f4f517ed7fd6dc98bc94052650d1463df14581af494eb0497a658d94	3934
388	e2a0a8ecc8d5c209f5787331f6aed8299dffaf6da819f29917f5aec568441ede	3959
389	934bd4b042e31ae1311f13755b4dc8fe2f5784a5509f2d273802de11995d5c57	3967
390	c300c8a381467788e58103367ec7525921c10ec6315dcfaa06bf7a38864f74a8	3983
391	43b497bd1ba1cf7966f062b849b04684dba604ce70e6ab0c794f012d07c41e9d	3998
392	02958b9f6e7f8828dcac7f817264e651954532278bc116a6c95de14f949a03e3	3999
393	729049e768d5611aea0f48130d2df8dbefc4b1ac7836c38a9360e645fda04e75	4009
394	c52956fcdda6a976f7f919a87da8b4440ebac2b1ddc351c16b96e648d9218116	4014
395	d87805ebcc3d1e6142e5ae30aabe3efce06046ff8d628ea5e6a557b69f8b973a	4016
396	0771ba6ecda35331a1a295d2090036ad662f1e62a959c4635619818404615b21	4019
397	09ca8b35fbf77d997da590259908f94e24fcb89585894a60bb1e0743118a936e	4020
398	233f4437f525c1b184f4556d800cece02c3896bf0e1bbad4a4faf0701ce19670	4026
399	88011c0cb03d832aa692528f47b995fa1a6c79c969567b6816493d3253bf6e5c	4027
400	4e1071a5c9e7bd7248876e7b6d4d01d2f0b8fb65ae93c0e9f55efbd8434359d8	4034
401	8a4d498c19dc3bbe4bfd0d5570af8fbe0c5c02eb3b055fe77d593371cedad939	4054
402	59c3d7d57ef2aefdf5dc7c29101a90c14b7d319703b1650e842b7699c5620d09	4064
403	3890d6c0ae2e855fd99d974b490331a71726067abdc55a24884bc2870d0ada51	4069
404	bf35c07acffe7d418e1aa0087592d7007f316792d657bce970b49fc52e791962	4073
405	b5b323d10a594c1baea0ca9fd35051fd19965c38f50ae36d1412ed54ca6f8ce2	4102
406	4640652e011073bf913ac2cb8e1cf5bf4c3588f2be4e02fa5baa46e959149533	4118
407	ee70050702c85d709a9a2ee509b2903d528447fe9707ae8a3fccb284aa78e7b0	4124
408	dd09331df545b77b14fa80ede7687f304ca525e63ef940381f31beeadde3341c	4129
409	f0db8faa996de010cac6874b2718af86ff150a973a986d79f3350f99d81d018b	4144
410	7c0c4877c491600c13e8bc37682597b4106460fb7d6bb6f0a60699deed6855c7	4145
411	e233e4e42a79802fe949ad411723b1c9266137b870bf81be06822a9582dbc681	4174
412	b25287e3d44c99cec2151e3f42f22e50842d5b4a157fe93f6d1787f4246d1e5d	4185
413	9a0f0c6e3abfea711e3152ecb81d5846395646f6c6f228f90392525b5e905948	4187
414	73d9f0a04f728304e4b8a89a0cfa3c6a78232c120638d15693365dbd2707aa28	4199
415	5b08bc9652d06ed52696df7ac6b631e66f5b693fd258395a928b773f53061b50	4202
416	c212558569458a2f418b9350c0c30bb620025770b246f76d705e744a8baa7fc0	4206
417	7ea32664f0376102bf75470bcf77bbae75500d652ace7a6b247b3ff4a09e81bc	4210
418	41542141d5876c635162aad6acdfe2aa8e3c69d79cc311de4fa948655852ef3e	4213
419	be7e64091afe84c8d1d266154af250ca39879c2bdcbb98935f605fcaf48cf971	4223
420	19b4818b169b5cfca13a89278ed299237c6e722be07ea165e0f74a2e470ac6fb	4224
421	9f8b4f61124dc93fa16d8384985f1d19eeb2552dd9337b198f8be5dab1c20d9f	4226
422	f6fb4156d7b96bf02e035437ffdc4ded2e804c109eb26811c30597aee6bc256d	4229
423	3e49b4962dd9ec85264f70fea0002970e68ca9fda7e49dfedf4b66e0d2308b36	4231
424	4f9211f576dba15ae316496b6dd2081dd250fe3fa0387fb8dfd76c10e2b11425	4254
425	cbd43a16a2b1c1f4cad601fe536da5a1865a8480386e526a78ffd0ac79f48a3a	4274
426	9ebbe95a62c3a9ca72bf75eaae18de46af2f140fa3a94b64f251821cc3cb8c1d	4324
427	a36fbaf64be55aec9e8f2114d6b11328ecb137c50706d9a7dc2fc5b24e0f7aa2	4345
428	0260d3757bdbdf3711254df0be6617ca4112d2735fe91a21a8f3c6f8a2a362b8	4348
429	f0a9d42daf9b9a20389491e5623f08fca29cb88c609289c051d5be3c64e37dcb	4367
430	5c7b548686309ac86a814a710d4773d4e0c6a6c27313116e7d8fd4c54a0e34ff	4371
431	c2f99afe7f2000bc5127cacd61f9d04a1dac9149b3b9980dc882027cb468f025	4393
432	61bd1f7ad037f26aa3d39ca6eb3a3077961fdb3bfdd37228272d4b441545fb0d	4419
433	d5164402dd27af45184173b69835e755ebc78ca736d46a23bdae7ac2ec3b5ef1	4448
434	4d80f0a7c578d4f448312f38b8f187386e061006c254a41e981d199a5b14b87f	4460
435	7e52ea11341f92b2ff71c24f216e94fc9b0e1547ca7c7e12a8da9f9acf25e2d7	4470
436	777c831a5f40a51d96f855aa5c892934092151efe6a1557863020c85c391fbf2	4491
437	f443187bcd9cea7231b755834a5c6c8da2958d053f53c959e347b7b85bf8ed8c	4495
438	57f0e8a0a598e7de336a0eaeb2f0df0f28ae3d8a66ab9c3d06855feaf52b4efc	4506
439	bf6233071b72baea4669e82dc5b52ecff2eefcff4a5145763f31512e04140673	4519
440	9b6e8a2ec9f0c857f7a41b05016c66a46a1b9b515806b64d885ab515e0f1eb68	4530
441	5e07bf4e668629d4f70102a03b04d993ec32aa756693798516cb77ed7a1375f9	4531
442	664d1b94c7a1bb441e960b6ce61947b8101ebe4d9c6cc8e9e13a2e78a64c4ab1	4532
443	e568a24f073497e224cd0b665273e42e7662cb3471b2eb6fd06c6f800306dcd1	4572
444	047b49c31770a2d929211f4d5f79eb140b4a35fc2e874f266151b830ef1eadbd	4580
445	db9bfb2e4435a2646cba45440ba79ee1bc28b14a927838fc7be2f5489cb670db	4587
446	33c31ff7dd9e800789644fe5e9a212e43e5a9fa98eb6a5d05f281d75c883c3fb	4589
447	9cfd4462e31d9ddf9e9164824a79983c9bf5dfae60a83c29c60b7fa2eeb8633a	4591
448	a44874114a5aa14f9d5810e0905608c7af577a73a4f60dc6b18b2119aaa7b768	4592
449	11d3f9168cb72b1af9b0c50687946cc77de2d4e8235de27ec50b0fcbd5d3b232	4593
450	9a5f8c9dfaa4010c79d6236e9aca3607c281efdfeb4be083659d358172d9e555	4604
451	4861b6afefcb24b9b341cfb52f99460c60c55640b9993f5d06a2ec2624823666	4610
452	196fe0554c4664f1236daf6e8caad675b0f0b2a92814213325eb1eca0ca8c3f3	4615
453	e8b03edb535ad879d5c3a07c06f5eb83f9853d9266831ede0561095433bfb07d	4620
454	24763bc8abb8e658a0c0c31ff1bc96ee423de45f4ee61a5cd212a1531233b460	4630
455	aef3f6796231435921c61f11dd9f26bab7793952c3ccd121baba1c7772b75db4	4638
456	30b4218fe9abd9a8e11912c3ada59ef35efe4a8033f180a776b9d51630708f30	4639
457	476363e7cdc5d4b0c1d353e22890524343a4ceff985301c0f3bdcb3ec905f462	4640
458	98f65361b45bf85b99175693205a3a82c7e89c21299c9f2da931bb83d70d7dd6	4654
459	9fc3904e01a58931d008a9f4d64c8039796c78d29659a4c307d34982836bda4c	4655
460	35f35adec05eaa5de396f800dab9b797557e19f9e6719b72fe061601009bba6d	4658
461	82d204249d290d2639a6acf7078b71b1103f0c6d3c8e9058ab131b168ba8ae31	4704
462	13c0b2b34f893dee7cec1d004280effea168f3874555ed4e308e0941e89ae3e0	4726
463	de2f06e75a3d4a6f649a6e6a0359e6ccabdc1434f1155df80d510d2e12f14d39	4729
464	4edc78ea969fda189a1e30f40805a84381f699c53b0a974f600c6c27a36efc18	4733
465	0e853b82c7bf56614e0c34a626e4614a3534bcecb881054cd1d3404f0e4c34af	4743
466	6d0e5fa4ac0f3b334ee110991ebca7a2147c01b92be95dedb5c03a4125e831f7	4751
467	d7ed33d50ab1f9e2e089aa6dbe1c2c4d77af49ea2ad35e32198861e2d5e8a539	4756
468	a986148305ba45bba94109531e8992572bd88dd5fe36806aebd3b54de66c1dc8	4764
469	db56f91a2b729a9e49bd74d0695325600f13bfac418773be87a7015ed3d58ba1	4775
470	c6b5c8f149a99cd28800659053f59f9c2798342772ae0d2f080068c48cc3af5d	4833
471	816707db8c21eca1ac11b27cec416ea53ae168c7f9f568a1b47a1f6bcc0d87f4	4837
472	4a49a6475e457f95790d9b540a636234e8e7590e8cf5562a64ec93bcb638e186	4854
473	e7c29f848b37b365571768e620d450f568c95652f8a3025602c77986fa343f4e	4858
474	eb7805b0e7200ec7cfcc98f0da967458d720977df0a404161aab2841e72bc1e3	4879
475	3c006215b44b3eb31a169e391fbea520f0215334d4691a9ff3705b7be542f43f	4888
476	3f4ba3c2f25a8937f5352f45c021079ba2109f6959f976d3be8fb77ef6886bf1	4900
477	b0142e66c2b0fb2363470dc91060369d402a3827361736c140bbd6ecb17a97dc	4907
478	0fe197ef9c9dd4284cf6a1519d1cfec0a10a1f53853fdfeb0ca428e21309fa39	4933
479	53d433e75e8e29c993b953e7896cfbffbf52a34ed8e5d1b5bc889fd9ea2b9ecc	4934
480	dbece08f62df70f144d290cb41ffd74dedcb8bdf5c3154de20602a9e5ec6b224	5012
481	5c19cf4fa15d7558b1c5ca2d8a3d80cc6b9839785687a5438fb5d86bd2ccb9fa	5017
482	016b15613cecd842e0ae5e9c278d68a5cc01e40ee279ff3f4c02bc597d4adeb2	5028
483	3655e18c2f534dc2e9ca77087656181ed2e68d9e847ab64516891e2caf198413	5030
484	d3fbac5bb41de9ac512e959a4024ee872076b31c4bbdf1f176f3d4cc9ac9c437	5039
485	5b1602f24c0474b423e00aab37e9940570c62e0c3854571fc6f7284b2e08bed8	5046
486	91e82421b9cebbd9a87d05087da79e19a7f8e2ea41aaa9f8292c419037e35c56	5051
487	d279d31f350d9731c560bd19fd113e20135806d1fa90f7a45c1a9cd80706c407	5055
488	f3e7c77cc4e6a2eb46ed7632f3541cb43ed4b3a2cbea34c7449d29c27c8b4116	5062
489	69e5220f9ea70ca91b0acb15686a82216c6f9f8a9780a13bb47a10646b87cb95	5074
490	847a16b8cd7300dd1abe6111dc508e79b56d675b2bd524d79344fcc3853f11c5	5077
491	7663e000fd7fe4e36fa1c5a2a1c495bd837c0f413d61f0d359c723540e368189	5079
492	666464f4e408bb62fb38a80c694e449cc644acd5c64cffe057d5e382f5d970aa	5081
493	d8311a7b7a0a7680479daa6e128880ad0129e527a7fdc847226c37f06ff99600	5111
494	964282cae90b6756e1dfddd7da6514cdd5b8c86ce26ed882f0cb4f99078d9e79	5113
495	3a8def330b0b5e25e0b75f8d99740953bdc6ce2b2c670844fcfce259effecd6a	5114
496	3fe441e770cd108e2a3164b03bc6fbaf73a2acd2ff9921a438a9c6b4c2c591ae	5122
497	d094da351e34bc42f5a693e307d69cefa54808310a939ffaf2aecd19aa524d16	5138
498	0aeeac221babe5530dacb6d559de6d21ea97d771fb5bf5767fcf4247319b9f2f	5142
499	f0e2812402b423653cff45b1804eea14ab62af88b2d700b8c74e98ece1843c28	5144
500	56cdbb7876c4176df4c8a0526f27569183dff632c00afea0844d6f49b57e2d2f	5194
501	1d5ec2d27188bd753948eea4fed72578f136bfdaf3242755409909d4276a37e8	5195
502	f5aacc6aa20bd6d2b09e0b1e54af9a94dfd4d3a9f526d8fd1ba48bf7669716db	5230
503	29e40b04028dfcb09c9ac9d2303b9182bdb9f5c0b753f44b90566f7533ef8d54	5247
504	0964cd313b0a95ffafd7339cb8cf7685601a114e4f9e5f5334794dc5a785bb0f	5254
505	a901768b9f3b8282646f49e643c229fda1e632294e7f7172f73d9d16c38a3b55	5255
506	50cf6bb1e2698a00e02b762fc515bad1275b109476946df1fb8bb32794aa1782	5271
507	5c6d100f1ed895d7fba8d42972a486ef8ef8432b9e33087c72e7daf41a42480c	5287
508	3430cac9baaea6bfe1c3e8c2184b61d427d3030b342f67e65996cf90a91f1832	5288
509	a286caa8a27296c5cc7914d141d27f91f4ca4d5de761d4f72f977fffb4108997	5290
510	23d86f0f0cebe2ab75df40714afea1dca54b6d42fa154abd882b8846346b2c13	5302
511	2869f8bf86383afffa4a7a5c0c19ecd30276f0029467d172ea440745d3f4ef7b	5305
512	ba58c8dad4fa54f69dec440138a9c8c316b13385304081a7c6fde6cf7880d90d	5313
513	e99b6a22858d207145f4c8994743de0633d918861d909e11984d0620a630febb	5325
514	423526f044f6045647a02ab20d81ef7c72419804fb655bec12db0ca61071f2fb	5329
515	006e96697a2dd1488f0354c1aa0be105eed476f6c2908e9392b5f6a707e1f8bb	5351
516	270193fdd9d85dc6891fa4d3740f28662a3fdf3bdb65500382a5101c7f4a9c35	5356
517	0092453a048fd94a60397e4a2093777dcea811ff5fc9e1b669742e305008d586	5375
518	1b39924340c2813c5038e8fa3133f07527aae1e5cc48b26042f7344d854ef487	5392
519	91f2569538d624c6c3219f6dd2c42418e4d8969f987b3d862369ed4ded785a15	5397
520	0e9d93ed2f5c3de9e0a82fe49da5f56d2ebb4bdb7ed6cf6ef17aa3a3657aa623	5399
521	4794474185886a8a91962bb6225cb2466f31304b0b744ce550f47a9a557476d2	5421
522	531b21f1d09e50d25d2ec0b837c8a1762bf0d0c98418caa20c903966d4e067cf	5425
523	eaeb2ccd73fc35ac57713f24631d80031c98a3e9244c3b9209b24eac977c4ae9	5437
524	9ccb317a2f83f892de25d17d79d0615ec15481ae67267cdaaafb975780084c1d	5459
525	19ce89e7f16ce883a1586a7bbe87795dbb624cec434eae939fefa1351e6b7fa1	5485
526	1c75473e51de074d6adf5f0bc6ff1ac43adf13ea942b8fa09ec6a8483815703c	5489
527	9cd8eb5b96a05137b527b732d01a35aa5d83797e985cd486869b386db36f05e5	5494
528	0c4cd75547756b79049ec91254ebff793c246e2c2836c12eb711203ba6916549	5510
529	b38c640348e9866a0f6377092f38b05ec0d3694bfa4b7e4387861eb31268e135	5522
530	828982daead747305af6b066442300c55577dffd7d7ed153cdb8be7b365ee2eb	5523
531	67196fb8777165344fc9d53a0b599fadb344b70250790ba5de7eb4d22e9567ed	5532
532	dc14f02f5ca88a6d8cc5bc656221a57710e0025a77fd244aa1f728bcc241df9d	5552
533	b48246837dfa6edc4f8455b810abad8211ad35014835592177fbcc039a2bcc9f	5554
534	ede4e3a043bb0aae78688702ff64bdeec603df0a3766b7dcdec8af64ddad3c8b	5571
535	5085cc1a130767f648d257e2f722f3e742b5f476e718a1c708df3d41b995e179	5574
536	3da700784b3118e55d5a17f89577f76e7e69023f088bc6da44076158fe557852	5576
537	41430d147a9f30e0828508d50175d118744ba6f1c54b1261a0c47ea38aaaf990	5581
538	5a06b8e05954d788778a45fd3d0543fdcc3a4b6cebbd4e37fcb59320a9b1173f	5607
539	89721da2004b93bd04145601e5c83dfa9bd921eb487595355283ad92614c6aa7	5631
540	a84c834d9e59b129f643b79a41e0027c6d529126635fe900353be961cd155545	5636
541	b2e56ae1ee338db9fafe6425da7b8d59bdfd7f687de2cb17759be35229d75566	5651
542	cdfeea984a6a6216771fea4137b8e036944089aec748996306e97882907a83a7	5655
543	e4fdc0f8f1f1bad0cdcd34a43a75997f54a012dc96ef45eb1792acf7eb98bfb6	5664
544	feed7718c7a621d2ce3cfdcea1f40116d453339e881457d1a55b55a3c91aab85	5665
545	c3e0566e7b36cdd4b9df99ade3a9d06832a7dfb17cf0392cf024908d45e563f7	5667
546	84fff1e8922e92550bb84b7ec1dcca4b969696f52b9c8f9083573806f4eb1700	5674
547	a76418864fc7bb1d4b61d55847ac5808cdb4577171fe0b669b820d9bcf05d24c	5684
548	bbdc2d99888c4dce7563b163c7f9a555300625a0982a17d978b295b92c354102	5700
549	e8244bccd40017265d91d46057c3444c051643c2fa67c39aaf8f3c50fe69e39b	5707
550	ba749a6b8e4a2f850f7ef3de002495c8867845ac3c646d297aa3fc37b48150e6	5710
551	55e6a612504fcbc288001740006220ffc138d5418154372e430b4bb41f5ca6f2	5725
552	b6216b60a8b20f660e69e3d5c03a2df7b59de0f27b95ff962265d47b242340d5	5751
553	278e060e50e0012839d7928b93946815520eb0200b4a3856ce7ff9c1dc0db510	5758
554	928abdbba59ccd083d1f262d251917e54540c5226e0de7cc41e2a91dc36f3f1c	5763
555	0904ef4439e5316127c9ea41d126788eaf2a9174ac7234fa3e953e6e65b79836	5768
556	676d92c792ecacb51da8cca476392387cdd5802d93581b22d29a333f9f54d088	5783
557	0513ebdcf55eb14d1e6d3761bb9e238ed8fb63dac33b910bd9d081cbc0af9b22	5784
558	76bb70ca397083a99406e2d85990ea1d4b9fb493105200600330bbc63adf5664	5787
559	1c402614ec35d5213e485f52837fec71aa9f5e403989fe3d0c0acf4ffd3c3d0b	5812
560	f8743129886d59f35f13bf65937406fc9d9edf1bab642a4a0c5c9852fa4b96f6	5813
561	ea91526f4460faf12d79de052306e4e3192e99dd8d526c8a9adf1080258f25d5	5815
562	cd21908c35a3fa833d3cd05fb86903a0c1049eb56048627ab13cf546d871122b	5817
563	61b591a44a42be574ca9b69636b55fbb10ef7f22d3cea0f3494b834fb5bea9c0	5825
564	64d29ae7b12df809d07aa8cfcf18afd04f6d6da21adbc84e7d2fd6bb7f222728	5853
565	adf59c547f425fddc9e422815e93777aaf9c6f4b3ea1dc437e3d1ad0df8d90bd	5859
566	ec40ae3cde8f7c354c93b0d5070f2ef6de7c863d610ad677ce7dca6e2938a232	5860
567	dcafb6ea0a1dbb9388cf1bc90d4d3e763b68aca99bdae9bf2c61434683871484	5869
568	8bfd3131edebf744e5afa0f8fddc68efe8456d094795222500b1a890d32b87e9	5874
569	189147263762df98fd3cc90e7635ab04d6fcbbb763aaf8d5e0e54bc96a24a29a	5880
570	cbc468a3a992e995e8d54c0d341170f4fe624403e25955fb1cecf22f2ea931ed	5908
571	69f2b469b2071cea9f3badef2164c88e9fc8bdaf1c54496c4c04fd80558eaf05	5910
572	cf927b5ddec25b2d8d82aa606f7de3370f0d2b96656b9030e5b91752abe07027	5929
573	650d39feb948809f2598d7e64a769f3cd02afe0ed04864fea2da6e2b7e2eb1c6	5932
574	48dd8abbd0a46226627d79ce6f66623a19eec4ac4fb5bc4fd643755cba128dbf	5955
575	7e3d6bf68222f5d365c25e6fe5494d84cde91d1a84f02795c2714b5a1a66c1ab	5959
576	066dcbb28808d73d25709d644928f0cd20597ba99f3ff7916406f2c4767d9665	5962
577	264519d10f85663e6dec812f0c8cd35b9f484479a3ad52a28ec61f2322754632	5987
578	0c3762d76a0cd73e9ca45217c576e23ad39f7045ed2430f6a22c9c0e742bd0d3	5990
579	071f7b8cc9527ade04ef6269782dd2693ab643f6b69c18c04d9b604cdbdd6d1e	5991
580	18984413d05785cc56b23a4a71bf0ec4dcf640790f7f25f662fdf31fa83226cf	6015
581	5eb8e5863fe8c60f904f260f723ceafb6b55fe4cbc481dc538c013c1828f25a3	6036
582	b09da86d7cdbca2ced3d61627f17cae8bb9956a03e9d9251712fd1f930fc0c89	6039
583	73245506170b24e620a4cc39106985acd97041f01f7df78e284b9f651a7d68c4	6043
584	6e9c925dfc4f177dcf8be7eacc25f9ffabbc5436ec8abee9b45d3f3120439237	6069
585	6f56a1fa3c17e99a391a27e89db9077fac9a52f11749282b09ece15df250bbd3	6087
586	619cac89bcb8c15dcb4fc6b0df94be3a5ee42683df1444fba5e1433fdd1255ae	6094
587	e185b73c5a8376113e7c1c5fac26e423b0599c42b167331a47e6a7b50d65d2be	6107
588	711c004a9a366ae3bc25ada70c16b12d94c0325f9c7245bc7e9efedcde74495e	6109
589	4eb296f2cc03f5dab08d31031779fa44b699ceb2302bb147238e7fcbbe4f5a9f	6112
590	8ae9d443948964bd9615470fdc5940b4d60948b32298b49a7cd2c6a58f6cfce4	6130
591	724b8396f9f077c6b0dca83e83a771e5e228fe103c6c316fd775b93f89080d4f	6155
592	d4f6640b4cb268c91e60232bf2ff6a803beb456ae24cf357188e687224f98f36	6179
593	597b4f9e3046c758709b038ade54961eb41b3ec801c484f44b52b95910175453	6184
594	c1128d955ebffbef2435992e29a3862b13fcb7b73380467ffc228cd05ae277bf	6197
595	940a739ff86c47ddfb8fb364904a20f05d263ddbd017db81deeb9b2e16c387fc	6204
596	79d3edff77ef04e4c53efa97a50dc2441c1685422ac5472c830eece43339e913	6225
597	c7283ac793197697a34c82f89dedf9f75543f01af58604d67864ee2528fddbc8	6234
598	2d16b88db31d4c35cbe9595c62a679d806cd6344365d0f376fab355d56426856	6235
599	e435f2b311289455b890365fbbb1d06f2a8a3cebf0a053c441ee5c53bf140164	6236
600	401fcb326fbebdc64ab8f6c8e0e4a3ca1dcb18ef5a0d930bf0089d5fbf0a1256	6252
601	fc91180d8487e33ff31e340a07f441ba2f03ad2d9854ea2c9e636ff46784e699	6257
602	53b8d17bdacd00bda486b9c9bdec62859f2992949f33a66b7371e070a8bf9640	6259
603	4457fbb2018d924685c3e7c00dd0bd96cf6447476046f6feaf95c97d26602cb5	6261
604	9c201b4dd15b494d764cd1c2c7c14ccd6c697e4f3d10f05e3473b8c9260f9213	6283
605	7876b07b58f4188b013163c190a4cb0596871544e36638df7e34b5298f93f46e	6301
606	ab3bcb798c852565e4003c586510211f7ba38f9f0d94a2383f910dbfa296d7fd	6305
607	72cba968eb593d10ec3e9ef4168d18ee8252371768b796865bde75cfbf8251c3	6313
608	ca0a42e5921e06799c472e368b0e5da4f1f3fc73c5a77ee6cf6790e2d1fd456f	6325
609	73b81cc0805b69599da0f95a598623df882614397bd354ecdbcaf47afcb670d6	6339
610	8e8f0c71844a34515f7fb2b31202aebbc1e754676572440a8f595b5d59698f2a	6340
611	b05f166197a6b52b8698c66e42c42673052d8470b3acbf6c206b648dfabb49d2	6343
612	b83a8f8024352ed6a4fd983c4889bd276611487aad57a5368d714e89e20b815a	6345
613	cbd5612069fc7a7784f7ba75bb6b13fc04638891de56fc756ee8fc4cbf3873c6	6366
614	c08260769c7cfa1be80a2603441f53cee9dc9329b4f472b67921535332d36bdc	6367
615	07fc00293831448522b98cac71eaff763355bac99a1b93a74dd14fef0412bf2b	6436
616	d7e65682595cd72097db998d88458fab776f5b8138c4ea0d1bd973bd11298e14	6442
617	c11f2e6438b342b439639a49702e2f3ef8fab35f61a407fdf102dd5ee4cc4008	6463
618	777c11d174bc793d274e2f985510779fe9ca8c779cac8eb8111a9b239bbc5de6	6469
619	15fa4c31a1c0f43ac2f80658bd635633843fe13b582dae0d7ff406b644b62aa5	6474
620	910bbb30cf04beec53050b46a58bd6655f5c14ea40673c8e7fc7c67b06fef91f	6479
621	3cc5239e6ab1d072723de5c6c3cfe658b780d61e927e68d8e6218f37fef075da	6483
622	45a6265e52c9559b233d8054dd5d9509c35b128cdd666af470b30f31fd5324ae	6488
623	fc49a01c65b7929ea8d32810bee1cbef45e75ba74a69028c42668580fa430228	6514
624	df8303808162f327c34e63478ae081f9410fd6c2894fbc09b16ad3b1e7bb392d	6518
625	7ef5c3297ab7707c4fa5657ff541ca1c7e39c909312d627adf0a5abac564607b	6521
626	f6ce79818d81906534b842737547d98d2c096f53032b507025b0ecfe9206deab	6532
627	8b30d13812f5b1ec7c5a33ba5a6833e1493e8723c903a9dc8fb29ba04417d2e2	6538
628	7092f7455d6b9188abe230618cf38a71399b80bb7f81852f013de8be91f29237	6542
629	52d09a1d140408add34719c5c2c4025a850cf2038f3ea3b2338e5f7fad9c25b7	6546
630	d3f52fb5a691fdb794cb78e912543a73713eaecbbb76f12fdf5fc67631c77577	6550
631	d04f782a8da3960a73132520c40da5152af823db0ad986ab03c8b879c7737865	6551
632	c7a5599a88f08c2cfaf29c0589d12842377a3c1df97a0dfd46cf19461f803a82	6556
633	2a09e9f939dc5482ab7d4f21e28f979c1f743b75c21af52bd2b03d35b324911c	6561
634	ca9d3baefedc667052c670b24a44e36cfad03731eadc15fbac1dde82be412d8f	6578
635	378f9ccc296c92bf42721aa60d4abd62991971da2830e28ab6e3f2118d87f086	6586
636	a34b7f0fd4bfb93c7681cc4e9c184b3f9d7de5ad256f6eaccb3327b254baa95e	6588
637	c1eb9e96d899d7d63935cbaf7f5e22a130a6a3d4fc0019d271707eca8303fc7f	6590
638	50f6d664ecbbd2547c50790b5dd2bdadd7cc29f9187743c161e2baf333899c71	6597
639	8dd0688ce67c7cddd8314fa36dfa819013e2d39d13fe4e11b4e9e9f85aacb124	6600
640	3a67f42242ad3be79577a89d78800df05a79e45614ea220e832fdb55e9b45015	6608
641	e368d7c17023127367a99382783cf6a2dcc29a9f600a387d4b7ee8f79c8f49a2	6621
642	baaee300bdf0c8033a53b2b31666477a4aa3686262d846e5c602fffea3e0c107	6634
643	6274d65ec1210c5168184c35e8dc9a239fec8055c4e47103afdec5f05b70a06b	6639
644	773628d145b55f5b9a19b579a81698a49a2dc9cdbab2e0c2fcaa5b939cb3005a	6651
645	eb0850f1810a3ce59389cd6e7a96d908c81642f6b1ae7e97f3ee8caa8c1ec31e	6653
646	40eda8124a4791b6020bffc4e18f04adaefaa5c860a22e37ee41f392ecad2751	6656
647	085e74e3ddf7a73b61e674fcf398387ec1723e3d584ca3a807e5f6965587ddb5	6658
648	058c31c4244199ce876f8c62b74b836f2228ab4c1d878e2ece50eacfffb92f96	6664
649	315cf42d15217c023691e3fba7a992cb928693d554afc217ffad6586a16f1ab0	6679
650	119e2ddc4184daf8d1ca1f1947527f65af88399591cc2e22b467c163f742a4fc	6683
651	8125e39d1092e2cdfa6a166b36a9b773871de4c07db1036e11a483711edfa1a3	6696
652	cf69efc887b3786787581d272270d2c49e772e1e24130589cf252e03dd34b6ef	6697
653	ca9241053ebf075f28e285c21f50083c1adbbcf46f3140bcaac485063ff5139a	6710
654	00f16bc1a6dc728d229b4eca160b02d3fdd44cf01216d5b9b3fd3429bf33756d	6716
655	d349c1a2a925744be927c7734a8ecc03bf60ceb90376c0cbc25b8b2da47faf49	6755
656	5b966925bd16dbb2300b49b97e908a30916237043cab44e9cd93a8a323040d1a	6767
657	43f4e03aea418870ae4b836577428cff2e7f58a9aa635a5d5871866293706bab	6769
658	5633f760aa3a5470aecff1fba3f2f125d740de1923488ffd3a99df970e73198d	6774
659	edd10e95ead9f242a23fd7ffaf9d1a75655445fc874251390dcc587318221add	6796
660	bc7402b9f1c0d97ac1f0cc6c7e918c4a022f46e00f64a91935beaf90ab004e49	6808
661	a61a2951220c756b71af50968b48e6e36da4ed66e465fcd8c055e4fad035614e	6817
662	8d73b75dfadaccb0b9575e886e37e3af2b6fd0d0135e8ff13e6293371c01a063	6819
663	ecc72f74dec19620798897bfa634c7ca861f07f8441c82b98deefaacd24b62f2	6828
664	88d820ca8592539bf0bb1e8dbe94c51780aabe01d55a805fe2e100172d422fa4	6841
665	2f45325ecf1e4e7ed1539326d921b8418b0f06d7238ec71aea2499518b96992a	6846
666	8519ab50a6ac2edc238abf70fc0724929a302c692ff6bbad702ecb96eabf3ade	6851
667	e3d3e5b1d242c1dbef3e11d41e8a31ddcd054fa9e6ebff1ff17bac45e4f4b4b4	6860
668	adacd58ba1065eb09e9c9cb479f4446fdb23664b562b2498f8ed67dcd00db1c6	6861
669	b6ed0a92a5bccff76a36d91a7cbb16218bacf220f51717ce940d02f16ed00b92	6883
670	cdbb34329ae574e3519cb2227a8c2f8d13867761fe50bffa413dcf286e57a790	6927
671	3b9095bfc99fdd728c4491f84d39600aa22f8937ad3129e084492398fb910ac2	6930
672	496f2df22d38e7f7966d7e0800a6693539b24190de580b20c07fbec459dbae5f	6933
673	34a3c81cfa8240ff0acc5d05d3156409f4f3fd055da8b9d43d2646d020f5b54a	6938
674	3665877ff94b6dc3741d73c4e3c448b263bd963f98035bf6815ef30c5bdee82b	6949
675	f416d8cc82369053401ce9b1b290c6ec006de6cfa3f153943471077631928682	6962
676	358d6bfa6d68b5ad3df62a16aa3d7d78f152b71cdf7709bbd3e74db119a58a30	6964
677	3870f437bbb5568e4a815b4e0c1fe65cfdba1f464e7f09fc96144922f3139d4b	6970
678	cf88f49375b482c03e6c544f39bb68ca87102845a109ca7f12d5fc506c1534ad	6976
679	81f740e5cdf7984229ecc72f7f80ea9c9d29199963f6fe584bb17a242999bb19	6984
680	7b246bbdbf116e429e1f3ecab86961294524659b9514f6c051fb9de1290bb387	6990
681	85901aa588fc3c3a51f5cdf718517baed8476a1729ac26e9ae9a501dee66afbd	7006
682	ff9fdff101619f55d7f95c582bfe7be36428d35d8a9f7727654adecd87a06cbf	7017
683	3502a194f7b36c209dfdb8dcd0098abf01f6b0fb61d47583e916194e59e756b7	7021
684	1536071780f907e82459bcbf23885c5a6ea13e6c929ea41dd55424b44cf14857	7036
685	45366ac6385d00172d3237cff31a91cd609073d0c292c119810e89f9d94d028c	7044
686	305e36face96316c5f9f9c6ef5cce68b56190a7d179e999e1d1962a49875646d	7055
687	aa4fed36e1770278e87b7756d3ed71bfbd4a4cabf9461ea3de0d988514c54e4b	7062
688	088a50ce3047c94578f5729b1934ecb5e8006418d4e0f4d8ca62afc6a663184f	7088
689	1406099ef5e7b52e9720792b6874a6d27b93fc6a7c149c238ca8c7de92fed1d3	7090
690	7178563d73543d73496ec0c77da6ba5e1690236a972b1e402fb582a0ee703c13	7099
691	4da573213c224dca2d450fe6f4ee8180c8bb6712d76ca5e566df5ef553b1607f	7124
692	11b96018ee5e6800f6e505288062623f7e1d1e9b9803d1632f1a999d83f899c2	7150
693	1537cdcd69c07c8b3c0983b6a2df365cae6442eb01a75c8fc7d9a330d4aa6739	7159
694	7034e2b66bc08c57b594073d7127d5c8a3f2173fb1a373308b0a63ff31fd2ed4	7160
695	e74ec77962594d3176027c5a5b6211dccd1cdf376af8243d3212d6bf6ec1f5ff	7167
696	419d248847526297190e2723888b1c0bda05c1b7722b446e907f074b24eaa3f9	7174
697	040c9eaa1d7cb9978d8b6c971a0eec5d2c06c198c023a73795bd126a826ed6e0	7177
698	5fc718c11de5781c94ef4a73f3f99f6c7222b5553150e71a3e49972533713297	7182
699	058cd92860353542b369463354291a02fbb29982193c21f01ef4bcd9ccbdba0a	7187
700	2cab9ab5a3d4ee11a345ae841c9365c5ea2db1e88d5589a0ed8ce6c5a98b2cbf	7201
701	1fa30b225195308d8590edcf5db43f939a720b776d04562a706b68a92ba3e931	7212
702	7245b47bd58c913be5ceebf0a96186c61386318c4bd5a15ecf1eff8be0071ba0	7216
703	38069d2e5a3726dffea5e03afdeefefb3270cf131137ad0dc19e2c211b93b6f1	7218
704	49f40f5c002aa93f16bd7abb4d840962fba81fe28cddbb143e939c0903d7c94b	7228
705	73cbdcfbb203258fb24ee6ba88cfa7414fee7b077f9b9dd70d683f9c310db2fb	7232
706	e0b5f53c1c84a428e169816cade602ae1a465f308ce87ce9ca797aff83f718bf	7237
707	06902a2455ce34d5f1bac48ca8416efff8e2148099bce813d1d4b76746215287	7252
708	10d882a9d9562ae67d3963d872c66a0ef65bc8b42e48793a1658363fc09be147	7255
709	5ab9a287c02c6f50f132bacf1dc99b7e479738f112f131255f0b5e7503bb2d1c	7257
710	75dbef173fcfa5d977ec30cd0eaefa75cae7997ec53c99e110212fb917053aa4	7291
711	2253dc0b8b12f376dd99e0ce425d56e1fc861caa2eb4bebd0179212eaa3a7929	7294
712	f82f629bb111ca2cec3953642a57236ef669982f4c1f712370a35d0ad235c91b	7309
713	3406c55ebd2c6d7e08e6e86eb539cbf36f82e520c187600af5f1d5c397498a2f	7310
714	5028c6fec7b10d8a5328db222430a5f1dc14a7156ce8f3c52a6bb9a0d845c705	7312
715	7f2d60efdcc0dbda7d0ffedede0bc5cc3b87931eaebe335496b20fee81ac3252	7327
716	4c860d327501c6b795f7002dd3608f5b957014870d7ab7a09440fbb4ed0d3936	7344
717	ab36eb35bbbc464115b8fb0a28e4f3b82c0d32f6d37d4cd0c23b50adc40bc3ef	7346
718	bb2482e820145dc0ea66623b3932e1482f64ea6e1bc321003535c447c7745ba4	7361
719	29d10ff4d498670c6415ea78afa3b3edeb9ae3209689aa8140474130e0c3e307	7375
720	c49717b00976b832f3097cb42f2650166c5dc0c04838eb4e605bb1d0df678c9a	7387
721	172f79f62f8261f025cd419ecc11dd53615db20285977ec95743a594d11d5bc7	7396
722	08ddc4bf86f371c54c0ce4480c87c618cf5c49839e76294cc7cf85cf038da8cc	7399
723	fe7009077dee9a16185d9088bd2e0f746b6f0bad6ab5c312e3f6d0de1579a9b9	7409
724	eabe9d7216b7c8820e1f6b3fde13d714093ea8660f29e6c9845c2cae6b4eb1a1	7414
725	4a1e14677f27ef761c602a474a624f25698aac134689600e76f9f58a5190d872	7427
726	693ba800e989702d599a941943624fd3454b96101da6f71f09c59514f83cad58	7430
727	b63cbf788373859d2a291ae814f257d4e759e4277c48a0896667d704408ae39d	7431
728	fea932a62a8c08844d0d1df81a1edafe7a31d70375df94e5e8fc6657b5e9adbc	7447
729	53444c002bfd7aacf6ab146f88a95a491312c3b61000b665e9344c1fff84bf5a	7452
730	20a5d0f2ebdc618335b7ccc74b565792979650308a044d375379bd0a7e3828f7	7467
731	95b432839fdde3111fd7eb1360f88211bf93a4fd91a290a4fd27fb1c7502f402	7468
732	ddc3a900b61b85be10dd04722da35fb85dd64a547afb09d5f093a087b7c6af66	7476
733	2a3eb2c5f50083d2ac336ed3f9cfbc59af8e2840a6dd5a24e2699927f7037fbb	7479
734	7db9a13522c5320710690a0cd408eaf4d1ad181d769d2e00c3c155fc79a6eaeb	7516
735	67abb2c0f664c03e540e9d28a291d2c49db5eb579fa596807a1324fa4e118f22	7519
736	8c0f6f88f7bd4647ac0697b890a5bb3b5da0be98bfe5908cf584aadb249387b6	7529
737	0318472d4c286a3d500cb8d3d4be41ac34d777f262854c017d6527d59c083e98	7563
738	cc19a51838eb9f1596d0bf9533b3a77679a9a3468dda49d90b0689ddd7218ddf	7582
739	051f6e1d78a574b47a0ccb768ae1c40f0a8f01720db7283fd14aedb633cad5ec	7608
740	0a96e87c17d557cb1cc05e0358dcef1cd58992e3619b60c1abcd04a60b84bab5	7611
741	e3edd7bc585b360f8c5b02befe7b51bab57c8fa4fc0093c5722379ec3c752d90	7612
742	4c96d299bc0d053732822890633449d2f9bb5ea8da9ca9262f607c6ad4d3085a	7617
743	0b11b5ad23a66d5ae72cb6be62e13b6de772a80a95c3b08bb8cb383fafa67230	7620
744	f1e644c4ed9a7aa4e9f7de2558d77f723f6c94660d762ffa5a390d2e2c89f634	7629
745	6f3979cf3759674b701a5bf37b4fa11ac4daa2bd49c314e0893fc636d837978c	7638
746	9602237b1e7b6d2f45d9b69d40e2a6048317fef83c7a782586ce8f06ca9d5992	7644
747	e28b0ed48ef7217fa8b856703e92ec21521adf77817b1aad646b78afda74c8cb	7653
748	5815071e5a2e9eb31eb13d1b55181482ffac6fba6c58f98e525b656de4c47f88	7658
749	12a7aa3274f1ab2353f0f1b3a53da1a47c8353e40ea4ec83b725afd155ee76b8	7668
750	b2c381310b0657fe8bce57ed15a7016ba17f58b22a1e7fe6d39007ac01eaa016	7675
751	74a4cf1a1107d56e7da01e757aaf2972659bbf40348f0d045ba9711d247ea1f4	7684
752	5600209a65f6b181408b2cd37777700c766526258aecbd0f54d7639dccfb3035	7698
753	cc4eeb773a51638a2502a6f643ed3a808bba2d4856931e0f6f37bcf1cfca13f6	7700
754	b55b3cbbcdd4978fc5b145087e1ca33b2402d00246438bce2854b13501b68cd6	7707
755	a926a39cbb411b7a16994fae6eb8d550c932a639d7f1ac80ee4d92885d3dac59	7733
756	55b2784224d9502bc6572062a249713167dca4b32b0089be9dfb8c8a8fb04354	7742
757	a6605231d116216a80850467f7a066992edb35ea0e112385ae4e071f29ec0494	7744
758	5a726d30394cac4e6cd879adfe326baa9cd6800fda8bd678eea31c2083da2d04	7755
759	849ff21a06feb04fa1015a75d79d56470437b0486cbc2f2b5f8b9e173204a474	7757
760	9b84c734248c7ff0c3d5575d8170a217ad9ef8d0ff495d84d4dd15b116e1ffc2	7770
761	8beb30e36ba874444ed4a456dcac548739c1df6bde69ec1b5923bfe8e1d18711	7778
762	1a9d35625575a5b9073535e74a654909f8ef20e53fa24951e5b63f42b8c2b625	7783
763	1c47c4b6c6d19412a6c5412fddf590be52fa19ad23de536a521a9a19055735cd	7810
764	d6ec5a0f2ecdadbb44811e67dd93c54d55cbf932fa6d2c93192bf7ce916c1095	7825
765	5ac6294a60955855264f48eaf300c1bc8fc9c0f66f08d8678adab9468c1f3fbd	7832
766	6b084c86eb8b6a477e7b910f128361c95f03160f20afcf37fbf418a6227c8b2b	7836
767	8c7c6bf5fa27fd187ffe03af0a63db9cab6bbb0f4d25dfe68141fd53e9a2065f	7837
768	21a43dd2055ca56b1d34755b67118ff80a110e89d10d2cb02f1e0771cc1054a5	7840
769	5b1f2999392b7131afd671725702e3eae1265f01fe26e4ba4ac90c63d094b9b2	7842
770	022a30d685bea8d3065e1634e8384e5b5c7182b841963d925827045bf723ef0d	7857
771	325876c0d1a4ec61aa85a3a6087bc8974cfb8df5e9936f8d06ee8b20475fb5a3	7863
772	209190719969e7afb837869a7fe7dcd85d9d902c02b73c2c88e1d4143ebc977e	7891
773	3b6e0f2173a0ae5ddbd8787063d98959819eadeed5bfa760271cf774e80a7bcf	7897
774	8e97c39a5bfb2efc057fb6a7a91d614dd75cb60cd5ac80bc624b2d0eece7b052	7912
775	f98e8ae796533c9ffd40ec1ff2f8d4ee5bb10471e198a82eadb96d5467a9c31f	7915
776	2ae19a9c4dcdd78dbfdf8bdd32d0e1e1ef87846c94e9c0767b573cb0d685cbf1	7936
777	5a5336cab3f8cbbec315d35b0703ac85efadb8f828ec0af7519cbf1b2f033e29	7961
778	f124990305b11147ee32b8ba6d3bfdc6a52189c2316c1bd422ab7984371b1394	7980
779	0967bfb52443f6364e2dbbae2bff89b08e939f4390be9dbef7d94ca2955a4627	7989
780	b919f87482b8086df2cdab97d50982b0cfb57cfacd453e0ef00b00c9ae21a63d	8012
781	fee0da1f3375705ce12e6953d519cd15bead25f35de47b8c5349f1fccc844b07	8015
782	898ed907044c0f8f5237f94160c780a6c9b355bdbc3263f22b70ad12a1422a35	8019
783	9fa536c3c862c176283d6a4ae060664ab00a5c6794d18d90433c136cb77f8862	8022
784	e57cf4bb18a28243c5461f912d83f8bbb01dc84580702992346a34b62c2af50b	8027
785	3f0e29276ad136bd85a0308857797efef80296d387d99299fef34ee161b6f69b	8035
786	6e40a06086bd2df428ad2e8942d855e8f6d2bc0f2ce4284c39125a93c0a26cba	8036
787	43f0ea56fee114ee23599c8872ecf4894426ade51ffa008ee5aa212b5082571c	8041
788	1cbdccaebc795110ac099a6d3a2fa103af288e61f53324c19eac02168c551329	8043
789	0949907647efcfedd245f06699293a4512cf1012e29ac3e49de3d598baeedaf5	8044
790	4fa8c224c3a3c85f3e62a87b955ebe47618065ab5ad9d501b6dd7f20a9febb13	8046
791	f3b9ccc69986e254b14244a327533ea857395cc4fbc1ef0d796d050f5f698351	8085
792	d78e453575c79a76f47aa3f04402186ca526bcffc24ac430122c34e8b8b3701a	8090
793	cf57bbfc506c60f98b312d56d52d2f1c391bfa8bfebd6ddddeb7ff04484bebce	8101
794	e12ac05bff18829fad6bf9f0d30687bbd589aee8519574e3e976dc33d5c5ac8d	8102
795	5da6c6c4c8e46838e2aaa407470695a7150aa39e800f8fc243e122873e571017	8108
796	ab27487596974cbfa3eaf8113e2b9c173eae691bb0aeea16b3087d5d7dc7e736	8110
797	1e8e173b2c65e40d4804d6c2c8fc9ebcf6c2f26ef0c0aaadd8a5fae7d925f3ff	8117
798	c5b4bb2318e304aeed51b632c2df80742ac94c1b40ff31b109b6915ae8e20db1	8124
799	c52a433395ed0f205eaf0ddd2b0d4ec5151427af8ff368f9cb022c624aa50bae	8145
800	2faa12b99aa849a5152b2b3d3f8eff9463dcc1fadbdc2e86fed6afebc24900b1	8154
801	3331e28cf522a66d181cbd8609627ebbdb4b53ecdce4701e63a43a96b08b2f17	8168
802	e0a6b6780787998ecabea5977065fd7387f423c06bc1c505aec29b97ff066a77	8171
803	0d8a839a9e13175d7a30fec43854ce67a5aaac7acde9f2776781c09d34556b4b	8172
804	25b09ebb9dbe84f7dadbe72186099b1dde8fb5f963f68506db8a41f37c1ff4cb	8177
805	06456ba19f7494f867b26b0a013f413cbfe6aa17b4e3e046847693ebd1b49519	8192
806	543ba6a311587429896f68daa3591653a754d14b406669785b729307aaebe38c	8205
807	61e036d46e22bedfc8acd25d3537cceefc57992acd81bca740548926cee82deb	8206
808	a0feadacd6758f6f4237bf50dfdbffc1ffdf8d66d1ec73688a68bcb7bf03dd75	8217
809	9a73d2e5eb3c150b25bcaac833f87d27a7fac77ecf5f16bdc7fc40b1e95254fd	8219
810	a2b587d3ce4a16d751d3bbc0950f52093dc55f9f7abc583d4cb7dce643a85a6d	8225
811	a67e36bc62a7278d63d725f5d43d9c710c9c65d73378e08c79081c47d48481e4	8232
812	e481f62b3d78bf6edf08fd0b71024650b044e36b9843f74ad0a8c2856e86d5c3	8236
813	8b3fc25e14909ec808ee1562ce105babc7f16a362ccf3c8e78db8a64587b0bf8	8238
814	a9aa7adccabaa2dcd918132a4742d0edfae5dba912a58eaf8a2cd5b7d446ffc8	8240
815	6b7e1e1a63753bf640032d218fd2698e49a5dd46f6e171ba88fa708902f60bbd	8241
816	4d609f71373a58c76ba3bb11f03c0f5ebb191abcbc3eee40f5554a7410d09a8e	8243
817	6e383d69fa4386c76dad56a21711ca014edcb28e0d86daea69fb9475fd84b4c9	8253
818	b8dc695685ee12929c7ae8c16211d1b80f4fb8a2b8552b18de8f555a1d49d662	8255
819	c438dc09904d51a9f28f12c5bef816c2f206a2a893540ceafc5ec18f484c52d3	8268
820	9612b4eeab05697912c3fc44e3e2caec23e373fc5eef7d31c458910025fa466b	8271
821	e233fc67b0b95ef503100e818017207bc4042ae194003e8e3a061f4e1503b769	8272
822	ec31bfece84bc97c46d8ffc39d7ed39c3c925c77d5447a2f1c25c305e41fb53a	8287
823	8d3d57f2a8d44605a7c479b3579ebebfefbce25322b91cf5ed2e186aef40b82e	8299
824	051bdb1e667b0b4f5b77071ca74d3677e8776d26992d3aeb471854cd72459c65	8315
825	bf636f65b1159069386ba28cb693fd63d4cc1eb1d1b44f703d69047a6e6c3c89	8318
826	5820978203998376fc044205f564cdd2f32606ded5ead4d163c856fb6f2b6552	8338
827	39f6c2b4cf7a93c6576e60f8375f068bcd9710353469c91d8df7cea3ed542556	8363
828	8383f03fc1355738e285551aeb66a1b6337348af5215a55778e4304a5468ad3c	8372
829	889914631834e4ba230445a14b827da60ac51312fb84d1ffe77ea95f3549a1ed	8375
830	1d05c3d21fa601430eb64046697b452377266b16c749a93cc521de80fcefd07a	8382
831	a7928704119f210739eea96883198fd9c199815ed968c066ef57e3693f87ce6d	8383
832	8fe34df588ef660a6e2c8b5b26ce2aa35ec24bb345dbb2b69c6231227c524384	8398
833	c09e28ca5f978c4a63ff2bb31bb94caa33916142b81dc49a5d3ef090e04532b8	8402
834	d5f55e746e66079d2c8538c489fc09efceb9767f48a0b5ea52b467a3f257e1a0	8414
835	91184e776b7c6d6f1483b69a9886b00a21c8fa695f6c607518b5112037123592	8437
836	7ef4663f209646d7b5d4ea432a7cde0105f606d1df2877500e9f4a1cfea2a744	8446
837	15c26f965419a0aeed26b0acf3704d0675991f7c40a6d1a8ea62c4d262f0e73f	8450
838	8bac5166aff5ef355670b010e7afcacbe8228fd491a4729248e21d0602d3b191	8458
839	337941bcf80abaf029051ee767a4198a8b22441b8727bfca644cb84c3cbb27a2	8460
840	ddba32b8bc92a524ef9a65e56f6d1d63b4c44d06203940ee83885bb2c0cf57db	8462
841	5a10b85881dbb0805c6194a8379d1c72a72d6118c53b8cd5d6765bbe80f8a336	8468
842	47380ffc019223037c1cf29afe4c7f6d4bb1aed4e1b478f37247689616c4fc2a	8480
843	606e2e449e94dd915775d5fdb3cb6fefa3dc69d50f8035da50e50a7762ce1f63	8481
844	67a15aed1d5949ac6dac2a3eb594dd593fa3f714830b748954ba1eb743d90108	8495
845	1a7c230cdbdc460bf6040240891fd76fee2cf2b5980e701e3b9329cf4e037525	8502
846	b17ccc763376c04ceeeffda8cbf1e47b68ca12e1791f1175aeac4a8a809e8db6	8506
847	5c503bc767e10da7baf505a713caa7e728a13011dce28bfe576d7c4d9ca1e790	8517
848	4afa8b8ab2c187cb7fb776aa88a33523d5ae929560aa02072593ccc4e831d0f5	8528
849	75456100c8bc7cacee9ec5abab9ae088522420885279bab9d60b826cec33ec03	8538
850	de3343645b5fc040f3bf4a21f63f1e973afd7efdb312f33837936147f1f74c60	8598
851	145c542675519611d748b6b4987bacfa0cf56a1a8b1936f7fa0c313c0934f84e	8604
852	3c2785bf33a6bdd742f7c689eeb6ef34591b24f1193b06fa4e6aba8e5d0eb4e1	8612
853	f28c8b25c5ca447314d5e1fc95f936e14ddc620b8c645f77b3a992d6e4a9f317	8626
854	85e208adf3507b64172b8e2796123f90bcad4ae2949baa15cb07fd42155db257	8635
855	d828469570e6109fcf431bfa9c57c8a7b53d4bef67a3f624c1bdd25702496e3d	8638
856	3d702e768f7fcddc1a88183c79162d6094ca77dd7682ca0307ab1136c44cd51d	8643
857	3f8822f7067a8028165119f92a45023635f5b938aceb41e4b70be25be7ed5851	8672
858	8faa724cafac4984aead9c972da7b9928ddae255454190d75eb396bb037430f0	8674
859	bc9ff52946ea6cbcf60daf5889a71ed5b80800671fad247b08face251c0952d2	8685
860	7e56ead58ec71f5c332df5117666ea979d0684f1a52d3e455dbcd66503dca75f	8686
861	d7e35a3942e94d72f2385cc52a7575eaeb12533de133a66bc9b605696dfd6a14	8694
862	cd5334f7341fcff72e1dd2c95a652ae720bf9d788a2c1ad171a6536b93082ca5	8701
863	985eac9e9a70c79eae5b2e8444eb3e3c7a669eab3f3205819a89275201876806	8716
864	daa00ca7e6d2d411a6684c69021c435fe94895a4459453447c77e497a1c71b27	8724
865	df87aa5eb2f7272fe592eac5add28e92480ad413f908574af07af4fd6e163fa7	8734
866	e875dade6e67fb8b1e821a0a141e451e5e970485254f4818881b1b080fb31fe7	8736
867	f5cc090696e44fa3b165f964961e2bf049a63afcf5e293cedd32186104801808	8737
868	ad43e717e73e2dd110d2ca13d26267ab7b0b033a3f850a92304548edd1d35305	8743
869	20176e42b2984859d21f34182642076e4f37812f70b4783c7f6ebc28567b4ee2	8756
870	ac07d626e63ba403f2c63197891e7ea21f1302c79fe2ec26247e6759b5fddc40	8763
871	54ed0b915efc59482816ee8bb41c4ba6a3bc12da233fef94d22ccc8c1c32a715	8786
872	bb90cb2d009f702cf1f1dcfc8f8e901c61f7ba88ea27c3901a50f5314522b170	8789
873	d43708e99f7af6fd7dce71da81dbe0d89c99b65f71826a1f7f5f37f4f63ec538	8803
874	496458479eb11aa81e5ea9baf80b9c8a2f358e700142bf8533e12a2c663cbb41	8807
875	86a1863779a5a9df2b887060a9d13b757196531259863756e1ca56f7d4db297a	8818
876	acb7ea5a940024ae2ec4bd3d8bf84b9284850a6bd827de5948e14e8e9abc66d8	8841
877	32f2852f5ed83659c8ee1bd6a0edc9a978497007fa575cd90093b17a1b478e75	8843
878	87dfc918f8d5d077496db8e7556b226711f744124606b9c04e6b89b27a872aaf	8848
879	cbb5b494e5495b2d04c4ff405dc2aabf870dc1fda5e6d140fa9cba839060abde	8854
880	33e92532f8f0d6aa75b0265cdae0562d7faf6f7da49e3f4e2b0503b3d2c7fe7b	8874
881	da97ab74343909097f9b97dca35a85f4e088fdee0f589cec86a777924bcdbfd1	8900
882	e6539038a2b2aa5a0c3d1648bf596a0d48ec11621320345a114277beaf175a99	8902
883	3d6f4a4b1450b4ae1d379a828f438eba18b1e8f2cc561d7af6b5b4d45f58a3b8	8904
884	0cc240a5603511b705ca8c8cf7d3634d3edc151028e5886a2fb5d6786087068c	8907
885	c98b4fc5efd7fbad8bb6401d5a0fdb8bf814efda40ed059c4adf83ce540950c7	8915
886	6a79f68963b47e7edc13e2433d19f78863adc93f51e3d06c74fd513f4d31479d	8951
887	da2fd38800022973b16a9181e9fee4f800eab20b3cfe7c4e41013de7d1563761	8952
888	0c7cec4dce8772f5bc3e38ac7c1432344f202d322726c5a81ddc3aaef853971b	8969
889	0c79b1b12cf1375a8344cad1461f03757b7378269fd71841abd156957f7bf052	8976
890	abba4ff38aba771da6e1ba9aae4f50c31e79267d89f64b018058687160992ea5	8983
891	764e9470a2880d05e9b5279cda31ef36b0ee60a4e65791f30f744cbffa8d213f	8989
892	661325fde0c593286547bf2105afde4c74d5183748711d7275d44d524980e456	8990
893	2f280d25ec544e500abfdd5b337ae3524e8cb18b1ced79e3670ac9259636f930	9022
894	c7ff1ed45c8bbd4993d0cc9ff95e039d71ed8979c3e5ce65c72a4c7ee1f76388	9042
895	74d9acac88a678d64fc1cffcaf1bd19ab4d6df886831587be27d51df7612fbc2	9067
896	9e2c3e409b49cd2559066bdfc084ec076fbd0f114d57a56f2020b92c9020e8a9	9074
897	64bea9fac2e22fa08675aa8cef413c5119a0cd95d483aaab0b16737748db3fc4	9080
898	0f24db5dc410507bb4a299899d42cb0c4fde8c18e3174925cc88a0abc2813cff	9089
899	ce81fe9db83be6e67a70210ea7baafa0b6d00aec9ad3893b02a355496d39cdaf	9109
900	cd0332c99a8ab5784fdaa40ae0448c45564001d8361bcf4406b68d30b1cf715f	9120
901	50cdc7454c8635e7e878d8e39077601609f168b581c87f95e99bdbf2b4c5d68b	9135
902	d1856b4987c274218cd4be030e39ce05ea15631513f1ceb745f3cd63e465d31a	9152
903	3002b6c8aae9e06942add06295fd75b8235f2dc83aaffaa9363c4f083be6b170	9161
904	af557c0a8630f54f3002ce5a9546ef2662e3451fbaeb6da43c8dccb761d21ab0	9168
905	e940a38ce9a8ce7d6369c4277a683a8be6a1da8537929f8e2d2b222d9e4df01f	9177
906	38260b7b8e20c1297ff0b636d15854f137154769c97ff46216a3d4dacf8be1bf	9187
907	3668c53301a87b6d64e08cfe123726449a37349b44a039501b4151d3f54bac37	9188
908	4060143d002ebc1bc9e1d10331e2369e4f77ed2fb727c107fa3a318fb50634ed	9189
909	77893904cd9723b9546bc5782be3780d3651284418545f9c91ee3bbf8d753dbc	9209
910	ec2ad8f7b443bef0dc2e1bf544ff595ffcb048f99182fcb8de77134cc77daf1b	9213
911	cbfd9d75532d70c5144c54369cc92f452e5064d2130f44c7ed5eea7c5ec0f297	9217
912	401420d9d771750606814d32d00f17ce898e745a9b65ef5ace18bcdc9c5c481f	9234
913	01a9322e1a368735f5ea5a00e92780443d4b0d84624b3ec097ca20292c91b1b1	9245
914	d6579446dbe390de93466debc300c93b51545cefb4d0126c7769c8a67e161170	9246
915	984655a4863fc5cdfe1e79a71eb5bb4c96a1eec38ff0b1b92dc59617f167f673	9262
916	fb4990fef97413101c54d90c75cf57f8e14d339e2e98a56e114566af62b79675	9279
917	6c94bfba52c6cf33ee5540c0ac78e50202e6271dda4738d09cd3490852ccef33	9286
918	121180c14c30fdd29f6dd4c33267528c27de4c954cef0c45253d93e2c64c5db1	9290
919	154f5ba330259015fe4a2a8c706ad305f1411d7680cbf777080b3aec3f35fa12	9292
920	512311ecbe8be568183eccc32d94605d6ea7cb6b96661455dd802c06f60ecf3e	9296
921	0d8cd8adbb3756b8b9de7a9b35011ad5f18cddf6ee8a21def895925cef7f0d59	9322
922	614d4901cffe394759aba8854bd5efe8b6ed656477ea59ef1039547ad4a9e82c	9344
923	e73216a79dfcc3a170b6430f055e38dbde366fad1b35a6f018c636639e0c921b	9356
924	6ba0d02a3e425935f8897d56a0fcd47c8bea714807b4579b4540f5921e5d91d6	9374
925	ffb275d44e8c759786d24138ad19a041fd81478c6c02664f1990820779ac6969	9388
926	0e8703912ba5b24f44e8b9ca1e4fddb1bb0d06c2630aa8e6fed573c8e33470f9	9393
927	1efa16517468a133dacc5a1ace3d67d72a6d9b5d21a48aa3e5e29438726b14c3	9397
928	06125ad0952edabc1b438613e9d1c58f882779e34ff26652096ead0caf18af3a	9402
929	a9a934f630e207321174e78480eb50b11f11742f71b9e9e43d0c1ed65411ca74	9408
930	03b2e4ad35868355846a82b350eed0aafeab515d5a3a6576004d20a3f17f3a3c	9420
931	fffa800af4f9c186a3969816a3cfc4758ceaa3d97dd480f115d34de8addfbc12	9432
932	04aa2c8b271fc71123f7609ab9e7f69be751df73cadf7bf9cbfb47a10b12ba22	9435
933	e6c7fc3fc9b383f67c310f80b427d86348afa6cec4244e985f3547b8537727aa	9443
934	34d07f65131622a79a6fec5f211f73b509b4674151bc60a039d6c75e5caa76a6	9444
935	6838ec19c0b8ac49d073a7997e4d374f80c1e5d3869b72151868f8278e15bd3c	9447
936	e7c3eff1d3c3e847b501b87b492410d072402c8068791ed2b5ff7970092c7665	9449
937	4d04da2fd59ec68ba8423ad358a9f3a623bfeee03ebe4b7e19cf39cc249b858e	9454
938	5746a40eca3fb151cde551c25d753337bdd072f11891f2bd1754669327098a40	9458
939	21affdc78072f180c2b30a21f7c29d58edf0e519a000dc0ae60c3f1b0b75f58b	9462
940	40f73712fef4a564df9f56e812518c168af6bc7d60dc8a7f43334d1f633368fd	9463
941	8bd3f355ecc1eaaadcd6bacd982e3650022d476d6ce421f71889bd8103abe8a3	9479
942	a9b2d8a75a96ac7bce0114005f911917ff8f2125ba423ca0325ac5325d5d58e6	9481
943	f721f4e325ab09223e9c5987cf05d5f10591b548959988b90cc359c920acc64d	9482
944	4e6a2d4697e27bcc3a4871669b2c7945fe5923c09e71d578e3ead885c5666930	9485
945	9d4e3130f14bc735c7e0f10e8a304a89e775a85b99ad4dfbb54eea13dd241fec	9493
946	dc05f6a68ed072693fde277c72caf7468089b4e304301284aa12e8e61f43ddf7	9498
947	c5fe181e23e5465aff0fcf5fd5d9d079128448c7d79258d4a49b52e9dda84b9b	9501
948	61dea4d1cec8cfd34100f17b6f73ee1c87b6294ee7a70571a0b70e7811314d0a	9525
949	8783038ab5951e174351eb1fa79d13a98d3a9d753f4f4cedba54e5d76834a1ed	9537
950	ffec6fa35e73e9320dd702d8789e2c3d1a0062e256452b2bebc44a0654c370ea	9546
951	5ee9f9d58da9067a6397aeb53fb44a82b36480f37971a10865f059b4efcac24b	9547
952	02b9f38a923425c9b07b7487e3b5b6cc6463f6be7c3373f20e64538afed5c28a	9575
953	edceab4d72aed860fa0965c4346871309b7dbe4f9aea0c7237237ae60772394f	9587
954	0df959a57318e9319bdaacccb7c019a7dc8ec1eea4c4e6d00461996bba782cd5	9595
955	c0c287a5abb494fcab3456586eeaaa9ddec94f474e71750d165124ba02b9a0aa	9600
956	04e37535ed11aa3bc955cae16a2d19aa3ab4435d47810b486a529ac574f291d9	9616
957	fc6ed68293c0ba51a7ee155c3c4c806f32156ae2e9af7649821880a5657d8f87	9618
958	132cb50406a97ceeeebd47ad6d91886f106309be2f9993476a0e85e4cb1b5e5a	9621
959	9e9206c884ab2f520bc5913a45ab64b3580f4a96f8aeb70a1aaa88c1150add61	9630
960	67a8d2951c63a9505b6fe450342f47d38cc74e4dbe1fc66940fda1c2d248b421	9659
961	e2a9cfa5f123b6e680805913cf3b831ce11fafd1c3932b1433594039576813fc	9663
962	4d0c77e934ec3fb6088f6400b1465bd77eabfa43a49c6dab720dcdb78b84e008	9665
963	20d7560a9b628e52ee62f5f7395ed3340600a00c9d04f4f1136dc4c21becd048	9680
964	9f3798afb1168d76a4104ece026b2de7140d1561667b9327ed48e8f3d1bedb16	9681
965	cb3f3b739fcca11bac666a35b281f7aa22d67f6e92d80938ce89ddacc4b2d467	9689
966	a25215be700bb7298b74c21386d17beaaa0412a64fdcbc7992ce450eb12329a4	9695
967	a8e78d0277282cc64f844b16e0b7a567db30534f9aebb3d7ca6a60b3146055cd	9696
968	1e31fe5422511080c19f16594bab5f5278f46f799de7b6f26e722f8f2105173f	9699
969	dd4db31b5ea0665b10c2c697f4ba35e0449bcd8c25bac1e361d75e77a5572c39	9703
970	3d54ab913a6da7ec0004449664cc8391e51849614d2cc1509d7b80cf8fe30aac	9712
971	1bd06b2505180d171dd607c25444fb2642bdfc12d421719511419f6a94be001d	9718
972	53c02d3db5ad9b82448360c7a2166c0478b1f70c9096bb9ff4609dfdc163ac29	9723
973	9971c77540f72b630ee4c88d6a821d763f0868297309545676846ef6f84da5e8	9735
974	75109dcb40d41486d5adba9d41daa14c8ee74ef5eb49def9d077316c1da06b11	9759
975	169ef7273132846d6528ea4b3d4880f9000802b1d9240c9bdba5a10883b81b39	9765
976	6274e094371caa1e09aab39b2f23b0593b920f704acca1ec1e5aeefb7c19c3de	9785
977	5ca95bdc1578cb13d835bdb5f9df970ef0a7ca5f7987297a3be2a64cd019454d	9791
978	fba962ffb207f6bfe0a4d15a5dfac58cfa001b0801b25f61dff13e17019e4930	9831
979	0d1a984a12a07827b955b4ed7eb7ffde5e56e9fc413b1da37a19500e4b493247	9836
980	4b96d8d4214201c410e37df841a55382f639e65c1693c9aed9da63d8ee236b8a	9842
981	fd7d12c388b27ee34e189cf49c529b0da59751f80308f9b128b6427ee2e47fdb	9845
982	70a9bdb26cdad6a32c5ea2fc7fb7b6cd529b0054bab14f61ac5a6d7c1a4497ef	9870
983	8afcaf73eb01ebb752ec8988e2138473715b883e3af530db42e6be2f87fae8a8	9880
984	72204275f5e767f54e1bc44cbd824f55eb1e79c0a1fa590b22b7d54b4645cc44	9895
985	98549d8024e34a9c661f3fa39a1a623aacf25cbe03faa5cfac74dcecbc81f427	9897
986	a38fba5cf75abcc49d9facd0f0317fca61e879df7959856989eb35f3755f0079	9910
987	98301828609becb60ab2e828ee662ca598bfdea4b1f56e6c9e834bcf422acdbb	9929
988	a569dabda7fe1a1272d8431df548861e0eb8bebbf26fa0ff6cf4694999d9ca6c	9932
989	420d8390dfc28817f19742b41cad917d408515ee8cde2c8f9bbe9b31479d3923	9934
990	299a059212ee735ae8c51a5790a78b6087dc6f5a976ec4937aff9b957fc1a271	9945
991	ad8bfd4b01459dd7322183703c559a99d50cd39c06ab8eb73218ff86ae38a5e3	9950
992	7ead0d1babaf013a1bd8f5bfbe6397f02ea74156741ff5ec8b4c2e3869ea6d39	9965
993	b52b62d029de43d842e342027450befd78fc4b949328b1400135321863b598a7	9980
994	86fe79d03170ae34194c37f53184c1543cec9b58f9e0866be2e44ebd8986094e	9987
995	a6cbf3720576abe2a58d05c6dc95ffd6ad3460f2e00083bf8d4022241d056d2c	9997
996	6ce03e311fb9f7fed9eaa7ded86a58ffd8eeb6c1fe8c8652f998e70053b610b0	10004
997	053d8031039660f3824bac5498c63427872d8c648006b793537d49d25687f611	10006
998	f295a3c757fae593383d9a0ae1577db3fdabe6fd778b1d14d1d671f82d3dffe0	10015
999	d018fab15ba8ae9d360e6eb8ab0f6a473e6937642366bceccaca2f0301e041d2	10035
1000	3b5d636b286a534a438c7c0902fc69cd99eccb1ab655fa4af91984f5c301dc17	10036
1001	5bd9b037d8a4ce1c51edc669e503ae300c782b3aea20e1dd5ef8bfc7a70fbbe9	10039
1002	1ddb10f4329400cf76e025fbd076d21ba83d07edd5dd142efd30934420ac693d	10043
1003	dd6ab9f2e57aadfce65e91b9bc030d63b79bb1feb2df7e88f87c88ad0f8545c3	10052
1004	4e651a1404ac8036afde11b6e375e507d143e98ec4cb9e6aedc888759b9bb02f	10062
1005	c53f78d5ecb54afe48e03887fe377d0111ef71e9cbbb54cf059063242db6fadb	10072
1006	3bf8afa7011280a4ed622400e8fc448d152cd4636c0813719363668993a8703e	10097
1007	f711233e5d0266711f25657d08b4790016bd7f52b3f980311039e935bd0c2898	10101
1008	19683cd965168d0b4c75eeff67ffc811fa5c97e6f7a892f320de7cf77e681fe5	10110
1009	d2e2100b1ec1504ad9c0b284ae890a20c158d821494070e1ce1986bdfce577af	10114
1010	2852a92ec77a107e69ef9b825958a67b48636cb7c0030e329dc504e2e980f88f	10131
1011	36a3a43787a0ce9fc54b93f055a1b94067610457d7af5710aafefbe9ef5513c6	10158
1012	a5b437404bf3b428d24ed0bfc2d98ee042c7034d43d98d3adfb27f0d6d50dd29	10168
1013	daa3c36cff4efe4444ecc1a76385179c87368ea98fa4bbeef5b02d536b49eecc	10195
1014	9f67774e6301d9784ea494e63b8b3e72d3177840d1c5f6503c1adc95eb853090	10198
1015	9d929e8fa9d4ac9c3732b4c7f5eff506e950282c134a2be0c8e1aeaad446e5f8	10200
1016	bec946930bdd6ba8c648d8388051e35d4d4f73400ba707b9d170a7b42cff35e0	10207
1017	0d720e17d11875c3b1716af005038e89dde6a3d8e94ae5a41e11cd1c67407a78	10208
1018	33e49b07b4a11896c6942b18a7f3552da1d2af4995d2e5234d12d936e66b84b3	10221
1019	8a8cc356cb558e28d42dac8061ee4ddfc99fc3f9a6702ecd96bf08fcbd0b184f	10227
1020	95297e9da623581f58c2010d0543158e98d2eda62139d778dbf3e7e14ee6d837	10235
1021	a786ba1396cee4ab7226beb671340fc0ac0e0a18ac1407887bdf7732c298f9ef	10256
1022	d9575d940de53bcba4766dc9e3a9ef08de59c81723758f3962f3f8930a1a393b	10257
1023	6fe7275127ebe3ca4e01d35ffb67d35a2cf4e3a7243df7ebb8e866ccf68b2c97	10261
1024	73639d52da3271e7d0ef0da92974bc1f3c938b04a7c116ec337e7a7e253d5565	10276
1025	87f04e0d7068e327453b166e603770d4bb435df797cc9b3fde4309c1b8423bcc	10280
1026	79a5129e98e78e6a5387c8eddce2fb778df74ddf2d51bdfbb2ca485cdfb05c7b	10288
1027	ff8ba0a827138596c22037e9444f873b2b2eb4cce461d66b49d177b2f98ff9c1	10301
1028	c8b0bc57d603dbe9820ab00e3778c28675e219e831827a36abfe26ed3f700cfa	10321
1029	a51dbbfb7fa522f405e0932ca9987654e11d09e43742bfd09ee413c50b1bdf49	10326
1030	ac9fd0a85c344e16b44dff32bc40a84c7aad7903576377fe03961687bd4b53d2	10335
1031	e14a0cfdd3d028b10ac594e215e11dbed756911a1d20b02b3cb444c78a4e646a	10345
1032	f735db19a91f09057332d409acd78d83faa53824ec380731edd05e98a5c52271	10349
1033	9aba43f76e8fba7eb04d006d3449f139b00d63912cfee83f6ae79dd1676baf08	10365
1034	c3b90ed8f9c1b7b01c3f180f2c472beb985d09c85491428637484eb6ffff85ed	10366
1035	33da418e7ca9d9340634f4f99e53b4d8900d916adcd989f6bd61c0b108115d5f	10369
1036	e2a57fb08eec00de345bfbe5e373e429e04043c337c951143f49547b72341ba7	10376
1037	ccc17b70ba4a4e266b75579f7e2af5490c2ee352aa49c5da427872f7e6f886cf	10380
1038	90b39065aac6dfd9f9b235c5b31dac5368c3eac8c47257daac14df84822e8117	10381
1039	85f7d6f21e569d4794441c5742dd181dfcac22c02e73f5521690cc66331bd764	10399
1040	c73fe98770bb4c0f8b50a5a8241c1ee0bfdaa46c918506fad415dde3b0ac54f3	10400
1041	910a9d12789974ec910890d8737bea03422cdae8f7e8edc11ddca4f7708b469a	10402
1042	e9ad3a0a005f80f3397e17752b8b138f64b7e5c6c2a4b506ab92bf3ab95989b1	10410
1043	5d8e586d5884d6dea689985c09ffb92959a74e86ed3519e4fa3c148004a0b3d5	10448
1044	16cd260cf754e3e0152dde8119eec97a25780e3418baec898ed6af3286653505	10450
1045	06977bcb9098f7fe3f85e8e41e0932f153eff98894ca8b71ccd80b35484136f9	10463
1046	cfe83569c1c7af9ba9e3110727a66d14a0d423a1d7b6b1210a2d091d6f845c6a	10465
1047	ab7b72219c22630e0d2e15840b9be549b3b6a7ffd4fc754dde3f70e7d24e65bb	10471
1048	576d9f0ad36a4a2f9f4c97a39e3b11541df1009fee22800e755de78953a4015f	10476
1049	238b54fba54f14a99fd335d60a6a53d964b203c944655218f15767a252117167	10477
1050	51feb380def2d3ede587accf0a6553c35b6c73d582a8b770b509892da4fab101	10500
1051	2fe5005573f3bc2f2deafb1fb86feb4492d31229146ff566b7cf3e0c8ece0491	10507
1052	1277ef014fb10ed14de3b12995f5fbdc78447853fed6134b8a3287cae554f02d	10514
1053	17c59e5a4e8a134fdb6486f9c9294054c7f6e3452615b1254762b71560ed18ea	10557
1054	94c0506fbed67b9e3dde39e7420201b51ddbcd9779adfa7e880e9ae79ed101a5	10561
1055	72f460c4d656d46306c5e44d95644e410c14f8ae5a0d37edddb1de1142cf5dc0	10587
1056	b960208b5f4263c920f08fc84a901b45bf919cae32bf7a347f50eb787d8eabd5	10594
1057	50337db818f88b7a7c8ade4da5a022743b91bd0e9fc8baf7f911a9969d47ca9f	10600
1058	f4cf772a49c4a1a12bebab8250eccc2132128d722e7fedc7d8fd272bc4a7f78f	10602
1059	337e0345f9ec7c451dbb9a00ca94acabc709d3f8b342f2437a729f3718cd6213	10615
1060	33561615137f8f111b7313e219350397ee6de7078f0e9f1b2936008ee1185ca3	10625
1061	a71cb4415ced141bbcdca372375d0a0a77e9ea9082138f684ff2f1b7115168df	10637
1062	89cfd5ad55f3b41904db5a8bfa180dea490d572a7a87957635ed3729d6356598	10640
1063	d881c57a0df957fdb8ea94137db215dfaa1e90cbc2b8125ae6e28e8c956e82cf	10650
1064	f4ccd5e04b1d27209dfe7ca2d36407e094909fa711a093c0173edc10512d7a0d	10662
1065	9bf50a1b37bdb9ac77249b880b91069655f09875e3d3c235b678e0a963e7c5e6	10664
1066	9caa049d25879f245ca22198776b51825b52672fc65feaa435648529ecee7fd6	10680
1067	2b6f8ff51d8a1ca970f6c2bda5e277346ce94e59ea655be0e21d3c146f011939	10685
1068	3fdcd4b2bc67a7ce76feec64ffb8716809c181b4b7c1185eebc94427a717ff04	10687
1069	f85b4d2695d24c3aa24c06f465c9a209e29b0c43d55b63981c5254427bfe6cf0	10708
1070	869af925133ad75e63cdd3e23cc2142d5db01de404a6bcdeb06571b7dc327d89	10717
1071	5d6083a72a6e557760a9888f83b5e1f4e0ee59619945d33b5bf37028b04c3fb0	10731
1072	d6fbfb2ffc787236f348d49056112212a18afa8f7531545e4273e0aad7ea0dea	10749
1073	cb15ea319491c7494394350c8ff55e94128d67f7dc06e0ddb9233ebf79079fdb	10775
1074	c6c7ddc00e6234b81ad5b21c99f35cda25f8efd6cd8f122bcfe646325823c03d	10780
1075	e3cc1dd19ca73a23c30740035c2c049e06c4dc45aefee6f997eda57f195bfdf2	10784
1076	bef7d5afbcff65235a48e3439fdafc098c052e12f2db436702d22b3417170bd1	10804
1077	90cf06236d40a354baf2529c926b9331fdf79e8e382507a796fbb0e91c0ef0d6	10806
1078	25e76be7562b4524bd08ecd225badbfa27a37b589860d043a0a9c4adb0be1252	10810
1079	2559059dd2fcab0e24e32de0ecb4cb0b4efcc7ce1e2c1cf34226f59d041324a5	10838
1080	95cff58736caa6d3791e4a74aeb3f6c34d93af8c8f0328b333447fc9cc7bbbaf	10888
1081	8e819ad1f3cc3ee0b423800c7ffd44f2d4986cfa22a8d712cc4f1c96f9261f2e	10905
1082	ccc81ed7b7a8bc9c8c31088fdab3e850e16dbea85c7c95f4592c8e1cc0d5566d	10910
1083	c7df76e247ab6c156ad24c7a56f002aa190dbb419c1ab52272a9f691917a7474	10932
1084	40654919618fdb75123ff48019feb34092fc30d62c468d9784369c170b4b19f3	10953
1085	f3f3a9047df0ecb2997945033eaf3015fbfb94146f95129e842c0f96c82fb57a	10969
1086	f4e27ebe04239508fef398a513bc364444f89a64de3d33269a21ce8b2b51faf4	10972
1087	2328b5d514ec561e6faccb1f79bd63530b993a4225962152b47d26d1d4c803a6	10974
1088	aacb7c5be4ac4b4be93265e115526ac19f0fc63476674ee8670beedc5919fe8a	10981
1089	360d7c2f4425f8481b683bd1ab28f72a53fdbf32d8d95858328635631a1464a4	10983
1090	a10a404b3721ae2579b49a4ab97275288ec26a454ff6c8aef45ba745361393be	10984
1091	f1919beae7e40ddfb9cbf0e0d0698ce09131d3f8073376205781ca3af04654ab	10985
1092	63a144af3e61d3533067501ca854d2516ea780869ca71ec10351b568cf3161da	10986
1093	3dddc7fd59aa04bfbd7af5caa647e2df58c1de4843fac7e99c98ece7d4875861	10991
1094	1f9addbeb8bf48d223086b2070fa77c8b97be674af18a74e0eced2668c324aa2	11000
1095	d559510b9239ecb246b08d04ac53156b020eb22a1f0f43e6b3766a0462b385a0	11001
1096	e2892a23ff47d1dabb3f3eafd7850d385808e2d69e9f27353e6c55b4ecf67578	11003
1097	79822d7828e572efad03612313268c586f480b098c5aec233d5f8b0d8b79c15a	11007
1098	3ff3c6a7cab88b6583e1ec6eeaa41a3b97dd66a7a0a9544e9b28e45667994f80	11009
1099	641b09021d38c27d4b7b85a620c286e11ba5ed01e41eddd48dae8eea91c1e95b	11015
1100	87ba4ce8944075e3a9d9e62f1997851436de027eeac5ba31c9f21d5c0e2c59bc	11020
1101	18d761dc785a56f5f9963ded297bf32e36306847719cc705e5b88acf6df1978a	11021
1102	fa3cbbbb5ce502a3db8048d921f1bd7705afc6566b3cd5d0b3d0542ee40b9601	11042
1103	1aab678f149666fbf7d3a14b477892da02cfe712794c0a9313386fbb4fe51721	11065
1104	e806503dc2629c25dfb78ee836877358a9439b526607259cfa27e08b2a00367c	11069
1105	c5f2d4a7754faa2c26dbd0ff749d5675614c5e22d9c0f483a148a11a706d2bc3	11090
1106	3d51770ad46041cf1cf60f716a35a36a6bcbac0a7c9d33020a097f3a6f43f393	11107
1107	9e5c14196177f53850226a576bb6ca6b82db2c098965b9bedff731504050e9f3	11118
1108	f83cf68aa76a201b04a0690f64dd498d16684c3f8b450e8f6ba553adc37e77a0	11122
1109	21ada5c2b1d5f20b9f7eede0af2c47821963b178c2b8595226d9577b395c30e8	11123
1110	b8f57d82036047f0f297abedd5339bc499138742ef2e2e2a67d116c870258138	11127
1111	f250b0340efa6ebb55aad97017995e1daf8eee91cae506f8243723041a4f0688	11151
1112	d6bfe566444e0ca1bbdc1a1f97f3cb0febac742d96c40ead2bc620840015dff9	11153
1113	0b071712b73a5742877d068ebeeedcd426d67013018f8c0b730f779f2ff9c7c4	11169
1114	6694120377c673e8e24043716e12dbe01e1b5df10e6fb482fb7118265361e6d8	11187
1115	24050c3018b87b27d03d94e3b35a1a32b97b0e03ea9f854bdb2234f04b59f567	11196
1116	fed8c6d274bee3b300ae45377437c9d4a3400a22449f9e30652e0c9ebfe8076c	11202
1117	0ce976bd4531ff74fbb821d4efeb1368284243de6a1657a55beb568dedd444cc	11213
1118	6adaef945fefe06aa57fed4beecabfabba5dcf6a36e9255f35b07201beb8bb13	11214
1119	6a37e58536612edd91280028bc9f315a801fd9a6012b4b8c553bbf4be6ab4f78	11216
1120	f1e76efe5b190e373ac6a09c1b9b047e63b48c539fdd13be87968013cd93e424	11252
1121	c4e64f5b84f783ac3d470668d04b4f91e947bac613be4d70415c2e08a0e03e35	11264
1122	9859de14686d0ee4e5a7b34e0f16bc5e6f29923bb70bbcf1a8a8ae0fe9e820b2	11274
1123	12613188a6a8395f2aad770ad06945c29615b5f899009900dbb87224d0bc2c2f	11277
1124	fbb45bb987d6b4d5871b61d3e62d5a1bad4fd8a612e3813c87aeab2ecb4c56df	11293
1125	f86d22630362888276b32aa208adfd145cfe11ba95ba0d5c9f176139b0c2e8d7	11295
1126	93ebde84dc493caea4ce69bb3dbad4aaccca96d11b6e907330d9ea9fff3ca16f	11303
1127	24e83fa20d4f7575c7c9ba5c493c10be135e4a596c8235874084e0051747ec67	11312
1128	81ad0837ba1d2302ec047e5b92f2177e41f773bb1d6f092307780df20764a4f2	11320
1129	12a5ec7bd94988a7cd152b4b03b6770a4892942c2119a42e3b42350a69743c0f	11323
1130	d5128650b26c79f2d61ecc5bbbbfc2bd553e6d1b6697fb57dafd945448a65239	11341
1131	0f89fcea8edd315b82ca7a66096f19494a9e3789d38704c4f8c95f90f4a3ce1b	11374
1132	c4631f2a33f3c8320c6909a8f3c864ee92639fd013eea525639df54314a4bdec	11375
1133	92fc9426df6593f8a431a4dc33d5d7e9a10d8530bb6d6146d4ab4891f8dff4b4	11382
1134	fac4e9bad293bc4cf4d0a02c62d32d486609dc14954e04491b8ae54e822619f8	11388
1135	e3f2509260a7a8d551fa0b8049c294730549e0e65ea97971dcfbc8aa1e3bced3	11394
1136	156732ca04889daf0698bed8b51a57ca91b6ff33874951ac8ab28e5f21f03b7d	11400
1137	23010ab8aa89964cd84ad3083abf76827b025af6795265edcd8409c062fc10e8	11401
1138	1e796f15a7381c552f3db19803a3e76c9056ca85d8b9097f11ef9eaea31b4e72	11414
1139	5f8336baf502b6ad39471f99b53e324c622437e7df73868464e536b03d66dfc9	11416
1140	747d7cbd8ab4edb07bbe2136a50bba20ac369fd09ef87a51c9317013499baba9	11449
1141	9fdf2abb0052e142f0ffaca27abf1971e6f2c7588b19b03b17b5eb01d02186ee	11453
1142	b814c86e4edeca401881e264807fc3decdd478687a465c49878147903811228e	11463
1143	9f71fb3159a96d017cb47f5b728f9caab1dc9b9e3876643cf10d3ee029a8ad23	11464
1144	c7e77f3654e9fd9b7964b78ee16c1aad444cf79cddd57e1091b726948dae27cd	11470
1145	73853a6138d09469cf1b7d2d959812caac8cde140776d8f2a0a4ec8e76363c6d	11476
1146	7823ab93c857405652a8a127e2473816deef991dabf878f864b197f258aeb81f	11480
1147	c903ad4da30dd18e4d8ddc3b684b27657c5fcbc85f305aa8ef5ace059b7595af	11481
1148	6bd7837cc9e82f7cffadccd2fd592aa0bd3d0b2358ce2c075aa6a98eadbbc7ea	11482
1149	9adc302d70b3eea8488e74869c645886d1b2c7e5b59827639957857140cf01c9	11486
1150	d5cff23e6f9ab46c0a3318c5136d2af49d39b03d279b96b37ddb71ddeefc670d	11489
1151	b68c597f70b41d734c8a958d26bf9f2e1f7142ded624c822d7ad3f348b17a2ec	11496
1152	850fb3fcf889efa3732d6cb670d1481c56ca672edc51013905d5b3ed5eae0e3c	11502
1153	68d1d01bf252fd1c24141745b3b04345d0d62ad1875a9dc91a52f4529a7195a5	11509
1154	49d3e2dc5ca851a624669bbe84ac55c9ea38174b88b6d4e4288687390df0bbb7	11513
1155	562cd260496647df70c4d9b484106cd03a3af4bf9cb72240a0a01931e594e600	11515
1156	9d770779c77ee26e9e4eabd9d1c0089908b0f3aa4151a0e79fbbbbb37951c7d7	11521
1157	96c383ea3c07b79fbddec4070e1a2948c9d3e700cb51066ebf65cb238245a2f1	11524
1158	8b8600c9f44b6e793543b5c612c804c969e07b44972dce871bcdcb0783c78461	11540
1159	c24846b7bcf0444679cb46e94fe708d5c402a0613c570201a040f3ca0be2b7d3	11542
1160	126411e3ebca8b6cd2dfbbf652c8559848bfdef25dda233409cc805fb2bdcd11	11550
1161	2603ee7117e9195df06de7e5de2745386127ccef660598a3193a875415571f35	11586
1162	9e2e0fc052c977759836f53f6d54ebb4b1ebb99c7b9dffd680b987693819b4e5	11591
1163	f22e1500004031687167318dda2e851c1a6051e70c4aac83520d076d56fcd055	11592
1164	60a826303c199951dc08ae0ef8e1925ebaf3a94a4ddce66ee8bd0cddd4143a96	11607
1165	3fc1cc315619dff20f8f6f83f580b3fe17a0e47eda6e1166daf85a8971d95c38	11622
1166	9e0ce4a9f9f1eb18e3d6cfb20287356eaa171b01d62d0c6d4a07534400ed2eaa	11631
1167	dd8fefde0a24a13e9c9b090491a3b974034c9f71b05c0d0bb0b423d9e7657856	11634
1168	0e490fc9a29f4316d32bd0552883d254610599428ef4b87a0258776314cffa82	11636
1169	01551e32726954ac05852e46bc9f687328a6d2422040aeca8cbddf2ef0d67315	11637
1170	036c156c3c2b465e9445e463f722c172ab3dce2fdde6442d59bb428f515571d2	11639
1171	c8af701719ac0372eccb50f7a78a411eaa3b2d1d9702decc1f734dd652148507	11645
1172	abd780f461267e58c36b74717d8978dc4563e8ef3aca4b3f04b4c11caf03c047	11664
1173	0204559293e1921b4713e6a826d9a171f86453008b86c66d3baa1357825031f6	11667
1174	65e9cb5febe9f7e5758fad33a016ce950c051871b1fd882553979a2ed01ee9ce	11668
1175	124013f56ed7edbd079e9528187bcb9bcb5d0ec4a68890a948dead86f40351a5	11674
1176	3e39c30a4a5d0006525da176a1671ae0ea6345ef8bb5f0a5ba06707f9a41edec	11696
1177	40474f64801584f0694b8cf159e724580a71c5a2538c1cff19939b05f6ee1ee3	11699
1178	5a21abda9a1019ab53ff988d06041658cd0c2d45b0961dff57f266d0c193ffe5	11707
1179	9c15f5c450378ca60af1ae3b866f7e23139c3b8a1c18f9a58af84ce8561f8cfe	11713
1180	1d0847cf643b77c6d4224ef788f3c5fc49d4f044a811c00adc82345ff6d28a45	11714
1181	2a014960c256ade68ec4bdc6631ef11d1ced21f22e0c7ba5496cc5bec9af6a52	11725
1182	217f9718a10725d1c712e849b6ff00c0f80868b97cd5db1ce619e24e4c8112af	11763
1183	5c0f1919ae1d90c639c3672a8f76db948f4dbff2bc36b859d16504082878e2e9	11764
1184	4a838fd2dcb91f29541dc6ea383670f4452f8684c05c14df0bab9c1ee80d29b2	11766
1185	cce30a3c60762a8b717804c130dc2395e542d7783966783f2ed65c18a33899bc	11773
1186	b6e0567e1264ca87035434f70383ca6260e2abdfe0f27dfe1c1f56e81baa844c	11788
1187	80d615a3f4654070e128322e4c44f192bfcfe28fb1a97976725e0ed739162666	11795
1188	b05eccb5423e1fb52164d239d0908eaa1027b290db1aa93a57fc538819b80217	11805
1189	f76b228dec9875e1e528cb1d7bbe18f27413aa0acb8b8deab110beea95cda662	11827
1190	fbb38e88e7c0065fbd34da3c40905c6dadab3376bcf0fa047d0834777d5812c8	11843
1191	8a4d9b179bded16f0b3914b80e5185ed1f9f120ea1f20672283172aa043ea0a4	11849
1192	f8d97a496bc0d91b511dc725dc34d593392bc7af8d4181cb9587f4e77bbf4472	11854
1193	cb671de994ed0f0bdadcd565b008167e84fc1a929346c25616e8e57ce02bcfe2	11863
1194	70f967fdde2acacde2c415fed3ae22adca8339fdcaa32c83f6bac4faec721d71	11866
1195	62babab2cfa2021d91d53b256d0d8aba7f2d2819813c83c9bfa9df7668d46b9d	11872
1196	638afe7bb5808f053f1fa69473bb3ea2788e860248491ab28844060770e9b1c4	11874
1197	49cd1120decabaa1000db20473999fd7919096110dbafcce18dc778b56c63442	11891
1198	6d371d43ee3464033779ba80ccee4b04bc34511d5229f0f9edc06bc1b99492bb	11893
1199	7a261a3ea9bc9802b53f4811df93b323651323fc53fd2f565fe86dc743456f22	11912
1200	7adf590cb1e4d9110dac89e36bfdd0854d57fba0da0f76edb83865b27aca1b98	11913
1201	b02546a6246b935c0447d918d4bba4815b3d317f9189974c3b8cb6144a918bae	11936
1202	341d7e64e34a961eb3a6d6c9185c4464ac30c6fffcbd20eb6c80f0a1395dfcfd	11939
1203	089b2f6031c5cb8b51093e0c025f99196d0059411fb399ea865ba4d4b0fe6351	11940
1204	e6630f03d5b51771bf21823a64f482da531f9f74dfef1990a8315374db81c5e0	11950
1205	f125d7e55ec7562307f15adc4c1bb2042d3682359a8e92b2b8503e5c31839c71	11961
1206	29ed9f89b848d1fd28f3c1d172a3a41a8c44df5d19297da718a4dbfe68d11722	11964
1207	4c80cce40b75f2159ccc286bd7cf61d2e338b80bcbe5834a915c87eff2b3afb5	11972
1208	5eb2cfc294ac7216079b8b012235bb11ca9e0a6974f82b907ab27fbf887eafb6	11986
1209	a1d7ced0531f81d25a6f8e55773137ded4e4288e464c85bdd7bf699409c666a6	12002
1210	c31a5cbc5636bf2507e70dc43ad68f3b31d4592969e3493d975179ba48fc9a79	12010
1211	4dfab67beabd48c43ee70d6bb5a328c50de48b11794e4c773502d05a3441fcc5	12044
1212	1e4f9af53e357a07f572f3b1a53d67c610c670e321dcf826b7e6b03e81995dd7	12055
1213	930c21e0bb6f4c717d51873cc1815a3ecabc37faae0d29d2cc68db821eb2c6c6	12067
1214	89db27579596ff96ba18f8eb9aa690570d587ac0aa878a28043868b8e826fbb9	12085
1215	faaf595a9e726945b8e697350f94a50c135b50dd9473a5c0e50cfb486eefdc44	12091
1216	b76cc7b9a49cdc4a94cbbee8abe8c5ebc7ce4cc050b329dff6cf74c8627934d2	12109
1217	a5338740f417f43336c6b6d70c5e1636841cdedc69a7435aaeb7b90ca72ff797	12127
1218	dda391eac2c6f548ab23f24286a8229cc569489f7cf68276833b0cf7b02697c3	12139
1219	1c12778311685a5a95168f46687eb7582aa4ac909939a2eeb0bf461571230c11	12140
1220	0d3677dcd796484b75b829c1d0c70604359dbfcea8c5cb740dd42e5e040014f9	12142
1221	ec360a5f31ebe265ab6cf4f313caf36cfceb482170d1b5d2b40012abdb53cc4b	12143
1222	cfb6b8dddc5a88ef5839e1823cba118abd53951fe7f1e28a8890c2064a4e8ee6	12151
1223	ddd26e315635b31a4931fcd0e1066d71592625e95b2837e5901ce4dcbdfd4c5b	12156
1224	187db95a9a230a9e6107cce71eda4119a1e63eea351a1ea1d2abebe872259cb2	12172
1225	646501e92b2bb307f7bea7b01c64d27b37c8a7f28f843ec1993764238eaf3072	12180
1226	7a963656ee4fc450df40a6d33b2a941bf788f876601c3186923c41f4ba358e11	12181
1227	04ec775ce4a85dd771c29361219743d035faead4d598066c7ee4bbc0a80df09f	12205
1228	d8a5e9c0dccc14d5e6487ad8dc4d4bba4762ab0e486b6beef890f24a32bf489a	12217
1229	3e41199b276144cc69d813c320b4ccf82fb08b2ebb1c87b7fd02b70f25c24a03	12233
1230	56e330f12f0c49284c3b67cdffc194b68b60d8d3c39e8415f8cd0ae77de40d9f	12236
1231	d14b29c023a2a442f236ba581c61a758efaee9440c3dc665b72c1fe905a54a88	12238
1232	67177d914aa0efafcf919be338011fba7251754d27c543bb4c29f40c94d2b239	12243
1233	8a5540959ce52b1ff5c2b7f15f432444130de1f8f30f7e3ac7099729455c4e4a	12253
1234	89b71fe1eb19be62494dab62ecd7a4724ebb6d812383674b46cf4b1fc87d314d	12254
1235	59aeb2e93f3bf76689243faf35ba06145f7a9112da09b4f6da132192021c0f49	12255
1236	cf8a437fcea4e1e2e96d4f6c201527430f5332e163be9b491432ab1ba05d98d7	12267
1237	06e7f4d4e60787356bc5402dc437a3f149c63b3e496b963ada4df60addeca7cb	12274
1238	a1b3e2e0dc8256df392a8f8f3c9fdb6d826206e799ae23636dcd755990375943	12278
1239	bd80c9151d2aacd33d6631ed510084cbb8e0b8323d140f1931d387ba10eac318	12281
1240	5106224a41691017d24f9fc59c39a987b4031a8391f5e4de578b310c90d6f729	12296
1241	7b2aa1e0b8609b6d1cba4465a328da41ebb554bcbe6b7ba2509e66a143e62d89	12309
1242	8ba688c5f06ee147d271ca5311e37acc4bfb7bc4517ef3388064ef3ba52c91e2	12348
1243	e16f80a050514d6fb86df0c18c283fa91fe164ba6b5eda20fbeed35cb3333538	12351
1244	92cfe6b0f07c3f18c193cf65680cf3adff75051c7ea7d707f2d05427e18ee9de	12362
1245	d0efbf355a4c74b8d38c151a1fcd3159fb809adf3d094cacaeb9e9d2c940c94e	12366
1246	9acecac43cf3071761ab22f188f13683aee3c8648832d783bc6f6b8dcd6db7f9	12369
1247	a0bbbd52f86adf4946db6c47686c22cf27f01faedeea72f7f8b153b31a9aa40b	12374
1248	357b47ab3f7c3d592e8f2acba13f41d679ac3e55ed2ce2d5884ba96d2c06c17c	12377
1249	ecc769f444cbc4c45dc91d34a160bbd212ece261b725ef7e3fe8a51c60ae2dac	12392
1250	2c67f87105fe0315bbed5c6c0efa57c427be74b7b03640dfa9295ef949e7bc69	12395
1251	c9d0c9e714e496357336f360abb87db2b0f888e474acdd109033b71f2027dde2	12415
1252	1bed667f22dbb05d5f21274c9c02cbf947d8f795ee783e1ae5ff238a6c1563be	12435
1253	621a0f3777e860a060189cec0503cc6ef8f09c1dc4753c9734469989777c321d	12451
1254	97ad9b3b5b4accbe37cbe5de25181f3852c057a769dcb3b3bc18d28515e2173d	12455
1255	46c7f282f23d8b7e93677ba8dfb6d57acc63a72f90da2a3afe2f3d5ee3555406	12477
1256	82a0320d4c01561534a358674fd7054f6a845e852ed48f36aa73ae6238f1c84b	12491
1257	f26ea22a6a7dc7252562385ab38fd848fef2760b1d0a26763d0e5af549d1d0c7	12497
1258	93ba72c21e531475afc9efff52ce2b84b5ed7458d696470ef42fe1cbcf8bc950	12505
1259	bfd69ab42495a0c4a91146959d03bed8640a94e72c8aabdce11bde3dd0e8ebf4	12512
1260	e580bd05ca7782929484d2c2da555822204814d98e6ddeec092abef0e8dd5c5e	12536
1261	1cb6ac20e54129466fdc040c6caa223843849fcca69039c32ed8c36cc7b7d2b1	12537
1262	ea697313e910de8935905eacdaed26e83c6fdb357f19ba9c404e98dc3913814b	12543
1263	4bfb877869331b80c3f5bc335d48781eff5c62e63914e4e8f9d501955360fc51	12556
1264	2dd0f7c49bf4a3b9912d9cdc72611ed3cb9d29f70b8b95d37ae6a037b24cabdd	12563
1265	129a2195f1de35d0c867ec7f930a7c3d8cc97af927ea985898ae235be6ea07cd	12572
1266	af9a477f1bf4486763c62e9b81ee2d5791c23475e42f3e2980f4bd4ada4ab038	12594
1267	9268604cfa8cbdc4071796296c0a80bc35f308b56c30f8a38bf5980593db3158	12595
1268	2c75bbddf0907783a6a898e2359590440a9dbadbfd658524bb7fc1ee585a3291	12603
1269	a8f5a2d1073e61895653bdda063386cd98083387fdd8c6039ad307b5a459d5d5	12606
1270	5e97b4e1a2fcda982c87cbc56c6b0d2ff91f3e738fad058bbfe009e40c4f3b9c	12608
1271	8a4717605f58b079a777c8bf11aabc8b08fb973d588834127e791b41b0fc9183	12610
1272	4140b5ee0a5208c33326a02019b6d88144525f9bd0412b4835a205927cdeef6f	12614
1273	81fad9d6214d1119363d955b42a2c4f1c995d602725bd8a0c0b690f97ec03ef2	12617
1274	bd0eb8307f7f91f24c99c26f164a5c7c26f771eed32b87c39cd32720e3786181	12619
1275	8877eda50f173cf94ba88064b7c4f7aa3fbc7e751f3a5dfc4d866006fbbd0844	12626
1276	c6deb95803a5665517154179d8b10ac0841d25968986a2c172b8d028d5ca72a6	12633
1277	7f7a806c43ecc86d00df47cb202f5287577390aa05b756a8c9657c849b4f0e81	12635
1278	6f93079e7cbda94d80039ea90c53e103edaea301e6c6062f720d1c64e1f5341b	12643
1279	71d24c6057016067e6ae6060e18797bbadc439eca533a32ec06d4cae06c0daea	12679
1280	7928a09c6ce4eb8ee73e396980132243d86a638b70f15830e495cc5a6a42f27f	12698
1281	a8f62d09b3640ac8e7e9c0c2cc40747ca8109e1e3fc29ccda134c2a2850aff79	12717
1282	4d86cca9c7d0cf410c56f83db6f6393d7d3d7fd89ca6fa7c509207ba1b8fac10	12720
1283	9ff19680c9bcdc35783173b01302435a4146b97b36143367122a3cdf61bea5fb	12726
1284	0a553693726cef1a469a9bb4b682c8a1bed0bbe8bd2b051afa9c0c7318879f9b	12729
1285	2d6dd8c6d1575f841da2d27d59d71ad7214aeafaf19c1965604f95813be5401f	12730
1286	51ff88046107d060a6245d752f9caade12f06f7fa9707c8457930cc54554a0a5	12732
1287	c1b11e43b26880352c71a8ad1d4194e311afbf511f2268348e5b8dd5ef905f00	12740
1288	0db95990296edeea75cc28db904c3fda6171e4d753ab6d6677ebbccea17df389	12746
1289	f8c16acf6a53a47631313001e998633393f5fccf8c39256b38f8eb1e380a551f	12749
1290	ff01be0f271a01abcf23942ad04572ea6cc5f28fefa6bff1d137aee3e4184500	12766
1291	44cd6c1148aaddeca72441595bf70ba78b057a297d99d24aa0c2da60c4295a9d	12770
1292	5ebee67a55720db27097321d53d36ffced900177ecc42e78cf88a0f46797c9c9	12774
1293	8c1f185633a188591d15885c01537773a8db5d5184bafdcff8468b9c6ab37404	12777
1294	a6ee429c0f8c6a44df6bc4b55f9f65e3892a59ae76b2db745003ec215743351d	12779
1295	eaf860b729f44e0dc8172dc1f7cf0605ce800ff332f45270c533722dbff87f94	12788
1296	25548a48ad1c21cd5c1e040ec79fbcc8984929944f1d9570e40ec548821b06a2	12794
1297	b5620dd4751980ab0c028d8a68f5d999cbb05e7cbf4aefdd9faf0476b16cfd1f	12798
1298	46465d6dc1e4eebac5251ab06f23f19ca69d25463b64d6265088cbfa6b18518d	12807
1299	0d0ba126770f6adf4f10706d24ba34e121331ee09322aeb3f4e6489684d676ed	12808
1300	4c1fc7e6004621aac87f4708400562dc823c0c5cb53bcb9d4e691986f08e0cf7	12809
1301	1afc87f7c2b8846ef8d2840435b2241c040c3f72b336adc927f2516def7b1d27	12811
1302	d54b465fd104eb8342ec1daa92c8ca8956a64ad13f5baf757212978741f30bc4	12817
1303	56e081101c9b3889f9905a687d5b02e1752a70e0a064a03d799fc64f6be07ba8	12829
1304	815056d590d9f71671da723391dd21e158943b67fef7dcf42c790a0e2c754d6b	12846
1305	2e3cd907cf93a48024ff38a02482249c00666b6331cb526e2851f1fc1f550963	12851
1306	dfd8cf7b22245554e2deb80a38c8863150e4bb352d7a0204fcc55e0292738249	12854
1307	b1f9a9ea7b2528c74d311bd8741c483e6a40241193433bbb6048423c34276076	12856
1308	deeba220237d68fe6066337d27da42dcbcc5f4cb02278c6cc76c10795adcf285	12867
1309	eaf5ef9411a410ec2ffb11ff5fe9def24dbb4835ca5ba930766223b8e4971f86	12883
1310	8332c052d1d6227fbfc1ee9910e456d373a7d6ba069b9efa023df8b4a0b15e68	12885
1311	4ce1d6fb9e9fb4bb6055341e1586173ca9c0f83a1f75c322ba65c244e78f65b2	12888
1312	7a0f2e338e22c8cc07e08cac653063abb535142baee09f0c8ecccf628a621b49	12891
1313	36b91b49638507b36ce60860f7bdb71ef3f705e778c24b1d38f4bc1aa54f9598	12900
1314	ed20614354271d3d98108da7621ef888e0135d8c8699f410ee4f916af260c34f	12933
1315	aae6f4152b5c69831506d556aab93e3e29e996f78181cd426dab031002dc6dbb	12937
1316	06465d0dc9852336683c2573f5bb6f99e86197b504db708b16fc10b324761cf2	12947
1317	9d18a505dca549f7bccec2e99810d2a5eb0be0589478a1475f574204e07d3069	12954
1318	75d98c5297cfd9397d24d4db3a96798f749d0c7502feb09019787a62d1768ad0	12968
1319	87873d4fdbd4523876cc588f7414b51a7f4a239272791d3a66daf8c40c5a242a	12969
1320	a7b742c02d79b9d609d5ca69dc2c3237a5d2c84dc6d37829ae1a4328303b183a	12979
1321	e35b94e5ec170027833f623830e356367e6727a2bc181e07e582d9cd6bdb5f1c	12983
1322	d2a3afc563d679b7ea51923278379cd29364ab9190913cf59724aff35a19378d	13021
1323	f265797ce6ea8f93126ff348d8444bcbf205ef7f89666f3db65dbdcb293adaf6	13036
1324	462798ac5e7f01ccba1774a7ba036c33a5bf2f291443aec310ca7270035b8c4c	13039
1325	cf0a5628d4e30245aca7f2dfc6a0c7723b5bc41cb8904415e24336fec6dd0044	13046
1326	de8661384734b7bddaa2089a47dce245ee1bd1bfccdc74e5ef573fb3cde23c9e	13060
1327	3315007c63a2bb56262a10d30cb5cc713b63db6ab3f68d414e27b7cfa5b6fa0e	13065
1328	31b7831769b096575ad2e5c0356ca3ba403f1f6a900de32db34f22f3cd18e378	13067
1329	4116bb44b58211a9934d6d53d2eaa9415d0dfe98b9c37c58a754f62cd38ae044	13082
1330	17307b8afe774b731502e619946c8c55019fa9a71718dc72e9d974fc62553102	13083
1331	2bd962cdc22ea52e1a35ee15de7ba5813a3cc6ba1a4f84fa96be7face2ffa20d	13103
1332	33dbc07929722b4315c758cce65482ba1ba3d09e06b9286ffd75c96282e3eef9	13110
1333	ab5f8b2415345b2937d7cf158bae63d57436c98285a9d4591897864ad6f32ce4	13115
1334	c55836743ea8f6103c9a8bf5c714d1945cf551d512587fa5264ae5d860d900d3	13119
1335	0e9ff2ce671cc01de7505d38e5fedf05e7d52a546bf06700ae1a0bd3f0cd1c34	13126
1336	d6166c74e3cb772668b8a9fe6b9daf3770c0a0b8f6a59d1b790aa1dd3f426681	13136
1337	ff6103b96b919c38fab87f2abd3d4f96bf060afe91378acf8ce532c074e0a715	13137
1338	00ad93939044bdb449142b33add8224e03658d2d5461682734844d2e1a7dd492	13142
1339	457114e5b7d311f279beaac8741923d1b556167c085b655f6031006c37e8e61e	13150
1340	489ba1af00cc32683cbd583c5ccec846ca356cf097c23914e88c096c5390deec	13156
1341	56284a9c57415e34cdc6aabb1af78be3ae6ff35521e000992e6e81b63b7c2777	13160
1342	ab1e0140be6e17ac20c161f9d18cddfa4170a7c85dd612af2b149fe8a7cde1c3	13164
1343	ceba867ee23708504248edfe39d1769c76620cb99fcba097830c7b2b3b17cad8	13174
1344	77aba07b7c09db9f45a88c8e3c633c7b17f07f86c2438284eb298a3c7019a5bd	13201
1345	4d7ed6cd4e789c8c995f16efc77f4bea9e66743c69bf14c178648bbc4188f645	13224
1346	da47734a78739f8a33a16b139756a2d400519ccd350f61843927349b9a230695	13245
1347	646faefc086a89a79c710aa4f84e82bf65822247d3d5c1d62010eefeb10ac6cc	13249
1348	67b8a68363a5a2c91cb729a3a720d890f50402b7064d6f40b542849e8b2bf739	13266
1349	5c8141396668b7b59bc00cb10bcb3a6fe9c82224c9df9ef79738f0183c725829	13276
1350	f0a69e2eac574554c86b7f7e3e7d189d86e89e3a46a4fa7393298944564b7cf2	13279
1351	f17a26b18e12bc5ec5ed472fd6dacab8ec53a81c497eb5b00b565903b8a1e47e	13290
1352	99de749a3495f4ff8d70da119432517b3e0154c50b343943f5e5818c5bbb6839	13291
1353	f0822a97f79e43ccfffce8d7da3fbece6c1976fc63c0e2e9ca091473c3041cf2	13323
1354	f64332efec1146fefd183aa7a537bd566b3a91f9ab23e39460a336a05b62c64e	13330
1355	a7b6571ed384548e8334053ac6dbc9856f3b8cee840e476187acc6fc0068b20f	13343
1356	5da9d71956c0579272d644c2faffadc4123968c545665047c83dc54954d2bc46	13344
1357	bfdf048565a4b316204b3a97b52e408af41752eab5ba01a2d0d017df4597ae3c	13350
1358	ee1c46dfcafb25a9ef083d853ea3474c5d4e1035dc487dc872dccd094a06ab5e	13359
1359	9ee4f82e4c34e7216ba7f5a43a34eeb4b20dce31aff50f3b266f48b3b2eaedcb	13369
1360	e03b3558d7f244cb7e56ab02cc3eb78aaf0894996c29bd0a832c121bd54bf01c	13371
1361	c48e3ce623944510f7fff69a70b18a32a4d99929436d3bb10eec199727d79e45	13385
1362	0b9edf94912944cf5dd44081761cb2336440e673363789af7123287d3f7e005a	13399
1363	4d5ef1a515aba84347f8f51d01fe2d0d268426ee990a3dba8dc9cbdcb71004ee	13407
1364	3b3a7777ce1a7a824a092ac34f7b987f9ae20f13b9762cb3f3f72b96e9f5695e	13419
1365	2ddcf109c75985f4bd89ec3387c2ca75c95043c457cc73e9a7a93f4bc663a195	13436
1366	a979410649096b7b5b08722af3b0fda3799f7b4f23c0f4a0d7d9a8dc67c77453	13447
1367	1e4aeaac25d7748adab9ab406085d969cd3a89c37665e7406c36e1e713c3a06c	13449
1368	726f2ce82a70c7737e21009804d39873c9afffd446484be967ee5a8ff797b4b8	13451
1369	ae50e360ca01b85c207fd5ee3b8af4d094e203582048f04ee00706ed348612e6	13455
1370	0dab396a41a0d5db44dd295aef378453e381fd71ba179a0d72831963d3f8b24d	13459
1371	ac242b1222bfdad5bdc29cce62badb7d0b085dac232b00a0f70b179c1babc224	13465
1372	ab38a7e58d56eed2231292860aeab01b595040f2c4726d8b2688570e9d66073f	13469
1373	93b91bd1ab8d1563d7f3a203843edba8bd2cfb7890b25b19d5f616ba0baa07f5	13483
1374	a34d0833643a2cfda16a93d954d3a35c334ffb96cfa41e981a140327b406e3b3	13485
1375	0af723c9857a06f0f371b4a217c79af05a6343a71a9bf9175779db2e82089fba	13506
1376	c9436797edd1879a63d73026e9fb416e8a7e7ac5a5fb9c7a803a78e9ead6de25	13516
1377	1c1d99a257dd0850b36c4cdf25e6e37f49439894310dfed5a831e79f8895eca7	13540
1378	69b7809984f244b2243426446d711bbf39ae5b6f7557338a4b6fe408ecfcb4ea	13548
1379	3e97a3fbdc7e686d8e24f0784f27e1e7652796fd07e9779489d79156b73877e2	13562
1380	1ace0990904e7fd7b091d05a77cd5be8bdeab93c95972aec2e705fa51d590c6d	13572
1381	b1aa2dbb281c16361a18227f1b3dce126596d4c7e5ca517ef06fc532696348b1	13577
1382	08e70c2dedbcd24903d43bdf20aea5e7295cae40feef4787305eafcc4316ff85	13602
1383	818386820e09c2368fab9dd8461345df108f439158b551881b08d94f048f090c	13606
1384	c2e4af5e98d78a4cb3f734f5837ac5bb7ea7515592cf5949677e67d0b3f59d91	13609
1385	72ef105829297b95b0d859095370bdd3ca1df758130e47cd94d2e862eead810b	13633
1386	56967399dcd5d24d7b86a64c9485469d97a5f624897be42b58a95cdf14c91eef	13649
1387	50e25cef895ef7df4984a3e167e323305952b7bded0f25799a4e31ca2d8fe89a	13663
1388	45d14cefcdf879b1df200cd75fbbb7e81171055b52e438172f138729cad7f66e	13667
1389	e480b85aae0971dd274750e6ab9e620c2278cdf457e01831b33547ec87cccfa6	13698
1390	b43cfe369388d6f4d20b2cc9b2f07e5594e60bbcd5be6b649cfe6695a174ed3c	13712
1391	27461ebaa60b6ac6911bc0c09ea3d3e17b9ad20021351c6ab55c9258bbec2ba6	13714
1392	5404acecc3c60d2ef668ba20740c5abab7db182015d44627c22178d1745a7d0a	13717
1393	af2124eab52b8912884aab6d2297ff0c78c85606cba5f5ac54d8a10faffe643d	13754
1394	ef97d247886cd46e82314fbd028f8cf3f5ec628adcf82b0bc4f7923b386dc468	13770
1395	5a7d0876d74492e2037746c6115ec6c9fca00d9a0a9b78d51f5ef62e3123cd91	13773
1396	89da0578cbfe5956fd5e67d2b3abedc06efc95e854f6b5bc1748eb6f1db46740	13775
1397	feeb952a238d92463377e7a0599d8063b39378bc74c96ac04699f287ddce1ec1	13784
1398	6e179941fdd578f46d097c0f5ada8d7235bdafe2a30b70b3182ac0e3698b61ce	13787
1399	5b87569bdd316c33a84a393d8d1bd607eced72a070e1eee5d9132f2a67f2ad7c	13789
1400	cf8a11e3a21c9a3d0d105ed3a901483c9f8b668e8aac2ba8c4c8db7d55c9f182	13804
1401	bd076de1b44018d23d9b39af10d5d06b9275aede640b1ab53de2ad7ec2b63a19	13810
1402	5ced0895b767009dbd98e3bf729c635f56e3e1a5bc44c02a7ac3b103f3acd30d	13817
1403	59fb51cdb8e0bc31e97aa8f1677ef590008cc4ee65405bdcaa00652309f33829	13820
1404	c3447f4df02e0a549aae687557c4408c1510f8d0290913a4c55377921912aa60	13823
1405	54174549eb0ff29b45cf94a2165b0b3c9b6c20f97bb5e2b42b4319d80f9bac44	13827
1406	9ac5e1b47c2c6b67e8b199df939461b0e28d18235b12b772338ab5c990f04402	13835
1407	3bd54b4c30f74724105ce105a00d74da2e2aea94f18f31db996a077baf0abdad	13866
1408	974d8542c32b7b48def04de786ae3e036e09e935a864b526aec7795bcc9a7140	13885
1409	29816250d6105b796c6a8c42fae8dc2a5e659a5166f9bdeae8a7796173104693	13898
1410	57f599d082d89ee2e5bd7ffd6b07aabc42dbee76d35d57aeffa3f5b84a282e83	13900
1411	41a9efda0950129fe0acd01f1e8a47b2efdcda0641b1fabff96b90fe874c989a	13905
1412	203ebb4d4c5228e2a2beee639a7482388bc551d3e381e3a132c201bf51259982	13915
1413	94bba6c9dc11aeedca9d44715a4d2b82c1384109ab058d9802c97926d828b3d2	13921
1414	c3efceb542e9bede498f0c5f596c6b865f83c6f0e7007879f2117ae135f131b6	13926
1415	610179197244f8fd9a62951aa79b7d183aa78ef21ddce6d7b21f2f7a2bd7d80e	13949
1416	51573f2b36f4d06caf582d1b9c74ee55f7a3bbf1303aef315f6596f9feca4e49	13951
1417	757d86bce9a16aa8ec9d27b5c4f3c7cdcd31bf58c97159c7d8a458ad29082676	13983
1418	8434e803f048aa48c68035312c2b2658f9b9e26980b27cc35acf2ae1b0d7760e	13985
1419	651b8f6dc39d4ae8f9972a42a78f83d9c8478b4b71aa06de29327ebcaec6f1a2	13995
1420	41f650e3d02da668cbd21d22b49f9d829166069ca23f5fb867179eeda59d8bac	14003
1421	c360e20154361d0192f4baad008882709623309a80249e4ad227dace01c350b4	14015
1422	ceddaa0c5050ba44cb7814644d9e312993244f690c2cb6fdcea5572be6051876	14019
1423	d32b41ab1a7e1d19e6354ee41f170bc82b5f5e3d4456259c1af68a56a4140ad8	14042
1424	93d2cdf58f0616f4a043a1907f6826f6e3738be1888d5d169b18b3e8db6635c1	14128
1425	ebbcf8be9af8b693fee7bd39ba0723664c5ce7ad254691db20f7357467cfa10a	14134
1426	053c449f46d262bf3134b17344a6cc652dc2cb17400c241a9dc918835bdaf984	14140
1427	719b42d2fe8c177ae6bb2cf7fc52e7895c717c278b2d548b253ee5bd36d5b079	14152
1428	9404562c3b0920b0719afc9ec9530fa3c07864b25f50f286ae7be734dc3e401f	14173
1429	a1502178294206c266af4766273579cdd9e5078ca71903f472a4c25ed34989f4	14195
1430	8cb280abe2e2d35a745ecef37acd6b728f7075249c0ce802a48d3040fd26c251	14206
1431	0bb5071e9bff26b340f233e895a5ac483fb10d45c8fc931cc7f458c2dda2913e	14208
1432	251901c7d6aa970aceca30128778fa36677de405bb38cea5947cfe48dba986d4	14214
1433	c7fea57b5a6fbeabc5b30092735b0773b7825f2cca28ffee1fb68686a6b43285	14218
1434	8dd695a74af2e146285d1c3dce892e7e2dc5e15303cc271369a7ca01d55fb3c6	14229
1435	7256e1a230d7610dede78a268828b170cee6fc7ba9d5a233b68d6cb411464c3e	14247
1436	2fa9209245c0bb5694fd1bfe68e7ba3bf84714b3cf3487b39612828467a8d4e7	14260
1437	e6101b4f5df1caaf1f19b003d91fb0946867e627cacb0f75f0ac53fed9a0ad75	14264
1438	8a4104e0bff8c3a25daa66d8c57fa3ba1c525beec337cda23de25c64de9b8d25	14272
1439	9db675eeeb8d9c94aae3a6f7506f6856fc614c42e37543b4cbeb8e371c8133d9	14281
1440	e1b5d8d59bfe42d69751797811113d0e476bdaed40b9810bdfbc0605bf72e92d	14289
1441	bc74ba97c11b4fba2057fb22b89cc8041c7722b09c164fb3d887588cdc347160	14293
1442	d3ea4e677011c96372ac2abf24ae0f3b61c7b29534bc6facbda27648c1745831	14307
1443	2d7f326b7d0a1c2211e83a610e893ee3b13b76af0ef9481e869a10c9f2b54f4c	14309
1444	842ef12f77d5afd6b1d69da800d43ede243585500c7e4a64fbc2919fa59d62e9	14312
1445	c25644e1a09020443e5d72af3b7194d96bb87aeb997288941d937ecfbba387a0	14314
1446	aece140d3af2753754793bd34b22f95efceea89886dd050cefec522737c9a1b7	14331
1447	8be01bd35fe52b525b36738e5379ab45f0ca06213be1349244ac17d18ce5d880	14351
1448	8383d51e1e8a5b88d55ce33289e06acb033b6a1245d6538fe1c2eed7b09f579a	14353
1449	2e03495da51cf79331c4b163b2739cef0d98cb347457c3f7013c4a4448d4a376	14360
1450	73b962e3b4de507d91781d80aab6acd065e979235318fafc82e6d290f43668ea	14401
1451	5edc348e20ca544710f2eaa596a099f844fc82378bc304067d24e05212fd61b4	14436
1452	168bcf4cceae81619f70746853f7e6a65bf4f234e60f93d7ab007b5010ba6471	14440
1453	c57d364d34230fc115e269a98c6d5bd5b145aba98d859ffb53599c07e91e5d85	14447
1454	977e6dd3c8631c2db5959f2b387509eaf460e205163e2b3367cd5f20e7102425	14463
1455	96bfaae15b20110810d17cecf6816977630082acf1f25f33a8b1f94fc7416bd4	14480
1456	56afc6ff0b21ee3247ea1055701033adeff972066d590904062e5573415f419c	14483
1457	9e9bdd1acb9bf016836c67d9bf672199550d5110293d0088e9191ba70024a56b	14496
1458	a628a1e79373ff3e116c7599edf5d2737c20cd05eea04df061faf193d53701ae	14511
1459	d08dca4c7a1b4c2fa37be349b2badf27ed6d42cccdadc91b5eaa726cb969d318	14514
1460	06507d79424482fbe54a7e3326b86687bfbc2f087e845c61538112dea18bf02e	14540
1461	39e17820c65e97a8909963430177665d4646ca0b2b27e3de324a51d1c9a57c9d	14558
1462	59b90773de095c686bf9f709bacada526dc1a6ce7b380a4dc49a28e632403fec	14575
1463	84a8b8937ac6fb753b4e4273e30cc2ff8a5ffce25f0772a0d4ace81099277def	14601
1464	5c48b619c9357965b15caa5fc9151324179690e96d113392aa4757b0368808f0	14610
1465	c1e408e682248044b6ace147a91636bc44ef70324ca0f90170511a061763ba47	14618
1466	a034efa9eae677551983582cb10c4f9502b70db54aefaff543ae80b8728ae653	14622
1467	cd8848b2fe940f9bb396cd0eaf9ef249cbdaaef6fe0edd0c3fd541578e0446bc	14636
1468	7a9e8b6676f112aedf0cf1c8a8ceb2546694ab322fc6272027f8b5e61ca941c1	14642
1469	b4d95e4277cc89aa05346f8c844d50ecb6f589bbd117f577d3685855ab277d05	14698
1470	4aaa3e8ef082c5620f62b865a64985f2fac88999528da67398c9bcaaf16d53d9	14702
1471	94f6f39d8b1b7c1ea9e8f1d186dfb7757a95fc72378999e950a867860f0b5b43	14707
1472	b8d7da665a69fe38b91d9eda849a867cab72875c8ad1f8c949a089001d7e0cef	14719
1473	759ce4564aee13d1e03378be078f7e4850894ac5a1acfaacb708b01b128199b3	14738
1474	48d9170b04efa8458f8890ebd2f282ab59be3e367c1c940638d0064bae131f8f	14746
1475	c541f7134bd382a7d492b7aa1024d724b625fedfb4329de846e1798b6777b81e	14747
1476	4d71d7998954abd476f054acf4b832bafd320aa4d9e370de58d4fa936b1472b6	14755
1477	40de93fd91aa31f3d2ea652a1f23296658e08cd578b6deafcfe67dfca6016e16	14761
1478	30d912f73e253a09c4235de46a90a1720f6bc89054e263059e7b3f4668f92aba	14770
1479	66fc8b401a8bde8eb112ffad2df9bd46b7613d40f150cb290bdbd592994a321d	14772
1480	9c5b6afc6d6aac690de325923a37be58316acdbabc607ba38b867529ee5cad68	14783
1481	f35855818d8810b00a30257af1d8c779365d0713690696bbdcaee4e4f56138d8	14795
1482	6a6c7be067932937b38c5d957f5231037dbf9ab58420d3c44a59c6d0586e910c	14801
1483	79498399e6b672a66a84096d4d913de6af4f05fb0a942752e9936b7a3df5f31a	14815
1484	ce042195aacff11a61db7102997432de119b3b6f8c357cbaebd58a6a663980e8	14827
1485	e83571d4e862457e39658e40bdc5ffff8069a74cb6ffe03ec4c5b52842eab31e	14828
1486	16c1b87a72b355bbeb5d2b40968c0c21872e1e39eadde992eeaba1cf224f38f0	14837
1487	21ed7da368415afc010d07b42ee95fda66b81ff67c95a3770545f77ccb52f8a4	14874
1488	522491e04ebec30688ca9b854d1b21cbc890b3744f82caffdc2834bd8129c948	14882
1489	86826aa4cca293f0b1b409463eb06a6d4cbcdddb0ca8e359ac196e049bdd5525	14883
1490	4a59c1fe77265d671b83078ea2a73c92cc51d6be3d797cdc761d6392d40cc8c6	14893
1491	6fc4ae23961b57d8ff203aee65237fda5bb3d08c82633451952e301d53aa765f	14903
1492	85b8f9a6a04daf4c797f10f9c591ea05e344e91115467722320d5aecc247f832	14907
1493	eaf2b61133152ecce13c2114f44d446c7879a08c51e9beb82bc96d56911e312d	14911
1494	4428e98ee69450f7c3a66077cd57dd530547378ee9e602dfae449b402f06a04c	14912
1495	51dd0ba2915dd083404e9204eb8e108f56d6114201db387c18ee0078e27caf4c	14918
1496	b7caa24ea601d5933f9906a8de04312dd4d45aa6601878e80892506bc8f34609	14960
1497	a8ea6d12b73960fe56f26f6be401844dc19477b20e239acad39bffa09c3f7d3c	14977
1498	670f01ef7e874b3d661bf97712e15bae2e05657c53fe064535c645f28f84ecb4	14999
1499	6d8ae0d352dc4bd7f575adda90be7f998b9032075eff9cecd500c69052c3bc33	15001
1500	79357f57e8742167c41b90a9541007987e5092e91020b63c81d159e452d3f022	15040
1501	dce36556ba7e8ce3f436f1c827b5f448bc497b60c17b2e2cdabd2b6b70758558	15052
1502	d2a8fa332f3cbacf3dc8fe1b9551b62519fea95f74913adbfe9e388e652e06c8	15063
1503	394d5890c732cbcc704f4b36efb36c42c550fb721e83fecdc4fcb1743d7d5142	15070
1504	987002abcad31281a8cbf5a1e5f3b9b01fe6c981902309c960ef4d6c117c4844	15089
1505	f249b263500a039117251978774de428ba737290d4a2dc8dff97ef003f360e7e	15094
1506	766b011ea816096cfcca0d1f449b4e8252e31fb8c910a2acf9eabcd69ad0a8ee	15109
1507	9755fa2594697c61f03a8328caab4b10d341c84a24b13181028c47c5d087c679	15120
1508	5c35588648d842393c245aeb69d2a0ade2549b5d24a76547a09051189f964be0	15121
1509	a4feae9fdc32920ae58f9b0e8cd7301f2893ba8bdab5a1673fbb21e2c4898254	15122
1510	6aedaaa424e087d6b5b501fa25b4eac8a344e94eda02a5c99ded3829e8a5861d	15131
1511	6e146ef2c2645c4e820a2d3fb7483ec7650c28bc3968226842d171c644ca986e	15163
1512	a53ae817976d76066302182b743d77cfe198c94b48762ae806ec35e7e2a41285	15166
1513	21d4e906d39e7118a46047d6fa33c34b6a0559f8044005ec440481bcc96cc0e9	15172
1514	59f804fc469a653aa37b3e6dab414142be37a8a17d14cd9ce18d75b590721c45	15181
1515	d00fb82bc0fcbf0022573e2c060f67ddf4001cdfbe122296a2b4d73a534b3c6f	15184
1516	a032d1f42216b740e0d3857e3ef17727bb50b3eebc969189bafcbd0d9a8f3333	15186
1517	bffb2220849da5a3eabb19ed3e946d97519a72d1d32f74a8a15a5d7d4be3a980	15188
1518	f3ac355f4b527e4a9f09f41463333c708b32bc040609ba2dfa349b6d964ec057	15192
1519	e728058f6dfc8d44afbb35a609aaf2be628f20007bcfc4d6b2a6acb11f1aa436	15202
1520	6b3b5b6b8e99d1ef5edb4807484519d7730449290fc9412a9b874a8d0a06c40b	15205
1521	cd118a9ae432e71d0b1ca6ac0c54011e028beba66788354ea11a8c918c3b07bb	15214
1522	45947efa947235190d905a8dcfad9542af12b72b7c95f8ddd4896f893bd3fb17	15215
1523	797d89c27ecd2c0e07ce2080fc07a2df09cc77f5e90e787d1c230c2a7e0f3c01	15221
1524	227112b745dfebe6991b7eae5af8c7ed1d363cf832126dac8cda3fdac3821a4b	15228
1525	f3715f40c75865d8572b4044144158b069b526f79e5112ed5d672ed3c496b716	15262
1526	be76a4ca09432bfaba07f82d8a033b8291001b757f6194f07f079c93a1c83af8	15280
1527	fd68059de985d1e1f846b2235503896d092241531534f0d9ec958f894f24e9ee	15290
1528	1ebf8b4342553c6502d64b094024037cdcc0fa209b1e970c0b46418f83bff9f5	15296
1529	6dbd7bc5d30a89d22505bcdb757d111efdb15ec741a2289cf6f39673fbadc6c4	15303
1530	39109f0cbc50cd8d06365787949e4812b191cc642924b26e25265fff54c1cf43	15312
1531	744f949b70cf4fc083d04b2e39869b18376ecda6eb60ce1cdda1594d1e2dd8b4	15319
1532	596f1bfa068dc4099962f1d2df7a1ea3cab3ede5f603566ae3fc1ae177a650dc	15344
1533	0f0241b1b8b143abe9f4bbd2814110103c8a839d4a6eaa266baa12bf08aa514a	15360
1534	1ac9176b71dd427ab25d3cce5e37befb824ec112353b2f959926f061e9c3b3c6	15372
1535	4639e0adc4a35e8d52e80fce1bad81407066a2844cb3e1f64b7f56dfb46c9922	15378
1536	1ea0c45c73524f039c2ba4917b9afaccf1293e9120f5904d246113341bc83be0	15379
1537	c77bc8e31307465598f2947f55287f9a8940099c0a3d00480cfe0d2ccfa6de46	15393
1538	3e31f14160592800e11be6c352f36e9e5db7728185ccdb388407a0d34ee5d2c7	15397
1539	b0522de4f9817a1109aaf6663185051206860786a30f93d66e6cd34937533ef5	15427
1540	c430458f0cc84df71d619d6522207185ef669a012318dc5d9cc8a48515e34a81	15429
1541	de65bf7508736b50b9a860c6d7e8028cd701ed5d035450fee07076b0d9493504	15434
1542	1b15db84a2e7cc8dceadad21390082c4ac0f98c0fcd4acb9740ab2928a2e0dfb	15439
1543	9f1e48651fda99adb2eef394cdbe49604a8456b37ee9c3a57aa20560722fa785	15442
1544	b9387b5e3bbe4347db5089f6d9ae26cf2171339e95e8863553ff904d43a30560	15460
1545	8db3d0185d3de30b595e6f32b1816bd9a218fe03d6fbf39c30073b9b7a04baff	15467
1546	8aab8914973bc00394e1c605ec917a9d96e8b8cf6d08f718df8ed41240824237	15482
1547	859d532dcb0cc88cd64128f86f9c53e7ed62538d0a516bada125e904b0359c9b	15531
1548	202cdb31deedd46006af87f76b53db1b9a8cc27f681e33795f4521eb42e0f21e	15536
1549	0e28807007b0098d8c47464d9e8c05f2502ec3ac547594f5687801ed6699646f	15543
1550	43ef7751badac06d182f8226b5239b713ca7e9a1dae55272e4e194b670ae4ef1	15553
1551	80f57ca311dc4ae6c12a856587742450ef7c5216c1d0cf065f9d25eb283ef2d4	15558
1552	ae21280d673a490a58c184df79dd210900cc945d0a1082a963e06d314b1d1292	15572
1553	a78886d96059a9e45c50a4fe8965f4e758ed47afbece27a61dbf342a97ce5977	15573
1554	f0788a61d52d317b355e3b8f7498782d6196b026977477dffb8298035180ce56	15574
1555	ac23ce1dceda9a33dc66136c3cd7bb9a026a4596c9584cce50a1d6e86b53468a	15582
1556	6289688dfe63181aff9b676d7e0374c82fda8403fc1d8d416a12f5077fee60dd	15596
1557	a2c99f164cf8795253c6b31d9899883a2f6998b44e9f83a95b2b01ed0ea1dfc2	15611
1558	f25ef39af8ceb1b678b966bea6a0c1748bb043376dec592cbc6ca8378f3ae7dc	15613
1559	1d83bb8df6ca9cbd1e1d0eb1363869f750b091f68fc24354c60609f2f932ba6b	15618
1560	35f879023c25a013f7b6bcba81a3ef79645ee415f07c3e659e15f9f43a195ceb	15625
1561	eee09b7d621b9737d9af325efcfb91d878721aea721bab00ba4322c7179c634b	15629
1562	a60a5d3e7a22359da1148b9dd47f4b93fee3b515a9c4a6ee61079a4ebcb9e98d	15636
1563	3dd5c9836c1bfecffc4a2584c7d54a5e6f6a141a195b1d47765511f7a8fd6faf	15640
1564	c3fa1ef4ce758ad9fd76e9d63e97c844efca26325727f7e42b2ba8da7b9062ea	15648
1565	776582d05770dbad9b5e8d26411e1ca12fee152e1364422813dbeb2ab188c490	15652
1566	acf80ef8a6a551304edfc045f1d505af64fdc54d6ab32070ee0b7d21b9caaa4b	15682
1567	63c03c28043a6ca8fbb5723fcd021b345dba27fe63b6e17524a927344a241ca0	15698
1568	6179403b4110351c37eddcabbc3238f6cb7e02495d2f836a9abb933b9e8ba73c	15702
1569	b1c5e4852404195c8cdd8a8667ab62e2de942730ddabf2d5c97f432bf9cd144b	15703
1570	148ff91c49b6fd6add195ea2f7af7dac419e22f89afe4c91eb5bf8575faa6523	15709
1571	1c99c0c203487d7f4014c629e62a31f8992205778f4a65fad51d9ce0a94ff49a	15710
1572	0cb0a5df6a28c193b304996cc8b87561992f38a569ce7d7f2e4e17c4ce7b275e	15721
1573	fbc3e7bcebcfd43a876d71b9e321874a32f17f544e4122f4153130b1b0100c3d	15734
1574	7ef84a472a8c8860dfc94d289a28e712289a19e600b2b3f157aa62cea4d058c8	15756
1575	e1933a9b42bb8ba883542efbc1cabd06fa5c15454dbb84291b27fabbcc6520c9	15769
1576	9d7094b605aa5193c2863aac457b49e25890d328794fbc265c9561ce059bf22f	15784
1577	5ddbbf808f2558d28e9f79d7c07a085695f03ca1bf2853f8f90bc9f609e90773	15789
1578	9e3f3e1881c1fb9acd989846a46e90cd8099597703833a34f459c09937d6d556	15793
1579	8edfc28fd27472f62bd27d8bdeb40736d393293eff9b3e7055f8ba8439cb9f8b	15799
1580	62bd0201bfec5d59e66b8f58e2bd0eb39fdae2bf3a804551d4e01a2a0f62f0c0	15808
1581	5aebcab961b6154404846d06465e280a2090d6aa68c8d53b946775d710bbd46d	15814
1582	510d64865baafe2bb328fc12d6c8a56d43d8c043b191a61fe6aef9e4f64c326d	15815
1583	757714184ba22a914075ff9b87f191cb7ea98c64f30bb315068e8dc5b2574e67	15836
1584	dd6a0dd19b4d79d542572ebe399a2132086728d534969d222f60d65f0e186184	15837
1585	e06c59deab39154c1e3d999b9fd4de9d22141ccc2da7d1bfff7564e3dda2f7ae	15842
1586	6b0184ba68645f2701972e0845c9f71332e5acf9aaf7c18ae6494004588873c7	15865
1587	3edc6421d21498a8dcbc1179e7d33050100807ae0fd47d657db81385ebf68327	15878
1588	0d6798e5de84623687b47f0b72803f4c8f8743d5282be19390286afcb56e5bc5	15902
1589	ad964ed7b3afd3dd3e6221d41ba84247f8f4d2ecb07d7a80369a177b4c8bf045	15906
1590	dd91681085456ac2ed61ab78e4a2805a87adb9ae6ed4ec5306d60ba952ec6d98	15909
1591	4d5bce44d4031ec40b2df78845869e285782870b12bebb609c70e8bdbc6b4ec3	15916
1592	00dceb88749957381c6b3448362c26c6f86cd3b668741b2fe39fbb45dcb958e5	15918
1593	2b35fdb457209365a2330e294437205e6fe29fc96acb650120f2e4b58ea7941a	15922
1594	5e611d62cd2609eb4e6883f51049e837f86024899c440c02f9d57fa2a3f1dfcf	15960
1595	74cbbe0bb6907c2c7105b6db6f9b15fbc01421c708d27ff5f06f3f8de9fc9235	15962
1596	676e22d495e76c016df13823419b7c192558a4640cad8884ace01de3d6ff5a24	15976
1597	b6e763272effe016fb81d95506226603a579d95ae0ece145c122fbbd900fd749	15987
1598	ebdfa060b3fcd6787ed3acded71e539daeef06f8a64a913fe12748f34d6e55b1	15992
1599	41985e3c26ec60acc5181d50a43c4d2cc57a24b959a78b6ca8af00432d1fa50b	16002
1600	ff7684157207101f250bcdbec1b61c35a320f9fc9c6ebec8be8a3e29b2180d64	16005
1601	97af7696d845636e0e6bdfc2a61d8f2f93a235fda37757c6d0e46aca653aa953	16015
1602	9afa6099a959bb7d59eaaa69528dbd083218139e09222a66ea725e7ad20ca65e	16019
1603	3ae5cd8c79022fb77d812ab33dab490004de07bcd97261840ddbb0dfc323505c	16020
1604	a00f34de06df09d61b636abf84f01957eeb838b9cb82df1dd54c0da9f38e3df7	16027
1605	d51e97693826e82b4879515b790f08a4533d1aadb83a534a7bde17a8a60b7ead	16063
1606	b3588b20caed196e87a9211813f19f726a8a9094d0b38946dc41231d9b86009f	16083
1607	7daf3feafcfe23f854c43a00e0fd9631f11a50c0d0b230e633d982c5ce95fc69	16130
1608	c74f81d22db584b41c34559bdaa1ca62e9c662452707ebd08d9adf9edf1eda8c	16132
1609	e357b6beed442061a49857c5ab277e29058f2ea7fdc88536c2b5e9a25dc02dcd	16138
1610	6c17b7029aedf978624c6edb5e189dc63a5994937afef2b9de3cf655ed4930ef	16139
1611	0734a6af1656a392069986004708a55cbc73e3a3ea0d4f0cbe28c206bc114cd5	16147
1612	ae242a2763f88df9ec8543bbad94ecf816fd755cbedfb041d25f4e79919f2b0b	16169
1613	a3122cb766434e3ce3af770daa6ebae19fba1d2d1b4f2cd839c27e98a098d12d	16184
1614	fdcb32127b9edd576842c94fd7c6bb31d9aedadfa0a9a86da45b03aa7a9219d5	16186
1615	bef8f5b876d346810194ad31cbc73a5fa0972e05af27b56f96094b8b140fa586	16187
1616	27e62e1bd2b57c1e6142dc9383dc1271421291ee0987a34f4933f75eb761117e	16193
1617	f302ca935f22cc041dc2d59bff09470fe6a2ee26878c71b053f7da4bd6b60c4d	16196
1618	c35c11cb2f9f23426ed228b5d9ee4d54e28980b54128e53b110b96333fd9810f	16198
1619	f1c366dd1101dfbf4d77f571f3b4eb560eab04f81d4b6404590c702fb4e51917	16208
1620	be4c32f1dad06f33971711e7ca9d595acbd2e6afe1d5a90ac215978f89a6dae1	16221
1621	bd6d4dc50f3156ae2403ec5f516ba83647679e750605f1436b7496bfbbde6d6c	16230
1622	20366e0784a559ea51aafe6a395d31d191074bc07ab72fe1414541a7b8e06806	16241
1623	97c20cfe1f97fe4cefce1d6687b83f9363ae890aee11f5b9c9183c29479663af	16243
1624	35ab4df6fedc48ffe78e19243c11114afa3953f0f188780321ad880762c83755	16244
1625	9165aa71e5a62b4178a12d1817706810701ba68f8da8808c36ef39ef4aa6ca8d	16253
1626	3bd5286aec72e82e40c5afac0e3ea0a6cf3ee8310d55c1cdf20987c09728bd85	16257
1627	5645253f07e41e7b00b14dc60b5216d16fad87bdf6ba546542651934b2be8b5c	16260
1628	f5f6dd9d9c3dde22e1ef596d30eef0375ec19323bce0544369a6b6860f62436b	16265
1629	6273ae96fdbfab04757780a0d22f74cfa96e505098953f19e46c784a20f78451	16276
1630	84173fc12e5efb554742d5bd8b9bf0e7ec688ab1f7a36fe1657e2329ad13ab56	16297
1631	8230bd0d86a284ed507ffa33a4dab9b904942a1ff379d774b100cc4e67d84779	16299
1632	768c2660e54e4c756192e4a91ebc19915428953e2966145d21265b8d79f79c6e	16305
1633	bd499e3265ffba0409414630440e580038d5d656dc9008a7d4b8ef5e5e2b4fde	16306
1634	fcb63b21b24b281f5b22828b453757514bd58c14af9b875f9e61133ad5b7f17d	16309
1635	b089eee1c7e5cd149960feec8c6d32b9cb421f0e36155d737f682763ead96b33	16314
1636	d43879e04ed4f8a918b7363597b5e9322e2bff0ba600a29af1c870b36b8b2da7	16326
1637	5018a4fdc3bcedb34dcc529a7d0a98e0f02bc29bdd681aa61ff6a86d600b3010	16337
1638	eb8c96b2aaa9fdadcc12825a0172997e6e537f02068f7ac17c0d0fdc26d5454f	16358
1639	65703c2ecd9fd9963985530289e77fe9874888a789802d93ffb273dac868e3f4	16371
1640	a770aeb1c5370c5eeaa03cee5ebcbeb24585e10a0ec1b530b94033ac90869d87	16377
1641	32f9553b3a441c4006276f6c69195c10e2b19225b7dc071d856a73b770910207	16405
1642	1d1164f41a7a683992f8b06ee5000965265ca16df509603a7dd68a7166bf7066	16432
1643	937cbbcaa4aeaf0667bedfec04026f021c93cb7b90685bfb7612f0f218b6390e	16437
1644	fb0c60e40bffbc7ef487b722b244bb8d916662b117a68771a1bf87d94c93a377	16454
1645	0a29616a941f70f8ad72c2ced2a89af11cbdd42bc65c875e4b4bd4ed82a84ea4	16465
1646	9e452c1e97c82e6ebf1c38a9095b5d8f79c071ee455037b16149880b293400d2	16480
1647	8fec476aa7fe4d29b9515790c7472b61276cf30182838224127dd2bdddf29173	16488
1648	55242e1bdd44bbe15c5ec250b1aae701b4aeb62b13170a45110fa6fe4f7b1fbd	16521
1649	a080c6887cf3922ca80403ba6ee94b3c1ee913da92470344b926547267a0c937	16529
1650	8df4af1e5853642765988b58e23a8d498e457500c6daa20c52caea5f0b55879f	16536
1651	53dfc7641f093ed1ad5a01583d956d95215400b5cb3926e1903697551a9dbdde	16542
1652	46c4323eac06a1dcca7446c7a1bed71b92b8ae70cb655eb9eab39f7a02558481	16545
1653	5c8ed7f62c48cd28028fc00cac86840e7e72e6fbaa5580e86fe99ec5e83c8af0	16547
1654	493552d3c223bd587f75cf1e729b64e204744d61670db9d1b534e8cdd33c18a5	16593
1655	7ca1e62da5f9a922e525c47c7d79a6a5e484ca910fc8040ca206a41bc6166b80	16609
1656	06ea41f9381e0a9f0a2f124f3e2d679d5fd3903e2ba9d4b128dbf394351ae4e5	16615
1657	618085be00c9ea46b1b7707062d6da45466c61b6d8ad3e928ce498f91f2bf324	16626
1658	e9d0814913c8d4b78149d8c4129fcf6510f8ba5a51ecce8a95491edb7399d9be	16628
1659	c345955f16810b0df16af58148a355b8661cb972134ac151a5e2aafff4f3a101	16634
1660	ea288f353965cc5d8124711dbfe48fdd23a5a83f18ce756eac48800ae4dc49ff	16656
1661	9cbb74b992f07ffb9a26e78bdf027ad066b81dd409d23ddf57e2c9a3bb62602e	16661
1662	63e23f5ce076ec33d74e8eb36961fcf29a779e666af7242b8362e33d07474f55	16678
1663	e9b428a7290e57620ff2aae4dbd07ee6fac79e377fbd720d6ed62b6c2055e9af	16688
1664	47ef9a82ae497962bb0c1e7f34749d16cebed74b0ed93b8129fe9b5ca1eb5124	16696
1665	defb049f36390711e594ba1cb98c609c547a282eda4f1149fa4653df9c04ceff	16698
1666	1a4ea8bd2a3e26ddac3cb7ba531c98b8a8ecf070b2ccd7af490dd71fbb50473e	16699
1667	6e3ac9b1c4fc72493a7950cc0501c6114dffed20fe5bba193997a7be89fb13d9	16707
1668	08c02cfa4e710aac68786369f0d94be1350d518ebdfdde1853d132666e698fbf	16713
1669	18a36fb87a79133cad4d032fac1d38cbda59be8322451631d6020a7473b66696	16721
1670	0bcf010cadf445594a076ee4f609d708a10202e993ca2879a52690ddd03f5302	16730
1671	61a4d768df5fe73679ae80021cfe486e091d1f67633971df3a911b96af880ed2	16741
1672	5a17f6fc8c0e03864113c197d5d502e60e1537c157947b97558e582b152fcce2	16768
1673	51e25d88635448401fda7655c629ed150edf6ec092ade2e9847e86536bc2c89a	16774
1674	0d40bda07a7bb46926a0262249b3d243081342884eb92d379bbcdc8f0b830deb	16782
1675	75524610e27e2576423e9e03871f4304798221200517dd37792d0a7bd14cba5f	16786
1676	43de588cb007a4b969723f6f96ab207721ee8f1b144f09eca1c2ad9f1aab93ab	16803
1677	e09fe1cfd7e34ec56c752d3fc55747ecd946d520d43450ab05e64cd0f23a9408	16813
1678	bcad9f6b4dc44f4f6b08d1857321e805d56614e020631d5c8cd61b3c50494500	16818
1679	fd1c951ccb1bcb81db2258d462e733e3ad91ff0ef0c67961dbaa7da2d6e51212	16823
1680	7a0cfe5a33bc175fe718ac71d09ee2e8b71e2ae1eebbf0a431f9bf72990a9cd0	16824
1681	b305c43186d22af8b1e1ecfe666a1857009053ced4d41a77dc3d08c825933845	16846
1682	af59a84828ec843e697c3a46b01abc790a5af5f8a18ebd2a5a7814bef1f98261	16852
1683	61dd826c497ec075d48cf9cf0328ad2b52977e78bb0d8235f72f2db122a32e38	16857
1684	d0e81af3d743afbb9669b15d1d071ffdcc5dbeb44d4d153a506e0970b8bad47d	16881
1685	3cf09a74ffeee1fa2cb10c34ae1ba7926aad8d17c2218fae090613b19f16fe7b	16887
1686	025abf34fbce63e81b4f5651cae06b51b6d5d4f2e83775b06c0943d78929ed74	16896
1687	819109cedd7d64fcd6b1245dccb0214a27e792b120c18dbae3bfe9634e98cc43	16898
1688	b4589e51b8fbdcb6c7148cbe113ae555b9380ec22eac72a71eea6e0ab67d921e	16899
1689	5fce8c224af908af637d48a7bc18b56dae5a4585a546681c62764e88da763da8	16901
1690	3b5165579c9736de5ecb7c891bd187bef6f86a7fd4760b8100d08149bd093442	16910
1691	f776f0e3a901403b8965fc9fac22cc5e28a7f322b4ec66206a34539d5df6224f	16920
1692	7441e91b14d3633efde780926f5a1e38ec180ce080264973717ad32e609a7ca3	16923
1693	f424956d18c610327d3f6beb7e8463fc5dbe7988fb351db059a2fd577bfe6716	16925
1694	22bf6379869045da8d44aecb92d82a346abb923b1da8481d8bebda14a4bd361c	16938
1695	f3c8a65ee09b92c0e5ecf39bedddacf530b9f8c36351d3455776017766597965	16944
1696	ad18778931303fb633a8cd7bf0e50f472f0292f5ac8c915b8615937b5dd4459a	16965
1697	6b92e2fef33c3c66921fc0afb960d0a2921bf2afd83ced1ec68430fad3fce17b	16976
1698	3d3619a31517e527aef663d668f8e5a7cb8b2c431b402a07d028f66f0ceade7c	16977
1699	9a46d1fac2c03eb9a9f2faa29011af70224da71eb54af2ec9246cc7eb1c8ab60	16984
1700	efdb818e56012be09ecb3efa90e4f08d4e94089d3188177b66c3ab4cad7e1f79	17033
1701	947a652f1e8483c465c0906a1841a4f2a348f26ff1a2b5834bc27aa2f8824f64	17054
1702	53aa65a5b668528c9ce726a0d26551bdd1cb3d6fb691e9ddc13ec4af8859273e	17059
1703	3dc3180be107b9137730a8f3819b197fdb5c56d906253091166824addedf6f5e	17068
1704	2e09e6f3cbb41ac6d1f020305a8f9151be77d2710265161e7eab3e66f2737709	17089
1705	424bea070e2a326e7a791074756f8eb46062960a5a9f717cd3ccd6a470a6a9c5	17102
1706	4a6f217af11325f048930020ac1bc88045738c45ad257c1f2fccb9147b36b7f8	17110
1707	3135dc663b3ed71c00a20bef3e876ac48eb6e733069f54a9817b36f7bc035b7a	17114
1708	f03fe05e441589fb3044f7337e14f5adb10e2bee09c188431f69088419a7c91d	17117
1709	7eaec955a98c6256a1ff1248092a747ba6a3ff4e1cd95d9c18b62f26aa585ac6	17148
1710	7b9c3726a28e01cdcf7a55bd9f9ce467cab8d31c8f1528d81971e3b9c5167294	17160
1711	a292b85f7dcd7b46a64005166b736da1ffd4f6c1f0a20e2cb71a5fabf7ab7b72	17163
1712	de6d7afd63daeef9cd77569628a7ae1f4eec1da92023ae6d8fe6c5d5c77b8c1f	17168
1713	0ce50485a74c7fe427e2db11e42b2c7efea197adcf657be36dfd9d7d0d2266de	17187
1714	e4f8c9e99c09949de23f79da02b14727c30b16ddd0af545a5a80d98019d361cd	17188
1715	6bbb55459bb0083e771129ab84efb8fa0879164a61874e59f3459b1456493de3	17198
1716	994349b1697104edd45980b8ac8f1cb15bff8a5968dc57fd213c5f516e9155b3	17218
1717	a750d0e0e83cf1138a2ea0564101d1be6555f03a4ba916e808390c0d82a2c5dd	17227
1718	dfcfda03507fadcfea28b71e07085c14fe5593f8a9529400d677f220403e49d4	17229
1719	08ad672dc6804f3d2d6bd3c853f918d0a75d5d332f6a83bdedd956b5183df420	17234
1720	c03718daf7b464b50353694fad1da4d9a8770fcdec6dfd0ce1726f5d6747418c	17258
1721	2b124a0361cc83df22636c30ece4bedf32831a1d525e43a9587d7e84a9706f5a	17263
1722	8b487342909e31128291494a8db5ff6b51a24a301ca7df823e6e11b0b1e019d8	17269
1723	cfd2e3f44eb36e0ae1ea58cbc6b9d70c385ff7957316ff06c0b210e5fda43212	17274
1724	5dfaa00d9b26d60434cc2b3a9037c39ac259462afb01f0924a6a80ba0dcc8ba6	17309
1725	2a2af59e62d82791f9f30f75215ec9f205f27a781a61dedd542cf072f3c174a8	17310
1726	4f19f58a28184ac868644b5107c8ad28e0cbc29fc8b0b4431866ca7dcf1efff0	17312
1727	54af9f87e4d8eb0bf215b2c3ba89ce4919cddeb06c1142282be60ac0b20df752	17335
1728	672346bec0a927c4946529754de5e683892025e9aa2719b0b809fc878b96cc1a	17344
1729	f34cb8e608ff8060889fac30e0252ba197fe230525362ffac25c4090751db861	17362
1730	85dfba0e55dcbc32e91dba958bb4340de4edb559172a7f8e9a2ef1b3b577d6c2	17364
1731	b2be420a7c9859201873a6b1741aff60efc03bfbb97325b0fec9b8b5d01dd80c	17370
1732	fc13d7ed287847f3fada0958b4f546a798bf75e6a492dc85d247aed596a0e0b2	17377
1733	8fab77e1dce84ed8ea88506a9b24796efb9df70b1d11139332ce57e2c5022301	17401
1734	bea5dc395964c9fdb27b15abbe3e79d196c5ff284ca3fdfaf5ba7dd934dee605	17409
1735	70a3b747b39014fbeddf45e6b2d0ba924029991c0e0eb66875762b68799d0d41	17411
1736	f537af25e619ffde1f0826f2ab064f6a8af20febeb7732584c8f989e9e3096db	17422
1737	9c1acaa2c4807fbdbec51d859561525eb2b7a250357e6f9d166418224b1aacb1	17435
1738	4988951a0d3730c7f11e8d8ff38822f7b8c18e0fcca4cb93f452a1b13fa4d08f	17444
1739	18f852ae5a49911b151794c990587f63a3f1468e910038e39ed6e8e7c4cab3e0	17445
1740	5eaff214b07a0886040a84ff23785572486a21a254c6120452d2aaa93af10ccb	17457
1741	25f52ec28e6dd28af17e47d7f6e048aba8cb7186b7a40556dc24fa51e189d5ef	17471
1742	4173b3c6bb5d5c5ab5afef4df247c06d21e36351c19abbe26c059a603b0eaca5	17479
1743	955e2cc79845774e0c67b729bf69b54e806bb871c96107653e08986c52e80acb	17504
1744	fae6f01ddb35478592189f8a1704c158b8459a52edfc59856c6953f84dc1a9c1	17507
1745	896387a9d6ef3ce71be42bda345ddc7f43fbb0760cbb8578a6fdebb03ef98d2c	17514
1746	3049f74b59034820616c564bacf00c2fb3703eba010d4a5f8757201decb24012	17546
1747	33941666f83fc21966e81f06baeee2f51e51de959fcddb307ec2c14168697b83	17551
1748	3118131d6178799eabb72ab51f0feff7fe1d0d47c6e11ca18585e5ff5e3f1d4a	17554
1749	54123bc0545bc97ba5219db59776c515a842d20ac92dfaa90199a2b09dc726a1	17563
1750	6ec1c9f0fd3de65e89d3eea63d180acc01ba06337d0ba507dae03f3e7204e48f	17565
1751	753f97d4fc3b76f265318b9a5c509be2305a9e2f9f484e0958f0252eec031e51	17598
1752	1d5efcf703f27421ddc31fbedd8e207214812587b434fc37fdf199d8322c31f8	17626
1753	a1702033a824620b1c301f18ac68c177b2ce44b4711561147cdf075333368203	17635
1754	e1d51d48f1c3f8fa6e5b494ea16af8096eba2b4a471e6de4e3194a7c3e231f7a	17646
1755	b4721fdcc87e6ff892fe348daab392f3f970d787126997f7b73340d6f9800eea	17683
1756	c46b168b774fb9807d781df47769e3824d29d69bdce819f2bea061670ba39d77	17718
1757	1cf23f1af4a900e4b16988278c7c533a633b58789e02092516a0ce5090062b41	17723
1758	57f78227229ab1ebf3a4374de283a31b953833adb4106ebc2379233abb13a515	17727
1759	09e28e78c52c69408a4bcc20bfe0cae42bed85fb2d5dce6ef5e4865f82844c49	17738
1760	f61b161e9d0673fef62403139ce7c858f19366a8df1182e37d6f221834e77989	17740
1761	dc1ebc2bd213cf7efffed8636857d097ab5617ae0135fabe6344b2d9bf3b6dd1	17756
1762	0dd26dfb18f6e79f918ed9226530ea02bdb06b5d456a7d0f292ac4c688f4fad4	17760
1763	f18b7c81b62452d18ea2cdfd69f8a9fbb41d14bebd3e14974b77ea05cd8a1926	17771
1764	27123339af8875dbfe5c7e42790730e81a8ca3ccfb81bb8c95af69d9257ab0a9	17795
1765	4cfafc2406fc3af88af2b4defca16704cce4cca61f8713c2680209e1c6075f48	17799
1766	20b876917c08f6a753b6544ea3c039ffd07debc69d5a61d6635bbf1cb2d71dff	17801
1767	fccf2238317014524eb5f2366c86725f5cae83e2dec45397bc07074fb3ae0c0c	17805
1768	11295396abedb67983dc472b98139206815877e41df77b2966b28ea56d351b5e	17838
1769	cfddf678717722d27f0df74ef304d98f48b26f764397e74a46f9010562a0edf5	17851
1770	d1082d63e75dee6dbf07b4210f7af7266a850f08b3b904322fdbf34478119e44	17860
1771	100fb4879a1b6d63c62968cf9a484fbf7e5b52dc33559927f0b2556da708bb81	17865
1772	1f1c7f0d931493c1bbe242e2b16f2985b507435558a86d55de81e12c1a650fbc	17869
1773	131bb3f49cdd132511ff6538f50a9697bf92ba9cc1735c4920c330cd1027ef9f	17873
1774	ee53c7f7a57bdb017cb07d4691e215094ce257c8d49c154bc04a64fa79392977	17874
1775	05573811794137236868bec4c71f274ec19e81c9cf9db2d87434a0523166a66e	17892
1776	594051d3ac720f43ef79a937921777b4edae84b83873a01c6a14cc0bb3ea7208	17898
1777	d58fd62fd4ccf82219daae3693e620dd6d3008f1065f2c65bc150234e4fd0f3b	17908
1778	23374610ebae558d6c0671daa7111500c57eb0fb13fccfab96abb570f1d3dd4e	17922
1779	a6dc7f20f6f58d2d55a6a68f66194ae9fefbbaff18674621fc5e9c0036da007f	17925
1780	7343bfdd4b2d8ede0b98350d6aba33c0be95d057bcc5f4f31d36cbb8d6a767f0	17926
1781	9bd30c06842fb66488d885482d33190f5b044e46eec7d0f40700e2a0866b9a4f	17927
1782	2ed38a3a151176aa3ab4c50964c2443b4380d922c7983365cd001496ae8778c3	17932
1783	0ff5c51ea43e119dcdd527682bfe2122d28ed619a5e7960e857ba2bf89099284	17936
1784	82e2fcf813cf7be814e8694c41633d7bca4717481d6c3657452d68aeb0360495	17947
1785	a39bf40e70fcdad4c0f5bbba17147a17f061d40ab62fba2351ecff9f83250f6d	17952
1786	aa2ab62ece17dd3a2a584b4b661052020c759f24dd03cf64c411e4343cb4cccb	17965
1787	ca299061663a8de97ee664832b9d2b6387665cbefb72bc5f9859cea13277539b	17967
1788	626d7d6d4909b57afc699299ca7fe5e6bb6655379f66066ec115f5429a0be649	17990
1789	721fe83eb9024d9b03d0483b389a047cc759515efb88729d5fb920b69836eebf	17999
1790	98330d7f9ffc553842469625e248ede6ef28a9108df3cd867d8951527829a00e	18007
1791	a0fa9899fc0e3f444f6d524315d24dc21b98150e2a357261dada13af8201beee	18011
1792	f0466be351d2fc7d112ea1131bc76275b2b312699ff65439526db390a43b4c58	18013
1793	e2a8fc97fc5521f8091f12897047719b616a9771a3c25d9b68d6e4f4ff4e07f7	18027
1794	52dbdeaca629bab744a72f5ecb764f74806bf4e5c935fc508c0826559a64d2f2	18044
1795	4df8cb6653bc7199f5c98729741f3631198beba634779f032617ff3093fe9490	18050
1796	955c7b8404857deea52a863e1da839bd66e257e9319c857013d312e00e440b8c	18075
1797	5f2b15d56270e14640194e5b4d62fd4a909eee64e669fa3cff1a606794759188	18077
1798	69ed9c09686be388ed8e41859455d89c0cdbfb9c80a7a312df8d1fc15debbd11	18106
1799	eea50ed9bbf97135d4b203d901648fb2b8ee8f82bdde2788846f46cba3f7ba54	18111
1800	bac600ba8039432951cf7e7324254903369cddc66cf38263657b5f6ecb944961	18114
1801	8cace56abb20a8749319a5a68393122195663715bb0188cfb6df1cbcc89fa0cf	18115
1802	b3659f110aa085c29dc8a1521ab5d3616f81c18c88e33a6924406ca4f50d0d76	18118
1803	615c488eff914f94690389460af6b7ca49f250f1e05737bb3f8d99290e58b66e	18119
1804	acef46f329cd8677097107fba82ac9cb863c78f2f1597a7ae62c5822ce81055e	18121
1805	6d3d5f9e153a2617e6ef63e56a98982a43a154c0640cb3a44c70b90dc1179a24	18153
1806	770ad60189cad471afa1a3b2a1ce06e502cd21c0896900dee6e95686654eb822	18160
1807	818f08b2f9ab295a803951ffa5fbb8ee4f406c9c92ad9f2138ce4e186a5701ff	18167
1808	51b1a81f1970f7f6e4838af35c3b901d0d4ffd3adb927e294a2be760a834dfd5	18174
1809	1e24d1037583f5bdf774d727252e2afa9bde3946af6d1d5d5cfd769d578034f1	18175
1810	1fe76984587f256dd423568b3edf8f38090654ef5154ffa4e56461c2545a34ff	18177
1811	2c3cbc44c07aaaec48db5e0aeaf465af3c8a25d8e81cc666d2688e1783765357	18191
1812	1d429d691c8f4621fea3994fec550784744e23bcff48be6ee3a1cc271e7742b0	18205
1813	1e2c661347cb55a4869cee4f7456b30f04617e78b01a8accfe53e46f38f1ee89	18213
1814	77df09a34eaee6afda85eb2c124d5206e5cdf632fbcc3101eac9c49fd59fade7	18234
1815	a8b077f933aae2fb9caa960b791763b61af0d40b456221f544c25fb7b0bdb9c2	18238
1816	3faa54373401a8dda2213adc75be68c19deb6287a6b828eb730ca478004ababd	18242
1817	a55720bc405814ad14371fc779b17db24938bf2a0a38adc2812d6f19c2b08148	18248
1818	af97ff29da44141cefb4f923e0efb382e1fc53faa582c896f847d4ea7ce1e444	18254
1819	a2fe7c4a495f3a21baba3500852ff86af3239dac5d4e219fc3c427b1666e23fd	18258
1820	330bd93becd646d40756e557b4a3566e54ac4c6c4b80b575ea6e815c11e05e6e	18271
1821	8ec4878bb9f9057e2b403b2a1064a8dd646b7b770efb8eeb347d83b2e614ddc1	18276
1822	8a7536ba0719cf7377bee65bf361c318b5cb6c2fb130814f5304210b5bd0bc7f	18282
1823	7572850d60a608039aeea5905795ff85551ea013bd5f6e23c66af002d57fa3cd	18303
1824	5355e622762065220b419626156172ed08e216dfefa42bbf2cea9ca851fa79c7	18304
1825	ab5a14557529424df3bdd3a34b7d8241e4d39e7ff4c5880d98db414a81322f02	18321
1826	5b3ec38cf7a2b5237d1056af886839d909475a6da3da86f728f1adf9fd14b6b0	18322
1827	21332b5858d5bae9a4ac8bf6bdd951f7c3fe765ba834b20f61d29b7d644d9cb6	18332
1828	c830c1a33c47e88c4cd6742c7137741d1b6df0a5b4eb800dd9905a53a8dd1139	18334
1829	13c766282c217ce87bb57a882e79f0215003161e209f50d00c7d2cc9cb58613b	18350
1830	0b3bf74f696a7c0877c6f97697187ba5780638428116b5df89e3e45cea5dde87	18358
1831	132ed592a796c170c416d900fbf34f35a18906e51ddf5a7e43825cb48dae1718	18361
1832	3c88c518a7e34afeac5a193fe64c8be66b5a7f9ebfd763c958d01c036ed4628a	18362
1833	dc41018925c2be5ec6f3bae62be7e1c32dd758d2ff9126851d72854461a323bd	18378
1834	6e75c395d8627bb264551dc0f5aaa12e0c188b046aaab60bb25303e931e0cc37	18382
1835	50426496e73bb9aa7cc0507963ed83ac16420b5b08b37a2aac433e95a8cc811d	18393
1836	fd8a1e557fd0d7c81246581b62558d20f5ce3f7c8eee42d5696db8edd75ec5de	18394
1837	e1ba433da6e545e27df94bd7c66a2a49f2d3966bfec73942bf6c2b436784b511	18395
1838	4b3b737780918c8fcc4b9c2f38c3c2fa4ec7546a48a48f5c90d21c461ea7ea17	18418
1839	971c84cd047aa5e01568da37bd10229cc1737aa9fd0ffd4d8022e3a20e7355f1	18433
1840	7e065493b39f04da79e8193737518be60eca1fa11a29894dbbe38808c6861544	18497
1841	4260f75b709216dc6908575f99919906c70fd7e2d44fe2eb6eefbab51b845f19	18503
1842	8c4db787d1cdffbe662434d3f590ab30b34801f551e17f39dd2740b776e69848	18510
1843	d7fa15cc03525364ae384370ee7e098e8811ecda6943d1c13f76e5439bd4bc9f	18528
1844	6e2ee7966cf1825ea69196039f1d77c46904313ecc11a79fe5893e1fd4b5c454	18533
1845	f4370656dd100b68b15be8658df197aa2c5713af4c3325619e1eda6649ef3617	18538
1846	08e03d885c89bcfc6c315f68cd11558f091d933ee4aa098a0bd47fa96f2a5ca7	18542
1847	aa1d1e7dab196a826ffa65e889e2ca4aa025e183f18a06e338e7dc413ea1ece6	18549
1848	f1af23c90af4ed06391dc23b8593668c411afc434f04bb6b81055c584ac9bb9b	18551
1849	6727db34cfc5fc97e2c4e6ae9f7f62f04de102626a931911d8f7aa2f39d2de92	18558
1850	958c09b281704119189c1cf8b33c9f844cbbdedc3a4e8068b77b7f057388f5cc	18566
1851	e5d5bf1fc24f1c4ea3ed719ce40f2cedbe9095417845157651cfbc76910f7eb7	18567
1852	f42092e8ebd3b898af681d77eebca0209eb559d2beca5d599fec9c928a1d2200	18573
1853	96332f277c03d6c2e13a5de472de55b1544c03c1ec2872d9b1abc6c71874d311	18580
1854	d9dff5ebd2f85321ec0c62c5f675d42a573647c2ee51791f4bebbf9ec9c89528	18590
1855	c8a8627bc23290ed8b5c2c5ddb5bb864bd804fc7fbd2836d3fdb4a7dccfb7d5a	18595
1856	6bbac6d5733d2dc03f3df83bfc98e461f81b8cde11f1f53562b29fe65f5cfe12	18600
1857	f9d3f1b3bed973f480840187c8f065453fdc3cd1af3bcd3d5162882f88e9f3b1	18606
1858	efaba13638a276dc8fa5bd844f8371e7f0160e45d529b464ef7d1284b2a0c022	18646
1859	13cbaf291287a6edf774ac03fe2ba1d12c9d402e192fa62a7b211d62e76cb85b	18647
1860	a8e4fcf37c1ae859a9c7b77e63d107f2b8ac612f447850e32fdc879e3f471ba4	18657
1861	d58a71b4114351e68391056ae3dd47cad8d1a98e781e143a59e2f11bd5dc0f9b	18673
1862	955b0047e2dd342bac1328965df82f9986015516957291dde63812b4329c259a	18695
1863	fa367df7b828a6bf82c7f5070cd2564f81b117136e5b3192cd2b208b67efdde1	18700
1864	395d2861bd9b24fd58903fa94fa6df45d270eb321092a0abe2a3feccaece7539	18706
1865	b66c12f8cf1963e9c5da894ddd09555b997a5d8b50393a8372fbae1fbc2a6d46	18710
1866	eb2534c3b79a3d110f31ee4944080ff4fd35c18d10b08eb270bbaf36883acfdc	18712
1867	180be286c08438a986b311603b4d9ed6fd8a0110f20cf8091a532d8c4e2f8783	18724
1868	af2bbc163fbc3d161241c6cf88b798f845aa6e84beccf987f02e9ab67da793c5	18727
1869	38869f9e70c9f558237a68abb31ea2c0aee703d287afead1c6cef917ea909345	18731
1870	290ebc04ae15dfda8666dfbd77ec64e7f6382e4155a17fb921585b7b2f09a6a7	18732
1871	9c68dd14148394ee0513831fc60a957cdadb5636460927f6d996711bb4d8d29c	18733
1872	78ef04410297139479c9a719e3117c145c390bc6f4cd767dee6c72654ec537c4	18737
1873	75338eddca8505dda704961e9a620bdfc53990a6f45035c18f05f4e0b82dadeb	18745
1874	492b1ace3df3d9c129ba4a029bc3d1e8887a0c2f17c9ce1da25f517afc5fd065	18768
1875	f88407f51b1a8b155ab0da391dcee7ce191d7d64e02236d0fefc1e4140f3d2b4	18770
1876	6a38a5d693173f5bffe5b53abc4615b4531ce5303a0f62705607015c4dbd9050	18785
1877	90c2d12e05991fb7aa9f9e57520c05f4d2475ea44b63e59c011cc022b750d400	18786
1878	b7ab9e489539f5f8f86b870b465a292b0c3633060ed50a1d5ce54ce6c2dfab2e	18803
1879	cc7c2b6639077768da570b843cf4eee80395ac75418185623b95f6293d309347	18833
1880	3095bd2b0d1134c1447f17fc662ff12cdb978123c406c72b833e020d9fc90d09	18835
1881	329e333e51b88dc66735863422e5db3e9b25e61af16a495a4cb27ec56764c006	18836
1882	9df0fe834e0aaee710d47f13b6b09e3694ff85aa6acd6ff57ca9aba4cf79323d	18848
1883	e1612ad926f1c3759d7198629cf405ddbd36210c638cbe61ad36d0be18d41b8e	18857
1884	3cd2fbd724d12cb08e156f41c77a2aa6acf53a5869ece3440d0657bd6789695a	18863
1885	38d238d74c40223294ca001706157471493f736334d0550eb8ab70f362a009c5	18864
1886	e46fa1a152a8dae645853ddb595472cf89f9a53ed7029c51c2b5df1c3af574bb	18869
1887	409bad4fb9639e7c83086f2597bccd38b8f12437c415326fc51cf90460be2ff9	18876
1888	29360a8f54e3697853fcdb94b865b1efe65b3939e632725b5f959e83c6b7b9f6	18908
1889	98822bfaaebf90281a5c2788e46b9a8957d22f70d38367e1a23c996119eccdd5	18925
1890	48f2d0398c5df1325a61726684586bfa3711970a5654353bdffcf8a144deb1f8	18930
1891	1e3c5f420a10df6c24299ccf49abdba999c68a8ce2aaa3103f690e90d81a1f41	18947
1892	ff0392924a844fc823e2e010d950a6e155e16a93b0ea86bd70bb915e7a1a97c6	18951
1893	aad67c70dc2b31dabd1e8c2222cf1916ea1b169435981736cc19679752e940fd	18952
1894	bfa4162ba1fa3913cdb32a93d5043d57fb04f11b75cc8d788b4a945b7ff9b22d	18958
1895	1b87aab4fa46f8f82b3313009a4c10ef9b20a0e4edbd859cc7ba541f7e402552	18985
1896	72a0dc1131a0a7c8b2446e595daad08e47876e54e734500b2327bc3438dc205d	19008
1897	0dbcea7ec62c19bb44ff7e6cc9f86a73725d3f78644dd2d2c8d2e22340c4099e	19013
1898	defa059a92984f7647a1abfc4e520278483d76c823bcf972403475fdee5bc51e	19017
1899	ec710592da244bc68c6d9975e3e7e9c0a5007ee45da0dfa395052ac5ac4492ff	19018
1900	55c5f5721a667b8feb12095d438be3bd9b0835cd5435cc9a278ef5b600a64dc5	19044
1901	22351fdd96cc00a4d21594775f95d0e528b401df71d6720c1f9d47b70d2c4408	19045
1902	a35ff921c5efc7ea2b002e0c1e7f648210b9d15e89a8083cc8685557d093d5c4	19046
1903	d91a369e77c0000b4e1af5368384ecc49d4cfdb228ae62485234b3b64a0a01d6	19058
1904	0dd2417bf221a779b0a2de4db2007b02e01793dd3c15a068556faf93e4791ac1	19066
1905	dbde3a585689eecb84694cf78678a73c8b275d7d7dd720efa5fdaea0c79349a7	19073
1906	0724ab3fbf60d3a3db7638c38650c48992673eb0caf03dd3d9d091650d6369f5	19075
1907	18ba6511d99e5ea599be015e5798484770af34cd937fdb22d561a1ded7ad546a	19077
1908	e37392064bc4c0bd9b3c090dff42dfa3bbefc698ed30aa16074421c2eade3127	19078
1909	7fe80ab54f84c096e93bfa7fa558170a1c4f1f73a88e2a065488801e86edfc9a	19099
1910	ce38ba107bf2d7b3eb4fe2b807505e1de4a8cd5bcb96c20d20652e23a401194d	19101
1911	23f768d997ff49a00e8ecc27180d81173c78f04e31e4b6eff26bcbb4e6611ba3	19110
1912	f4bc138b358f341b005417dbe7ed8419c3760730ce4555687f818dc2d5a4e72a	19120
1913	c6d8347fae79c12e4c7bfe21b588e49866f27c37e9d55cb6e909caf5d8369e3e	19136
1914	2ee8e297cc8e36b1a388f7b8ccd3d90a69ee3f1604b242e623f93a8d3f8a7329	19149
1915	236305a26f2b6ec1cef80731998c87c2b4f5c2e57ac5f30891c082ade4ed97a1	19152
1916	ea2fd88bfdd72d429e5fde864ddf8106a028e16e1d0ae958205939a3cd92cd20	19167
1917	5f29283f2731d6e9d3e4196d6048bb1dc264486397d80b58103b410f45d3b328	19180
1918	c5e07ea7041766d24e59f95f65e7ade850471bdf77983cabb9db5bde2060be0a	19215
1919	6802fcf31a9999f0b5017d32d54c4fd81a350504395fabf086bf796b016d8c93	19228
1920	ef06dcde11aa32fd74d3ed703219bdb4f924267133b20931ae36b68ad5210546	19236
1921	3d1b27d240fff0e011107c4107abfb47e91ecb7337fe1c22a039a172d574bc72	19238
1922	88991c081c2cc9495848631135797533f7a09ec780c5fc1c4d82f13ab0398ac5	19251
1923	220816602b858337fd9b8484cec14801eb89fe2c00d83d07a9e74c3f6eb529d8	19256
1924	f3910528325533b8fbc123501bed416480ad40ec79946ce8044f69743f3057f6	19262
1925	85b48ab11302af2b68da33455efefe8351c29f38a4c57364afda0766fe78a606	19267
1926	6dcbe63ce341c49fe24cd436d6cfd26aafe7d658d766daf7f47e3d354fd80c59	19271
1927	ec9da4422e9d6f2fd284930bdcbfdc6cd44b327dba46dd9b3f32bfc2f802fa62	19274
1928	4f0784d2ea0fc3657fa0481e2ae8e4c9dff8da973dd83327a4d7866937807683	19288
1929	012499bd22ecfcb713cb718d6f9e2a2261367aede56f90203fc093565ad0815f	19301
1930	e0db763327f5ef4aa9c09c44d9504b19df34a664bab507d45c6e674cc4688ead	19320
1931	ef2209c001e13652a86c84e652b915b11d33af7f8bf257dd6ec3ed83d3ddfcd2	19322
1932	2dbf07fd9811e9b39407bf443e0b2dc1a9912ee8214853f5d7632d46c93d861c	19326
1933	7fe15d7a175c53754f02913b556b3fd684f844f22c82c789d6b48056f9eae807	19332
1934	cd140d145f4ab485054e60bd7b6f9a541ee620b4f8bffc8093c0445b0b200134	19376
1935	7b96c60c20a6959781eb8ced403602affa356a5b10da94cd14374833677a1723	19386
1936	1fd91d84c8a85e7779823a150e2fcc3268bfabe88f59665b2978ed1234ab1a08	19388
1937	f6ee8d024d97e47e084872c5c7567114d157533a072aeb42060130b669df18c2	19463
1938	3cc3fa6316098e239030a89556e17df02749d14b5a27a4d0a370c924f9bcd3d6	19477
1939	5655b466a6a2248e9aef1b579996ef3162d68fb1a5fbde6d5b2e32d0e1395039	19490
1940	fad9f961e3d96c63a1c608cd3a446b837295bc694ff5b2c879a597ad029b54fb	19497
1941	79dce77083fdab289d2036322d514f9e318f0f0398da4d26ca4afac460f49ce7	19508
1942	e54f325b89907e57a6fb22124c571deaad0cbe2c3aa03a004af59e4115a29543	19527
1943	5707242d4296872994383091867358f61cd50d893a544c5d18e465cd97c9b74b	19530
1944	e250e25779375bb35c8d5549f1792b04b9c328cdc8db0570153421c977265198	19545
1945	6098f69aba9a1ef6c4d5973a3c015540581fd90ea3355e1c067f4a763d61c5c3	19569
1946	9c5cfdba20334570878cca97f3bff78af5b6517f118d7882452bdaaa33ca1a75	19574
1947	9c0801095882f33ae3144d0e157de781050931776aeb192215d17c3ef217a8b7	19576
1948	def23d367715b4375d646dfeda6f71eceb8bb37b1f38f1af43d85f29b94ebb2a	19583
1949	e37464f9c3a2014250e2b566b7d143343cf7e8dd5c1426b0bd8642132779dce0	19598
1950	9073c6859367128430c7f1f71dd0108b0150c52f26548df3d52b02ee8b20ba39	19622
1951	076e525939032a87ffcd3133e021fd48562d760ca186cdce6d74288481efd295	19626
1952	c39a1342e3ce2ff583f3d82235df65b866fc72c0d74faf5e6722a9ddc7a7fd67	19635
1953	c04c7e592eb2fa233c7751d2998b6440e45e8a7b082336f735a59ffe3613c2c0	19648
1954	6be054d791a7bddcdf8a7691f03944ad7ec3afc7317a78905ac7ec94b8c41495	19652
1955	73d8b87cf6a0e041a53b6d710ebe1b08f218da64fc8ff11f4364ed93a6547863	19654
1956	5a2a311e7d372bf190b457f40af249e45149cb6affe40e1bc0703cb87bd467be	19666
1957	c50a3c7cd02ba3f2b753a7e9bc5f6fe9b094037bb07877d06c0787e621623373	19669
1958	c4bcb544f969c82184a6a3db0b8cfbc43da2366ab12889fc7f5df2d86d67c6ff	19702
1959	0d2566038e8a986e83d2014edf37a35c2d4235cd1db26a72722210023c1ae409	19704
1960	c4ebb49b0e8dd701df1c69ec2c4b48b55f8aaede2d0fb7fa35d4233097a4ce98	19754
1961	1b895f7e500da9380c63e8fd1720c7847f700398a7efe8340527c41f4553a9d4	19764
1962	ec1e1b818ac46d7deb5df03b5797780d0781f94cbee138a4ad888116236df5ff	19767
1963	f101adb684483921181fd3108b4b6f96776be6519a4cd6550dc9f157ca5ad623	19771
1964	fad1e76d5a6a85c0482499841880981083287e36416f5fa1cfad5248fd3dc579	19776
1965	cbf25cd3a591cb6b67b0d01af94a61c566b0db01cdb96292b3525ee8514846c8	19798
1966	82837cf3923e0b2cd58dffe0ec891be8ba836e6c1b95471cc42eadf1fda88ff5	19800
1967	7c736e169a76e74bc970b6c13264f5f78cabe41dedc5d8688bc7941079a96a97	19818
1968	af40d7fec9ab7509325466a299bfbf25655103f7993af17fcd6224ebfd9c4264	19836
1969	0f5ba0f5fc46d4aee4277307b8c346d47fdf3a91a53908344be5628204e09509	19848
1970	f3b63e05e8ca0c5b4206b42b4dc3fa7184c955d77bbdcac546602310b54ef033	19852
1971	44b9b8efb86b11d06fe3cc22e24277cf85c61497e14e6ec6a0f03364356aa089	19873
1972	57945753ecd6a6cc8ca62806f5ff8324b5989010b7857c6ba5242c9a08434b75	19884
1973	795f5f3563bb5651046fada3b5574d7ce62ccb8d06b6b2cf84e313e184c9b24e	19893
1974	c6d73d013a8ac548c91225d02dde233f31b3936d0eb9546b24b9697971522b19	19900
1975	c7d7132ca526a71a8297969489291d6c0a43d807bb8648ec4af875ce3bea59c7	19909
1976	fe7a7631235740ee055f190da65cd3fa4960ef53fd7bd621aed857cc34b6db6b	19910
1977	932483fbfa27a0f984a31a30b94ab4e4a400adfef12ae5b680a464262ea2c44c	19914
1978	93d24482c9f2bfcfa0b454b39d89a5ed85a89347d3507a2846382b2540d9ba36	19937
1979	2f84e5df2ff7786a76e5ef2df55c7148ea7e25e480449e767e973159be9454d0	19943
1980	fc6b3a1015cdb386544846e5ec9f531da2192dca1637f89afc37271592ede409	19952
1981	d39510a89dccbabc30de5ff8171283043a1c0e770b6eefa2881a0b6e2ff65571	19983
1982	88aafa2ec85fe0e6ff320763dda8452a76489a917b3c07c03718f4ed6627792f	19996
1983	9c2007b46ef3cb1e9d0f088a925836d77beeaacdc0449c4cdb2e44d6be18387e	20002
1984	e805b49b3ac60976b8dedb1661d0c116491372db43a2191accefc645ef1f59e9	20003
1985	5ca03b99f4770a76ec857f5d83b39eed703aa6fe8eca0b60da350fe622ddaf39	20006
1986	355f2ac3dca57adcde74fdd50489a58ca4dd97e2bef3cd92f412356a1d5601a0	20011
1987	481969b4d8b3ef0fcc7d011cad62118db94808a55fa95aaa1bb072cbcbd8f64b	20012
1988	65b0f01ad69cf5cc7708576f913621c434a0acccf56df16ba9af334f0ed2da45	20014
1989	5116c6e8d35fb847fea46c49e04c1c163c530fff36ae8e03c6bf2c5f053f247f	20025
1990	231e538258450740b6926d3662c983c7488338e89dc846da45cffb89c40d271d	20035
1991	d7a8a044647103e01960c90915a96836cd5a0a832e531f143b5880c979ff3fee	20044
1992	1cf003c11419aebd24c776269d4e696a167c86c525f54abae7650f11d52bac9a	20045
1993	90d76df2c370753d83724649b3752ca3246df0e465f8b56b30c6af2fa3c1d449	20047
1994	106982901b439feb87c51752f7f31dcffa1c89d7f251e9660bfb45dd7cf9ddc6	20051
1995	1d3aeb5e6a37d57f7f8d0bb2fb056b666f8b7ceeb6104ddbbf1fbdce394b6f71	20055
1996	a68f631235575e6d00bb15cc237c60a4fd769c0c05598417c57238573b0522ab	20058
1997	bb65567adeac11312be7b4c014ec78ed5faedb89b8e1a3a14b9a3203ebe32558	20062
1998	cac235cd652d13bb1c21f86e29fa9288ad39b50a81240882870b559b9f6f97d9	20071
1999	d1aac1fc42c9b759e98f9af43f9cefb6e992ec9e7b7bbd5e00b21a2715f04ce5	20082
2000	e9f9c6501b2c079370f64d375886b739d186f8810e8c9a480f7ba0c84200da24	20085
2001	d62c10b893037f9ab0531fe33882efe7cfc65ff9d689fcbd432a0ae52d7adba0	20111
2002	3479b4b8e23851815a7a11bde78138f6f4402a27b2cd06a05e490b9256f61bd9	20117
2003	c9987c1c589adcb4beb283163baed770a2aa3c0f4bc88ee8c1a012ee929adee9	20118
2004	185210afe87c66ea83408d277190a9704128311f1d96f132d657de4f6d96a5a2	20139
2005	07a57efc9860dd369d3904671a574df86fe3b6156ec931c62b94b973a7e0bb1e	20151
2006	c8974a0148fa937d69e69e51aa0232734524f604be8888a026dea619e522f846	20152
2007	f0439329607eabf361130a95b7240ddcacc6c0ad6796e7dd13ccc12a67d7673d	20156
2008	e5fa72eb7e7ca549da7bdb5981d71741a33f52a819a217997e69b012360624a1	20157
2009	41f12c7c6012b5aa171d3cd492bff9ced7c49d7a29a569d7c90345f344c65717	20159
2010	1800daa733a1a97dc8c460d48a5acad79f7f179b04c3191f6a1f6d055e995c05	20169
2011	ca0986491556f61bd27664e11175c8d575b29e1dba36dfa16122fa08deae9ca0	20171
2012	1d9aab0532fd0eff1328d60df396c608eefa2e01b7349a8c0d7234b4f175bc00	20186
2013	fe278f98bb85a5cc28ea927ba7615890440f3a54358f848ddd782a737e271c9c	20212
2014	26660245cf353293b66cad2adbb2393d4fd75ae8e0975866857d4b2cdf599c38	20244
2015	85ad79804f53cda76eff09f8564a4c4c8f64b5c51c92ac6f5a04c0d0e136955b	20251
2016	93efd6173427882ec15796729f1376defee6d1a2422eb270a19b9ea63cfbd83b	20255
2017	1f251538862ca99ed9e5dcd64f2ec6444fdc457684b09e1632f85f5822c3bfba	20272
2018	4e16526031da02c70b2c6ec7cc34afc92828e2bf0cfbb5966e6bd294c89ed07c	20293
2019	ab59716412d85b36c532f1f6276da770c18683f8a2adcf0ef4b15ef4fe06534f	20299
2020	227f21fc14bcc5d64c66196b939a037b9a4bb499cbb15e5090feea83c5360f42	20317
2021	2803215dc5a3d381f680d25294a78b36a96d5968be3077c83da739a8e199cc95	20327
2022	ae4b4853f5c4eae726aa4384420a8554fd68c3247d3933c12c4473c333b184da	20335
2023	d2b5e27e9d7cdf4470963472f0e2caf46b4dc5011dd575629938427cdadb0efb	20395
2024	130a066c7fb39b91dafa885ea5fcb0d1883e451e25aabd3a8ee5c56ea2337631	20400
2025	92ca59711e0272e089e91b1668020915edef3538f0dcf3d3b3a41a50ae21b28b	20404
2026	cc1f0d5eb3265e38e95d7f49892793bca1e557d52bd6106180a75ea90241b921	20406
2027	599906c4b0a352d5bd6f5c3f7a52b006d87503483f73b3a9b9ef6161af422d1b	20422
2028	45cd5de16663970cc45147af4ecd387cd3c3a13fed646c926ce38162022191b7	20442
2029	cf6a489a4ea0e97578f3e697938f73c9dac154e379e9412840af68d02fa02142	20446
2030	acbd2c1a0f46f30bbbad45b6ba85f0ad7e6984ca95ebe885f733b00b458f87f8	20451
2031	7d225b634557457bbe1f5d53e9f364e9f97641256de5740b62a2a8ed2b687956	20487
2032	0e7fa73e55fbec09c3537e4bc6744e437e5a5f6c9b494be499165aad479b7276	20506
2033	2924da15e902e984850e394b2b49b2562c4a34fbf2a9af0a6c583224fde07437	20522
2034	615e3559cc7ccb7aeaf487cd06cdabd4fe211e54260f8395c161694e22298f7b	20533
2035	94350bcc9bec6477c5afacf65f5e52895c61c13fc92974eb954f54e9c6cb7221	20549
2036	ec045670a51b1ffc4f0c68bd31716ded8a2bd5836c764890bd0a606354a01e88	20587
2037	738837d7052d8046492134a07ada036ee14c5cc20625c3168cde484ad746c98e	20598
2038	ef402dadfc130427b0f297eeb8e7f8464f00cfb3cf79ba60134c135919b90b3d	20602
2039	441fe552020a5d8cedd0bb7e7aae9a9e54e1c086276f6b7c7431a3272b7270da	20617
2040	bb0f07ce97bc8e22863b8ec15fdc1fbbeee829e2f7a95d966be4e72e479ef648	20631
2041	46c6f50eca1e3d229ba58688e0b1fca5fc91a8298d0b7410f519dda024bdf011	20632
2042	c13558a12476f43ae05fbaa9ac7a4da330fa7ebd42f05d1a852f8b25d99734de	20643
2043	eb1f86389131a02667cd4318be640e732fb31b5503176bf4c374006a6c884585	20648
2044	4d892aacca08fb6ccb5625ce69244f56ce32d8ee0315f8c655d095081b5e8abb	20667
2045	b0675a5cdf1b341f740199b18903672aa645ae9692925269a40348b9a7ca035c	20683
2046	88cd4eed1845548ab86565347ad3bd6bd74c1a8ee1583fc92f637fe0ab429c07	20695
2047	6ead4668f90363449f513d6ab1bd56de084d0525bdad7fc9693a4773b48a0569	20713
2048	f06a208e9e5d0de3fb76a5419e895691f5fa15fff1bc17aecdb7630f047d69ca	20732
2049	3d6713a30b42384a77198195e9c2a4a940a8f02e7db9f27834c863ad84573f13	20737
2050	dacdbb21c023a6ee407eb1afdd1f1ccf6b019c3c3c91db9c1ad1e803eeded5be	20738
2051	bde41f03a73bfd619e9e97cf0a82508ed2b81e32fc6506151dbd5dc65ac2a4b9	20747
2052	e27f87fe500064bcf2975e3e1182be9344af5f6a1d4219d7208dbfcd64edf16c	20752
2053	032777123eb1056bef2927516353b40ae531af40670bd0ee4837096379e5a24f	20756
2054	aed94bdcd11fbacaf43865d4144d7ac981468b51094640285367bd2030001382	20770
2055	14876897e828161744b572f9cfa5980d3c475a038292008d8ea49a874f65711d	20779
2056	9bc88c8cd830ad805b4e14b82f99790936689273fd3697495410ad3564f6bb30	20787
2057	dc5db489968b2fd320f2b8e994b99acd77d612eaabb09fbed2ab6bc6d6bcc328	20792
2058	1d745af6289d37a2953736c52cff87cba3bb34d6f89c1f35cd5d2a2b4aff8f64	20830
2059	032de6bd56bc36fd11727a622de65117d17a152ef34b9d7c34c770a5d89b5e1d	20833
2060	1bbd4f97188d813ba64083a1e771d56429bcc979763c736f3e0fba5debd03ad1	20843
2061	bd33040703c3dd6bc83d324c1b8e6eb0fe985711651d603d70565e8887a59026	20847
2062	3e93cc185e98ad57a1e37bfe0774096a96b285a213666060c8c3b76f842145c3	20854
2063	b5121778db18e58288d936dba877ad530fef52912c1fb3f23aa0aabb2b129f0a	20863
2064	6d9220d676c4fe422a52a8693a17e5701be3a99096f06a358451ab2ef8bb1fc0	20864
2065	fcf555528a020870943f8a707baca0d87f37d80be1f5f49c0e6857278bfa9579	20865
2066	1749848f47ea3b22da11e8e35d45bf7c9fcbb4d25ae976c58bee4a82d3e3184d	20868
2067	5b7f1db4e021c160ca03b1edc306fddf23507124c3ba673395492a4d4d4202c7	20873
2068	c121918e8e383000ebe816333c210cd20fb988540125188be2e48941e9e91600	20878
2069	3db6805cca8c56246b0171ce25a0ce32b1c635abb0d828e7aa2ed2eaba26ec8c	20905
2070	ed58d2440d2fbd88342b3b7628713963d1c1b75af902756428dbc4a9e929f36e	20909
2071	954848921334a3bf9b4441761fefc9ace71fdefb82697e3d277bc61366babf40	20933
2072	333cc8c1f78ca120e05eca88b8c55e77794ba690f4575ed4de777f917cdf7780	20936
2073	a1de15f85f8fd5e73935429e166a137f670cab11fdb961bdf9b7295836182c85	20937
2074	2cf3266969f56f870374684c6ff51febf579fac31fc4a74d0596dcdc14e6f46d	20942
2075	bbc3606a049bd0ac42d2ecaa44fb36ef5c8963e3404cf4a1d9bf38b5f66b874b	20951
2076	35e9ddf2d98e236ef40a1e295e0ba3635cdc9e060c655c49207bbc25d5600a60	20957
2077	d9ed47e5cb2c5f48a337ab75027e0b09989024a286cb330f0f1c89f313598b04	21031
2078	1fa08808f31b1b463523bdb149377ac6d4563bf678a70bb14ae892314c758dde	21032
2079	dee6453be03d00a2247dd9d145ff34888d227f6ea7ca780d54c9235970187a01	21042
2080	ea4cf0539a6ea983efdbf1ed2dec0854d4c376ed3c0dd94730b514643dfd789d	21057
2081	914f5b098f29a4cde3776f1850f4000b3f180e84f4237eff5d11059b65610f14	21081
2082	f6a0580064639e76ca1852c27a584252fa92c9e8a430e87e3060247d111710d2	21083
2083	2ed648b241a17f3b92f371583473f38b1a0c55a74d5f705160e9d5a9e4e66578	21088
2084	4b4f96be2806f7f6d398b43e6ea57b6f88f3fda0405c3d3af845f5373c3c57b8	21095
2085	6bddf427352c4718f2bfdedd7fd74adf6e3bc97a7dbe3fd6f8ed55ca167c8aae	21104
2086	6dee9a1d09ce126d4698fed03b8e98e1b4ea838f32ed869bf912dba3a52a7c75	21110
2087	ec37753beef647c444e39fa256fe83836c172fd7effc225448bacd2e6cdf3c66	21117
2088	61c65b3f89669c4a151c05ac2c8facff2022022893f596188c2589ea72ea9c95	21136
2089	c2c6600ce2f19946f60a232238f128efeff4fcf27296eee2bfd3f047f45410c7	21143
2090	c40fde2f327ea502d43f6d3d6327a70696cf38d8df2d7694ba6da3e935c10674	21145
2091	224d190ccd1a2e673fa57960e7cd0acd7c8806c18711763b37088f5bf9867ca6	21162
2092	91f9ce165bd2bf6c6615a12ec7177b1b0af7df843b5870cf855a239bef2e4a73	21165
2093	52a4581e6b36a660b7a4a500ae0916b723243e52be82ef0b756e09ce247a2d00	21168
2094	09902742b8b996a7f6945baacac6c7fcc4f35cf9321bd8c3b152c1699781143e	21178
2095	5f6232e02f41a79bd7a3185cc335aa39582a2ad8d302e55526043db840d0d77a	21181
2096	ddacf3a1a5770f34ed566cf7759f204ec9dd9c2c02513e1686b0b6a40f095c5e	21182
2097	a30e8d85d5f4fc2f1d2bb6a38db394600321474cca0a99f7ec2620be86d3672f	21188
2098	7b43a06738eb2e972c282fc1393b67825c1d5f20842aaedcf4a8debabec81b5b	21192
2099	325d5b79362175ff0cda0c21038d6273b0920ce65157ffef145f40eb2fa6fbe9	21210
2100	052f48d1ca88333ee5a40b58a21f63d153af39009a812e3a9bacd5ec8c4d4e9a	21228
2101	484eb65688ca7dd2bb0f62722095ed3e7f4a2a28017b6712cc7fc1292f002f9e	21242
2102	3bdd221199b0148797e145478580f990e054a4602f3e6706ecb72148ae003e79	21247
2103	8c0bfe96f0cba25cfe989a4ac7cb7a4bfb9ff5b46bab2758abfe9ff9577baf63	21266
2104	963f4ff1083e193417cd0de8c60351f0b41bffa96ddd8ae85998ffe56184ae17	21321
2105	c45642c838eae539ad7c547e10688690302d60d14fcb7d1812f1d1cdb748301a	21327
2106	a658a08bb90be94bc94f167848bb23247935442a220c0b9024bc886a1d551559	21345
2107	b7d7855ae14279716504a16586a7fb9806a68bb035314f6692e61fc7c8741700	21360
2108	4b8593d224827667ae99f70177a023d3e3214a59314b2eb5da6d431b9d291693	21366
2109	f4c65653f0c7e55e55d49608505b3536b4a1f3872477c4cd741555eef73d2983	21375
2110	e069664ab71999689c77dba6ef07f5c7306e2e9ab70abaa6c317c97f377a4339	21380
2111	e30fdfcd61658b80de8cbb26053d94b910afd1614bfca439d5a4f2ae7cb00f93	21390
2112	be950977998edde4237a16fde7d83eb51eaefe9541a66e312467937cd8335632	21395
2113	b36c967fab2193e3eeb0f52cbb173cd543567b15d190bf190523e2c37c72a324	21406
2114	d10f3735193b0be21ba1dc03c7a9ba9fd4b9be8f86788a48a8a80879cfbcfbeb	21407
2115	1a12f1f65eb2a2234ac45fc385b6ae09a4fefaeb1cf0b8062bc50079fdeb030d	21409
2116	e266c2fe179f28c2f8ad5502fa51377a869f21fa0035fe97e373ad236b0089e5	21422
2117	0cac020506f4f12755fc08798525e63e5bb289c012de27fe77d59b71fb8bed18	21423
2118	3361d40b0e204766a946047ce4ed581f93a6c9519f701690e7741543feacd5e8	21432
2119	a0726715697e76fa5e6318d6ea5e06427f8b8010b448ed07b4b91ef4d08c9002	21439
2120	5f3595adf62a8c60b5eced9e72334530742e0242de4c034f03d8fdccba1dd519	21460
2121	f95fe3e0cb6b220dca6c1cbe0111495fba821e3d918b5a8d0868eeb7c09f58ee	21463
2122	d8a354521ab8b7c6925bfb98deb1d092b694dfceb6d07dcd52b7ea834e2525cd	21478
2123	15c8debe607380d18905ad70582d76598b82def87d766862af8b3c794341be5c	21491
2124	7e6985f2f3fa4d4ae12f4c47a424ff3c8b1c27e4fe2df36c0e5950bb7e910b0b	21522
2125	722d231cec51af84e5adeb7b5fce57fb1e1f37fe0cf865e09677c58014785fe0	21527
2126	b4353603b232628c963b217743af7b6429a148fce5dfa4412e8582fa7a13f01b	21531
2127	73b0d8172caca420262dba9bd641bd9b6cae0c615fa733c86b65cad47a57400b	21540
2128	83e789e81690a914fd0ce13171eec4afb8435032dedc379eaa83e56de51198f0	21543
2129	f3c4bc3d9b7fe5725629db7b68d50ccf2dd8dbd470b765de4234865c031b1a69	21569
2130	36659b6968a6715ef27e9dea8e3cce709aa90bb5fde25d409d752f9e32bd5410	21572
2131	50f8161fa9728b43654813b6f446c6ee798e26f35fed81df2593e10ef216a424	21583
2132	79f2efa11769f0370eb0b6d9651f1308d0f22bba75873e527fa38ea11e645132	21585
2133	43b38ae2f9bf497ed61592515fec714e156ee8d89fd09d9dd176d73be6ea3215	21608
2134	69258d1d36ad2913c1c001ad607fcacf02546600d14d8d554d7b17ddc750df99	21628
2135	1f5b0cc138fdf1767b1307bb326968af65cff0d2fd1e734dff53a1ac21db2227	21635
2136	035a7eb75a4bbf44d8bbd35ca8e9b00ded0268a272d1ec1d0edf42f849210366	21644
2137	1747eaf2c7dc992b6d4e12861014561452ebdd6902d7b6c184e5b129a47833b6	21654
2138	c5c9211067f10ff9072a7806482fde0580bb9c553b32eb949c7a648dafac8054	21670
2139	797d99eb3103f06f9e40fd3556dd30bdeeea9da3a4317fd8dd4da3f14d94bf3e	21691
2140	77aa4e74928de6d9133f7ae65c36c2c41c7efe5594a5289237e9ed900a67fb9c	21705
2141	d1e9fd57852518172bea856ef37b03f258ce7fe86526ef454dbc5e39bd3b6fe9	21716
2142	56274ebdf7e1b0040fa9fc6bb4b5bf5efe32749e09510daf54b2c6c155600ca8	21725
2143	0988fb48e53575b4417a1dd1cffba1b0ba9a38815323a22e81e90ec9aa6cb58e	21744
2144	0a5a6508d36ab8a42169a8888066ddbad7daf681f95e7e1b9c90be1742fdd134	21750
2145	505ac157f78f73ca3108ecad01c5ef24836d0e731c72b68e1807771b8cdbf710	21764
2146	83db5a6a00b0878bbd86353794834ddfc4aee88e8a70a3402fbf9e731c4729c4	21770
2147	50e1aaec6f1d537388e9e74dac0bddddac44e4ca631241b36c594f1f98d3543d	21771
2148	f200223f6ffe6e767275f640fcced4a371835985731a614d62df400cff24ed4d	21775
2149	1de26be91c8f82fcaa5838ce66c24d2fca69b9a2d4efc3e84251fa9b584f0f13	21777
2150	e0031d2e01cbe7e2b19958e40bc822e383a81c1fd30861c2ca4ba5b175429616	21780
2151	3519f024836bdd1f3aa8e58db60127cc5cd196cd5fadfd0685102b0a65859473	21791
2152	1062203ffe70161d4a59aae6b3104e2499597b3ce742e7f81498ef76af1bd48c	21798
2153	283eb1662eca382f0920de5c9dc2c6499769e69f3cb21918b96a9a53fd21479c	21808
2154	d6de778ee05af463a7c8d8b9595d463e9eb69f4b4220df9a34c02af5c5915f98	21817
2155	3ba1b8686e271f9b014a8e1012b8c05ea63c72a9d837a8c66046ae388aab1e5f	21819
2156	cd90cc56f4bc5dd50bac0f5a0931a4d30517149eae5ac42507d64e37c63c788c	21836
2157	b32246b0800afb3eab7cf584e617800f8fd9de9fe6423a9a22967a05b520f9af	21837
2158	4920a57a753e1a48ad3915d925b77e0392b61a95af3461e8018a9f4251d22e6c	21850
2159	1c45ea030164dc99ed9110235de1d7cd2f0f6cb31b6b72ff0f81d9d000296ebe	21852
2160	eed934e9cee785a285256cc1bdcbf223cf6edf7c77382df4ce41c572f4efcf76	21857
2161	fc4fb82d69ee556a24fc3c1b6b6f52a2d59f47685ce2192e293958a02232f237	21866
2162	d67c77e47c8925dfc209108f339852ef6d653dc7f9e909ed9a8be0ebad330e32	21872
2163	f147dbf3a7c03ac3012b06686be13fc83ff3bc32342aa3eb35c94385006fdf9a	21873
2164	e24d42d3ef9f636b830983e7459da3cf5f5591887d234c8c34a3f83528bb0a61	21878
2165	6fc17259aeb0dd73bdbc8aae26f9f4a159295922b7efdd02e16e8335c91e0c9d	21880
2166	e44c20b9de1abe82512a9d1e3facde430563d9b3a96f802cc6d2f1f46eb569d6	21893
2167	0aa02b5342fdf563923f7ca79ab0c8f6c70876a3a4199988eceee431e4a31d5e	21906
2168	8c4d0044ff73454ee77e41a26d0f595277ecc13aaf10833a1cbc6e9198ef765a	21926
2169	7f3684cf348276770570ccc14e7ec6d1ac96c4f9f96183ea5736c83b13e6c957	21927
2170	cff25bca6b9beba7d4c9a6afa9c081183a93e44e9ef69478bba81e874a891c65	21930
2171	2a16c066b57217cc8b2db0e6fdfa5d59078b1b44483c0b87c395236ad7075167	21939
2172	59377c45b3b5c44fb7f651c4bed7b01518fa66927d8e348e20cd2408669b6b8f	21947
2173	b443c5373422bbb47bd4c1d9ef63aca08da501a1ce76eb6776a708475299d0fd	21950
2174	4be7a6a5363e3846ebb4a6eab8140a7c3335c1f4b510bee78fada0ebd9aae1d7	21955
2175	262344f90efd0e199b21de6ac2738e2cd8e2fc44c0def61b03b8d5453a5e4b14	21963
2176	f6a14841d651c7029a6e47abf5a49f1ff1a2a0b4bf9df93f56b5cf507ea5bb09	21973
2177	0294e293a331a2be8bb867fff8879ba3db3bf2ae634dbcbf82a80dd6cd0d86cd	21994
2178	3d28355d56ab96909289c2421e9c780ac3c5f3dd48916af1eba578028678ea29	22007
2179	9ff1a33b0cb83aa9f7a2f1258af2007d1eefff62024dc956048f464fac95ebcc	22018
2180	cd20fb97ef159df884458adf9c71e628f61dc4df773bf2d59e04ee392fcceaf1	22036
2181	032d9c9e143846fb4309406681a143bb75ea96f5ec7bf67b304d8da8e5c9d141	22042
2182	e848db19fd001a05e791782bac9ce13c0e17169519b51b9c06ac49edc21d4268	22052
2183	6fba9d479da810a44cb85658d45c60791f0e8e31b63ac0e8f97e878d0f0ecac1	22073
2184	e5aeaa89e76539743accbdac9aeb07cbbae6e02e615888bea41746652409637e	22080
2185	91e898022d5b1fa3be408af5eba19db71cb6057ef47c12e33bdbf0fae3d7a89b	22087
2186	87b5154cdca9025bff1dff535d1ceee5bc069d483aceb693edb10bce0183bdd9	22102
2187	912faf7aaefa7cbd167eb76f7fdb01cfd0fe6e8d13f34cafe7405f4d999b12b0	22109
2188	354e9f5a53f5c6f63ced882e5c28da6e55664f894295b7237fd7bfcc9d0762c4	22112
2189	fd4267fff59e0374d3faf404213ca38b25f9bdf1cfbc55cf39c8329cca367a63	22114
2190	b4655720c98fb9e3d3975f08148cd96b4bd35ff181574820210ba6be1aa7cbc4	22115
2191	9db2f2c488f330fcffff64f4465d261cae8cf8f12a8e2d4fba6cb637be6c30f6	22124
2192	904022e29784a98bac7d552529e8246c187a1be79e2e21226255fbb819f0d106	22127
2193	bc72a463b82233549f7c72759830f1ed98eb45f8e7a62856a8f72a995e54c71a	22143
2194	eaba7ce0ba87565f715d8cde41963d1d1e4847d71e3cb5f95dfb0e008f749c7a	22155
2195	ffd72e43a65d090e41e9d0c533fd45954b75b522ef7ff082bd1d8a68c9e0cbd4	22174
2196	fb38289d48dab8f56035ddb9cda9762e839a2c1d3018462ad153503d64ba9454	22245
2197	e944d20af986a770e0b787972ec6de618cdefa0e96194ec3112799e2d8ddc3dc	22247
2198	f403b93819634f282db3d5f16a80da0420657d4fc259f34df7efb2569a5fa90a	22250
2199	d94a3f9e71f5862b2ae915b3507d89e4ad67131e51cad1991e0d425db1bdbc70	22251
2200	e7a1adc878a0445bc469f9e41bb69ff7bcaafea6a0ea8c7a8e8260c652ccf91d	22254
2201	5cdf1d893ab86902785b44761021e5d3d9ea9f5517a4fd19f4b962c791b1ee09	22278
2202	07cadeed53264a680abd1aff5b6bbbe8d0861f8752e1c5a80ef5db4a50c009b0	22283
2203	78772fe21f99a72a95e33c4c0bff44dbcfdb5dafb870199ddd4262d560eb84d1	22286
2204	0aceeb90a21093a41a905169ad774e82e81d9e39d1ce349fca024e0ad8fece6a	22296
2205	757168a9d8f4e8d2d78ced069875e0c7e1b7327cb7360b89cdcd68f414a1095c	22302
2206	d74008db1825c8adfa78beff5934a26ca7afa220ef20cd3a6ace10cc8af4901e	22308
2207	950cca09656b186091d39dc16dad141c21b2b3fb5db62a0c9a05a42e8fef4e4d	22329
2208	8452e8d9918bc130256cef1ff752181b3f53fd74f70a6ae5edbd3c7ca9ca8ba6	22334
2209	4bf71826edfea480184623c53188fb28144d5a15114f930dec17e18f45ec6bd7	22335
2210	7e2e7d1e40a378223950abc11032568a7d7cd72f5c5e15e746544331a47ffbae	22367
2211	e77abf89e68ebaaf7f29dd818d268d6d879fbc661dfffb5e3922f030958452f9	22369
2212	ddf7dfbc94dcc708567069aec26a31a069e488ee0e6b87138a9185bee7341f22	22370
2213	595b2514ed3d94224e161458c2e73f917a21a59a2e01d4bf71530e0c3dd4d7ee	22374
2214	42265e33e8bc1f8cd59f0880403dbfcae974b74ea8d6957c1e36488e3128afe8	22382
2215	6977b8601eaa9c5f1c091cfef6d4d644297d9941fe990133905f359a0d320e46	22384
2216	70ddf4628f37714c2b5af3a29e7ea4deabf0d0ee24c73cf0da4b319ac1813d69	22395
2217	ca9ffe0d8f0b272b7d86881fd7748019738794d1fe5f771442265e9fc7cb4310	22397
2218	e3029b49d668e0e2335f9db2201ba77ea4b542e8e2608136e1f224b201a0d162	22400
2219	66d63ddb30613a8e3e94c28bc1df4be772669d04ec7bb02596c42f7ae20f0b43	22452
2220	26d49d801dcfc61eb76c609ade393bad79baa415f86f199098ed45adcb32f29b	22459
2221	568f1f6f1d041676e683c1e2e2b3a0161c921a4e4b1250ef467262be348ae2c5	22488
2222	d649dbda2d8498757dfc98d8f7412c3ba19d4307446571cbc37f3abcaed6705c	22501
2223	24380337ab2235c22172e502d4ce7feb648c8ff53a32aa44659816948b80c106	22505
2224	f96e331e1a5ae6a85b0632b5cfb7aa03c43ae0855994a120a8d06c0d27ab2817	22516
2225	5a524d88064fd8d051db0fb7cae3c18695a09f6a3604c41bc8af10dc1c802ce5	22517
2226	ff2130aaa817ba7ccae4c7671777be2433c5a6c629c92eb6c31d85a795213660	22519
2227	eb51f19d43a2a80ce383ea363e30deb7bab2842d5e51005bca956c57b2ecbed5	22529
2228	55af0c67d7bb977d9d1404f4ee995adba70ccf618db0a7bc8047c29784941d0e	22547
2229	520a21c7798c68b8863943ab477e660a85e2527a6226790072f3c5f766dcf713	22561
2230	c2040f1e4fe1454ad46b56c6e48ab05f4267db9f862a3d1f58dabfd64cd07186	22568
2231	c1fb5b6765cc87f154337715c96ced23213d85150823446abd74ccd8b966d402	22574
2232	80833400fc44abf813676c4da5cf59feb2e288611c0f13aea94b001fff8451b5	22578
2233	1a7c6342852ddf3269d7c7c83026e8c40a4a7003b159aacb68d805b6bfc83f15	22583
2234	e136f720036d8d85e4dc00b116cf651c91c49ac0cdfdb836d9e65ddf152f777c	22586
2235	a05936af8ac754464f83e68476b1fcb131e720efe120e03d2eefe5ca13402fc0	22600
2236	e831944bc848aee0bca737f6f66070efb32c483fe6ce973934dd78e6f196d356	22601
2237	7980ac713ef2018806a23187f2d956b9c830f83d5f6c6ba44c4c36f94382e40d	22605
2238	4078a3d9bd9fe434b40397c64f802c70cf3802520717e0788798f88abc80b44a	22617
2239	63d42a62112d2d323121a1912647f621d7160d13435672481c4f29c9bb5d4907	22625
2240	18035c7545edfbc5d97fa2beb7d3ba2841ff9bece26071c5d24a40e841a16da2	22649
2241	7d2a9ee4004bd80c18a4f260f174e205a0b5b0650a671d1110c7c43068740b19	22660
2242	dc03ef5035b63b7f47bb3da82cfa18b7fb56c3d763c55bd49826d66d199bd37c	22666
2243	f3677d99cce9a0627f821c73c8d14f4decc3616775abf873b0157715355d8f7f	22668
2244	25926daf272c243ee7c7d93acf21e93465b8a9e0dd06bd5304bd4e55c7238df9	22686
2245	b59c5831e4424c7cee1cdf91f5bb4f9fa5e08d0d74514d1d155c5e43b45904d1	22694
2246	1404f1e93b5e68c6ed6bd99bac041ff050c79bd083442dd4872d899576ae78c7	22704
2247	18b686dbd4bc2abf6c4f1ed1b88b4903adef7e118b592dcc9f08e8a53c028f92	22709
2248	9aa492c31bbae38d070c245bac634545b6228b7a084201ca3b3f7ad15161ce67	22710
2249	acfd6706d525f709f416b9f539b9f13b266f82adc5609c341936fad3478ecbfc	22714
2250	fab306f2784643dcb2cfbd8fdc4ff2b0ffea735a0380558159051d6aa7b4142c	22716
2251	94aecf711fbb932dd3696fc8c778548b093bebbbbb2c67dd31571f22a9b55f63	22739
2252	b0d9ef26cc21a5b21193e941ceccc8b179f60e5c37d18dc0f4684adb0f8ca3ce	22752
2253	dffcfdad20a55b408d30fac2e2075aae0625f9f701643c87211ebd782deec2f4	22754
2254	97662a11ffb043b660e5a3b9a87910ec1a6523824f7fd566997fb7d544163019	22757
2255	b4073fe985ddab442e5bf234fcdd1d425c265b5fbe481450a2c0a56f22549280	22768
2256	0d15c769fa3238eabf41cb5cd97eb95f26b980c6d4358a8ce599dd15f069d9ae	22769
2257	4eacbf3c6a08a6648ab4bd7e7e77866cb2ceb88f00b132fefe762a8c0295aeb7	22783
2258	620b956319852d136c0a79c8c4d347050c3ae2217db2c49f604357da76856894	22814
2259	d9b4aea1d76aef0287dc7ecbb4ce36265ec2a661c57716c1b252adee845da65f	22816
2260	d9bdd47d9c24777fc367f9f49e2b476a18d5b7c486ee349ff60d1c39fcb12585	22844
2261	a50dc25ce9752388abe2272c779a65dc5713f039786537c20fb3bb14782ec820	22846
2262	eca36caba09be4c98a0b71d3eeee15214b089a474de22b0ea075dffcd6ebf7c1	22850
2263	e7797d03ebc2ae954a9b41461ccd7cc5c964a1070d7644d126d7756631a1dd1a	22856
2264	526882dbee62a332ec824bdcccbcb2a5eece30b3f01066c72683ab1ded983576	22880
2265	bb3e63ce14636bd0392d4daff5c09b9e3b4641ad3274b2bfd51f904778e9c03a	22884
2266	1225662fb05928ac740268795c7f66c4b5c1708ec9a362176c1f9dade51a0fc4	22898
2267	965878338a5e6f9f37f9c5cfd5887d0caefc967a96d4a5760a50019423150075	22910
2268	d6075c460b1ca50b2be8ffdd525054eb1e909edd3bbf5f4698e516ebf268539e	22942
2269	e14ad7c44f9353a397f237c7656e58e9f7563215fc4bf99c0b54baeb7a6ca4d3	22960
2270	5aabef13d0f8647cb1fe35212615ce23c12d23aa7e3ada9799507941d296c232	22981
2271	5435057c6b0fc84e033a13ec827c401e984a5a7648338d1901cef7d911a89c1e	22988
2272	b437ed544938e914a91b2cf7b9adfefb10bdabd8c1d1b34f69563eb8a6e8ab32	22991
2273	42d375f4a1067cd2ef92b274b4df4190cf22585681b6ccb8f3251bfd3ca3d14d	22997
2274	cffc55ac6847f4473578b6081dd93dc3823af315b54da3ee0882cc1451e71c0b	22998
2275	d8c21c761a9d4942a4157e0bf7b059ada1ec914d27973303ef211dfd4f5fd1f2	22999
2276	cc5444f600bd8f2f6c7266411506450918dc344194331cb392b83be705074826	23002
2277	b44a03a3aaf4d758efae34ac00a1c4175fec2a8c65f61e73824f9c7f405be6a8	23006
2278	c35f0a463e84884469b5dbe9f3977ea7d91e37c8e909cde066a433391a184f65	23007
2279	c93c36a7682400ba959fc898e41e74f774a4c87b2fbfa856a249d662b7e28b6a	23014
2280	405768a75f025deca081f6554748e7adaff07a53e27662e6e2cd8ae62428717e	23027
2281	eea03406054c53b3247ecb7180f9a2862afc66ca0be192b8b60ea8d7896e2166	23036
2282	39170322ff9f2b710a9ee6588e14e7fabf3a374c022b95f3d5b3a9cce45e07c1	23038
2283	7b22e78e40b38fa7298672ab1d515fa323b3607e7ccee3b4021fcf4ad93ce700	23039
2284	396a660b75275fa3429be6e3b6896a6eb0fa6ca5e974555e07f7474f1e814506	23050
2285	d3f7e25d43d9a5756a73f98a462d92b403a9c59a8addb5151d2ecca28bd7b9b0	23059
2286	aef4d3ad671ba4a1ffadc4cb24b1c69672c0b5ccd8a15e1729bbc2a9dc9d5517	23069
2287	c1cbd08c5e98b71c83745e2e9fb3511bec0c063ce8de449a2b0504b26f7e5567	23081
2288	48aa1c9e25b53a6cf56dedfbb436992391c49e95c7593143cf8334171e00e2ec	23084
2289	ff7f7330d09c53a9f4fbc53d338d1d5bc2f225ea3d4d102b78b5478ee494cb10	23100
2290	70434d4ba0278c05b8c86cc214a1ff1d47b184a62cac8b37a7a794216af38fba	23123
2291	d09072df39740855af3d9211f5e02d3fafc449f0c104b0058efbcaa4f649ef6a	23153
2292	3329a4fc9a6e874bff96b72b5967f840c26bb022e6c2c498cc550c75d1b41a92	23181
2293	5f025740824f5f6143c77ad69a5860a83ba3cbc1fc19cb6f50ed91055a71d64f	23184
2294	3747f4505c2d4855ab4b09c6e1ad7a3c26e7d792e1ca2eba0010473820c469b3	23186
2295	1ed9f79de9bc24685ff4b245eceb1d74ac35ad212fad35bed26d868e1782be8a	23191
2296	d038aace56593c2eb6779cef57b193c4b820568ea04425eca8e829c29c06d2bf	23193
2297	4a7751460c76c106e5a22936a45d6e927ff4b7e0eaae93d6eb703c39d0bbf444	23197
2298	60ed0ed750443526ee61c10a25ddcf0c4dca153e97e7ca5f7ed2790ee25d5d97	23200
2299	6366eaec1cf758cea38b87405c966a4f9d724bbc6805b59e8a4979d66a281775	23202
2300	d25154f4f49ac1a38a41d031a811c5319ec6ef2f57b98bbc9b5ebb23db8064cf	23205
2301	1109b627f443a12fdda8efb95de9a2d51e284bc04c3f0feb125825285f1d6d50	23216
2302	3f05e2f2eaf30a84f962c73a66cd0b95c056b78a111dc9bf184f7affc38b7af6	23235
2303	37eea8a4b6c250b6d4b29c1324e77f8efadd1e4193cb00d9569b6cea7eacee80	23253
2304	7bc420b2b35c8de86f34b9ead8865d085aab740ebb033bc0352823f4a3d65f03	23306
2305	367d80871ac38de31ea72013c04d781ad3536b7794ddca61e3a7b0f22cdb9de8	23313
2306	8b060aca6f151991b202d07417005dccd6b2e89f8c07c7622a08622c6410e454	23319
2307	85735999345f72868f566529c778aa73c3b8b8d40279e9c0e326322b5e520877	23338
2308	c21f40971a03731f380a41a1d4efb70e0cc8c598a4d7d18d1257d420fd29ffdf	23343
2309	9ae258243074e0190a02032403ffbebdb1d26640379b0e6121f51e9af245ae2d	23354
2310	acf4210596c6a494fe011b74b086a6d2801097547069f38a52506259a1b67661	23356
2311	9b0dab16202417fbe7f36fb44363941347bfb43d35a6ec541184207a2b679c61	23363
2312	3ea7f6836e05c383becfd1494d3859664273c9546d2da1bb6aa35bac88f4e643	23370
2313	1b626e72880d0efb57ef9300f62ed0355c4a68d60cee2bd57546ab69a2bb3ee6	23379
2314	6b2735c3f9da879396ae469940ce1b2c95df9d2d2b011849cc408be6a2a29eaf	23383
2315	57d62e901bd17d8c2928d7f8952949d7cfb36ec1e57c39cb65e46bc3cb6cc2de	23392
2316	0a9f0652457e3073a03cb8a3fb6132e265dab29a7f28e70764f82963730af09a	23423
2317	22824266c7119159c90ef89282e117095fb0067ee0190a40a54610d8d01b4812	23430
2318	0ca550ac170815d72ba20ac02a6280b07e6ba612ef250fd6bacaa5b7a345dde1	23435
2319	853d562686552160d77cfd411425e02d09d4ab8cfb304f86256eebe9a2ab39fb	23437
2320	b744b371a0f21c239de39f6f323cf2631334ad23b438b0659838eb394dbb8f6f	23457
2321	d089a1905035ae43d05ce09e9f5bd0b2d0a7ed8c8a6b2ecb4d36fff42e69f224	23466
2322	d68ffc6a549859bee35e6fd14bcd132eabd9bf0e43cfc98b9dea2524b0f6ded6	23480
2323	9619e943bd08578a0708b6b1eebc5bc33b80a1189e5dc55f88efe8d42f453613	23483
2324	f6dd140bfdf4f34d849a8c157798ccb32bce8dee0d20f79ca041304603739a5b	23492
2325	92c07a04eda0e5f0e488b14c46374bcdb63a2770e0ad2305a0b816eea2d9d2df	23508
2326	0cfdc8b75b8bcd670b82e93edd05059f8d43a3282447a846af8d7cce3e0b13ec	23512
2327	0e2048e61bcf889717653f99716d6c7ae0a84575ccd5431383bfffbe9724c56d	23513
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
2304	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330342c2268617368223a2237626334323062326233356338646538366633346239656164383836356430383561616237343065626230333362633033353238323366346133643635663033222c22736c6f74223a32333330367d2c22697373756572566b223a2264363064343265343165366436386563636465363337383263326436633136656237303035626364373462336634343939393836623366663032613730356234222c2270726576696f7573426c6f636b223a2233376565613861346236633235306236643462323963313332346537376638656661646431653431393363623030643935363962366365613765616365653830222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178396d64703933636d6364636b6d38676a787a337a6677637a637263683261796d6366396c777739733964686d37643671646671637a6177797a227d
2305	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330352c2268617368223a2233363764383038373161633338646533316561373230313363303464373831616433353336623737393464646361363165336137623066323263646239646538222c22736c6f74223a32333331337d2c22697373756572566b223a2232303062323531616463326361616161303065303930333239363562386235626335316538313635366637346539656361323138383061653431396465303930222c2270726576696f7573426c6f636b223a2237626334323062326233356338646538366633346239656164383836356430383561616237343065626230333362633033353238323366346133643635663033222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173373361647a7275686b38636d7166726e33636b64736a6b6c7073343479777979633372656b376135776b6333373470653932716537327a3938227d
2306	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2261663838363333363139386164306161646138333238393963363932616661313631323861313035633935653362386133323635613737613837663739643438227d2c7b22696e646578223a312c2274784964223a2261663838363333363139386164306161646138333238393963363932616661313631323861313035633935653362386133323635613737613837663739643438227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363438353338227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32343735337d7d2c226964223a2239383437323066346363613364323437303733653236336534663761396530326661623364386263636565616135653561636162643838313736313961353663222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226162396532643035613536316661613530326437643766616666613563313430663064303234396263303565623538616461636632613466363331613866343664313937363463373466306665306136356535336164663738653766353234313639653965656230373933316164396437666366643563643766613036323037225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22686561646572223a7b22626c6f636b4e6f223a323330362c2268617368223a2238623036306163613666313531393931623230326430373431373030356463636436623265383966386330376337363232613038363232633634313065343534222c22736c6f74223a32333331397d2c22697373756572566b223a2236646166393262306331323231333365303338666532333033643762366263646462633631373362626633323434366536623630643631623330643834323262222c2270726576696f7573426c6f636b223a2233363764383038373161633338646533316561373230313363303464373831616433353336623737393464646361363165336137623066323263646239646538222c2273697a65223a3336352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363438353338227d2c227478436f756e74223a312c22767266223a227672665f766b3161687275356d73336e3770663935306e6c6e37683075786d7139673874306564797737736d7365377a6867377376776d306b3771326366663573227d
2307	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330372c2268617368223a2238353733353939393334356637323836386635363635323963373738616137336333623862386434303237396539633065333236333232623565353230383737222c22736c6f74223a32333333387d2c22697373756572566b223a2266363466616363343935333635333636663935616539313439623635393931633734623137313435633761633964396133343737336231373035306432626234222c2270726576696f7573426c6f636b223a2238623036306163613666313531393931623230326430373431373030356463636436623265383966386330376337363232613038363232633634313065343534222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756135733868746c3365336e786c666478756d6e786b686e6c6a65357961306d6c676e6b61717773793778616e6a766a346a71767774783970227d
2308	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330382c2268617368223a2263323166343039373161303337333166333830613431613164346566623730653063633863353938613464376431386431323537643432306664323966666466222c22736c6f74223a32333334337d2c22697373756572566b223a2232316438323733306564383761663832383032376666353965333165626434376663623930623163353561336631346466646563346334353736326133333661222c2270726576696f7573426c6f636b223a2238353733353939393334356637323836386635363635323963373738616137336333623862386434303237396539633065333236333232623565353230383737222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356439706a64617966716c6a327271716a6d736e36383637726e70306c6a706c777339336b30366661716132766c36686c686d7334787a773839227d
2309	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330392c2268617368223a2239616532353832343330373465303139306130323033323430336666626562646231643236363430333739623065363132316635316539616632343561653264222c22736c6f74223a32333335347d2c22697373756572566b223a2266363466616363343935333635333636663935616539313439623635393931633734623137313435633761633964396133343737336231373035306432626234222c2270726576696f7573426c6f636b223a2263323166343039373161303337333166333830613431613164346566623730653063633863353938613464376431386431323537643432306664323966666466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756135733868746c3365336e786c666478756d6e786b686e6c6a65357961306d6c676e6b61717773793778616e6a766a346a71767774783970227d
2310	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331302c2268617368223a2261636634323130353936633661343934666530313162373462303836613664323830313039373534373036396633386135323530363235396131623637363631222c22736c6f74223a32333335367d2c22697373756572566b223a2239643536613365303939646538306162376663653764376137383937373830346331336638386132343833623162343461633061343331613765646534313334222c2270726576696f7573426c6f636b223a2239616532353832343330373465303139306130323033323430336666626562646231643236363430333739623065363132316635316539616632343561653264222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356c79723439687274753470767667676664366572386633333772663371356172383636376d746365786d6767337a33723574736b6768347873227d
2311	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2239383437323066346363613364323437303733653236336534663761396530326661623364386263636565616135653561636162643838313736313961353663227d2c7b22696e646578223a312c2274784964223a2239383437323066346363613364323437303733653236336534663761396530326661623364386263636565616135653561636162643838313736313961353663227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936343731323031227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32343739367d7d2c226964223a2235336561323363376637396430636139353466633533656437653061343534343463616239656663646465626561326136336136356161393863613834653261222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226461663366323366636565343465393639326262316264633235366232616331623238303162323564306532306330366638383362353362343065336639393265376635616637353565326338316364396361336664326536346233333363383037663236316531336132653566643933353931643865366439383265663065225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226334656162333930393438643133396630666265356636616435643937343935346534366233373035653935303839346631353166363265643833373361323165333939643834346233396461353831623136656638643932346537346361383239333032346662356331393066663162336436323237623734356533633063225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22686561646572223a7b22626c6f636b4e6f223a323331312c2268617368223a2239623064616231363230323431376662653766333666623434333633393431333437626662343364333561366563353431313834323037613262363739633631222c22736c6f74223a32333336337d2c22697373756572566b223a2264363064343265343165366436386563636465363337383263326436633136656237303035626364373462336634343939393836623366663032613730356234222c2270726576696f7573426c6f636b223a2261636634323130353936633661343934666530313162373462303836613664323830313039373534373036396633386135323530363235396131623637363631222c2273697a65223a3439362c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939343731323031227d2c227478436f756e74223a312c22767266223a227672665f766b3178396d64703933636d6364636b6d38676a787a337a6677637a637263683261796d6366396c777739733964686d37643671646671637a6177797a227d
2312	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331322c2268617368223a2233656137663638333665303563333833626563666431343934643338353936363432373363393534366432646131626236616133356261633838663465363433222c22736c6f74223a32333337307d2c22697373756572566b223a2232316438323733306564383761663832383032376666353965333165626434376663623930623163353561336631346466646563346334353736326133333661222c2270726576696f7573426c6f636b223a2239623064616231363230323431376662653766333666623434333633393431333437626662343364333561366563353431313834323037613262363739633631222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356439706a64617966716c6a327271716a6d736e36383637726e70306c6a706c777339336b30366661716132766c36686c686d7334787a773839227d
2313	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331332c2268617368223a2231623632366537323838306430656662353765663933303066363265643033353563346136386436306365653262643537353436616236396132626233656536222c22736c6f74223a32333337397d2c22697373756572566b223a2236646166393262306331323231333365303338666532333033643762366263646462633631373362626633323434366536623630643631623330643834323262222c2270726576696f7573426c6f636b223a2233656137663638333665303563333833626563666431343934643338353936363432373363393534366432646131626236616133356261633838663465363433222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3161687275356d73336e3770663935306e6c6e37683075786d7139673874306564797737736d7365377a6867377376776d306b3771326366663573227d
2314	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331342c2268617368223a2236623237333563336639646138373933393661653436393934306365316232633935646639643264326230313138343963633430386265366132613239656166222c22736c6f74223a32333338337d2c22697373756572566b223a2264363064343265343165366436386563636465363337383263326436633136656237303035626364373462336634343939393836623366663032613730356234222c2270726576696f7573426c6f636b223a2231623632366537323838306430656662353765663933303066363265643033353563346136386436306365653262643537353436616236396132626233656536222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178396d64703933636d6364636b6d38676a787a337a6677637a637263683261796d6366396c777739733964686d37643671646671637a6177797a227d
2315	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739373133227d2c22696e70757473223a5b7b22696e646578223a342c2274784964223a2239353232363637303264306637303635343431623234393239626165336536623133353830643833323463353230633535366230616465373931316234316538227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230323837227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32343831397d7d2c226964223a2266336430336331656463353965313035373131326465366339316237633938336337306233623535393630316161303830663465316132333166383935326239222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223330666233343930376335356538656663316237383830313832663534343439623965326239343635343230323564396631393261346662623333333364633936396166393232326537646133333539613566306531663163313633636134393035656533653330633261316635306134366265626565613861646430663033225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226233353063393861323737383237303235363139316365663362613362363534363764333038613364333362343937356133663665626664346536346439643766303164333736363863326537653135346637383030376438643638363830646630363265333839323736393964363535343532386136636333316337353066225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739373133227d2c22686561646572223a7b22626c6f636b4e6f223a323331352c2268617368223a2235376436326539303162643137643863323932386437663839353239343964376366623336656331653537633339636236356534366263336362366363326465222c22736c6f74223a32333339327d2c22697373756572566b223a2266363466616363343935333635333636663935616539313439623635393931633734623137313435633761633964396133343737336231373035306432626234222c2270726576696f7573426c6f636b223a2236623237333563336639646138373933393661653436393934306365316232633935646639643264326230313138343963633430386265366132613239656166222c2273697a65223a3535302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230323837227d2c227478436f756e74223a312c22767266223a227672665f766b3137756135733868746c3365336e786c666478756d6e786b686e6c6a65357961306d6c676e6b61717773793778616e6a766a346a71767774783970227d
2316	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331362c2268617368223a2230613966303635323435376533303733613033636238613366623631333265323635646162323961376632386537303736346638323936333733306166303961222c22736c6f74223a32333432337d2c22697373756572566b223a2233633330383336353238363263383333323663336661356664313139366234633734353632346534623932613033376531353266343562656337393530656335222c2270726576696f7573426c6f636b223a2235376436326539303162643137643863323932386437663839353239343964376366623336656331653537633339636236356534366263336362366363326465222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317573716b716d34756a793568787279656d6b7064666d6779643636363871307a3764326e38706e34706b3739387368706d307973776a74337a71227d
2317	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331372c2268617368223a2232323832343236366337313139313539633930656638393238326531313730393566623030363765653031393061343061353436313064386430316234383132222c22736c6f74223a32333433307d2c22697373756572566b223a2264363064343265343165366436386563636465363337383263326436633136656237303035626364373462336634343939393836623366663032613730356234222c2270726576696f7573426c6f636b223a2230613966303635323435376533303733613033636238613366623631333265323635646162323961376632386537303736346638323936333733306166303961222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178396d64703933636d6364636b6d38676a787a337a6677637a637263683261796d6366396c777739733964686d37643671646671637a6177797a227d
2318	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331382c2268617368223a2230636135353061633137303831356437326261323061633032613632383062303765366261363132656632353066643662616361613562376133343564646531222c22736c6f74223a32333433357d2c22697373756572566b223a2266363466616363343935333635333636663935616539313439623635393931633734623137313435633761633964396133343737336231373035306432626234222c2270726576696f7573426c6f636b223a2232323832343236366337313139313539633930656638393238326531313730393566623030363765653031393061343061353436313064386430316234383132222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756135733868746c3365336e786c666478756d6e786b686e6c6a65357961306d6c676e6b61717773793778616e6a766a346a71767774783970227d
2319	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323331392c2268617368223a2238353364353632363836353532313630643737636664343131343235653032643039643461623863666233303466383632353665656265396132616233396662222c22736c6f74223a32333433377d2c22697373756572566b223a2236646166393262306331323231333365303338666532333033643762366263646462633631373362626633323434366536623630643631623330643834323262222c2270726576696f7573426c6f636b223a2230636135353061633137303831356437326261323061633032613632383062303765366261363132656632353066643662616361613562376133343564646531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3161687275356d73336e3770663935306e6c6e37683075786d7139673874306564797737736d7365377a6867377376776d306b3771326366663573227d
2320	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731393235227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2233346265303631366532333037646562663337666335356631623763333864626538343433666637356537323636333862643130303539306232383162353063227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613238333233323332323936383631366536343663363533363338222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383238303735227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32343837357d7d2c226964223a2236616561643930636235396535366230363133343161363433656463383336613135613833356630383462363562646366353632383138636161613962353161222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223733613931396434653235616461303564383061393063303631636330313265303332656335383830653963616264613734346336313864343831386635623763666232626330383431343762333038343534356562353161653666633461363763623738643437636266383763343862633630626435316531653036643036225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731393235227d2c22686561646572223a7b22626c6f636b4e6f223a323332302c2268617368223a2262373434623337316130663231633233396465333966366633323363663236333133333461643233623433386230363539383338656233393464626238663666222c22736c6f74223a32333435377d2c22697373756572566b223a2264363064343265343165366436386563636465363337383263326436633136656237303035626364373462336634343939393836623366663032613730356234222c2270726576696f7573426c6f636b223a2238353364353632363836353532313630643737636664343131343235653032643039643461623863666233303466383632353665656265396132616233396662222c2273697a65223a3337332c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383238303735227d2c227478436f756e74223a312c22767266223a227672665f766b3178396d64703933636d6364636b6d38676a787a337a6677637a637263683261796d6366396c777739733964686d37643671646671637a6177797a227d
2321	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323332312c2268617368223a2264303839613139303530333561653433643035636530396539663562643062326430613765643863386136623265636234643336666666343265363966323234222c22736c6f74223a32333436367d2c22697373756572566b223a2264363064343265343165366436386563636465363337383263326436633136656237303035626364373462336634343939393836623366663032613730356234222c2270726576696f7573426c6f636b223a2262373434623337316130663231633233396465333966366633323363663236333133333461643233623433386230363539383338656233393464626238663666222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178396d64703933636d6364636b6d38676a787a337a6677637a637263683261796d6366396c777739733964686d37643671646671637a6177797a227d
2322	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323332322c2268617368223a2264363866666336613534393835396265653335653666643134626364313332656162643962663065343363666339386239646561323532346230663664656436222c22736c6f74223a32333438307d2c22697373756572566b223a2232303062323531616463326361616161303065303930333239363562386235626335316538313635366637346539656361323138383061653431396465303930222c2270726576696f7573426c6f636b223a2264303839613139303530333561653433643035636530396539663562643062326430613765643863386136623265636234643336666666343265363966323234222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3173373361647a7275686b38636d7166726e33636b64736a6b6c7073343479777979633372656b376135776b6333373470653932716537327a3938227d
2323	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323332332c2268617368223a2239363139653934336264303835373861303730386236623165656263356263333362383061313138396535646335356638386566653864343266343533363133222c22736c6f74223a32333438337d2c22697373756572566b223a2232316438323733306564383761663832383032376666353965333165626434376663623930623163353561336631346466646563346334353736326133333661222c2270726576696f7573426c6f636b223a2264363866666336613534393835396265653335653666643134626364313332656162643962663065343363666339386239646561323532346230663664656436222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356439706a64617966716c6a327271716a6d736e36383637726e70306c6a706c777339336b30366661716132766c36686c686d7334787a773839227d
2324	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2236616561643930636235396535366230363133343161363433656463383336613135613833356630383462363562646366353632383138636161613962353161227d2c7b22696e646578223a312c2274784964223a2266336430336331656463353965313035373131326465366339316237633938336337306233623535393630316161303830663465316132333166383935326239227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363432393530227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32343932337d7d2c226964223a2238386136666338663662663934386664343631396161343935646565653665383666383739383637313636336431663562346162376563376131616462663231222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223339303839393262386439323939613838326662376537643938336339333736346239656436623735373362303038323163613638303339353935653630356435363637373039356235353731623237323764623061666336666534306330363862643234663139626333303964346361356165363730613834646632323066225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223236623735303863643136343131303363623337623138343730663939323661343435616636646131373763636436656431363266386636303236376661346566363331643934353539303032393833623436653663366164386164643539623739663764656264336133346438663638353962313861613261383837363064225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737333337227d2c22686561646572223a7b22626c6f636b4e6f223a323332342c2268617368223a2266366464313430626664663466333464383439613863313537373938636362333262636538646565306432306637396361303431333034363033373339613562222c22736c6f74223a32333439327d2c22697373756572566b223a2236646166393262306331323231333365303338666532333033643762366263646462633631373362626633323434366536623630643631623330643834323262222c2270726576696f7573426c6f636b223a2239363139653934336264303835373861303730386236623165656263356263333362383061313138396535646335356638386566653864343266343533363133222c2273697a65223a3439362c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363432393530227d2c227478436f756e74223a312c22767266223a227672665f766b3161687275356d73336e3770663935306e6c6e37683075786d7139673874306564797737736d7365377a6867377376776d306b3771326366663573227d
2325	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323332352c2268617368223a2239326330376130346564613065356630653438386231346334363337346263646236336132373730653061643233303561306238313665656132643964326466222c22736c6f74223a32333530387d2c22697373756572566b223a2233633330383336353238363263383333323663336661356664313139366234633734353632346534623932613033376531353266343562656337393530656335222c2270726576696f7573426c6f636b223a2266366464313430626664663466333464383439613863313537373938636362333262636538646565306432306637396361303431333034363033373339613562222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317573716b716d34756a793568787279656d6b7064666d6779643636363871307a3764326e38706e34706b3739387368706d307973776a74337a71227d
2326	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323332362c2268617368223a2230636664633862373562386263643637306238326539336564643035303539663864343361333238323434376138343661663864376363653365306231336563222c22736c6f74223a32333531327d2c22697373756572566b223a2239643536613365303939646538306162376663653764376137383937373830346331336638386132343833623162343461633061343331613765646534313334222c2270726576696f7573426c6f636b223a2239326330376130346564613065356630653438386231346334363337346263646236336132373730653061643233303561306238313665656132643964326466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356c79723439687274753470767667676664366572386633333772663371356172383636376d746365786d6767337a33723574736b6768347873227d
2327	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323332372c2268617368223a2230653230343865363162636638383937313736353366393937313664366337616530613834353735636364353433313338336266666662653937323463353664222c22736c6f74223a32333531337d2c22697373756572566b223a2266363466616363343935333635333636663935616539313439623635393931633734623137313435633761633964396133343737336231373035306432626234222c2270726576696f7573426c6f636b223a2230636664633862373562386263643637306238326539336564643035303539663864343361333238323434376138343661663864376363653365306231336563222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137756135733868746c3365336e786c666478756d6e786b686e6c6a65357961306d6c676e6b61717773793778616e6a766a346a71767774783970227d
2295	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239352c2268617368223a2231656439663739646539626332343638356666346232343565636562316437346163333561643231326661643335626564323664383638653137383262653861222c22736c6f74223a32333139317d2c22697373756572566b223a2232316438323733306564383761663832383032376666353965333165626434376663623930623163353561336631346466646563346334353736326133333661222c2270726576696f7573426c6f636b223a2233373437663435303563326434383535616234623039633665316164376133633236653764373932653163613265626130303130343733383230633436396233222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356439706a64617966716c6a327271716a6d736e36383637726e70306c6a706c777339336b30366661716132766c36686c686d7334787a773839227d
2296	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239362c2268617368223a2264303338616163653536353933633265623637373963656635376231393363346238323035363865613034343235656361386538323963323963303664326266222c22736c6f74223a32333139337d2c22697373756572566b223a2233633330383336353238363263383333323663336661356664313139366234633734353632346534623932613033376531353266343562656337393530656335222c2270726576696f7573426c6f636b223a2231656439663739646539626332343638356666346232343565636562316437346163333561643231326661643335626564323664383638653137383262653861222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317573716b716d34756a793568787279656d6b7064666d6779643636363871307a3764326e38706e34706b3739387368706d307973776a74337a71227d
2297	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239372c2268617368223a2234613737353134363063373663313036653561323239333661343564366539323766663462376530656161653933643665623730336333396430626266343434222c22736c6f74223a32333139377d2c22697373756572566b223a2232316438323733306564383761663832383032376666353965333165626434376663623930623163353561336631346466646563346334353736326133333661222c2270726576696f7573426c6f636b223a2264303338616163653536353933633265623637373963656635376231393363346238323035363865613034343235656361386538323963323963303664326266222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356439706a64617966716c6a327271716a6d736e36383637726e70306c6a706c777339336b30366661716132766c36686c686d7334787a773839227d
2298	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239382c2268617368223a2236306564306564373530343433353236656536316331306132356464636630633464636131353365393765376361356637656432373930656532356435643937222c22736c6f74223a32333230307d2c22697373756572566b223a2233633330383336353238363263383333323663336661356664313139366234633734353632346534623932613033376531353266343562656337393530656335222c2270726576696f7573426c6f636b223a2234613737353134363063373663313036653561323239333661343564366539323766663462376530656161653933643665623730336333396430626266343434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317573716b716d34756a793568787279656d6b7064666d6779643636363871307a3764326e38706e34706b3739387368706d307973776a74337a71227d
2299	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239392c2268617368223a2236333636656165633163663735386365613338623837343035633936366134663964373234626263363830356235396538613439373964363661323831373735222c22736c6f74223a32333230327d2c22697373756572566b223a2239643536613365303939646538306162376663653764376137383937373830346331336638386132343833623162343461633061343331613765646534313334222c2270726576696f7573426c6f636b223a2236306564306564373530343433353236656536316331306132356464636630633464636131353365393765376361356637656432373930656532356435643937222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356c79723439687274753470767667676664366572386633333772663371356172383636376d746365786d6767337a33723574736b6768347873227d
2300	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330302c2268617368223a2264323531353466346634396163316133386134316430333161383131633533313965633665663266353762393862626339623565626232336462383036346366222c22736c6f74223a32333230357d2c22697373756572566b223a2236646166393262306331323231333365303338666532333033643762366263646462633631373362626633323434366536623630643631623330643834323262222c2270726576696f7573426c6f636b223a2236333636656165633163663735386365613338623837343035633936366134663964373234626263363830356235396538613439373964363661323831373735222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3161687275356d73336e3770663935306e6c6e37683075786d7139673874306564797737736d7365377a6867377376776d306b3771326366663573227d
2290	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239302c2268617368223a2237303433346434626130323738633035623863383663633231346131666631643437623138346136326361633862333761376137393432313661663338666261222c22736c6f74223a32333132337d2c22697373756572566b223a2236646166393262306331323231333365303338666532333033643762366263646462633631373362626633323434366536623630643631623330643834323262222c2270726576696f7573426c6f636b223a2266663766373333306430396335336139663466626335336433333864316435626332663232356561336434643130326237386235343738656534393463623130222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3161687275356d73336e3770663935306e6c6e37683075786d7139673874306564797737736d7365377a6867377376776d306b3771326366663573227d
2291	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b22626c6f62223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b7b225f5f74797065223a22626967696e74222c2276616c7565223a22373231227d2c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b227669727475616c4068616e646c222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b226175676d656e746174696f6e73222c5b5d5d2c5b22636f7265222c7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2268616e646c65456e636f64696e67222c227574662d38225d2c5b226f67222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d2c5b22707265666978222c2224225d2c5b227465726d736f66757365222c2268747470733a2f2f63617264616e6f666f756e646174696f6e2e6f72672f656e2f7465726d732d616e642d636f6e646974696f6e732f225d2c5b2276657273696f6e222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d5d5d7d5d2c5b226465736372697074696f6e222c225468652048616e646c65205374616e64617264225d2c5b22696d616765222c22697066733a2f2f736f6d652d68617368225d2c5b226e616d65222c22247669727475616c4068616e646c225d2c5b2277656273697465222c2268747470733a2f2f63617264616e6f2e6f72672f225d5d7d5d5d7d5d5d7d5d5d7d7d2c22626f6479223a7b22617578696c696172794461746148617368223a2231323461306263656630393965636233363831303065336632326339383664363435313066623435373637376666313237396537336166626233663633353766222c22636572746966696361746573223a7b225f5f74797065223a22756e646566696e6564227d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313931333733227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2233333762306266653862663965643138333133373863326238623637633236383131646232363964623964653566396630333232363464346362356538393834227d5d2c226d696e74223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303030303030303736363937323734373536313663343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171707730646a676a307835396e67726a767174686e37656e68767275786e736176737735746836336c61336d6a656c7370396a6e32346e6366736172616863726734746b6e74396775703775663775616b3275397972326532346471717a70717764222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396130303030303030303736363937323734373536313663343036383631366536343663222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2232353130383737313236323532227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32343536337d7d2c226964223a2261393736646336346633383639653930656666626335353566643931633666633431353532346537373836353838363464313533353364656664616162373263222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2233363863663661313161633765323939313735363861333636616636326135393663623963646538313734626665376636653838333933656364623164636336222c226634633666326165656439386337313730623330363432346662626530623265633564393335363536333935653031626334643438643164376463643838393238366137626362353661313462316632356239343930623631616230313965333863656134333762313063366335643236616532396631623331613766343063225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313931333733227d2c22686561646572223a7b22626c6f636b4e6f223a323239312c2268617368223a2264303930373264663339373430383535616633643932313166356530326433666166633434396630633130346230303538656662636161346636343965663661222c22736c6f74223a32333135337d2c22697373756572566b223a2239643536613365303939646538306162376663653764376137383937373830346331336638386132343833623162343461633061343331613765646534313334222c2270726576696f7573426c6f636b223a2237303433346434626130323738633035623863383663633231346131666631643437623138346136326361633862333761376137393432313661663338666261222c2273697a65223a3731362c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2232353130383737313236323532227d2c227478436f756e74223a312c22767266223a227672665f766b31356c79723439687274753470767667676664366572386633333772663371356172383636376d746365786d6767337a33723574736b6768347873227d
2292	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239322c2268617368223a2233333239613466633961366538373462666639366237326235393637663834306332366262303232653663326334393863633535306337356431623431613932222c22736c6f74223a32333138317d2c22697373756572566b223a2239643536613365303939646538306162376663653764376137383937373830346331336638386132343833623162343461633061343331613765646534313334222c2270726576696f7573426c6f636b223a2264303930373264663339373430383535616633643932313166356530326433666166633434396630633130346230303538656662636161346636343965663661222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356c79723439687274753470767667676664366572386633333772663371356172383636376d746365786d6767337a33723574736b6768347873227d
2293	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239332c2268617368223a2235663032353734303832346635663631343363373761643639613538363061383362613363626331666331396362366635306564393130353561373164363466222c22736c6f74223a32333138347d2c22697373756572566b223a2233633330383336353238363263383333323663336661356664313139366234633734353632346534623932613033376531353266343562656337393530656335222c2270726576696f7573426c6f636b223a2233333239613466633961366538373462666639366237326235393637663834306332366262303232653663326334393863633535306337356431623431613932222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317573716b716d34756a793568787279656d6b7064666d6779643636363871307a3764326e38706e34706b3739387368706d307973776a74337a71227d
2294	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323239342c2268617368223a2233373437663435303563326434383535616234623039633665316164376133633236653764373932653163613265626130303130343733383230633436396233222c22736c6f74223a32333138367d2c22697373756572566b223a2239643536613365303939646538306162376663653764376137383937373830346331336638386132343833623162343461633061343331613765646534313334222c2270726576696f7573426c6f636b223a2235663032353734303832346635663631343363373761643639613538363061383362613363626331666331396362366635306564393130353561373164363466222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356c79723439687274753470767667676664366572386633333772663371356172383636376d746365786d6767337a33723574736b6768347873227d
2301	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330312c2268617368223a2231313039623632376634343361313266646461386566623935646539613264353165323834626330346333663066656231323538323532383566316436643530222c22736c6f74223a32333231367d2c22697373756572566b223a2232316438323733306564383761663832383032376666353965333165626434376663623930623163353561336631346466646563346334353736326133333661222c2270726576696f7573426c6f636b223a2264323531353466346634396163316133386134316430333161383131633533313965633665663266353762393862626339623565626232336462383036346366222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356439706a64617966716c6a327271716a6d736e36383637726e70306c6a706c777339336b30366661716132766c36686c686d7334787a773839227d
2302	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2239353232363637303264306637303635343431623234393239626165336536623133353830643833323463353230633535366230616465373931316234316538227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a32343635367d7d2c226964223a2261663838363333363139386164306161646138333238393963363932616661313631323861313035633935653362386133323635613737613837663739643438222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223538363431363433353235616130653137616434626135376461313535623532626331353232333333646261613535353734363730623137623936383866353832653530303439653566613539333965316638323564666237333764643336656236326435353864356538393165646336363664333434646635666163623032225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226466613035656366346261323935663965636334616430623264363836333934663763386433326333613837353362623831653832366265616466393865663731623566386562346133396639343737653234633163363365633833323432643161386361653961323532396631306631333362646332323435663565343065225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a323330322c2268617368223a2233663035653266326561663330613834663936326337336136366364306239356330353662373861313131646339626631383466376166666333386237616636222c22736c6f74223a32333233357d2c22697373756572566b223a2232303062323531616463326361616161303065303930333239363562386235626335316538313635366637346539656361323138383061653431396465303930222c2270726576696f7573426c6f636b223a2231313039623632376634343361313266646461386566623935646539613264353165323834626330346333663066656231323538323532383566316436643530222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b3173373361647a7275686b38636d7166726e33636b64736a6b6c7073343479777979633372656b376135776b6333373470653932716537327a3938227d
2303	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a323330332c2268617368223a2233376565613861346236633235306236643462323963313332346537376638656661646431653431393363623030643935363962366365613765616365653830222c22736c6f74223a32333235337d2c22697373756572566b223a2232316438323733306564383761663832383032376666353965333165626434376663623930623163353561336631346466646563346334353736326133333661222c2270726576696f7573426c6f636b223a2233663035653266326561663330613834663936326337336136366364306239356330353662373861313131646339626631383466376166666333386237616636222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31356439706a64617966716c6a327271716a6d736e36383637726e70306c6a706c777339336b30366661716132766c36686c686d7334787a773839227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	20085	203	3	7887054757451045	118942803601284	15472606841513	0.09264151011415175	66.30964227049634	-65.30964227049634	20.5235385427234	19.718269348926608
pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	20085	205	3	7882084826749572	118076597073241	15347359110236	0.09196684398556747	66.75399716897704	-65.75399716897704	19.182073607569592	20.218913302618592
pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	20085	187	5	7878788343049712	110682689634555	13593959288378	0.08620791843459166	71.18356419656398	-70.18356419656398	18.89501133793805	17.924677742750852
pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q	20085	60	3	0	14420523175783	300000000	0.011231776981808413	0	1	7.716238645887314	7.716238645887314
pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a	20085	61	3	0	43933477623839	500000000	0.03421866299101431	0	1	19.49776350972212	19.49776350972212
pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	20085	186	3	0	13608688871221	300000000	0.010599459988598714	0	1	0	1.3639815787559337
pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	20085	217	3	0	126974610370693	500000000	0.09889727915216259	0	1	23.950382170288204	23.143898257799204
pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	20085	238	3	7901998793112714	136438785795293	17993409394499	0.10626868353118904	57.916073842584176	-56.916073842584176	22.52319558373373	23.222160083109255
pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	20085	212	3	7891560193680068	124467471568107	16307767364150	0.09694453280934101	63.40259100838172	-62.40259100838172	18.920324147311227	20.032671448119327
pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	20085	199	3	7792475357671493	19748084944221	200200192	0.015381278696170132	394.5939760580102	-393.5939760580102	0	1.4348377831253627
pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	20085	233	4	7901893562211621	136325415585943	17699488093385	0.10618038237232827	57.96346578697988	-56.96346578697988	23.757553477385184	22.141993586889978
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
\.


--
-- Data for Name: pool_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_registration (id, reward_account, pledge, cost, margin, margin_percent, relays, owners, vrf, metadata_url, metadata_hash, block_slot, stake_pool_id) FROM stdin;
2110000000000	stake_test1ur3sq69eskuvsdsn4z3j00wmjggmpp6syy8v6pang2gxwrsazwpe0	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1ur3sq69eskuvsdsn4z3j00wmjggmpp6syy8v6pang2gxwrsazwpe0"]	bc8852ee9eb600e5d70826ad7a74229eee1ae4d8588d3f6df80351f96f354532	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	211	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k
3260000000000	stake_test1uz2kznllx3ya9gx4ewp09dzeu5lq3vthsj45kcmwfjwr34gqcvxxv	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1uz2kznllx3ya9gx4ewp09dzeu5lq3vthsj45kcmwfjwr34gqcvxxv"]	8750ed646358fd119842c945152be172129b158a1409e003856538e0f603c115	\N	\N	326	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm
4020000000000	stake_test1uzmypmmjg6jtuegr9qwvwgfgmeg22u3teq5407a0f8rlg4g05qvy0	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1uzmypmmjg6jtuegr9qwvwgfgmeg22u3teq5407a0f8rlg4g05qvy0"]	1a823986d72f302cd35220dbd4614b9078319f441a8f45fb011d684aac0fd24e	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	402	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse
4830000000000	stake_test1uru39jsxjdk04xwm85dtxhg2edv0q8ls9hc63vwng42nzucuve06d	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1uru39jsxjdk04xwm85dtxhg2edv0q8ls9hc63vwng42nzucuve06d"]	484a86f2224782ea5b35c5221d85bb4b3e34cd4ecd3d9f89997307936a2621c0	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	483	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww
5860000000000	stake_test1ursqd8zqktpt8486fey2f3xqu564jerz2a7s9ex2lv99uhswzap5y	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1ursqd8zqktpt8486fey2f3xqu564jerz2a7s9ex2lv99uhswzap5y"]	c0d68e8f003e642cf79a7d8b77c3faef693ff2d63d57c1c533b05c7f66eea298	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	586	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg
6970000000000	stake_test1upmp9432an8crdj44kqz2a9s47p4sxgu2eavj802av3zxjgnhhxdq	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1upmp9432an8crdj44kqz2a9s47p4sxgu2eavj802av3zxjgnhhxdq"]	a2d1bbb13f67b1c0ac5e90969d336bf14ebd9aab1c4a9d171e19ca5bc7a4344b	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	697	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk
7670000000000	stake_test1upjqy9dz4ft6n4mk7tfdp8dtyhte6vp5sps28wczj3m87xs55x2ja	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1upjqy9dz4ft6n4mk7tfdp8dtyhte6vp5sps28wczj3m87xs55x2ja"]	a9847972e3aaa7d5af3e8a3fd8d1951031382d3bd5f4e4769f3807190d770245	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	767	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f
8460000000000	stake_test1uzhcqtadqcmx4l8gsr8n5zq3nfjky0uvzdaku07uv77ptygnq8wuk	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1uzhcqtadqcmx4l8gsr8n5zq3nfjky0uvzdaku07uv77ptygnq8wuk"]	c5dc60d09385bd2abdbb56eae749161dab7fa790ff41b6041ae93d287854ec7a	\N	\N	846	pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q
9890000000000	stake_test1urv7mngmavchxqvpzlrqh598zmpghtvp43d87pmpfsfcv4slqc8ny	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1urv7mngmavchxqvpzlrqh598zmpghtvp43d87pmpfsfcv4slqc8ny"]	541c6a4992da58c27ca993bad749061f15d06c1e91b2c0bae6ab9c3bc44133a0	\N	\N	989	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp
11340000000000	stake_test1uqplklgjks3s6lgt3090e7wv59vfmj2sk4zp967qecjtuss8amtgt	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1uqplklgjks3s6lgt3090e7wv59vfmj2sk4zp967qecjtuss8amtgt"]	ae20765cf00421ff369492d47562cde0e7d00a108cdf5c39d01cf723379797e7	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	1134	pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a
12450000000000	stake_test1uqxhf9zuxt5y4kuewf74rk2hfs0ucc0m7ek4gp98a5vuf2chp6sh4	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1uqxhf9zuxt5y4kuewf74rk2hfs0ucc0m7ek4gp98a5vuf2chp6sh4"]	3fcc9643b9aa59e3822ca6b33f911e5cd8e14172d0361fcc79d14923f540ade0	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1245	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f
232350000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	23235	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
233920000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	23392	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
8890000000000	5	889	pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q
10140000000000	18	1014	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp
11750000000000	5	1175	pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a
13000000000000	18	1300	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q	1000000	0	0	500000000	0	0	0	0	0	1
2	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	0	0	500000000	0	0	0	0	0	1
3	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	0	0	400000000	0	0	0	0	0	1
4	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	0	0	500000000	0	0	0	0	0	1
5	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	0	0	600000000	0	0	0	0	0	1
6	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	0	0	420000000	0	0	0	0	0	1
7	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	0	0	410000000	0	0	0	0	0	1
8	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	0	0	410000000	0	0	0	0	0	1
9	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	0	0	410000000	0	0	0	0	0	1
10	pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q	1000000	1	0	500000000	0	0	0	4410445112873	4410445112873	1
11	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	1	0	500000000	0	0	0	7056712180597	7056712180597	1
12	pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a	1000000	1	0	400000000	0	0	0	4410445112873	4410445112873	1
13	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	1	0	400000000	0	0	0	6174623158022	6174623158022	1
14	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	1	0	400000000	0	0	0	7056712180597	7056712180597	1
15	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	1	0	500000000	0	0	0	8820890225746	8820890225746	1
16	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	1	0	600000000	0	0	0	11467157293470	11467157293470	1
17	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	1	0	420000000	0	0	0	12349246316045	12349246316045	1
18	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	1	0	410000000	0	0	0	8820890225746	8820890225746	1
19	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	1	0	410000000	0	0	0	7056712180597	7056712180597	1
20	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	1	0	410000000	0	0	0	10585068270895	10585068270895	1
21	pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q	1000000	2	3	500000000	7773227572016780	7773227272016780	0	9509778773402	9509778773402	1
22	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	2	3	500000000	7773227572193545	7773227272193545	0	6051677401116	6051677401116	1
23	pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a	1000000	2	1	400000000	7772727272727272	7772727272727272	0	6052066923466	6052066923466	1
24	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	2	1	400000000	7772727272727272	7772727272727272	0	7781228901599	7781228901599	1
25	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	2	3	400000000	7773227772190781	7773227272190781	0	9509778528507	9509778528507	1
26	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	2	3	500000000	7773227872193545	7773227272193545	0	6916202477209	6916202477209	1
27	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	2	3	600000000	7773227472190773	7773227272190773	0	7780728187250	7780728187250	1
28	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	2	3	420000000	7773227772190773	7773227272190773	0	6051677245414	6051677245414	1
29	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	2	3	410000000	7773227772190773	7773227272190773	0	6916202566187	6916202566187	1
30	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	2	3	410000000	7773227772190773	7773227272190773	0	8645253207734	8645253207734	1
31	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	2	3	410000000	7773227772190773	7773227272190773	0	4322626603866	4322626603866	1
32	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	3	3	500000000	7773227572016780	7773227272016780	0	0	0	1
33	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	3	3	400000000	7773227772013964	7773227272013964	0	4243537654461	4243537654461	1
34	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	3	3	400000000	7773227772190781	7773227272190781	1018780908250	5770879338736	6789660246986	1
35	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	3	3	500000000	7773227872193545	7773227272193545	1400699520418	7935083199083	9335782719501	1
36	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	3	3	600000000	7773227472190773	7773227272190773	0	0	0	1
37	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	3	3	420000000	7773227772190773	7773227272190773	1400682436353	7935100403253	9335782839606	1
38	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	3	3	410000000	7773227772190773	7773227272190773	1146087084284	6492280693574	7638367777858	1
39	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	3	3	410000000	7773227772190773	7773227272190773	1400707936351	7935074903254	9335782839605	1
40	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	3	3	410000000	7773227772190773	7773227272190773	1146087084284	6492280693574	7638367777858	1
41	pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q	1000000	3	3	500000000	7773227572016780	7773227272016780	0	0	0	1
42	pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a	1000000	3	3	400000000	7773227772013964	7773227272013964	0	6789660247140	6789660247140	1
43	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	4	3	500000000	7780284284197377	7780283984197377	0	0	0	1
44	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	4	3	400000000	7779402395171986	7779401895171986	1377320391625	7802602209267	9179922600892	1
45	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	4	3	400000000	7780284484371378	7780283984371378	1001664427667	5673885992566	6675550420233	1
46	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	4	3	500000000	7782048762419291	7782048162419291	1001437487032	5672599510781	6674036997813	1
47	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	4	3	600000000	7784694629484243	7784694429484243	0	0	0	1
48	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	4	3	420000000	7785577018506818	7785576518506818	1251129792882	7087635791820	8338765584702	1
49	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	4	3	410000000	7782048662416519	7782048162416519	1126575667882	6381716051144	7508291719026	1
50	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	4	3	410000000	7780284484371370	7780283984371370	751339695744	4255323119431	5006662815175	1
51	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	4	3	410000000	7783812840461668	7783812340461668	750990771923	4253402552759	5004393324682	1
52	pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q	1000000	4	3	500000000	7777638017129653	7777637717129653	0	0	0	1
53	pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a	1000000	4	3	400000000	7777638217126837	7777637717126837	1127231324495	6385318102194	7512549426689	1
54	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	5	3	500000000	7786335961598493	7786335661364935	0	0	0	1
55	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	5	3	400000000	7787183624073585	7787183124073585	986352928609	5587120870534	6573473799143	1
56	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	5	3	400000000	7789794262899885	7789793762288185	1355656594567	7679840745578	9035497340145	1
57	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	5	3	500000000	7788964964896500	7788964364362653	616453998084	3491027528076	4107481526160	1
58	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	5	3	600000000	7792475357671493	7792475157471301	0	0	0	1
59	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	5	3	420000000	7791628695752232	7791628195362968	616226318806	3489850979084	4106077297890	1
60	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	5	3	410000000	7788964864982706	7788964364537833	1232576422277	6982386735424	8214963157701	1
61	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	5	3	410000000	7788929737579104	7788929237023013	1479040575640	8378959672134	9858000247774	1
62	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	5	3	410000000	7788135467065534	7788134966787489	370044345034	2094707058162	2464751403196	1
63	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	6	3	500000000	7786335961598493	7786335661364935	0	0	0	1
64	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	6	3	400000000	7791427161728046	7791426661455088	1440749357182	8162032863575	9602782220757	1
65	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	6	3	400000000	7796583923146871	7795564641626921	1440862474996	8155568341432	9596430816428	1
66	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	6	3	500000000	7798300747616001	7796899447561736	1200842395507	6794422710360	7995265105867	1
67	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	6	3	600000000	7792475357671493	7792475157471301	0	0	0	1
68	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	6	3	420000000	7800964478591838	7799563295766221	720374748050	4075146269144	4795521017194	1
69	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	6	3	410000000	7796603232760564	7795456645231407	720661770149	4077541754468	4798203524617	1
70	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	6	3	410000000	7798265520418709	7796864311926267	960752982012	5435487996366	6396240978378	1
71	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	6	3	410000000	7795773834843392	7794627247481063	720738470330	4077975538569	4798714008899	1
72	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	7	3	500000000	7786335961598493	7786335661364935	0	0	0	1
73	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	7	3	400000000	7800607084328938	7799229263664355	780929448687	4417853788907	5198783237594	1
74	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	7	3	400000000	7803259473567104	7801238527619487	1073789083802	6072108095363	7145897179165	1
75	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	7	3	500000000	7804974784613814	7802572047072517	1269035035319	7174260172841	8443295208160	1
76	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	7	3	600000000	7792475357671493	7792475157471301	0	0	0	1
77	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	7	3	420000000	7809303244176540	7806650931558041	1170986802652	6618504286065	7789491088717	1
78	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	7	3	410000000	7804111524479590	7801838361282551	781085279579	4415363441823	5196448721402	1
79	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	7	3	410000000	7803272183233884	7801119635045698	878705834490	4967927789314	5846633623804	1
80	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	7	3	410000000	7800778228168074	7798880650033822	1366863174759	7730807889853	9097671064612	1
81	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	8	3	500000000	7786335961598493	7786335661364935	0	0	0	1
82	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	8	3	400000000	7807180558128081	7804816384534889	1445550983563	8172741423177	9618292406740	1
83	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	8	3	400000000	7812294970907249	7808918368365065	935545303360	5283981310545	6219526613905	1
84	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	8	3	500000000	7809082266139974	7806063074600593	1275818980920	7208842881318	8484661862238	1
85	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	8	3	600000000	7792475357671493	7792475157471301	0	0	0	1
86	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	8	3	420000000	7813409321474430	7810140782537125	1530326042761	8645629639043	10175955681804	1
87	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	8	3	410000000	7812326487637291	7808820748017975	1275737102876	7205401337441	8481138440317	1
88	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	8	3	410000000	7813130183481658	7809498594717832	850600062166	4802910624471	5653510686637	1
89	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	8	3	410000000	7803242979571270	7800975357091984	935880688270	5290860759412	6226741447682	1
90	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	9	3	500000000	7786335961598493	7786335661364935	0	0	0	1
91	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	9	3	400000000	7816783340348838	7812978417398464	1651491034334	9325960888627	10977451922961	1
92	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	9	3	400000000	7821891401723677	7817073936706497	1376402572926	7765500037736	9141902610662	1
93	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	9	3	500000000	7817077531245841	7812857497310953	1101393228964	6216632633249	7318025862213	1
94	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	9	3	600000000	7792475357671493	7792475157471301	0	0	0	1
95	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	9	3	420000000	7818204842491624	7814215928806269	1009306576213	5697916539832	6707223116045	1
96	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	9	3	410000000	7817124691161908	7812898289772443	734371528648	4144282946890	4878654475538	1
97	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	9	3	410000000	7819526424460036	7814934082714198	917849885747	5178595136979	6096445022726	1
98	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	9	3	410000000	7808041693580169	7805053332630553	826349606709	4668521365959	5494870972668	1
99	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	10	3	500000000	7786335961598493	7786335661364935	0	0	0	1
100	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	10	3	400000000	7821982123586432	7817396271187371	837123015687	4723016270950	5560139286637	1
101	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	10	3	400000000	7829037298902842	7823146044801860	1023114247465	5766487545722	6789601793187	1
102	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	10	3	500000000	7825520826454001	7820031757483794	1116274332873	6293892320436	7410166653309	1
103	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	10	3	600000000	7792475357671493	7792475157471301	0	0	0	1
104	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	10	3	420000000	7825994333580341	7820834433092334	1115924660670	6293793644919	7409718305589	1
105	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	10	3	410000000	7822321139883310	7817313653214266	1116344697416	6296853052458	7413197749874	1
106	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	10	3	410000000	7825373058083840	7819902010503512	1023293668401	5769487364401	6792781032802	1
107	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	10	3	410000000	7817139364644781	7812784140520406	1302599343639	7351864379724	8654463723363	1
108	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	11	3	500000000	7786335961598493	7786335661364935	0	0	0	1
109	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	11	3	400000000	7831600415993172	7825569012610548	1432663042756	8074724342603	9507387385359	1
110	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	11	3	400000000	7835256825516747	7828430026112405	1591976177485	8966857886470	10558834063955	1
111	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	11	3	500000000	7834005488316239	7827240600365112	796245969415	4484014351596	5280260321011	1
112	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	11	3	600000000	7792475357671493	7792475157471301	0	0	0	1
113	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	11	3	420000000	7836170289262145	7829480062731377	1034660605341	5827781486888	6862442092229	1
114	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	11	3	410000000	7830802278323627	7824519054551707	637103821314	3588832358843	4225936180157	1
115	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	11	3	410000000	7831026568770477	7824704921127983	1273883507704	7177746780363	8451630288067	1
116	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	11	3	410000000	7823366106092463	7818075001279818	796487062259	4490954145730	5287441207989	1
117	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	12	3	500000000	7786335961598493	7786335661364935	0	0	0	1
118	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	12	3	400000000	7842577867916133	7834894973499175	797042475095	4485043812835	5282086287930	1
119	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	12	3	400000000	7844398728127409	7836195526150141	956518844108	5380513393115	6337032237223	1
120	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	12	3	500000000	7841323514178452	7833457232998361	1116053427207	6280050319888	7396103747095	1
121	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	12	3	600000000	7792475357671493	7792475157471301	0	0	0	1
122	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	12	3	420000000	7842877512378190	7835177979271209	1514025604334	8521554909356	10035580513690	1
123	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	12	3	410000000	7835680932799165	7828663337498597	1116180050432	6285249732479	7401429782911	1
124	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	12	3	410000000	7837123013793203	7829883516264962	717652919547	4039533569769	4757186489316	1
125	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	12	4	410000000	7828860977065131	7822743522645777	558382157239	3145556538012	3703938695251	1
126	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	13	3	500000000	7786335961598493	7786335661364935	0	0	0	1
127	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	13	3	400000000	7848138007202770	7839617989770125	975367614162	5485131908218	6460499522380	1
128	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	13	3	400000000	7851188329920596	7841962013695863	886830347670	4984069203567	5870899551237	1
129	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	13	3	500000000	7848733680831761	7839751125318797	620967421456	3489947528909	4110914950365	1
130	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	13	3	600000000	7792475357671493	7792475157471301	0	0	0	1
131	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	13	3	420000000	7850287230683779	7841471772916128	1329824842149	7477535326022	8807360168171	1
132	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	13	3	410000000	7843094130549039	7834960190551055	975728020388	5488926235082	6464654255470	1
133	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	13	3	410000000	7843915794826005	7835653003629363	709710077000	3991364156684	4701074233684	1
134	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	13	4	410000000	7842515407637009	7835095353874016	975300218383	5489831083460	6465131301843	1
135	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	14	3	500000000	7786335961598493	7786335661364935	0	0	0	1
136	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	14	3	400000000	7857645394588129	7847692714112728	1397020568754	7847887043408	9244907612162	1
137	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	14	3	400000000	7861747163984551	7850928871582333	698741223658	3921300874291	4620042097949	1
138	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	14	3	500000000	7854013941152772	7844235139670393	1310174050529	7360934235594	8671108286123	1
139	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	14	3	600000000	7792475357671493	7792475157471301	0	0	0	1
140	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	14	3	420000000	7857149672776008	7847299554403016	873236389735	4905195416600	5778431806335	1
141	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	14	3	410000000	7847320066729196	7838549022909898	786343602404	4420759315689	5207102918093	1
142	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	14	3	410000000	7852367425114072	7842830750409726	524296477756	2944874113861	3469170591617	1
143	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	14	4	410000000	7847802848844998	7839586308019746	524098554832	2947089836423	3471188391255	1
144	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	15	3	500000000	7786335961598493	7786335661364935	0	0	0	1
145	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	15	3	400000000	7862927480876059	7852177757925563	517261629339	2902449319742	3419710949081	1
146	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	15	3	400000000	7868084196221774	7856309384975448	1034266287172	5800673077383	6834939364555	1
147	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	15	3	500000000	7861410044899867	7850515189990281	1034500645207	5806241421323	6840742066530	1
148	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	15	3	600000000	7792475357671493	7792475157471301	0	0	0	1
149	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	15	3	420000000	7867185253289698	7855821109312372	1206357017023	6768650067358	7975007084381	1
150	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	15	3	410000000	7854721496512107	7844834272642377	862256536743	4843216112230	5705472648973	1
151	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	15	3	410000000	7857124611603388	7846870283979495	862226040475	4841501579865	5703727620340	1
152	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	15	4	410000000	7851506770645541	7842731847663050	861924673484	4845884027796	5707808701280	1
162	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	17	3	400000000	7878575137870960	7865214755053306	1168115046630	6543012589014	7711127635644	1
163	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	17	3	500000000	7874192068136355	7861366071754784	500900358008	2805708186684	3306608544692	1
164	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	17	3	600000000	7792475357671493	7792475157471301	0	0	0	1
165	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	17	4	420000000	7884272771821940	7870705566612730	1084053375921	6071104955769	7155158331690	1
166	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	17	3	410000000	7866393253685670	7854743958193148	1001629739187	5618143754303	6619773493490	1
167	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	17	3	410000000	7865294856428689	7853806522250040	584445496206	3277628309295	3862073805501	1
168	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	17	4	410000000	7858941363180049	7848667041424343	834723312400	4686985352891	5521708665291	1
169	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	17	3	500000000	7786335961598493	7786335661364935	0	0	0	1
170	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	17	3	400000000	7878632888010601	7865510776877189	500721195288	2804023567560	3304744762848	1
171	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	18	3	400000000	7885410077235515	7871015428130689	1086541843872	6080723565987	7167265409859	1
172	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	18	3	500000000	7881032810202885	7867172313176107	853936646559	4780613968752	5634550615311	1
173	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	18	3	600000000	7792475357671493	7792475157471301	0	0	0	1
174	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	18	4	420000000	7892247778906321	7877474216680088	1085866396657	6075189423228	7161055819885	1
175	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	18	3	410000000	7872098726334643	7859587174305378	698863874161	3916455003350	4615318877511	1
176	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	18	3	410000000	7870998584049029	7858648023829905	1319824983062	7399218067879	8719043050941	1
177	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	18	4	410000000	7864649171881329	7853512925452139	698844831984	3920845768733	4619690600717	1
178	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	19	3	400000000	7894287665477070	7878548912973073	1132975336667	6333633448222	7466608784889	1
179	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	19	3	500000000	7888253585135376	7873300654775793	404933680768	2263752151423	2668685832191	1
180	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	19	3	600000000	7792475357671493	7792475157471301	0	0	0	1
181	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	19	4	420000000	7894738403879931	7879208835559124	566519358348	3166571886607	3733091244955	1
182	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	19	3	410000000	7880434983957555	7866662870729390	809667465211	4532999691170	5342667156381	1
183	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	19	3	410000000	7878222752944071	7864779664313103	1295341538673	7255326293318	8550667831991	1
184	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	19	4	410000000	7873266634384421	7861206243240427	971241918088	5445795856231	6417037774319	1
153	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	16	3	400000000	7873955095773011	7861293454179015	1344103399171	7533484842384	8877588241555	1
154	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	16	3	500000000	7865520959850232	7854005137519190	1092433332805	6128341599686	7220774932491	1
155	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	16	3	600000000	7792475357671493	7792475157471301	0	0	0	1
156	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	16	3	420000000	7875992613457869	7863298644638394	756006094574	4236345436772	4992351531346	1
157	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	16	3	410000000	7861186150767577	7850323198877459	1260561198900	7075696424012	8336257622912	1
158	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	16	3	410000000	7861825685837072	7850861648136179	1092528411844	6131640483198	7224168895042	1
159	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	16	4	410000000	7857971901947384	7848221678746510	924144714804	5191611460064	6115756174868	1
160	pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	1000000	16	3	500000000	7786335961598493	7786335661364935	0	0	0	1
161	pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	1000000	16	3	400000000	7869387980398439	7857662889833781	1008076589186	5653978771428	6662055360614	1
185	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	20	3	400000000	7901998793112714	7885091925562087	807758561225	4510612138262	5318370699487	1
186	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	20	3	500000000	7891560193680068	7876106362962477	559490569474	3127328692109	3686819261583	1
187	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	20	3	600000000	7792475357671493	7792475157471301	0	0	0	1
188	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	20	4	420000000	7901893562211621	7885279940514893	1180171287434	6592935557033	7773106844467	1
189	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	20	3	410000000	7887054757451045	7872281014483693	683812538336	3824873984188	4508686522524	1
190	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	20	3	410000000	7882084826749572	7868057292622398	621752214367	3479638155978	4101390370345	1
191	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	20	4	410000000	7878788343049712	7865893228593318	1118444402659	6267147101820	7385591504479	1
192	pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	1000000	21	3	400000000	7909166058522573	7891172649128074	909932720519	5076899950035	5986832670554	1
193	pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	1000000	21	3	500000000	7897194744295379	7880886976931229	910241383572	5085666693812	5995908077384	1
194	pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	1000000	21	3	600000000	7792475357671493	7792475157471301	0	0	0	1
195	pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	1000000	21	4	420000000	7909052688313215	7891353200219830	970368263201	5415678123158	6386046386359	1
196	pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	1000000	21	3	410000000	7891670076328556	7876197469487043	910346053114	5089759538986	6000105592100	1
197	pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	1000000	21	3	410000000	7890803869800513	7875456510690277	789036543551	4411625805387	5200662348938	1
198	pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	1000000	21	5	410000000	7883409962361827	7869816003073449	910093474455	5096298934674	6006392409129	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1x04paj628jzd24ak60cj73u7p0gkmlxtd8sxr23l6jfksjeaa5k	active	2110000000000	\N
pool154da0ahhgd98yqnclu72e9gw6defp37asvp0e5jgfst4z7x08xm	active	3260000000000	\N
pool10sv8u7jnyw9m7nk2t996rl3u0cpaz7796evjwhcaamjx72sdrse	active	4020000000000	\N
pool1cfh60a2g62quvrlhqhka58kne9rvfax28uwve9la5y78w3gy4ww	active	4830000000000	\N
pool1ln75fe8k4su5wttrd2q2qeruqadh89nl896d26kq3c9gv8wfpqg	active	5860000000000	\N
pool1vwrt3639ymlypvt0agl2mwezmvu0t085tkrfckwl0stc6jypkrk	active	6970000000000	\N
pool1uvcxk7th3zcws4928lugu27v90wyndcymvqmtd8xl5fqzqmj50f	active	7670000000000	\N
pool1w53526n4zr3g02q9jv0gqtamv6vlv3j7jpu2mpvu32u4ssqyt5q	retired	8460000000000	8890000000000
pool1yee2g5ukhcce65uc2ftpv93wnz5cl5d4gens4lg3syrnzj0yc3a	retired	11340000000000	11750000000000
pool1gghrmcjt3vmz2qq0z6jqkqrfes4zql982rk4zavvtjgdgck4lsp	retired	9890000000000	10140000000000
pool1d9nh94h8ms2wmjujtm60fy8245lwg433e4vs0jrkaq8as52jz5f	retired	12450000000000	13000000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	232350000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	233920000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 1, false);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 198, true);


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

