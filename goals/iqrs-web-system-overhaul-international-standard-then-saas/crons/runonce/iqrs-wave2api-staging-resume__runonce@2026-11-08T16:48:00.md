---
id: iqrs-wave2api-staging-resume
title: IQRS Wave 2 API slice — resume when staging recovers
enabled: true
owner: goal:iqrs-web-system-overhaul-international-standard-then-saas
mode: task
schedule:
  kind: runonce
  timezone: Asia/Karachi
  at: 2026-11-08T16:48:00
delivery:
  - chat_id: 912efd32-16a2-43e0-9b9b-8ff5ea7f9b6a
metadata:
  tags: [cron:flexible-time]
  originating_chat_context_json: '{"chat_id":"912efd32-16a2-43e0-9b9b-8ff5ea7f9b6a","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false}'
  presentation_locale: en-GB
---
One-shot resume check for the IQRS web overhaul Wave 2 API slice (goal: iqrs-web-system-overhaul-international-standard-then-saas). Context: the slice build is COMPLETE and lint-clean (6 vendor API files in ~/workspace/goals/iqrs-web-system-overhaul-international-standard-then-saas/hidden_files/wave2-api-build/ — WAVE2-API-BUILD-PLAN.md + PATCHES.md + patches/). At ~16:20 PKT on 2026-11-08 the staging host (staging.iqrs.edu.pk) was stalling: any request that runs the full app (web pages, POST /api/auth/login) died at ~10.5s with an empty reply, while production iqrs.edu.pk answered the same POST in ~1.1s. The staging deploy was therefore parked BEFORE any file was touched; production must NOT be touched in this job.

Step 1 — probe staging health with curl (never urllib): POST https://staging.iqrs.edu.pk/api/auth/login with headers Client-Service: smartschool / Auth-Key: schoolAdmin@ and JSON body {"username":"teststudent.w0@iqrs.edu.pk","password":"TestStu@W0","deviceToken":"wave2api-acceptance"}, --max-time 45. Healthy = a JSON login response with a record.token.
- If STILL stalled (HTTP 000 / empty / timeout): send Assad ONE short message in Roman Urdu/English in the delivery chat saying staging is still stalled, the build stays ready, and the deploy remains parked; append a one-line note to ~/memory/2026-11-08.md; then STOP. Do not reschedule yourself and do not touch any server file.
- If healthy: continue.

Step 2 — run the before-captures: bash ~/workspace/goals/iqrs-web-system-overhaul-international-standard-then-saas/hidden_files/wave2-api-build/acceptance/capture.sh before (from that acceptance directory). Verify the login line shows a non-empty token and the getHomework-nostatus capture exists. Note today's known pre-patch expectation: getHomework without homework_status returns an EMPTY homeworklist (that is FL-046's symptom).

Step 3 — staging deploy via a browser task with profile p0b17e5065f41 ("IQRS Hostinger"), STAGING site only, granting the 6 patched files from hidden_files/wave2-api-build/patches/api/application/... Targets in the staging tree (staging docroot api/application/...): controllers/Webservice.php (staging original must be 326,504 B — STOP on mismatch), models/Attendencetype_model.php (3,119 B), models/Homework_model.php (6,940 B), models/Subjecttimetable_model.php (7,295 B), models/Syllabus_model.php (7,715 B), models/Leave_model.php (3,611 B). Back each up in place as <name>.bak-2026-11-08-wave2api before overwriting; verify patched sizes after (328,140 / 3,924 / 6,974 / 7,295 / 8,296 / 3,901 B; File Manager shows KiB ranges — accept the containing range). php -l is already clean on all six (PHP 8.3.6, done by the coordinator).

Step 4 — after-captures: capture.sh after; diff before vs after per the plan: FL-039 getAttendenceRecords + getAttendenceRecords1 byte-identical; FL-046 nostatus goes from empty to all rows, pending/submitted/evaluated byte-identical to before and unioning to the full list; FL-047 class_schedule / getstudentsubject / getsyllabussubjects / getlessonplan / getSubjectList byte-identical; FL-049 getExamResult byte-identical (its zero-max leg needs a staging phpMyAdmin flip of exam_group_class_batch_exam_subjects.id 18 max_marks to 0 and back to 50.00 — run it via a site-scoped phpMyAdmin browser task on the STAGING database u238632175_test123 only, restoring exactly).

Step 5 — FL-048 + FL-054 legs (staging only, via browser tasks + curl): FL-048 — in staging phpMyAdmin set the fixture's student_session.default_login = 0 for students.id 3699 / session 21, then curl dashboard, fees, getHomework, getExamList, class_schedule, getApplyLeave as the fixture student: ALL must return HTTP 404 {"status":404,"message":"Student not found."} (not 500); restore default_login = 1 and re-verify normal 200s. FL-045 leg from the plan (one scratch subject_timetable row for Seven–Diamond section 13 with no marking must surface with NULL attendance after the patch; delete the scratch row after). FL-054 — addLeave via the API as the fixture writes exactly one complete student_applyleave row; delete that row after (atomicity leg is code-proof per the plan).

Step 6 — report to Assad in the delivery chat (Roman Urdu/English mix, concise): staging deploy + battery verdicts per flaw, any failure named plainly. Append the outcome to ~/memory/2026-11-08.md. Do NOT deploy to production in this job — production follows only after the coordinator reviews the staging battery in the main chat.
