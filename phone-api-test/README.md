# Phone API — Ready-made Test (SMS Gate)

Chosen app: **SMS Gateway for Android (SMS Gate)** — sms-gate.app
Why this one for the first test:
- Cloud Server mode: no email / phone signup — app auto-creates an anonymous account
- Works from anywhere (not only same Wi-Fi), via api.sms-gate.app + FCM push
- Same app later supports Local mode and a self-hosted Private Server mode
- Android 5.0+ — Redmi Note 12 is fine

Official docs checked 2026-11-13:
- Overview / modes: https://docs.sms-gate.app/getting-started/
- Public Cloud Server: https://docs.sms-gate.app/getting-started/public-cloud-server/
- Installation: https://docs.sms-gate.app/installation/

## Phone steps (Assad, on Redmi Note 12)
1. Install the app: open the GitHub Releases page from the Installation doc
   and download the most recent **secure / standard** APK (NOT the insecure build),
   OR install "SMS Gateway for Android" if available in Play Store.
   Allow "install from unknown sources" for the browser/file manager if asked.
2. Open the app, grant: SEND_SMS, RECEIVE_SMS, READ_PHONE_STATE.
3. On Home: toggle **Cloud Server** ON.
4. Tap **Start Service**. A registration dialog opens with 3 tabs:
   keep the default **Sign Up** tab and confirm — anonymous account auto-created,
   no email/phone needed.
5. Button changes to **Stop Service** = connected.
6. MIUI battery: Settings > Apps > SMS Gateway > Battery > **Unrestricted**,
   and allow Autostart — warna MIUI background mein app ko maar dega.
7. Credentials (username/password) auto-appear in the **Cloud Server** section.
   DO NOT send them in chat.
8. First proof WITHOUT any agent: open https://dashboard.sms-gate.app ,
   log in with those credentials, send a test SMS to your own second number /
   your own number. If it arrives from your SIM — gateway proven.

## Agent test (step 2, after step 1 passes)
Credentials go through Secure Vault only. Muse then runs send-test.sh,
which reads credentials from environment variables — never hardcoded,
never in chat, never in this repo.

Test message: "Rektrs Phone API test — ye SMS agent ne aap ki SIM se bheja hai."
Recipient for the first agent test: Assad's own number only.

## Limits of this test
- SMS only. This ready-made app does NOT dial calls.
  Call test will be a separate small app / next step after SMS proves.
- Cloud mode is for non-sensitive data only (vendor's own wording).
  For real use we move to Private Server mode on Assad's own VPS,
  or to the custom app.
- Consumer SIM: no bulk/spam sending — carrier can throttle/block.
