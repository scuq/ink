\c ink;
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: insertDomain(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "insertDomain"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
BEGIN

	NEW.rev_domain = reverse_dst_domain(NEW.domain);

	RETURN NEW;
END;$$;


ALTER FUNCTION public."insertDomain"() OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: dst_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dst_list(dst character varying) RETURNS character varying[]
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
DECLARE

  dsts character varying[];
  dst_parts character varying[];
  current_dst character varying;

BEGIN

dst_parts := regexp_split_to_array(dst,'\.');

FOR i IN 2..array_length(dst_parts, 1) LOOP

  
     current_dst := array_to_string(dst_parts[1:i], '.');

     dsts := array_append(dsts, current_dst);

     
--   RAISE NOTICE '%', array_to_string(dst_parts[1:i], '.');
    
END LOOP;
 
RETURN dsts;

END$$;


ALTER FUNCTION public.dst_list(dst character varying) OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: reverse_dst_domain(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION reverse_dst_domain(dst character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
DECLARE

  rev_dst character varying;
  dst_parts character varying[];

BEGIN
rev_dst := '';

dst_parts := regexp_split_to_array(dst,'\.');

FOR i IN REVERSE array_length(dst_parts, 1)..1 LOOP
       


        IF rev_dst = '' THEN
             rev_dst := dst_parts[i];
        ELSE
             
             rev_dst := rev_dst || '.' ||  dst_parts[i];
        END IF;
END LOOP;
   
 
RETURN rev_dst;

END$$;


ALTER FUNCTION public.reverse_dst_domain(dst character varying) OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

