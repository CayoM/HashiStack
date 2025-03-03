CREATE TABLE api_keys (
    id SERIAL PRIMARY KEY,
    token TEXT UNIQUE NOT NULL
);

INSERT INTO api_keys (token) VALUES ('my-secret-token');