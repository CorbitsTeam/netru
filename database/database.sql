-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.cities (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  governorate_id bigint,
  name text NOT NULL,
  CONSTRAINT cities_pkey PRIMARY KEY (id),
  CONSTRAINT cities_governorate_id_fkey FOREIGN KEY (governorate_id) REFERENCES public.governorates(id)
);
CREATE TABLE public.districts (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  city_id bigint,
  name text NOT NULL,
  CONSTRAINT districts_pkey PRIMARY KEY (id),
  CONSTRAINT districts_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id)
);
CREATE TABLE public.governorates (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL UNIQUE,
  name text NOT NULL UNIQUE,
  CONSTRAINT governorates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.identity_documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  doc_type text NOT NULL CHECK (doc_type = ANY (ARRAY['nationalId'::text, 'passport'::text])),
  front_image_url text,
  back_image_url text,
  uploaded_at timestamp without time zone DEFAULT now(),
  CONSTRAINT identity_documents_pkey PRIMARY KEY (id),
  CONSTRAINT identity_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.user_logs (
  id bigint NOT NULL DEFAULT nextval('user_logs_id_seq'::regclass),
  user_id uuid,
  action text NOT NULL,
  ip_address text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT user_logs_pkey PRIMARY KEY (id),
  CONSTRAINT user_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  password text NOT NULL,
  full_name text NOT NULL,
  national_id text UNIQUE,
  passport_number text UNIQUE,
  user_type text NOT NULL CHECK (user_type = ANY (ARRAY['citizen'::text, 'foreigner'::text, 'admin'::text])),
  role text,
  phone text,
  governorate text,
  city text,
  district text,
  address text,
  created_at timestamp without time zone DEFAULT now(),
  modified_at timestamp without time zone DEFAULT now(),
  nationality text,
  profile_image text,
  verification_status text DEFAULT 'unverified'::text CHECK (verification_status = ANY (ARRAY['unverified'::text, 'pending'::text, 'verified'::text, 'rejected'::text])),
  verified_at timestamp without time zone,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);