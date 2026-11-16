# PAID PLUGIN SPEC — Google Sheets (integration)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/google-sheets/
- **Demo state:** Active/Configured; tenant Integrations shows Google
  Sheets "Not Connected" (Lane 4 §§B, C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Let flows read/write Google spreadsheets and trigger on new rows.

## Features
**Add Row node** (map text values incl. flow tokens to columns;
values written as plain text, never evaluated as formulas). **Find
Row node** (first row matching one column; Found / Not Found / Error
are separate outputs). **New Row trigger** (pick a unique ID column;
sheet checked about every 5 minutes; each flow starts once per new
ID; existing rows are baselined when the trigger is published).
Files chosen via Google Picker (the grant covers only chosen files;
pick spreadsheet + tab in the flow editor; refresh columns after
header changes). Safe writes: an append with an uncertain outcome is
**not blindly retried** (no duplicate rows); the result exposes the
updated range. Bring-your-own Google app: OAuth client, project
number, restricted browser API key; secrets encrypted and shown
masked after saving.

## Workflow
Google Cloud: enable Sheets/Drive/Picker APIs, create a Web OAuth
client with the exact redirect URL Zender shows → upload plugin →
Configure (Client ID, Client Secret, Project Number, Browser API
Key) → activate → enable Chat Flows + Google Sheets on the plan →
Integrations: sign in with Google, choose a spreadsheet → add
Add Row / Find Row / New Row steps in the flow editor.

## Logic / technology
Core already carries the schema and the poller: tables
`google_sheet_connections`, `google_sheet_files`,
`google_sheet_operations`, `google_sheet_row_occurrences`,
`google_sheet_subscriptions`, and scheduled
`flows:google-sheets-poll` every minute (Lane 5 §§4, 12). Limits:
100 columns, 10,000 data rows. Operational note from the vendor:
Google "Testing" consent grants expire after 7 days — set the consent
screen to "In production".

## Data it touches
`google_sheet_*` tables; flow tables (nodes/runs).

## Dependencies
Chat Flows; a Google Cloud project (operator's own); scheduler +
queue workers for New Row flows.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + flow nodes via
  `NodeExecutor`.
- **Key interfaces:** OAuth connect + Picker grant handling, Add Row /
  Find Row executors, New Row trigger poller writing
  `google_sheet_row_occurrences` (dedupe by unique ID), uncertain-
  append safety (verify-before-retry).
- **Priority:** Phase 4, integrations group — first integration after
  the channel group (master plan lists Sheets early among
  integrations).
- **Difficulty:** Easy–Medium (core schema + poller exist).
