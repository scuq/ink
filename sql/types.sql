SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

\connect ink

SET default_transaction_read_only = off;

SET statement_timeout = 0;
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: prx_profilemode; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE prx_profilemode AS ENUM (
    'whitelist',
    'blacklist',
    'greylist'
);


ALTER TYPE public.prx_profilemode OWNER TO postgres;


CREATE TYPE req_allowed_result AS (
	netbiosdomainname character varying,
	profile character varying,
	profile_mode prx_profilemode,
	accountname character varying,
	email character varying,
	req_allowed boolean,
	queries_used integer,
	message character varying
);


ALTER TYPE public.req_allowed_result OWNER TO postgres;

