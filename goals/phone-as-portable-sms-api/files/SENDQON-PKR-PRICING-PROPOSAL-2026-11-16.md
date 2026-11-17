# SENDQON — PKR PRICING PROPOSAL v2 (2026-11-16, market check ke baad REVISED)

Status: **APPROVED + APPLIED (2026-11-17).** Owner ne 2026-11-17 ko
manzoori di; neeche "Applied" section mein live tabdeeli ka record
hai. Pehli tajweez (flat
Rs 4,999/12,999/49,999) market check ke baad revise ki gayi hai —
BYOD market us se sasta hai. Research: 2026-11-16, FX ≈ Rs 277/USD;
mukammal report `research_notes/sendqon-market-pricing-pakistan-*`.

## Market saboot (khulasa)

- **BYOD (apni device) panels:** SendFlow (Pakistan) Rs 699 / 1,499 /
  3,999 per month; textbee $14.99–29.99; SendPK own-number
  Rs 3,000–13,000/30 din. Band: **Rs 700–4,000** aam tenant,
  **Rs 4,000–13,000** multi-number.
- **Official WhatsApp API platforms (PKR):** Autogine 1,500–5,500;
  BAMNEXA 4,999–9,999; WAB2C 5,500–55,000; NotiFly 8,900–21,900
  (+15,000 setup) — upar se Meta per-message alag.
- **Per-SMS (Pakistan):** branded/masked retail Rs 3.15–3.90
  (SendPK 3.80–3.90 + mask setup 5,000 + 5,000/saal; Veevo 3.15;
  BSMS 2.70–3.20); Pak Sender flat 4.30.
- **Meta Pakistan per-message:** marketing $0.0473 (≈ Rs 13.1),
  utility/auth $0.0150 (≈ Rs 4.15); BSP resale PKR 15 / 5.
- **Device-supplied model:** Pakistan mein koi vendor device-rent
  publish nahi karta; bahir SIM hosting €41–75/mo, rented Android
  $40–99/mo per device. All-in Model B band ≈ **Rs 9,000–35,000/mo**
  (modest volume) muqabla Model A all-in Rs 750–4,150.

## MODEL A — Device USER ki (software only)

Tenant apna Android phone/SIM ya apna provider lagata hai; hum sirf
panel dete hain. Uski SIM bundle cost usi ki (Rs 50–150/mo).

| Plan | PKR / month | PKR / year (2 mah muft) |
|------|------------|--------------------------|
| Free | Rs 0 | — |
| Starter | **Rs 2,499** | Rs 24,990 |
| Pro | **Rs 5,999** | Rs 59,990 |
| Enterprise | **Rs 14,999** | Rs 149,990 |

## MODEL B — Device HAMARI (managed device + SIM)

Hum device + SIM dete aur manage karte hain (setup, bundle, ban/
replacement ki zimmedari hamari). Qeemat = Model A plan + managed
device fee **Rs 4,999 / device / month**:

| Plan | PKR / month | Devices shamil |
|------|------------|----------------|
| Starter Managed | **Rs 7,499** | 1 |
| Pro Managed | **Rs 15,999** | 2 |
| Enterprise Managed | **Rs 34,999** | 5 |

- Plan quota se zyada SMS (aggregator/masked route): **Rs 4.25/SMS**
  pass-through style.
- WhatsApp official API route dono models mein: Meta ki asal
  per-message cost pass-through (marketing ≈ Rs 13.1, utility/auth
  ≈ Rs 4.15) — market ke BSP bhi yehi karte hain (PKR 15/5 resale).

## Limits (seed plans ke mutabiq, dono models par)

- **Free:** 500 contacts, 1 channel, team = owner only, 100 SMS/mo.
- **Starter:** 5,000 contacts, tamam channels, 2,000 SMS/mo, 100 credits.
- **Pro:** 20,000 contacts, team 5, 10,000 SMS/mo, 500 credits.
- **Enterprise:** unlimited contacts/team/SMS, 2,000 credits.

## Notes

- (Applied 2026-11-17: currency PKR ho gayi, Model A prices lag
  gaye, Model B plans alag entries ke tor par ban gaye — tafseel
  neeche "Applied" section mein.)
- Charge asal mein tab hoga jab payment gateway active ho (Bank
  Transfer owner ke bank details par ruka hai; JazzCash/EasyPaisa/
  Raast Phase 4 — USP-1).
- Trial (3 din, 50 messages) pehle se ON hai.

## Applied (2026-11-17) — live record

Pre-change backup: `status=OK push=OK`. Tamam tabdeeliyan app ke
apne raston se huin (`SystemSetting::set` + Plan model) — settings
par koi raw SQL nahi. Subscribers 0 thay, koi gateway active nahi,
is liye kisi customer par asar nahi.

**Currency:** `default_currency` USD → **PKR** (setting key wohi jo
Settings > General use karti hai).

**Patch register — PR-003 (zaruri chhoti core tabdeeli):** vendor ki
currency list (`App\Support\Currencies::KNOWN`) mein **PKR shamil hi
nahi tha** — baghair is ke `Currencies::code()` har PKR setting ko
khamoshi se USD par wapas gira deta (aur admin Settings UI PKR ko
reject karti). Is liye:

| # | File | Change | Reason |
|---|------|--------|--------|
| PR-003 | `app/Support/Currencies.php` + `resources/js/lib/currency.ts` | `KNOWN` mein `'PKR'`, `SYMBOLS` mein `'PKR' => 'Rs'`, TS `CURRENCIES` mein PKR entry (label `Rs - PKR`) | PKR ko site currency banana mumkin karna; upstream Zender 5.0.4 mein PKR missing hai. Patch host build tree (`~/sendqon-build/src/`) + live container dono mein hai — agli image build mein bhi rahega. Live frontend abhi Intl fallback se "PKR" render karti hai; TS entry agli build se `Rs` glyph degi. |

**Plans — before/after:**

| Plan | Pehle | Ab | Note |
|------|-------|-----|------|
| Free | $0 | **Rs 0** | price wohi, sirf currency |
| Starter | $19 | **Rs 2,499** /mo | Model A |
| Pro | $49 | **Rs 5,999** /mo | Model A |
| Enterprise | $199 | **Rs 14,999** /mo | Model A |
| Starter Managed | — (naya) | **Rs 7,499** /mo | Model B; Starter ki limits/features ki exact copy; desc: "Includes 1 managed device (device + SIM supplied by Sendqon)" |
| Pro Managed | — (naya) | **Rs 15,999** /mo | Model B; Pro ki exact copy; 2 managed devices |
| Enterprise Managed | — (naya) | **Rs 34,999** /mo | Model B; Enterprise ki exact copy; 5 managed devices |

- **Yearly field maujood nahi:** plan record mein ek hi `price` +
  `billing_period` hota hai (koi yearly price field nahi), is liye
  sirf monthly prices lage hain. Saalana plans chahiye hon to woh
  alag `billing_period=yearly` rows hongi (Rs 24,990 / 59,990 /
  149,990 aur managed 74,990 / 159,990 / 349,990) — owner kahe to
  bana diye jayenge.
- Kisi plan ke **features/limits/credits mein zero tabdeeli** —
  managed plans ki features+limits apne base plans se byte-identical
  verify huin (script ne har shared column compare kiya, diffs =
  none). Trial settings ko haath nahi lagaya.

**Verification (live):**
- DB read-back: 7 plans, tamam Active, prices upar wale.
- `Currencies::code()` = `PKR`; `Currencies::format(2499)` =
  "Rs 2,499.00".
- Public **https://sendqon.rektrs.com/pricing → 200** — page data
  mein `PKR` aur tamam 6 paid prices (2499 / 5999 / 14999 / 7499 /
  15999 / 34999) + teeno Managed naam render hote hain.
- Site `/` aur `/login` → 200; 7/7 containers Up.
