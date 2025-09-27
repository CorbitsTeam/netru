-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admin_notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body text NOT NULL,
  type text NOT NULL DEFAULT 'general'::text CHECK (type = ANY (ARRAY['news'::text, 'report_update'::text, 'report_comment'::text, 'system'::text, 'general'::text])),
  status text NOT NULL DEFAULT 'draft'::text CHECK (status = ANY (ARRAY['draft'::text, 'scheduled'::text, 'sent'::text, 'failed'::text])),
  target_users jsonb DEFAULT '[]'::jsonb,
  target_groups jsonb DEFAULT '[]'::jsonb,
  data jsonb DEFAULT '{}'::jsonb,
  created_by uuid NOT NULL,
  sent_count integer DEFAULT 0,
  delivered_count integer DEFAULT 0,
  failed_count integer DEFAULT 0,
  scheduled_at timestamp without time zone,
  sent_at timestamp without time zone,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT admin_notifications_pkey PRIMARY KEY (id),
  CONSTRAINT admin_notifications_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);
CREATE TABLE public.cities (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  governorate_id bigint,
  name text NOT NULL,
  CONSTRAINT cities_pkey PRIMARY KEY (id),
  CONSTRAINT cities_governorate_id_fkey FOREIGN KEY (governorate_id) REFERENCES public.governorates(id)
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
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT identity_documents_pkey PRIMARY KEY (id),
  CONSTRAINT identity_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.news_articles (
  id character varying NOT NULL,
  title character varying NOT NULL,
  title_ar character varying,
  content_text text,
  content_text_ar text,
  summary text,
  summary_en text,
  image_url character varying,
  external_id character varying,
  external_url character varying,
  source_url character varying,
  source_name character varying,
  category_id integer,
  status character varying DEFAULT 'draft'::character varying,
  is_published boolean DEFAULT false,
  is_featured boolean DEFAULT false,
  view_count integer DEFAULT 0,
  published_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT news_articles_pkey PRIMARY KEY (id),
  CONSTRAINT news_articles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.news_categories(id)
);
CREATE TABLE public.news_categories (
  id integer NOT NULL,
  name character varying NOT NULL,
  name_ar character varying,
  description text,
  icon character varying,
  color character varying,
  is_active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT news_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  title_ar text,
  body text NOT NULL,
  body_ar text,
  notification_type text NOT NULL CHECK (notification_type = ANY (ARRAY['news'::text, 'report_update'::text, 'report_comment'::text, 'system'::text, 'general'::text])),
  reference_id uuid,
  reference_type text CHECK (reference_type = ANY (ARRAY['news_article'::text, 'report'::text, 'system'::text])),
  data jsonb,
  is_read boolean DEFAULT false,
  is_sent boolean DEFAULT false,
  priority text DEFAULT 'normal'::text CHECK (priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text, 'urgent'::text])),
  fcm_message_id text,
  created_at timestamp without time zone DEFAULT now(),
  read_at timestamp without time zone,
  sent_at timestamp without time zone,
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.report_assignments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  report_id uuid NOT NULL,
  assigned_to uuid NOT NULL,
  assigned_by uuid NOT NULL,
  assigned_at timestamp without time zone DEFAULT now(),
  unassigned_at timestamp without time zone,
  assignment_notes text,
  is_active boolean DEFAULT true,
  CONSTRAINT report_assignments_pkey PRIMARY KEY (id),
  CONSTRAINT report_assignments_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id),
  CONSTRAINT report_assignments_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id),
  CONSTRAINT report_assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id)
);
CREATE TABLE public.report_comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  report_id uuid NOT NULL,
  user_id uuid NOT NULL,
  comment_text text NOT NULL,
  is_internal boolean DEFAULT false,
  parent_comment_id uuid,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  is_deleted boolean DEFAULT false,
  CONSTRAINT report_comments_pkey PRIMARY KEY (id),
  CONSTRAINT report_comments_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id),
  CONSTRAINT report_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT report_comments_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.report_comments(id)
);
CREATE TABLE public.report_media (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  report_id uuid NOT NULL,
  media_type text NOT NULL CHECK (media_type = ANY (ARRAY['image'::text, 'video'::text, 'audio'::text, 'document'::text])),
  file_url text NOT NULL,
  file_name text,
  file_size bigint,
  mime_type text,
  description text,
  uploaded_at timestamp without time zone DEFAULT now(),
  is_evidence boolean DEFAULT false,
  metadata jsonb,
  CONSTRAINT report_media_pkey PRIMARY KEY (id),
  CONSTRAINT report_media_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id)
);
CREATE TABLE public.report_status_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  report_id uuid NOT NULL,
  previous_status text,
  new_status text NOT NULL,
  changed_by uuid,
  change_reason text,
  changed_at timestamp without time zone DEFAULT now(),
  notes text,
  CONSTRAINT report_status_history_pkey PRIMARY KEY (id),
  CONSTRAINT report_status_history_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id),
  CONSTRAINT report_status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id)
);
CREATE TABLE public.report_types (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL UNIQUE,
  name_ar text NOT NULL UNIQUE,
  description text,
  priority_level text DEFAULT 'medium'::text CHECK (priority_level = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text])),
  is_active boolean DEFAULT true,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT report_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  reporter_first_name text NOT NULL,
  reporter_last_name text NOT NULL,
  reporter_national_id text NOT NULL,
  reporter_phone text NOT NULL,
  report_type_id bigint,
  report_type_custom text,
  report_details text NOT NULL,
  incident_location_latitude numeric,
  incident_location_longitude numeric,
  incident_location_address text,
  incident_datetime timestamp without time zone,
  report_status text DEFAULT 'pending'::text CHECK (report_status = ANY (ARRAY['pending'::text, 'under_investigation'::text, 'resolved'::text, 'closed'::text, 'rejected'::text, 'received'::text])),
  priority_level text DEFAULT 'medium'::text CHECK (priority_level = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text])),
  assigned_to uuid,
  case_number text DEFAULT nextval('reports_case_number_seq'::regclass) UNIQUE,
  submitted_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  resolved_at timestamp without time zone,
  admin_notes text,
  public_notes text,
  is_anonymous boolean DEFAULT false,
  verification_status text DEFAULT 'unverified'::text CHECK (verification_status = ANY (ARRAY['unverified'::text, 'verified'::text, 'flagged'::text])),
  CONSTRAINT reports_pkey PRIMARY KEY (id),
  CONSTRAINT reports_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT reports_report_type_id_fkey FOREIGN KEY (report_type_id) REFERENCES public.report_types(id),
  CONSTRAINT reports_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id)
);
CREATE TABLE public.user_fcm_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  fcm_token text NOT NULL,
  device_type text CHECK (device_type = ANY (ARRAY['android'::text, 'ios'::text, 'web'::text])),
  device_id text,
  app_version text,
  is_active boolean DEFAULT true,
  last_used timestamp without time zone DEFAULT now(),
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT user_fcm_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT user_fcm_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
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
  updated_at timestamp with time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  last_login_at timestamp without time zone,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);