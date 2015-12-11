
CREATE DATABASE ink WITH TEMPLATE = template0 OWNER = postgres;


\connect ink


--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
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

--
-- Name: req_allowed_result; Type: TYPE; Schema: public; Owner: postgres
--

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

--
-- Name: create_all_list_tables(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_all_list_tables() RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE

  current_table_list character varying[];

BEGIN

-- create tables for domain lists
--
current_table_list := array(SELECT list_domains_table_name FROM profiles);


FOR i IN 1..array_length(current_table_list, 1) LOOP
  

  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = current_table_list[i])
  THEN
   RAISE NOTICE 'Creating table % with create_table_list_domains()', current_table_list[i];
   PERFORM SELECT create_table_list_domains(current_table_list[i]);
  ELSE
   RAISE NOTICE 'Table % already exists.', current_table_list[i];
  END IF;


END LOOP;

-- create tables for url lists
--

current_table_list := array(SELECT list_urls_table_name FROM profiles);


FOR i IN 1..array_length(current_table_list, 1) LOOP
  

  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = current_table_list[i])
  THEN
   RAISE NOTICE 'Creating table % with create_table_list_urls()', current_table_list[i];
   PERFORM SELECT create_table_list_urls(current_table_list[i]);
  ELSE
   RAISE NOTICE 'Table % already exists.', current_table_list[i];
  END IF;


END LOOP;


-- create tables for ip lists
--

current_table_list := array(SELECT list_ips_table_name FROM profiles);


FOR i IN 1..array_length(current_table_list, 1) LOOP
  

  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = current_table_list[i])
  THEN
   RAISE NOTICE 'Creating table % with create_table_list_ips()', current_table_list[i];
   PERFORM SELECT create_table_list_ips(current_table_list[i]);
  ELSE
   RAISE NOTICE 'Table % already exists.', current_table_list[i];
  END IF;



END LOOP;

-- create tables for custom domain lists
--
current_table_list := array(SELECT list_custom_domains_table_name FROM profiles);


FOR i IN 1..array_length(current_table_list, 1) LOOP
  

  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = current_table_list[i])
  THEN
   RAISE NOTICE 'Creating table % with create_table_list_custom_domains()', current_table_list[i];
   PERFORM SELECT create_table_list_custom_domains(current_table_list[i]);
  ELSE
   RAISE NOTICE 'Table % already exists.', current_table_list[i];
  END IF;


END LOOP;

-- create tables for custom url lists
--

current_table_list := array(SELECT list_custom_urls_table_name FROM profiles);


FOR i IN 1..array_length(current_table_list, 1) LOOP
  

  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = current_table_list[i])
  THEN
   RAISE NOTICE 'Creating table % with create_table_list_custom_urls()', current_table_list[i];
   PERFORM SELECT create_table_list_custom_urls(current_table_list[i]);
  ELSE
   RAISE NOTICE 'Table % already exists.', current_table_list[i];
  END IF;


END LOOP;


-- create tables for custom ip lists
--

current_table_list := array(SELECT list_custom_ips_table_name FROM profiles);


FOR i IN 1..array_length(current_table_list, 1) LOOP
  

  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = current_table_list[i])
  THEN
   RAISE NOTICE 'Creating table % with create_table_list_custom_ips()', current_table_list[i];
   PERFORM SELECT create_table_list_custom_ips(current_table_list[i]);
  ELSE
   RAISE NOTICE 'Table % already exists.', current_table_list[i];
  END IF;


END LOOP;

RETURN;

END$$;


ALTER FUNCTION public.create_all_list_tables() OWNER TO postgres;

--
-- Name: create_table_list_custom_domains(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--
CREATE FUNCTION create_table_list_custom_domains(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN

EXECUTE '

CREATE TABLE '|| t_name ||' (
    id bigint NOT NULL,
    domain character varying NOT NULL,
    rev_domain character varying NOT NULL,
    category character varying,
    allowed boolean
); 

GRANT SELECT ON TABLE '|| t_name ||' TO inkquerier;

ALTER TABLE public.'|| t_name ||' OWNER TO postgres;

CREATE SEQUENCE '|| t_name ||'_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER TABLE public.'|| t_name ||'_id_seq OWNER TO postgres;

ALTER SEQUENCE '|| t_name ||'_id_seq OWNED BY '|| t_name ||'.id;

ALTER TABLE ONLY '|| t_name ||' ALTER COLUMN id SET DEFAULT nextval('''|| t_name ||'_id_seq''::regclass);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_key UNIQUE (domain);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_pkey PRIMARY KEY (id);

CREATE INDEX '|| t_name ||'_col_rev_domain_idx ON '|| t_name ||' USING btree (rev_domain text_pattern_ops);

CREATE TRIGGER on_insert_domain BEFORE INSERT OR UPDATE ON '|| t_name ||' FOR EACH ROW EXECUTE PROCEDURE "insertDomain"();


';



END
$$;



ALTER FUNCTION public.create_table_list_custom_domains(t_name character varying) OWNER TO postgres;

--
-- Name: create_table_list_custom_ips(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_custom_ips(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN

EXECUTE '

CREATE TABLE '|| t_name ||' (
    id bigint NOT NULL,
    ip inet NOT NULL,
    category character varying,
    allowed boolean
); 

GRANT SELECT ON TABLE '|| t_name ||' TO inkquerier;

ALTER TABLE public.'|| t_name ||' OWNER TO postgres;

CREATE SEQUENCE '|| t_name ||'_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER TABLE public.'|| t_name ||'_id_seq OWNER TO postgres;

ALTER SEQUENCE '|| t_name ||'_id_seq OWNED BY '|| t_name ||'.id;

ALTER TABLE ONLY '|| t_name ||' ALTER COLUMN id SET DEFAULT nextval('''|| t_name ||'_id_seq''::regclass);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_key UNIQUE (ip);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_pkey PRIMARY KEY (id);





';



END
$$;


ALTER FUNCTION public.create_table_list_custom_ips(t_name character varying) OWNER TO postgres;

--
-- Name: create_table_list_custom_urls(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_custom_urls(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN

EXECUTE '

CREATE TABLE '|| t_name ||' (
    id bigint NOT NULL,
    url character varying NOT NULL,
    category character varying,
    allowed boolean
); 

GRANT SELECT ON TABLE '|| t_name ||' TO inkquerier;

ALTER TABLE public.'|| t_name ||' OWNER TO postgres;

CREATE SEQUENCE '|| t_name ||'_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER TABLE public.'|| t_name ||'_id_seq OWNER TO postgres;

ALTER SEQUENCE '|| t_name ||'_id_seq OWNED BY '|| t_name ||'.id;

ALTER TABLE ONLY '|| t_name ||' ALTER COLUMN id SET DEFAULT nextval('''|| t_name ||'_id_seq''::regclass);


ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_key UNIQUE (url);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_pkey PRIMARY KEY (id);

CREATE INDEX '|| t_name ||'_col_rev_url_idx ON '|| t_name ||' USING btree (url text_pattern_ops);




';



END
$$;


ALTER FUNCTION public.create_table_list_custom_urls(t_name character varying) OWNER TO postgres;

--
-- Name: create_table_list_domains(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_domains(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN

EXECUTE '

CREATE TABLE  '|| t_name ||' (
    id bigint NOT NULL,
    domain character varying NOT NULL,
    rev_domain character varying NOT NULL,
    category character varying
); 

GRANT SELECT ON TABLE  '|| t_name ||' TO inkquerier;

ALTER TABLE public. '|| t_name ||' OWNER TO postgres;

CREATE SEQUENCE  '|| t_name ||'_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER TABLE public. '|| t_name ||'_id_seq OWNER TO postgres;

ALTER SEQUENCE  '|| t_name ||'_id_seq OWNED BY  '|| t_name ||'.id;

ALTER TABLE ONLY  '|| t_name ||' ALTER COLUMN id SET DEFAULT nextval('' '|| t_name ||'_id_seq''::regclass);

ALTER TABLE ONLY  '|| t_name ||' ADD CONSTRAINT  '|| t_name ||'_key UNIQUE (domain);

ALTER TABLE ONLY  '|| t_name ||' ADD CONSTRAINT  '|| t_name ||'_pkey PRIMARY KEY (id);

CREATE INDEX  '|| t_name ||'_col_rev_domain_idx ON  '|| t_name ||' USING btree (rev_domain text_pattern_ops);

CREATE TRIGGER on_insert_domain BEFORE INSERT OR UPDATE ON  '|| t_name ||' FOR EACH ROW EXECUTE PROCEDURE "insertDomain"();


';



END
$$;


ALTER FUNCTION public.create_table_list_domains(t_name character varying) OWNER TO postgres;

--
-- Name: create_table_list_ips(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_ips(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN

EXECUTE '

CREATE TABLE '|| t_name ||' (
    id bigint NOT NULL,
    ip inet NOT NULL,
    category character varying
); 

GRANT SELECT ON TABLE '|| t_name ||' TO inkquerier;

ALTER TABLE public.'|| t_name ||' OWNER TO postgres;

CREATE SEQUENCE '|| t_name ||'_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER TABLE public.'|| t_name ||'_id_seq OWNER TO postgres;

ALTER SEQUENCE '|| t_name ||'_id_seq OWNED BY '|| t_name ||'.id;

ALTER TABLE ONLY '|| t_name ||' ALTER COLUMN id SET DEFAULT nextval('''|| t_name ||'_id_seq''::regclass);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_key UNIQUE (ip);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_pkey PRIMARY KEY (id);





';



END
$$;


ALTER FUNCTION public.create_table_list_ips(t_name character varying) OWNER TO postgres;

--
-- Name: create_table_list_urls(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_urls(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN

EXECUTE '

CREATE TABLE '|| t_name ||' (
    id bigint NOT NULL,
    url character varying NOT NULL,
    category character varying
); 

GRANT SELECT ON TABLE '|| t_name ||' TO inkquerier;

ALTER TABLE public.'|| t_name ||' OWNER TO postgres;

CREATE SEQUENCE '|| t_name ||'_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

ALTER TABLE public.'|| t_name ||'_id_seq OWNER TO postgres;

ALTER SEQUENCE '|| t_name ||'_id_seq OWNED BY '|| t_name ||'.id;

ALTER TABLE ONLY '|| t_name ||' ALTER COLUMN id SET DEFAULT nextval('''|| t_name ||'_id_seq''::regclass);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_key UNIQUE (url);

ALTER TABLE ONLY '|| t_name ||' ADD CONSTRAINT '|| t_name ||'_pkey PRIMARY KEY (id);

CREATE INDEX '|| t_name ||'_col_rev_url_idx ON '|| t_name ||' USING btree (url text_pattern_ops);




';



END
$$;


ALTER FUNCTION public.create_table_list_urls(t_name character varying) OWNER TO postgres;

--
-- Name: dst_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dst_list(dst character varying) RETURNS character varying[]
    LANGUAGE plpgsql
    AS $$DECLARE

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
-- Name: insertDomain(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "insertDomain"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN

NEW.rev_domain = reverse_dst_domain(NEW.domain);

RETURN NEW;
END;$$;


ALTER FUNCTION public."insertDomain"() OWNER TO postgres;

--
-- Name: req_allowed_default(character varying, character varying, character varying, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION req_allowed_default(in_login character varying, in_src character varying, in_uri character varying, in_dst character varying, in_domain character varying, in_dstisip boolean) RETURNS req_allowed_result
    LANGUAGE plpgsql
    AS $$DECLARE
  found_profile character varying;
  found_profile_mode  prx_profilemode;
  found_list_custom_urls character varying;
  found_list_custom_domains character varying;
  found_list_custom_ips character varying;
  found_list_urls character varying;
  found_list_domains character varying;
  found_list_ips character varying;
  no_records_found int;
  rev_in_dst character varying;
  rev_in_dsts character varying[];
  queries_used int;
  message character varying;
  result req_allowed_result;
  custom_allowed boolean;



BEGIN

queries_used := 0;

rev_in_dst := reverse_dst_domain(in_dst);

rev_in_dsts := dst_list(rev_in_dst);

found_profile := (select profile from accounts WHERE LOWER(accountname)=LOWER(in_login) and LOWER(netbiosdomainname)=LOWER(in_domain) LIMIT 1);

queries_used := queries_used+1;

RAISE NOTICE 'Profile Found: %', found_profile;

IF found_profile IS NULL THEN
  RAISE NOTICE 'NO PROFILE';
  select in_domain, '<NONE>', 'whitelist', in_login, '',  'f', queries_used, message into result;
  return result;
END IF;






SELECT INTO 
 found_profile_mode, 
 found_list_urls, 
 found_list_domains, 
 found_list_ips,
 found_list_custom_urls,
 found_list_custom_domains,
 found_list_custom_ips

 mode, 
 list_urls_table_name, 
 list_domains_table_name, 
 list_ips_table_name,
 list_custom_urls_table_name, 
 list_custom_domains_table_name, 
 list_custom_ips_table_name

 from profiles WHERE LOWER(profile) = LOWER(found_profile) LIMIT 1;

queries_used := queries_used+1;


RAISE NOTICE 'Profile Mode: %', found_profile_mode;
RAISE NOTICE 'Profile Url-List: %', found_list_urls;
RAISE NOTICE 'Profile Domain-List: %', found_list_domains;
RAISE NOTICE 'Profile IP-List: %', found_list_ips;


FOR i IN 1..array_length(rev_in_dsts, 1) LOOP

  --  EXECUTE 'SELECT id, allowed FROM ' || found_list_custom_domains || ' where rev_domain like '''|| rev_in_dsts[i] ||'%'';' INTO no_records_found, custom_allowed;
  EXECUTE 'SELECT id, allowed FROM ' || found_list_custom_domains || ' where rev_domain = '''|| rev_in_dsts[i] ||''';' INTO no_records_found, custom_allowed;

  queries_used := queries_used+1;

  RAISE NOTICE 'Records found in %: %', found_list_custom_domains, no_records_found;

 
  IF no_records_found > 0 THEN
            IF custom_allowed = TRUE THEN
               message := 'found in: ' || found_list_custom_domains;
               select in_domain, found_profile, found_profile_mode, in_login, '',  't', queries_used, message into result;
            ELSE
               message := 'found in: ' || found_list_custom_domains;
               select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
            END IF;
            return result;
  END IF;



END LOOP;



EXECUTE 'SELECT count(*) as count FROM ' || found_list_urls || ' where url like '''|| in_uri ||'%'';' INTO no_records_found;

queries_used := queries_used+1;

RAISE NOTICE 'Records found in %: %', found_list_urls, no_records_found;

IF found_profile_mode = 'blacklist' THEN
    IF no_records_found > 0 THEN
          message := 'found in: ' || found_list_urls;
          select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
          return result;
    END IF;
END IF;




RAISE NOTICE 'isip %', in_dstisip;

IF in_dstisip = TRUE THEN

   EXECUTE 'SELECT count(*) as count FROM ' || found_list_ips || ' where ip = '''|| in_dst ||''';' INTO no_records_found;

   queries_used := queries_used+1;

   RAISE NOTICE 'Records found in ips %: %', found_list_ips, no_records_found;

   IF found_profile_mode = 'blacklist' THEN
       IF no_records_found > 0 THEN
             message := 'found in: ' || found_list_ips;
             select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
             return result;
       END IF;
   END IF;

   IF found_profile_mode = 'whitelist' THEN
       IF no_records_found > 0 THEN
             message := 'found in: ' || found_list_ips;
             select in_domain, found_profile, found_profile_mode, in_login, '',  't', queries_used, message into result;
             return result;
       ELSE
             message := 'NOT found in: ' || found_list_ips;
             select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
             return result;
       END IF;
   END IF;


END IF;

FOR i IN 1..array_length(rev_in_dsts, 1) LOOP

  -- EXECUTE 'SELECT count(*) as count FROM ' || found_list_domains || ' where rev_domain like '''|| rev_in_dsts[i] ||'%'';' INTO no_records_found;
  EXECUTE 'SELECT count(*) as count FROM ' || found_list_domains || ' where rev_domain ='''|| rev_in_dsts[i] ||''';' INTO no_records_found;

  queries_used := queries_used+1;

  RAISE NOTICE 'Records found in %: %', found_list_domains, no_records_found;

  IF found_profile_mode = 'blacklist' THEN
      IF no_records_found > 0 THEN
            message := 'found in: ' || found_list_domains;
            select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
            return result;
      END IF;
  END IF;

  IF found_profile_mode = 'whitelist' THEN
      IF no_records_found > 0 THEN
            message := 'found in: ' || found_list_domains;
            select in_domain, found_profile, found_profile_mode, in_login, '',  't', queries_used, message into result;
            return result;
      ELSE
            message := 'NOT found in: ' || found_list_domains;
            select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
            return result;
      END IF;
  END IF;

END LOOP;


IF found_profile_mode = 'whitelist' THEN
    IF no_records_found > 0 THEN
          message := 'found in: ' || found_list_urls;
          select in_domain, found_profile, found_profile_mode, in_login, '',  't', queries_used, message into result;
          return result;
    ELSE
           message := 'NOT found in: ' || found_list_urls;
          select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
          return result;
    END IF;
END IF;

IF found_profile_mode = 'blacklist' THEN

   message := 'not found in any scanned table';

   select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;

END IF;

IF found_profile_mode = 'whitelist' THEN
   message := 'not found in any scanned table';

   select in_domain, found_profile, found_profile_mode, in_login, '',  't', queries_used, message into result;
END IF;

return result;




END$$;


ALTER FUNCTION public.req_allowed_default(in_login character varying, in_src character varying, in_uri character varying, in_dst character varying, in_domain character varying, in_dstisip boolean) OWNER TO postgres;

--
-- Name: req_allowed_useragent(character varying, inet, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION req_allowed_useragent(in_useragent character varying, in_src inet, in_uri character varying, in_dst character varying, in_dstisip boolean) RETURNS req_allowed_result
    LANGUAGE plpgsql
    AS $$DECLARE
  found_profile character varying;
  found_profile_mode  prx_profilemode;
  found_list_custom_urls character varying;
  found_list_custom_domains character varying;
  found_list_custom_ips character varying;
  found_list_urls character varying;
  found_list_domains character varying;
  found_list_ips character varying;

  found_rxs_by_src character varying[];
  result req_allowed_result;
  queries_used int;
  no_records_found int;
  rev_in_dst character varying;
  rev_in_dsts character varying[];
  message character varying;

  custom_allowed boolean;
  pseudo_login character varying;

BEGIN
  queries_used := 0;

  rev_in_dst := reverse_dst_domain(in_dst);

  rev_in_dsts := dst_list(rev_in_dst);


  found_rxs_by_src := array((select useragentrx from useragents WHERE subnet <<= in_src));

  queries_used := queries_used+1;

  IF array_length(found_rxs_by_src, 1) <= 0 THEN
    message := 'src-ip not found in any subnet of table useragents';
    select '<USERAGENT>', '<NONE>', 'whitelist', in_src, '',  'f', queries_used, message into result;
    RETURN result;
  END IF;

  IF array_length(found_rxs_by_src, 1) IS NULL THEN
    message := 'src-ip not found in any subnet of table useragents';
    select '<USERAGENT>', '<NONE>', 'whitelist', in_src, '',  'f', queries_used, message into result;
    RETURN result;
  END IF;


  FOR i IN 1..array_length(found_rxs_by_src, 1) LOOP

    IF in_useragent ~ found_rxs_by_src[i] THEN
        found_profile := (select profile from useragents WHERE useragentrx = found_rxs_by_src[i] AND subnet <<= in_src);
        pseudo_login := (select accountname from useragents WHERE useragentrx = found_rxs_by_src[i] AND subnet <<= in_src);
        queries_used := queries_used+2;
        EXIT;
    END IF;


  END LOOP;

  
  RAISE NOTICE 'Profile Found: %', found_profile;


  IF found_profile IS NULL THEN
    message := 'src-ip found but no matching useragentrx found in table useragents';
    select '<USERAGENT>', '<NONE>', 'whitelist', in_src, '',  'f', queries_used, message into result;
    return result;
  END IF;


  SELECT INTO 
   found_profile_mode, 
   found_list_urls, 
   found_list_domains, 
   found_list_ips,
   found_list_custom_urls,
   found_list_custom_domains,
   found_list_custom_ips

   mode, 
   list_urls_table_name, 
   list_domains_table_name, 
   list_ips_table_name,
   list_custom_urls_table_name, 
   list_custom_domains_table_name, 
   list_custom_ips_table_name

   from profiles WHERE LOWER(profile) = LOWER(found_profile) LIMIT 1;

   queries_used := queries_used+1;

   RAISE NOTICE 'Profile Mode: %', found_profile_mode;
   RAISE NOTICE 'Profile Url-List: %', found_list_urls;
   RAISE NOTICE 'Profile Domain-List: %', found_list_domains;
   RAISE NOTICE 'Profile IP-List: %', found_list_ips;

   

   FOR i IN 1..array_length(rev_in_dsts, 1) LOOP
   
     EXECUTE 'SELECT id, allowed FROM ' || found_list_custom_domains || ' where rev_domain = '''|| rev_in_dsts[i] ||''';' INTO no_records_found, custom_allowed;
   
     queries_used := queries_used+1;
   
     RAISE NOTICE 'Records found in %: %', found_list_custom_domains, no_records_found;
   
    
     IF no_records_found > 0 THEN
               IF custom_allowed = TRUE THEN
                  message := 'found in: ' || found_list_custom_domains;
                  select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  't', queries_used, message into result;
               ELSE
                  message := 'found in: ' || found_list_custom_domains;
                  select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  'f', queries_used, message into result;
               END IF;
               return result;
     END IF;
   
   
   
   END LOOP;
   
   
   
   EXECUTE 'SELECT count(*) as count FROM ' || found_list_urls || ' where url like '''|| in_uri ||'%'';' INTO no_records_found;
   
   queries_used := queries_used+1;
   
   RAISE NOTICE 'Records found in %: %', found_list_urls, no_records_found;
   
   IF found_profile_mode = 'blacklist' THEN
       IF no_records_found > 0 THEN
             message := 'found in: ' || found_list_urls;
             select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  'f', queries_used, message into result;
             return result;
       END IF;
   END IF;
   
   RAISE NOTICE 'isip %', in_dstisip;
   
   IF in_dstisip = TRUE THEN
   
      EXECUTE 'SELECT count(*) as count FROM ' || found_list_ips || ' where ip = '''|| in_dst ||''';' INTO no_records_found;
   
      queries_used := queries_used+1;
   
      RAISE NOTICE 'Records found in ips %: %', found_list_ips, no_records_found;
   
      IF found_profile_mode = 'blacklist' THEN
          IF no_records_found > 0 THEN
                message := 'found in: ' || found_list_ips;
                select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  'f', queries_used, message into result;
                return result;
          END IF;
      END IF;
   
   END IF;
   
   FOR i IN 1..array_length(rev_in_dsts, 1) LOOP
   
     EXECUTE 'SELECT count(*) as count FROM ' || found_list_domains || ' where rev_domain = '''|| rev_in_dsts[i] ||''';' INTO no_records_found;
   
     queries_used := queries_used+1;
   
     RAISE NOTICE 'Records found in %: %', found_list_domains, no_records_found;
   
     IF found_profile_mode = 'blacklist' THEN
         IF no_records_found > 0 THEN
               message := 'found in: ' || found_list_domains;
               select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  'f', queries_used, message into result;
               return result;
         END IF;
     END IF;
   
   
   END LOOP;
   
   
   
   message := 'not found in any scanned table';
   
   select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  't', queries_used, message into result;
   
   return result;


  RETURN result;
END$$;


ALTER FUNCTION public.req_allowed_useragent(in_useragent character varying, in_src inet, in_uri character varying, in_dst character varying, in_dstisip boolean) OWNER TO postgres;

--
-- Name: reverse_dst_domain(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION reverse_dst_domain(dst character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$DECLARE
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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE accounts (
    netbiosdomainname character varying(15) NOT NULL,
    accountname character varying NOT NULL,
    email character varying,
    enabled boolean DEFAULT true,
    profile character varying(20) DEFAULT '<NONE>'::character varying NOT NULL,
    priority integer
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: TABLE accounts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE accounts IS 'Cached Account to Profile Assignment table';


--
-- Name: cfg_categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cfg_categories (
    id bigint NOT NULL,
    category character varying NOT NULL
);


ALTER TABLE public.cfg_categories OWNER TO postgres;

--
-- Name: COLUMN cfg_categories.category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN cfg_categories.category IS 'Category Name';


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE categories_id_seq OWNED BY cfg_categories.id;


--
-- Name: cfg_activedirectory; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cfg_activedirectory (
    id bigint NOT NULL,
    domain character varying NOT NULL,
    netbiosdomainname character varying NOT NULL,
    basedn character varying NOT NULL,
    username character varying NOT NULL,
    password character varying NOT NULL
);


ALTER TABLE public.cfg_activedirectory OWNER TO postgres;

--
-- Name: cfg_activedirectory_group_profile; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cfg_activedirectory_group_profile (
    id bigint NOT NULL,
    ldapgroup character varying NOT NULL,
    profile character varying NOT NULL,
    domain character varying NOT NULL,
    netbiosdomainname character varying NOT NULL,
    priority integer DEFAULT 0
);


ALTER TABLE public.cfg_activedirectory_group_profile OWNER TO postgres;

--
-- Name: cfg_activedirectory_group_profile_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cfg_activedirectory_group_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cfg_activedirectory_group_profile_id_seq OWNER TO postgres;

--
-- Name: cfg_activedirectory_group_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cfg_activedirectory_group_profile_id_seq OWNED BY cfg_activedirectory_group_profile.id;


--
-- Name: cfg_activedirectory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cfg_activedirectory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cfg_activedirectory_id_seq OWNER TO postgres;

--
-- Name: cfg_activedirectory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cfg_activedirectory_id_seq OWNED BY cfg_activedirectory.id;


--
-- Name: cfg_profile_category_link; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cfg_profile_category_link (
    id integer NOT NULL,
    idprofiles bigint NOT NULL,
    idcategories bigint NOT NULL
);


ALTER TABLE public.cfg_profile_category_link OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE profiles (
    profile character varying(20) NOT NULL,
    profiledesc character varying NOT NULL,
    mode prx_profilemode NOT NULL,
    list_domains_table_name character varying,
    id bigint NOT NULL,
    list_urls_table_name character varying,
    list_ips_table_name character varying,
    list_custom_domains_table_name character varying,
    list_custom_urls_table_name character varying,
    list_custom_ips_table_name character varying
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: TABLE profiles; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE profiles IS 'Definition of profiles and their modes';


--
-- Name: COLUMN profiles.profile; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN profiles.profile IS 'Profile name';


--
-- Name: COLUMN profiles.profiledesc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN profiles.profiledesc IS 'Profile description ';


--
-- Name: COLUMN profiles.mode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN profiles.mode IS 'Profile Modes: whitelist,blacklist,greylist';


--
-- Name: COLUMN profiles.list_domains_table_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN profiles.list_domains_table_name IS 'Name of the database table to lookup requests if in blacklist mode';


--
-- Name: cfg_profile_category; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW cfg_profile_category AS
    SELECT profiles.profile, profiles.mode, categories.category FROM cfg_profile_category_link profile_category_link, profiles, cfg_categories categories WHERE ((profile_category_link.idprofiles = profiles.id) AND (profile_category_link.idcategories = categories.id));


ALTER TABLE public.cfg_profile_category OWNER TO postgres;


--
-- Name: temp_accounts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE temp_accounts (
    netbiosdomainname character varying NOT NULL,
    accountname character varying NOT NULL,
    email character varying,
    enabled boolean DEFAULT true,
    profile character varying DEFAULT '<NONE>'::character varying NOT NULL,
    priority integer
);


ALTER TABLE public.temp_accounts OWNER TO postgres;

--
-- Name: clean_temp_accounts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW clean_temp_accounts AS
    SELECT temp_accounts.netbiosdomainname, temp_accounts.accountname, temp_accounts.email, temp_accounts.enabled, temp_accounts.profile, temp_accounts.priority FROM (temp_accounts JOIN (SELECT temp_accounts.netbiosdomainname, temp_accounts.accountname, max(temp_accounts.priority) AS prio FROM temp_accounts GROUP BY temp_accounts.netbiosdomainname, temp_accounts.accountname) maxprio ON (((((temp_accounts.netbiosdomainname)::text = (maxprio.netbiosdomainname)::text) AND ((temp_accounts.accountname)::text = (maxprio.accountname)::text)) AND (temp_accounts.priority = maxprio.prio))));


ALTER TABLE public.clean_temp_accounts OWNER TO postgres;


--
-- Name: profile_category_link_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE profile_category_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.profile_category_link_id_seq OWNER TO postgres;

--
-- Name: profile_category_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE profile_category_link_id_seq OWNED BY cfg_profile_category_link.id;


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.profiles_id_seq OWNER TO postgres;

--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: useragents; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE useragents (
    useragentrx character varying NOT NULL,
    subnet inet NOT NULL,
    accountname character varying NOT NULL,
    profile character varying DEFAULT '<NONE>'::character varying NOT NULL
);


ALTER TABLE public.useragents OWNER TO postgres;

--
-- Name: TABLE useragents; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE useragents IS 'Definition of User-Agent/Subnet Excpetions';


--
-- Name: COLUMN useragents.useragentrx; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN useragents.useragentrx IS 'User-Agent RegEx';


--
-- Name: COLUMN useragents.subnet; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN useragents.subnet IS 'IP-Subnet Restriction';


--
-- Name: COLUMN useragents.accountname; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN useragents.accountname IS 'Pseudo accountname for the combination of the User-Agent RegEx and the Subnet';


--
-- Name: COLUMN useragents.profile; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN useragents.profile IS 'Name of the Proxy-Access-Profile';


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_activedirectory ALTER COLUMN id SET DEFAULT nextval('cfg_activedirectory_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_activedirectory_group_profile ALTER COLUMN id SET DEFAULT nextval('cfg_activedirectory_group_profile_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_profile_category_link ALTER COLUMN id SET DEFAULT nextval('profile_category_link_id_seq'::regclass);



--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: aduser_2_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT aduser_2_profile_pkey PRIMARY KEY (netbiosdomainname, accountname);


--
-- Name: categories_category_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_categories
    ADD CONSTRAINT categories_category_key UNIQUE (category);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cfg_activedirectory_basedn_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_activedirectory
    ADD CONSTRAINT cfg_activedirectory_basedn_key UNIQUE (basedn);


--
-- Name: cfg_activedirectory_domain_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_activedirectory
    ADD CONSTRAINT cfg_activedirectory_domain_key UNIQUE (domain);


--
-- Name: cfg_activedirectory_group_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_activedirectory_group_profile
    ADD CONSTRAINT cfg_activedirectory_group_profile_pkey PRIMARY KEY (id);


--
-- Name: cfg_activedirectory_netbiosdomainname_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_activedirectory
    ADD CONSTRAINT cfg_activedirectory_netbiosdomainname_key UNIQUE (netbiosdomainname);


--
-- Name: cfg_activedirectory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_activedirectory
    ADD CONSTRAINT cfg_activedirectory_pkey PRIMARY KEY (id);


--
-- Name: profile_category_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_profile_category_link
    ADD CONSTRAINT profile_category_link_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: useragents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY useragents
    ADD CONSTRAINT useragents_pkey PRIMARY KEY (useragentrx, subnet);



--
-- Name: accounts_col_accountname; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX accounts_col_accountname ON accounts USING btree (accountname text_pattern_ops);


--
-- Name: accounts_col_netbiosdomainname; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX accounts_col_netbiosdomainname ON accounts USING btree (netbiosdomainname text_pattern_ops);


--
-- Name: fk_idCategories_categories; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_profile_category_link
    ADD CONSTRAINT "fk_idCategories_categories" FOREIGN KEY (idcategories) REFERENCES cfg_categories(id);


--
-- Name: fk_idProfiles_profiles; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_profile_category_link
    ADD CONSTRAINT "fk_idProfiles_profiles" FOREIGN KEY (idprofiles) REFERENCES profiles(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO inkupdater;


--
-- Name: accounts; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE accounts FROM PUBLIC;
GRANT ALL ON TABLE accounts TO postgres;
GRANT SELECT ON TABLE accounts TO inkquerier;


--
-- Name: profiles; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE profiles FROM PUBLIC;
GRANT ALL ON TABLE profiles TO postgres;
GRANT SELECT ON TABLE profiles TO inkupdater;
GRANT SELECT ON TABLE profiles TO inkquerier;


--
-- Name: cfg_profile_category; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE cfg_profile_category FROM PUBLIC;
GRANT ALL ON TABLE cfg_profile_category TO postgres;
GRANT SELECT ON TABLE cfg_profile_category TO inkupdater;


--
-- Name: useragents; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE useragents FROM PUBLIC;
GRANT ALL ON TABLE useragents TO postgres;
GRANT SELECT ON TABLE useragents TO inkquerier;


--
-- PostgreSQL database dump complete
--


