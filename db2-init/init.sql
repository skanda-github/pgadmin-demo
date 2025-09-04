CREATE SCHEMA IF NOT EXISTS tenant_schema;

CREATE TABLE IF NOT EXISTS tenant_schema.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- Roles
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'tenant2_reader') THEN
CREATE ROLE tenant2_reader LOGIN PASSWORD 'reader_password';
END IF;
END$$;

GRANT CONNECT ON DATABASE tenant2db TO tenant2_reader;
GRANT USAGE ON SCHEMA tenant_schema TO tenant2_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA tenant_schema TO tenant2_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA tenant_schema
GRANT SELECT ON TABLES TO tenant2_reader;

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'tenant2_writer') THEN
CREATE ROLE tenant2_writer LOGIN PASSWORD 'writer_password';
END IF;
END$$;

GRANT CONNECT ON DATABASE tenant2db TO tenant2_writer;
GRANT USAGE ON SCHEMA tenant_schema TO tenant2_writer;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA tenant_schema TO tenant2_writer;
ALTER DEFAULT PRIVILEGES IN SCHEMA tenant_schema
GRANT INSERT, UPDATE, DELETE ON TABLES TO tenant2_writer;

-- Default Data
INSERT INTO tenant_schema.users (username, email, role)
VALUES
    ('david', 'david@tenant2.com', 'admin'),
    ('eva', 'eva@tenant2.com', 'reader'),
    ('frank', 'frank@tenant2.com', 'writer')
ON CONFLICT DO NOTHING;