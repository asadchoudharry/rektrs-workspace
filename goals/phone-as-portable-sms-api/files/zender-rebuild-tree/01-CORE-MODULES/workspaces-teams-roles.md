# CORE — Workspaces, Teams & Roles

**Status: core-owned (purchased).**
Sources: Lane 2 (Permissions), Lane 4 §B, Lane 5 §4/§6.

## Purpose
The tenancy unit. A workspace owns channels, contacts, conversations,
credits and its subscription. Members join with roles; Messenger teams
organise agents for inbox assignment.

## Screens / pages (tenant, Lane 4)
- Workspace > Members: 13 members in demo (12 seats used); Owner + Agents.
- Workspace > Teams: 12 teams (Support, Sales, Billing, Onboarding,
  Retention, VIP, Escalations, Product, Compliance, QA, Logistics,
  Marketing), each with a named lead.
- Workspace > Roles: built-ins listed with permission counts.
- Workspace > Activity Log (35 entries in demo, Export CSV).
- Workspace Settings sections: Inbox, Notifications, Lead Capture, AI
  Agents, Away Messages, SLA, CSAT, General, Data Retention, Business
  Hours, Reviews, Branding, Shipping Address.
- Invitations by email; workspace switching for multi-workspace users.

## Features + rules / limits
- **Built-in workspace roles (permission counts):** Admin 73 (everything
  except billing/ownership), Manager 54, Supervisor 6 (escalations/
  labels), Agent 20, Read Only 19. Messenger-only access exists as a
  separate grant (chat only, no other modules).
- **Custom Roles are a plan feature.** A role can never unlock a paid
  feature the plan doesn't include — plan gates beat role permissions.
- **Admin Roles are a different system** (platform staff): Super Admin
  62, Billing 24, Operations 18, Support 6, Content 4 permissions in the
  demo; managed in Admin > Admin Roles.
- Teams drive Messenger assignment (round-robin cursor per team,
  least-busy, manual) — see `messenger-inbox.md`.
- Seat limits come from the plan (`Team Members` limit; blank =
  unlimited, 0 = none).

## Data (tables)
`workspace_roles`, `workspace_invitations`, `messenger_teams`,
`messenger_team_members`, `messenger_team_round_robin_cursors`,
`admin_roles`, `agents`, `agent_round_robin_cursors`, `companies`.

## API surface
Admin API (our rebuild) manages workspaces/members — see
`../02-PAID-PLUGINS/admin-api.md`. Tenant API exposes workspace context
via `me`/`usage`; API keys are scoped to their creator's permissions.

## Plan gates
Custom Roles (plan feature); Team Members limit; Messenger switch for
inbox access per member.

## Keep / extension notes
- Core-owned. Our plugins read roles/permissions through core contracts
  only (e.g. Browser Extension checks member rights server-side per
  action — `../02-PAID-PLUGINS/browser-extension.md`).
- Workspace Branding settings (logo/colour/name/address) live here and
  feed white-label surfaces — see `settings-admin.md` and Lane 4 §E.
