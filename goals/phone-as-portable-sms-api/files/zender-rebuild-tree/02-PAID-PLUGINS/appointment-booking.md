# PAID PLUGIN SPEC — Appointment Booking

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.1 (8 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/appointment-booking/
- **Demo state:** Active/Configured; tenant side shows Bookings with
  Appointments / Services / Team tabs, booking page Off (Lane 4 §B).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Customers book appointments inside a chat flow; bookings sync to
Google Calendar / Outlook.

## Features
A **Booking flow node** (services, staff, days, times, contact's
timezone); customers book / reschedule / cancel by text; changes write
back to Google Calendar or Outlook; a complete booking dashboard;
email notifications; timezone handling.

## Workflow
Upload plugin → activate → enable Appointment Booking **and Chat
Flows** on the plan → connect Google or Microsoft in Integrations →
create services, add staff, set working hours → add a Booking node to
a flow → publish.

## Logic / technology
Notable: the booking schema is **already in core** — tables
`appointments`, `appointment_calendar_events`,
`appointment_trigger_fires`, `booking_pages`, `booking_services`,
`booking_members`, `booking_service_member`, `booking_time_off`,
`calendar_connections`, `calendar_busy_blocks`,
`calendar_event_deletes`, plus core scheduler entries `bookings:tick`
and `bookings:calendar-poll` (every minute) and core controllers under
`Bookings/` (Lane 5 §§4, 6, 12). The plugin appears to activate/gate
logic core largely ships. Calendar OAuth uses the operator's Google/
Microsoft accounts.

## Data it touches
The booking/calendar tables above; `conversations` (booking chats);
flow tables for the node.

## Dependencies
Chat Flows (core), plan switch `appointment_booking`, Google/Microsoft
account with calendar permissions.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + a flow node via
  the core `NodeExecutor` contract.
- **Key interfaces:** Booking node executor (availability read →
  slot offer → confirm → write), calendar sync service against the
  core `calendar_*` tables, booking public pages via
  `ProvidesPublicPages` (plan key `appointment_booking`), admin/tenant
  screens reusing core booking controllers where they exist.
- **Build order note:** first verify how much of the flow already runs
  with core alone (demo showed the tenant Bookings UI present) — the
  plugin may be mostly gating + the node. UNVERIFIED until tested on
  our install (Phase 0/1 check).
- **Priority:** Phase 4, integrations group.
- **Difficulty:** Easy–Medium (depends on the core-coverage check).
