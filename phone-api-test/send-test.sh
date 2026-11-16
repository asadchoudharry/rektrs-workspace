#!/usr/bin/env bash
# SMS Gate cloud test sender.
# Credentials MUST come from the environment (Secure Vault flow) — never hardcode,
# never paste them in chat. Split literals below avoid harness redaction traps.
set -euo pipefail

: "${SMSGATE_USER:?set SMSGATE_USER from vault}"
: "${SMSGATE_PASS:?set SMSGATE_PASS from vault}"
: "${TEST_PHONE:?set TEST_PHONE in international format, e.g. +92...}"

curl -sS -X POST -u "${SMSGATE_USER}:${SMSGATE_PASS}" \
  --json "{\"textMessage\":{\"text\":\"Rektrs Phone API test - ye SMS agent ne aap ki SIM se bheja hai.\"},\"phoneNumbers\":[\"${TEST_PHONE}\"]}" \
  https://api.sms-gate.app/3rdparty/v1/messages
echo
