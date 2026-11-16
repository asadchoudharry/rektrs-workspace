# PAID PLUGIN SPEC — RCS (Extra)

- **Vendor price:** $59. **No Extended discount.**
  **Version:** not shown on the catalogue card (UNVERIFIED).
- **Portal:** https://products.titansys.dev/zender/rcs/
- **Demo state:** not separately listed in the demo plugin walk;
  RCS appears as a channel type in the Connect Channel wizard
  (Lane 4 §B).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Send RCS messages through **Google Messages on a paired Android
phone**, alongside SMS — riding the free Android Gateway, not a
carrier RCS API.

## Features
RCS text, or **one image** with an optional caption (other file types
not supported); recipient must be a full international number; each
RCS message costs **1 allowance unit** (no SMS segment splitting).
**RCS Companion app** with a setup checklist: allow Accessibility +
Notification Access, remove battery limits, keep Google Messages as
the default SMS app, confirm the connection. Self-test (never sends a
message; also runs daily and after Google Messages updates). Optional
**SMS fallback** device setting (off by default): failed RCS is
refunded and SMS is charged. RCS works for verification codes. The
Network Directory shows partner lines, supported destinations and
per-text credits for RCS and SMS separately.

## Workflow
Admin uploads the branded app bundle (gateway + RCS Companion) under
Android settings → turn on RCS for the phone → install the RCS
Companion from the same bundle → work through the checklist → run
Test until the device card shows **Ready** → when sending, choose RCS
and a ready phone (Sent/Delivered/Read states show what the phone
could confirm).

## Logic / technology
Requires the **free Android Gateway plugin active**, with SMS +
Android Devices + RCS enabled on the workspace plan. The phone must
be **unlocked with screen lock OFF**. Delivery is not guaranteed:
unknown outcomes are marked failed, refunded and **never resent**.
With RCS on, the phone receives **text only** (pictures/files sent to
the phone cannot be received; an incoming image without text does not
appear). Choosing a phone does not switch its RCS SIM. Core tracks
per-device `rcs_enabled`, `rcs_sms_fallback`, `rcs_failure_streak`,
`rcs_report` and exposes `GET rcs/selectors` (Lane 5 §7); plugin
config `rcs_pacing_seconds` (default 6).

## Data it touches
`devices` (RCS fields), messages, `network_*` (directory rates).

## Dependencies
Android Gateway (free plugin now; our own app later —
`04-NO-SOURCE/android-gateway-apk.md` §RCS module); a phone running
Google Messages as default SMS app.

## OUR REBUILD SPEC
- **Plugin type:** an extension of the Android channel (in the
  vendor's taxonomy an "Extra"; in Lane 5's 9 types it attaches to
  the `android` channel surface — there is no android-extension type,
  so our build implements it inside our own Android channel work +
  a small feature plugin for plan gating/reporting).
- **Key interfaces:** `rcs/selectors` capability data, device RCS
  state machine (checklist → Test → Ready), send path with
  refund-on-unknown + optional SMS fallback, pacing
  (`rcs_pacing_seconds`).
- **Honesty note for our build:** the mechanism leans on Google
  Messages' on-device behaviour (Accessibility/Notification access) —
  fragile by nature; ship it as an optional module, never as a core
  promise.
- **Priority:** Phase 5 (master plan lists RCS among late items).
- **Difficulty:** Medium-Hard (fragility, not complexity).
