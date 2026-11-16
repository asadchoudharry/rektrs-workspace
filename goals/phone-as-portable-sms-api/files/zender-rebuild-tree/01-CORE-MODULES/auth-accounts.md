# CORE — Auth & Accounts

**Status: core-owned (purchased). We keep it; our plugins never replace it.**
Sources: Lane 2 (Authentication settings, Admin guide), Lane 4 §D, Lane 5 §4/§6.

## Purpose
Platform identity: registration, sign-in, verification, 2FA, social
login, sessions, account lifecycle (suspend/delete), and the separate
staff (admin) account system.

## Screens / pages
- Public: register, login, forgot/reset password, email verification.
- Admin > Users: 53 users in demo; tabs Users / Pending (8) / Deletion
  Requests; user states Active / Suspended / Pending; New User.
- Admin > Settings > Authentication (see `settings-admin.md`).
- Tenant: profile/account settings, signed-in devices review (mobile).

## Features + rules / limits
- Registration on/off (admin). Verification modes: None / Email Link /
  Code. Optional manual approval of new accounts. DOB field: Off /
  Optional / Required.
- Sign-ups can auto-create a Contact (tag "Signup") in the admin
  workspace.
- Disposable email domains blocked by default. Password length 4–128
  (admin-set; demo 8). Session timeout configurable (demo 120 min).
- reCAPTCHA on login/register/forgot/reset/WhatsApp sign-in —
  **warning: a misconfigured reCAPTCHA locks everyone out.**
- Social login: Google / Facebook / GitHub OAuth (Socialite).
- 2FA: TOTP (pragmarx/google2fa) + recovery codes.
- Suspend: revokes the user's API keys. Admins cannot be impersonated.
  Owner deletion is irreversible.
- Account deletion: password + 2FA confirm, grace period 0–90 days
  (demo 14), completed by scheduler (`privacy:account-deletions`
  hourly). Self-service "Download My Data" with 24h gap between
  requests (see `privacy-gdpr-security.md`).

## Data (tables)
`users`, `password_reset_tokens`, `sessions`, `user_consents`,
`login_handoff_tokens`, `account_deletion_requests`,
`account_data_exports`, `personal_access_tokens` (Sanctum).

## API surface
`routes/auth.php` (~37 routes: login/register/2FA/social);
`auth.login`, `auth.login.two-factor`, `me` in the API. Mobile sign-in
tokens: `mobile_sign_in_tokens`, `mobile_devices`.

## Plan gates
None for auth itself. New accounts land on the first free plan after a
cancelled subscription expires (see `plans-billing-credits.md`).

## Keep / extension notes
- Core-owned. Our extensions attach only as *consumers*: e.g. sign-in
  codes delivered through channels (WHMCS/Perfex/Odoo plugins use the
  core OTP service — `otp-verification.md`), and "Sign in with WhatsApp"
  which lives in `otp-verification.md`.
- APP_KEY caution: auth-adjacent secrets (OAuth client secrets) live
  encrypted in `system_settings` — see `05-INFRA.md` backup rules.
