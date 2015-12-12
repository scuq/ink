\c ink
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

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

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: useragents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY useragents
    ADD CONSTRAINT useragents_pkey PRIMARY KEY (useragentrx, subnet);


--
-- Name: useragents; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE useragents FROM PUBLIC;
REVOKE ALL ON TABLE useragents FROM postgres;
GRANT ALL ON TABLE useragents TO postgres;
GRANT SELECT ON TABLE useragents TO inkquerier;


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
-- Name: aduser_2_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT aduser_2_profile_pkey PRIMARY KEY (netbiosdomainname, accountname);


--
-- Name: accounts_col_accountname; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX accounts_col_accountname ON accounts USING btree (accountname text_pattern_ops);


--
-- Name: accounts_col_netbiosdomainname; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX accounts_col_netbiosdomainname ON accounts USING btree (netbiosdomainname text_pattern_ops);


--
-- Name: accounts; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE accounts FROM PUBLIC;
REVOKE ALL ON TABLE accounts FROM postgres;
GRANT ALL ON TABLE accounts TO postgres;
GRANT SELECT ON TABLE accounts TO inkquerier;


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

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE profiles FROM PUBLIC;
REVOKE ALL ON TABLE profiles FROM postgres;
GRANT ALL ON TABLE profiles TO postgres;
GRANT SELECT ON TABLE profiles TO inkupdater;
GRANT SELECT ON TABLE profiles TO inkquerier;


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

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


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

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_activedirectory ALTER COLUMN id SET DEFAULT nextval('cfg_activedirectory_id_seq'::regclass);


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

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_activedirectory_group_profile ALTER COLUMN id SET DEFAULT nextval('cfg_activedirectory_group_profile_id_seq'::regclass);


--
-- Name: cfg_activedirectory_group_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_activedirectory_group_profile
    ADD CONSTRAINT cfg_activedirectory_group_profile_pkey PRIMARY KEY (id);


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

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cfg_profile_category_link ALTER COLUMN id SET DEFAULT nextval('profile_category_link_id_seq'::regclass);


--
-- Name: profile_category_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cfg_profile_category_link
    ADD CONSTRAINT profile_category_link_pkey PRIMARY KEY (id);


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
-- PostgreSQL database dump complete
--

