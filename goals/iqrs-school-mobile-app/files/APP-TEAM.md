# IQRS Apps — Standing Team (owner order, 2026-11-07)

Owner's directive: a complete multi-agent team for the apps that (1) researches design and new features, (2) produces improvement suggestions, and (3) hands proven proposals to development agents who build them. Research → proposal → owner/CEO decision → build → independent check → device proof. No lane approves its own work.

## Roster

| Lane | Owns | Produces |
|---|---|---|
| **Design Research** | International case studies (school, fintech, gov-service apps), visual/UX patterns, motion, accessibility | DESIGN-RESEARCH-<wave>.md — every suggestion tied to a named source pattern, the screen/rule it changes, and an S/M/L cost |
| **Feature Research** | Competitor school-ERP apps (Smart School ecosystem, international school apps), platform capabilities (Android), gaps vs our module matrix | FEATURE-RESEARCH-<wave>.md — proposals ranked by value/effort, mapped to plan API numbers (§3 contracts) where they exist |
| **UX Analyst (improvements)** | Evidence from OUR apps: owner device feedback, checker findings, plan rules not yet honoured, friction in live flows | IMPROVEMENTS-<wave>.md — concrete fixes ranked by user pain; feeds the wave scope before build starts |
| **Builders** (per wave) | App + API implementation in the shared tree | Build report + signed APK; never check their own work |
| **Checker** | §6 protocol gates, reconciliation, PASS/REJECT | CHECKER-REPORT-<wave>.md |
| **Release coordinator** (CEO) | Wave sequencing, owner proposals, server swaps per manifest, memory | Owner-facing reports |

## Operating rules

- Research lanes are read-only: web + local tree. No server contact, no code changes.
- A suggestion becomes work only when it lands in a wave scope the CEO assembles and, where the plan requires it, the owner approves.
- Every wave still passes: builder → checker → owner device proof. Research never shortens that chain.
- Suggestions must be buildable on the real stack (native Android tree, Staffapi/Staffsync extension, Smart School data) — no fantasy features; anything needing school-side setup is flagged as such (Wave C pattern).
- Dead ends are reported as dead ends with the reason; volume of suggestions is not a metric.

## Cycle

1. Research lanes deliver into the NEXT wave's planning (currently: Wave 2 — exams/marks depth, lesson plan/syllabus, library, income/expenses, fee setup, reports, behaviour, ID/certificate files, content, transport/inventory ops, HR depth, online-exam authoring, Connect C-2…C-7).
2. CEO merges research + plan scope + checker debts into one wave proposal for the owner.
3. Builders execute; checker verifies; owner proves on device.
