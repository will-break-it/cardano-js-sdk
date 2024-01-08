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
b7dbea86-3148-4ec4-a9f8-440cbe513998	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:04:17.666013+00	2024-01-08 18:04:17.668984+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:04:17.666013+00	2024-01-08 18:04:17.680304+00	2024-01-08 18:12:17.666013+00	f	\N	\N
8988ab6f-f8f7-4637-9d41-e8c0422e37d4	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:14:01.482934+00	2024-01-08 18:14:02.506934+00	\N	2024-01-08 18:14:00	00:15:00	2024-01-08 18:13:02.482934+00	2024-01-08 18:14:02.513029+00	2024-01-08 18:15:01.482934+00	f	\N	\N
e072c54b-888f-495b-a8cc-8d10d5152976	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:15:01.511361+00	2024-01-08 18:15:02.534783+00	\N	2024-01-08 18:15:00	00:15:00	2024-01-08 18:14:02.511361+00	2024-01-08 18:15:02.540635+00	2024-01-08 18:16:01.511361+00	f	\N	\N
be14835f-bf22-4b10-b3ea-c406a276bbed	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:16:01.538992+00	2024-01-08 18:16:02.562736+00	\N	2024-01-08 18:16:00	00:15:00	2024-01-08 18:15:02.538992+00	2024-01-08 18:16:02.568932+00	2024-01-08 18:17:01.538992+00	f	\N	\N
03c2ea56-fa5e-4e14-a5b1-87c3b19e080b	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:17:01.567221+00	2024-01-08 18:17:02.588438+00	\N	2024-01-08 18:17:00	00:15:00	2024-01-08 18:16:02.567221+00	2024-01-08 18:17:02.594046+00	2024-01-08 18:18:01.567221+00	f	\N	\N
e65393ab-1d7c-4edd-88c1-9b3e569fa5aa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:18:54.259574+00	2024-01-08 18:19:54.257423+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:16:54.259574+00	2024-01-08 18:19:54.271319+00	2024-01-08 18:26:54.259574+00	f	\N	\N
7a50126e-07ce-406e-b425-04f198af85a8	pool-rewards	0	{"epochNo": 6}	completed	1000000	0	30	f	2024-01-08 18:20:41.813965+00	2024-01-08 18:20:42.706387+00	6	\N	00:15:00	2024-01-08 18:20:41.813965+00	2024-01-08 18:20:42.850403+00	2024-01-22 18:20:41.813965+00	f	\N	8004
6d182632-2481-42fb-9d1f-99b843ec06cc	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:04:17.674671+00	2024-01-08 18:04:54.257062+00	\N	2024-01-08 18:04:00	00:15:00	2024-01-08 18:04:17.674671+00	2024-01-08 18:04:54.26157+00	2024-01-08 18:05:17.674671+00	f	\N	\N
32641594-058c-4ee4-b200-6e01c3936ef3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:04:54.240371+00	2024-01-08 18:04:54.251999+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:04:54.240371+00	2024-01-08 18:04:54.262579+00	2024-01-08 18:12:54.240371+00	f	\N	\N
9eadf3af-a609-4c7a-99f4-96eafc3e1f73	pool-rewards	0	{"epochNo": 7}	completed	1000000	0	30	f	2024-01-08 18:24:01.010604+00	2024-01-08 18:24:02.800601+00	7	\N	00:15:00	2024-01-08 18:24:01.010604+00	2024-01-08 18:24:02.918501+00	2024-01-22 18:24:01.010604+00	f	\N	9000
41e34c18-ac45-43c6-8291-41c0260626c7	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:27:01.842101+00	2024-01-08 18:27:02.863368+00	\N	2024-01-08 18:27:00	00:15:00	2024-01-08 18:26:02.842101+00	2024-01-08 18:27:02.869648+00	2024-01-08 18:28:01.842101+00	f	\N	\N
dd13ed5e-4da3-45f3-8351-c1c7f25400d9	pool-metadata	0	{"poolId": "pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459", "metadataJson": {"url": "http://file-server/SP1.json", "hash": "14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7"}, "poolRegistrationId": "2080000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.334671+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:17.816147+00	\N	2024-01-22 18:04:17.816147+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459/14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	208
4b1769c3-40bb-44d5-9772-13dbec3f6160	pool-metadata	0	{"poolId": "pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv", "metadataJson": {"url": "http://file-server/SP4.json", "hash": "09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d"}, "poolRegistrationId": "4970000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.336738+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:17.914066+00	\N	2024-01-22 18:04:17.914066+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv/09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	497
3807b761-8954-4a9d-a1d0-24b725c22c40	pool-metadata	0	{"poolId": "pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c", "metadataJson": {"url": "http://file-server/SP11.json", "hash": "4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9"}, "poolRegistrationId": "12260000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.344578+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:18.207956+00	\N	2024-01-22 18:04:18.207956+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c/4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	1226
d8e3a17d-c046-470c-bda4-7206f8d58ee0	pool-rewards	0	{"epochNo": 0}	completed	1000000	0	30	f	2024-01-08 18:04:18.406187+00	2024-01-08 18:04:54.275219+00	0	\N	00:15:00	2024-01-08 18:04:18.406187+00	2024-01-08 18:04:54.521503+00	2024-01-22 18:04:18.406187+00	f	\N	2005
d68bf904-1197-4fc9-99ab-98f791b0f863	pool-metrics	0	{"slot": 3050}	completed	0	0	0	f	2024-01-08 18:04:18.755206+00	2024-01-08 18:04:54.268518+00	\N	\N	00:15:00	2024-01-08 18:04:18.755206+00	2024-01-08 18:04:54.593889+00	2024-01-22 18:04:18.755206+00	f	\N	3050
5dbea982-82d0-4b57-ab03-af060339f54f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:05:01.262058+00	2024-01-08 18:05:02.259068+00	\N	2024-01-08 18:05:00	00:15:00	2024-01-08 18:04:54.262058+00	2024-01-08 18:05:02.26629+00	2024-01-08 18:06:01.262058+00	f	\N	\N
321a96c8-c730-479a-af19-1e5a63c558ac	pool-rewards	0	{"epochNo": 1}	completed	1000000	1	30	f	2024-01-08 18:05:24.311588+00	2024-01-08 18:05:26.281969+00	1	\N	00:15:00	2024-01-08 18:04:18.733144+00	2024-01-08 18:05:26.41186+00	2024-01-22 18:04:18.733144+00	f	\N	3003
e01bb208-6c53-4244-b9c9-6e0634e236aa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:06:54.265362+00	2024-01-08 18:07:54.251714+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:04:54.265362+00	2024-01-08 18:07:54.257192+00	2024-01-08 18:14:54.265362+00	f	\N	\N
c2c19660-dc8e-4ff8-a14e-47de51a4e9f6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:15:54.261756+00	2024-01-08 18:16:54.252855+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:13:54.261756+00	2024-01-08 18:16:54.257831+00	2024-01-08 18:23:54.261756+00	f	\N	\N
dcc75f24-93d7-4b5c-8fb5-b5e343f81896	pool-metadata	0	{"poolId": "pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m", "metadataJson": {"url": "http://file-server/SP3.json", "hash": "6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25"}, "poolRegistrationId": "4100000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.338211+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:17.872784+00	\N	2024-01-22 18:04:17.872784+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m/6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	410
1a3380ef-391c-44da-a0df-e13f1a3dd5e3	pool-metadata	0	{"poolId": "pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc", "metadataJson": {"url": "http://file-server/SP5.json", "hash": "0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501"}, "poolRegistrationId": "5630000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.340152+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:17.941784+00	\N	2024-01-22 18:04:17.941784+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc/0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	563
d85300f5-4a1e-4b8c-9929-bcdab832de59	pool-metadata	0	{"poolId": "pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v", "metadataJson": {"url": "http://file-server/SP6.json", "hash": "3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba"}, "poolRegistrationId": "6580000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.341533+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:17.9731+00	\N	2024-01-22 18:04:17.9731+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v/3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	658
f0af1791-24ef-45d2-9aff-619d66e9f91a	pool-metadata	0	{"poolId": "pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z", "metadataJson": {"url": "http://file-server/SP7.json", "hash": "c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405"}, "poolRegistrationId": "7670000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.342908+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:18.006948+00	\N	2024-01-22 18:04:18.006948+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405 due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405 due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405 due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z/c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	767
302458d6-7067-4e45-9759-44fd339eeb4e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:18:01.592451+00	2024-01-08 18:18:02.616628+00	\N	2024-01-08 18:18:00	00:15:00	2024-01-08 18:17:02.592451+00	2024-01-08 18:18:02.622871+00	2024-01-08 18:19:01.592451+00	f	\N	\N
9dfa2e5e-97ad-4452-af44-56e5fa625ff2	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:19:01.621116+00	2024-01-08 18:19:02.644773+00	\N	2024-01-08 18:19:00	00:15:00	2024-01-08 18:18:02.621116+00	2024-01-08 18:19:02.65064+00	2024-01-08 18:20:01.621116+00	f	\N	\N
f147c98d-541d-4379-a0f6-f7d85b23e6a8	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:21:01.675322+00	2024-01-08 18:21:02.701473+00	\N	2024-01-08 18:21:00	00:15:00	2024-01-08 18:20:02.675322+00	2024-01-08 18:21:02.707322+00	2024-01-08 18:22:01.675322+00	f	\N	\N
ef9c1640-f480-434e-a672-92407c932d0d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:21:54.273345+00	2024-01-08 18:22:54.261535+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:19:54.273345+00	2024-01-08 18:22:54.274264+00	2024-01-08 18:29:54.273345+00	f	\N	\N
1bd1b0b2-1a5a-4fb6-bc4c-1303f2f73169	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:24:01.758815+00	2024-01-08 18:24:02.784305+00	\N	2024-01-08 18:24:00	00:15:00	2024-01-08 18:23:02.758815+00	2024-01-08 18:24:02.791196+00	2024-01-08 18:25:01.758815+00	f	\N	\N
430f48c5-55e7-4995-901e-b4ac487b32b5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:24:54.276012+00	2024-01-08 18:25:54.266098+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:22:54.276012+00	2024-01-08 18:25:54.27137+00	2024-01-08 18:32:54.276012+00	f	\N	\N
80814775-2039-4f16-bf95-1c8e4b95fe8b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:27:54.273196+00	2024-01-08 18:28:54.269199+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:25:54.273196+00	2024-01-08 18:28:54.275367+00	2024-01-08 18:35:54.273196+00	f	\N	\N
93ba87b1-3083-4212-ab64-9163cea17173	pool-metadata	0	{"poolId": "pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg", "metadataJson": {"url": "http://file-server/SP10.json", "hash": "c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd"}, "poolRegistrationId": "10820000000000"}	retry	1000000	0	21600	f	2024-01-09 00:04:54.346182+00	2024-01-08 18:04:54.268393+00	\N	\N	00:15:00	2024-01-08 18:04:18.163502+00	\N	2024-01-22 18:04:18.163502+00	f	{"name": "StakePoolMetadataServiceError", "stack": "StakePoolMetadataServiceError: FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd due to Request failed with status code 500)\\n    at Object.getStakePoolMetadata (/app/packages/cardano-services/dist/cjs/StakePool/HttpStakePoolMetadata/HttpStakePoolMetadataService.js:79:24)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async /app/packages/cardano-services/dist/cjs/PgBoss/stakePoolMetadataHandler.js:77:34\\n    at async baseHandler (/app/packages/cardano-services/dist/cjs/Program/services/pgboss.js:119:21)\\n    at async resolveWithinSeconds (/app/node_modules/pg-boss/src/manager.js:34:14)\\n    at async /app/node_modules/p-map/index.js:57:22", "detail": "StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd due to Request failed with status code 500", "reason": "FAILED_TO_FETCH_METADATA", "message": "FAILED_TO_FETCH_METADATA (StakePoolMetadataService failed to fetch metadata JSON from http://cardano-smash:3100/api/v1/metadata/pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd due to Request failed with status code 500)", "innerError": {"code": "ERR_BAD_RESPONSE", "name": "AxiosError", "config": {"env": {}, "url": "http://cardano-smash:3100/api/v1/metadata/pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg/c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd", "method": "get", "headers": {"Accept": "application/json, text/plain, */*", "User-Agent": "axios/0.27.2"}, "timeout": 2000, "responseType": "arraybuffer", "transitional": {"forcedJSONParsing": true, "silentJSONParsing": true, "clarifyTimeoutError": false}, "maxBodyLength": -1, "xsrfCookieName": "XSRF-TOKEN", "xsrfHeaderName": "X-XSRF-TOKEN", "maxContentLength": 5000, "transformRequest": [], "transformResponse": []}, "status": 500, "message": "Request failed with status code 500"}}	1082
cb15a264-c2c0-4e5b-a562-cf5e40404c9f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:30:54.277067+00	2024-01-08 18:31:54.272988+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:28:54.277067+00	2024-01-08 18:31:54.279628+00	2024-01-08 18:38:54.277067+00	f	\N	\N
6a848694-6ed7-4a80-8f7f-637399eca319	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:13:01.454968+00	2024-01-08 18:13:02.478571+00	\N	2024-01-08 18:13:00	00:15:00	2024-01-08 18:12:02.454968+00	2024-01-08 18:13:02.484567+00	2024-01-08 18:14:01.454968+00	f	\N	\N
50e60321-3ef9-4a63-afd1-03f4ad0c5860	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:06:01.264531+00	2024-01-08 18:06:02.285884+00	\N	2024-01-08 18:06:00	00:15:00	2024-01-08 18:05:02.264531+00	2024-01-08 18:06:02.293654+00	2024-01-08 18:07:01.264531+00	f	\N	\N
be0c470c-44fa-459e-89da-5ec5c710e54d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:12:54.259754+00	2024-01-08 18:13:54.253006+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:10:54.259754+00	2024-01-08 18:13:54.259939+00	2024-01-08 18:20:54.259754+00	f	\N	\N
4feff0a6-3c41-437d-bb23-b7781c07876a	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:07:01.290774+00	2024-01-08 18:07:02.310105+00	\N	2024-01-08 18:07:00	00:15:00	2024-01-08 18:06:02.290774+00	2024-01-08 18:07:02.316146+00	2024-01-08 18:08:01.290774+00	f	\N	\N
f7eae7fb-05ce-4744-93af-d104324130b5	pool-rewards	0	{"epochNo": 4}	completed	1000000	0	30	f	2024-01-08 18:14:06.017808+00	2024-01-08 18:14:06.536328+00	4	\N	00:15:00	2024-01-08 18:14:06.017808+00	2024-01-08 18:14:06.688488+00	2024-01-22 18:14:06.017808+00	f	\N	6025
6986b2a8-0253-4dbd-b2d6-8954e42fbbad	pool-rewards	0	{"epochNo": 2}	completed	1000000	0	30	f	2024-01-08 18:07:22.209777+00	2024-01-08 18:07:22.331581+00	2	\N	00:15:00	2024-01-08 18:07:22.209777+00	2024-01-08 18:07:22.468855+00	2024-01-22 18:07:22.209777+00	f	\N	4006
0ceeb6f8-b858-4602-a1f7-12b5c62efb06	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:32:01.965089+00	2024-01-08 18:32:02.986723+00	\N	2024-01-08 18:32:00	00:15:00	2024-01-08 18:31:02.965089+00	2024-01-08 18:32:02.994344+00	2024-01-08 18:33:01.965089+00	f	\N	\N
3537e3d1-08e2-4bf7-b19c-9273652f3721	pool-rewards	0	{"epochNo": 5}	completed	1000000	0	30	f	2024-01-08 18:17:22.013197+00	2024-01-08 18:17:22.621199+00	5	\N	00:15:00	2024-01-08 18:17:22.013197+00	2024-01-08 18:17:22.755273+00	2024-01-22 18:17:22.013197+00	f	\N	7005
edd4f996-392a-4faf-9c58-f0adf97c4a8e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:08:01.314484+00	2024-01-08 18:08:02.336672+00	\N	2024-01-08 18:08:00	00:15:00	2024-01-08 18:07:02.314484+00	2024-01-08 18:08:02.342371+00	2024-01-08 18:09:01.314484+00	f	\N	\N
1a73f8f6-0692-4ed0-9f2d-62e864288dbc	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:33:01.992711+00	2024-01-08 18:33:03.008309+00	\N	2024-01-08 18:33:00	00:15:00	2024-01-08 18:32:02.992711+00	2024-01-08 18:33:03.01487+00	2024-01-08 18:34:01.992711+00	f	\N	\N
97a6f550-2a44-4974-96f1-d15a23034ef0	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:09:01.3407+00	2024-01-08 18:09:02.362986+00	\N	2024-01-08 18:09:00	00:15:00	2024-01-08 18:08:02.3407+00	2024-01-08 18:09:02.370435+00	2024-01-08 18:10:01.3407+00	f	\N	\N
e70c2782-f099-4398-a2a5-eff106aa1493	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:20:01.649031+00	2024-01-08 18:20:02.671116+00	\N	2024-01-08 18:20:00	00:15:00	2024-01-08 18:19:02.649031+00	2024-01-08 18:20:02.676948+00	2024-01-08 18:21:01.649031+00	f	\N	\N
12d55da7-da03-4713-8bd9-4892a4e76b2f	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:10:01.368295+00	2024-01-08 18:10:02.391874+00	\N	2024-01-08 18:10:00	00:15:00	2024-01-08 18:09:02.368295+00	2024-01-08 18:10:02.397942+00	2024-01-08 18:11:01.368295+00	f	\N	\N
77f63eae-640a-4569-ae9b-86ca6d12c6a1	pool-rewards	0	{"epochNo": 10}	completed	1000000	0	30	f	2024-01-08 18:34:01.009371+00	2024-01-08 18:34:01.066862+00	10	\N	00:15:00	2024-01-08 18:34:01.009371+00	2024-01-08 18:34:01.180942+00	2024-01-22 18:34:01.009371+00	f	\N	12000
418ad92e-3784-453a-b66f-a583f1f4605f	pool-rewards	0	{"epochNo": 3}	completed	1000000	0	30	f	2024-01-08 18:10:43.211878+00	2024-01-08 18:10:44.432587+00	3	\N	00:15:00	2024-01-08 18:10:43.211878+00	2024-01-08 18:10:44.570762+00	2024-01-22 18:10:43.211878+00	f	\N	5011
b05803f8-44ab-485f-855c-6bc054820cdc	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:22:01.705715+00	2024-01-08 18:22:02.726776+00	\N	2024-01-08 18:22:00	00:15:00	2024-01-08 18:21:02.705715+00	2024-01-08 18:22:02.734551+00	2024-01-08 18:23:01.705715+00	f	\N	\N
fb3f6349-536c-4a00-9200-da8d18a8e472	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:09:54.259071+00	2024-01-08 18:10:54.252991+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:07:54.259071+00	2024-01-08 18:10:54.257902+00	2024-01-08 18:17:54.259071+00	f	\N	\N
6c3d3066-1738-4578-b9a0-c49b1201993c	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:23:01.73248+00	2024-01-08 18:23:02.754608+00	\N	2024-01-08 18:23:00	00:15:00	2024-01-08 18:22:02.73248+00	2024-01-08 18:23:02.760423+00	2024-01-08 18:24:01.73248+00	f	\N	\N
49cd43d2-4ea8-4593-859e-472fea630b4e	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:11:01.396334+00	2024-01-08 18:11:02.419867+00	\N	2024-01-08 18:11:00	00:15:00	2024-01-08 18:10:02.396334+00	2024-01-08 18:11:02.426578+00	2024-01-08 18:12:01.396334+00	f	\N	\N
7cff556c-51b7-4781-9c70-1e60396cf7b8	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:34:01.012987+00	2024-01-08 18:34:03.032969+00	\N	2024-01-08 18:34:00	00:15:00	2024-01-08 18:33:03.012987+00	2024-01-08 18:34:03.040338+00	2024-01-08 18:35:01.012987+00	f	\N	\N
3f13469b-c663-4455-8086-851a472bda74	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:12:01.424779+00	2024-01-08 18:12:02.450523+00	\N	2024-01-08 18:12:00	00:15:00	2024-01-08 18:11:02.424779+00	2024-01-08 18:12:02.456572+00	2024-01-08 18:13:01.424779+00	f	\N	\N
58837ee4-20de-4f5e-97fd-384238b02a23	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:33:54.281489+00	2024-01-08 18:34:54.275044+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:31:54.281489+00	2024-01-08 18:34:54.28064+00	2024-01-08 18:41:54.281489+00	f	\N	\N
c86c107f-3fe5-412f-b7ea-0fae3daf0d68	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:25:01.789424+00	2024-01-08 18:25:02.810821+00	\N	2024-01-08 18:25:00	00:15:00	2024-01-08 18:24:02.789424+00	2024-01-08 18:25:02.817118+00	2024-01-08 18:26:01.789424+00	f	\N	\N
cf2e293d-3f6b-43b0-a80f-7bae2719b406	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:26:01.815185+00	2024-01-08 18:26:02.837848+00	\N	2024-01-08 18:26:00	00:15:00	2024-01-08 18:25:02.815185+00	2024-01-08 18:26:02.843749+00	2024-01-08 18:27:01.815185+00	f	\N	\N
876a5b5c-72be-4bba-a2a0-04e59ebdb2c6	pool-rewards	0	{"epochNo": 8}	completed	1000000	0	30	f	2024-01-08 18:27:23.412401+00	2024-01-08 18:27:24.891821+00	8	\N	00:15:00	2024-01-08 18:27:23.412401+00	2024-01-08 18:27:25.037173+00	2024-01-22 18:27:23.412401+00	f	\N	10012
46925ee2-6ce6-4396-9085-696bf1bcee9d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:28:01.867956+00	2024-01-08 18:28:02.889107+00	\N	2024-01-08 18:28:00	00:15:00	2024-01-08 18:27:02.867956+00	2024-01-08 18:28:02.895067+00	2024-01-08 18:29:01.867956+00	f	\N	\N
0120b899-8113-48ac-8ec1-aa4671f05994	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:35:01.038718+00	2024-01-08 18:35:03.057356+00	\N	2024-01-08 18:35:00	00:15:00	2024-01-08 18:34:03.038718+00	2024-01-08 18:35:03.065726+00	2024-01-08 18:36:01.038718+00	f	\N	\N
f545adf4-4fa5-4e4c-a22a-d6c0007a9c22	pool-metrics	0	{"slot": 10296}	completed	0	0	0	f	2024-01-08 18:28:20.212494+00	2024-01-08 18:28:20.917704+00	\N	\N	00:15:00	2024-01-08 18:28:20.212494+00	2024-01-08 18:28:21.086844+00	2024-01-22 18:28:20.212494+00	f	\N	10296
d88cde4f-3b55-4a50-8c08-2d864e184c41	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:29:01.893416+00	2024-01-08 18:29:02.913107+00	\N	2024-01-08 18:29:00	00:15:00	2024-01-08 18:28:02.893416+00	2024-01-08 18:29:02.918899+00	2024-01-08 18:30:01.893416+00	f	\N	\N
5b2ebe03-1ba0-488e-86e4-114ddbaa3e57	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:36:01.063531+00	2024-01-08 18:36:03.075224+00	\N	2024-01-08 18:36:00	00:15:00	2024-01-08 18:35:03.063531+00	2024-01-08 18:36:03.08171+00	2024-01-08 18:37:01.063531+00	f	\N	\N
0ff5bc79-9f83-4310-911a-f751b4eb7ffa	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:30:01.917199+00	2024-01-08 18:30:02.937846+00	\N	2024-01-08 18:30:00	00:15:00	2024-01-08 18:29:02.917199+00	2024-01-08 18:30:02.945078+00	2024-01-08 18:31:01.917199+00	f	\N	\N
a53160e0-3a27-42db-b19c-f608f1a93408	pool-rewards	0	{"epochNo": 9}	completed	1000000	0	30	f	2024-01-08 18:30:41.607641+00	2024-01-08 18:30:42.978957+00	9	\N	00:15:00	2024-01-08 18:30:41.607641+00	2024-01-08 18:30:43.111078+00	2024-01-22 18:30:41.607641+00	f	\N	11003
ac966d7a-7de2-4545-af6d-5bc67bc7e9d2	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:31:01.943412+00	2024-01-08 18:31:02.959904+00	\N	2024-01-08 18:31:00	00:15:00	2024-01-08 18:30:02.943412+00	2024-01-08 18:31:02.966733+00	2024-01-08 18:32:01.943412+00	f	\N	\N
663c362b-813d-43eb-9489-8ec664d39101	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:36:54.282332+00	2024-01-08 18:37:54.278155+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:34:54.282332+00	2024-01-08 18:37:54.282938+00	2024-01-08 18:44:54.282332+00	f	\N	\N
a61316e7-eb3d-472e-b963-4ac19024dbf5	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:39:01.129015+00	2024-01-08 18:39:03.14673+00	\N	2024-01-08 18:39:00	00:15:00	2024-01-08 18:38:03.129015+00	2024-01-08 18:39:03.153456+00	2024-01-08 18:40:01.129015+00	f	\N	\N
5e5926aa-2d9d-472b-ac7f-e32e2086994d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:37:01.079825+00	2024-01-08 18:37:03.098403+00	\N	2024-01-08 18:37:00	00:15:00	2024-01-08 18:36:03.079825+00	2024-01-08 18:37:03.106306+00	2024-01-08 18:38:01.079825+00	f	\N	\N
fc289910-dd0e-41d3-989d-1c73d63883a9	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:40:01.151874+00	2024-01-08 18:40:03.170552+00	\N	2024-01-08 18:40:00	00:15:00	2024-01-08 18:39:03.151874+00	2024-01-08 18:40:03.176351+00	2024-01-08 18:41:01.151874+00	f	\N	\N
5b00dda3-f2ee-4ee3-a18c-b8fa80ec0bec	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:39:54.284637+00	2024-01-08 18:40:54.279794+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:37:54.284637+00	2024-01-08 18:40:54.291162+00	2024-01-08 18:47:54.284637+00	f	\N	\N
d8c94483-2438-4339-98c9-a159c9b88ed0	pool-rewards	0	{"epochNo": 11}	completed	1000000	0	30	f	2024-01-08 18:37:24.013276+00	2024-01-08 18:37:25.149296+00	11	\N	00:15:00	2024-01-08 18:37:24.013276+00	2024-01-08 18:37:25.263884+00	2024-01-22 18:37:24.013276+00	f	\N	13015
79103614-67fc-40cf-bd42-ac2927cbb950	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:38:01.104339+00	2024-01-08 18:38:03.124808+00	\N	2024-01-08 18:38:00	00:15:00	2024-01-08 18:37:03.104339+00	2024-01-08 18:38:03.130664+00	2024-01-08 18:39:01.104339+00	f	\N	\N
d25f0705-c0ee-40d9-a7a1-6e65baaaf23d	pool-rewards	0	{"epochNo": 12}	completed	1000000	0	30	f	2024-01-08 18:40:42.611264+00	2024-01-08 18:40:43.239282+00	12	\N	00:15:00	2024-01-08 18:40:42.611264+00	2024-01-08 18:40:43.369561+00	2024-01-22 18:40:42.611264+00	f	\N	14008
a9d9f7b4-3bf9-4732-9a47-a8b0efcef0d8	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:41:01.174735+00	2024-01-08 18:41:03.191441+00	\N	2024-01-08 18:41:00	00:15:00	2024-01-08 18:40:03.174735+00	2024-01-08 18:41:03.199549+00	2024-01-08 18:42:01.174735+00	f	\N	\N
31c9ce47-1d87-4543-b538-31d131f13d3d	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:42:01.197878+00	2024-01-08 18:42:03.219867+00	\N	2024-01-08 18:42:00	00:15:00	2024-01-08 18:41:03.197878+00	2024-01-08 18:42:03.226659+00	2024-01-08 18:43:01.197878+00	f	\N	\N
87496bcb-cd71-4797-b255-c119c9c263c1	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:43:01.224617+00	2024-01-08 18:43:03.247454+00	\N	2024-01-08 18:43:00	00:15:00	2024-01-08 18:42:03.224617+00	2024-01-08 18:43:03.25377+00	2024-01-08 18:44:01.224617+00	f	\N	\N
3b57f4ac-5dc1-41d7-8b60-f9460a1934fd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:42:54.292879+00	2024-01-08 18:43:54.282798+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:40:54.292879+00	2024-01-08 18:43:54.294843+00	2024-01-08 18:50:54.292879+00	f	\N	\N
66fe6161-b215-4759-8318-022780083319	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:44:01.252061+00	2024-01-08 18:44:03.271759+00	\N	2024-01-08 18:44:00	00:15:00	2024-01-08 18:43:03.252061+00	2024-01-08 18:44:03.282411+00	2024-01-08 18:45:01.252061+00	f	\N	\N
25e29305-f091-4e0a-a317-33d7c2785214	pool-rewards	0	{"epochNo": 13}	completed	1000000	0	30	f	2024-01-08 18:44:01.408629+00	2024-01-08 18:44:03.320733+00	13	\N	00:15:00	2024-01-08 18:44:01.408629+00	2024-01-08 18:44:03.433412+00	2024-01-22 18:44:01.408629+00	f	\N	15002
189998c8-8718-4a0e-815e-616eebee70cc	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:45:01.28066+00	2024-01-08 18:45:03.293151+00	\N	2024-01-08 18:45:00	00:15:00	2024-01-08 18:44:03.28066+00	2024-01-08 18:45:03.298945+00	2024-01-08 18:46:01.28066+00	f	\N	\N
4d312a54-7095-4a10-9d61-5ae79abc17d1	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:46:01.29722+00	2024-01-08 18:46:03.319806+00	\N	2024-01-08 18:46:00	00:15:00	2024-01-08 18:45:03.29722+00	2024-01-08 18:46:03.326817+00	2024-01-08 18:47:01.29722+00	f	\N	\N
01747c4a-cb77-4aea-a0d9-65c15905bc40	__pgboss__maintenance	0	\N	completed	0	0	0	f	2024-01-08 18:45:54.29656+00	2024-01-08 18:46:54.284631+00	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:43:54.29656+00	2024-01-08 18:46:54.29717+00	2024-01-08 18:53:54.29656+00	f	\N	\N
3abe09c3-5903-4949-96de-7f980116fd95	__pgboss__maintenance	0	\N	created	0	0	0	f	2024-01-08 18:48:54.29889+00	\N	__pgboss__maintenance	\N	00:15:00	2024-01-08 18:46:54.29889+00	\N	2024-01-08 18:56:54.29889+00	f	\N	\N
231be640-68c9-409e-afae-1231337d6a83	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:47:01.325183+00	2024-01-08 18:47:03.348173+00	\N	2024-01-08 18:47:00	00:15:00	2024-01-08 18:46:03.325183+00	2024-01-08 18:47:03.355566+00	2024-01-08 18:48:01.325183+00	f	\N	\N
2d48a349-95ba-4f03-846a-c35b03781fae	pool-rewards	0	{"epochNo": 14}	completed	1000000	0	30	f	2024-01-08 18:47:22.413969+00	2024-01-08 18:47:23.415633+00	14	\N	00:15:00	2024-01-08 18:47:22.413969+00	2024-01-08 18:47:23.538296+00	2024-01-22 18:47:22.413969+00	f	\N	16007
9116c032-7f0d-4535-b661-b6f817930316	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:48:01.353971+00	2024-01-08 18:48:03.375118+00	\N	2024-01-08 18:48:00	00:15:00	2024-01-08 18:47:03.353971+00	2024-01-08 18:48:03.38129+00	2024-01-08 18:49:01.353971+00	f	\N	\N
2a9d2bce-2c1b-4a61-9f5c-9a5a079e2cd6	__pgboss__cron	0	\N	created	2	0	0	f	2024-01-08 18:50:01.406574+00	\N	\N	2024-01-08 18:50:00	00:15:00	2024-01-08 18:49:03.406574+00	\N	2024-01-08 18:51:01.406574+00	f	\N	\N
ac878684-04cb-486b-81e3-da31555c8e87	__pgboss__cron	0	\N	completed	2	0	0	f	2024-01-08 18:49:01.379464+00	2024-01-08 18:49:03.402415+00	\N	2024-01-08 18:49:00	00:15:00	2024-01-08 18:48:03.379464+00	2024-01-08 18:49:03.408217+00	2024-01-08 18:50:01.379464+00	f	\N	\N
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
20	2024-01-08 18:46:54.295954+00	2024-01-08 18:49:03.40469+00
\.


--
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block (height, hash, slot) FROM stdin;
0	90e0b2bc1691abe0076c23faad3e41e8e64ae4a79484458f399986e49676abef	0
1	4569a2e540d53ecc3b282e2f869394c41873fac2b659e912e9ba776b256d42ef	6
2	5428b9fb02451eb1079a8d1f898cf6e6d0a550cd6f81ce5c2675f1ba28025a76	31
3	51f699073cb075902147c73af20fdff12246123a08a0d59450f1d74695f2b16b	52
4	5a4ff6ea416fb6eede7e39d436a7d68bfdbf1eb1e46cfbf51658f791647275ee	54
5	acf0a3b0e7fdd46215ec53301702967e039de964840933cefcdb043c4831b851	79
6	a441cd75c2af685b2073bd193208c1bb3c8321956932fc3c37e2cf08aef64e8b	80
7	5b73850b202e20c5a26315753f48865dd31d7a7384d6a768cf0cf6bb8c84f437	90
8	8e509e18f0d80c7bf0b344ad94da0841897dba6afe0e41398a302ab3dfc0fa94	91
9	2c412c09fb9c73c630bca97ced0fa43b08a61931eeeb978c6a996a4a9b69cc51	113
10	f655f0053c06378607653f0d5870e50530e8a0bbe05d6c22816532d36935f2f2	133
11	fc4f46638de955b451383afd40901a950f1dd3c62cd877d2486252573404d92b	140
12	5f65c2e830724e7fb6d2a1edd1b841ffa6b5a7666a9bbcc2be0a479ac0a2cfeb	146
13	32cfd325ee2c4309d56902816caeb588559f0daefb1b78670e309e73574b64d5	151
14	a4f7a9620766deac54ea7b926924b7fb5d9bb5f71de7a3645340eaf268053b2c	156
15	920ca2d169a92606407cb47ba9f23d96c75f93ab36a9e94c9424f0092e0ec228	165
16	d3e8fe5bb4265169ae4f8f41ba7f7b984cc3c949dd5bd0e913f42feebfe02c21	176
17	059253be4d37a0e2c2f9ee6d608c0ff5aae671e9a185b38fc4da897d19db706e	181
18	4e71025eab5e6b21de032ff752e4b1028053936505515fb6a408d03cb1070552	192
19	c045d72479b544044e83f986812d56826db691dda450505adbaec6106ac3b6e1	208
20	f448ec8023489f76710ea911ee8f630cf6681a4f0d7e63e3adc784b9ae485897	217
21	77301522cf51d37302ef91b3068ec51a03d44148a151b84e654d471256a9b971	230
22	b6166a1ebef48dd8d0638c99a910e42df1ad7447c3363177646423d6464ea3a3	233
23	03b1da58fcd99637ca372f4f05963dc69e38ec47f5485c72e7781e823d6a53f8	237
24	f16ee1ad47bce5943b7b316500f7741987d7c119c04642b80028b3d36bd526eb	247
25	e516bef63ae1eaa01c68e124a19cdfefa5bc74ea89f4fd5d8b044381c24690cc	265
26	e4ff488549cc86ade16d9c74e6d76fe5d0b9c822c32639bfdd7d9009c096eb82	291
27	5750801f487a8aa8785ac1054942f59b2a3355d1aa6dac1b58f5860ae38f8a46	296
28	2fb6b78d8df1a439d28382e350d614eb44dae6178d6b249e24e41c1cd73aa436	298
29	e7202d5b05e03caa79ccd3b6d9a51c0c0d5ecb5695a9b7ae5a3acdf082ca30fa	325
30	eb89bce82e7ec39288b4dae7c2e49dde3c32e1672f8081a2df6c2493996ddad4	331
31	3b75086032b4a936d3cc71c4d926c759b14c98eac1da98ad09564223a10d00cb	376
32	7e41af460e2eeab863dffb2d520dbed98a59e5eb0d9ed359f7850aaa5179f749	400
33	7cbd158432470e7c721a89e854dd98225b339b8c12f2519662e44b9010daef41	410
34	a3f8482d81bba9f951f03cbbf5ce7280f0b19047d1819ec4b1ed916ece24e4a5	414
35	3e8c7090fdbdf91f1ec5101fcbf4f75579510f693034f81f20dc9b1a00661860	433
36	cfcc7a22a2991da24b85d81d1c92b78f543138742ea79bffcfbb852ea7662348	434
37	226ae77130a832434eef1454c9cb63218b66a317d7c6b70df00a7249fc448206	457
38	2ba619945039519854746a2d68b7a4cda50bc562ceeadc68d514628dfd3e24fe	463
39	b7ff9f75c3c3625c8ec592dbacc1584811d8ca15f0f6c659a4beaf832c51f2c7	464
40	0432d3982e6690d563185aec2b2a6aa7d4a73a12c6b601f01ef14ce13c313eac	467
41	048846c0a78676195984e6d30db3c62ce2a184dab586cc38e48abff699ff958d	469
42	4aeac0db6c7c1127cf4628b3b5dabcbdd08927c2329b04d7e41898b032278758	472
43	932a7c2fa77dedda84238ff1dbfa9f9af4e4dbfcfd45b42eab3b3fc4f2643a4a	485
44	98e18b81bbe6d3abedff8eb40832f837a83a758e50373b61090bf9ed02182e7c	487
45	0d5c62e8cc21f5dc04abc365cbb13baadfbf59d2b5892cc10509f7f0644b5319	488
46	5886f0d12c8a74aaee39106fabc593a03c39538ce96dd175aebb0365d9c0135b	497
47	26232321af11e8c55b545fea8d82f68a4a159265ad3b874b19c99cfcdcabe11d	504
48	078a88c672b9325159b22ee542e1b1265cbe80799dac00c2a0e95915cff75776	505
49	4282798e19586dda3070952a988f1a2cd616a7f8ce02008839845f37620c4342	532
50	ae195704804b9aba881400cfc851f2a91a63094ba4b8aa859be94764da1322fe	538
51	727d927b6e0353d8feef6dde8049ac07a74289c48c8a6dd69adbba6964f0d2aa	541
52	4232639ab58ba1f0d92a35da1d40c915038732224a92a8c14d62ccdd48285883	543
53	5dfed3f4359367d478ca9e567c5765d375e72a004b7cb26bc74c3c83ff53876a	547
54	3714a3da30566d094ee950008088973e4d608abc64e261b733d259f9e2768d99	563
55	d9181d35b6a52bdff34d6189c19f8c47be4f0d00ef43b633f2793752c538b55d	570
56	203accebdcadcb44b0e70272f1d3910e10dcb6e28c2fc7d035729a07f8a39829	573
57	6ef08c07a00aa16c02c060cead412b4df93e814cb2e0fa43d6c3b756e584a22e	588
58	5e2f1f390cd83f05372e42bb568693f7575f1fa1d1273dd3400564869b689eb7	590
59	2506ebf2c3d2a28678475a4e95a2249342ca8287918d935f0577ca147c28af56	605
60	88e8513332a362fd18044d280bdad918372e4cee3e7d81ccd2ed6233f5249cc1	612
61	5eeca2e39ebfd07ef46c53b123d840399d62bf6265ab7f2939da13fc431a5c23	621
62	8b96b70a35cdeaab8a92e67bd366e90cbd12c63f7b8ca3b58d020d5e56dad5d5	622
63	cb3ccc3845572c9d48a81817bf48ed85f842a5ec5062e61531ba2269f56f06a5	624
64	68e8c457f618f11067764e28f7b5d8c51fdfb5dba87058e185add74721ae82d5	658
65	f6dc4a62a68329d3b5c89e1938a025c79d02d46212dd4f5ae323dc161be9879f	671
66	ecef28397b30f63d2d6bcd3b7346d8844123df08977faa22086b1c2996729fd9	677
67	739a8485b789f5a3cf6c9024404355c22313e077e2857a634d61fab2862c44a7	692
68	78807f72c2c8e2deb792c99280e7178660d8aa9c622e5e58ce7e96ba0a9a73a0	697
69	a87ebdd224496f35c34bc8b6172af132ddab59af3b56efa6ea25bb55231e5f66	699
70	02e13f91482045705ed07c075936220e211947110a65a03d2b0183d59876faac	710
71	291b1bd436e6c01fff4bf26f979e74b9e7afc8bb2006c5094fc8e99d3a4df45a	715
72	6f131668de693b0b9daafd671b3e31345810162892838951415f4170d01e9197	725
73	486b66880fef412a3ffff4d6521278eb3880c4128e452e5c4a58df412d01f646	729
74	aa207783cdfda52c1dcb6f5b1a16e8209dd09f063c8b17fe5569e0d07951609e	767
75	e773e9724b330f212a82f649e814284d7e1e30ddd6beea109e957e090a54203c	775
76	e14b02bc0cdaf12f8d83696a6dc438d017247d57bbe7e26d1f109d65491e6511	776
77	7a24fc267d4b15205e3999042dedfe3e8599b133f2acccc958d5dc07ae82c124	777
78	01052104d71802f77b4903f99a189b535c74bd96ef004e76a74572e5e126e03e	783
79	aa25c7e4bc7de4597513dbef6f1241bdd728b2a746d4497de029c35501e25ba2	789
80	6af78e0b6351b24292f91d24e0b468ab7c94980f9d98b42ab2ed2b90336aef61	798
81	d95aae8599e340b0af34f3a7387c116a955b3acf6912412f74da11cebbfaff17	801
82	9132e027e61dc1dab0278e0232193f873f67400c882dc86be8c2dd05e86e5e83	827
83	cb35fe87282c9af8699a32e822cdb74da98f48e4a83171dda12862b200fd7017	830
84	668f0c9d27bfd27db65bc7d7bdb023cccae7ea5d984fe0073ff346f9704573bc	833
85	3926251c7a36d75597541461752cbb2b546d7cbf3f1cbf0d84c16fe67374f98d	854
86	e218369a5dbce5241097b1611d89e966ccaee1fa5d4534365beab35557d2ad21	856
87	759b45a7290965f17b6ca70dcce0b5d0febab7effb1a8f4471c5b855d2bbcf54	864
88	552314cc1c436aad320b4354bdb4aefb4547757ffc95c011d41a3fbde4dd053a	866
89	021a68d0387bfcb48a714befee598b5ab295301bff6ceefab87265d887ff8396	870
90	b2e9a34c3198ddea78bb8d284964a2ac75cad7235c527ce0f5799f4db806daa0	881
91	21114f3b19885dafa6a7584094ddf98af9e3e097f00655e20ed603c08aa95c80	883
92	5088d8cca9ebc2793c23711eba8a5cb3f12c033f6d8a97ead828b13b61483aed	902
93	ae3ddac7da49df155be1a3157fb90f04201cc652622ce350dd6a99452995baaa	924
94	2e5566cce36b0e0a8fa53f0504930673226617cf1cc9a9df0d4cb5293231f859	927
95	20b9bdf0bcd63d9610c26beb2491c008d6892ee1cb63191a7a4d93f975e53da6	936
96	186194774de4b1e0935dc307f1c59aaf81c2e7a777fe55e636907fd65f68a2a7	946
97	138cde189d79ae9e2666086a94ecd1b0119c4083bad365cef1f7ea93c48e0aa0	958
98	a44c7bc71e590570d63396fb690a871742be386b01bbe10ae9a5b2cd1de914e3	965
99	c4aab234e9cd71dff038512edc92e7c9945c2b7b68d90fc23cb20bb054d9bec4	992
100	c05d2a9d74949aac9a8de9d4e18aa6c322bf198f55894b465db384f6b3b6a88b	1000
101	476aaca70da0bd54fcc2994937301e43094dd14787d4188d47b9c1a3e31dfbbb	1015
102	4423a38298e34c1aebec72a967a1fad96e8356b66ac57339cdb59a6f0b4a0d1c	1017
103	78b5323e5b7648bfa82f7b1d9cd7eeb0ae78b1f4fcfdedf7aa9fdd00a20e842f	1027
104	bcb7c0896669a99a14ce0427fd3ed40c7a475dc4df807276432910298d8d2f59	1028
105	1a2b104bacfbf6c9cea298557bf20747bdbbccc379e395db2ea7cb816127eb07	1029
106	cc63922a6f6a384d7c5de64d49960537ce38cdf93506ac8795f78b555e891c44	1032
107	8cb68c6cf42005dfab7ef7238dc882d4e92eccd613daac1fffd4680c2454da99	1042
108	1696784a84bd135eb0f102511964b2d39d92bd02afa5da5c3b2362321c6e8aa9	1053
109	f8e741d46247484c7048efa67e797900cb1cb80032d5f55c094983456cfa630b	1058
110	f43ae979a966c6cc68e442ebc2a4171bfeb005dda1d4f38b488ddc3b358fe50c	1065
111	8699da98819f321d3fdcbcc670241df4bccb20b922080aab64951c455031e752	1067
112	c38628d8ab9e29eb5261600114787015a14f1832d48b7ac2dc7489d4c88a2bd2	1082
113	962aeecbaae6dbde738fb79a05e94d6d46301c31b12d97b0da8c416485e6fe9a	1115
114	6c6d0928eb7a8300f051f628900e139e86d22d9c4ee6ddde3418bf0727c6e9d5	1119
115	950765a9d2def17f9bfbaa25846feb4997fdf0fff42be5d26a5795090d9d6d0f	1145
116	f04fc6f6c384cd7799af8b7260e8c3eeb1bec71dc1e965add4a13b7fcf7feaa0	1151
117	d89da19c1dab49883bb8b0211d3192f001cd6ebf6b5477113c998a68f2aca3cd	1162
118	d32defa22ca88e04ca0631313f6fd42240618867b120e1b6451c5d0b1682f7a5	1181
119	f139c3bc18af5c9d892bfa0bc787c78c4c7c39ac10194075ba55e373fe89ec76	1182
120	d85d5f72ec2c141746b3c9b94e4dcbb9f138b1c3a4d2531655adb629fd95aa50	1189
121	4783b93b9d3a958a9b37d24618a179b9d63be310dc578b2d8d617545439a7e30	1205
122	018a07b4944ea97aa075e78fc493c91b39ab44cab9d13a4a21d299112b94f931	1211
123	7ba49b6b166f79ef3497ed53439a4d0ed1946dcd7efa833da2cc9660877c86d1	1215
124	aa89a9a42421ca3d2d9e37a0b8e360c5f58aede37de79f0c9dd94d2f95e7d580	1219
125	26369ef0a887d8798b333c75d48a47e11944e55dee8877c9f489d10c5108230c	1226
126	4ebe525598b4ec1c0b39a94a47710fb58688968a2a74d4b0c9fbca0f36e9029e	1233
127	d7100979332c9f3de7fff0bfaba0831c673210ba447bb2e48d0191c74dad4ca6	1235
128	8843089613b7e3f5a17564b72bf4301caec80e19dd1c0befba41bd5f657a3da2	1246
129	cad83c4008c741e8b0b8586a88d48ead3ba750216ae59313344fc42311aaa5aa	1251
130	44ef438620d129b6e24dde94d9164905c4679b9f1bad89ed037c489445b23b86	1265
131	0fad9f9ef8ced9cf77818189f8ed5675d2db6bfcee406a42e368ece4a7b52c33	1266
132	af5bec20ba960dc6b5d434973f5cc254ef58d503ab084deb5efa5f64b7d09843	1280
133	9646ed8870677a5a6a8333824741e7e16b2c1cc75ec9508a4666b0e785fad776	1284
134	a4b4f00fe1b391214df7e08ec71551acf28602d96fe88467cb9d05b4058f35bd	1288
135	dc00110dfcece910066e5e6da9701d4c1a68624514bec8fa7f9d296883ada51d	1316
136	74e81d7ec135c7b59324f2747df4f8e63426fd3bc1f540230b07a6a4280ac530	1340
137	44fc2c07da6f642260b1ca360226dc627b5fff3e6c7a9b9dbd5024119c7c5cd6	1353
138	98ae2392ebc98b719bc5c0871ca79e43a9cb28ec697a4b1b409be0b3eec55de3	1355
139	f8ab732ef2e66416e704b07edc4dae74233e58faaf59c680dea0622f941156ba	1357
140	a89b6d8a89921fbcde03afd92ec6b78c46a75365885f5a45de7bcc3639156fb5	1363
141	5fdb53f94928951f4b3709cfd6ca0723a9b8d8b16d8fb011b61287d1fba0dd30	1365
142	352ad9d25a2507a99a4a4a7516914c7aa5f85feb432afba7ded50c894d1f5811	1366
143	d0526b0e6796341972ecfdc02a360e2a9afaee71d95480519c4483c5669c3e76	1367
144	4e373d5af2d5f7d9a47b8cd400a332ad1d9855bfc8ff9b7f7ee0bc520aa49170	1372
145	eab8c9f7b16a7d1dadf0e31852e1374141d0c67b1d086258dd6b5dba17b70be8	1375
146	122b2fd9e66e8f87ee1bbe53e95be9d11315e1e6d74394ea02712785c58c30b3	1378
147	27a4df221103353e5dbddf5dea1bdb53d549c4ada1a10bae68cc3348a92bc579	1385
148	2785c0e99980f3c20611d049745879bbc5c7dce8be18d6ec5b6a2a3b83e757fa	1395
149	ee93b82624632993db72a70c4e4a6fef5bd4bb0bbde60f6adf1e0407b4572cc1	1410
150	dbacca577193304977187a342e2b038c5ebac0ae66cdf3c93f1517028c9ebf1c	1434
151	ea01683ae330b1b097b8fcacc4f625435334343ec9cba7a5f78c4474dd7c8991	1479
152	91b4f01f686749c900c2dd6d81606d6b7c978b410fbc5deb79b1774b715daf41	1509
153	a316c90ea7ac524003c030c906aec94b214aaca3e4f1b07347f9b59bb5fa0593	1520
154	7ccaf7225c2b063a5d94133cabc432918b89c9938239e05bbcd0490861a4795f	1526
155	f326e5fec6ce5aab3d70d624d60a93545a171244dfa9e308374c965e1c6d3dc6	1527
156	720d67c3e4b678a8b358f2b40f12b2f8c9a6ec1a63fa9d1ef847b87e4661224a	1538
157	b4f5b4d1ac081fd24af7745fc9878b6587dfe61a325ef3ba573f253a4e01c971	1545
158	843431f87299a8ce62900e60c0788a640e35b9a3a55ff893aa78d97862a4080a	1547
159	b3458b0452605eae2551745e470209877c4fafddab213e0125e2f44dbf73f1da	1550
160	976a56118cc0e3284f51ea34464ec00b816cb5b68b93797f19ffea16e1dc34f7	1557
161	5918741807ecca246f92b71ff8969c1f54522fbf0cf92c17693d27e3ef14924c	1590
162	43bd4fb33cffbac8f9c689bd0a6056cc2f2551f0fb06cb4ad72a7cfcd96ab8f3	1605
163	ec8a13bf3d943437a1cd2a5b553286ca2d9587ffea79932da86a4aabac7aa02a	1607
164	d7f80f27e6f156fc06d5feed39c3e548e2555a65cf8e8cd2d0a7e3bb620197e7	1618
165	df750168fc4cc098dc7bb329ca10a503b22b8d826739ce36af1949fa297a487e	1670
166	6e3d19c2d451677cbb4e666499bf3e4600e25fa38e4897e3fe483b37c6c9b0c6	1701
167	e167e0aa7d07d6bd93355f47d1e184018ae8afeb22820407322c4c31ff6dfbf2	1712
168	22c4bfed643e7b4071f2db474ac4880cd5960dd1bdb04d965b96c45d93013faf	1752
169	73557fe846c9c42385392a42e839451841425438bf1c4656403c861ce16f1d97	1760
170	73abadeea1116949ffd0e21437567578da5d676d4224972e0b1422f22ddaa164	1782
171	901c9212dd49bda548e7df0771ff91c04ebe5d628a933a1142c6e154c7793960	1786
172	5e18974a773b1b874bb7f6496018c569622f8ba45bbd2c72868308ca5d6a5faf	1793
173	3177f3a67e0a5abf15b6847db12358011f0d45768bc9dd3ef3e3e40d3a4cbe4c	1797
174	6aaacf125cb05562225bfbf73dde8474cca5f3df1619fef8c47d070285cd51bc	1800
175	4371c69b675677c8bbbb621ff0dce16e6bd9d8f58f1f71579dd724f28fd31b50	1819
176	b3d02dda1f018f8296d8a62c219e5bd865e0a30f5e450b82a36d59aaaae1cd88	1865
177	9043815bbad480a2ff9005797b6c72bc386376bd30ab668c049caf519ae8c669	1883
178	b59a606f4fca413dfd6690814cca2aa97eade04cfe950a38612eb0d5033563c2	1892
179	050e1bed92a9fbd4d14745bb8584f71b0f3a0b1d7ef919a1dca69c2e72f805a7	1898
180	aed6300573ae775d4c4bbaf639a4e64cbd6de6aadc5b5be5db0a164b2ccab39f	1902
181	bf8bae95ee77ca734cf97579f88bd94c6902c22b7bb0d31a58a834c06ce78335	1917
182	e201786142c6deaa6e33880297775ea28276d8e9e717dbf1e64b5764ce84ad12	1920
183	23f976c3cacb871f477c4ab5eca8bdff41f155701304cc90dfeb34c1eb41c3b0	1942
184	5912d49ecbdfea7ffe34136584eb2579b4f1f972c2eb112e793c8793e6ccc6f8	1962
185	fc0c48a542c5393f3a2725117593223df27fa2b857d37c9d0d3631b605250eed	1964
186	1b6c874cfe3bfadd8151499e3127abddfc84888e450918c6edad53b8b0759f63	1994
187	5344b18714c101a5b61e090670294bb157f645c06dd0a855d36cd95e2fbfc7ea	1999
188	db5a9cb3f7e63fff3ada701a460f180d9128c76675a8cae2903030cbc608b58a	2005
189	ba21cdf5482af11e9fd3970c07fd99a0af65456a68d7fd423037f0122f4af596	2009
190	6a15eca042f9184a25bdb9892099a6edcc01af8488e03ea261df294516ce222c	2017
191	1728b5b726ca399e1ef335f445e48fc7735121ab113452c24e3b4baf3b205749	2019
192	503bd36887a5bedff28af72cfda718b00a37ffd20e2ac55691f28b19b1fcec2a	2024
193	36a30166a50edb2acdebba574cf48e49c7607280f1e99a6cfba17ea6d4e7c266	2025
194	bc9798f77521c79cbc76dcba1e84adc2b42a825a2f396ce13137a920f04cfb04	2045
195	9cf2df8e990fd6331cf96a4d076c99a4bd2b0bb5fd0172e5f1deefd9918e5de6	2049
196	533e37db3278a02f18c496afa06cffc3e9a048c1541af593144dd55d32bf2e35	2055
197	1b2d849fa5e8401d22c1860188f0ca49e4decc0b7dc2fa75eae20b7e756495e5	2062
198	eac236f29f4b55cc38169bf0396f4b679a3c8898a129f69c9a9fb10c4c4e254c	2079
199	1efe9f8403881af96e3fc00d4e69c82639a7f07c39fedfcd8677546c21c17c79	2094
200	caf4883fdbdc58f03b7615bace81a3c696cc3ab6b21ae0ee3a5df9a6e343a2cc	2102
201	29fd1de705bc57fb9a0c1a9cb94dd875a0ab9b3f9b1585152ad6f467e466e857	2111
202	4568442154294f8d251eb590ae476b5acee3a57889e62e512f64fa402e365d5c	2120
203	4a86be3ac5771a4cc81036aa18833d44337250adc7965c1b61f744206a2fc0ae	2125
204	fc8379421a72629f87caa7f0cfbcc8a91a60e179e9dfcb909585293d62edc25e	2130
205	e7931e6036c99a77566c99a7ad7c86392ac5fa2fb276d5db8396c53d1365b306	2143
206	7ee540394da43aa7efdbcb12cca03853bb72863abe43df2f5dbc6610364175f3	2145
207	6fb838bf259adad5b7daef4ba7e76b861c8a01b934c94369f001783424ebc28f	2163
208	a9c3a729d8e7979d8a03c3f8b38e5a57f64b2c69fa5730fb3af27027084e35c0	2168
209	d4cacf61e6ef93309b81c58d5132c73e89317771a8f224a6a1375de62323b2b0	2175
210	0fc47f12a1a441f1d9decae4fcf859314e8b4e36f67896edf1067cc272c5bb50	2180
211	0a64e034060d6af5723762e3f05f2a1e06b1472185ffb2e6366e1a265e819ed5	2187
212	f5ad34653dbec7a9760d120f29beebcdc573ce234a953868552cdbab9cdc730c	2200
213	07b97328bc6825cc303945a7c747f31b57cd09d74181b08efa0f6b67a035d8cb	2212
214	e51d0276c061e3460ca4c9f6ff71d72af2272030a87d02bc68fb75776cebdd5d	2248
215	f3cc00d1da6396f290b71e96b497488dc7121d2066ba920655aa8e5941d186e4	2252
216	0bdecfb76aaf87a984a8186d34af7cfd73d49db72771fe6a3a62a2bae0f7f13f	2257
217	d24b7250c7f5373edbb0ddd375d8f079ccc7adde2aae18d75649e3000b4339c7	2262
218	b3ae8b1727196625dc630da43013d733b25e788c9b377fa12ae5127478268b9b	2293
219	020c8e8d2dd9432a4e490d1346a84ac9ae309407f9be9aa5202876fb640b9f62	2295
220	779d635dec5df1fa8861befb5348c43010dcb523bb5005f46a2de349c3983022	2314
221	941db2241ae3b8795836208cb5fd40ff9535ed3fffaa9ce162388948c594d03d	2319
222	db69c19306cf495f2fd289a503aaf1b99538bd5ef2c58ba513516daf4b34a6af	2341
223	ceea524a0327806399476d4ff8fc85d833e7e59487ef986cafcce467b3087579	2348
224	c3a7c0edfc13b18e5d09f5657fd5dfcb883173b1e5893d7f668c583badfc3f87	2356
225	bff5cf709ff4b1930c994717b9af14f9cf918c4fcf24d0c55ff2aaf65c212a95	2360
226	bd14371046be3e1a18fc43749ee5590797106bd74e46084e335a02f2dadf3a0c	2365
227	4323bfc4f194dc25263c60129da3152e1bb51729428d55f843427da24b50e6d4	2381
228	0b0066fddc52114e92b62ff693c860d400bb5720f78f0060ae0272928db41feb	2383
229	b4f288dd7199e53788ea86cf54d44917b201492b5ee3e7444f21b9478cb62efb	2387
230	4cc2f91c96d4b6da248eddb743362e13b9ad24c1f0181d6750e7c4a4c6e276ff	2396
231	9254132b83d804a0df2de2d6bac30e61c731b81f83fa7b095d1c094553378a81	2411
232	4f48f87631c75655ff8346292ac2855176fc01230e66d8c3e83b7fcc60eab00c	2429
233	5c7b09f10a0f18cc07df9fb7c093032d242e94d4da0b155e8387000db7ce0073	2435
234	9afb8392d03366f2597551f9c4ed3dca63224e588558664f4e54e1a7488a2cf5	2442
235	cdcb1157637a43414531842688dca2da50469fd75d8af40e9a3a2cd49fefcd44	2459
236	1a58684b9af7413581b4c0ec73159cb169d152e1fa897404a55d9f261b367d49	2472
237	79170fa56c28f360bf08aac0764b45e300ab9c549376504ae71c85926a28deae	2485
238	5bf5ec67c95b4e407c7d589b81f5be6462f3f9f1d8f33e22b3a7d581f01d6621	2487
239	355480f397baaa55b7aa4133388a51c85a8c913b16e66cd09d1604f5eeff8c7b	2510
240	79976a92795da9f59aa5de5e81606a5b92aa1a4fa9236daf74aeffbf842b6d95	2514
241	b9b4c8a26a032a007305967b408393f4a8e4ac89f321515e72cd7fae208de0dc	2515
242	1b0a4f9fb53b5969f75ca3511fe845420a1589edfe05cc6754229d43665ad9f1	2519
243	1875bbb18ddc016173e5549ade9aa6ba45af3ffc9aaa671d5629e7a4ab62118d	2521
244	72ecd6330f3db4a224e7a6f1c9f93084d342e37506205c240b5841d41237211b	2522
245	d102423a5aa6c8bd05c0ffc6510b820d68a7ba2fb0125926d34d6a84f36a9b26	2524
246	762b6219700e08dab0cdfd741c56770c3f5aad1c45ffb392fd3911148487b6f1	2527
247	1b0dadf8389f1777d6d5b9995a8af9c3eba9f4aa4a6044a98875bb5b10335f9c	2531
248	d467d48a75024ed89d05e979c410a52aa2589e83ac5620b5dcb54e53f957b690	2560
249	6952785629da90cf2e0e97978f4cf65962a4205efca78b983b40d5de6dabfb4d	2571
250	fac5e7e0f8c98709ddfcb3021ccadd823f7c5d7e8ffe66689f780ae02b0b8a02	2591
251	676345a54dc362a1cf4e65d6797f46b5fe0c093a449a6d882145f3c6c5139bd0	2592
252	83d5cf42410690e0bac393f80648b14938c6a4dbc4b50779079ae686c6ef113e	2605
253	aa638d284cf43d5ad13386dc49deffa10a6f284f8e408d7557ab778ff9af9efa	2606
254	10b81387a92d22f968afa3263add8a272b6da9048a26bfbac54bc4abc017fd80	2612
255	4077ebfec990675eae99ed4c719d02a83ffe207a98afa90fb821f99359ba02a4	2620
256	4355fe6794b1a941da5d9af1ba54078477eded9acaf8113a62233d4f788704de	2627
257	98aa8ead3b1ab49a64509bfbb153927a996a64b03a2de28d9c83a0480cf658a5	2634
258	7c44a4c3a39ec628ff8bcc4d063eb20d01fc0aeb7356c0aa1dc751ed1199d1ac	2656
259	66ab3d7dda1a2c52e2965c44c99c59446c7b585ae5e91c09eb6e8a768cf5da91	2673
260	7d912f77504e5d8ee74ef8594c2113d009da8a7be58563baa413b2296366c40f	2679
261	b024949f50dd441e883db214d2e4cc9855dd35c070a3fcd06480b2f8f32f7fdb	2685
262	bf1e82f5d94ae44563e3801d46c61facf3f2ba1767619b40e0d47ff84fb87414	2706
263	ed62f47b87fd0e4ae682ea5848af07c7a23b5a3134744e55be8a5ba18220a491	2711
264	c4fbaa19fdcb77cc9ffc6a34882c577e4b71b92de2af12ec8da8debd3f792df2	2735
265	bc578da89a6d8d5113b94a8104ee1bf0b63a8a0d0f0f5b37798f2b899b1e09aa	2743
266	aeec54233d33880175c024c6acefa610cff037f9a99aa0deb25d616ad729a5e6	2774
267	5e548704ee066f8dbe95e7e9987dd2679d483f32813d545ce7088439f70bd612	2777
268	d876e3be1dcf87c61eba914548b45df287222152ec33dddcd1425a337c023c7f	2788
269	6dcdaf72ac442df7d9353b5a100cd4e9e68837cf230899fd807e6af3d671e9c3	2792
270	96f7c31afbd6b64d4d31dc7fccbc5d21faae04f79a7a2bf4a7a68b37e5519f75	2794
271	48e4e35d215d108991822826f14e57326e9702368b665145c315d95429edf64a	2802
272	76106df32f0a4663e5ab3a95842e20e7dfe014155ac8c051ee47987a4446e4da	2824
273	3d6589d50aaaa0b975fcd0e1a1c6cf2e8344f587d5d9f94d09d59275ce0bc780	2836
274	33def61d6ce55ad8e71dd57ea70e461571d0438973737a96b96649fb19f2aa21	2838
275	3cd0cef3062d92e606a7585c883463c00efc60e3f3a46386bb788a8e5f8f1735	2856
276	5acb482f09aff1d3cc71c240ea9df2927af0b602a1948054aa84a44f340ebc2f	2862
277	e14d3797aee817fa5f8c64d854fe2f58b2491fd3d0b78d49c3edcb33194ad6db	2878
278	36fe3db6220394c5899d9b2d2a38ad2fc24bc1f633e4f8c9850681fb67128636	2879
279	a959133cf4444a27d52fb72ceef8a623f143b8c88d72649a3a4c7b77613564db	2882
280	2f3c9655ddca1b32a94b946f102651e4c8d43601af28eff2776f3c7df6d0c3ee	2883
281	49e319a1f5951da9da4ee8a21cfa53528f3cf1eb155ba8f116c25c93b9fdff21	2892
282	be576dc60d44739e24cfdd939bb99c4e21cb32b0b74f81950d9bf0096ab8495a	2905
283	d0138a673afe589ef19f930f5e44dd0239e4bbab83574ce1bd5cddd8fa880bad	2913
284	c1d728d4403711861067de16e301968e805fb393e7fac457a4b535df8b606c19	2917
285	b05aa8f447cc70e21debd59db92b6a5968378a279c9922ecc191f0d49633b6b2	2969
286	ebc74ee60b2a16ca1715fb12e92df76ff0f0048de84b8e1a05003fdbcad61c16	2981
287	626f69877fdbb349339020641cc30af2e751ccaaf55bf21b577818820feeefa5	3003
288	8710ffb1c6e950c940ec1a4d02159da4f68af4958c64fe37bb629ebda6b345d6	3008
289	2868b18a21a49cc114048767df7c23e1513216eff1bed3c16f97699f2b84040a	3011
290	494fb2ec84c31224e7c868ca170b5c52e6b9a93d323dec3d0576b758dc6ef5b0	3016
291	8f563ed2076820fe8fabc9ba686aa7ab4e1664fb450dade18416b4e9433a5a93	3042
292	fecf195a9832ccf78509d133e7acffa37a96c83c084d8469e60f754f9c48531a	3050
293	2f0db9bb1867680eef059ec52a2b3cbcf46843751e89b80b568381ecfe0f083a	3118
294	c14f8388f007ccc446a0520c657bfc5276fa8b547a6652880065da8e8ec71453	3121
295	2a35f28a90ca327ed28031150ea5f64d7034b9fb4c3752409c54666de1cacca7	3128
296	e7e84161e17275a7f02b8237aacf592803d69bf2ba58160d726b78ef88820459	3133
297	15128934189242f1c643d49813d5eec1cac4d74a4f82b102af4f4277a97edf83	3138
298	43ef298fb37ce7be68f434333b979fade200e6aade8f62e26ad3d830c7c99dda	3139
299	c7e1f300d8b397711ba9928ff7ff7eb3acce00a9219ce3cb2dd466a58c3c9a49	3151
300	12d20d2d94cf427b75a45dc659e740e54d7a91929ad9de99c3903e40985d378f	3154
301	849506e3ceda0346a9bac177259d35fec1a330a80e351abefdfe50948f9a2ec2	3198
302	1e600462685b9ff8b6dd4a98aaf9e09c9ff9b69246cbbb8ef49dc85b5a8c4205	3201
303	8f462c0d6c4b2515c5fda69da2db2e44a2f22e30b42a22e1f26c7e2678a19ff5	3206
304	89eabc9f4c4039e97e218a1fb036087278e78be944a4d8193498d663a2179c47	3211
305	430035a998b493efb1f99e5e09a4eb3e8aaad999e75e10dcd0d44f58967b2004	3214
306	2bbec31a0d128799408d6ba18d09839869daeb663093f87bb0bdc0784894b2dc	3216
307	86b630b84beebac89153b22628e55606ca24f717aabf5a604114d53c9b657051	3219
308	9821caea0dfbcda6c1969b52e6c33e9219055b6bdf78949769f5230e3d278e02	3220
309	2d0a007bb7ea2595b4aa368948bb62b6235344c94230d8f12358211170d09147	3225
310	1fb56ed1dcbd2b95ff629c957b822a87b3724c9a0a4e6783c16bed2eee60b5cb	3253
311	815ac96c29203efc566fc1af3d0cd8a6e0dbceb8b684427d21104d33dd012f2d	3257
312	033a67fff287df1d675cc14e5ac8c482d6e88bf1ed911658d6eaea7a28ce24eb	3264
313	e7bd5fbcfc048301218248aa5714eeae05484a7246c8f1d0f9dd0344e3aa9657	3268
314	13a67c32703afda6b614f94dfc7bd91461a9f78facb90a935cf7553e91dccab9	3274
315	813d7708a52a6fa4e6b4a26c8cd8ad1d3caaba0e90962df92665df6fa69a13c7	3284
316	b484941a8b49213a01fb6f164ad1cf4e5e9865ca0cc9b3a0bd6564b73e650c72	3294
317	c3fa6cf424c29c451d9398d5746c8cafbe1942ff87a7f9aca114378b4c16c7e5	3301
318	7a83c7852f0cbd7b0bf38c696bfe0fe2081cfb9adabb4b140c255f25b6fe0b69	3320
319	ac07fbcedb78a8a39e8a54d4dd6e7030304f660c5cafc992ec7c23fb77cd9c37	3321
320	1f912972878dd6b154d85f8dd58af7bb2fe6f154311d58a583e751c3ad1b0858	3326
321	2d4143932a904344a92269e432c020554188056fa3afd58a533d12d938b05200	3340
322	630c927eb3ea6d028843dca4a76abdb5bd43a4eeb19aa7762c3b12e6d69d4722	3347
323	ecf16f0af88eb0425afd7fa3b36359323f39a427e70a109c268176723700dcf9	3359
324	46b12d01cd99ab62182e0cfe4656cd6a9df4e05bd9ea106b499a9936741907c0	3362
325	14c3c6917825f2032c8da8321827d3fcf5f84c4925d392a5b0850237c66617eb	3366
326	5651589e034abf3285e02ea89a57a391ac1bf4b433e1732b87925893424b628b	3367
327	e14c41f7ba1deff5a91c999f5bfa7a1c0674913e1394c8f081c1a77150880f7a	3373
328	c26729d174a7465cdf1c9334b51218befafd3c572e18cb93cefc510f1b4b07c6	3390
329	55ae93895a4af49964e996087a6e070e73d0e36fd432b879446c964448150b8a	3432
330	3754b6bd82e7fb2ba09ff27d3dc8dbfeb236678ff38cfb815a728f173bedf15d	3434
331	7474e73a85a11a4b3b1453b3e134adf68b0d611b15a8c527a627a8cb38107337	3436
332	ec8a5737519898d4b28e1cd97128d3f4262cb97522a159f0d37f4293171284a9	3437
333	52588d58cdbd219c2f25fd997499699ef94fe24a5941c75ec99baef44a4da29c	3439
334	a27bb900eb476e4d7e95b8a03df95ec6726d80da6fb21242dfc3e0f728d45fcc	3458
335	750d8f0857dc1d7a50eb1236833cddd0c8408678a1bd10673aecde5c0967a803	3465
336	7a562d5864c50f713ba32be45b3fdfdc51fb186594af8f96ca7e2b3b5570b9cc	3482
337	90032b2d8d6871a14b909579ccc1238f8bfc24e830837019dd378324eb4b7da0	3491
338	c61be2ac15df4929b8ce4fd9bc5355110fac93cd08703f46c33cc1c158bb42e1	3506
339	0c5c47dced55ba361ed7ce3d7dcac588586eb91b3c6a8e9d36cd604e93cb7c31	3521
340	ee394fe05833bdcb016b67d41c4a636179f724173b95b1ee6098c7827c11e12a	3540
341	dc96431025b371be0d783c0b321282c03d5f55fcc2eead884ce78b4664cf013d	3541
342	895c9c8e87c10661c6c610e04b66339b56069028b5884273c67d8329b44e369f	3554
343	9444ca7b5ee0778e34d0f43639325cf49e90867bf09fad64409b53f37a9a9cfd	3563
344	4ca8b7ac85393a48beb0e301510e273c6f58453d65eb86bbc0b64ecf2cbb3415	3569
345	c9dd3d22c5e095b684973d6b6f221e9db64f5444d80964cab08d193286880ed9	3573
346	03d9ffb99b61ffca6f8cb700c4ab631c3c1bd0dcf50916b3a0ff2ea822de37d1	3600
347	6eea5b92e1a048d33f2950d763752a5f80dd874e8ad6f8a67a34af083e206abf	3608
348	9878018e4bd7ed31e7995a33908b7cbb4a23c263134a68cd19c18cddf4c8096a	3615
349	e9350a4065325ef755231fd433eafad928f92b7cf5ea4e04309184abfe5e992c	3617
350	00d18d69c1666a5175854b7b9686f9e6ba1804b4657e6a970162d93d0cc4ee24	3621
351	11926d5f6a05214501fa7b1cb7704efdba0415042d807a0641d3f0f1f5c1e30c	3628
352	5c2f533c815431494934c8b3f2c812a1ce881e162a3b31852ead41f507c9e2ac	3633
353	9635d43e5d24774885d66fe83ea95a5c344230de6b8921408ec2e40943964e17	3636
354	4450d62bcccacc7ab8419ae7ce75a72988288460f591e2e0af019a2e4b83164d	3643
355	b8ac334e52564c0ba166db1b305355dec1219896c3c8dcad0f061f96098d7c3d	3663
356	23b0c5ad0c0ad0fb8ac82ea44f1e54313c373cf51068307728d1641a2f318774	3666
357	af4371ffa66707d357c64a98807833df27c1cb8fb89e51ef74f285218fea71a9	3668
358	93119ca7b751342b706342d18646ffc6e0997f39ef3c23efc861ff0179a39c35	3671
359	18984cdaf4d39b3c431ab48f67612e22c7c8bdbba32c9eeb99b6ac373f7f9ad8	3682
360	7f2d8b3f9fac07afc39575f4de9d8b38f4a20811040b50925200c8bdfe1129c9	3705
361	27600d5b2c43453bc1515c36251001fe8d91e1bcbc340e1d4f6f11b3984a37b2	3715
362	b5d9a3f745c59484dd564a6e7be4c1ad90c6d108ee6dbd2500c3aea5cd0ea0c7	3721
363	5514e3c0e3d7e4845c95eefdb65fc1d5f380aa352b60adb0eddc35e6becf7f15	3722
364	730db85eda53d474274799f0c8779509d438be04e795ad6f9f3a84e63b910e09	3732
365	f457c49388665f42c1ef05678a3b136aa30db27916c3103f700ad4fcfdb45dde	3742
366	382212fa6717f1c3e7ef7b1c6e34aa763b38c14a93b89624868dcab325f6fe3c	3749
367	0a36376d79cd691696a0c67a6d4c53962a0a6d90646d51651c9cdaefa3d9bf60	3759
368	f2807fbf05b80ccb728952d06b2a33d04e2c73d3e969b68c540f9eb573fcc40d	3760
369	cccdcd042d1f42923de34b29539adc0c1bf28246c9f1b5444de20d92d570014c	3769
370	f1c8f1c7e1dd6f5fc3bfbcdec0feef1d9e03deb809e0d814326d455815e08823	3777
371	58fb616e6531b76da3d8cebd20b00d9bb2782f397d1f14b66d7eecf6190d0680	3786
372	13c57989837b13537b273cf32c6c1c077cb16076d751be18d63b0b3f324358ad	3795
373	85305cca3155d32120e6a4c23dd76f1430827e2fd56f7b9b50f65c72571c4a40	3800
374	dc21501d4a477754b945bb31ea3ea11a5828cfcb8ef8443dc1b8d309e9d35ad4	3802
375	ed937d7c58b6bca7a67a15f2dda136dc51f259b0769156379249b1cb87f61c51	3809
376	940dc2d9d9ce37de206fa2b25f6ac87be37c569c97a28b731066e9a8d2ecc8da	3831
377	b5a62158e0b1fd047557dc76b9e3fd90c914ee018129a8e9640caede2a5350c7	3834
378	75471c2b7a190c3d24c668818224cab8070c33a055c641a0a5b65d6375d9a617	3838
379	195e401025b11cd660fd4f04396e6b6326b05f32c2e1d630cd035d2c810f7c29	3839
380	8cb2b08c2e0d9fe72e02fb05ad278fab2761594a6f47c291b7c2919166026674	3841
381	8d1eeab7eb4ed5bdb7489696a6b1d0dbcbbd5e1207a43afa5dc6cf69ba4230ec	3850
382	a8f2fdfeb081feea0d582c79ba78ceaa6eb5241e0ed045af16c76a24fcc81f34	3893
383	7c0b281e4e8d7edbd81a6e513105c9bca50767e8c4af5fd61fdd1371d0039d3d	3904
384	ab5d7fb54330f4ba3cd7303f807e2a3f5306a7b4dea656203a7ae701bd49392a	3906
385	3c795452a756943e2b9249d386bbc479f370f369bbf97e6468a7282e38371e5d	3912
386	ce416706da7bbc86eae23b8f6b57b9fccf41333dc8864ea14986ea42c2c2d7e9	3928
387	c2cc986451a541950e266b2d7fda1c6e029be7716464ae2b1c7d2f625b640890	3945
388	e3cf9a5cacb749cfeae52672131f2b4d9208dabce230edea7ed632e5a9eb8e48	3961
389	5c0616bb03c89f1d0ddf8b5271ec15b1858026f51e255eff9ba01921a0ceb7c3	3963
390	a427f599da3fed56eff5a3f0949d09adc2fa0a3ed7bea359c64e8d6f6abb2189	3970
391	552fd111310a258bae93f5fcbbede4cbfed4aa4eeb0c71ec856a1414d8501338	3976
392	69c2a3ce5ecee43dfde15e5e1c4625954c3b7646b6af9a55640de5ae4a0753f8	3985
393	81f6991752b67e89f52a98860c40b82a8d4234fd200469722b8b44e2fb41da0b	4006
394	c1a034387311a14a87676c67c68f7d16f04471be7cf7c724ab7e26b271e8a4da	4034
395	3c662d327b677da380b5ec317171b7e8e7206417e29a33f399ebe4b21b3add1f	4037
396	51cf9cbb78c0d1c268f2043d65a51efcb47f898c464b3652bf8085c95d14ad26	4066
397	5ef14811adaf1b819fc3ff2d7c1a38b47b952da1609220729d51217c4c14dd6b	4072
398	362049433bc2f1656c7332d86f8d412e133c929bac5a14acf5e563917623b116	4079
399	a9fdf935f3bbafc0399309c0816c2d706df08f06c982472810324f13876a3809	4086
400	b7ad585aacae76a514fae5dedd1b8dabcfe0a585290dc55598f2328d0814b29a	4108
401	250e20a3d8c6e757e664ab7430daea381588c1ce473ba45f907737d51fed35bf	4111
402	1c94c01a8ee49b733497ea43bf0903fa8d273a159a6626db7b9d9fe8b8fe1115	4121
403	edb9f30614748bc35ae4623de01c179467cda4801afd58b9a689dfbfc5b26591	4126
404	98340630eac847251ee17b66218504a56a6474e9cfcd654cae0e80e45d7e57a7	4130
405	ab4f4c689f320f85bcc12c56ea4e3c75455a4f813608fb5ed1f23962f0231cdd	4138
406	76cc6235171933231d3f93cddc43f993b808a08f5b2aeb91797fd7c4351cb8c0	4201
407	a73a3b901c5c6f31926a2d8dcb7903440dc791636ce8a6fa85466e806d8ec3cc	4217
408	5c1adfb345182be517f0d59bd45e03df6d7171de52b5004491aab0835def9873	4226
409	8f6cb55c7b927984b9f5ab5bb1e1d1f12e3abf404c6f447bdc94f322cf2db4fc	4227
410	7bfdb2aaf37343996c2e516e924e27bd0ed3479df4224fd3bedd55ee91506e91	4241
411	e9a256db619333c73bef243ffb5d5abd6dfdf5d232bcbed64b27252cf4647f3d	4242
412	1fbabcd8f71b01bc793c750506bfb4ae21353b3de483c03f8d48124c38b83229	4259
413	3248f8f149f69e2ec8ebbfdb59e7c35870a68c652b0d0181d39d23b956407bf2	4285
414	67b2b76749f270af8349b3f3c50a0975b988d55fc17269965b6c52371bc91642	4307
415	6472084367f4a0f483cf26375bb52e5d4a304236766f4ceeaadec24a1e19c54b	4312
416	1e897b0b73930fde6196681ce53936ef6edb8306a1f99bdb6308e49228538a36	4313
417	bec2e6dd27ed29a8288db3943af8de60e1958c9887dd4ce0f4e086a933d406db	4321
418	dc5a1fc403d0a68739484218d1a19c89e7beff2c6c76a18119b86c6a7e3af1a0	4334
419	fb538be8bafedb07d0ec573991b8cf631db2448b50c086fd2dd449cbc89dd9f1	4343
420	3ece123d5ec0f3f4cb3e6aeeb9886ff7a34d7cca4b2d34bd9e802e1c7fdc1715	4346
421	100acc13fe73b633ffddbbd44e318cf003dba0721f7d788ef9ba127fb80089ee	4354
422	5f0b6b6b8353cf531a6ff69048b06edb627862fa9800633eea67d1ce4fc624dc	4361
423	4e39724f70570d4208b07c6af732d02729792d5a443fe9fbb7d3a2406fd0c011	4362
424	c44141c9d8d87c596395612a0cc09ab1073312ec5c7dbc1629c3ffa502668146	4368
425	a1e2d8fb1bbee0117f4c4551c0b6de552d25d5d3e1893f23e0d29fed838ce786	4372
426	d3e744b527bf0e1deb21dbe4b9c1e63f84e99a97ae7cc998cf3ce46d1096a7d0	4381
427	0ff7e9c309654a2f4c50db9d4fdfa094fac96824f84590e8c1bd35321a5df059	4384
428	ebaeaa43587d12d803d2796b3a34238ed6b9c15f132c3cb300e3cb3f3ac17298	4394
429	a1188041593524e27beecd45a37f4382f949546e4c7fad3c68065255092022bd	4414
430	b379ee1a756e93316572e36b7a8dd9ef75aecc5f5d730a1f5f2adfa1e005863d	4419
431	a436dc9c5ef7dcba780676c1563b61adca51129ce6c287f3364f3ac05d34680b	4424
432	033169e6b6a25d79b313e86717cb6143d90f58eab5040728eb49a5a283c6a4eb	4426
433	19c907be265676dad484d2f20669d7370e40541d014f220aa93f8a6e5cf46761	4443
434	82492bc88274f59f636b4c035fb3ad6211324c00cdb9e156a91e2b594f2de9f2	4458
435	3a7952d7b3d74451f0c44d10679195efa92563dd305b060e32a8b156686100b0	4473
436	f1db2bbbe189503fae5ae84f46ea09d249332c0995df85f9e4adbb7e988f2621	4487
437	ea339a6e20ade0472f1a61f14779290c8728032eac7816c52a196889ca2be657	4492
438	1edb67973f0103d2bcb23460a7d198a87a600b6b92d481618b19fb74dc09c1a5	4497
439	1b4530fd20be9aa0935bf27a2b0f23f72a9e641667b2dc49ae122c405271314d	4500
440	54d4524c28cdfe3a68588585b9349cb54295492bbd74d6ed5157e2be953810f5	4503
441	dc4861a0611e72c0d3911e73868de90e383a095866371ead27509ef3fc687376	4511
442	ab0249c74a5a1d6000a067481fb0c635c1211d14249e75c08519c4b04de939dd	4518
443	561db209de8d450cdf73f2201580628d079cb3eebf59926e88d3594f2cbb73a1	4522
444	916ea0da06683cd01d33f087da5d97e42e2175331dc685f4a231dc661e04313c	4525
445	590514a8bda1051c17c7dc75f82267ebee37a8c5b3f29339034b2ca4b594c4f6	4536
446	4f2bfea81c87626a68b3937352a808240cce023c876b8c012157de7cf0912bd4	4560
447	b888e4b8d13cc941fbe0c5060ae0589671cbc9a332a02a4a2372a647cf95c0b6	4563
448	c3f1e59c27209d08d16d1fb5bb861922cb38794d4b0a2f0f610b24538ad5f10a	4568
449	c9cdb3e71ca6b31b567886423fda76060917b5169105ff13b87fc8381ee110ba	4590
450	7f46eba3794a50c337ecb7fc1d7901c3460323904d4f3001743156394438a57c	4598
451	f0960433f51501ef0debe820d89534e0106f52ddb1d6422985d63ba98420312c	4604
452	d3ddc21c50c6308674595828a2ca8e1c25d150f763addc7ee71f1cbb29765bfc	4609
453	586706fdb1240de15600b91efe5a8241783fea32a9c9cfcb672693589a299e49	4625
454	4d7e306aefb6b921bae5aa79465e47b179fb0352ac16d19179be3cf9248ece08	4642
455	756971ca6a2092714e090e704e2636ab1328b2b1c580b037f7c70021d38756f6	4661
456	6acaa0d74073fc52468c8623726aa6970da575a64c70c01c77f557a280bca12b	4669
457	c6142e47268bff89cd8fcb4d3cf089c3fdcf45c1b2270b3ea901530e9e9561e1	4681
458	725c4b1ea8344f8018669cd748fff860a458f8f691e641a8eb1d8824322939e1	4686
459	2ec7be4bccbdff1c41fe5c2f3b181b59e56c674bc30569cb3fafc5267ef912d5	4688
460	0745de3ad21c720b161f832d4d39fe402fda06fd607537619b7bacfd50b9487f	4691
461	b92b176bd61a6d6b1a6609e73951c0308d6bc64d8136006d4659ad5d9fdf668c	4704
462	501c61f903f170b81d278d7b0fdd4c3fc3560836beb3f80971c6bc44898efc3f	4723
463	df199f75f5eb5b1cedf2f989fc83f21aa95fde62ee22189ee043db2d0aa83100	4724
464	60dfbd19b09c78303aff4993d4ab4f168b6e4eb341b1c696a0eff02471559d9d	4733
465	bd45cf8bdfe9a0994ddbcd8a60b464e7bf42bf44f71726f6ecc2e58eea692d1d	4761
466	7deb36d52e6155ae85c844577129e84f85fe3527a01c2fa95995a00c287fa4e7	4763
467	63da2c05c80ae6d840f707d653ddabc3a56dbc00dac0053549fa8cbe56383dbb	4775
468	82eaa326539e54bc0a54ac66baa695fef0b6b3f6ad610ac02c9c2b3f138a5e3d	4780
469	401ad17bf8f05d5f3f14b7e4c061aa2b6f4d402ec2cb628b8308077f836c4b4c	4781
470	0a6af7abc7295753a79b56447ad22b0e1c1c2112fef021822948b595ff934245	4786
471	abbd4150accf039f4cb75e600619b68601b01189970659bb187a10fa3e49e805	4798
472	ce2b2b88fc8ab6b40b5d9b970950600e90f8252593a9b2dc76fc554a50474428	4811
473	dd2d09c8409120c84a5d9e05755faac0446288f86a1f01407d0a3f98f0336c7b	4812
474	109670df450e7bd4080f0286d8757701c5c786562ae3e68d21a6774598e1f705	4827
475	90310ea8b13eaa3c8c5ac7a61e89b65909b6f0547b089ae15bd20fc2949a99f0	4829
476	bf629b6a6ff27198b7bfbb0106a5f29a162b53c549113925fbab854bd9ffb0ca	4844
477	96fd860937e41d5c52e5ee56a44015134c3cfaeed4a37510cb35b78855635359	4845
478	42c4288d17b9b24e5356d83fea5c1ee0afdf0af826a4319da88ebc676b7a2a0e	4847
479	3ea630eacff4534609ff01424857fa9d215dc0884a1b4aeeb08d9c899e8a0a1d	4875
480	0978c8a32e7c206a222b7db3a83ad9346b96290c593e431bd07ae98e367ddaab	4883
481	f533a19f1c011fef6d9ed9284a968e34b2b614ce346307a9f3b5a58cbb8c9d69	4885
482	9fe8ab0f118cc5a480ff240de4432f123810b85892025f13b04b9bbb7ed0232e	4910
483	acdae2870d1b3815059b0a402169dd3c8b7761c69122d34f80e40090f94c3f04	4914
484	560a35e774608b63373a4b6f3c0f64db76c3201b7818e5dac1f299ed05eede98	4943
485	b94973f63500fb4f3a00448028c7572b8b3e6a444b87e4b7413d0bc4445ec60b	4945
486	04871fd0784e0b546ba0b13815f4f666612a61e41a40a5d79aa4aa2b50c33693	4980
487	9796ceaf5f86358c3082ea3459eecaf329b4ad63df426b4727a935a68dea3f17	5011
488	2e459f47b44e5f77ff1bef919c6186ec053375107c0f1e990625939e36bcef1f	5020
489	00a81c14373e17558183794ca3abe2ee11c67b6aa2beef3358bca227939c5e9d	5067
490	58460a60fa72de00239c0948b759be86d8d08987f9e0792ab182103a57c9a7f2	5068
491	819be4a6e0d12630358bfbf4c44a14b6780c45d0ae12f4fa03cca81f983d5a52	5076
492	9e5bfbecea4eec9ce3bb1b6e6c544b071bb744b92c3f2196b6dce7a54f0448f4	5088
493	85c2da0b620c0958ac98ec3de13e673cb534d012d2eda40309fddeb2f9cf3aa1	5091
494	60dd02217007c2d0a16574bf01622c46945822145d551f45d7f057d3fc5ea438	5104
495	17fb620608e8792419d1bd1a624ce6f67c44cd47aaa51a199f98fd6ac6d42798	5114
496	a33d7cdf81d1d8cce2b77b1b92e0873976eb6553f37d0b59aeac431bd6e679a9	5163
497	dcbb07b73b9cc333148089db57cfe73ead6c2376d2001625198c00a0e3f7e1eb	5168
498	be082b066fe41d1f418eb7570ae365f46988e8afe9f597fab02d96b8d74760bd	5177
499	f38f7c48e213e8e0ea66be9b79be73abb264cfc9ae8b9d48b4c744a8a98e5b6c	5202
500	9c392e788e4491b1b5431ea61c359a920706fb1c13d7454374d82440c67dd169	5207
501	5b41649639c505447e60f2b7eb3aac204e488833a4eb43470599320b5d3a0f36	5227
502	daf2280d40c032e857010d9367fd01a7cd530eb7be3cf986ce3a9cc1a383cb37	5255
503	f12c3f2d7fda24ea25d99a58697b1a532588521d47689507bc899716955648ca	5271
504	f19728f3909a3be3a1e5e06912c01406c8559d559163e241b7a44f7e8a662c4a	5279
505	35f657284cc8d85fcffd13352c2e2bfbe1ef97eac5e15916e17f99e4056b1a5b	5284
506	e3de1c9b6b9bcddf75d8e7ba3e31c6d84d0193aabaee1953c3988a2d6c1f561c	5302
507	b23588f2ad050a930aaf93f8246d4aa9af3c7bf6d3215f80b97f5e8b2c170fdc	5316
508	45157676a0c5eb536d977a852047d1c5bb99d4796676ecf72eb1da95a8b4df29	5332
509	3f67d2760720cceb5386748ad64b1a0ba85f8af0c8c2abc752ff8452434b6a2c	5336
510	47b97fe9a0287abf270f38f9849b3dc8fac38bbf73f517c2928b28b25e5e8d2c	5357
511	eb0b0cb5bbe33481731e0fdef973a1b9565bb7769a7ec00a2250eadd1c4b936e	5377
512	7788257962c4840ba77d9bd897bbfaa9ccbdc49a203458eff24758d5bb34c8c9	5394
513	0c65a389e4198fd55c881a71f7e95dbfb524cd53d960a9909bceb12be1fd980d	5396
514	615be3706049aa22452ea8b26e6aa7ef66d525b29decd99c1741a5146decac6c	5399
515	f724b845866f71b30b9a7c132d786a940c9fa5d8c69b4b687bd53ff4d11e0696	5408
516	e6c58ef8f82a6ccaba015214faeaad1e50abdc996c1dfe564f7327508ac5b080	5410
517	f8c81de6af5545d28c47e04e10e6269f9d0d3c66a32b91eb8591fe91977e89c1	5412
518	140fdb60459834cc3bc77cf44f35ee9c51a909205236c127b8b8c019b489b4cf	5414
519	b90b636df50a94696d99656c9a205e435d355b6f7fd4018a8ef69eccb3287962	5420
520	885dbbc3a6d27c5a71e68f2f90c5aca32316427bd7e3ecf9dfaca2cf48b4b872	5422
521	eb248f9c21f92b915a137607374fb47310b3e0585199b5eed7b2a33648a311af	5437
522	5de3fd5b69b4d1fe2b7237cdeeb08c047c9ee2ac92f9a4aa3f78b6de5b3e7e4e	5467
523	f254f568e7f75f1cf1a6655952a82f0489abd29846443acd792146ff23c20236	5478
524	f50fcb8b3d8c7303284b3b079e8d972ea723ed760e570eda60e6464d7bc051eb	5499
525	b10123ce1311b6875f3762c37b3f7f525aaf71575dfde1a623486d2406608017	5500
526	590f41f700e266e744099f8b216921c22ff0607b28ac482a6417b775921af481	5505
527	43575924c8db5e74bd9584c7706dbbb1337cf268a73d0f2ecfb5610378fd2f87	5508
528	c86872290162c1a687920b9b6016ac3e44bf20cc4e8b6f85c74a18bf2989fae2	5514
529	a3fc268ad575c22bc5a8df1b653b284d7ca89fb218a41484d89ad80813a978fa	5517
530	6a9225482ab7614fb6a854781d6dde9ada3318eceaa4c88232c447edd0293316	5522
531	45038a320e0175491f2ee5de804c7b9aa44eae7ffe3ba770bf5400cbf7cec461	5538
532	1bce20f8d9d81d8ca7c6fc346316b77ef3c57a4f8d4e0bfd9e1f2b489ad26f0b	5561
533	da2cbc1d97dc3e922ea419523df98322f941c4bad33872cb1ecac6b5efc42e32	5562
534	758ce3a58fac0092ece1f67c3f1a7bd5871d4b4404b8a7e35cb3d8d893d6022a	5567
535	0767b8e5f0863175fe5eead28dc19c04d11f8edaea23330a66045b695b607ffa	5569
536	51af705b77666a572cbf279873f3e38dd2d5426b7e35d8b43c718e1bb2dcb2e2	5590
537	b8715eb89ad1aac2818e67d85fc5f82aa5b9f1e6a5026d50d6762b6fcd5229c0	5592
538	6372e773142377c905743bc4dc082027ea0efafd915cf346469b6dc183c07c39	5595
539	c0b4e2a54463382a5acd86b5c97d878d1f11e3238c7f92fa63942119cc61deca	5628
540	39bffac68892255285207281c91f4bd0e64fcccf233f3595528adec6926b20a7	5631
541	3017d20a47690989be2b93c190a8997a888389e546dd0b714a0ee08111f7181d	5634
542	c1406f998f3a466690427727167e9895e5c071d16534b6d766cf1ed48962bf55	5639
543	31bf7957ed23c997d1dcd94732a9ccf50669bbcae8cd85cb6636885b05dde31b	5643
544	e00789caa916a7046d04e989044e33de698aad5ddeeec1434bc9060185240a0b	5650
545	103b3762ae41ba7c9a39efc8980c4b1075f9112606d38af900a999f7a7749c65	5658
546	3d1dca22ed4c524927dfa787ec6e18d023010e559c1a79f35511cd9abd12b041	5664
547	ccc9891ade736ef885192909628962370b47df7c0e06cc311bbd0b0f522e03c3	5674
548	e98cf2fd242873c9a49078bd6c4e1b76af4cdcf78bf5d6db69f32364165cddf6	5675
549	ba672b8841b098151f9156342e41aeec5d722db63fc1a1ef318dd263acb090e5	5677
550	c0ef4876f4d21997405e190013a0f0864a3df6a8e9ca6031c26edb8b0f80cd23	5684
551	da353b6655edfa1a478e297f8a1a126cfc4688ca1f9e92fbe10c45971a4e1edf	5694
552	20f624c0b75e8cb4b7da155c704e25ea9e4795c9a3e3c5baa35971d9ed11c875	5697
553	c1144d6e630044a7fbae856123caa569a572e50b06e4f2ad4d245f9411fbf20a	5698
554	bfa647b4f1abdaea3f70abd9c379972fa60b867be92b7556b322b8ae64d05c63	5700
555	1308cbb1bee23da89b2fb939b6c8e126233eef54d1aaadafd920a9b5704a1ec7	5701
556	44e010accfc86548981b1597f12a40476e58068896232d9b2574eba91e0b94eb	5711
557	ee25ed5f0454b0bfe4882923361f528551e401bad195253b533726d7a18d9510	5739
558	42aa0a93ff73e3ad90f213219e5bb6ced328c616fd9120d362d2c71a2ce41726	5740
559	6c55c2e704ae10b88266cd5ef966307df84b9b02398e4c409e21e72e6f4c94b6	5741
560	f25a3694cdbe979d13f10f164a3d10613f2aaf95b0c8ec2c355f76eacff3f7db	5756
561	ee5acba22544e9c3ba3a62e90f5fb683a3b61d4cac222d29476e22ec98912ced	5765
562	395c820427e5a425e0e32d563533d426d29b6c523ac4da9f5d7533f96be262c8	5772
563	c250f4748cd1d3d35f842b574b22d23b124deeb0f01e9a3f131ac64c408fda27	5780
564	49c17e15a17218758cb86c331b63841c9befb47aaaea3abb8bf741d2420a2193	5810
565	1c872ceaa14561adbd346ce3f4f7f4c8b781b68aadfcaf9f8ef85ad969a8d8a2	5831
566	7b105f7f79771dce3f46bf65160bfe5139c0a29ce29d5c38197c5955bde7b66e	5846
567	dd1ba9cb58d7e8a6b410db7cbee47f12250aa4505c79d4fad57fb5a803c5b493	5855
568	a1cade44277bd41a44df406eee2142e3c9f76c0565030260b9832872f209a6fe	5864
569	3a3042d48a671ecaddc29f6c49fc4f5ad8481ac9faad03f7e70e946cec311085	5874
570	1746f58314560ff85f078baf16f1758c34475dbb35ddb556f2ba54ec20f79b1d	5879
571	73ced2215d0be0adec6c6da8ef26a3f606f4b76186d54097d36b91cad2171bdc	5882
572	5516593f307cd13ef2a37c3d924c68cc912707ff5fc94016a5605d5dfd63b50f	5883
573	a3c5bca9a801644833852aa4df5c02fb6b547cbcfa35d1efa78755f6c75dd6c2	5890
574	7cb23cead923fe4adc78710d2ca31321acf5efc406f8a2345b86da36d9eb13a9	5900
575	1ee8ac149aa9f4e198523630dbee30075aa366a9cb5f239f3ac7e4044f0903e6	5964
576	d64748a535862aff923d913fe2866a68058bd81109ed416691b40d94bb014d36	5975
577	22fb9fa9bc93ff99030b544533b633c1497c84cba56ba4c50b0d9fac29fbf61f	5976
578	68eb9a764a292774c4aefe6013eafc8b881857a52e247b45bb4ebc7e35f60ec5	5984
579	2308407ec7cf2ace218f1a70a0e666ac71ff39e260c38a45fdce06cbc38cce9d	5986
580	bc90fead6642ce4fddf456bc2b5ff57e6e5476f324df3dd1e6eb62b0ebbdf1e8	6025
581	35a10a937aa39f6e48d88e34b9983022120f4ac1c91e6a105625b509dd37f58c	6045
582	caa4356c5010aa60d65de61de4238505a2110cbb99a24adc51f178dd06bbf4c4	6065
583	6b713b8cb0f79563bdb06ae47454159a9216899b8afe24f89a231ca7b7ed39a4	6066
584	e4c78cee58af3fd1699f9012045163b4e3014afa3a2369143da655f0d531c31d	6076
585	d19630a41e976bc220de41d918116b88d998a306d1895c7b2964cd5f04d81e1e	6101
586	d7409cbf33d2cfd02dfc812a9545d4ed871ff240dabdafc8e5f804a089b7087b	6104
587	e0ef52a4e74bd3cb3a11ec361cac5b7f2b54bb0ea82e510491afd065e6fecce4	6117
588	6a1a1f42119d77ba232d076a9837ac1c2028fb2ea057b7e62fbaa5fb63264499	6121
589	c180a1f3354f04dbad21f305f98d786013652df4e56ce866238e9b5bdc4f981c	6125
590	6470f0f202bc815cb90451f26a2df1d108d0ba293bbb19a1905e1cc6fa59a0ec	6130
591	142ba5ee3307b3e6160eeaea4d6819ff52e278345f8dffb5cfe714f55a337d88	6131
592	b7a521820be90982f1ad5f9d401d13bbcf2aa282f66d3d782256243065f6d84e	6140
593	9ed46db121f12e90176b57af4b0eacfc549f0d5fef06cccfd0dd0b0c3560707f	6141
594	56d085c73e5751cf56482f7093081cc22ee157d475e7efe3de4cad9e845525f5	6149
595	ddff212c9f1c912a74f63a96f56e36a4b843729864dfccbc22997af8975ae27e	6188
596	bb9acf7c80bd000b41b5b1d945ef5a93d556b5943b6ac4998bfe84c780681f84	6195
597	7bf32fbfe14538d9688b9c649e53e4b3354ee3a7c850405873da88cfac7b2bbf	6229
598	0589e4459339d7314276af6fb3af4b784666f11dc3636878b974221eb79edb69	6236
599	6c0d0b72d727ac1d49ae99b916dfb61920342aff8d43192d78f42f09e386b953	6237
600	b46b25be546aaa6ebd16a9334edc9b74c381441e19d1e2d0d4013e73189aad9a	6238
601	546201ee0261d16e0dad19e82aa4913f478513e00ab5d4c3e81b4e79e62c122b	6240
602	6d2c5a34e99b9a56cfd8dbdc1c1893b49db9d5641f68d4adf0cc86d05ae36cb8	6243
603	d896624b9eb805944fd07399073f576f5738fbc74ee1d5ba0a142826aee7eb93	6245
604	80fcf38a55b9b52dd56922d522791f67b9c75034b7aa321f5e3097aeb2f54db3	6246
605	046c95c2269a48a88e3b2c90779b8b0b31fb1904db5c1645c635ad95928fd3db	6257
606	0e85562bb662424fd88ed2be3dc81a1809c391494ad3097748125a685c526c50	6260
607	f63fc391cca3efd0a052dc3c738ce1c19d20333721f810e08c23451acb02f799	6264
608	455b2494ff477c4e89d170627f280c712a72e39873de3acaa2551e9049b2f112	6274
609	fa5098f0c4e9a9be00fff5f38c658904f51ed7c04edea857edd26ba994b916ae	6285
610	b6890b2c8d4ac2274e9e56d61f94d418e43c8fc9f29cd5fa080b9f26464d7cf2	6292
611	2c3f220eedd0a14e51ce6c2cf44609c7ac14ef994535ea60d91b248a28e28fcd	6305
612	83485a0b573ed405d39d9cde22c5a4e1965edd227fdeb53e6ec231df5ea94a90	6312
613	8b391afb87869ff0c1bc109fca119f66b9e763a625524fd330c62d1377b98c89	6319
614	62bdc5fcc526f1940e75ad18d0c0af9b56355a13970722d805707888071e6497	6323
615	08316de8b0353207a6afad08c154c26c27dd515360aa72c0c3a7c20ffa93babf	6324
616	bcb64c10149be139a5e98ab6b04065b3fff39257c660966c274ed596d254d327	6339
617	3253ae6ab5c8158a32f91d32564daf73a4807e4018ffad271a97a586f491e6ad	6365
618	60c24800e3c2ad038eee231aface437ca61da43029b78837c3ba8f1bb570cc29	6366
619	c72b983dd8d8e8faa711a0ae60b663a3faa0e5d6f5c242f8dbc1f14c6c37bde5	6393
620	aa25ef1d13637a5cf4a410692b30fd422dbc2c436f16d89893b86b003cc414f6	6399
621	fc34e9644f9558bf59b55a6b17e75d058a4d1e2f28204dbbe7ef0d3b569bee99	6409
622	7e8a085aa3c229e1265f2701144897746587d1875ec04905c4c0f64116c5e29c	6421
623	67c1d775d319090b963d1118eda087d7e0e660c7ed76845609a23617002cbafa	6426
624	e642bab43dea255faba7a54997d06bb6dc27d094bf3922eaff752498f569e22f	6433
625	4d710dba07994982b02225c42d654aecbf41f764dbb4a7f4abe2473033c05414	6442
626	3cd83de8e160f3ab0c803b7857d331e10604384eb7b521354c83b5f4a2b9c062	6460
627	24666ae5d81b47331f833d57750dd6b822aa258970f9fda360087087baca23f8	6493
628	ad0fea5408250312451a579701a65930edaea47e40ef8413e3b1dbe4e11f3565	6498
629	517e3f195e0c43be35e5bd5bcb8eb9ff710f937e0e7ac35ed3d36ad596678659	6510
630	fd9805bbdec0b7e4a901c340f49128b444e39b86e7f0ec4a767792ddcadc6a98	6521
631	a2f766ee8aaf0ccecd7489ea13e3a08758d956399428b64682c6902ed0fde180	6524
632	6f6d5ebb35876b4a11cc50a22d36002bbc6c40b306700581d26fcbfd47ba8c01	6533
633	06ba0b66ff448b9e4d918dd2ad4483b357e1cbffb827dfa1d3a07e367671d831	6537
634	711bfe35894c34d92b8c611f22186214c821fe54d889b5e8ae342f473b090980	6554
635	f5382c41be3506bc14c4c03fe6a8a29b7bf86ab1ea832ad4c669bb846b542406	6567
636	e245012310dcc3d1640c4f5db04b608ffe30b580239b7fe4d552c92f32365544	6570
637	53eb235b2036fcbb0be4a96d7eeb7f62a1dc0214ba70b326ba275adaedf93236	6572
638	efab09096e4319c99126a98795cff653e70033c124e7331967d0dfa769677f74	6573
639	c9db0452374fc430831515424cafc9e62ac49aee0a00810fcc686824b710f2bc	6585
640	0d14eb73c92323b2200847b20ba9320b302fafca801f38dc5a55270f1459bc30	6593
641	deab45893498ea179c8a79ac5e41afe8bc7bb4920162818e5cba6e9e9a19af98	6594
642	0f1013a04ca8131fb90d00639472e3e640f19d748efa3e0b6f22ab6a7ea4346b	6600
643	3680dec1548f96f0d277d846902ce0f832b60b24fd54dac607ba0228bc9b05aa	6619
644	5456637387020843674b9406879f66e2436cf9b04f01e85067626ca223bf2fe5	6628
645	3c9daba64c85cd58062352a04739dcfba7a5666544724d7650958592c5b9eb71	6638
646	dad33bdd769eeda5dffb3f01aac848e4e665eb403cc1d8d143e3f5d39d520ba1	6643
647	5b63045969b27f6b748e84102a7b78b7a637458692b1c3d6f5d22ed7a57302c4	6653
648	4ae06372796aade6787168cc2d63e42f8d7cb80b6fb05908abbd3fea3dd85b8b	6677
649	ae759c68a620fc22ad06f31ec661c5ae68c367ad3113cef067cb3c6b9e13d8ed	6699
650	e05f52e14b7052075c15d27b513a4eedef15da32fdc04cd16eed2e84670af291	6710
651	2f35741d5b99608b50897c86aef986afe5b59737e0a94c226c78650908b1ed5b	6712
652	cec21fd9e1fdf2beed30874fe296f9791065b47e8701a9d5ff9487e50085afdb	6717
653	68f55906b2f4f42b5b68a18757ab32fe3604cd5eada820f92de745e7265dca40	6752
654	4115c9413f54ade3cde05dfb3153a223b0180bec327039d79d0400618011cac9	6787
655	552e53cfc5d0212c1a6afc78d89fc76a2b4fc13923d7d64e552b282462de2589	6789
656	57470ca6408b97a893e3bad456e537c7c9776ea49e5d0de55a96efeb444fa311	6795
657	6134b14d48709230bfa2f060da2c63770b2e53b27604430df0174dbecca394c0	6814
658	0bf5d583cd0fbc0987485ca86a91aaab580bc13d44c060e62fda1c32414c3794	6815
659	243ea3b4e48ed4a26ac412302dd9d00f5e203076320c301c2df82f25732fb425	6842
660	56bb785103c6a53326300b9785acb667bde1d9dea4ead8d7b4fde86c4119c56c	6844
661	69e760e85b38c01cb51b3ec437996a31dd44462aa94e3a120ea78a144faeeace	6857
662	d30baf0238530c2ace8cf69fd5806996f4288fa7dd706c79309779816401cd81	6870
663	9df6a632897996bc0e6e658dd7ea5f01b8aac38e727ea2afec6688f569b9eb3d	6873
664	080d71d54b1c7e8a6914ed170480af2a4f90a6e2d16e5f693be4ac6779fe975b	6885
665	8f28acb588fdbfedfca0882d5a5636782caf822df348cbd8200bba747934e424	6896
666	152a057c958d3e26e840c172a0f7b57f0e52e28fdafee5b3f344d3f5f4414dd3	6899
667	3a31b991c0a6c288b717b8154aed5f1bc02b15be747e1618b747fc6f15f030f3	6901
668	97f1c3d4beba48b6f4db05424fade1b535148d585d37811d6e9d775f1d629456	6903
669	ed147d5721a6ae82e5f8b8a7757b69341f6ce801fad79e3fcfcadafb37a9312e	6910
670	99e6dd9094cba265083d197e027c731f60273a5bb4c98a145335e341e3ec9a49	6923
671	6b2d50c314119eda51d54128b674e70c8882c79237b5d201c982c075ab7925e9	6927
672	a5ede5f3d80ab88bea11a3f004e95555068fb4759fa499b4db2bc8b74d0f8fe9	6936
673	604e3c2b39c7c8ad2352059ec9c0eaeb3d82b9960e1ba849fc6ce50562108202	6944
674	6ec7c3f4bbdd51e2321ec22fa51d6b001b0ca197da7925d8807eadb55971fb94	6948
675	cf4e646d9b0c24ccf9c04947e07ee43e8d5f899a12310c1cb4120d4132ba21ea	6956
676	ac00e44b4b2b304f8d37fd8a5df5848a7dd5c675955bb839cccf2b211b6dcd7a	6965
677	37b480fa3df60606e5d203e8d79e4bfa3991dcb3822539558fd3344ed3dc8c7f	6974
678	10a345103fc7b7dfa93e1cb9453d35261cc9a2b03b26fd62f31c045bebf5a4f5	6979
679	e84ca523f4133fe20b8c12b2092895e87084960edb1782a4e129311156ed0b34	6983
680	b06b5aa17699f1d9dc77726dcdc889bc7a3d276113ab2301ef2a90d05422a2e2	6988
681	f21883f5607f63737e192ed26e42208981d115080c16a1b6c8af752aa2e84109	7005
682	2d8c238f667a0505e2b9edfe5cf6362fbc5ff276e8451ed64ee36f0f35fa60ea	7011
683	3e5c2863e9634603f62892176a5fce77816f654e04a9b75a5eece744649187ba	7013
684	e80bb5cecd9ad4034182e2d0d6879b2f7efa791ee0a56627123a4d4c0554a851	7039
685	40dc61d37ccf82d4abf2c80498ed58046250c49f5fc2470c27feac3e48066751	7064
686	9bd838bfefef89690e6dd3ce4fdd50b58929c6f3c8bea64f0eab2e079a297d1a	7081
687	22ad695820d7ae82b3d5d2c29b780d19f2de6998e29dcdc9c18ddfc2b5235237	7095
688	40361d367dc42b776f7c7c5fedd32991528769056b65c8abe223c2b09030541b	7133
689	8fa1b14775444b4221201ba1bcd3103aa5ac200facbcad795502aaaebf75943a	7137
690	55a9e11857edf7e77d023ae9ac9dcb7cb68fdee48fa4e82e315fedeb916a710c	7141
691	57b8cbb1feb5015ca36bc44a6b22a9d8d700517d9ed2cba1af7dc1a25fce6b89	7146
692	605f95795a3ce2591911429ed62ced50f39be766f3d8acea10a507bc977c660c	7160
693	a7ac9ec27ee2140dcfc887f5aaa81cc38a99544502d0fbeeb7cd32f626f3bff7	7163
694	537ba3dea994f9c762c52cd6d46f49c6e073f901347b0249ca552b264b9ff9ca	7166
695	74a325bf76f5a0830d9d3fcf1c61214aabe4ae2ea7ef86a7832328aa9915a1c6	7172
696	6489e4ee9bb1c40b67087c14f43ecb4923def06ae2d0163cf31fdeb5960cf1c5	7189
697	eda411a097b269c9bd89d3253887237c85105eee0e5e3cc0b108de17ba50e13f	7203
698	531caaab08a2c4100b8f51d26936f44958e452c3bf0196075e2546101cb28c3a	7215
699	df58d0d104790b5b2223e465c7534308bac2069c3080932851ec5c861b95e667	7265
700	ac8a26bc22823209dedb7c26131ad8787b294c8e8be06df90688c67bec794e89	7267
701	3e5d786fe09730170860f907e7c51cccaacb1df3e70b678169da59ced689eacf	7273
702	ec5c6e062d0fc19011763c1bfb59f5188db568f9fa23ffb82d0b0f87640272c6	7281
703	f34adb101cabc34fbe8ffd70c65179eb99c7f061bea4177c7f806ee008adeddf	7289
704	c7829cc2601027cf74c85799cfcc589e408c78f91dfd0aa9d9f267463eaeb025	7291
705	a600732f7a76bf84040bf83d64723f438c0a501b717848d804004822f5e869f4	7303
706	035e46b46ff812a60c32b15741aa3f240f619ecc129311df90da342a6d9b2c90	7307
707	eca2d3ba401f9be11d42ba8fb301d1a0966f5c89ffc5fff5b553eb235febc89f	7336
708	3700a334e6940ef1d5dae0682759f15a2805f24e7e035ac00f73e79a97b81cb4	7362
709	3fbc1195d45ca0b291b434855f5284631973376f2bdf336076078b2d7ff2c152	7373
710	ee2372590cc51d507cb18bb65faeaa373aee5d5863a3d7a80282a6d89c4b7ac7	7392
711	7d75806d355b35230a2216655655a4eda78f9201ec46c5639a91b3b31b8f8297	7397
712	815b6920c86b691800473bbea7375feca990bd8df56f73ac914c8a8dfee4006b	7408
713	beded76123808efbd63a4915231b0d7cf867c2e5bfe58711ae69c83471953e8d	7409
714	305f16c86ef1bdebe901eef3b27fda70f3913c25993c4a6fc3a27be1f63bddf0	7411
715	b80b4df7f7c7e8c3e6f3b03c586e883b1d0aa004b34fabbd8a027e697aed61b8	7420
716	eda3f116de9172b65da33abbae1a82c413412434958c8f33e85baf3ac3324e59	7428
717	bee9de0548ad9a9dc6677bd3e48673c75e794383575f9730c24a4db66902d696	7433
718	6b76bb1c45bcaa95c980b23d452b6a10a743cc068a12b61007f5f9376185641b	7439
719	ea6f3bb824bd9d5195c1e063f4be283c23a84c722298717051ce4e63fbc378bc	7446
720	c4bbe6a239b8e41706b36c06b3dea7f78822de04a5910f48255c1fba7205a18c	7456
721	0b4c12d8228805cf4192c8f4c9d722867bf5334adda6a18fbde743a91b8341e6	7464
722	6ffdbe70d65ecda197ac943c2dff2a84d7a489e012b1112941da485c1742f369	7465
723	4ca784d17f7c7dd2fa49c6f1725081620d98dfe5abad9ec209e4e40d3a524c73	7491
724	f977b22b03a839a40f1b4283ec20672782cc3e319a267f17f0aa0b8f5239188a	7503
725	a0e75dc1d15ec7bcd246e5622e162d8adcf8aa04d173bf518b507a60c80ab348	7506
726	9c1413469d2d4e688a22844376c7d1731c87b7adbfb92f4e8a4276ecb3684fb3	7515
727	b14ba6cecdc9fa8cc93d5f1cf6c8b28f0f003479af57bc34c4f812824c13400f	7517
728	38e2fe0443589a13d9a674d2dbf313b1bbe0bdd47ddaf94faf7a0b2af254acff	7520
729	5ce3989ed246bf2d02c81497155cac1e4148ecb125de55b39bea36ff3badb72b	7525
730	115d5d0c2f29b6d587e3e8545a7086904cefd10ae8d8789d2b50667061e513b7	7531
731	88fed1ad43232db29d2ef8d0e1f456c6c8de8680f487b0d5ceadc0c2b02d64fa	7533
732	b2e0fc6bb15356b7f8b462b775404e5d3a0fb77168831f12a01fabd2fcb4cc15	7536
733	f5ba6bad8d84f5099df906eb76698e41f1f1102edcf97cc767bd7e5c23671d52	7537
734	c94828832633fe8ccca35ceeed53549e562859e71b67042e3f9d7ca611494db9	7546
735	1bdd9571084220a9bf26cc97861439a0ec1fcf55c9786ad9382aca28c03bcfc5	7547
736	b918b7564c405dfbccdaadabf432cb17efe41a4c0ff70b3c6ad55b54d67cc47e	7590
737	00ba9a252f9539f6aef95e41ed04520e9235b85e4008e8710e13a537447eb117	7610
738	ee5a801862634a18b0f7d167ef6d60dde1a403a12a17515f91989489b971570a	7620
739	4ebb2d8e245eea08dc92fd440ee9fcc6f3b40fb370a598d0b27385620e9c9b9a	7626
740	d6b45a3cc20fd49471ff46acc0db882565d46ac6434fc5d05eb3b4d743229621	7627
741	edf43b1244f94ccde897e49ce7bb13821484ea1cfbe631de5d16a6de839e5386	7636
742	1333b9ddd4bc7890a761c4d63e8ef7e95d038d77d4853d7c02655161820baa49	7675
743	4e109305259be9975621ea8a1ef7e5cb3944dca09e6285e094269601ebd672e9	7676
744	4885e679e1a909586a79701b48390d19b96f9d766b40ebd5f60a6542de8dad3f	7710
745	2b2fe8ca63e5b1275d59b3b30e85eb6b20ba1c498202a54438139f16e3a86135	7711
746	5d8be9ca9ac536e536096abe2744f9674fb8d2f16a85cb8515cad4431c04ebe2	7714
747	ee9661d065b20a7c43dad695fc10c2fdf78299429f840544554670105f9b8391	7722
748	d08a86b1104d6bc45a6b72f559fc39d53940f28ab86202998d8686fcaf4730a9	7726
749	4e1f4300f2652ca529107381ee5217aeec864a39c7dac6c6f84a57bf4f5c6c93	7759
750	3b121bf7c3ca81129d9656563e9d2faa4ce9ab8584f8f39034706c797f5adf03	7763
751	ed807fe437038bd51ed8c69fac85c2af19100bdc48cf4d50ca1d355e34d5d254	7770
752	27974124e2ad25de87812b43e78b975999c867ac236600a083502b3403a94cd1	7784
753	216c6a4f955b304ba8079ffeb28993f67e961c314e195b117c745feaef588035	7817
754	a5a335bc5a524d8a29d33134f0873ebbeb7a323bad832b6bb3a827e311c29b28	7818
755	47f4f23537b0bf643848af9bb4c42ef94293ee9370ccca59fc2b4d0b93423b60	7843
756	c43f31bc97eb5318150e08b94bc16991322177e25ebf03e4499f8468215f74b3	7852
757	a33851e2f870dbdac7220a2bfa097bb67e387235668578d3c8f0c538c06cb675	7872
758	79d93adca1aef9f6c3b0334f38edfe5b2d37d792495ed757da3a2d32d65a8ace	7880
759	1ea6590afe1db1f242c28e891617b733e253022f01e515216f3102912668807b	7883
760	6987fe2811292556478a7de19bfc61c25617a87e5a30487e888b6d0c649e2220	7889
761	8a07d94581998c58224c59c73044fa66e1e8bf0a8e21813ddbd3d15bd6f72824	7893
762	13c421bbd39b6c12dc10736d6f4ad051ddff2cdc71059d2e06013963653311f9	7897
763	d2c65108a8c9becfc3709dfc6a58d8817e38b4afc4e47b9e4b97df1f15d606ad	7900
764	068df3491cc5bddd061c28d3cf126ee3d8897e46f855b4d5dafb8e1cee4ab1e6	7914
765	69be7b910b4869abd02ec3dd5555db668e4dad8ca7a2ad9d46138956a717eb7c	7950
766	5673b04ed00f919489466f547e08aa6e1e920a8f9621ad6b9b979464382135b3	7972
767	b03c6707b3898ff2d8f32b39429abf654dab09d52173783619947ab718f30e05	7980
768	18920aa565a0670c305b264368b6a9abb6aaa5986b7d6ec550b2facad1886a82	7989
769	1fc296fb9375b44e82afe634ca72ecf6b415900b8631cf6446b7043f1b8a3486	8004
770	4d3ed80ac32afa6d1db8a88c16e0124c3bb47ec1b216dc5f5cf228a1cff92b40	8009
771	5193d3e2f7957a37204573f930298f0d5f0b51a0b3bb28fcdae64434f00c493c	8016
772	b2ec8bbda80091c449bcfd5f354a5eec05cf83512fdc5909f13144d9728fd2b2	8017
773	c4c3ba788a7fa16655872c3842729a4fea2cc45a80bc99c5fdfcaf2d2e08e938	8019
774	3967c2fae4784a8c242dffcac939593d24d7381b9ff3cf305c3618f17d282e27	8026
775	eef9b173485e5523720f8b8f3f8bf90998213a3b7df9e30d161b2fb18c0fff8b	8027
776	b9561c48de3fde02e750c2dd45cfc27b1a9a171542bc2c38f683c08772ae85da	8032
777	0abba88d8d465ee67830ccb00fc3a0574d857465052fd9398e04353ef3b75681	8038
778	2f1fdb9246e379808910db9e2c2308c7152845d0a093600deb47988ea656cb95	8064
779	216701112e48416fc42169d5e18d76161ab8fb34e119538da0053f9722e3e9d5	8066
780	5a790c72b1924698a41b35d77c4dfbb4f55e16360835b1f7fef6978851a8ec8c	8070
781	5c71894abba660d8379248b8919eeb628a0cd6b82e76971fd6548f0c37d67532	8076
782	d537c3d1a354831e88e7a8e94035dd732eba338ac0c9937bb48d0223a927928d	8084
783	4532ae25d04ad567f3f77cf6e4b188e5e083dcd34a0e5c5b802de4a7ebdaeac9	8102
784	682395829bc60470ba4d03336c9e5276f2b2271e5fa14054e3f89cc50abac83c	8130
785	1b6f5768a8618baa3b1986b59c84bc04b3f3c51cac7c7f226e8e9d7b451b2e91	8135
786	2fba16831512b3a599b3bb70eb874d2404a5709a18c177fbc898fbdb92377af7	8141
787	3c3ba41caad15a295c30aab4dc0a5c61dde9970ed4b9e62a1e20fa0dc478d20e	8153
788	83f20db4b0cd4502467dee4ea1c56103a3704b481063914cbc8e3f8a728257b0	8154
789	5e08b553005cf60821ca529672b79b7e1008f85e5966ed4f6e99955c6241ed05	8155
790	056fa126055cdae974464dd21d2ec9091eb7650ece644a77629dc243e330e2b5	8168
791	2e696f90500a5fefa3c2bd2f136ed37a7d2f1cb4a8bffbfb08fdf4f37a656a97	8178
792	76dc9a493e2373d333806a437fb543ee685c3a9ae1353e877fcee1dc32806140	8200
793	20f42cb7c194124adc8da881c094becd9856d5cdc2e81bd40777e6dd484c420b	8205
794	93e3eedd570b2e4a96e214420b40a7872ce1586bcf8e1914bd0962ac922328c3	8234
795	14e962afd5600719d97b13d4c990b6d5cdad9f06a1f7776cbcff5063f8398fcc	8269
796	6092bc573999873ccaebf1728d89d9290db728245206998df94db6ce500afda2	8279
797	b9cf63f5fc2136ea56647bc167e97e6ae55335b17366a57285c29154b6fb2788	8317
798	b5ecd560dc710972cf37824b931c3eaee016a96fcc48d41cc851f3eaef8e3347	8326
799	32b1c335ad92199c1a1929269f15a33994f125b3824cae5ba30afd44adf7284b	8327
800	415e56613aebef8881fe848b13f383bd9373b80006c20fa4577c847ad3cd200b	8340
801	9ea3200d30cd4bf8feee69e2ef68071b1520219c7c3cef0b3c64c5c79c5bc566	8341
802	300be44eb61a3a48cba01f4249c5fd4772e3a13be8c5a45f0d64d3eef8c80355	8346
803	ffd63c5e91ff33958773f7824df50ce442dbeb7ba6046711996b7c9beb0bc868	8347
804	b1a4ab47d5d37522ba6a95fcff9b150830271f49767669716fdb44b5dd8bd74f	8377
805	0508bb58f07c040b677614be355e64c7a7805c52398bcb8cb4751eda4f9acfbc	8380
806	27afe690a2df17350a9d3f6ae34aa48614fea3c3ef8b76bab5edaa4d180ca410	8381
807	bfa7f5c67939e134cf18eb70a57c51087e33352f2f300023babd5b789b8582a1	8389
808	7c8b2fe01f4000dbbdf4841249b900cc3f77e7d1e4d964c65dc598ee894788c0	8400
809	741a9fd4dcf4319778b0f6a9ca242f13bc48ebc9d004a332707333cbd103ce8a	8404
810	4719b019e4a893c4bf6bff33d0988b3b768ab8d4ae6f991d2bd9c8a880f16011	8410
811	d90fac41f3cec72493fdea24f0ecfff0d8a9e322efcce05e3e700e066541fbb1	8414
812	13cc1a1087809df5b0a8f49bdfb9383621f2311cdca0e005612a1cdd2fedebc1	8419
813	915ad3a885d7d482b6a0383794fff23ab6b2c34a59d8b197936fd32d7668ca89	8424
814	c09384a8f7a37277dd37f909f36038897126c27837d5b6c2b80818fd5cf6572d	8435
815	5442ad74eb255b0ed27363982db12a9c7ea9c3bd2894e9824b6746c7aeb15f6b	8436
816	5cab04877101dbcffea655dbda330ef13912185b5045750baa7588846abfb82c	8438
817	04ca4268f98b4b8cba5c11610415b37f0bd209f6093736e2921080fcfe4d7375	8443
818	cae0065b302a542950e4800a321f50037cddaaabf75e8803e0c8d2a0b6912937	8465
819	5b71561fe977a738c0e5811b22712592b3aa6baac72917b6363de3d8bb82dbef	8483
820	bd18cb6d6875914080a287b47b975a8160673df68896401a2069402776ef42ba	8484
821	7b2eed0324e7ee1fd2d4eddbf54f61d85fee9414b3a2a48ddac7e7f347f2284f	8510
822	48b2c39431d43cb27532e1448d9597cffc23047a2e82a0be507338d179d66fb3	8518
823	b79fc3a2c7c1e8965a73f3ece923b16fd7bce2fa4a79aa57602a4181fd985c66	8531
824	20eb804fde426e006d7011dbcd43f8fee4acc28e861ca1241c18714a5ebd7385	8535
825	e07a87547e539b882443d37263cd309c741c5ce3a11cfb0757499d416c57530a	8546
826	07e6eb1607a54caed4c99725e7ca5af29ccad96295139357dc5041ad6f75dd2c	8553
827	2678f318bfaa65eb9fa291b907bd0e0328ee31c302948129e4518503ad5df604	8568
828	a98de50564301a3fd4f2095109383f4efc299f7e0240e6541c57bcd9a5417dfa	8574
829	2cfd88fbaa8a0bcf1f355ab425537132f22dac58bfcdab62c6c8c008dc9215d6	8630
830	ded96b30810472d8f25d99555ba0002f4e0b153980687d4a903532d15297f187	8639
831	83c24d6a4248e96c65724960a1a7cb619ecce90f39a2f3e7b13fe72d54cd5a3a	8644
832	c972345b1fc8dd69ecbd5d00edfa4ded87fda20ca83e5a91d41d164b4a8a57fd	8651
833	e3be7e782ddac50a9ca9b819d68d2c74cbeedb02345811a697662b9e11af96c3	8658
834	ea2e731979047e8b017dd335d410a1746330d7fd18ad8cecb9d2507db37a4eed	8677
835	5d49a14e8fb9fc94de106065237a87708983fcb8a9afe1457feab675637ef5a9	8678
836	56029dd69bbcd26f8cae1c3268c3eaddf77898f0b08e25d72b62bf6740834f81	8681
837	5ebc6cb732deaa0e337db4e6ba298881ef3861e80038734d8cb46980d58451b4	8682
838	cfc6a00c33cc882cf6611deed35ed498792cdf539cfff2ec7a25276dcb05a9fa	8683
839	195755c5ebed2b29d2b1a97f05419615ff26212eefc911b212a35da9c0c25a00	8688
840	104e8d872ddb3d8960259b8d0c5d3933b6ab527909f64d0b0a097574a156fd01	8700
841	cca89648dc943deafd1e43cb23e9dfc6c3a6030ba633802d2d9df6649e645c70	8712
842	548fb323e113840444f2fae1b24a19ede0b8308d9a32d9c8944209c11f4b4ac8	8717
843	3c76b3863eb67263c9c0f8496631dbda8a2347ddfadbffd782b938973400fece	8720
844	f1bd14172aed188211c2fa642523956221a2ed731ba7be2c597e190ef171b8d3	8721
845	7dda6e2c969ef876f678d57142fa1a0aede01b2435a203eebad6dfdfa2982aa0	8724
846	3e7d4f060d403a15102629a29eadabf836de524023f5b0cec23fdc99f72b892d	8727
847	0733c64ef7333e0ba7828de18671e35e949807b168b3b3053a2f7203584b7037	8736
848	3ebb1d455cbd0fa62abb53eb6652ff3edd199b02f24b501b69f85e918ad34751	8741
849	d94a6e8353a0829a4426e9c66328fb60a33c840edecf303daf50a234c138463d	8744
850	cabbd8df87be380db4acc4600313380875878bd746c8b619c9bb7254ace32a30	8748
851	4222d2cd1d7ab7d0d6aa758e8b566d4833884cd394387cbbf93b5334e73ed9f1	8750
852	1e91a3c9f1fe0a3257aa8f6c3e391080ad112a502fd1e5e4536c5fa7c2788741	8764
853	f41e7c9fb138485256f67f7101a2f4fe6dedc873c0b45d2f823522892d7828ce	8766
854	098bdae45d5f3164460249a4bea67f24c09deaba84417f16984ba02d09d0c061	8781
855	a36a1f12caa22d7961bfb8ecbaa65e5ef18afe0dea0c6392bda36b14fb3be6ec	8786
856	a2777df83ee94254cdd2a4970f4195b54fbca6419b8e3594c7f08b628d71de4d	8829
857	9b052e75f784ed5e7c39c7cc9dff9c822713caa8a0758b18a2a8af9a19d97b84	8834
858	124d4f5f74d0eb134d53f7eae8f719a23e50a9d23ff370786335c4d0a2e7dad3	8843
859	c7c819175350db7d185bc1905b22f87263e86591b06476de1294915c48585121	8844
860	3680dec8c1f04907d5d9b0109606ae7159aa8464b63f3ab17a0b4cb0fe5f2e02	8850
861	dbd60e75f5b1699513d9541ed502c9a14c5ef512c29117ba97db2ada64648572	8853
862	6255b2894ecae815fd300e3e3d1b9e84933010ff8bddc2d3b8a793549fb9c820	8855
863	39bb13b5f6eeb3efca98a779d4f8e7467bef1e63715a287f0726a1e34d35196d	8858
864	c27403e88a6e81d6d328f46e1de58c24c60389c48aa9750ee770caddf4dd694c	8863
865	ecea4ca21520936e78f2bd9f1aba1564b7dee01cb2c2404cb93352840624519a	8878
866	e3985d0e55f2b154dc900dce591dc6893aa3f0189c1d1af6de3cb688b4926ec4	8906
867	e0c7a46b2ebe04c157e20db6f74a6ee0a6f4eb50dd4c157826c8df57536f48f1	8918
868	30aee3687bb3b891202f5cea11671d9c56bf5449e56082fa19a7702b807831f5	8934
869	11f8e912ffa6ba25b93b8b9c28fbfb6609b34ff56e665fda875a416a915efb7e	8939
870	8b8e66940a486aa8bbd2ffe796d9abdd2fed10b9ae61d7e2f4911abd17ff69c2	8975
871	bd5340bba9198c742585d6f26d2dce2d2c674d40c8f8a4d7ec4e79be732f4c79	8982
872	00361d51266ff2d96c8c0ab20f31e0253c0aaa32b991f21699c28a62690ef269	8990
873	5e5b44c6583988bd09b7120c134ef07b1908d873df5ae908a34cff459d6347e3	9000
874	6caed0b26bdf92236ff3c8bb224421219fd5a251ecfe6eb59586e223d098af1f	9003
875	b2fdbdfd19ba64f59c1489248deb4df1e0287ad6bc16e050be50481da917db3d	9006
876	2e66ba815950457015bb99815f6895cf344aa437d6ae1e330632cc21e68ba769	9016
877	5b7da37ed19d8ee98f11c4b12889e855642d4f0653cf1b8ce1ace8ccf30f69fe	9024
878	be5005c1a4ec8ae4589823f0782f1fe88825b6dc65f84286f12c4cdd5e89392a	9030
879	b457881e875aedd3c3bb9d088e4e3bab9b7a6522c1d2035e558310a9af65089f	9036
880	56f5ba966079837909fbc162991b04716dec12a46d8ebe07a197cbc92c1a5f34	9038
881	08f53b24c05d7ab740898d6309b3ab854aed5f01dfd555a6205632fedc66fbff	9041
882	c01abaa81182c2fa730fa4228a01cc28b015483395e12dc6cade8083f0f04556	9045
883	c0dfb065fb7a7f33befa750938571bcc1db44ee2624e7d6919648d03d06c5d48	9052
884	15788f4b2ff95be551de23552d30da03a7df88f5d332cb747c46118965b5b727	9055
885	6e76dcf5d75586261b5d8149afc5c19a0aca9b329c3d50041098b7c137c1a58a	9066
886	064bda3f5d6b348e9a50c2cbef97602b0f2e52b2c2cb8b3a141d9e3529706d3b	9082
887	516e6aae2c45637b484c58c2aedb308acfe62048cdceb677bd7d1b40f02cc230	9095
888	fbc4924a372da1910fbb84c0354534d57ff01addbef79bfc89b5e8634e9fca01	9110
889	9f2e5935e5df5dbb957014e4912738a908af58cdf37ea134e1396082bee341e4	9111
890	7c884ebef15dac142da4f35e9b161aa199173c271f3c7607b6fcbb7bf8319b45	9114
891	811aa8717caadb7ed7f774c5e8b7210d642d6da1dfdf7e6ed309d88c36dbbcef	9115
892	67c3850493be4faad3a393b5acae667878d5713e733ae55837e5bdab586206fc	9136
893	222d2ad1f80523c49cbb0f348cf547bb4931e9b1ae7777868ad856d032a0b46c	9137
894	9ca2a4baedad128bfb12d42e57d4a87d888b43c2c52a8e2ca81a8bee60f12bb4	9142
895	153000c90006eadfeb0ab3de95e841dafa5ff4e051938332967a85252a724549	9147
896	427f45446393042764c305f820509225d48a769b14b88673b034e17ea4374ceb	9148
897	dbf77a5772b0bd8cfe939171c455f3e0011438d57e4e326728fa30026913ff9c	9158
898	428acc0f5715850b57d99ed76656f2660620f36ae914e1dea25e93ae85e7c0aa	9160
899	e9851c050d4e405b9434d5d3e329e6d41067b2679ea218e93ecf1013e9006bbd	9162
900	938eef4947862aea12f852b8ad806f5332b8fc4b002db923dbf52d8f51e4f441	9172
901	740d3e805a580b3ee2469b3dc3c94e2ca2c23d39eff60ff92a6dcdf4b837a0ff	9174
902	379ed830bffe913821858119bff6cb448b8565c060c9ebfea371c289137f857c	9185
903	2280b4a607dac43ded1e83c10390b5970ff123cf9e1bd68069b0141c2187d14f	9191
904	f939d1519c717d0484b37d951c13e56834dc26aec0be854d4fba0acc7ca2e403	9197
905	c793b2f7a6853b0ecb77cb19c11c602347891ca9a0eee1189db6935d0f41fb1e	9199
906	179fefc69245bb66d80e9f95fa15549683f0262f1d144e5d0d4618907406c354	9201
907	4743da981dcce3a1079dbfd9e69f98347a39f818d0175094d06e8142c3459bc1	9211
908	f3b030b9743adcbd62c209ba199786396761979024eca0ceb1b568b41791cc19	9214
909	9dd34ad25851a84c63a15e2a525986350c63a4f83e810294e1dc84f4037343c0	9229
910	dffacdb72a861a025d1c25245bd38a85910adf9ef624a1ab44decd9bfc59edc3	9251
911	ea19a1c848731535e1f10cb4b0c8c2187205d9b5f237ea708e9f96b3f1ad69a2	9256
912	753be7550b3e23f7ceef01db838fa2c064d2d782d93b9274b829d5af4c84867d	9258
913	71ec1dbbc60c24b0eb4158844f203696288dc1ec4c097a1b43718004e8f02c99	9262
914	b6cfaa28d31315097504b232a9e98fe8aa59dcb2b2afd6aa4d18d6eecfd33182	9283
915	be88f8a85833385bca462d4f08d65342744c939dcdec82344ad412633cf8bcec	9290
916	62f3a82c8371d1c54219d23113e56f0ccea93b954fd58648e93e021e4a3abd44	9356
917	d98eec0d19624575632b306371971c789f2a396a75411691a1d45d140ae0b4a0	9359
918	35fb6b4d0ed0ea6be93e0333b6be7ffa46aedb75d8409fa67b7ce258e2b1f877	9367
919	4a2859a41d23017b644c471ef56596976fe1f2fdfa1fd08a5e9beecde98e165c	9368
920	e66d5a2ed5e9e8a00446c614d822cd505f97849adce0bdb6fb8ace042659224c	9374
921	4a2878b38a3966d29bfde33017e6460ab5a0f9df141427a3281aa155ca3a0b5e	9385
922	1a213c9aab702f89deaba14977f7c5c6f496ad33c9399ed71ac243b704e5e3a6	9397
923	e2d051cb1ee24f423e12df259dba916172ec0d565c1067e229349aa2e5e339d8	9411
924	51a58b0df40f871f45dcc6e814f7441919f9622c0e46408a5b13c42420d2edda	9415
925	7ff06d17b8405c7b3538989e5d5e1e5800674ce31e1a49a02829467cb79072ed	9418
926	16628581216cdfea5620ba68683c3d611bddae83181918807f3618aa10356029	9459
927	14cca42e39ba7d12adda1374c9ff02ebaee760f2c6eddd2c5066c232daf2f12b	9464
928	37c9a01b331f6926eefd2abef605710ca46a197356e2385c6524a4cf4d7dff9b	9471
929	bbc8f421c9be039b1c92cd02dc51ddbffe1b3214a159f431ceff938f315e364a	9479
930	dd8925cd8cb39f3fe3c379105abfad2740834f461f2ad35916ea71a95d780834	9480
931	6f8db541c8d8ed8c50ce985513bbfe838afa0a21f2a4e691b2973f845af5a00f	9482
932	432edaf122efe8db6912a8eabc31678c22975a699a5ddc39ce56f67d7d5c2fb1	9502
933	ff6aa16e594344be144de3ac890f7e431653d903b1989f7faa381bd12d4d7e57	9529
934	ccada8dfae2b66081a5ebd61120860101c913758afd39d6d6da5ffca20f52efa	9532
935	216baf952873d5038fd5bbdaed2367f19227af5079b5d10d2e43d8afc6fb005e	9534
936	8e1a3839486b12e458ea35e6ed3993a283df654fac3aabea1eba4b1e0b36b03d	9541
937	bdcff19655dd30604e0b69b1aa419824e08f2bffc00337748b3a2ffe115b8607	9553
938	2be1d0854179968a212085290088600efe55775b1808ff4221d7a32525272fa3	9575
939	17d0b2283b09b74996c217576e7d6bf2efd1c16c038c04a61419cc1aa304b01e	9584
940	f0d38f3696b29abe7ea4b25eb7f35bfe85ea6f7941308bbae463fd306edef2d3	9594
941	e485d9dd7583f667eea58f6a59586a70bf6bc7154c99301a8d334d31ef448a0b	9600
942	b604c40537b3aee051da727949c8254da7c5359038b0a61025228c05b87c1890	9627
943	3e9676a5fddbf5bf681e01535b04e1a095d7777e0e445007d62f07edbaefe7e7	9642
944	69dadd7dfb51b86c36d8d857b20b703d0d15c53b34ed8e7dd6abb6fdfa1c151b	9645
945	90642b965a31bc8b1aaa56f7392205f69128bd2c63e4781b856addd96922c913	9649
946	eed8c5367d55f2e4bc3df83b7e121aa9c3700fbad2b3e781a5b873f0efffb28b	9657
947	b09cc57766758748612ca44db1d2395eea29ecf738acac0f7434eea01bbca590	9661
948	2e2bc19b8e4249aa66c0bcf6da0a6f05f13ef13da31af5dd5db2a202dcf86bce	9672
949	12d73548ef01bfd410c1ccc046997f59f2d4d2cd5fd0671ef381ce2d83ac0d78	9674
950	2c46c6556f4d92f185cea8b3c529080492521a766c0978149056a19983db43d1	9701
951	b63cbb3c41f30626548dcb041ae29c20097d78e656c796c2667ec75b4c4d1bef	9707
952	d95a1e6b674e0ee12bd3139a309b8334997976d976968f39c328ffbf6e5e0d67	9709
953	e7d2d5ffd10f4570eeb340d513582ada63d7ccf89018807badfb135b6f413847	9720
954	c1982afec1a08ee6867357480604b61584b147a6bf505bf3382012722c6c7bfe	9724
955	d5ebe31e89563e5a6485fa1f6476fbddb4679b70165e1d2a9b967d4c921fe1ca	9737
956	c138e800e6a016b849b23e3cc1654742556983961f3061c7ef79b9073e13d65b	9755
957	7089572e8ccf7980d9cf85553fdf5ec7665bb5a9bec285edfd8e752294354713	9757
958	fda6d267df7c6bfe349c6709f96b81885b430c815e71b71b6d847c652b9863c2	9758
959	4115165c77cca5b3a58b40794b883dad69a0061975f720e2d65a5aeec3bf6fe1	9771
960	6dd5921c2fd8ebd46f966d0fade5c5083f0ec9a49ca61dc4c7f14119bc002e8a	9804
961	bdaa1493e3d6b085f74504854f1cd056c193ad172e673092ac79313ac66d4cd6	9805
962	47a166d63c7f5bb22364f7b273c67ea321404880d05a35134bdb187cfc02e2cc	9810
963	34eb3066c21afb8677b8d8ce4d01d7da8026bedb1bf4eeb3f17f9dab7ba2b4e1	9831
964	1fa236fc9191575705d39d61e9de1be2ef6028cc917eb4460b4f7b013844481b	9864
965	f2b54141ac11663bed96db9dee819fa46d92032d28431cb3114c52b86b6aa649	9886
966	2e13f75cb287bf1f284b6aac078dd640a916203d1539ea7221af4735ac371167	9891
967	0701975887cd34e43688a7c1783592f978d134582409cfafdde4942525dbf4af	9896
968	1d454a7a190929d7511dd85157d1732d48528225a6ab02e3541113282b3a0202	9915
969	04d4fbaa07ce87de598401d49e3f595f1f663a2a135365cf28146ed87955aa62	9924
970	4f9c0d38cf13a0dc58466f94a066c5b51426d15c85ff5cce6898f3e9b6d8cab6	9945
971	62cb319078770590e47939a4a2fe8c908460a50785278af3ed9d3690e79047fd	9956
972	38f20fdb4a598cc610a2cf61190aeb813e44fe7820a17205d640ae9d9fff9718	9960
973	51e122c0dc46dbafb04b2c42c5e2b9d65acf2c2f2b84a76e224c1a98a4e03725	9965
974	0609c977a70638a79624d84cc19b063e475294cc2b023f42a0d8de5badd99d43	10012
975	316c6eaf1f6c0aa3896c7453615fa8c163fece96884c02ff5ad7afe02addcc51	10019
976	f199fa1c628cc40053c7a72fa3ec54a11c71509d268c67b71e9b8e3d98e99865	10023
977	0780d594e840802fb4ff40536fddb0d31727792891d2cba42b317e070e07b8cb	10031
978	565317192d554af4657d5848e4d0b31a90ae824d78dc51795d2102fb8212e517	10056
979	a044bb48044ed5e4e67aacd6720f6826b24638c7e93fe42e5b66bd0c5d1b2ad2	10067
980	61220e9cbcd7bd65457d217d699cb8a6d4706befc9947e78f576cd424eb57546	10069
981	0974446f3586a360815b0805815255a6f567d732aefc03e03666c4a74fe6aea9	10078
982	c8a2eb9fde18a86e8d30fa76bdf0bd60af352513849a21cea818bbbf72ba0063	10098
983	d3b3dca9f7da44e8d218e0a4362d6a8d2fc9adf62238826b6ff4270259da2601	10106
984	e394a1fbbb025e4117215dbf9aebbcfb8bf7e0fcc05df1955fa68bd7a88d4e02	10109
985	bc654944c8bb561f8aa6e858d881e5b2e5296a5294271021fb124a96b39010fa	10122
986	02ac2987812c4811c8e2331de3a1bfa4984cf6b4efd013ff3d7123ccbdabd021	10131
987	7c5899b32fd54afcaf24ce4000dfb6159fc02b03ce48321509780bc65e209c5d	10157
988	65b48ce71787b5a683e90563db8d7d13ff45d5dde2cdf95b4b8c3e7b2a344d73	10189
989	7d57a9365928e25e5946aade051acde332d65bbdacaade22cb3b315102fb2347	10202
990	ccc37d6cb45e201cd1d66243969c0a10dc0e6ff295af2d695542eaf7ff36bba4	10217
991	940f77e140946354d5d106f8245f3ba93be704670fa6c5cd20305e8e2a3c72ba	10233
992	5171712221d25d6bb0024c61e5a03746115f2789716fee48f5254e27554653c5	10235
993	17513344738ef5e4f66112d141612970d5e79cfd4f41b462c6b5c023b6fd46b8	10243
994	bf5439828f24f45c46c4f2d5e7f854639e51f63630640e4a87b973555efcfbc2	10249
995	1db2a666bc0b7295240c43fcd40cb9b29cde918ecf2a8e349a2c7d63435ad7ed	10258
996	87838b5a39abf4bd9c7ef35d7086853936cd79060354350c1f250bb1c8083a9a	10263
997	6d011ce2aa821640d52f4739022578afc33f0667372f82b6347beb38739a237d	10280
998	b80521029bd51324dabd513623de4b2a0edb40302ea7617116930f8712fff773	10284
999	d0c21b697334cdc38e2c8e3e4b1b6d20102833968378a90a98a3cfe89be3a5fc	10286
1000	32ea93b5fbd3dab729147180ce39875cbe006ab48c499ec35824c230ea304bc1	10296
1001	ae3c806483ae26dfc85f4cc83833d6eef4dcdedc260393619246549f0f6907c2	10301
1002	cd3e8ff5a24d6b597e128f42828dd4f37ad8f85b922df3e834c7d5fd98323d75	10315
1003	22b7c8d29c54346c03bafc557f5474158c98542361fe063bc1f03f3664b6686d	10327
1004	b2ba5ee2733ae31c4e873f363c54995be4beecbdf54c45d2da665f859f4bc644	10354
1005	5ab83ca8404dd2c72a0ba302e1bb2f5c8ea218ef3cb8c62ceb1ac0b44576035c	10372
1006	bb545ca2917a18d877eb487f803e9c61bb7ee776a189f848984eee11014433dc	10381
1007	68f9c9d59705e3ef5d827348399e4484ddfc03c19571b7551473acf82b23712b	10394
1008	f482bf3a65946b693f4728371b10f82236522ee6ecdd9cc3955fef49455ee60c	10408
1009	76ae062c2ec931c317a7b55232039f3e922e7f2e6302979aa2df312949152611	10417
1010	a56b7344c908089391a8c1ac0aa6c7b47e5ca287db34c9889483d576ca908f47	10434
1011	af2d5e06fdf29e9523f1e458b89e566f7a2d84a633db1d1b08259a0acba20a4b	10446
1012	49443a653cd7734df0fe86cb753f8d91a19eb6346c2c0fee5679d5bb34ca3cc2	10471
1013	1162061e0ff49132df3f0c4dbc3dee040f9cbe7405393096893d6e0c610081e3	10492
1014	dd75a0f7e06e9ec35703f59dbbf4f4e630c705c9b3a8321c223fa49e003c2269	10497
1015	83fa19d4fa77ec33deecf57b978ad6b10a9a7500d8cdef065f421f4c3fc43721	10517
1016	d13c0ebe933fdb12167d44218fa3ffab7d9aa38772b75ef91ae18c0eba38d0ec	10533
1017	0388e3fcc0a9c75633ce93fee1c02ebc91530506ba9b1bac647376eb2a944c0a	10548
1018	e4fee3d8049a538d4e9e00646be7e6fa7d4c34e95bc83ca2ce437d8aefd73458	10559
1019	67d121ef4bb707f43ada690df1dcc20ed495adb312cfb657115d3b0f0318fc86	10578
1020	cfc6e23a589dd9f4e6a6bc3f2bf3736a9dcea7319e3a9ac63307cc24c1361e3c	10579
1021	27beaf031ca748fd7beff657ab38a8f8dd100a0ed1f40fdcb05cc33162181f92	10589
1022	e0729267dd8e54a1b3d59c0c1eab54d8777d5a621262f9c86c973ede87a6dfc6	10591
1023	5e155c5c90ee3381a6afc712ffd80d2626f30964ce67f551bd61d3a2b1f83b37	10596
1024	66e0ab991cefe13902e061787f6531e114c8a023954adecbbf3805487ae7cb0a	10605
1025	0238b752a38e54751eec0b14ee0ccc7b9f54101cd760aa69ad339eb20eda6b17	10622
1026	93e6b92b7fc5fdb5446d6d9ad5d485398ffda24c78a981e8b096c6a86a6b1584	10627
1027	302d0dbf2f7c2e7e8d2bae96a7b6c237bd66139275e3e0950318ebcbc3bb2139	10662
1028	ae80ce2638462ba6d6861a46d985e70adf7fac26638275a450fbf89488e04b5a	10670
1029	50e5886add708677e62a57915a5aa2b584515d56f68684a89126202687f573dc	10686
1030	b30a004c1f7dcde1ea935c9842f2b138c2d9b5a195926b40e96c7ad8a6800d77	10693
1031	ae6a639ce05acdf231cddb9711692081704e07ac8b5714332c84e91d0ee48b94	10694
1032	c295522e4527632b7a505be07536aa03324e2d0ce83286bab987d3e9b49d2630	10701
1033	91b662bb58a32819b417f10dba3c6a7362004dedac7519b4289b5dbec13c9864	10714
1034	151b966c82466d98d191414c318f4e4e97e8183c17d2ac72283d23d7a207c45c	10719
1035	afee730feb6dce8a63b5d5c15ee23b6fb4e70ed095f78309394ebfa296b1a5a0	10728
1036	5f70583c2f29b934837c1376f746d793ebb8207dfa73e7d065690f5cf96b31e6	10730
1037	158ee35e41b8a38e510925e0525c9a94d3eb4154c85813839288035befcc14c7	10737
1038	e030912f7957d35cc92960c3fd9cd430aa35dd907c3c2e927cadfc3c3185e229	10740
1039	c13351dbe9a513eadc6cf2b7fadfb097560458e9fcee63c61330e3b4fb045a6b	10748
1040	655e52b585df4edd3194be9ae0f3f97244705742a7d24abb7f7a6bf69ffb1050	10756
1041	beb0c67dbb35771f7fe45b69486365585232a80a31a832717f2514f735f9ad08	10760
1042	ee7672ed2b2a9757c125513fa42e91ca1017c312e6a1db5fa67af54446996012	10767
1043	7095bb0ca674ee6d303e3769b33bc9bde682de3f06684a3d8527673da790f149	10806
1044	3fc8361bb1eedd11fb1274234ca56570797ffc5e73f42bfafd52bfd0433d411d	10812
1045	a8d6b606fe562ba2fdfd57cb26e269026fa0ab1cbf6ff1f3381f1cee9cbee94f	10814
1046	b65bf73eff09d4c821956fd63bd9dd33be9ea81e70dd9ccacb761265efa3620d	10843
1047	66bd0d558e0a44578f9796a2d3925a1892535da8bf4d6b7da2a9d7e00062ae11	10846
1048	cd16bbd27a85ffde8768b3a65953c6846462d44691128c92ada3ea510258a258	10900
1049	b5ca9a9e55d86b1d16585f017d4870a2a49237ce70ea49dec43970442b305592	10902
1050	94aacad64ec38bede0138e711e56f366b022fd0d11beeea3f249e2065f5338aa	10905
1051	40cf5f23c2082e836d6bf10277909736df245e72fb9bdc4740830935a7ac7d6e	10908
1052	2b33aa8e77e5fa927d0d1849c8417183b223ae4f13cd2f117d89cb41a8f97723	10913
1053	09e7c1042c22ad924de4320fcd6ca8f78248ad2f545e2618257fb499e8d34b36	10934
1054	3cff4a1fb4b815603cbdf7040f272e1f4a6b927e0d91f4328f40ce6aef79d586	10945
1055	99e23653bd83effce2a7fd9f6a691f10ec58f437ea81b0b066c7c86f2264ab2a	10947
1056	e30a48bb0e6e6b7c9c58b064749a8cc0f54c182dae712722152272019bf842da	10966
1057	5c407c7aa3abe6417f89f3a14e330de7bc00466827df89a5619adffd8454def9	10970
1058	e9fe535d478691630c66bc090e2cfdcbf8d62ed87aae9bdf6da6a56556eb5c11	10971
1059	96dcdd8447690f358a98cb3a59b0dd4729e92d74e5cbd4b87ebc08de9aa534b9	10973
1060	f05583c5afa21dd277a786df12d1579dd5c5669fb52a9d804f5ac96842fe61ad	10976
1061	d87f2b8cc45c0fd2d94463d62aa96842a9cdcaa309f4b3bc08b283a97982244d	10979
1062	47aa0e3f6457912c7863941d460b80382e5fc8082570f1921155153f253ac8a2	10988
1063	2bbae675cca65e15161bf5963999584e16e97208f2dce91a935c5185775c3f3a	10991
1064	50747ebcc87952827f04eaf0d02a8f4f39df3e6ebdb61daefe391f1ebb5c5c36	11003
1065	81642e62780d9863a7bb03f4df0304ff88fd4356999250176b5d17e130036376	11005
1066	095514e83a971736bfb2787cc162d80e6c72115407d9ef9de232cc43dc1dbe5b	11014
1067	20fc8634c35dcbe33a2004a1b180ab157888c75b1c0cd4c8ad6481f135f16aa8	11015
1068	5d1a17e829e62597c50225877344efe6b0b6721332e61df268afab5feee15c95	11022
1069	78b212af230882b839e085047a1e1f36e59e4f5ec3ea8cfef6a0b7fd660ee1a7	11096
1070	bc794b45b8420975bcf554702a2f9c58ff551d59cdf040745f3bf61764742e84	11103
1071	65fa526340ffff440daff1e9f469099b55dbbeaca507754932556ad8d08ade02	11107
1072	5965991a373dc52cde64188c7fe5d34be9d29fdc9879ec2838a29658d618248c	11122
1073	ff7f9f92669af6812949638720b2c9b3aef450f0a1dc4e8a5f8c5d67765ce6fa	11151
1074	7706f1dadb9217dd0bca7df1100afae20c03c410434b1778038a423f5c863795	11212
1075	6d76c21d5b862715fc4676bbcf38690ccd33e684123d5a3a57c7799ce7e1747a	11214
1076	a6c438cd2ca820d22d224318a9bd5f636a21600d5b86e4bc858da96fb8de7eb5	11219
1077	e9d81e9f733e6c49bd847be1d32547375b0332d6ce38f5a8aa2bd353d7b289a1	11220
1078	04050afef4438a6d1d26b856ed047e8d4ff78382a763e05e1af0673b647dba7d	11244
1079	5103af3989cb60d7f944b6c95f7cbc90306782607db4e79124713c4b01d65237	11247
1080	bf8e33a5d3e24bac377956fa98859d7e4ce946252c7d8b601c677606d3b56634	11251
1081	55e2bd695f09ee48a8649d4edd10cf7996a43059939e717a2642ac7f6e832765	11262
1082	db8bac5f53a5a15c71c74e221c5740dd4813762eec3e3991c0385d11fcafbb82	11266
1083	91e9243ec54d27cfd2ba47754ff7daaee4d4eb09ccff6d3c061117de5acc9c23	11268
1084	61cc332edbedce5e6a0c51dfa8b15800481f8ae3c9f39468b1768bc03697f110	11269
1085	1c2db55c118e2bf2f2e2ace8b2d972ac9e746646888c0a077ca26d1fa68d7e46	11273
1086	908a39e264fd17628e18ee15b78c896e0a81f999fe22651b67d05f66d31b8217	11274
1087	adab915ab0b382b75e15f5c3815cbbc161c63c7402effd4034f078d2f621ca99	11297
1088	1a2135e34cfb4e29c2994e0150a006eac1d48c41afc30b616e8e1e95d0bc8280	11308
1089	3adb42efc89997a35f0031cb521fae9fb756fb48c7b915fc7d286568d0eb6ee7	11314
1090	57e9edcc328e0a27b186529d45079908e9964830f69464d2b5fc6fb40bdde14e	11329
1091	360be7120dc9a636fe272afe26c505176638fff14ab4e856e8958852691decd6	11363
1092	6412dd58484ac2d010f7e1e394752b70959e900e8a3bdeb621927c4c0600fe58	11368
1093	3caa92fa4b11170a843ec42b39625de50324b7e6195d6e5e83acdd0ef1774642	11371
1094	6ba5680ca5f2c140bbeb24c8ac9f36d657d263415819ff036cff67c8d42dafcc	11373
1095	055238b86f2240229c559b0c3bf7c7a2cdccc8dd027cfda1b5c5a89337c2c834	11386
1096	5e53823833869ff815effe97c51e410ceba299495a59617e2f3bc98c2d8e736f	11389
1097	a0b0b19f27daac68a0da56a22f10d89383c8ed4d3ff162b199873be26177dd02	11393
1098	2ac4655fa12c221fad3f11c4760d6d293dcf8f751c48763a050ed12e6d657bda	11411
1099	5012b209f6c577fec4cb97870ebf9e73b4de791842a48e89b34787f409ecb0fe	11421
1100	9b0711c9779de075243664ef14b4dbc9cb84642776bb04c647d2a308037166c2	11427
1101	fd31c39cbddd3d05614d65fa48b806024bdd2fdad5aba5dff2ecb2e7235761c4	11428
1102	1469d102891e27c1762f96d0b51e9450e22698275a04186de02eb3d35a273581	11451
1103	3756cace105fa9401fe61d3ee5a8dd8df01d9cd6245b46455c3203b171624f20	11452
1104	2c231598fb49fc290a5e2149240d73b61d113001b4f8301c9ae4d6df4a2cac16	11464
1105	1194892260c299a70f137963a5687480dafb23e1b39e2c318130a2b6026251da	11470
1106	f2cc59692b9dfad114dd16987aa1a6969f924d0e75b9ff655a9120475475ac72	11471
1107	e5efde766d8e282cd4884774669cb830a865a3499d43625ab82c7018381a7fdf	11472
1108	3563abd39537408651c928f5ef9d2ad8ac7cad1da9a158d2ff7ce86709eecfda	11507
1109	f4c025ef7466017682df13e4630f64f67ed886dc1b25e0082bb5356addacf9ab	11511
1110	dcd185edb56d643c8d4d0b7ec4ff338d37ac88ea0e64c218242751f2fb866f65	11553
1111	b98a32818128a13e97eecf60cd9206239e0f29af53f22f969d8039be669dec7b	11556
1112	42d80d3c0741d6bf49190a766004e4521ea2b454ea1e5cb7f268a5f489dc23af	11560
1113	fb2a92f4ff7ac21908be02f841bd0734481d4d0cb676f9768c79512dc4e7838f	11565
1114	fa4e8fba779e52b4c151006d0615658905dba2781eaff2068ef01fe01b81de6c	11569
1115	8600ad5b8fecd7a5a3cdf0615a27248c948e9a76b2cc8e53434aae78a094c9b1	11571
1116	acead02753993bf2333bf170e7d5c11a949a70b71886874ae9f4ccccd7a00ee9	11579
1117	27c5015df493b54611914c81c1054b489b442e6181d825d755a82e18b085d0bb	11600
1118	e9e42bbdf625664887b9910739ca9203f408c4a00f11f3f6c908b0bd39fa6a88	11605
1119	8ade910328453f0abafda9ad8a00ad6bd71f6722e3ff2a447a21d7efda88af0a	11611
1120	c254ce037c350a0a52d4b003496dd6f0a0b9b76d5f7db9fda1b0aba6230c2d3c	11612
1121	55b81d3b67d65cd191cf96fb92ec9668dd88d1a95a622b3c599eda54a3e44695	11615
1122	ed74731a535011c297f0ff6659f98b536e176d4645698b85dfe0d100168ea551	11629
1123	e8b0a17f0ad7fbd6ce6ca77db4914938906fd809e38cccb33cf52f42b492fccc	11632
1124	6f5db78fe9c5f99d09e339ff8fa419f28f70af5e623ec4ff1952aea21638bbfe	11635
1125	e841033f1e8b9f716d527f08133d304ebe291be41269489e95622d6c23548bba	11638
1126	9c895a9e02f6bed2666914f8d72213de5434aa6ec93847078630863899b5d8be	11658
1127	55f9d71d3fb1a7ca9c6f8459b9e24d6cf4e568698b6f9164184ae183d7e7891e	11674
1128	2b8ca18b1c8876de575c8e918fdb8783d37fc0953e1840e7574a00a78eceeb42	11679
1129	99153629c178cb50ba9e47d7b868289d0cf4c03725369f6879c1e2698d8444e0	11685
1130	4533b5d7af91c132a7c360d5bf974f0739294fee9875c25ceef0403fbd1f8b35	11697
1131	c270a73ee467440264c23da44ad838164c0ced670a1ba89c6fd1183eccc798bf	11698
1132	8d6ba373fdcad1b6058d9badb86efa61d44942d4a24bb3f84c240d667f7cc2f8	11701
1133	3b3363cc54254818d1d148c81c755c0d5d399e3ed74289c929eae1b7be1e01c4	11702
1134	60cbec3944aa8d7b299ee2beef0559f771fb3209b22636440df8546de4aeda75	11726
1135	8cdf5dc52496ca8afd0e3223b9975f1f6b1321d46ac566560ba731d1cb5a3169	11736
1136	44d4fbc691693eeb8ae3147c7894113fdbac6a355da7bcc6f0235277afdac238	11741
1137	febcaf27e9ba6ffa225d43c97bde8b914c503358575c3fa75a8b501e4a8420f0	11742
1138	36861c2c212279e473ab7bcec7a3818042f8e693fa49e8f2b715919b8db0d322	11743
1139	9e5a490ad4f0243a5f531c598ebd90e45f225784b491e23b3e020c2e25256757	11749
1140	fd98bd9c25687e7a33da99d96139b1bf8f1fa1d6d9a775969692f40a4d060e10	11761
1141	d9a46c461bdca88f10dbab9ab954889b061c7e8285cdf8f76819c87fd37c8a03	11774
1142	c9981cb0431a0febf6846fc773561d1f68eeace78a9319ef02369e9d7819cc8d	11790
1143	63088571eca8256caca6af3cae10f7f4032b9cd9941b4f624d7101e9aeaf1af4	11808
1144	1373f676834d54c2c417e9b8f93c45b98a5a9bf9e14c3c41638f06c77f514cb2	11826
1145	d82344254e0b998c612123c3b30306347bee5434148af5bf54e74f3377e9fe7f	11831
1146	4dbee1aad846282e055daabef3a76c93b795e0e10739e3a95c1c7eb921e73c2f	11846
1147	6297e6a042547c8ce1f746f50b1b5482bf70e0bde96e46914deed062a2478eb7	11849
1148	d59237489ba623fab34e2f3dd6bc2a67ffd327c0ec3a98a2d886f2f461ed21b4	11854
1149	84b1d0661483ec6b35b13baf55243ab02b94762901b0d1ff37861c3899a16721	11864
1150	e5f43f8161660ae36cd96148c6d4ed4fb190a84513eebdc582ab63879041a7cf	11868
1151	e6fb3f3cc77f9ccb6b37008e06769c124185f4870898f2581da4770c9ef316f5	11870
1152	1726b4c21faadea792dc47725df6f6066f36f7f0213908714cbdc8922d028eb8	11884
1153	c0c6306e3b3c3c5eef96b0f405f98edd843fc523f6be15b3fab45489eac5937a	11889
1154	1cacf3a3748b8cb3695deca0cce5fbdc494e41ec96d1ee8ada674cde47a61b9f	11907
1155	6b11758ccc08b8f65a6a7c401f9454a1fadf950b5aff2dffd7bacc1a81a5d517	11914
1156	998959dfa532a167190746e91a26eef3eabe004e5654e4c27f8aa7c034f060bb	11930
1157	b2d830ab9caca79a85039fd1025b2365f3d758362159c746da935c17e12ec456	11936
1158	17f6bc405fbe70177d0f89e5bdf637b83b3aaf1a61c4579b9487a415074338db	11947
1159	b0dd68f4ba659b29d39a6a3659d80de5ea4a5930315122c4e123061eada77380	11959
1160	c1dd0bb442584859a53966d794a76626778a5c3f87b3dcdb3320486d767bd83a	11960
1161	251002204dfcccf7fbe847bd9606b2c5dd2ce8b2bd22b912ddab5edef14f611c	11961
1162	72e0b633ac2bb3f93f80800d9e7b1b5d816350aa36d1d603c224c6546650c62c	11966
1163	49288a333e996686efa1da480e9e340c947e746018eba623863a1f33fc4fc073	12000
1164	127e86142e68afeffa45a8ca10b2d3da175361aa341d54e375b76ecafbc3f6e7	12001
1165	0105e00d2c6976f1764fb04b1326774b8eea4a6a1119a5f6e1f3467b7b1f039c	12004
1166	270d865d5145f37ec8a6e8f8c47b9a30640192c1977ddc7ccaf7f2adaa6f56e7	12069
1167	0a6317de13353df554b1b55c88a61c00bfb07aea88675984bfb93651bc023dc5	12076
1168	e12b2c6186686d3ef6abbea9c08c4113b081520129b75a01ccbc7f2402769739	12091
1169	d099502fb1142466107f1b1ce66fee851fea13d5eed02bda986333d85f68288d	12100
1170	528e86a8228b26fd0d8d2de50d3578444f93b368b6d6b61430f8efa33e148e23	12106
1171	f54e07d2b580e356179072b1c3bb024011acbfaf81c28e6df0c5a41b0f7094a1	12122
1172	2490f1fcf92b396c386090c9a4a09c06ff94065b7802b02c6762b8a793b76ab4	12146
1173	dc90f40b8791e306d3aa0f0abdc565e5bca6e7fc6a4e15e389e9a8398c8d796d	12150
1174	d1e828cd62687f8a217d8e46ed74b9d35ac2ac4d1c013d9e882e5474443f63f9	12155
1175	0b6406d7ab4d588b9332f7ce07d1b635042fc35fa206838bd40acd5dd548e5fa	12162
1176	9117f9e665b5e8b0f49f826964eef222ec0588c1c218ff97af18a2db9d785c8b	12163
1177	7af7181c128ab73d76bb1b80c87a581af855f2da170605dfad524be80708fbc7	12185
1178	a236956ae4af63f19d7d3e76b508e79259adef2a0a7cd6faa4bdb336d2b7587f	12199
1179	6f7a024552a33b9c0664d6ab2f5fadc5a4a88109d6526754d52535ff82046c80	12202
1180	efcc758b3e1b60ebaee205ae260af32474a2b5fc200312236c6b60d98104e240	12205
1181	7b0df83c7f16a637187d6939e6aa4ffd352ce9ec1365d58a3e86f478faa0fdd8	12212
1182	152fc67250d33cf05914f56efbdc4f7d8f69a69f762142b10a0f09c2d065568c	12216
1183	55146b2a4507531609ed06312089104b0e4dab0bb4444ae640fa2f4b15b9034a	12223
1184	481601e79c823b2a8e8aeecfff871b4e5771d4b3c6beee4e0065d4e939f46566	12227
1185	491d48f2a76553b82c36498d0248f31147bf843ecc68665e61c6dd4067f16932	12245
1186	bb0547cb0a6219667cf8e51b1f2503d8dae0e4a36568119712cd1c4fe6c06506	12256
1187	8e5aa9c89e2b6ebc362df9da19138756d8d40ca4b0028fa0dc41e809d55efab1	12270
1188	c9ac25d3091f480cd42289a1abc19b7f4fe0deb008d51f021ced0d6d6f4f6c63	12279
1189	1ad818a426b2da022162e80475653bf6fe24015d204cfe6cd6981450ba2dc117	12283
1190	6f27928e3fe5ec0590676f0acd7ace4a760717b7057cd47878dd91efc39fe7ff	12298
1191	5bbf794580c7113defe115b2bc581e2eac9c1704087a313bc9bba01f99185bb3	12299
1192	d39a8b1077a0372bfb27bca347bfeb70d39e1fb85c6e3534c7990c54c6daddfd	12308
1193	abb684ae645bd7e0220545331347be946989e5087176e8cb74fe4f1bf925c234	12320
1194	48a605da8ec1cdd9a7fa716606c6bd46baf9e0eef4ec5b92498ab1710add1c17	12340
1195	65c870daaf4d803e9f5e7f2ba09df5ada78748d829893a1f04402f1770efb58d	12343
1196	2b98e177ca01e7c28f80be2a03bf31b66e5cceb112b1b68ea7aee259c6e0c8dd	12344
1197	9ec414bdf992f4e541e8a4675460d23900c5f574b56cec25726a8f5cf5c1d3d0	12355
1198	6c8fc572cbb32e23e4ce50ca5cf0488f517c2c504267d4831bc9b3daa31a69ba	12356
1199	82d5d4556971ba78512e6506e593fd5602d43601c4caa53fe1e1513df5ef6bda	12360
1200	3842b78f53048fe2453525cd413ddb09d70a57be8f5d61184e098bd3b3ed4d04	12390
1201	6710ce11e50f73d693d1381f108b53f64e74b1ee678ed3666ccee4bfea6b8666	12414
1202	13c4d954f85031d2e4aabe05eae0fa42a4979314b01efb36cb29aa933a174345	12416
1203	baf569c55471b9ce98871bb937b7a0cc72caa475f009a1e20795552f0a09c4ad	12425
1204	6cb74111ea32695e14551205b3ffcf1e1a2fe55344ee39748c75bf275dc052dc	12428
1205	e906dbe31a27d48d090e81104e71fde24b724745a792bae167f65df4517a9f21	12458
1206	b166da5c5b2ff3203ea6049bbc2cce3a9c311de3021ba3b1e2999d2cf84a7c27	12461
1207	d1b1054571e074b68bc644b85ed13d16e18a22c31e463001a8d59ae9c1bc3cf9	12463
1208	8253d525e08ed023ad07af6cb726806949eeff33422466a75accdb76bb06048a	12469
1209	f0c06cbc46b064c33f0b1545eae33658a65ec7d37eaea0269e775c7ab3835262	12470
1210	05027eb6ce9a19ae4bc6f9298644a1f8cbf3280b64181fbb5e6baab7802f9cb7	12503
1211	5fb6ca10fc81c0b1a46556360a6fc7acd6c4b5ed6e7646e811f70d9f3c040b93	12523
1212	a57012a603cf0e8f51a37e97c273e08574117211c8142cd9b87a925a337e91ea	12542
1213	e065d1f10543f9ab79d36717b629c5af7a7e6c37abb29530cc6fb26e7c6a406d	12544
1214	67931d339fefd1588208630c2743cd6ef31fa880f2a151e0e9e5008bf45e4cb2	12548
1215	26d214601634aa969acbf43c670f6d018d78711d343ea1b2e1c38ac790107f0e	12560
1216	d089a0747e99dd8649926d9812a5eb7259a262f8e1587da4a768dedab410d5e8	12586
1217	9dbb320287631aae7c7ff35071d09506a61fd162ebb336f95e2f5ef98934bfc6	12595
1218	ce323f1ba9c70a5819342f14721ee240e5dcbdbca43bbb8a3f8a3749fa24609c	12607
1219	c54eb9e1d3189b0ed5297cef967dfef3679fb0cf3493985e15f4378ef8183148	12610
1220	545d94714c117718bb2665a26db40bfcddf26fdb29a1849cb8316ffa61857927	12623
1221	47ff1e6aca3f0660e38b98494e78df892b61b17dab268d1bb990911c448735d3	12627
1222	cfd2cf43a78f833336436672fc6e7d446c2addab19722bed26e19f5231627fc6	12630
1223	d2aef1a2f9ca446b04008ed2bc4688f1ab83b49eeb860e985d295b904ce1c51d	12631
1224	b8a2c0900f2a91274a712ab9b588ced0798db73580f22ac42ca2257d61f8b80b	12637
1225	c031311fd8a49bc797fc7f37a4ae859059b4af497cbe95125a8a9a4bef8d652b	12647
1226	3a40f9e2b0a5497a47372d3aa2078fd8238609cc1cfa87426e065879d1c94d2f	12660
1227	91cb870b00695499a0cc5998ed466fd3b599a6d479af65d64fd6da3cc42f2578	12661
1228	2fb3906d99316edb9570aa484bc665dc752e82e52048b4ed53419578657ae3be	12677
1229	3fc08033dc927580a85764cec21804009918042915a9e3b77af08ebce3164374	12691
1230	a500c021930dcda5f41f1d9190c4bf53470692afbd27d11e3b6e900a6cd09059	12701
1231	61c2d994f52a10a213eb87e7387a989079a1d316b3b70e78a3796df0548dafee	12704
1232	cc5f19cf71377d8bdcd659036a04b517619cf7d5dbd7e49842d75b834e6d5c40	12708
1233	edfc9420198ed09b8519102509fdfe69431f381aadfd0ed167f91d9cf1350c47	12713
1234	103ce5b45b8b5051297302260ad02d51652dc17755f1ed69988a11d02cf6ac59	12718
1235	cc197f60bb8e61914417e7b7b6e94abe2aaf83c8cfcc1fd14a601ec9c9b27458	12724
1236	a2971046d18650eed2dad0d0939ae959026177fad619d2d1308d502d2a860f56	12735
1237	2c2ac40ddd8211e48d4ce5be44e0b1790bea18b695fc5227a58f1775340d9a94	12745
1238	acf4ced39484e61e57d5a45673aee1b8c5e47d3781bb645139e3f5b270d31939	12749
1239	3f6efb358d939d63ed38f466829ffedc2f9e62e8dad8b18879e4c9ef41c5de80	12751
1240	97a820294ab2e2450774dbcce2a5e682d6ed77e6381dddec60ceffee3718ebe1	12752
1241	f617fa701a2891ad2e1f23c67f1b8e7af4ef58fe84255e728466542495633f94	12756
1242	6e3e98c17f7e224c06ea54bfcb3ccaba41e0c7f81db538e98da57a93ae75bd3e	12767
1243	afbee90d2560a501694a2d3dad52ab3993ab16d7faaf67572fd85198d9e777f7	12790
1244	256f25898953103b0af114f0c611fcb7961d119930a79b91d27f4a05bf6204a5	12800
1245	7d25be0990f5927138869cb26c2340705716df710359818cb3d3c47141fff052	12814
1246	48036664b6e22659aa24efd61da8575fb84282cb63a7e068f57c22f974222c43	12823
1247	9400a12e27223a7f3a703518c2fd40d2be29ec9311c9ac864e1782778abd00be	12824
1248	ff6043972d259ba2d2d967b9375da6745a8f2e99807c376e665f1cc99a8fc9dd	12828
1249	90d552a3b04341d8919e3ee27ed02bc4f1bb8d77ed4bc8aa0c92d2bf5d9cdb9a	12848
1250	53b1367945b6c3774e5b5330fa4727e3d9ec4d38d8cd9b8efbf80c1b693c94ea	12852
1251	3459c2b10711d603a8e59057b48aa4114a9b58bb1ebcdf7e60ec284ed3cc6832	12853
1252	bf42f23d187d5431d86dd908a7e48bf1b5ab72fe37b24069d9bf7fd147c57d04	12865
1253	0a372730f1eb4c3c9d6bc4a80def95024d4082749fe134745c16d95498937990	12870
1254	8c4aef12e86bab1e26fabc9031c9c74aabbaf3ebc85df2325488b2496d2e03f8	12871
1255	0fabf8e9f16f4b75e451ef8c3ffc905d7677974fd40bf6e4df77c570f4036deb	12879
1256	3fa32ffb37dd4bca14009d2d535a5b5d7b0d5408469db26f7201689a138e5554	12886
1257	7dcae40abc5bbf5c4d59535f9891b6e90ddccf22061ac886ed1ee540a83ec085	12897
1258	fe263bd83fd631139f93e95dce2c550fe7679a1519b63fbeed73da72a377324d	12907
1259	059a8aa8cfab2afa26c9da0efa5afecc006277b127240517572b8a71cb5a3f1e	12933
1260	430fe3d77c234f08495ea0aa2bb799ee8ad9dfda0650a4214921ea0c70fa7a7b	12935
1261	9a77ba24840b9ef47b3d1a147db5fd522d29ab45fe677af20d6111484f45ed30	12948
1262	6df2c2c416f4468c64f996414c87e2787dfad9d12e3f41ddd1859054a0b2e573	12956
1263	8407add7bd7c8c33c1f66d773c0b4e3e44984ae5bb7a2e86e247a99fde294c77	12976
1264	ba896b9184092b922baecdab0ee4a4c4c3409479b9bf883b0b968e13dd22966c	12982
1265	609e37a7a90ded6d420df9a84bcf9f82a444946196d68c1db5daabdaac40a5a8	13015
1266	62726156eb91c148fd4dcbd6823a493cfb156896f067c1bf365cb44e8c7e832f	13037
1267	d323ef21427691f13fc851649de955289cef1fa7a9315d3aea11d8358ce9df91	13038
1268	9919b01e1bbaceb1d77e955af41744853b764b4f8933fe3a49729e7eee454a91	13046
1269	1d4c6834091ac8b5455f2c6eac0263348a87441189c90917363fad22f1001754	13048
1270	02e92047534697ff6f389a97685c63b5cfc0f1145c29c81fbe09cd2132f72312	13053
1271	c010410f441d56d59cc982c2bce67fb1d0b0080577bbe254e82e508a4bd6b6ad	13054
1272	04aa1d34f91d812580b5d99fac1be32d64b914183bea39b3bb6d2e9bfe3bd987	13057
1273	3dff24de626ec2f832778e88807accaa15c86efe528bf8ebd39bf181c39081dd	13067
1274	650b524471af8defbd6113ac21367ae39840d5ffa2df75b4e17d5ec6bedfebf7	13069
1275	1fff0402becd38619a218cdfa18e273d749ac403c4966456eb45a65f38792619	13070
1276	1b2faa4b5ce308044a5afe16c024ae6e1849ccddd306b1d01d53e1b5fe027dc9	13089
1277	46a1bc6508c42ac3029b03c75fae14b8da755c6f1ae776e4d824221dd91ab62c	13095
1278	d7829da8d7356d97f2f9bb1f5886f38c0a799267fe4e8ea54eef98153c2b8ad7	13098
1279	4418180fc792dcf96e09101dae13c77f1004bf8f219233747efe27c3c2cfa859	13112
1280	b23f618a80c89a7dc9554cc06362ca0220a5fae53d55554118f0d86996cc1545	13127
1281	45edf72145bc24085dbbd73c375a0b32e88bc5cf2bff1b686762bb1790ad547a	13136
1282	f759c1336b17d5fd3f2da40bd40b3d4d841429426bb5cc49ee98293f365818e6	13138
1283	255485154827ad36e0c60a5ffadfce948b5349693237dcd9f667ba1b2e60c78c	13150
1284	e892a7da6eaff74786b19c85306b1aa3178e04ede1404ea44101395710707838	13171
1285	5ee7007ee32a8e819c72cfaa863329930f5678bd2cf8ecabf807537ca3f852f4	13176
1286	c64094e4b1eea0c6485bf127ce9167c145511f4fe3120e6315474093320bd066	13197
1287	65fd3b312475562d75de8ebe390d02f4715c23f7585822bebe2343b8467e1e08	13212
1288	6b6348aa55e5a169d5e227772d2064af0a7c6996aa1f46f74d33027c09f42f4d	13214
1289	53d2262fb7ebedf2ea528cd12b851b19c2ca6e1c7f1134bcf364b73c2505ef3b	13222
1290	f68bca07ec6e06562d951a05504cb02331632a14bbe6832cf34cc69cffe197a7	13240
1291	e28fe1d9271bde5fd41b8c5da3eeed618f6486504f760db7c02c2d2b8a6c6649	13248
1292	78b36dbe2358cc929fe9cc4bd46c7f70fa1284d49847bb48eb55c31016f5974b	13319
1293	12087d4d71e897dbae9cb534a3276060d83672badb30de9f2aae8907b1328a7c	13328
1294	232be19ca01ff4b76211340376f0b523a8eee666a080f106e28e0eaef1150fe2	13337
1295	2c37262c27cf09718333a82b30f9cd01b8039a6d87a087259bf7810a7f5fe330	13348
1296	167e7a697ef6b140135f80e4a76bcfe5d2feab39c6d7e5fad712c16eb751ce1f	13349
1297	45341ad78c3528c6b3d22aa464cffac0ed80aa3c8f1fe48b8733a650da443ca4	13371
1298	9c5fb55de64e88b50e4c4671b26e68ef7694e5bfcdd8780f76ac3b04ca17af48	13374
1299	eb0b5d95597ee1c13509b8f081742b202b977fd17acfba57bfccde78a8b9ab41	13376
1300	febc2782512359939b9a7fe4b44811b3d4053949fda9888f2336452591f5e392	13385
1301	b5873397c446c70afd7ebd9df400ce7d4ff4c2ffe466c0737fd5e0532090bfcd	13400
1302	be4437eb53299d66020cd8c9f01f7afe648eb2083ac47e563e7cafbc17b4c9f0	13408
1303	4677cdc5d3698b2a2e264fb71576e16c1a0caea2ad77b132c0cbe106cb47a070	13409
1304	c5326a7e234cab0085e2edc9347fc445e77d24ee703b370a1d06494bc765c84d	13413
1305	9f31f9c16e89b59fac455eb8f92f0d0a56b521c0491d1c2eb556f1dce4b61b91	13420
1306	3a2d42ae62f3f8fe416f0bc67a59fa703c5857df76c171871a20ea240d263713	13422
1307	c5b9b58906b4e066e1f2d715de7d1c005992719a4f4aad6a650114840ee0ed4d	13432
1308	b91302d059d09c51c0a2c00ac0da4f1ebaebe486d01883206ab2c75c25b66157	13448
1309	006bce4d3e0a5513a71a0424dcd29a2f183f827481198ae18578916caa5614f7	13449
1310	eaf22fb5521cc855ecdefb73d7b1809844798b12a6ade8d664d4b274ed7f470b	13466
1311	ec2dc665b132de58e6c27bcf4fb327cb3f407e72be1b66cbb6ec3b922a0fe9a2	13477
1312	ed4f0a346c36e267a935dbf0f540855bc1b7b65a1b3363de80193fca9bd7357e	13481
1313	d231782ece54cefd96f0ce18823ce1c315f026c9c1f36564ed6e2b85c4b223ae	13487
1314	4c88ef90edee554b220e762bab5b087018091058423ff21c6dddc65b2595dcb7	13490
1315	56262f3dadc8551d288f731afb6c0a0fe662aeda6a57a5e09fcd32a04afa80ca	13509
1316	6d221df6fb440425a821b88792034d6cb60c3fe93bdea6c65ba5d34c110648f8	13518
1317	6d370c942be120ea788e1bfe9a5b3fc7feb7657a592444b6ac1404c3351a0db2	13537
1318	3541d064f13fc6ba9d944fa2efc98fab1f38cf3a45b4e8ec0575f869f234d128	13549
1319	a5d63d23ab4c87e7dbe94da577afd074782e2c579fdc9ef46119ea8a6e735b7e	13564
1320	5fa3a1014b0e38127b7763a8d790db37c991132494be0ed26e0c24c331a6afdb	13568
1321	41ce17bb85773c421c530f865f45cf63d9195a0f48ef88d10cec91740c5cf8b9	13577
1322	4fab6866bf421aecb6f05f48bc6145d6c8f6644c04c5cd1c5068ad351b40ce97	13581
1323	0659ad50b1cfd495724af641a2e4de0c284171c043c0fc80c7f3ee8c01688bee	13592
1324	9bf7213ddf748680334864678152f3b46b22c690b4702416472bb1f0b7f8cc6d	13618
1325	1310648818270ef7a1c234929cdd4778c643651b015b6b6137d024902de644d8	13637
1326	131bd7bb293b249cb151fb23143cf53dd5903f01bdb3d2155c87ab674eafc3bc	13648
1327	547d78878fb77457c00b4106b6acd87f709e9ca8f2e843dca85c435d265cbcd1	13655
1328	bea083c4d0b0efda49ff0bc3e25de03e0a72f0444a13196793c9aa2133bf2bd2	13656
1329	463b29083e0aef7e7eff7d45f32a7a925a841632866068be937ef847402bc4c5	13666
1330	fdb7d4e2a78badca6b566fe21fcc9a08bce7656cdde2e338df117bcdf3d948a6	13671
1331	294558c46e08e3e22876b36e22904aff3b5d1ac1da894c7f132777c4ed8fddda	13682
1332	fd98eaf026ac6207e81836396d2021b61575781611b701059b816e230592a66f	13687
1333	73189a2ae35062dec884b8b7024cfdb9d70730cc1632cbbbafaa3c79f23b6172	13691
1334	8d026bb43bd9d7bc1d3e7ba4bd09016dbf0b0f70e2a2f24e714bfd9370211eb9	13696
1335	4d09c53576b3bd530e40d355a263cbdc0308fcbd0681e6417fad14cac33261df	13715
1336	8cb84d5a8401b6f5a513e196d86aa85f6b11003dd2b31d080e0512c66308729b	13727
1337	02b804adf99a7fbd20a8c05a010870b965cdef3b9c72b58b63b9f8951626b5bc	13729
1338	358d6c72e93e18ce746cdbba38141ba330b61e2b25e9e45fe16cb252f694ec02	13732
1339	933c504e4f8088dbaa17680da493946db2c8a73ca71c26b0c10caa1a02194935	13737
1340	eca3e7c2ec47280e805a5d491e1502a10159979c65ea0688ab57105d8e340a3f	13742
1341	e83689dc08fe6c6fc44609b42295a517807711dcb0b8fb49edbc6a5b98b2669a	13756
1342	80c4973814b0e9ea62b2ab3fd4649de2c998d85fcfe132434f34bd1ead9ce00b	13760
1343	7e6490f6af1cd9ed04530f11519cfb140a436d6cbc875a087d2287ea241d2664	13766
1344	444e3161d5673e45a6d54c946b4a796e940c0e628a0f90bb301305485eaa19ee	13789
1345	8821a02b267026176035d3089a013688d5adc6d1f67d51fb74b86f5cea9ccd8a	13820
1346	2252e2f4be0ef5b95261e77c56e4dc5ae67eb2403a37e0f89325a8c717a64538	13831
1347	6e2811f62e09c4b14a9ffbe1a9ce031fd047ff5c1443b36f2cad69d3bc0db066	13837
1348	5347edd5ee75f4e6fb786301efbd8ae8f4698b7b056c4d08fa2077b0d15565b8	13840
1349	f5f2b36027eca82f077f665776853119e1558c994b1760145b171d6085bf9549	13843
1350	6135ad4bb61daf954c8b746dd532ab621e4a6c793b4fd4a49f177bb014d71144	13868
1351	66709007ddafc9cfc7da6de80637520626675969d52ea141c11c92dbd3c4dc5d	13882
1352	8de685bf6d678ea5b77a2e9342e1f4de597c0cb6e37e03eaaf7b9cc114428f61	13888
1353	ac24f7680ed125add0e9da47c959c88dc12ce1a02a37f47c3f21fb4fdc722afb	13899
1354	6cb514f70f6deccecbddeb6cdf7fb751929e8e1be6ddd8372cbb2902a8c27f17	13923
1355	04e89dd979eab7a6e1405b557db2fe4d839b5aba27872b38bee8aaf820863008	13933
1356	7c93a9e96836beafb87666b73119b8444fbb9296c1d074dca0e696a2690a85ae	13946
1357	b285703c81d65d91584fa9610785412e6b1f5f4163e08368eb2f6544a111d92c	13950
1358	df7de3dcf5042748fa2a50bcf403353b52484d323a4fc710796abc2979d4f48d	13963
1359	f13c30333905551cd4ed7a1695ebc1b9a23593ecb47f7c981d5115f05d218e2e	13974
1360	a62e57b7848bf6be7877e0b43919360ca81f1bcadf42976af70fbb9032b71225	13976
1361	a927228bcb582757ce759ae42634966e199a29a37339ed9cdb84a68fddb89069	13977
1362	2f679e650ada31b55089b4f71a8d5c4b4c5747a863bafb6f85c9a47adff38e3a	13978
1363	fd7d279dcc77a905b8503cdd6163cbb705586f16b9bebd42aa4a415275478524	13979
1364	607c18bf07f0c798720d9d4fb5e8b66f0724904895c64c3d5b63105b49f3915e	13992
1365	f1bf8295f949e0dd099884e40ef0e36c8e9e9080d8e4f1b7d351cf2305c1483d	13996
1366	6f5164eefd2b320bc6fb47d96bdd678b95c360e1ba286f9409db6c1c52400290	14008
1367	2ae4073257763ee588c79cc9b200b508801ae883c03c2efc7546585b7c843989	14011
1368	96d688dffb867585d4e5bced63dabc238347e2ab5cb88c27cec1b1f6aad48993	14014
1369	e28b4c455363d6b2c29faafac30232e1a951ff884cae3292fd2a2b29bccdee26	14034
1370	bc75e07a107035fd67ba6f87fe3a6c38d91a63514b8ddb9715106a4b39a00949	14047
1371	2d4a4a24593a466a19ffca5acb718425589ad85b08e454cf2370daa76afdcb46	14053
1372	5003a3091344aed60cae85c08fb876ad0c1bd0c120602389f128ec3fe5493902	14062
1373	9f3a8db3f46f74652c8697a99460655b13fa032ed04a573a9af9d3e7d19036aa	14076
1374	00504bf03396024930e2c7907e61a23fcadd8dc92a9c493865f8ee1d13dbbf2d	14081
1375	524097a3fbcc4010ebf085f748535f5f9da11e3d25be4f69176b0b1c572b8273	14111
1376	0437d223a13fd3f066a6c1f467b875798aa3de8bdfaa202963c312ab5b83c3ee	14118
1377	f71acf9ca12644309a8f006fc95e3362d3c0b589cd3e6ae98a92bef2ff40c81c	14125
1378	702df2c5b06a43f456a8c430dfa552f6e10a297f7e6ee6766807972aba952313	14134
1379	2f685f17c4c8e46c7ccc5f7eb058b2376dafb3885882a375df03434ad1230463	14151
1380	4ef812bc4090b42022b7783a2082b761d57b8b1be52e92fe40b420088f60b71b	14157
1381	62ddc0589954af705f502427b66ea7b7c3616885c18331a16f59ff5a5bfcb24d	14169
1382	a54e8ae50342854004b67bea265a63edd4259e5d32ef2881116c183855ac5de6	14198
1383	58a33d809f6fc31e3badb0486c6a1d9d736a17d556e0e4eacd71416b95eef98d	14213
1384	bf76d8735e40c7efe8c611e6e3593c8abbd48e101b9cfdb2acfed8d94fca09ab	14222
1385	5eb7f46a08e2bb12bde2478bc1a4f0445658cbce7246be49124c242abfa3880a	14226
1386	26c59b0361ea6cc9e1d1af76864d3b4c6e2441f87ba440a268bba944173947f4	14227
1387	a495134d42510e45264d0c3f8e582a2b6068d89607c86e0c2ee4c9bb6036f2f4	14228
1388	8a8634a0535600130d58ea0af45dcda2aee0966f1b2e4cbe229bb43494df7cea	14239
1389	f6374f555353374906821013d18c51c206f9c9861cd9ad328a9e57db8cb46762	14240
1390	128673d5941f914a1728d8224189b06c31f2ae74032d31a9721d5682ce1675e9	14243
1391	e438ca368d1789b40d4e59710dbc55bfe6ad224b46c78a2e69346227fd3a932b	14244
1392	ab87941e5d9a0f558f0bd02a63b8878f2c8b350ec997a5506f25d0b586d6a98c	14251
1393	266538c80496abd597981f512646d13c30d7d9be32de6ca7d23234867927ba0a	14277
1394	a128b23f6491eca47411f76818db1c9f56e40ec2e539b99ee0e7fb25a15ef9a4	14286
1395	ed1f87d386d609dbd090b53d318c0a100abb5802523b43416b43f854f82e1e8b	14293
1396	56e081d1a498ff8c528afc165d65848dae54b4893ef9cf76d9eec4137ed358f2	14297
1397	b9f82be05869b9d4b4f564ef5154088c5296bd622f412162adb24326cfa25503	14299
1398	99ea03ede369202c01861871551ddc6b4fa834bcaa42c3f997cbef2447d1346c	14313
1399	1d7e85628e5a209afd3f50a6ec3f532127ef0bc694aac622c3c515b9105c6fa4	14314
1400	8f253282435c3fcac13379783e5212cfb52345107eeecbb7c9f0b684adca8644	14317
1401	b1a870a5427f45db42b85b48a429dffaca86a2ace079ac2c63568081b189e7f7	14328
1402	d8e94dee29131dde6fcf84f983ad337109f3f66d5a40c081bc1b87a1a6cc37f9	14338
1403	f5682350af52649de5641fea0cc4dc11d0f4aeefa7eec8f368eafd4a4ed4e524	14342
1404	6e4ac96b7f6bdf6fb00d736260f0b069eff4b257b669f2b9c2d8feffb4251d00	14351
1405	1eee5aaf73afe833d3140589f6d8bc9ed27a99ec330b7cf85854ec66e844e301	14371
1406	b8d09d2548868842f2f9a2a20cb622999e8629213d3d1b246f2ebb932fa765a7	14372
1407	a9e399b91e5aed7d1dc8f4bc5a2d609b1c05d18a1b628131a5c4b2234613694f	14383
1408	2f039f11fb2a4928375270d9cc1f13768e9c13383e1f40263210d330351b6e91	14385
1409	465c4f7910070b29406ba60521fa7c8d868f964224fea6744b44ed2465789466	14407
1410	3fca459c02e74f3e2708dda2b0c67b3ff319a47890737e07a2c90ae5a2815766	14414
1411	75184b62ead05dd3f40fd53944b1a74ca0fcc383940feeeb6f83aa7fab3af1ff	14420
1412	e10a58fbd1c9f89a6d49223a31e67beb1e8ed9d711febf4b4745ce30a7b53d7f	14426
1413	ce7099d311324ef5e2f3894c9d038846daa92d0d384d2ea98ef122f1cc1e8a03	14427
1414	083bc42447e0d392a442204498aacd2c3843211d49db34d807e3566729372280	14435
1415	56fb2dc9d20574f324d63c60ecf491f8b8484dda61d70cd471c3fc48fc60b9dd	14441
1416	9168ae376de9245b802ae400da270aa5f44db65eb31d02d4d5a868b7c28616c0	14442
1417	905b7bb6bdfe2940cc67bfd258ac1b5c8bc07a52573d5368804f130ee2d900e8	14464
1418	3fb826edd1bd555d936b71faf9d81d4a30c755a667798ff27d4d8f34bf8aa840	14475
1419	0d97256fd08738aac83342bd556cd6755aac1dea2a11b8a89ae82d293de2d4cf	14494
1420	2cb2a252ccf7986dbcfa333e809ee4110dc35239ccbd28b6365ea9ec829f8e6c	14521
1421	6dbb22a14b57eb69fa8285cc8f80abec9bb749e25d11b00298d237aa015fded4	14525
1422	f8fd7a2991b71b49522254480dbd04714f9c3bdaa5509f9316436f64d0d05cdc	14546
1423	996aef846ec1a80796abf058d02dfab238736f9adf57ffce095307eeeb453f04	14573
1424	f50fe06917f5850a5de8da9f425b79dd8a6815c9cea25c553b1f21f859650382	14574
1425	da05d1ed37a131cf3b51fc18374fe34c7d336d090e2e61b9676f64e3ffd75504	14580
1426	1fba69ee2bcfc484a9ced4ab65156db46df85bf83bec937e1cc97b71f32b4a7c	14619
1427	0d1ae299b083d6e7b7dee17d25e02d9ed858872b1969df3908cb80306e40a00f	14621
1428	fa0b3088b85fd560ba1affe455fa1c9a934365f13ba1c5056adfd450d67a0799	14635
1429	370bac25b3eaa14e4ce02bb487aedfbafa5c346faf30a9b2a04909485dab6a7a	14643
1430	9eeb868327437be7eb2ebca728f517158a6a0abde7ebe1bef60036ee60b80e94	14646
1431	7f8e2c3c84bb4b8a09edba680f70a8d2183bec07fa2b45650c45f6e99c5c553a	14665
1432	d7e09072244260decb0d96235d4a84088c433a6aad8aaa894d64fa759c2d7247	14667
1433	26b995e1d04d62a5b542f7bbc96daf11aa06b17e091f2b99dbaf5eddf8f66055	14679
1434	f18baf61cfa161e90701eab3a69dd348a7d1d09ea9d8afe50a2b537924b544cb	14685
1435	4a785997a682688cd973c89dcdd5e6b5028418736e7526461bb10ea66eac3615	14686
1436	ba5edc6d00260c4686c7af5c444d8b91962815212c824f269bed91bc167504d6	14701
1437	77ec7e9bb15847230c0efbfc4093a0022e7d3f8dfb92e754b854416703377831	14702
1438	817407314cbaa1fabf92cfdc78e8816fed537b041046d42ee1914a4059bea309	14708
1439	bc76143b5dda3f9da4b020d32c2e4ad4feed78ab543afd0bb437d92423d49057	14711
1440	fa4183d26f0610a65f7c323c95501015834f17c43a369234d47709660a1da648	14729
1441	b29b3e699b0c7b9f79f0f06a061724de78e3b92d3b896fa090bafbb4fec55e4a	14739
1442	220a535e163bc7f1e9201fcb86e10b40a59511f26accc75e5529a43d009e4317	14743
1443	96960206e047b29343fb943e068b3e019c2fa61cff2e6cff71ac71f9cdecfdf2	14778
1444	ed36719d9dd541f512c2831b2c2817ca4d2898d15354d5ad15adb6a567039b9c	14799
1445	e0f7a2ba6efc027e8c559c0b9e399059ee38a96dff5d6a19fc80dd84c4e3c736	14815
1446	21010f202c2506ed90a74775afa69df02bdeedcdb1a342f5770ebc8605bb0d28	14818
1447	86bb5a02e79d01e0e9b52560ce6ad584c52939a5f3bc1373e5b52cf1f429e65a	14820
1448	cc834ffc06b084e26487f1ff05adbe51105e9f4bdfcf146742fbfffa67be6f86	14837
1449	3f5a7dcb7be74b4d26c913f34b4b42778d4ec2e0e6bbed0de6abce1746e1d3ab	14840
1450	9ce91298256fb6a8a92cbac447de74b06a835aec4b08db6d8b3412a7d5c9f2a4	14842
1451	29a2c6ff1c86cadf561ccdb48365d73ff84f80bf298a8cdc254946d78311ebe4	14854
1452	7835dc3fc32347b96aec29f03f86177bf36e26656ec7efa3f0ba004abec3f8e4	14856
1453	145a9e6393f42c0da5aee1fb6f9b7eb3a802f12f1756b4b5927603685bd03f2f	14860
1454	8ee07418e49224b24700bfb11bdb7113401e4868af348385a5faceb90466cf36	14868
1455	41f8b37fadce27c59d837266d480c23ae0795fd79cd2745535d12c239066ee4d	14925
1456	33609124e4a5189628403f8309bed652fe044e3fcf5926e72f94728bd000d706	14928
1457	f8192db0e0abbfc6c9824feabadf4e51ea5e31a65159320fd416afabb8e77c93	14931
1458	6503a452932d9481306081a72e8bad339cd04c9ca70969e9451702a0f42d6554	14944
1459	e2dabd591c2b8e078e4e5c271700cfdd62891f2439ad8e296d4368d5acb71b3b	14946
1460	94e7564fdc3e7f5b89a95db28b9eb8328573402a911eaf6ec1bff4bec6530616	14989
1461	94a2eba78f5f17d026e704509d7dc6a9d3f87d627c9acc2ca2d76f58f7f11109	14996
1462	d66dbea26fe3bc1b81ab337cfeaa06d6e25f5ec0e6e4029576e72b6374e5cf59	14999
1463	32bfa66a687696d0ef7414a3b731ae464c85ac65fac94876653627bb40c913dd	15002
1464	8739974e8aa2b00f00ef06fb256e514e2051e5fca156e1878641644fc67bbbf1	15027
1465	a532e234cec665f2d87169f22fab8d92a59775fafcde5d42dbaf78551a6ebd5a	15034
1466	544bdc1491d8b3f0983b392cba2b50c5de0e2acbe8496d1506325f605aeaef2c	15067
1467	42c5582aa06082be082ee429f8c91da2964e3a3a98e31d5a5ecb4a649882c706	15076
1468	7657b5e2c79b427a4865f8dafba624a9c54e4d78e42c3b0f16f382b300344dfe	15100
1469	bd5530491b5494b55f4250df539fcb4b4771eb979c53495c3e61943d53ea5bdf	15103
1470	a820c3422d0f797c96f13b26eac1cfc7ed7179ceda19b37a2e7505bac83a3839	15112
1471	7ec7217d03664332dc2d11feff73ba646f3ce8061aa12fdeb2fce210aa116bcb	15117
1472	5491fbbe9f2dea5660987d447cf31c204c97adbc6f287c15c9274bf13d46b6ea	15130
1473	71e427b7fef9a25468419898c247253a09c921ef154a9c90e85a9b0fd78390d3	15132
1474	5632e07727ab8af033de7005b8b660e0b7fcd5f955d9291a680ac5979ce22e92	15133
1475	55d3e32cf51caf9125bf9f284077380557469209d418e749545ed4c8a40025be	15137
1476	9a0dc8878c4a87651539446333f3b982514bf9d79f15d9ba71a0603bcb844871	15164
1477	2435e76aa410190c514583e9b5b00229382d7c601d5ed7fe6f90b50cb77a5830	15175
1478	799364fdfe50157c6e0e5b6ee545c74e7456f47bb3f2c827df8bda504ae33565	15179
1479	9f34d2a053c43021d5c38b54523a0341631a2d2ede5bbc3cb2dbf825b3ba58a2	15188
1480	0c34ae9a9a319b58a261098e849eaf09b7884d820ddc887227823ea673888914	15193
1481	cfd90d547db670f7f8561a05f796c9ad338141d2545f89355e922ea5a025b790	15197
1482	921da76924b603a7ccc0c5411c5039732ab5b24a3e6b44247882708f1e3b9c23	15228
1483	238d1320f3a7aea817eab7e6a0400d1665b10281a7518d4a1c5f0e03c9320453	15230
1484	399a33f8759eba4e8ce2395cbf90f6810165bdc3b6f5a3d5bdbba57ef45f4c26	15281
1485	fa408a046172f7dbb36f131cadb6204b669fe43099ffa1b0ae8ba546078938d8	15286
1486	367983480647afa380ac22249f59f93773d6b4d812b6ee0496cb75db96d90461	15312
1487	26b221c4ed3b8a7f6261cb3d876fd576ccea86f225b13ec5fd36d1a13c9f7684	15313
1488	9d1f7ad708993b909710b9602fd2ed9b0b42be4b6ede0600e0b77e9aaf3d4f69	15325
1489	771ce4178da1be09527942501443b164e5b9629e12efd2ef89422567b8821963	15341
1490	c17906b28871b110acef7568c523c00eed306aeb6e54a86b71596b9447be99b1	15344
1491	8a52e28b40109296094ad289c25fd4e70a775466151494de97b9e0a1a0bb6810	15355
1492	112f577d67ed4d2427a390bde72f3524113abc1aa19d782b488013843bf5a5f3	15378
1493	21f17fc360600e2f7ae8e526420aa782b1ca1d5ed272333210845495231ef301	15383
1494	90ebb8e90fe7d0bddc0468c5b3d2d0ebc4c78e114540a2d591f5e2af22df6aed	15388
1495	6a16e98b2ca392a1376e4ecaa9b833607ec3f41eebcf11d24130d95aa0e32a22	15399
1496	157c702c2320f484f71e417d5bdb0c61598388c7f31ae63e1191e4f3ab216f76	15413
1497	4c3429a2c9b869d2c92a5704b849fced47cdb44df6ec0fee86089fab95039a54	15415
1498	8fe4e353593c200ebb60ae56ad2954e2cc0b6d7c1efe8e544fb002204bd2973a	15417
1499	1fb55441954bde7dac5164b0bd57d631cf9147570ede220a5d81fed8c61ac75f	15418
1500	3e922b1cd500ffe37f9adb7e95683bf8594cd644613844bc2434fcd833e6c065	15426
1501	0d60e1944d73dd35fff89504eb4781445aa4f14511e0e948edd3b3f42cfbfef6	15427
1502	ba9b2e54a19d6120cb704a890ea2bb4d8922ad2038c8d5417cd8928d9431cb0e	15431
1503	d1f0fc123efcd68036508c8f559d24d21184134b068b8fdb9ad7abc895ca7163	15436
1504	59964ead89bcd4efbf99b8d2725520044a78fc132cf4eca7d831bb3ad2f8d607	15454
1505	5daaf561390e77a74bc471d567ec9707a624a13180eafe14b398d41f5c3a930a	15472
1506	b1ce1d417b91e215a0560ba02126e8f7b0dc11eb23a83ef8971dab3f12813c5c	15493
1507	77bd0849c6916e4a5f91a9a78fd661aa0fbb361dfdf14562c30ef3f955bf7415	15499
1508	e1abc5c916090f481009103fd5342f2e6862196487b6f6810132b2d4670e0751	15501
1509	d5e51ce3d9772377cb37f35efb90990e15a731137fb27b1efb3cf5ac714fc7b0	15506
1510	495d73ed9c6bd5cc9d0a4d5f32730c82ba790b2262c38b4b55ae5aba46df52df	15513
1511	5a2e8717b60990492bf94b3fb833032024a645064bfde4cc3846c052e3bcf239	15547
1512	09f66657a8c016654b93a07f3d3de504fe25cfb10bf779e6b7e896b32eed1f28	15548
1513	f54960720a6b51c3b0ce61eec174b1d94de1d4cafdd70e852bf61eaaf6568c60	15557
1514	3e61b7c40d8fbc588275200d0ffdb5e1c2341f76946d3be6c88a9271145c8b20	15558
1515	118e49e0d8ddd6a5d0c12bfeccb98ab5c04540322ba31552525192e49a72353b	15563
1516	03f80386a4e3a1f666e7bbdfd6e82130df7d204c1db17ff91229bb43a01d401f	15569
1517	8b1e343f1fd540004a56be076d8b3e7609b499f71b69042c0c317f342550aaa3	15570
1518	00afae6602e4b235310712b2bbdfc769d01faa6306e39d300674d97956fcf5f2	15589
1519	d3cf4eda58dd303e0a325cf1a8b49970794ff4993721f9ab28d1a084385b1c93	15598
1520	a22f04e860e2dbadfe3cc94fda2d37ea4c37f4946ae04ecede54cdac76e8d291	15599
1521	8ede3eeb534563ea0aee9a2b958d95dfca6c805b577f6a8934bc2db4b9f436c9	15602
1522	1aeec9cdc3977588906e58cb98c0ad5ca89936b648fc16af4ec48e665bfc0c00	15613
1523	09c5fcb9d1281e2a6aac5341ad127bab698be8d26f5a6a12ea0439baa43759eb	15623
1524	53f35c846844738ce96570c1e6f0853133983e644e6bbe907247f6400aba48aa	15624
1525	836b465d40b1b1cf7303e6514171cda7fb183c9e27967a150588b7bd198c3c00	15664
1526	45e77649d13f5d7d41bf82a35fdc9fe9293702da24a1a525fb8691ff83e54f01	15667
1527	97dec5ca9b6afca26beeaf1db5603ecb12641982d54e79f2e653b3759952ea57	15668
1528	26c2a88e76c8c985e6c9f1d844753ad30285804cf00e2c344dd8bbf578667583	15670
1529	44ebf6dbc991c7da7e8dcb37c8adb756d983423d60be5ed6c9d7993040495167	15675
1530	545297a3d00042a79b9218a323b28556b24e2850894de466f622e60f1f859361	15678
1531	0b32d7b5c9baf1d9f7ac0f30c2d397f866bf213b5fc27aea438818054ea66223	15688
1532	f22972ec67a409cd373eb7184b79fd8dd0057b528693d59a456e73665d1c8e1b	15698
1533	55890c90163da666ae1d177a7cbc9f12c211fed83f926994833c454941123329	15703
1534	a12aced350f3237f71bf5f0b97b7b4c4034bf3904067719a6ffdaa51209d503e	15714
1535	2453759c2565896626c97a625c62b0331e697855646c907a6cafdea3e614b29c	15718
1536	25df7ca49f13a22b30e58f066b56e782aa0e02b46fab9068c687db432f5dcaa7	15727
1537	3aef86e7eb8fd424882c0b41fe71c3e89915966fa2ce3a9c988c8d40eebb2737	15744
1538	db48db0141eba78c242fab5cba799991f9a26461fdd26778ba76256ad6b1a55f	15748
1539	1e079e1115c3919dee26b96de81f504233881bda3c7bc9f64fb13c610afdb793	15755
1540	3a5af391105b5af5a92c971b831e9aa04dcb410f47a4f8f07a06c5a1cbb9ccb9	15762
1541	762c79caf87774c7b5c8717b549f0a1772a43a6c813aed7cf4e8a55e286dac49	15777
1542	d5a4398f48a49f819fe7de77b699b55b59824bffdd820d1fda2bafa4071714e7	15778
1543	b846ed26c3a5b75b55348a17a2debb6c51468a80aed36fb2576aa6bc273b31d4	15781
1544	3651512de1468a9b15648696b1a0a4fd52447f99934e08a9dde4cf47af20118e	15785
1545	04189ad93fb418061639aa5e9bb7d3c9281ea9f0e4e8cd0c5a488225b0ad41d9	15808
1546	05116e7a42e5e3085eb5ed5c8068d24f10b3758121a60e3dacb503e4d7f99ee9	15817
1547	84443746d4d1f99ea43f092ab5735b38e5abf86fa757112561d1747eb7d1b5df	15821
1548	29f657832bc971206444b7a7cef2b79cc61d267633fb978933a107da94b5662f	15843
1549	e7b25f95a2fb3312141028dae9211b4e464c334d8e3af346b14bf11166324086	15847
1550	4fece0d1fbc0666da79957ea6cc25d1139a1fa2efccaf3fb771be5a1a434e995	15848
1551	f01874ac74927a9ddd9231780119df82cd390d5fec3122da1c2df2b490b8bba7	15852
1552	9f3c9ac659e222f6b733e883276edd94fb5b82b241db69ac9a20c1928f89e44e	15877
1553	01c05b68f9929aec99db842ec0e8a164f9e46395f008341fbab28345767bce6d	15879
1554	c8aa714802db923054a843d9c3c3c0d9af2f0ab6e8b237dd75bc298596d66f15	15880
1555	0b3a2d5fc54c0672c344e3fc40d218be07599e623385547413af2dc33101caa2	15882
1556	661eadb70db284b5ced3876c932ddada451e73079ba17ed2ec1734358843ee10	15903
1557	e5b5563993e60f42dba10baa59c95452b743f2c8130f36e5f57b541794b8063d	15916
1558	f03728a421ada474c0521d566e6e2739e01951ad21bf3b581638e06fd637b189	15919
1559	7ca9e32fba8054713ac722a84d539e122b712461b191dbfe6749ac9c83340f3d	15948
1560	9b96b7080e78e7d5121c35a4546f154c11f2c1bacf64eca72bff17477044f768	15957
1561	00b0377f3e6c80c1c5f310d6bf488ffa7c4cecc08d2e481452503d22c31c97f9	15960
1562	abb1c73109a725c83fe5d4901d00b251fad8bfe7d5494dde0cd60b55df741098	15966
1563	d193a0cd1ea24e4d81e4d732ab7748c214d26136a6c0b0b9842b35da38c5c87e	15974
1564	1d5f733da660722a57b74e134209264af49d61cb4d5a69308b7994cafecd894f	15976
1565	14b7c49426affb0060b5bd3761432b61a87a098341055fd7ff463352fef235dc	15992
1566	2b9ef30860ce030a276cec0a9e7c26e3b0030f40e08f2014d62fc0111aa49aeb	16007
1567	18160c4e95cb6e0f336861feceda49acee9a8dbb5760d3c08a06c485ef28e3a0	16012
1568	2e63d437e8fca3d83551661504ed077b0d22a50ce9c52e82f39a9e67388abd9a	16024
1569	19ae644d4e2a75980e65b1da978193b604750f0ed600476ab4668c306840c64a	16025
1570	96bf5486a9bfe93f6cf8f4621bd22915279ccc6521d30dd4bfef1200a765b0e9	16036
1571	a978bfb681503e8121244d35233ecee61a1099e66fa391f7d061473f806b7211	16037
1572	c49fbeebbd26ac2f16957d1a55ab7042785c1b3c75beae21e34e430f3aed089e	16040
1573	d5165a46f8a2c745c4e25339ffb3fdc8c47671862a6106d808e417f3037aa7c3	16047
1574	b84ec75523010c7c6c979054947bb0220218b3446e05d28e360d09abdcaab3c2	16068
1575	edb13e6d6d17a7aa52844ec252f3bbbc18fc4586b789cf2ad1c2e1b1b105db3c	16070
1576	ddd3d4bbcec640055a7746389512f168d732459ec8dd98ed606f1076ff2b62bf	16074
1577	e040f366b04c40079baf348af29412b49f50f333456969051119c5ed541c6420	16082
1578	036a9fb112eba7f2facbc5769289fdd0a956086a9f9f4f664c56b31d2dedfd2b	16091
1579	76855956e8b64c402702549e1ea55155487cab5cee1501d11ba62fa080a8ccdf	16119
1580	5644aa80c5fd116130578c553c4433dfa1960d39b25f34d41a18a426f3812638	16121
1581	618183e1608b647888f1eec1a5be1c060522f8a30e8c6233286c1768a7ad510c	16134
1582	74eeefc2a948bd3008506703372b560a22f10dabaa7c69e5b3f41a2359ee8f2d	16140
1583	b19f8ac5339dfd0cee88347f60b5f03ca106daa93a40cc29e5cb6fb13ec19a41	16146
1584	cf500013103fd8bcd117251b641ab6b42870753882d30c5f9a91f40b4e913bf1	16147
1585	0a68d6b96146bccb0b832e7e847d2fa5eb8ae9d429af9bf772bdedeb4c38acc4	16165
1586	65a7fffd9e7a699598175ad695a7babaf10c4b2c074db755446c6887fdb6319f	16168
1587	b55866694c547a838619187883be85ac37cab07287a6739c6c8240d7da8808c1	16175
1588	6a25987f051f51ed815ae7e128727c4db8f6ac3b349f9e0b877f2875d2264fec	16180
1589	3e1541810c4a9ebf397c0445a49fbd53c7eb48964eead686ff36b5254c88b62f	16183
1590	dccb99851045a52be4174748e5fdc6c2eaa1340adf69923a3b334a96bbcb7e4e	16191
1591	ed24a2e3efe42947208fbd1cbd365c15498d69318eddb17387df5e6a045e9ce1	16194
1592	8a6a065edb35381700c20413394225b02344b5120c0a98e17d127a8b01036b85	16196
1593	905211d52a680744ad8d6981a0052a8cb1b575ce71689db38a56203769e27f9b	16199
1594	69ad715fa833aa00da7d10e9dd72e7e71ee3b11345300010cabdfe40618ca903	16204
1595	0d746a8f86e3be43d01bf113926af94fc915687eda2eece6ec3b1c4b26f31c91	16237
1596	f46922a8fa94342a9ea7dee9c6f911197ad20a20bbcf77d329aa555b76c1bc44	16248
1597	fc00ab1e3c2ed410f3d59f6aa2c6214338b5f55da207735f5266f41e584737ea	16260
1598	4a856b02abb498fe25b0241bcfd45abd476717d3c0f514e2d9630b95f3b891da	16261
1599	dfaef3c530c3bf9ea929b633d942dd306676a8e8e800a03b393b52c9ea9a87d0	16268
1600	110962b988bf6e234063b7ec01c919b9810e3b736ba9bf6757a321a8647ccf47	16271
1601	9c373748eb3a2f50a541b81028867a843a4da85d6bea8a304f231704d9b5f9a0	16281
1602	805b6aa8fd15e791ee9e75e510fffd2b02c9007b39f18756f1f476294b6a3c08	16289
1603	d5798d96f9f82edb759358b5bedec6c0d5f9447419934bfe3d8daaa950499621	16292
1604	b3c5e4dc137ac6e12a7fb9993f6e529c5f09f490ae9afae299aa11d4ba91be46	16305
1605	8949a6e824ba12a72cc5c8a568a04ec58a24700e5f72e4c127bf0ff629125750	16313
1606	68217c2dc51d22d0239a033b3b28c892ada1f47922e4705b345dab4494819ea1	16324
1607	324adf726658dfb1e0b1ca7d37bb5f3e1622f26f7dd45810eda99a06bf71768a	16352
1608	70264e957b0b2bc11a14378cd8c68b9de6749372295c8b39789df5e42a557247	16356
1609	e9455c31db11145945ee76909810e305a4281101f18369677b4536e8d8a8a365	16358
1610	36a3fe1354d21b3b2d37863090a98ae4490a8605eb1db8a43fc16de53542b7e4	16365
1611	3c502c012b0f31cd15300ff9148308379dcd42dc362f74162e130d614e0d1f05	16414
1612	c3a2cb0abe772ee0453abc74e5cecbcf0fdf3f111bb827db79532810936016f5	16428
1613	3fa7025164c8fd620f35724019ebe654caa3d813921f0cb0d074682ef861d4de	16429
1614	48fd331c6d2d7e64634d604c304c4c5e1249c3c82dfd8bbcc462e01c2327cbd8	16433
1615	9fb8b96792acd922b5ad29d3c3d6e8c805b5f7b33f93fe7918eaaf3aaa8eed4d	16443
1616	7969c9b8da2c5b606dbb055ae7aef9bf2ca2365291d482917676f2c81a8b3108	16455
1617	2194b2f18c5cdd97903c480cd31b72cf6e11354d4fb09ba6948e28c4019c86f3	16456
1618	155dbf4f7802cdcc8d748dda7688f3bed22ffcb416791282096a5eb637cd4633	16458
\.


--
-- Data for Name: block_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.block_data (block_height, data) FROM stdin;
1611	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313733353533227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2234323136333431373361333434386264636631386636336536393835643661653436373133613931303538623763393438323963663637636365386361306661227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2236323736373537356262343734326232336539313030663138623835343534336438633238376536616435313135383137656664636561333734343235343433222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2236323736373537356262343734326232336539313030663138623835343534336438633238376536616435313135383137656664636561333734343535343438222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b223632373637353735626234373432623233653931303066313862383534353433643863323837653661643531313538313765666463656133222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d2c5b2236323736373537356262343734326232336539313030663138623835343534336438633238376536616435313135383137656664636561333734346434393465222c7b225f5f74797065223a22626967696e74222c2276616c7565223a223133353030303030303030303030303030227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383236343437227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373830357d7d2c226964223a2230313632333663303333393436316461343934383334616535653431623138653235366437356137366464613862626131333062333964396662343836306166222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226461643365333333373062633039343466366138366235303762623733373265383061323633343162393565363634643662343630666230363032343432383938613165666333316433306437323230303136646164343766313635386534626363646633393461656635383162353964373934393162363961646235613037225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313733353533227d2c22686561646572223a7b22626c6f636b4e6f223a313631312c2268617368223a2233633530326330313262306633316364313533303066663931343833303833373964636434326463333632663734313632653133306436313465306431663035222c22736c6f74223a31363431347d2c22697373756572566b223a2264643636306265646133646239666634663465663239626631373637376434393530363936353431386231373831306331636234646332343330323335373362222c2270726576696f7573426c6f636b223a2233366133666531333534643231623362326433373836333039306139386165343439306138363035656231646238613433666331366465353335343262376534222c2273697a65223a3431302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383236343437227d2c227478436f756e74223a312c22767266223a227672665f766b313770336e7230786776726a6b7833766a6b37746d6b6a7a72736d373270357464377065356b6472787065337077783479676566716c356337326d227d
1612	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631322c2268617368223a2263336132636230616265373732656530343533616263373465356365636263663066646633663131316262383237646237393533323831303933363031366635222c22736c6f74223a31363432387d2c22697373756572566b223a2237356431323365656338316533363130613834363431303662393664326662343464383434396263353362633131393136336361323863346664663938663261222c2270726576696f7573426c6f636b223a2233633530326330313262306633316364313533303066663931343833303833373964636434326463333632663734313632653133306436313465306431663035222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178766675667361706d666e356b75307173393767656d3365387674716a636766766e61786d343932796d76617a33763770737171716677757564227d
1613	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631332c2268617368223a2233666137303235313634633866643632306633353732343031396562653635346361613364383133393231663063623064303734363832656638363164346465222c22736c6f74223a31363432397d2c22697373756572566b223a2237356431323365656338316533363130613834363431303662393664326662343464383434396263353362633131393136336361323863346664663938663261222c2270726576696f7573426c6f636b223a2263336132636230616265373732656530343533616263373465356365636263663066646633663131316262383237646237393533323831303933363031366635222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178766675667361706d666e356b75307173393767656d3365387674716a636766766e61786d343932796d76617a33763770737171716677757564227d
1614	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631342c2268617368223a2234386664333331633664326437653634363334643630346333303463346335653132343963336338326466643862626363343632653031633233323763626438222c22736c6f74223a31363433337d2c22697373756572566b223a2261306165343936356635333335633336363932393232636435303037636232376138623066623537383636373933383235636137613232333132356634396135222c2270726576696f7573426c6f636b223a2233666137303235313634633866643632306633353732343031396562653635346361613364383133393231663063623064303734363832656638363164346465222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313573376371303535306e7a793572756e637961766538686b747a797872663333616c6c30643377766b337967386d68366d667971366879687364227d
1615	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c227374616b6543726564656e7469616c223a7b2268617368223a226138346261636331306465323230336433303333313235353435396238653137333661323231333463633535346431656435373839613732222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737313631227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2230313632333663303333393436316461343934383334616535653431623138653235366437356137366464613862626131333062333964396662343836306166227d2c7b22696e646578223a302c2274784964223a2263353139623639333835656661343166333030633138316132626237653337393839323863633930613966663736663164383335396461396362336136346166227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2232383232383339227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373837337d7d2c226964223a2232393630306230653864303536643064393463346233633863656134356330643433626133316433303666633735376135376464306531303733646539306339222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c226434616435663565623535303062633766386435383663326431343861633366353436303339316663303534656430346565363731663166356461613835313161353937346264653962663837396466313833376666313136393230303066323761666339303161373566623664353865666465373061336439333361363036225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c223031373536363333313731633637333565633738356530353730376339613366313866653766656330646238343937366639306139623263343731353438636565323239356166316336636330383437656666333161633535353934636339396365646361336637326635653665323935663134336132363532336335663033225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313737313631227d2c22686561646572223a7b22626c6f636b4e6f223a313631352c2268617368223a2239666238623936373932616364393232623561643239643363336436653863383035623566376233336639336665373931386561616633616161386565643464222c22736c6f74223a31363434337d2c22697373756572566b223a2239306632626565323534396338613536366262393937636361323762366635623731633933356333666338633762616135356136386633383266636133353765222c2270726576696f7573426c6f636b223a2234386664333331633664326437653634363334643630346333303463346335653132343963336338326466643862626363343632653031633233323763626438222c2273697a65223a3439322c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2235383232383339227d2c227478436f756e74223a312c22767266223a227672665f766b3137357a797065383477356a6736386b323468687075367a7461643968617532727032336d6e67396d7730387a39363938613376736b3264763363227d
1616	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631362c2268617368223a2237393639633962386461326335623630366462623035356165376165663962663263613233363532393164343832393137363736663263383161386233313038222c22736c6f74223a31363435357d2c22697373756572566b223a2262393630323839633064373431626333333964326136303366613266643065623164376138303237363561656162623439613536643332616439316532393165222c2270726576696f7573426c6f636b223a2239666238623936373932616364393232623561643239643363336436653863383035623566376233336639336665373931386561616633616161386565643464222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138666c7271636a78666c396e38657634357676703639306a756e386b746e326d727a72763770327064737635776b68773875797174387364336d227d
1617	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631372c2268617368223a2232313934623266313863356364643937393033633438306364333162373263663665313133353464346662303962613639343865323863343031396338366633222c22736c6f74223a31363435367d2c22697373756572566b223a2264643636306265646133646239666634663465663239626631373637376434393530363936353431386231373831306331636234646332343330323335373362222c2270726576696f7573426c6f636b223a2237393639633962386461326335623630366462623035356165376165663962663263613233363532393164343832393137363736663263383161386233313038222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313770336e7230786776726a6b7833766a6b37746d6b6a7a72736d373270357464377065356b6472787065337077783479676566716c356337326d227d
1618	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631382c2268617368223a2231353564626634663738303263646363386437343864646137363838663362656432326666636234313637393132383230393661356562363337636434363333222c22736c6f74223a31363435387d2c22697373756572566b223a2266343066313161643230323764333963336538336339303432343762336564393363366530333165383331336530386637316238383966363266643732653261222c2270726576696f7573426c6f636b223a2232313934623266313863356364643937393033633438306364333162373263663665313133353464346662303962613639343865323863343031396338366633222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b316c7732736d6464646670747a37786564326a7a64376e396b6371723473796d71676a63336d737139756c386d746e78346d353471346a66717139227d
1603	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b6544656c65676174696f6e4365727469666963617465222c22706f6f6c4964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22696e70757473223a5b7b22696e646578223a312c2274784964223a2239343962396561633965626235656561333733656231346430333935346330303566616363663664666334366533636533623634623236393032663033623438227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393933343732373835227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373732397d7d2c226964223a2265323836343563393163623035333033336365636336393434633532356532306334323639323565326132373136613635383162656361383036623432303538222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223938356438343765663865376534646333323966626132333533356166363634353162353133653131353433333230653462393638623633303731353639366165303430636336383133356631616431616432353036353539303530623165313433336462343361313962323937623131383037396135333336636331313035225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226561343432383233646336623138623631376232346561306165336132303061326534663336336264343863643536646538306537353266643636356534306266333463383665393039346165306330323334393733383333363637636362643932663031623330386339623136306263363935376339343631393035613064225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313735373533227d2c22686561646572223a7b22626c6f636b4e6f223a313630332c2268617368223a2264353739386439366639663832656462373539333538623562656465633663306435663934343734313939333462666533643864616161393530343939363231222c22736c6f74223a31363239327d2c22697373756572566b223a2262353764366262653734656533623636346262306335323939343633343366366264303031333762633564663462626364303731346562316435643562393762222c2270726576696f7573426c6f636b223a2238303562366161386664313565373931656539653735653531306666666432623032633930303762333966313837353666316634373632393462366133633038222c2273697a65223a3436302c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936343732373835227d2c227478436f756e74223a312c22767266223a227672665f766b31383468716e6d6a7773736778647076757474347379736365786e6a39637132367271756b36306335343832383865736e35346173786c61613868227d
1604	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630342c2268617368223a2262336335653464633133376163366531326137666239393933663665353239633566303966343930616539616661653239396161313164346261393162653436222c22736c6f74223a31363330357d2c22697373756572566b223a2261306165343936356635333335633336363932393232636435303037636232376138623066623537383636373933383235636137613232333132356634396135222c2270726576696f7573426c6f636b223a2264353739386439366639663832656462373539333538623562656465633663306435663934343734313939333462666533643864616161393530343939363231222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313573376371303535306e7a793572756e637961766538686b747a797872663333616c6c30643377766b337967386d68366d667971366879687364227d
1590	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539302c2268617368223a2264636362393938353130343561353262653431373437343865356664633663326561613133343061646636393932336133623333346139366262636237653465222c22736c6f74223a31363139317d2c22697373756572566b223a2239306632626565323534396338613536366262393937636361323762366635623731633933356333666338633762616135356136386633383266636133353765222c2270726576696f7573426c6f636b223a2233653135343138313063346139656266333937633034343561343966626435336337656234383936346565616436383666663336623532353463383862363266222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3137357a797065383477356a6736386b323468687075367a7461643968617532727032336d6e67396d7730387a39363938613376736b3264763363227d
1591	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539312c2268617368223a2265643234613265336566653432393437323038666264316362643336356331353439386436393331386564646231373338376466356536613034356539636531222c22736c6f74223a31363139347d2c22697373756572566b223a2264643636306265646133646239666634663465663239626631373637376434393530363936353431386231373831306331636234646332343330323335373362222c2270726576696f7573426c6f636b223a2264636362393938353130343561353262653431373437343865356664633663326561613133343061646636393932336133623333346139366262636237653465222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313770336e7230786776726a6b7833766a6b37746d6b6a7a72736d373270357464377065356b6472787065337077783479676566716c356337326d227d
1592	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539322c2268617368223a2238613661303635656462333533383137303063323034313333393432323562303233343462353132306330613938653137643132376138623031303336623835222c22736c6f74223a31363139367d2c22697373756572566b223a2261306165343936356635333335633336363932393232636435303037636232376138623066623537383636373933383235636137613232333132356634396135222c2270726576696f7573426c6f636b223a2265643234613265336566653432393437323038666264316362643336356331353439386436393331386564646231373338376466356536613034356539636531222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313573376371303535306e7a793572756e637961766538686b747a797872663333616c6c30643377766b337967386d68366d667971366879687364227d
1593	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539332c2268617368223a2239303532313164353261363830373434616438643639383161303035326138636231623537356365373136383964623338613536323033373639653237663962222c22736c6f74223a31363139397d2c22697373756572566b223a2261306165343936356635333335633336363932393232636435303037636232376138623066623537383636373933383235636137613232333132356634396135222c2270726576696f7573426c6f636b223a2238613661303635656462333533383137303063323034313333393432323562303233343462353132306330613938653137643132376138623031303336623835222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313573376371303535306e7a793572756e637961766538686b747a797872663333616c6c30643377766b337967386d68366d667971366879687364227d
1594	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539342c2268617368223a2236396164373135666138333361613030646137643130653964643732653765373165653362313133343533303030313063616264666534303631386361393033222c22736c6f74223a31363230347d2c22697373756572566b223a2262353764366262653734656533623636346262306335323939343633343366366264303031333762633564663462626364303731346562316435643562393762222c2270726576696f7573426c6f636b223a2239303532313164353261363830373434616438643639383161303035326138636231623537356365373136383964623338613536323033373639653237663962222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31383468716e6d6a7773736778647076757474347379736365786e6a39637132367271756b36306335343832383865736e35346173786c61613868227d
1605	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630352c2268617368223a2238393439613665383234626131326137326363356338613536386130346563353861323437303065356637326534633132376266306666363239313235373530222c22736c6f74223a31363331337d2c22697373756572566b223a2237356431323365656338316533363130613834363431303662393664326662343464383434396263353362633131393136336361323863346664663938663261222c2270726576696f7573426c6f636b223a2262336335653464633133376163366531326137666239393933663665353239633566303966343930616539616661653239396161313164346261393162653436222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178766675667361706d666e356b75307173393767656d3365387674716a636766766e61786d343932796d76617a33763770737171716677757564227d
1606	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630362c2268617368223a2236383231376332646335316432326430323339613033336233623238633839326164613166343739323265343730356233343564616234343934383139656131222c22736c6f74223a31363332347d2c22697373756572566b223a2264643636306265646133646239666634663465663239626631373637376434393530363936353431386231373831306331636234646332343330323335373362222c2270726576696f7573426c6f636b223a2238393439613665383234626131326137326363356338613536386130346563353861323437303065356637326534633132376266306666363239313235373530222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b313770336e7230786776726a6b7833766a6b37746d6b6a7a72736d373270357464377065356b6472787065337077783479676566716c356337326d227d
1607	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c316d37793267616b7765777179617a303574766d717177766c3268346a6a327178746b6e6b7a6577306468747577757570726571222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a223530303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e32222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757a3579687478707068337a71306673787666393233766d3363746e64673370786e7839326e6737363475663575736e716b673576222c22767266223a2236343164303432656433396332633235386433383130363063313432346634306566386162666532356566353636663463623232343737633432623261303134227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832373035227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2262343938303432626565353630643735316334386630353238323465323735376332636634356435373030386530646264666431663262626331366563663065227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f7465737431717230633366726b656d3963716e35663733646e767170656e6132376b326667716577367763743965616b613033616766776b767a72307a7971376e7176636a32347a65687273687836337a7a64787632347833613474636e666571397a776d6e37222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b223632313733623930623536376164346263663235346164306637366562333734643734396430623235666438323738366166366138333961343436663735363236633635343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2232227d5d2c5b22363231373362393062353637616434626366323534616430663736656233373464373439643062323566643832373836616636613833396134383635366336633666343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d2c5b2236323137336239306235363761643462636632353461643066373665623337346437343964306232356664383237383661663661383339613534363537333734343836313665363436633635222c7b225f5f74797065223a22626967696e74222c2276616c7565223a2231227d5d5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2236383137323935227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373736347d7d2c226964223a2263353139623639333835656661343166333030633138316132626237653337393839323863633930613966663736663164383335396461396362336136346166222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2238343435333239353736633961353736656365373235376266653939333039323766393233396566383736313564363963333137623834316135326137666436222c223663616162336564376432343962663435613138356634383239376134633766653433363362303538663533633433643662373133393863626566323131343562633132386238613062313865366237656233313233323932376164646664613437303734663932343930616262666330336238656435343739343830633034225d2c5b2261323864383864383665633264633963626666373466613030643362363534636330343734396430643165396265303934343762663530386163613330353030222c226363393465656132346666363763303239393730353935643839306565393330333936633066633636633865396438643234636266353435393061306131323330376137306339613837336266633335613462393136666438373836343736353862646133366662613239626334363738646337376435306366303438373065225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313832373035227d2c22686561646572223a7b22626c6f636b4e6f223a313630372c2268617368223a2233323461646637323636353864666231653062316361376433376262356633653136323266323666376464343538313065646139396130366266373137363861222c22736c6f74223a31363335327d2c22697373756572566b223a2261306165343936356635333335633336363932393232636435303037636232376138623066623537383636373933383235636137613232333132356634396135222c2270726576696f7573426c6f636b223a2236383231376332646335316432326430323339613033336233623238633839326164613166343739323265343730356233343564616234343934383139656131222c2273697a65223a3631382c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2239383137323935227d2c227478436f756e74223a312c22767266223a227672665f766b313573376371303535306e7a793572756e637961766538686b747a797872663333616c6c30643377766b337967386d68366d667971366879687364227d
1608	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630382c2268617368223a2237303236346539353762306232626331316131343337386364386336386239646536373439333732323935633862333937383964663565343261353537323437222c22736c6f74223a31363335367d2c22697373756572566b223a2238633666396233366539623863353030353565303165363334393133366638643966356635396635313964633761393836653230373132333161366161646333222c2270726576696f7573426c6f636b223a2233323461646637323636353864666231653062316361376433376262356633653136323266323666376464343538313065646139396130366266373137363861222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317a6567396375636a756c636c61366c6370657730617839757538303964643873746768356a787077343437367739667076336871727434773464227d
1609	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630392c2268617368223a2265393435356333316462313131343539343565653736393039383130653330356134323831313031663138333639363737623435333665386438613861333635222c22736c6f74223a31363335387d2c22697373756572566b223a2237356431323365656338316533363130613834363431303662393664326662343464383434396263353362633131393136336361323863346664663938663261222c2270726576696f7573426c6f636b223a2237303236346539353762306232626331316131343337386364386336386239646536373439333732323935633862333937383964663565343261353537323437222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3178766675667361706d666e356b75307173393767656d3365387674716a636766766e61786d343932796d76617a33763770737171716677757564227d
1610	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313631302c2268617368223a2233366133666531333534643231623362326433373836333039306139386165343439306138363035656231646238613433666331366465353335343262376534222c22736c6f74223a31363336357d2c22697373756572566b223a2263343439633934376365363439313261363865363562623664656433663265353666336664636134373164316462383462346565323862323030393962396633222c2270726576696f7573426c6f636b223a2265393435356333316462313131343539343565653736393039383130653330356134323831313031663138333639363737623435333665386438613861333635222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31347839766e7774357473326b6b337672376739676577673533356833716e717673376a726d6639787130676d356a746732787373616665747068227d
1595	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a22506f6f6c526567697374726174696f6e4365727469666963617465222c22706f6f6c506172616d6574657273223a7b22636f7374223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2231303030227d2c226964223a22706f6f6c3165346571366a3037766c64307775397177706a6b356d6579343236637775737a6a376c7876383974687433753674386e766734222c226d617267696e223a7b2264656e6f6d696e61746f72223a352c226e756d657261746f72223a317d2c226d657461646174614a736f6e223a7b225f5f74797065223a22756e646566696e6564227d2c226f776e657273223a5b227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973225d2c22706c65646765223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22353030303030303030303030303030227d2c2272656c617973223a5b7b225f5f747970656e616d65223a2252656c6179427941646472657373222c2269707634223a223132372e302e302e31222c2269707636223a7b225f5f74797065223a22756e646566696e6564227d2c22706f7274223a363030307d5d2c227265776172644163636f756e74223a227374616b655f7465737431757273747872777a7a75366d78733338633070613066706e7365306a73647633643466797939326c7a7a7367337173737672777973222c22767266223a2232656535613463343233323234626239633432313037666331386136303535366436613833636563316439646433376137316635366166373139386663373539227d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22696e70757473223a5b7b22696e646578223a322c2274784964223a2262613734326138393435616332663662663662626265376231363131356262663065393336613935363034643030373633663737353032643439366239333564227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936383230313131227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373634347d7d2c226964223a2231353763323863313333356338373865623734303864323763623562346263646334396463326365393964333062373433353939636361353662663839393464222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c223332386333366262643038353336623031383761653530663861653462616164383330646561333230633936613732643463373030353466376539633738333535653131373063326533346165326461643361663862313333396332623936326432366461646566356661303266626662346666666563656464353362323039225d2c5b2262316237376531633633303234366137323964623564303164376630633133313261643538393565323634386330383864653632373236306334636135633836222c226562363438663538623733643862316438343966663337653330653864303862336662613965323533643538393034313839633030373330373031623830646334356136313864336363633936373833336562663861366464383862386335313837363066643135363762333030363662653330366239633065363435313065225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313739383839227d2c22686561646572223a7b22626c6f636b4e6f223a313539352c2268617368223a2230643734366138663836653362653433643031626631313339323661663934666339313536383765646132656563653665633362316334623236663331633931222c22736c6f74223a31363233377d2c22697373756572566b223a2237356431323365656338316533363130613834363431303662393664326662343464383434396263353362633131393136336361323863346664663938663261222c2270726576696f7573426c6f636b223a2236396164373135666138333361613030646137643130653964643732653765373165653362313133343533303030313063616264666534303631386361393033222c2273697a65223a3535342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939383230313131227d2c227478436f756e74223a312c22767266223a227672665f766b3178766675667361706d666e356b75307173393767656d3365387674716a636766766e61786d343932796d76617a33763770737171716677757564227d
1596	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539362c2268617368223a2266343639323261386661393433343261396561376465653963366639313131393761643230613230626263663737643332396161353535623736633162633434222c22736c6f74223a31363234387d2c22697373756572566b223a2262393630323839633064373431626333333964326136303366613266643065623164376138303237363561656162623439613536643332616439316532393165222c2270726576696f7573426c6f636b223a2230643734366138663836653362653433643031626631313339323661663934666339313536383765646132656563653665633362316334623236663331633931222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b3138666c7271636a78666c396e38657634357676703639306a756e386b746e326d727a72763770327064737635776b68773875797174387364336d227d
1597	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539372c2268617368223a2266633030616231653363326564343130663364353966366161326336323134333338623566353564613230373733356635323636663431653538343733376561222c22736c6f74223a31363236307d2c22697373756572566b223a2238633666396233366539623863353030353565303165363334393133366638643966356635396635313964633761393836653230373132333161366161646333222c2270726576696f7573426c6f636b223a2266343639323261386661393433343261396561376465653963366639313131393761643230613230626263663737643332396161353535623736633162633434222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317a6567396375636a756c636c61366c6370657730617839757538303964643873746768356a787077343437367739667076336871727434773464227d
1598	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313539382c2268617368223a2234613835366230326162623439386665323562303234316263666434356162643437363731376433633066353134653264393633306239356633623839316461222c22736c6f74223a31363236317d2c22697373756572566b223a2238633666396233366539623863353030353565303165363334393133366638643966356635396635313964633761393836653230373132333161366161646333222c2270726576696f7573426c6f636b223a2266633030616231653363326564343130663364353966366161326336323134333338623566353564613230373733356635323636663431653538343733376561222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b317a6567396375636a756c636c61366c6370657730617839757538303964643873746768356a787077343437367739667076336871727434773464227d
1599	\\x7b22626f6479223a5b7b22617578696c6961727944617461223a7b225f5f74797065223a22756e646566696e6564227d2c22626f6479223a7b22617578696c696172794461746148617368223a7b225f5f74797065223a22756e646566696e6564227d2c22636572746966696361746573223a5b7b225f5f747970656e616d65223a225374616b65526567697374726174696f6e4365727469666963617465222c227374616b6543726564656e7469616c223a7b2268617368223a226530623330646332313733356233343232376333633364376134333338363566323833353931366435323432313535663130613038383832222c2274797065223a307d7d5d2c22636f6c6c61746572616c73223a7b225f5f74797065223a22756e646566696e6564227d2c22666565223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22696e70757473223a5b7b22696e646578223a302c2274784964223a2231353763323863313333356338373865623734303864323763623562346263646334396463326365393964333062373433353939636361353662663839393464227d2c7b22696e646578223a312c2274784964223a2231353763323863313333356338373865623734303864323763623562346263646334396463326365393964333062373433353939636361353662663839393464227d5d2c226d696e74223a7b225f5f74797065223a22756e646566696e6564227d2c226f757470757473223a5b7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2233303030303030227d7d7d2c7b2261646472657373223a22616464725f746573743171727868797232666c656e6134616d733570637832366e30796a347474706d6a7132746d7565737534776177386e30716b767875793965346b64707a3073377236376a7238706a6c397136657a6d326a6767323437793971337a7071786761333773222c22646174756d223a7b225f5f74797065223a22756e646566696e6564227d2c22646174756d48617368223a7b225f5f74797065223a22756e646566696e6564227d2c227363726970745265666572656e6365223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c7565223a7b22617373657473223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5d7d2c22636f696e73223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393936363438353338227d7d7d5d2c22726571756972656445787472615369676e617475726573223a7b225f5f74797065223a22756e646566696e6564227d2c2276616c6964697479496e74657276616c223a7b22696e76616c6964486572656166746572223a31373730317d7d2c226964223a2239343962396561633965626235656561333733656231346430333935346330303566616363663664666334366533636533623634623236393032663033623438222c22696e707574536f75726365223a22696e70757473222c227769746e657373223a7b22626f6f747374726170223a5b5d2c227369676e617475726573223a7b225f5f74797065223a224d6170222c2276616c7565223a5b5b2263396237386631316366356165383965363837303730376233333731623265613930323837356264613266623439363332613036353539393966313039353963222c226530306565656532346564656563326239326561323036636434336430643332393432636434373536393865313937346638363263373133326439656132383737633964623730396431336631363133663032353432653632646333623437613634623861646434653263613833396130343865636266313730626634393036225d5d7d7d7d5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a22313731353733227d2c22686561646572223a7b22626c6f636b4e6f223a313539392c2268617368223a2264666165663363353330633362663965613932396236333364393432646433303636373661386538653830306130336233393362353263396561396138376430222c22736c6f74223a31363236387d2c22697373756572566b223a2262353764366262653734656533623636346262306335323939343633343366366264303031333762633564663462626364303731346562316435643562393762222c2270726576696f7573426c6f636b223a2234613835366230326162623439386665323562303234316263666434356162643437363731376433633066353134653264393633306239356633623839316461222c2273697a65223a3336352c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2234393939393939363438353338227d2c227478436f756e74223a312c22767266223a227672665f766b31383468716e6d6a7773736778647076757474347379736365786e6a39637132367271756b36306335343832383865736e35346173786c61613868227d
1600	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630302c2268617368223a2231313039363262393838626636653233343036336237656330316339313962393831306533623733366261396266363735376133323161383634376363663437222c22736c6f74223a31363237317d2c22697373756572566b223a2262353764366262653734656533623636346262306335323939343633343366366264303031333762633564663462626364303731346562316435643562393762222c2270726576696f7573426c6f636b223a2264666165663363353330633362663965613932396236333364393432646433303636373661386538653830306130336233393362353263396561396138376430222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31383468716e6d6a7773736778647076757474347379736365786e6a39637132367271756b36306335343832383865736e35346173786c61613868227d
1601	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630312c2268617368223a2239633337333734386562336132663530613534316238313032383836376138343361346461383564366265613861333034663233313730346439623566396130222c22736c6f74223a31363238317d2c22697373756572566b223a2262353764366262653734656533623636346262306335323939343633343366366264303031333762633564663462626364303731346562316435643562393762222c2270726576696f7573426c6f636b223a2231313039363262393838626636653233343036336237656330316339313962393831306533623733366261396266363735376133323161383634376363663437222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31383468716e6d6a7773736778647076757474347379736365786e6a39637132367271756b36306335343832383865736e35346173786c61613868227d
1602	\\x7b22626f6479223a5b5d2c2266656573223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c22686561646572223a7b22626c6f636b4e6f223a313630322c2268617368223a2238303562366161386664313565373931656539653735653531306666666432623032633930303762333966313837353666316634373632393462366133633038222c22736c6f74223a31363238397d2c22697373756572566b223a2263343439633934376365363439313261363865363562623664656433663265353666336664636134373164316462383462346565323862323030393962396633222c2270726576696f7573426c6f636b223a2239633337333734386562336132663530613534316238313032383836376138343361346461383564366265613861333034663233313730346439623566396130222c2273697a65223a342c22746f74616c4f7574707574223a7b225f5f74797065223a22626967696e74222c2276616c7565223a2230227d2c227478436f756e74223a302c22767266223a227672665f766b31347839766e7774357473326b6b337672376739676577673533356833716e717673376a726d6639787130676d356a746732787373616665747068227d
\.


--
-- Data for Name: current_pool_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.current_pool_metrics (stake_pool_id, slot, minted_blocks, live_delegators, active_stake, live_stake, live_pledge, live_saturation, active_size, live_size, last_ros, ros) FROM stdin;
pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	10296	90	3	7818652899446105	53317682588053	5958467514953	0.041908610670168905	146.64277440291536	-145.64277440291536	24.789648764108993	20.770190568253998
pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	10296	116	5	7841698003754644	78810498109334	8787755172629	0.06194639979957109	99.50067810605431	-98.50067810605431	24.47517516606927	23.987943930553143
pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s	10296	59	3	0	10961709357701	300000000	0.008616091087469262	0	1	5.625483021000938	5.625483021000938
pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg	10296	72	3	0	50207592852264	500000000	0.03946402693059589	0	1	27.26835594761011	27.26835594761011
pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	10296	105	3	7792417128658904	19689855931632	300000000	0.015476563615226965	395.75795555417386	-394.75795555417386	0	3.2815317621016815
pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	10296	90	3	7817322824871509	50752422062374	500000000	0.039892272010650286	154.02856666158968	-153.02856666158968	20.529009489047606	20.77097770557231
pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	10296	97	3	7827086093365430	60512835970047	6123350316503	0.047564124322701545	129.34588121501574	-128.34588121501574	23.84386580998461	21.480469788300216
pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	10296	94	3	7819611517645965	53657506333762	5884274928205	0.04217571794798199	145.73192181176267	-144.73192181176267	24.005833006840227	21.121047831443715
pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	10296	88	3	7787201781175307	14474508448035	200200680	0.011377211269243969	537.9942130077976	-536.9942130077976	0	2.109556159919508
pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	10296	106	3	7828311558288033	64809483650001	6630279879976	0.050941362905955814	120.78959925933482	-119.78959925933482	23.44826676614669	21.43346020320402
pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	10296	84	3	7814364449493747	48412737356799	5484720018703	0.03805323980487204	161.41133255701584	-160.41133255701584	20.22768163157108	17.64952358000941
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
2080000000000	stake_test1upm5tvdlq6epcfmd8mlnhfm5r7w3ems53mrpkateyfz84tc0feps9	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3001, "__typename": "RelayByAddress"}]	["stake_test1upm5tvdlq6epcfmd8mlnhfm5r7w3ems53mrpkateyfz84tc0feps9"]	b7387cde9d8ccd424f385a2051cc711bc5d6739319c23206101f9bb557983b47	http://file-server/SP1.json	14ea470ac1deb37c5d5f2674cfee849d40fa0fe5265fccc78f2fdb4cec73dfc7	208	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459
2910000000000	stake_test1uzs6f5vqg424jq0h2pcdzwt7a76e5as3gwtdmgeyaafwmqqum2sew	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3002, "__typename": "RelayByAddress"}]	["stake_test1uzs6f5vqg424jq0h2pcdzwt7a76e5as3gwtdmgeyaafwmqqum2sew"]	73c0d48d25cf195d3b512e52b577c98530ecb8a9640b35871763c559b8766179	\N	\N	291	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv
4100000000000	stake_test1ur6a6makqulv65xq8ackdvj5v78jkl85kfjgzra5h6799tczmnmcs	600000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3003, "__typename": "RelayByAddress"}]	["stake_test1ur6a6makqulv65xq8ackdvj5v78jkl85kfjgzra5h6799tczmnmcs"]	d7d4b87471d9ebb57ba418ecc1464c3bf6168ad81ee1f2d287bd9346317104de	http://file-server/SP3.json	6d3ce01216ac833311cbb44c6793325bc14f12d559a83b2237f60eeb66e85f25	410	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m
4970000000000	stake_test1uqs927ane8x4t5fyquatmg8e7f4y9tu5v9a45frd9hlc0vq5ttaj9	420000000	370000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3004, "__typename": "RelayByAddress"}]	["stake_test1uqs927ane8x4t5fyquatmg8e7f4y9tu5v9a45frd9hlc0vq5ttaj9"]	00e158e77a2478b32fa81c0bb7e8478d5bf8a5516123abbfab7fcb3c24ede226	http://file-server/SP4.json	09dd809e0fecfc0ef01e3bc225d54a60b4de3eed39a8574a9e350d2ec952dc8d	497	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv
5630000000000	stake_test1uzwptdmkw3gh4f904dptdx77fkpmj54gmrzrur57p5sr8dgct86pq	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3005, "__typename": "RelayByAddress"}]	["stake_test1uzwptdmkw3gh4f904dptdx77fkpmj54gmrzrur57p5sr8dgct86pq"]	9645f27357e41c6efe65a0b50134c3c9109e651930f3d445cc6e53b294bf48f9	http://file-server/SP5.json	0f118a34e20bd77f8a9ba5e27481eba54d063630c4c1c017bad11a2fba615501	563	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc
6580000000000	stake_test1uz5y3dws9vg7t4jaql7dk2cl3jh35d034da57gn5qzk2tzg6dzux4	410000000	400000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3006, "__typename": "RelayByAddress"}]	["stake_test1uz5y3dws9vg7t4jaql7dk2cl3jh35d034da57gn5qzk2tzg6dzux4"]	8032eea046c33201a259c6dec7d691434025f13a19d4851666b0f3d6f666f02a	http://file-server/SP6.json	3806b0c100c6019d0ed25233ad823a1c505fd6bd05aad617be09d420082914ba	658	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v
7670000000000	stake_test1up9qxhs308s66cwg7uz6h67h9lv56n6vfvlt6863zg80g2qussevd	410000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3007, "__typename": "RelayByAddress"}]	["stake_test1up9qxhs308s66cwg7uz6h67h9lv56n6vfvlt6863zg80g2qussevd"]	e25c52873e8c3276391dac1140e69d502bf7bdffdf491b2567c3e833a9c92cc6	http://file-server/SP7.json	c431584ed48f8ce7dda609659a4905e90bf7ca95e4f8b4fddb7e05ce4315d405	767	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z
8540000000000	stake_test1uzwc9pxv5kw9y95lww2c2f9tau0lu9y66al2lh0afrzawnq228acy	500000000	380000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3008, "__typename": "RelayByAddress"}]	["stake_test1uzwc9pxv5kw9y95lww2c2f9tau0lu9y66al2lh0afrzawnq228acy"]	6754b00c14bf525672f426ed4a5a68d83b79221dd93b8ae1bcf5f8260ca11c16	\N	\N	854	pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s
9920000000000	stake_test1urffn7s7338835qn5ntm0jk55cvf23ma7ew9gsrzlxntmssyaz20n	500000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 3009, "__typename": "RelayByAddress"}]	["stake_test1urffn7s7338835qn5ntm0jk55cvf23ma7ew9gsrzlxntmssyaz20n"]	3da1d425f1d36f7d7f006471f22dca5aa63a6f76ac715744e84a7a0dc001b98a	\N	\N	992	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh
10820000000000	stake_test1upskl8ylag5yjlh7tfzxarrjffsd8azkkyturm0smpy4t7c33ccn4	400000000	410000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30010, "__typename": "RelayByAddress"}]	["stake_test1upskl8ylag5yjlh7tfzxarrjffsd8azkkyturm0smpy4t7c33ccn4"]	07b524090af738742362e48acd89f61725a6dc252870d4bf53bd339e354de892	http://file-server/SP10.json	c054facebb7063a319711b4d680a4c513005663a1d47e8e8a41a4cef45812ffd	1082	pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg
12260000000000	stake_test1ur470ml4vc4spckjca52syjp32x6y4zm960a3jsf2a9d4yqay0j9s	400000000	390000000	{"numerator": 3, "denominator": 20}	0.15	[{"ipv4": "127.0.0.1", "port": 30011, "__typename": "RelayByAddress"}]	["stake_test1ur470ml4vc4spckjca52syjp32x6y4zm960a3jsf2a9d4yqay0j9s"]	c7259af245a51f11d62567958650d4531fc1526f67586b248e0c97cda39cc612	http://file-server/SP11.json	4c1c15c4b9fd85a94b5d89e1031db403dd65da928289c40fa2513165b77dcdc9	1226	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c
162370000000000	stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys	500000000000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.1", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1urstxrwzzu6mxs38c0pa0fpnse0jsdv3d4fyy92lzzsg3qssvrwys"]	2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759	\N	\N	16237	pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4
163520000000000	stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v	50000000	1000	{"numerator": 1, "denominator": 5}	0.2	[{"ipv4": "127.0.0.2", "port": 6000, "__typename": "RelayByAddress"}]	["stake_test1uz5yhtxpph3zq0fsxvf923vm3ctndg3pxnx92ng764uf5usnqkg5v"]	641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014	\N	\N	16352	pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq
\.


--
-- Data for Name: pool_retirement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_retirement (id, retire_at_epoch, block_slot, stake_pool_id) FROM stdin;
8810000000000	5	881	pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s
10150000000000	18	1015	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh
11450000000000	5	1145	pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg
12650000000000	18	1265	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c
\.


--
-- Data for Name: pool_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pool_rewards (id, stake_pool_id, epoch_length, epoch_no, delegators, pledge, active_stake, member_active_stake, leader_rewards, member_rewards, rewards, version) FROM stdin;
1	pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s	1000000	0	0	500000000	0	0	0	0	0	1
2	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	0	0	500000000	0	0	0	0	0	1
3	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	0	0	400000000	0	0	0	0	0	1
4	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	0	0	500000000	0	0	0	0	0	1
5	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	0	0	600000000	0	0	0	0	0	1
6	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	0	0	420000000	0	0	0	0	0	1
7	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	0	0	410000000	0	0	0	0	0	1
8	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	0	0	410000000	0	0	0	0	0	1
9	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	0	0	410000000	0	0	0	0	0	1
10	pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s	1000000	1	0	500000000	0	0	0	3528356092243	3528356092243	1
11	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	1	0	500000000	0	0	0	7056712184486	7056712184486	1
12	pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg	1000000	1	0	400000000	0	0	0	5292534138364	5292534138364	1
13	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	1	0	400000000	0	0	0	7056712184486	7056712184486	1
14	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	1	0	400000000	0	0	0	9702979253668	9702979253668	1
15	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	1	0	500000000	0	0	0	6174623161425	6174623161425	1
16	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	1	0	600000000	0	0	0	6174623161425	6174623161425	1
17	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	1	0	420000000	0	0	0	13231335345911	13231335345911	1
18	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	1	0	410000000	0	0	0	7056712184486	7056712184486	1
19	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	1	0	410000000	0	0	0	7938801207546	7938801207546	1
20	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	1	0	410000000	0	0	0	4410445115303	4410445115303	1
21	pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s	1000000	2	3	500000000	7773227572016780	7773227272016780	0	6933053975950	6933053975950	1
22	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	2	3	500000000	7773227572193545	7773227272193545	0	12132844457638	12132844457638	1
23	pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg	1000000	2	1	400000000	7772727272727272	7772727272727272	0	8666875286047	8666875286047	1
24	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	2	1	400000000	7772727272727272	7772727272727272	0	6066812700233	6066812700233	1
25	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	2	3	400000000	7773227772190781	7773227272190781	0	9532948971442	9532948971442	1
26	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	2	3	500000000	7773227872193545	7773227272193545	0	7799685421746	7799685421746	1
27	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	2	3	600000000	7773227472190773	7773227272190773	0	7799685823109	7799685823109	1
28	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	2	3	420000000	7773227772190773	7773227272190773	0	6933053797412	6933053797412	1
29	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	2	3	410000000	7773227772190773	7773227272190773	0	4333158623382	4333158623382	1
30	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	2	3	410000000	7773227772190773	7773227272190773	0	5199790348058	5199790348058	1
31	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	2	3	410000000	7773227772190773	7773227272190773	0	10399580696118	10399580696118	1
32	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	3	3	500000000	7773227572016780	7773227272016780	0	0	0	1
33	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	3	3	400000000	7773227772013964	7773227272013964	0	7213314602957	7213314602957	1
34	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	3	3	400000000	7773227772190781	7773227272190781	962107130917	5449728071566	6411835202483	1
35	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	3	3	500000000	7773227872193545	7773227272193545	962107188653	5449727931342	6411835119995	1
36	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	3	3	600000000	7773227472190773	7773227272190773	0	0	0	1
37	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	3	3	420000000	7773227772190773	7773227272190773	1563199900255	8856032303781	10419232204036	1
38	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	3	3	410000000	7773227772190773	7773227272190773	1202551038652	6812242964452	8014794003104	1
39	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	3	3	410000000	7773227772190773	7773227272190773	601449769314	3405947232236	4007397001550	1
40	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	3	3	410000000	7773227772190773	7773227272190773	2044104715723	11581045089554	13625149805277	1
41	pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s	1000000	3	3	500000000	7773227572016780	7773227272016780	0	0	0	1
42	pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg	1000000	3	3	400000000	7773227772013964	7773227272013964	0	10419232204272	10419232204272	1
43	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	4	3	500000000	7780284284201266	7780283984201266	0	0	0	1
44	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	4	3	400000000	7780284484198450	7780283984198450	1377235114612	7802118973450	9179354088062	1
45	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	4	3	400000000	7782930751444449	7782930251444449	1001375467041	5672248550544	6673624017585	1
46	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	4	3	500000000	7779402495354970	7779401895354970	1001829551817	5674821209094	6676650760911	1
47	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	4	3	600000000	7779402095352198	7779401895352198	0	0	0	1
48	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	4	3	420000000	7786459107536684	7786458607536684	1000904853812	5669695077775	6670599931587	1
49	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	4	3	410000000	7780284484375259	7780283984375259	751369835216	4255550576339	5006920411555	1
50	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	4	3	410000000	7781166573398319	7781166073398319	1251928659909	7091992701384	8343921361293	1
51	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	4	3	410000000	7777638217306076	7777637717306076	1127272303398	6385663649161	7512935952559	1
52	pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s	1000000	4	3	500000000	7776755928109023	7776755628109023	0	0	0	1
53	pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg	1000000	4	3	400000000	7778520306152328	7778519806152328	1377564398171	7803871578775	9181435976946	1
54	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	5	3	500000000	7792417128658904	7792416828190649	0	0	0	1
55	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	5	3	400000000	7786351296898683	7786350796898683	739195704491	4186563866516	4925759571007	1
56	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	5	3	400000000	7792463700415891	7792463199802700	861663580006	4880548196422	5742211776428	1
57	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	5	3	500000000	7787202180776716	7787201580174674	985376200140	5581585597530	6566961797670	1
58	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	5	3	600000000	7787201781175307	7787201580974627	0	0	0	1
59	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	5	3	420000000	7793392161334096	7793391660888139	861543965605	4879983716001	5741527681606	1
60	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	5	3	410000000	7784617642998641	7784617142719918	985703168827	5583438897886	6569142066713	1
61	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	5	3	410000000	7786366363746377	7786365863411910	739202774946	4186547264572	4925750039518	1
62	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	5	3	410000000	7788037798002194	7788037297333259	1108387805418	6278651539801	7387039345219	1
63	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	6	3	500000000	7792417128658904	7792416828190649	0	0	0	1
64	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	6	3	400000000	7793564611501640	7793564111037656	960914062955	5442967359943	6403881422898	1
65	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	6	3	400000000	7798875535618374	7797912927874266	1201080801827	6798319785765	7999400587592	1
66	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	6	3	500000000	7793614015896711	7792651308106016	841423900597	4761936824023	5603360724620	1
67	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	6	3	600000000	7787201781175307	7787201580974627	0	0	0	1
68	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	6	3	420000000	7803811393538132	7802247693191920	840673361581	4755365353000	5596038714581	1
69	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	6	3	410000000	7792632437001745	7791429385684370	841676826987	4762389710550	5604066537537	1
70	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	6	3	410000000	7790373760747927	7789771810644146	1081910951658	6125406477818	7207317429476	1
71	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	6	4	410000000	7801662955419357	7799618350034699	1561972928591	8833532346153	10395505274744	1
72	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	7	3	500000000	7792417128658904	7792416828190649	0	0	0	1
73	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	7	3	400000000	7802743965589702	7801366230011106	488201843751	2761016444151	3249218287902	1
74	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	7	3	400000000	7805549159635959	7803585176424810	1171296819702	6624024545749	7795321365451	1
75	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	7	3	500000000	7800290666657622	7798326129315110	1074441444523	6076087021530	7150528466053	1
76	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	7	3	600000000	7787201781175307	7787201580974627	0	0	0	1
77	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	7	3	420000000	7810481993469719	7807917388269695	975926084205	5516072337922	6491998422127	1
78	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	7	3	410000000	7797639357413300	7795684936260709	684083700137	3867799776060	4551883476197	1
79	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	7	3	410000000	7798717682109220	7796863803345530	1172238889811	6629910978080	7802149867891	1
80	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	7	4	410000000	7809175891371916	7806004013683860	1464637894234	8274988440795	9739626335029	1
81	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	8	3	500000000	7792417128658904	7792416828190649	0	0	0	1
82	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	8	3	400000000	7807669725160709	7805552793877622	925280838489	5231589079648	6156869918137	1
83	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	8	3	400000000	7811291371412387	7808465724621232	925325903819	5228689428078	6154015331897	1
84	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	8	3	500000000	7806857628455292	7803907714912640	1018496040433	5754765374636	6773261415069	1
85	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	8	3	600000000	7787201781175307	7787201580974627	0	0	0	1
86	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	8	3	420000000	7816223521151325	7812797371985696	1387531268561	7837666820679	9225198089240	1
87	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	8	4	410000000	7804208499480013	7801268375158595	1018835170161	5756725420163	6775560590324	1
88	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	8	3	410000000	7803643432148738	7801050350610102	1111236134848	6280819734372	7392055869220	1
89	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	8	4	410000000	7816562930717135	7812282665223661	1480878856330	8358905158752	9839784015082	1
90	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	9	3	500000000	7792417128658904	7792416828190649	0	0	0	1
91	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	9	3	400000000	7814073606583607	7810995761237565	1218601488209	6885111700368	8103713188577	1
92	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	9	3	400000000	7819290771999979	7815264044406997	937478090010	5291988257396	6229466347406	1
93	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	9	3	500000000	7812460989179912	7808669651736663	1594606190593	9004744634553	10599350825146	1
94	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	9	3	600000000	7787201781175307	7787201580974627	0	0	0	1
95	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	9	3	420000000	7821819559865906	7817552737338696	749918634348	4232043258476	4981961892824	1
96	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	9	4	410000000	7809812566017550	7806030764869145	844640383487	4768683557606	5613323941093	1
97	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	9	3	410000000	7810850749578214	7807175757087920	844471118868	4768106724159	5612577843027	1
98	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	9	4	410000000	7826958435991879	7821116197569814	844038982477	4756988314496	5601027296973	1
99	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	10	3	500000000	7792417128658904	7792416828190649	0	0	0	1
100	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	10	3	400000000	7817322824871509	7813756777681716	1305095991124	7370907686735	8676003677859	1
101	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	10	3	400000000	7827086093365430	7821888068952746	1025428070383	5782928818906	6808356889289	1
102	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	10	3	500000000	7819611517645965	7814745738758193	559877226932	3157321772013	3717198998945	1
103	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	10	3	600000000	7787201781175307	7787201580974627	0	0	0	1
104	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	10	3	420000000	7828311558288033	7823068809676618	1118462043826	6307673691602	7426135735428	1
105	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	10	3	410000000	7814364449493747	7809898564645205	933266593617	5266225016440	6199491610057	1
106	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	10	3	410000000	7818652899446105	7813805668066000	1026286473052	5789413905538	6815700378590	1
107	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	10	5	410000000	7841698003754644	7834391127438345	745591504996	4196714288403	4942305793399	1
108	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	11	3	500000000	7792417128658904	7792416828190649	0	0	0	1
109	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	11	3	400000000	7823479694789646	7818988366761364	551568204398	3111428194325	3662996398723	1
110	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	11	3	400000000	7833240108697327	7827116758380824	1010856693176	5696269031052	6707125724228	1
111	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	11	3	500000000	7826384779061034	7820500504132829	1379295159259	7774796658517	9154091817776	1
112	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	11	3	600000000	7787201781175307	7787201580974627	0	0	0	1
113	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	11	3	420000000	7837536756377273	7830906476497297	1469896149248	8280574808927	9750470958175	1
114	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	11	3	410000000	7821140010084071	7815655290065368	919994455660	5186825843886	6106820299546	1
115	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	11	3	410000000	7826044955315325	7820086487800372	1287497695891	7256692325076	8544190020967	1
116	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	11	5	410000000	7851537787769726	7842750032597097	826768596431	4648090989448	5474859585879	1
117	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	12	3	500000000	7792417128658904	7792416828190649	0	0	0	1
118	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	12	3	400000000	7831583407978223	7825873478461732	975305769064	5497780679527	6473086448591	1
119	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	12	3	400000000	7839469575044733	7832408746638220	886637447255	4992066919842	5878704367097	1
120	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	12	3	500000000	7836984129886180	7829505248767382	1241928738668	6990867521710	8232796260378	1
121	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	12	3	600000000	7787201781175307	7787201580974627	0	0	0	1
122	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	12	3	420000000	7842518718270097	7835138519755773	886477517130	4989941230737	5876418747867	1
123	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	12	3	410000000	7826753334025164	7820423973622974	887617040683	5000638543685	5888255584368	1
124	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	12	3	410000000	7831657533158352	7824854594524531	1685696929335	9494982930542	11180679859877	1
125	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	12	5	410000000	7857138798133579	7847507003978473	1329232679056	7468993725731	8798226404787	1
126	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	13	3	500000000	7792417128658904	7792416828190649	0	0	0	1
127	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	13	3	400000000	7840259411656082	7833244386148467	792558191423	4462311734863	5254869926286	1
128	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	13	3	400000000	7846277931934022	7838191675457126	1144657016635	6439888431423	7584545448058	1
129	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	13	3	500000000	7840701328885125	7832662570539395	881181462225	4957233817286	5838415279511	1
130	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	13	3	600000000	7787201781175307	7787201580974627	0	0	0	1
131	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	13	3	420000000	7849944854005525	7841446193447375	1320460402798	7426850175562	8747310578360	1
132	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	13	3	410000000	7832952825635221	7825690198639414	881565673506	4962625075458	5844190748964	1
133	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	13	3	410000000	7838473233536942	7830644008430069	1057502982687	5950586844520	7008089827207	1
134	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	13	5	410000000	7862081103926978	7851703718266876	704261718324	3953769134884	4658030853208	1
135	pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	1000000	14	3	500000000	7792417128658904	7792416828190649	0	0	0	1
136	pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	1000000	14	3	400000000	7843922408054805	7836355814342792	1050608986222	5913176794999	6963785781221	1
137	pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	1000000	14	3	400000000	7852985057658250	7843887944488178	1313095448966	7381591178659	8694686627625	1
138	pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	1000000	14	3	500000000	7849855420702901	7840437367197912	963632935861	5415012661988	6378645597849	1
139	pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	1000000	14	3	600000000	7787201781175307	7787201580974627	0	0	0	1
140	pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	1000000	14	3	420000000	7859695324963700	7849726768256302	700290084442	3932917105385	4633207189827	1
141	pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	1000000	14	4	410000000	7841560948373263	7833378326921796	876215290312	4928687127907	5804902418219	1
142	pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	1000000	14	3	410000000	7847017423557909	7837900700755145	876198061719	4924667879420	5800865941139	1
143	pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	1000000	14	5	410000000	7865054660407419	7853850506150886	700444910895	3929605160185	4630050071080	1
\.


--
-- Data for Name: stake_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stake_pool (id, status, last_registration_id, last_retirement_id) FROM stdin;
pool1k8q6kttqpdadzduhkdjhm36z95hffx7jk6rrp7esrvf9jglnhlh	retiring	9920000000000	10150000000000
pool1mqs7r7n6d80ee7tnld9xk778cxjz8n2743vjhc8z7p2wup8yl7c	retiring	12260000000000	12650000000000
pool1e964zh7nn5lnvpptjk9scmhwt8p3gj0uwmfamupgk29m26fc459	active	2080000000000	\N
pool1u7vrkjt3zjsurnqfca6tl7yp0zj55zvczaz2px0cfg34x4sccnv	active	2910000000000	\N
pool1admr8x6frcr7a0nktuxwz20ym63304f5vd7h7429gsw5ww6sh8m	active	4100000000000	\N
pool1xcfu5j82h4wtcvpr9drps2qf6jay2v6nq4wxvsrrm53cx6vkqdv	active	4970000000000	\N
pool1q530ftx9aev7s7ycq77p87fuxdtt94dgsxr0v6zgaq2pwkppzfc	active	5630000000000	\N
pool13ty6mvu5ahz3ljv2e75l8cxg9swef0wmz20srke67a4l5mugv3v	active	6580000000000	\N
pool16wnsj90ppg4l9wjug5gg2rwyzqzvqugqaqhadeeskm6y2303e4z	active	7670000000000	\N
pool1p50wvnvah4s8tq3m7f478wnew3fetwqy7ztedt0synf4qn0832s	retired	8540000000000	8810000000000
pool14qtr03spcl72xf79xd9e5cnlhxe9ny8es9xjnpvf6ftn2yqfamg	retired	10820000000000	11450000000000
pool1e4eq6j07vld0wu9qwpjk5mey426cwuszj7lxv89tht3u6t8nvg4	activating	162370000000000	\N
pool1m7y2gakwewqyaz05tvmqqwvl2h4jj2qxtknkzew0dhtuwuupreq	activating	163520000000000	\N
\.


--
-- Name: pool_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_metadata_id_seq', 1, false);


--
-- Name: pool_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pool_rewards_id_seq', 143, true);


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

