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
-- Name: cfg_profile_category; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW cfg_profile_category AS
    SELECT profiles.profile, profiles.mode, categories.category FROM cfg_profile_category_link profile_category_link, profiles, cfg_categories categories WHERE ((profile_category_link.idprofiles = profiles.id) AND (profile_category_link.idcategories = categories.id));


ALTER TABLE public.cfg_profile_category OWNER TO postgres;

--
-- Name: cfg_profile_category; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE cfg_profile_category FROM PUBLIC;
REVOKE ALL ON TABLE cfg_profile_category FROM postgres;
GRANT ALL ON TABLE cfg_profile_category TO postgres;
GRANT SELECT ON TABLE cfg_profile_category TO inkupdater;


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
-- Name: clean_temp_accounts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW clean_temp_accounts AS
    SELECT temp_accounts.netbiosdomainname, temp_accounts.accountname, temp_accounts.email, temp_accounts.enabled, temp_accounts.profile, temp_accounts.priority FROM (temp_accounts JOIN (SELECT temp_accounts.netbiosdomainname, temp_accounts.accountname, max(temp_accounts.priority) AS prio FROM temp_accounts GROUP BY temp_accounts.netbiosdomainname, temp_accounts.accountname) maxprio ON (((((temp_accounts.netbiosdomainname)::text = (maxprio.netbiosdomainname)::text) AND ((temp_accounts.accountname)::text = (maxprio.accountname)::text)) AND (temp_accounts.priority = maxprio.prio))));


ALTER TABLE public.clean_temp_accounts OWNER TO postgres;

--
-- PostgreSQL database dump complete
--

