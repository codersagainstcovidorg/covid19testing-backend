CREATE TABLE IF NOT EXISTS audit_data_ingest(
    id                SERIAL PRIMARY KEY,
    operation         char(12)   NOT NULL,
    status            char(24)   NOT NULL,
    data_source       text       NOT NULL,
    recorded_on       timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);