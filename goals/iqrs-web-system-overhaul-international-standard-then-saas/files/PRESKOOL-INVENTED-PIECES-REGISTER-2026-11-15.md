# Invented-Pieces Register — PKG-0 (2026-11-15)

**Purpose:** every piece of the current staging build that cannot be traced
to the purchased PreSkool package (deployment plan §2c flags, carried forward
by PKG-0) gets one disposition here, under the owner's no-invention rule
(2026-11-15): nothing invented is silently kept — it is either replaced by
the vendor original, re-registered as an owner-governed IQRS-native item, or
put to the owner as an explicit decision.

**Dispositions used:** KEEP-AS-IQRS-FUNCTION (owner-governed native spec) ·
REPLACE-BY-VENDOR (with the PKG step that replaces it) ·
OWNER-DECISION-NEEDED (listed verbatim in §2 — not decided by this lane).

---

## 1. Register

| ID | Invented piece (evidence: deployment plan §2c) | Disposition | Step / note |
|---|---|---|---|
| **INV-01a** | `notification-center` **function** — BL-014 bell/panel and the `admin/notification` surface, wired to real Communicate records | **KEEP-AS-IQRS-FUNCTION** | Real IQRS function over real data; only its page anatomy is invented (INV-01b). |
| **INV-01b** | `notification-center` **page anatomy** — traces to the reconstruction's one invented page; the vendor package has no such page | **OWNER-DECISION-NEEDED** | Decision D1 in §2 — remove vs numbered EXEMPT, taken at **PKG-5** with the diffs in hand (deployment plan §6). |
| **INV-02** | Minted token families **`--alpha-*` / `--pf-*`** — 490 locally minted variables in the live `preskool-tokens.css` (818 vars live vs the vendor's 291) | **REPLACE-BY-VENDOR** | **PKG-2** — each token is deleted or mapped in a published mapping table to the vendor value it stands for (plan §3, PKG-2). |
| **INV-03** | **`--recon-*` semantic aliases** (and recon aliases `--muted`, `--m`, `--s`, `--t`) — invented by the reconstruction; do not exist in the vendor CSS | **REPLACE-BY-VENDOR** | **PKG-2** — same mapping-table discipline as INV-02. |
| **INV-04** | **Shell bridge / safeguard pattern** — `preskool-shell.css` safeguard/fix blocks (S1–S9, FIX-2) and the locally authored CSS layer files as a pattern, written to bend AdminLTE markup into the theme | **REPLACE-BY-VENDOR** | **PKG-3** — bridge rules are re-derived from the vendor shell anatomy or deleted at the shell swap; not carried forward (plan §2c item 3). |
| **INV-05a** | BL-012 MENU **population by permission/config** — which menu entries a role sees | **KEEP-AS-IQRS-FUNCTION** | IQRS function (permission system), not design; rides on whichever grouping INV-05b decides. |
| **INV-05b** | BL-012 MENU **grouping design** — 7 Doc04 job groups, Super-Admin show-all toggle, "Not set up" chips; the vendor sidebar ships as 13 sections / 343 targets | **OWNER-DECISION-NEEDED** | Decision D2 in §2 — keep as EXEMPT vs adopt the vendor grouping; taken at **PKG-5** (deployment plan §6). |
| **INV-06** | **Tabbed workspace anatomy** — pkfees / pkstudents / pkexams / … consolidated as tabs where the vendor is page-per-function | **REPLACE-BY-VENDOR** | **PKG-5 / PKG-6** per workspace — already owner-decided by **D-039** ("pages, not tabs"); tabbed shapes remain interim staging shapes only until their rebuild. |
| **INV-07** | **BL-013 global-search palette skin + launchpad / worklist surfaces** — IQRS-native function skinned locally; no vendor page counterpart | **KEEP-AS-IQRS-FUNCTION** | NATIVE-SPEC under **PF-6**: the function is IQRS's; only the skin's provenance is flagged, and the skin is re-derived from vendor anatomy rules at PF-6 (plan §2c item 6 — NATIVE-SPEC, not deletion). |

**Observation (not a register item):** staging also carries pre-PreSkool
design residue (e.g. `backend/dist/fonts/calmcampus/`, plan §2b). That is
leftover vendor-era material, not an invention; its confirm-or-remove check
rides with PKG-1 (plan §6 assigns the analogous `preskool-preview/` check to
PKG-1).

## 2. OWNER-DECISION-NEEDED — the list for the owner (verbatim)

> **D1 — notification-center page anatomy (decision due at PKG-5):**
> The notification centre's *function* is real IQRS (BL-014, wired to real
> Communicate records) and stays either way. Its *page anatomy* was invented
> by the reconstruction — the purchased PreSkool package has no such page.
> Decide: **(a)** remove the invented page anatomy and present notifications
> only through vendor-anatomy surfaces (header panel / Communicate pages), or
> **(b)** keep the page as a numbered EXEMPT / NATIVE-SPEC surface, skinned
> to vendor anatomy rules under PF-6 discipline.
>
> **D2 — BL-012 sidebar grouping design (decision due at PKG-5):**
> The staging sidebar regroups the menu into 7 Doc04 job groups with a
> Super-Admin show-all toggle and "Not set up" chips. The purchased package's
> sidebar ships as 13 sections. Menu *population by permission* is IQRS
> function and stays either way. Decide: **(a)** adopt the vendor's
> 13-section grouping as shipped, or **(b)** keep the IQRS 7-group grouping
> as a numbered EXEMPT arrangement on top of the vendor shell anatomy
> (PKG-3 builds the shell from vendor anatomy in both cases; this decision
> governs the grouping layer applied at PKG-5).

Both decisions are scheduled for **PKG-5** by the deployment plan (§6: taken
with the re-diffed surfaces in hand, owner-visible in the re-issued
scoreboard). Neither blocks PKG-1…PKG-4.
