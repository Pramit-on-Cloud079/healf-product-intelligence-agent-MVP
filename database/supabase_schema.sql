create extension if not exists "pgcrypto";

create table public.product_agent_runs (

  -- Primary identifiers
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),

  -- User Input
  question text not null,
  url text not null,
  handle text,
  domain text,

  -- Product Metadata
  product_title text,
  product_description text,
  canonical_url text,
  og_image text,

  -- Extracted Page Data
  extracted_json jsonb,
  metadata_json jsonb,

  -- AI Evaluation Output
  success boolean default true,
  answer text,
  confidence text,
  question_type text,
  can_answer_directly boolean,

  -- Structured Reasoning Outputs
  evidence_json jsonb,
  missing_data_json jsonb,
  improvement_suggestions_json jsonb,

  -- Full Raw AI Response
  ai_response_json jsonb,

  -- Operational Metadata
  model text default 'gpt-5.5',
  workflow_version text default 'v1',
  status text default 'completed',
  session_id text

);

-- -----------------------------
-- Standard indexes
-- -----------------------------

create index idx_product_agent_runs_created_at
on public.product_agent_runs(created_at desc);

create index idx_product_agent_runs_question_type
on public.product_agent_runs(question_type);

create index idx_product_agent_runs_confidence
on public.product_agent_runs(confidence);

create index idx_product_agent_runs_success
on public.product_agent_runs(success);

create index idx_product_agent_runs_status
on public.product_agent_runs(status);

create index idx_product_agent_runs_url
on public.product_agent_runs(url);

create index idx_product_agent_runs_handle
on public.product_agent_runs(handle);

create index idx_product_agent_runs_session_id
on public.product_agent_runs(session_id);

-- -----------------------------
-- JSONB indexes
-- -----------------------------

create index idx_product_agent_runs_extracted_json
on public.product_agent_runs
using gin (extracted_json);

create index idx_product_agent_runs_metadata_json
on public.product_agent_runs
using gin (metadata_json);

create index idx_product_agent_runs_ai_response_json
on public.product_agent_runs
using gin (ai_response_json);

create index idx_product_agent_runs_evidence_json
on public.product_agent_runs
using gin (evidence_json);

create index idx_product_agent_runs_missing_data_json
on public.product_agent_runs
using gin (missing_data_json);

create index idx_product_agent_runs_improvement_suggestions_json
on public.product_agent_runs
using gin (improvement_suggestions_json);