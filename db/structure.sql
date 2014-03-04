--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
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

--
-- Name: crc32(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION crc32(word text) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE tmp bigint;
DECLARE i int;
DECLARE j int;
DECLARE byte_length int;
DECLARE word_array bytea;
BEGIN
IF COALESCE(word, '') = '' THEN
return 0;
END IF;

i = 0;
tmp = 4294967295;
byte_length = bit_length(word) / 8;
word_array = decode(replace(word, E'\\', E'\\\\'), 'escape');
LOOP
tmp = (tmp # get_byte(word_array, i))::bigint;
i = i + 1;
j = 0;
LOOP
tmp = ((tmp >> 1) # (3988292384 * (tmp & 1)))::bigint;
j = j + 1;
IF j >= 8 THEN
EXIT;
END IF;
END LOOP;
IF i >= byte_length THEN
EXIT;
END IF;
END LOOP;
return (tmp # 4294967295);
END
$$;


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authors_id_seq
    START WITH 3189994
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authors (
    id integer DEFAULT nextval('authors_id_seq'::regclass) NOT NULL,
    "position" integer NOT NULL,
    fullname text NOT NULL,
    searchterm text NOT NULL,
    paper_uid text
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1416050
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer DEFAULT nextval('categories_id_seq'::regclass) NOT NULL,
    "position" integer NOT NULL,
    feed_uid text NOT NULL,
    paper_uid text,
    crosslist_date timestamp without time zone DEFAULT '2014-01-16 20:06:20'::timestamp without time zone NOT NULL
);


--
-- Name: comment_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comment_reports (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comment_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comment_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comment_reports_id_seq OWNED BY comment_reports.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    cached_votes_up integer DEFAULT 0 NOT NULL,
    cached_votes_down integer DEFAULT 0 NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    parent_id integer,
    ancestor_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    content text NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    paper_uid text DEFAULT ''::text NOT NULL
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
-- Name: feed_preferences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feed_preferences (
    id integer NOT NULL,
    user_id integer,
    feed_id integer,
    last_visited timestamp without time zone,
    previous_last_visited timestamp without time zone,
    selected_range integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: feed_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feed_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feed_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feed_preferences_id_seq OWNED BY feed_preferences.id;


--
-- Name: feeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feeds (
    id integer NOT NULL,
    uid text NOT NULL,
    source text NOT NULL,
    fullname text NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    subscriptions_count integer DEFAULT 0 NOT NULL,
    last_paper_date timestamp without time zone,
    parent_uid text
);


--
-- Name: papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE papers_id_seq
    START WITH 912413
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE papers (
    id integer DEFAULT nextval('papers_id_seq'::regclass) NOT NULL,
    uid text NOT NULL,
    submitter text,
    title text NOT NULL,
    abstract text NOT NULL,
    author_comments text,
    msc_class text,
    report_no text,
    journal_ref text,
    doi text,
    proxy text,
    license text,
    submit_date timestamp without time zone NOT NULL,
    update_date timestamp without time zone NOT NULL,
    abs_url text NOT NULL,
    pdf_url text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scites_count integer DEFAULT 0 NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    pubdate timestamp without time zone,
    author_str text NOT NULL
);


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
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    paper_uid text DEFAULT ''::text NOT NULL
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    feed_uid text DEFAULT ''::text NOT NULL
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
    fullname text,
    email text,
    remember_token text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    password_digest text,
    scites_count integer DEFAULT 0,
    password_reset_token text,
    password_reset_sent_at timestamp without time zone,
    confirmation_token text,
    active boolean DEFAULT false,
    comments_count integer DEFAULT 0,
    confirmation_sent_at timestamp without time zone,
    subscriptions_count integer DEFAULT 0,
    expand_abstracts boolean DEFAULT false,
    account_status text DEFAULT 'user'::text,
    username text
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
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1361734
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer DEFAULT nextval('versions_id_seq'::regclass) NOT NULL,
    "position" integer NOT NULL,
    date timestamp without time zone NOT NULL,
    size text,
    paper_uid text NOT NULL
);


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    votable_id integer,
    votable_type text,
    voter_id integer,
    voter_type text,
    vote_flag boolean,
    vote_scope text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    vote_weight integer
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_reports ALTER COLUMN id SET DEFAULT nextval('comment_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_preferences ALTER COLUMN id SET DEFAULT nextval('feed_preferences_id_seq'::regclass);


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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


--
-- Name: authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: comment_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comment_reports
    ADD CONSTRAINT comment_reports_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: feed_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feed_preferences
    ADD CONSTRAINT feed_preferences_pkey PRIMARY KEY (id);


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
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: index_authors_on_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authors_on_paper_uid ON authors USING btree (paper_uid);


--
-- Name: index_authors_on_position_and_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authors_on_position_and_paper_uid ON authors USING btree ("position", paper_uid);


--
-- Name: index_authors_on_searchterm; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authors_on_searchterm ON authors USING btree (searchterm);


--
-- Name: index_categories_on_crosslist_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_crosslist_date ON categories USING btree (crosslist_date);


--
-- Name: index_categories_on_feed_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_feed_uid ON categories USING btree (feed_uid);


--
-- Name: index_categories_on_feed_uid_and_crosslist_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_feed_uid_and_crosslist_date ON categories USING btree (feed_uid, crosslist_date);


--
-- Name: index_categories_on_feed_uid_and_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_categories_on_feed_uid_and_paper_uid ON categories USING btree (feed_uid, paper_uid);


--
-- Name: index_categories_on_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_paper_uid ON categories USING btree (paper_uid);


--
-- Name: index_categories_on_paper_uid_and_feed_uid_and_crosslist_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_paper_uid_and_feed_uid_and_crosslist_date ON categories USING btree (paper_uid, feed_uid, crosslist_date);


--
-- Name: index_categories_on_position_and_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_categories_on_position_and_paper_uid ON categories USING btree ("position", paper_uid);


--
-- Name: index_comment_reports_on_user_id_and_comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_comment_reports_on_user_id_and_comment_id ON comment_reports USING btree (user_id, comment_id);


--
-- Name: index_comments_on_ancestor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_ancestor_id ON comments USING btree (ancestor_id);


--
-- Name: index_comments_on_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_paper_uid ON comments USING btree (paper_uid);


--
-- Name: index_comments_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_parent_id ON comments USING btree (parent_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_feeds_on_source; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_feeds_on_source ON feeds USING btree (source);


--
-- Name: index_feeds_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_feeds_on_uid ON feeds USING btree (uid);


--
-- Name: index_papers_on_abs_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_papers_on_abs_url ON papers USING btree (abs_url);


--
-- Name: index_papers_on_comments_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_papers_on_comments_count ON papers USING btree (comments_count);


--
-- Name: index_papers_on_pdf_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_papers_on_pdf_url ON papers USING btree (pdf_url);


--
-- Name: index_papers_on_pubdate; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_papers_on_pubdate ON papers USING btree (pubdate);


--
-- Name: index_papers_on_scites_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_papers_on_scites_count ON papers USING btree (scites_count);


--
-- Name: index_papers_on_scites_count_and_comments_count_and_submit_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_papers_on_scites_count_and_comments_count_and_submit_date ON papers USING btree (scites_count, comments_count, submit_date);


--
-- Name: index_papers_on_submit_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_papers_on_submit_date ON papers USING btree (submit_date);


--
-- Name: index_papers_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_papers_on_uid ON papers USING btree (uid);


--
-- Name: index_scites_on_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scites_on_paper_uid ON scites USING btree (paper_uid);


--
-- Name: index_scites_on_paper_uid_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_scites_on_paper_uid_and_user_id ON scites USING btree (paper_uid, user_id);


--
-- Name: index_scites_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scites_on_user_id ON scites USING btree (user_id);


--
-- Name: index_subscriptions_on_feed_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subscriptions_on_feed_uid ON subscriptions USING btree (feed_uid);


--
-- Name: index_subscriptions_on_feed_uid_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_subscriptions_on_feed_uid_and_user_id ON subscriptions USING btree (feed_uid, user_id);


--
-- Name: index_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subscriptions_on_user_id ON subscriptions USING btree (user_id);


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
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_versions_on_position_and_paper_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_versions_on_position_and_paper_uid ON versions USING btree ("position", paper_uid);


--
-- Name: index_votes_on_votable_id_and_votable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_votes_on_votable_id_and_votable_type ON votes USING btree (votable_id, votable_type);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_votes_on_votable_id_and_votable_type_and_vote_scope ON votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_voter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_votes_on_votable_id_and_votable_type_and_voter_id ON votes USING btree (votable_id, votable_type, voter_id);


--
-- Name: index_votes_on_voter_id_and_voter_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_votes_on_voter_id_and_voter_type ON votes USING btree (voter_id, voter_type);


--
-- Name: index_votes_on_voter_id_and_voter_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_votes_on_voter_id_and_voter_type_and_vote_scope ON votes USING btree (voter_id, voter_type, vote_scope);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

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

INSERT INTO schema_migrations (version) VALUES ('20130318093049');

INSERT INTO schema_migrations (version) VALUES ('20130323085908');

INSERT INTO schema_migrations (version) VALUES ('20130402054215');

INSERT INTO schema_migrations (version) VALUES ('20130403232204');

INSERT INTO schema_migrations (version) VALUES ('20130408093659');

INSERT INTO schema_migrations (version) VALUES ('20130408140749');

INSERT INTO schema_migrations (version) VALUES ('20130616212916');

INSERT INTO schema_migrations (version) VALUES ('20130617035148');

INSERT INTO schema_migrations (version) VALUES ('20130617035237');

INSERT INTO schema_migrations (version) VALUES ('20130619010543');

INSERT INTO schema_migrations (version) VALUES ('20130619010724');

INSERT INTO schema_migrations (version) VALUES ('20130621041807');

INSERT INTO schema_migrations (version) VALUES ('20130621053609');

INSERT INTO schema_migrations (version) VALUES ('20130621053848');

INSERT INTO schema_migrations (version) VALUES ('20130624052903');

INSERT INTO schema_migrations (version) VALUES ('20130624065020');

INSERT INTO schema_migrations (version) VALUES ('20130624075151');

INSERT INTO schema_migrations (version) VALUES ('20130627181018');

INSERT INTO schema_migrations (version) VALUES ('20130709021255');

INSERT INTO schema_migrations (version) VALUES ('20130712055848');

INSERT INTO schema_migrations (version) VALUES ('20130715063331');

INSERT INTO schema_migrations (version) VALUES ('20130717132402');

INSERT INTO schema_migrations (version) VALUES ('20130719133047');

INSERT INTO schema_migrations (version) VALUES ('20130723204128');

INSERT INTO schema_migrations (version) VALUES ('20130723214946');

INSERT INTO schema_migrations (version) VALUES ('20130724001439');

INSERT INTO schema_migrations (version) VALUES ('20130916061905');

INSERT INTO schema_migrations (version) VALUES ('20130920083302');

INSERT INTO schema_migrations (version) VALUES ('20130920083426');

INSERT INTO schema_migrations (version) VALUES ('20131213045624');

INSERT INTO schema_migrations (version) VALUES ('20131213121346');

INSERT INTO schema_migrations (version) VALUES ('20131217134749');

INSERT INTO schema_migrations (version) VALUES ('20131217150844');

INSERT INTO schema_migrations (version) VALUES ('20131230114024');

INSERT INTO schema_migrations (version) VALUES ('20140106001148');

INSERT INTO schema_migrations (version) VALUES ('20140109042617');

INSERT INTO schema_migrations (version) VALUES ('20140113151158');

INSERT INTO schema_migrations (version) VALUES ('20140113154723');

INSERT INTO schema_migrations (version) VALUES ('20140114005857');

INSERT INTO schema_migrations (version) VALUES ('20140114015506');

INSERT INTO schema_migrations (version) VALUES ('20140116081240');

INSERT INTO schema_migrations (version) VALUES ('20140116081843');

INSERT INTO schema_migrations (version) VALUES ('20140116132257');

INSERT INTO schema_migrations (version) VALUES ('20140116140646');

INSERT INTO schema_migrations (version) VALUES ('20140116142259');

INSERT INTO schema_migrations (version) VALUES ('20140116153036');

INSERT INTO schema_migrations (version) VALUES ('20140116155505');

INSERT INTO schema_migrations (version) VALUES ('20140116160315');

INSERT INTO schema_migrations (version) VALUES ('20140116165322');

INSERT INTO schema_migrations (version) VALUES ('20140116165634');

INSERT INTO schema_migrations (version) VALUES ('20140116171422');

INSERT INTO schema_migrations (version) VALUES ('20140116171545');

INSERT INTO schema_migrations (version) VALUES ('20140116171632');

INSERT INTO schema_migrations (version) VALUES ('20140116172913');

INSERT INTO schema_migrations (version) VALUES ('20140116173528');

INSERT INTO schema_migrations (version) VALUES ('20140116182452');

INSERT INTO schema_migrations (version) VALUES ('20140116185716');

INSERT INTO schema_migrations (version) VALUES ('20140116192805');

INSERT INTO schema_migrations (version) VALUES ('20140116200452');

INSERT INTO schema_migrations (version) VALUES ('20140116200937');

INSERT INTO schema_migrations (version) VALUES ('20140116201200');

INSERT INTO schema_migrations (version) VALUES ('20140116201616');

INSERT INTO schema_migrations (version) VALUES ('20140119230607');

INSERT INTO schema_migrations (version) VALUES ('20140122194016');

INSERT INTO schema_migrations (version) VALUES ('20140127045258');

INSERT INTO schema_migrations (version) VALUES ('20140128110038');

INSERT INTO schema_migrations (version) VALUES ('20140128122435');

INSERT INTO schema_migrations (version) VALUES ('20140129081020');

INSERT INTO schema_migrations (version) VALUES ('20140129100427');

INSERT INTO schema_migrations (version) VALUES ('20140129100722');

INSERT INTO schema_migrations (version) VALUES ('20140129100934');

INSERT INTO schema_migrations (version) VALUES ('20140129102318');

INSERT INTO schema_migrations (version) VALUES ('20140129102345');

INSERT INTO schema_migrations (version) VALUES ('20140129102431');

INSERT INTO schema_migrations (version) VALUES ('20140129103856');

INSERT INTO schema_migrations (version) VALUES ('20140219052417');

INSERT INTO schema_migrations (version) VALUES ('20140228084747');

INSERT INTO schema_migrations (version) VALUES ('20140302104318');

INSERT INTO schema_migrations (version) VALUES ('20140304112236');

INSERT INTO schema_migrations (version) VALUES ('20140304135944');

INSERT INTO schema_migrations (version) VALUES ('20140304174436');

INSERT INTO schema_migrations (version) VALUES ('20140304183641');
