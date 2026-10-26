-- SahayakHub planned database schema (PostgreSQL / Supabase). NOT deployed yet.
-- Design notes:
--  * Idempotent: safe to re-run. Nothing is dropped.
--  * Webhook retries are harmless: system_logs.message_id is unique.
--  * UNIQUE constraints already create indexes, so no duplicate indexes are added.
--  * Foreign keys have the index their ON DELETE CASCADE needs.

CREATE TABLE IF NOT EXISTS public.network_people (
    id               BIGSERIAL PRIMARY KEY,
    real_name        VARCHAR(100) NOT NULL,
    phone_number     VARCHAR(20)  NOT NULL UNIQUE CHECK (phone_number ~ '^[0-9]{8,15}$'),
    default_language VARCHAR(50)  DEFAULT 'Odia',
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.network_roles (
    id          BIGSERIAL PRIMARY KEY,
    role_title  VARCHAR(100) NOT NULL UNIQUE,
    domain_type VARCHAR(20)  NOT NULL CHECK (domain_type IN ('Domestic','Business'))
);

CREATE TABLE IF NOT EXISTS public.entity_connections (
    id                   BIGSERIAL PRIMARY KEY,
    subject_user_id      BIGINT NOT NULL REFERENCES public.network_people(id) ON DELETE CASCADE,
    associated_entity_id BIGINT NOT NULL REFERENCES public.network_people(id) ON DELETE CASCADE,
    active_role_id       BIGINT REFERENCES public.network_roles(id) ON DELETE SET NULL,
    classification_domain VARCHAR(20) NOT NULL CHECK (classification_domain IN ('Business','Domestic')),
    language_profile     VARCHAR(20) CHECK (language_profile IN
        ('Odia','Odia_Romanised','Hindi','Hindi_Romanised','Bengali','English')),
    channel_state        VARCHAR(10) NOT NULL DEFAULT 'cold' CHECK (channel_state IN ('hot','cold')),
    slot_active_until    TIMESTAMPTZ,          -- free-tier 24h unique-contact window
    CONSTRAINT unique_user_associate_pair UNIQUE (subject_user_id, associated_entity_id),
    CONSTRAINT no_self_connection CHECK (subject_user_id <> associated_entity_id)
);
-- The unique constraint indexes (subject, associated). The reverse lookup and the cascade need this:
CREATE INDEX IF NOT EXISTS idx_connections_associated ON public.entity_connections (associated_entity_id);

CREATE TABLE IF NOT EXISTS public.system_logs (
    id                  BIGSERIAL PRIMARY KEY,
    message_id          TEXT        NOT NULL UNIQUE,   -- WhatsApp message id: makes retries idempotent
    sender_number       VARCHAR(20) NOT NULL,
    raw_input_string    TEXT        NOT NULL,
    status              VARCHAR(50) NOT NULL DEFAULT 'completed'
                        CHECK (status IN ('completed','frozen_pending_verification')),
    unresolved_name     VARCHAR(100),
    parsed_json_payload JSONB,
    trial_counter       INT         NOT NULL DEFAULT 1 CHECK (trial_counter >= 1),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Only frozen rows are ever looked up by status, so index only those (small and fast):
CREATE INDEX IF NOT EXISTS idx_logs_frozen
    ON public.system_logs (sender_number, created_at DESC)
    WHERE status = 'frozen_pending_verification';
CREATE INDEX IF NOT EXISTS idx_logs_sender_time ON public.system_logs (sender_number, created_at DESC);

CREATE TABLE IF NOT EXISTS public.scheduled_nudges (
    id             BIGSERIAL PRIMARY KEY,
    sender_id      BIGINT NOT NULL REFERENCES public.network_people(id) ON DELETE CASCADE,
    recipient_id   BIGINT NOT NULL REFERENCES public.network_people(id) ON DELETE CASCADE,
    log_id         BIGINT REFERENCES public.system_logs(id) ON DELETE SET NULL,
    fire_at        TIMESTAMPTZ NOT NULL,
    body           TEXT NOT NULL,
    state          VARCHAR(10) NOT NULL DEFAULT 'pending' CHECK (state IN ('pending','sent','skipped','failed'))
);
CREATE INDEX IF NOT EXISTS idx_nudges_due ON public.scheduled_nudges (fire_at) WHERE state = 'pending';

INSERT INTO public.network_roles (role_title, domain_type) VALUES
  ('System Root Anchor','Domestic'),
  ('Business Principal','Business')
ON CONFLICT (role_title) DO NOTHING;

-- Claiming a frozen task so two webhooks for one sender cannot both resume it:
--   SELECT ... FROM public.system_logs
--   WHERE sender_number = $1 AND status = 'frozen_pending_verification'
--   ORDER BY created_at DESC LIMIT 1
--   FOR UPDATE SKIP LOCKED;
