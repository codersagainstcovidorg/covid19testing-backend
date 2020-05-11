CREATE TABLE IF NOT EXISTS slugs(
    record_id         SERIAL                    UNIQUE,
    slug              text                      NOT NULL PRIMARY KEY,
    entity_kind       char(24)                  NOT NULL DEFAULT 'location',
    entity_id         text                      NOT NULL,
    created_on        timestamp with time zone  NOT NULL DEFAULT now(),
    updated_on        timestamp with time zone  NOT NULL DEFAULT now(),
    deleted_on        timestamp with time zone
);