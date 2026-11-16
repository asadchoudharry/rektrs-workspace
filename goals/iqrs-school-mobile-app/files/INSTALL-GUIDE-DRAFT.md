# IQRS Workspace — Install Guide

**For:** school office staff · **App:** IQRS Workspace Desktop (Windows)
**Status:** DRAFT text (D3-4 lane, 2026-11-15). The pictures are added later,
from the real install on Windows — every place one belongs is marked
`[SCREENSHOT: …]`. The finished guide is published as a PDF in the download
area, with printed copies for the rollout visit.

---

## 1. Before you start

You need four things:

- **The installer file.** Its name looks like
  `IQRS-Workspace-Desktop-<version>.msi`. You will be given it on a USB stick
  at the rollout visit, or you can download it from
  https://iqrs.edu.pk/downloads/workspace-desktop/
- **Your staff email address and password** — the same ones you use for the
  school system.
- **An internet connection** for the first sign-in and for update checks.
  After the first sign-in the app can work without internet, and it sends
  your work when the connection comes back.
- **A Windows 10 or Windows 11 computer**, signed in with your own Windows
  login. The app installs for your Windows login only, so install it on the
  login you use every day.

You do **not** need an administrator password to install or update this app.

## 2. Installing, step by step

1. Double-click the installer file.
2. Windows may show a blue screen saying **"Windows protected your PC"**.
   This is expected. This version of the app is not signed with a publisher
   certificate yet, so the screen says **"Publisher: Unknown" — that is
   expected for this version** and does not mean the file is wrong. Check
   that the file name is the one you were given, then carry on.

   [SCREENSHOT: the blue SmartScreen screen, "Windows protected your PC"]

3. Click **More info**.

   [SCREENSHOT: the SmartScreen screen after clicking "More info", with the "Run anyway" button circled]

4. Click **Run anyway**.
5. The installer runs and finishes. There are no choices to make — it
   installs for your Windows login only.

   [SCREENSHOT: the installer finished screen]

6. Open the app from the desktop shortcut, or from the Start menu under
   **IQRS → IQRS Workspace**.

   [SCREENSHOT: the desktop shortcut and the Start menu entry]

## 3. First sign-in and first sync

1. Open **IQRS Workspace**.
2. On the sign-in screen, check the **Server** box says
   **Production — iqrs.edu.pk**. Leave it as it is unless Rektrs tells you
   otherwise.

   [SCREENSHOT: the sign-in screen, showing the Server box set to Production]

3. Type your staff email address and password, then click **Sign in**.
   The first sign-in on a computer needs the internet.
4. The app creates your profile on this computer and downloads the school's
   information (students, classes, the fee structure). This **first sync can
   take a few minutes** — leave the app open until it finishes.

   [SCREENSHOT: the first sync in progress]

5. After that, the app opens straight to your work. You can keep working if
   the internet drops: anything you save offline waits in the app's
   **Waiting** list and is sent when the connection returns.

The app locks itself when it is left idle, to protect your profile on a
shared computer. Unlock it with the PIN for your profile.

### If you work at the fee desk

- **Collect Fees** (in the **Fees** section): find the student, check the
  amount, take the payment and save. Any fine shown is the amount the school
  system has assessed — the app never adds a fine itself, and it will not
  let you collect more fine than the assessed amount.

  [SCREENSHOT: the Collect Fees screen]

- **Receipts:** you get a receipt for every collection. If a payment has
  not reached the server yet (for example, you collected it offline), its
  receipt is marked **provisional** and carries a reference starting
  `PROV-`. It becomes a final receipt, with its real receipt number, once
  the payment is confirmed.
- **Statement:** a student's statement shows what was charged, what was
  paid, any discount, any fine, and the balance still due.
- **Cash-up:** at the end of the day, open the cash-up card, count the cash
  in the till, and compare. The app shows the cash and bank amounts it
  expects and any difference, so a difference is spotted the same day.

  [SCREENSHOT: the cash-up card at the end of the day]

- **Printing:** receipts and documents print through the normal Windows
  print window, where you choose the printer (see Troubleshooting).

## 4. Updating the app

- The app checks for updates when you sign in, then once a day while it is
  running. You can also check yourself at any time:
  **Settings/About → Check for updates**. The About screen shows the version
  you are running — support may ask you for it.
- **Ordinary update:** the new version downloads in the background. When it
  is ready, a card on the Home screen says
  **"Version X is ready — Restart to update."** Restart the app when it
  suits you. Updating needs no administrator password.

  [SCREENSHOT: the Home screen card, "Version X is ready — Restart to update"]

- **Your settings and your work are kept.** Nothing you have saved is stored
  in the program folder, so an update never removes it. The first time the
  app opens after an update, it shows **"Updated to X"**.
- **Required update:** sometimes an old version must stop being used. The
  app then shows a banner with the number of days left to update —
  normally **7 days**. Please update within that time. After the last day,
  if the update has already downloaded, the app opens on an
  **Update Now** screen instead of your normal work.
- **No internet? You are never locked out of fee collection because the
  internet is down.** If a required update cannot download, the app gives
  you a one-day pass and shows a banner instead. Connect to the internet as
  soon as you can, so the update can arrive.
- **If an update fails to install,** the app opens your old version as
  normal and shows a link to the download page. It will not keep retrying
  by itself. Either install the current installer from
  https://iqrs.edu.pk/downloads/workspace-desktop/ over the top, or tell
  Rektrs support.

## 5. One-time note: replacing the early build (one computer only)

One laptop already has an **early test build** of this app, installed by
Rektrs in November 2026. That build cannot update itself into the new
version, so on that one computer the replacement is done by hand, once:

1. Uninstall the old **IQRS Workspace** (see section 6).
2. Install the new installer file (see section 2).
3. Sign in again (see section 3). The school data is on the server, so
   nothing is lost — the app downloads it again on the first sync.

Every other computer — and that laptop from then on — receives its updates
in place through the app, as described in section 4.

## 6. Uninstalling

1. Open **Windows Settings → Apps** (or Control Panel → Programs and
   Features).
2. Choose **IQRS Workspace**, then **Uninstall**.

   [SCREENSHOT: the IQRS Workspace entry in Windows Settings → Apps]

3. Uninstalling removes the program only. Your app data stays on the
   computer under your Windows login, and everything that has already
   synced is on the school server — uninstalling never deletes school
   records.
4. **Before uninstalling, open the app and check the Waiting list.** If
   anything is still waiting to send, let it send first (connect to the
   internet and leave the app open for a few minutes), or tell the office —
   until an item is sent, it exists only on that computer.

## 7. Troubleshooting

| Problem | What to check or do | Who to tell |
|---|---|---|
| Windows shows "Windows protected your PC" when I install | This is expected for this version. Check the file name is the one you were given, then click **More info → Run anyway**. | — |
| I cannot sign in | Check the Server box says **Production — iqrs.edu.pk**. The first sign-in on a computer needs the internet. Use your staff email address and password. | If it still fails, note the exact message shown and tell the office. |
| The app says an update is required | Connect to the internet and restart the app, or press **Update Now**. If there is no internet today, use the one-day pass and connect later the same day. | Rektrs support, if it repeats. |
| Items are sitting in "Waiting to send" | The internet is down, or was down. Connect, and leave the app open for a few minutes. Do not uninstall the app while items are waiting. | The office, if items are still waiting after a day. |
| An item is under "Needs your attention" (held) | The server did not accept the item, and the app shows the server's reason in its own words — read it on the item. **Held** means a person must decide what happens; the app never takes money off by itself. Do not collect the same fee again until it is sorted out. | The office admin, the same day. They can move the payment to the right place, or cancel it with a record of why. |
| The app is locked and asks for a PIN | Enter the PIN for your profile. | The office, if you have forgotten it. |
| Nothing prints, or the wrong printer prints | Printing opens the Windows print window — check the right printer is chosen there, and that the printer is switched on and has paper. | The office. |
| After printing a batch, the app asks "Did it print?" | Answer honestly. If you are not sure, choose **Not sure** — the app marks the item so it is not printed twice by mistake. | — |
| A receipt says "provisional" (reference starting `PROV-`) | The payment is saved on this computer but not yet confirmed by the server. Connect to the internet and leave the app open; the receipt becomes final when the payment is confirmed. | The office, if it is still provisional after a day. |
| The app will not open after an update | Restart the computer once. If it still fails, download the current installer from the download page and install it over the top — your data is kept. | Rektrs support. |

---

*End of draft. Next steps (D3-4 exit): screenshots from the real unsigned
pilot installer on Windows; a Roman Urdu version prepared from this text;
the finished guide published as `install-guide.pdf` in the download area
with printed copies for the rollout visit.*
