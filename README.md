# Password Security — PostgreSQL Functions

PostgreSQL functions supporting a password management tool, built during
my cybersecurity studies:

- public.get_credentials.sql — retrieve stored credentials
- public.update_password.sql — update a password
- old_password_check.sql — check a new password against previous ones
  (password reuse prevention)

Stack: PostgreSQL, PL/pgSQL
