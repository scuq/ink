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
-- Name: create_table_list_custom_domains(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_custom_domains(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
BEGIN

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

END$$;


ALTER FUNCTION public.create_table_list_custom_domains(t_name character varying) OWNER TO postgres;

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
-- Name: create_table_list_custom_ips(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_custom_ips(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
BEGIN

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

END$$;


ALTER FUNCTION public.create_table_list_custom_ips(t_name character varying) OWNER TO postgres;

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
-- Name: create_table_list_custom_urls(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_custom_urls(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
BEGIN

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
-- Name: create_table_list_domains(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_domains(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
BEGIN

	EXECUTE '

		CREATE TABLE '|| t_name ||' (
		    id bigint NOT NULL,
		    domain character varying NOT NULL,
		    rev_domain character varying NOT NULL,
		    category character varying
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


ALTER FUNCTION public.create_table_list_domains(t_name character varying) OWNER TO postgres;

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
-- Name: create_table_list_ips(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_ips(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
BEGIN

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
-- Name: create_table_list_urls(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_table_list_urls(t_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
BEGIN

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
-- Name: create_all_list_tables(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION create_all_list_tables() RETURNS void
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.1
DECLARE

  current_table_list character varying[];

BEGIN

-- create tables for domain lists
--
current_table_list := array(SELECT list_domains_table_name FROM profiles);


FOR i IN 1..array_length(current_table_list, 1) LOOP
  

  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = current_table_list[i])
  THEN
   RAISE NOTICE 'Creating table % with create_table_list_domains()', current_table_list[i];
   PERFORM create_table_list_domains(current_table_list[i]);
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
   PERFORM create_table_list_urls(current_table_list[i]);
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
   PERFORM create_table_list_ips(current_table_list[i]);
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
   PERFORM create_table_list_custom_domains(current_table_list[i]);
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
   PERFORM create_table_list_custom_urls(current_table_list[i]);
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
   PERFORM create_table_list_custom_ips(current_table_list[i]);
  ELSE
   RAISE NOTICE 'Table % already exists.', current_table_list[i];
  END IF;


END LOOP;

RETURN;

END$$;


ALTER FUNCTION public.create_all_list_tables() OWNER TO postgres;

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
-- Name: req_allowed_useragent(character varying, inet, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION req_allowed_useragent(in_useragent character varying, in_src inet, in_uri character varying, in_dst character varying, in_dstisip boolean) RETURNS req_allowed_result
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.4
DECLARE

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
   
     IF no_records_found IS NULL THEN
       no_records_found := 0;
     END IF;

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
   
   
   
   --EXECUTE 'SELECT count(*) as count FROM ' || found_list_urls || ' where url like '''|| in_uri ||'%'';' INTO no_records_found;
   EXECUTE 'SELECT count(*) as count FROM ' || found_list_urls || ' where url = ''|| quote_literal(in_uri) ||'';' INTO no_records_found;
   
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

      IF found_profile_mode = 'whitelist' THEN
       IF no_records_found > 0 THEN
             message := 'found in: ' || found_list_ips;
             select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  't', queries_used, message into result;
             return result;
       ELSE
             message := 'NOT found in: ' || found_list_ips;
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
   
    IF found_profile_mode = 'whitelist' THEN
      IF no_records_found > 0 THEN
            message := 'found in: ' || found_list_domains;
            select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  't', queries_used, message into result;
            return result;
      ELSE
            message := 'NOT found in: ' || found_list_domains;
            select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  'f', queries_used, message into result;
            return result;
      END IF;
    END IF;   


   END LOOP;
   
   IF found_profile_mode = 'whitelist' THEN
    IF no_records_found > 0 THEN
          message := 'found in: ' || found_list_urls;
          select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  't', queries_used, message into result;
          return result;
    ELSE
           message := 'NOT found in: ' || found_list_urls;
          select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  'f', queries_used, message into result;
          return result;
    END IF;
   END IF;
   
   IF found_profile_mode = 'blacklist' THEN

      message := 'not found in any scanned table';
   
      select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  't', queries_used, message into result;
   
   END IF;

   IF found_profile_mode = 'whitelist' THEN
      message := 'not found in any scanned table';

      select '<USERAGENT>', found_profile, found_profile_mode, pseudo_login, '',  'f', queries_used, message into result;
   END IF;
   


  RETURN result;
END$$;


ALTER FUNCTION public.req_allowed_useragent(in_useragent character varying, in_src inet, in_uri character varying, in_dst character varying, in_dstisip boolean) OWNER TO postgres;

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
-- Name: req_allowed_default(character varying, character varying, character varying, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION req_allowed_default(in_login character varying, in_src character varying, in_uri character varying, in_dst character varying, in_domain character varying, in_dstisip boolean) RETURNS req_allowed_result
    LANGUAGE plpgsql
    AS $$-- version 15.12.11.4

DECLARE

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

  IF no_records_found IS NULL THEN
    no_records_found := 0;
  END IF;

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


--EXECUTE 'SELECT count(*) as count FROM ' || found_list_urls || ' where url like '''|| in_uri ||'%'';' INTO no_records_found;
EXECUTE   'SELECT count(*) as count FROM ' || found_list_urls || ' where url = ''|| quote_literal(in_uri) ||'';' INTO no_records_found;

RAISE NOTICE 'QuoteLiteral: %', quote_literal(in_uri);

queries_used := queries_used+1;

RAISE NOTICE 'Records found in %: %', found_list_urls, no_records_found;

IF found_profile_mode = 'blacklist' THEN
    IF no_records_found > 0 THEN
          message := 'found in: ' || found_list_urls;
          select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
          return result;
    END IF;
END IF;



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

   select in_domain, found_profile, found_profile_mode, in_login, '',  't', queries_used, message into result;

END IF;

IF found_profile_mode = 'whitelist' THEN
   message := 'not found in any scanned table';

   select in_domain, found_profile, found_profile_mode, in_login, '',  'f', queries_used, message into result;
END IF;

return result;


END$$;


ALTER FUNCTION public.req_allowed_default(in_login character varying, in_src character varying, in_uri character varying, in_dst character varying, in_domain character varying, in_dstisip boolean) OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

