alter default privileges for role postgres in schema public revoke all privileges on tables from anon;
alter default privileges for role postgres in schema public revoke all privileges on sequences from anon;
alter default privileges for role postgres in schema public revoke all privileges on functions from anon;
