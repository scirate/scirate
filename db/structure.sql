--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    content text,
    user_id integer,
    paper_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: cross_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cross_lists (
    id integer NOT NULL,
    paper_id integer,
    feed_id integer,
    cross_list_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cross_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cross_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cross_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cross_lists_id_seq OWNED BY cross_lists.id;


--
-- Name: feed_days; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feed_days (
    id integer NOT NULL,
    pubdate date,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    feed_name character varying(255)
);


--
-- Name: feed_days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feed_days_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feed_days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feed_days_id_seq OWNED BY feed_days.id;


--
-- Name: feeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feeds (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    feed_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updated_date date,
    subscriptions_count integer DEFAULT 0,
    last_paper_date date
);


--
-- Name: feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feeds_id_seq OWNED BY feeds.id;


--
-- Name: papers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE papers (
    id integer NOT NULL,
    title character varying(255),
    authors text,
    abstract text,
    identifier character varying(255),
    url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pubdate date,
    updated_date date,
    scites_count integer DEFAULT 0,
    comments_count integer DEFAULT 0,
    feed_id integer,
    pdf_url character varying(255)
);


--
-- Name: papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE papers_id_seq OWNED BY papers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scites (
    id integer NOT NULL,
    sciter_id integer,
    paper_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: scites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scites_id_seq OWNED BY scites.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subscriptions (
    id integer NOT NULL,
    user_id integer,
    feed_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscriptions_id_seq OWNED BY subscriptions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    remember_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    password_digest character varying(255),
    scites_count integer DEFAULT 0,
    password_reset_token character varying(255),
    password_reset_sent_at timestamp without time zone,
    confirmation_token character varying(255),
    active boolean DEFAULT false,
    comments_count integer DEFAULT 0,
    confirmation_sent_at timestamp without time zone,
    subscriptions_count integer DEFAULT 0,
    expand_abstracts boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cross_lists ALTER COLUMN id SET DEFAULT nextval('cross_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_days ALTER COLUMN id SET DEFAULT nextval('feed_days_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feeds ALTER COLUMN id SET DEFAULT nextval('feeds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY papers ALTER COLUMN id SET DEFAULT nextval('papers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scites ALTER COLUMN id SET DEFAULT nextval('scites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: cross_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cross_lists
    ADD CONSTRAINT cross_lists_pkey PRIMARY KEY (id);


--
-- Name: feed_days_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feed_days
    ADD CONSTRAINT feed_days_pkey PRIMARY KEY (id);


--
-- Name: feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_pkey PRIMARY KEY (id);


--
-- Name: papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY papers
    ADD CONSTRAINT papers_pkey PRIMARY KEY (id);


--
-- Name: scites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scites
    ADD CONSTRAINT scites_pkey PRIMARY KEY (id);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_comments_on_paper_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_paper_id ON comments USING btree (paper_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_cross_lists_on_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cross_lists_on_feed_id ON cross_lists USING btree (feed_id);


--
-- Name: index_cross_lists_on_feed_id_and_cross_list_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cross_lists_on_feed_id_and_cross_list_date ON cross_lists USING btree (feed_id, cross_list_date);


--
-- Name: index_cross_lists_on_paper_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cross_lists_on_paper_id ON cross_lists USING btree (paper_id);


--
-- Name: index_cross_lists_on_paper_id_and_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cross_lists_on_paper_id_and_feed_id ON cross_lists USING btree (paper_id, feed_id);


--
-- Name: index_feed_days_on_pubdate_and_feed_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_feed_days_on_pubdate_and_feed_name ON feed_days USING btree (pubdate, feed_name);


--
-- Name: index_feeds_on_last_paper_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_feeds_on_last_paper_date ON feeds USING btree (last_paper_date);


--
-- Name: index_feeds_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_feeds_on_name ON feeds USING btree (name);


--
-- Name: index_papers_on_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_papers_on_date ON papers USING btree (pubdate);


--
-- Name: index_papers_on_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_papers_on_feed_id ON papers USING btree (feed_id);


--
-- Name: index_papers_on_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_papers_on_identifier ON papers USING btree (identifier);


--
-- Name: index_scites_on_paper_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scites_on_paper_id ON scites USING btree (paper_id);


--
-- Name: index_scites_on_sciter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scites_on_sciter_id ON scites USING btree (sciter_id);


--
-- Name: index_scites_on_sciter_id_and_paper_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_scites_on_sciter_id_and_paper_id ON scites USING btree (sciter_id, paper_id);


--
-- Name: index_subscriptions_on_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subscriptions_on_feed_id ON subscriptions USING btree (feed_id);


--
-- Name: index_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subscriptions_on_user_id ON subscriptions USING btree (user_id);


--
-- Name: index_subscriptions_on_user_id_and_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_subscriptions_on_user_id_and_feed_id ON subscriptions USING btree (user_id, feed_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_password_reset_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_password_reset_token ON users USING btree (password_reset_token);


--
-- Name: index_users_on_remember_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_remember_token ON users USING btree (remember_token);


--
-- Name: papers_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX papers_to_tsvector_idx ON papers USING gin (to_tsvector('english'::regconfig, (title)::text));


--
-- Name: papers_to_tsvector_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX papers_to_tsvector_idx1 ON papers USING gin (to_tsvector('english'::regconfig, authors));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120313073916');

INSERT INTO schema_migrations (version) VALUES ('20120313075037');

INSERT INTO schema_migrations (version) VALUES ('20120315034427');

INSERT INTO schema_migrations (version) VALUES ('20120315103302');

INSERT INTO schema_migrations (version) VALUES ('20120315111149');

INSERT INTO schema_migrations (version) VALUES ('20120316095114');

INSERT INTO schema_migrations (version) VALUES ('20120319050947');

INSERT INTO schema_migrations (version) VALUES ('20120319090743');

INSERT INTO schema_migrations (version) VALUES ('20120320094847');

INSERT INTO schema_migrations (version) VALUES ('20120321044831');

INSERT INTO schema_migrations (version) VALUES ('20120321075713');

INSERT INTO schema_migrations (version) VALUES ('20120322045954');

INSERT INTO schema_migrations (version) VALUES ('20120323070352');

INSERT INTO schema_migrations (version) VALUES ('20120326031046');

INSERT INTO schema_migrations (version) VALUES ('20120402080859');

INSERT INTO schema_migrations (version) VALUES ('20120402081330');

INSERT INTO schema_migrations (version) VALUES ('20120402084818');

INSERT INTO schema_migrations (version) VALUES ('20120402090539');

INSERT INTO schema_migrations (version) VALUES ('20120402095150');

INSERT INTO schema_migrations (version) VALUES ('20120402120617');

INSERT INTO schema_migrations (version) VALUES ('20120418043502');

INSERT INTO schema_migrations (version) VALUES ('20120418052054');

INSERT INTO schema_migrations (version) VALUES ('20120419072503');

INSERT INTO schema_migrations (version) VALUES ('20120423025627');

INSERT INTO schema_migrations (version) VALUES ('20120426045036');

INSERT INTO schema_migrations (version) VALUES ('20120514045445');

INSERT INTO schema_migrations (version) VALUES ('20120611054447');

INSERT INTO schema_migrations (version) VALUES ('20120815023731');

INSERT INTO schema_migrations (version) VALUES ('20121009060303');

INSERT INTO schema_migrations (version) VALUES ('20130204055603');