revoke insert, update, delete, truncate, references, trigger on all tables in schema public from anon;
revoke usage, select, update on all sequences in schema public from anon;

alter default privileges for role postgres in schema public
  revoke insert, update, delete, truncate, references, trigger on tables from anon;
alter default privileges for role postgres in schema public
  revoke usage, select, update on sequences from anon;
