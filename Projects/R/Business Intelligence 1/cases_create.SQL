--
-- PostgreSQL database dump
--

-- Dumped from database version 11
-- Dumped by pg_dump version 11

--
-- Name: cases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cases (
    cid double precision,
    gender character varying(255),
    age double precision,
    dhb2015_code double precision,
    dhb2015_name character varying(255),
    date date,
    status character varying(255)
);


--
-- PostgreSQL database dump complete
--

