# rektrs-workspace

Rektrs ke sab projects ke **plans, worksheets aur zarori documents** ka central
record. Source code apne apne repos mein hai (Sendqon, Postqon, rektrs-preskool,
operqon-templete, IQRS); ye repo sirf documents ke liye hai.

- `goals/` — har goal ka GOAL.md, briefs aur files/ ke documents
  (hidden_files = agent working state, yahan shamil nahi)
- `team/` — supervision system aur training log
- `scripts/` — deploy/SSH helper scripts
- `research_notes/` — research reports
- `phone-api-test/` — SMS gateway test kit

Pehla push: 2026-11-16. Gitleaks sweep saaf (2 false positives: ek DB naam,
ek file md5 — koi credential nahi).
