# SUPERVISION SYSTEM — Inspectors, Supervisor, Training Lane

Standing system ordered by Assad, 2026-11-09 ~22:39 PKT: *"Jab update do us
say phly lanes check kia kro… her project per ek inspector bithao jo check
kerta rahy, issues resolve kerwata rahy, lane ko merny na day, progress
continue rakhwaye… un per ek supervisor bithao jo inspectors ki
optimization karin, lanes/agents ko training dain, skills increase karin,
kam ko fast kerwain… ek Training lane bhi open kro — jab agents kam ker k
wapis ain to unki mistakes or unusual things per training dain, unhin
professional banain or team main pakka karin."*

Born from a real failure the same evening: the W3-7 deploy lane died at
18:00 PKT on a browser `connection_lost` and sat dead ~4.5 hours while
15-minute updates reported "still running". This system exists so that
never happens silently again.

## Permanent roster (the team is pakka — roles are standing, not per-task)

| Role | Holder | Scope |
|---|---|---|
| **CEO / Supervisor** | Muse (main agent) | Owns both Inspectors, the Training Lane, all closure/redispatch decisions, threshold tuning, skill promotion. |
| **Inspector — IQRS** | Runs inside the `iqrs-15min-updates` job every 15 min + live CEO checks whenever the CEO is active | All school-programme lanes: IQRS web overhaul, IQRS mobile apps (browser tasks, subagents, builds). |
| **Inspector — Operqon** | Runs inside the `operqon-15min-updates` job every 15 min + live CEO checks | All Operqon ERP lanes (builds, image cycles, deploys, bench proofs). |
| **Training Lane** | Supervisor-run, fed by both Inspectors | Debriefs every returning lane; keeps `~/workspace/team/TRAINING-LOG.md`; promotes durable lessons. |
| **Standing lane roles** | Reused across tasks | Deploy lane, Build lane, Checker lane, Research lane — same names, same playbooks, improving via the Training Lane instead of starting cold each time. |

Rektrs School ERP + LMS joins this system the day its first lane runs
(Inspector duty folds into whichever update job serves it then).

## Inspector duties (each project, every 15 minutes, BEFORE the update)

1. **Lane census.** List every running/recent lane, subagent and browser
   task belonging to the project. Record for each: status, running time,
   **last-activity age**.
2. **Health classes.**
   - **HEALTHY** — activity within 30 min, or waiting on a named human
     input (e.g. an OTP the owner must supply). Waiting-on-owner is NOT
     a stall and is never counted against the lane.
   - **SUSPECT** — 30–60 min with no activity. Named in the update with
     its last known step; watched next cycle.
   - **STALLED** — >60 min with no activity. Investigate in the same
     pass: (a) independent probe of the target system (IQRS: curl
     staging + production; Operqon: VPS/service pong) to separate
     *system down* from *lane dead*; (b) read the lane transcript's
     last step — the death point and whether any irreversible action
     was in flight; (c) send ONE wake/status nudge (browser-task
     update or subagent message).
   - **DEAD** — no transcript writes for >2 h, or the last step ended
     in an unrecovered error (e.g. `connection_lost`), or the agent
     status is failed/interrupted. The update states the cause, the
     evidence, and the exact resume action; the CEO closes the lane
     and dispatches a **resume lane** (never a blind restart — the
     resume lane first re-proves state: per-file size/state preflight,
     so finished steps are not redone and half-finished steps are
     completed safely).
3. **Hurdle chasing.** A lane blocked on anything resolvable without
   the owner (expired session, stale lock, wrong tree, missing file
   grant) gets the fix routed in the same pass — re-mint the session,
   re-grant the file, answer the lane's question — instead of waiting
   for the next update cycle.
4. **No silent cycles.** If a lane is SUSPECT/STALLED/DEAD, the
   15-minute update MUST carry a line about it (state + cause +
   action). An update that says "still running" about a lane that has
   not moved is an Inspector failure.
5. **Scope discipline.** Inspectors observe, diagnose, nudge, unblock
   and escalate. Closures, redispatches and production actions stay
   with the CEO under the standing mandates; an Inspector never starts
   a deploy on its own.
6. **NEVER-STOP RULE (owner directive, 2026-11-09 ~23:00 PKT):**
   "Koi bhi cheez agar ruk jaye to kaam rok na dia kro — balky check
   kia kro k q hoa, kesy hoa, or solution kya hy." A stuck thing is
   never reported as a stop. Every blockage gets the full treatment
   in the same pass: **why** it stopped (root cause, evidence-based,
   not a guess), **how** it stopped (the mechanism/sequence), and
   **what the solution is** — then the solution is applied or an
   alternate route is taken under the standing mandates, and only a
   genuinely owner-only step (his login, his OTP, his physical
   action) may wait, named as such. Proven pattern, same night:
   File Manager app down for hours → diagnosed as a Hostinger-side
   app outage → alternate route (SSH) → W3-7 deploy completed.

## Supervisor duties (CEO, continuous)

1. **Optimise the Inspectors.** Review stall patterns weekly (and on
   any DEAD verdict): are thresholds right, was detection late, was
   the resume clean? Tune this charter; record changes in the Training
   Log.
2. **Train the lanes.** Feed every Training-Lane lesson back into the
   playbooks the lanes actually read (deploy addenda, AGENTS.md
   lessons, custom skills) so the same mistake is not repeated by the
   next lane.
3. **Speed.** Watch lane cycle times; where a lane class is slow for a
   structural reason (serial browser lanes on one account, oversized
   single lane, missing parallelism), split it, parallelise it, or
   pre-stage its inputs — Assad's multitasking directive applies.
4. **Promote skills.** Recurring fixes become custom skills; one-off
   lessons become AGENTS.md entries. A lesson that lives only in a
   chat transcript is a lesson lost.

## Training Lane (runs on every lane return)

For every lane that completes, fails, or is found DEAD, append a
debrief to `~/workspace/team/TRAINING-LOG.md` with:
- Lane + project + outcome (done / failed / died + where).
- **Mistakes** (the lane's own errors) and **unusual things** (system
  behaviour nobody predicted — stalls, session expiries, grant
  glitches, cache traps).
- **Lesson** in one line, and **where it was promoted** (charter /
  AGENTS.md / skill / addendum template) — filled in by the Supervisor
  when the promotion happens.

The first debrief is already written: the W3-7 lane death of
2026-11-09 (see Training Log #1).

## Cadence

- Inspectors: every 15 minutes, inside each project's existing
  15-minute update job, before the update text is composed.
- Training Lane: on every lane return (event-driven), swept by each
  Inspector pass for anything missed.
- Supervisor review: continuous by the CEO; charter/threshold review
  at least weekly and after every DEAD verdict.
