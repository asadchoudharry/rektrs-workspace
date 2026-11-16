# Legacy Source Findings — CodeCanyon "Smart School Mobile App" v5.0 vs the Family Parity Plan

Mined 2026-11-07 from the user's own purchased package
(`references/codecanyon-smart-school-mobile-app-source.zip`, 144,697,805 B,
sha256 3076ae25…), extracted to `~/workspace/iqrs-legacy-source/`.
Every claim cites a file:line inside that tree. Prefixes used below:
**APP** = `smart_school_mobile_app_src/`, **API** = `smart_school_mobile_api_src/`,
**IQRS** = the live vendor copy at `~/workspace/iqrs-api/production/api/application/`.

## 0. Headline results

1. **The package contains BOTH the full Flutter app source AND the full
   backend API source — and the backend is byte-identical to the iqrs copy.**
   `API/application/controllers/Webservice.php` and IQRS `Webservice.php`
   have the same size (326,504 B) and the same md5
   (`4e742290e5bcec7c3127a583e2093e52`). Same for `Auth.php`
   (md5 `24d42c6170d791a9931de1444a4a13a9`), `Payment.php`
   (md5 `db96f80b5e623b3887126ca91385e467`), `models/Chatuser_model.php`
   (md5 `551836543892b8207823214dbe760773`) and
   `models/Webservice_model.php` (md5 `423e1a74c908c1c88371cf4ded6385bb`);
   the two method sets (146 unique `function` names) and `config/routes.php`
   route sets diff **empty**. Consequence: there is no "different API build"
   hiding anywhere — every endpoint question is settled by the one
   Webservice.php both sides share.
2. **CHAT DOES NOT EXIST in this app.** No chat screen, no chat API class, no
   message send/fetch call anywhere in `APP/lib` (§4a).
3. **CHANGE PASSWORD is a façade**: a Settings dialog whose button is a
   `// TODO` stub showing "coming soon", plus an orphaned page calling an
   endpoint (`webservice/changePassword`) that does not exist in the
   (identical) backend (§4b).
4. **NOTIFICATIONS screen exists but is not a separate data feature**: it
   renders the same notice-board endpoints as the Notice Board screen. FCM
   push is genuinely implemented app-side (§4c).
5. **The legacy app never calls `webservice/dashboard`** (zero hits in
   `APP/lib`). Its dashboard is a static module tile grid; attendance %,
   events (`public_events`/`date_lists` — also zero hits) and counters do
   not come from the dashboard response. Our Family app already calls
   `dashboard`; the legacy app is *behind* us here, not ahead.
6. **Legacy pattern — endpoint guessing**: most API classes try a list of
   candidate endpoint spellings (primary + invented fallbacks) until one
   answers 200. Only the primary names exist in the backend; the fallbacks
   (e.g. `getFees`, `homework`, `tasks`, `staff`, `updateProfile`,
   `getStudentFromLoginData`) are **not** Webservice methods. Tables below
   mark the real (backend-present) name first and list fallbacks as
   fallbacks.

---

## 1. Package survey

Top level of the ZIP:

| Entry | What it is |
|---|---|
| `smart_school_mobile_app_src/` | **Full Flutter app source** (app version `5.0.0+1`, `pubspec.yaml:5`), package `schoolapp`, Android applicationId dir `com/qdocs/smartschool2026` (`android/app/src/main/kotlin/com/qdocs/smartschool2026/MainActivity.kt`) |
| `smart_school_mobile_api_src/` | **Full CodeIgniter backend** for the mobile API (`application/`, `system/`, `backend/`, `index.php`) — byte-identical to IQRS for all files checked (§0.1) |
| `smart_school_mobile_app/` | Prebuilt `smart_school_android_app_5.0.apk` (39 MB) + `smart_school_ios_app_5.0.ipa` (16 MB) |
| `documentation/` | User manual (`index.html` + assets) |
| `licensing/`, `readme.txt` | GPL/readme |

### Flutter app structure (`APP/lib/`, 181 Dart files)

- `config/` — `app_config.dart` (base URL, headers, prefs keys),
  `firebase_config.dart`, `notification_config.dart`
- `services/api/` — 27 API classes (one per domain, §2) + `api_service.dart`
  (façade), `auth_service.dart`, `notification_service.dart`,
  `translation_service.dart`, `lesson_plan_service.dart`,
  `offline_mode_service.dart`
- `utils/` — `dynamic_api_headers.dart`, `url_manager.dart`,
  `url_auto_config.dart`, `session_manager.dart`, fee calculator, validators
- `models/` — 18 models (fee, homework, exam, quiz, course, behaviour,
  timeline, visitor, document, …)
- `providers/` — `app_config_provider.dart`, `translation_provider.dart`
- `screens/` — ~110 screens (inventory in §1.1)
- `widgets/` — drawer, dashboard cards, child-selection dialog, …

Dependencies of note (`APP/pubspec.yaml`): `http`, `shared_preferences`,
`firebase_core` + `firebase_messaging` + `flutter_local_notifications`
(patched local copy in `third_party/`), `webview_flutter` (used for the
payment page, §6), `video_player`/`chewie`/`youtube_player_flutter`,
`flutter_pdfview`, `printing`, `file_picker`/`image_picker`, `share_plus`,
`url_launcher`, `qr_flutter`/`barcode_widget` (fee receipts),
`cached_network_image`. A vendor `google-services.json` ships in
`APP/android/app/google-services.json` (the vendor's demo Firebase project —
not usable for IQRS, consistent with the plan's Wave C).

### 1.1 Screen inventory (every file in `APP/lib/screens/`, purpose)

Auth/onboarding: `splash_screen` (entry; `main.dart:99` home),
`url_page` (school URL entry + validation, route `/url`), `login_page`
(route `/login`), `forgot_password_page`, `change_password_page` (§4b —
orphaned), `school_verification_blocked_page` (licence-blocked school, §5).
Shell: `dashboard_page` (module tile grid grouped E-Learning / Academics /
Communicate / Others, `dashboard_page.dart:705-722`), `settings_page`,
`profile_page`, `edit_profile_page`, `about_school_page`.
Academics: `attendance_page`, `timetable_page`, `subjects_page`,
`homework_page`, `complete_assignment_page` (homework submit),
`daily_assignment_page`, `add_edit_daily_assignment_page`,
`lesson_page`, `lesson_detail_page`, `lesson_plan_page`,
`lesson_plan_detail_page`, `syllabus_status_page`, `syllabus_detail_page`,
`video_tutorials_page`, `calendar_todo_page` + `pending_tasks_page`
(personal tasks), `timeline_page`, `add_timeline_page`, `edit_timeline_page`.
Examinations: `examination_page`, `exam_schedule_page`, `exam_result_page`,
`report_card_page`, `cbse_exam_schedule_page`, `cbse_exam_result_page`,
`online_examination_page`, `online_exam_page`, `online_exam_detail_page`,
`exam_taking_page`, `online_exam_result_page`.
Fees: `fees_page`, `fees/*` (fee_logic, fee_card, multi_fee_payment_dialog,
offline_payment_card, processing_fee_card), `enterprise_fees_page` (parallel
"enterprise" UI), `offline_payment_page`, `payment_webview_page`,
`payment_success_page`.
Communicate: `notice_board_page` (route `/notice_board`),
`notification_page` (route `/notifications`, §4c),
`notification_debug_page` (developer screen), `leave_list_page`,
`leave_page`, `visitors_page`, `visitor_book_page`, `add_visitor_page`,
`student_behaviour_page`, `behaviour_comments_page`.
Content: `library_page`, `transport_routes_page`, `hostel_page`,
`download_center_page`, `enterprise_download_center_page`,
`my_documents_page`, `add_document_page`, `upload_document_page`,
`document_viewer_page`, `pdf_viewer_page`, `youtube_video_player_page`.
Online course: `online_course_page`, `online_course/*` (main, lesson
content, quiz list/attempt/result, assignment, assessment detail/taking),
`course_detail_page`, `course_payment_page`, `course_performance_page`.
People: `teachers_page`, `teacher_review_page`.
Live classes: `zoom_live_classes_page`, `gmeet_live_classes_page`.
Named routes are only `/url`, `/login`, `/cbse-exam-result`,
`/notifications`, `/notification_debug`, `/notice_board`
(`APP/lib/main.dart:100-113`); everything else is pushed imperatively.
**There is no chat screen, no events/calendar screen, no share-app or
rate-app screen anywhere in this inventory.**

---

## 2. The app's API layer — full endpoint list

Conventions (verified across the API classes): almost everything is
**POST**; reads use a **JSON** body; writes with a file use
**multipart/form-data**; plain writes without files use JSON unless noted.
`getApiEndpoint('X')` builds `<base>/api/webservice/X`
(`APP/lib/config/app_config.dart`, `getApiEndpoint`). Headers on every call
(`APP/lib/utils/dynamic_api_headers.dart:28-40`): `Auth-Key: schoolAdmin@`,
`Client-Service: smartschool`, `Content-Type: application/json`,
`Authorization: <raw token>` (no `Bearer` prefix in the headers actually
used), `User-ID: <users.id>`, plus a session `Cookie` when one was captured.
Where a call lists candidate endpoints, the **first is the one that exists
in Webservice.php** unless marked † (= candidate does **not** exist in the
backend; the app falls through to the next).

### Auth / config (not webservice)

| Path | Method / encoding | Params | Citation |
|---|---|---|---|
| `api/auth/login` | POST JSON | `username`, `password`, `deviceToken` | `APP/lib/screens/login_page.dart:156,180-182`; also `APP/lib/services/auth_service.dart:325,337-365` |
| `<base>/app` | POST JSON (GET fallback) | — (returns school config: name, logo, colours, languages, currency, `app_ver`) | `APP/lib/services/api_service.dart:569` (`'$baseUrl/app'`); backend `API/application/controllers/App.php:17` `index()` |
| `https://sstrace.qdocs.in/postlic/verifyappjsonv2` | POST JSON | `site_url` | `APP/lib/services/api_service.dart:408-424` — **vendor licence check**, §5 |
| `api/webservice/forgot_password` | POST JSON | `site_url`, `email`, `usertype` | `APP/lib/services/api/auth_api.dart:123,133-142` |
| `api/forgot_password` † | POST JSON | `email`, `usertype`, `site_url` | `APP/lib/services/api/profile_api.dart:143-152` (second, divergent forgot-password implementation; this path has no matching route) |

### Webservice endpoints actually called

| Endpoint (real name) | Method / encoding | Params (body) | Citation |
|---|---|---|---|
| `dashboard` | — **never called** (§0.5) | — | zero hits in `APP/lib` |
| `getStudentProfile` | POST JSON | `student_id`, `user_type` | `APP/lib/services/api/profile_api.dart:24-31` |
| `editprofile` (app tries `updateProfile`†, `saveStudentProfile`†, `editProfile`, `updateStudentProfile`†, `setStudentProfile`†, `editStudentProfile`† + snake_case variants) | POST JSON | caller-supplied profile map | `APP/lib/services/api/profile_api.dart:56-67` (candidate list); backend `editprofile()` exists — PHP method names are case-insensitive, so the `editProfile` candidate resolves |
| `changePassword` † | POST JSON | `current_password`, `new_password`, `confirm_password` | `APP/lib/services/api/profile_api.dart:112-118` — **no such backend method** (§4b) |
| `resetPassword` † | POST JSON | `token`, `new_password`, `confirm_password` | `APP/lib/services/api/profile_api.dart:191-197` — no such backend method; no screen calls it |
| `updateDeviceToken` † | POST JSON | `student_id`, `device_token`, `token`, `platform` | `APP/lib/services/api/notification_api.dart:17-31` — no such backend method (§4c) |
| `getAttendenceRecords` (fallback `getAttendance`†) | POST JSON | `student_id`; variant adds `month`, `year` | `APP/lib/services/api/attendance_api.dart:30-32,115-130` |
| `class_schedule` | POST JSON | `student_id` | `APP/lib/services/api/timetable_api.dart:27,51`; backend `class_schedule()` IQRS Webservice.php:2513. (The app does **not** call `getClassTimetable` except as a connectivity probe, `auth_api.dart:43`.) |
| `getExamList` | POST JSON | `student_id` | `APP/lib/services/api/examination_api.dart:36` |
| `getExamSchedule` | POST JSON | exam id + `student_id` (per function signature) | `APP/lib/services/api/examination_api.dart:134-150` |
| `getExamResult` | POST JSON | `student_id` + exam id | `APP/lib/services/api/examination_api.dart:248-265` |
| `cbseexamresult` | POST JSON | `student_session_id` | `APP/lib/services/api/examination_api.dart:360-369` |
| `cbseexamtimetable` | POST JSON | `student_session_id` | `APP/lib/services/api/examination_api.dart:436-446` |
| `getHomework` (fallbacks `getHomeworkList`†, `homework`†, `getStudentHomework`†) | POST JSON | `student_id`, `homework_status` | `APP/lib/services/api/homework_api.dart:58-61` + body at :15-105 |
| `getHomeworkById` (fallbacks `gethomeworkbyid`, `get_homework_by_id`†, `homeworkById`†) | POST JSON | `homework_id` | `APP/lib/services/api/homework_api.dart:130-133` |
| `addhomework` (homework SUBMIT) | POST **multipart** | fields `homework_id`, `id` (alias), `student_id`, `message`, `student_message` (alias), `student_session_id`; file parts `file`, then `userfile` fallback | `APP/lib/services/api/homework_api.dart:281,327,350-412` (`fileFieldName = 'file'` :398) |
| `getSubjectList` (fallbacks `getSubjects`†, `getStudentSubjects`†, `subjects`†) | POST JSON | `student_id` (variant body `id`) | `APP/lib/services/api/homework_api.dart:178-181` |
| `getdailyassignment` (fallback `getDailyAssignment`) | POST JSON | `student_id` | `APP/lib/services/api/daily_assignment_api.dart:21,90-96` |
| `addeditdailyassignment` | POST **multipart** | assignment fields + file `file` | `APP/lib/services/api/daily_assignment_api.dart:137-177,270` |
| `deletedailyassignment` | POST JSON | assignment id | `APP/lib/services/api/daily_assignment_api.dart:371-400` |
| `getsyllabussubjects` | POST JSON | `student_id` | `APP/lib/services/api/lesson_api.dart:27,112` |
| `getSubjectsLessons` | POST JSON | subject/syllabus ids | `APP/lib/services/api/lesson_api.dart:224,325` |
| `getsyllabus` | POST JSON | `subject_syllabus_id` (per façade signature) | `APP/lib/services/api/lesson_api.dart:513-527` |
| `getlessonplan` | POST JSON | `student_id` | `APP/lib/services/api/lesson_api.dart:408-427`; also `APP/lib/screens/lesson_plan_page.dart:192`, `APP/lib/services/lesson_plan_service.dart:119` |
| `getforummessage` | POST JSON | `student_id` | `APP/lib/services/api/lesson_api.dart:575-600`; duplicate wrapper `communication_api.dart:194-198` calls candidate `getForumMessage` |
| `saveforummessage` (candidates `addforummessage`†, `saveForumMessage`, `saveLessonForumComment`†) | POST JSON | `student_id`, `message` | `APP/lib/services/api/lesson_api.dart:725-790`; duplicate `communication_api.dart:245-249` candidate `saveComment`† |
| `deleteforummessage` | POST JSON | comment id | `APP/lib/services/api/lesson_api.dart:942-948` |
| `getOnlineExam` | POST JSON | `student_id` | `APP/lib/services/api/online_exam_api.dart:13-16` |
| `getOnlineExamQuestion` | POST JSON | `student_id`, online exam id | `APP/lib/services/api/online_exam_api.dart:88-109` |
| `saveOnlineExam` | POST JSON **and** a multipart variant (with attachments) | answers payload | `APP/lib/services/api/online_exam_api.dart:186-206` (multipart), `:274-279` (JSON) |
| `getOnlineExamResult` | POST JSON | `student_id` / exam ids | `APP/lib/services/api/online_exam_api.dart:332-338,441` |
| `getNotifications` (fallbacks `getNoticeBoard`, `notifications`†, `notices`†, `getAnnouncements`†) | POST JSON | session-derived (role) | `APP/lib/services/api/common_api.dart:87-92` |
| `getApplyLeave` | POST JSON | `student_id` | `APP/lib/services/api/communication_api.dart:26-61` (body `{'student_id': …}`) |
| `addleave` | POST **multipart** | fields `student_id`, `studentId` (alias), `student_session_id`, `from_date`, `to_date`, `apply_date`, `reason`; file `file` | `APP/lib/services/api/communication_api.dart:291-336,389-395` |
| `updateLeave` | POST **multipart** | same field family + leave id | `APP/lib/services/api/communication_api.dart:505-551` |
| `deleteLeave` | POST JSON | leave id | `APP/lib/services/api/communication_api.dart:459-479` |
| `getVisitors` (fallbacks `getVisitorBook`, `getStudentVisitors`†, `visitorBook`†, `visitors`†) | POST JSON | `student_id` | `APP/lib/services/api/communication_api.dart:663-684` |
| `addvisitor` (candidates `addVisitorBook`†, `addVisitor`, `add_visitor`†, `saveVisitor`†) | POST **multipart** | visitor fields; file `file` | `APP/lib/services/api/communication_api.dart:795-851,872` |
| `getstudentbehaviour` (fallbacks camelCase/snake variants) | POST JSON | `student_id` | `APP/lib/services/api/student_behaviour_api.dart:13-44` |
| `getincidentcomments` (fallbacks variants) | POST JSON | incident id | `APP/lib/services/api/student_behaviour_api.dart:441-472` |
| `addincidentcomments` | POST JSON | incident id + comment | `APP/lib/services/api/student_behaviour_api.dart:592-617` |
| `deleteincidentcomments` (fallbacks singular/remove variants †) | POST JSON | comment id | `APP/lib/services/api/student_behaviour_api.dart:687-738` |
| `getTimeline` (fallbacks `getTimelineList`†, `timeline`†, `getStudentTimeline`†, `calendar`†) | POST JSON | `student_id` | `APP/lib/services/api/student_api.dart:12-33` |
| `addedittimeline` | POST **multipart** | timeline fields + file | `APP/lib/services/api/student_api.dart:104-129` |
| `deletetimeline` | POST JSON | timeline id | `APP/lib/services/api/student_api.dart:189-193` |
| `getStudentTimelineStatus` (fallbacks `getTimeLineStatus`, `getTimelineStatus`, `timelineStatus`†, `get_timeline_status`†, `getTimelineSettings`†) | POST JSON | `student_id` | `APP/lib/services/api/student_api.dart:235-256` |
| `getTeachersList` (fallbacks `getTeachers`†, `teachers`†, `getStaffList`†, `staff`†) | POST JSON | `class_id`, `section_id`, `user_id` | `APP/lib/services/api/teacher_api.dart:13-24` |
| `getTeacherSubject` | POST JSON | `class_id`, `section_id`, `staff_id` | `APP/lib/services/api/teacher_api.dart:178-182` |
| `getTeacherReviews` (fallbacks `getTeacherReview`†, `getTeacherRatings`†, `teacherReviews`†, `getStaffReviews`†, `getStaffRating`†) | POST JSON | `student_id` | `APP/lib/services/api/teacher_api.dart:233-253` |
| `addStaffRating` | POST JSON | staff id + rating/comment | `APP/lib/services/api/teacher_api.dart:628-638` |
| `getDocument` (fallbacks `getDocuments`†, `getStudentDocuments`†, `documents`†, `getMyDocuments`†, `studentFiles`†) | POST JSON | `student_id` | `APP/lib/services/api/document_api.dart:13-35` |
| `uploadDocument` | POST **multipart** | fields `student_id`, `title`, `description`; file `file` | `APP/lib/services/api/document_api.dart:172-198,281,352` (comment at :172 quotes the vendor's own working cURL) |
| `getDownloadsLinks` | POST JSON | `student_id` | `APP/lib/services/api/download_api.dart:12-26`. **`getDownloadsLinksById` is never called** (zero hits) |
| `getVideoTutorial` | POST JSON | `student_id` (+ class/section in façade variants) | `APP/lib/services/api/download_api.dart:99-113` |
| `getLibraryBookIssued` | POST JSON | `student_id` | `APP/lib/services/api/library_api.dart:13-80` |
| `getLibraryBooks` | POST JSON | `student_id` | `APP/lib/services/api/library_api.dart:201-247` |
| `gettransportroutes` | POST JSON | `student_id` | `APP/lib/services/api/transport_api.dart:12-30` |
| `getHostelList` (fallbacks `getHostels`†, `hostels`†, `getStudentHostels`†, `hostelRooms`†) | POST JSON | `student_id` | `APP/lib/services/api/hostel_api.dart:12-33` |
| `liveclasses` | POST JSON | `student_id` | `APP/lib/services/api/live_class_api.dart:12-26` |
| `gmeetclasses` | POST JSON | `student_id` | `APP/lib/services/api/live_class_api.dart:63-77` |
| `getTask` (fallbacks `getPendingTasks`†, `getTasks`†, `getUserTasks`†, `tasks`†) | POST JSON | user id | `APP/lib/services/api/pending_tasks_api.dart:12-34` |
| `addTask` (fallbacks `createTask`†, `addtask`, `create_task`†, `saveTask`†, `save_task`†) | POST JSON | task fields | `APP/lib/services/api/pending_tasks_api.dart:189-227` |
| `updatetask` | POST JSON | task id + status/fields | `APP/lib/services/api/pending_tasks_api.dart:533-545` |
| `deletetask` (fallbacks `deleteTask`, `removeTask`†) | POST JSON | task id | `APP/lib/services/api/pending_tasks_api.dart:338-355` |
| task mark-done (candidates `markasdone`, `markTask`†, `addTask`, `updateTaskStatus`†, `editTask`†, `todo`†, `addtodo`†) | POST JSON | task id | `APP/lib/services/api/pending_tasks_api.dart:417-447` |
| `fees` (fallback `getFees`†) | POST JSON | `student_id` | `APP/lib/services/api/fees_api.dart:1331-1332` |
| `getFeesDiscount` | POST JSON | `student_session_id`, `student_fees_master_id`, `fee_groups_feetype_id`, `fee_category` | `APP/lib/services/api/fees_api.dart:790-798` |
| `getProcessingfees` | POST JSON | `student_id` | `APP/lib/services/api/fees_api.dart:22-41` |
| `getBalanceFee` | POST JSON | `student_session_id`, `student_fees_master_id`, `trans_fee_id`, `fee_category`, `fee_groups_feetype_id` | `APP/lib/services/api/fees_api.dart:112-143` |
| `getOfflineBankPayments` | POST JSON | `student_id` | `APP/lib/services/api/fees_api.dart:63-79` |
| `addofflinepayment` — note URL spelled `api/Webservice/addofflinepayment` (capital W) | POST **multipart** ("ALWAYS use MultipartRequest", comment :663) | fields `payment_date`, `student_session_id`, `amount`, `reference`, `payment_type`, `fee_groups_feetype_id`, `student_fees_master_id`, `student_transport_fee_id`, `bank_account_transferred`, `fee_category`, `submit` + alias fields (`student_id`, `payment_from`, `payment_mode`, `pay_amount`, …); optional slip file | `APP/lib/services/api/fees_api.dart:596,620-690` |
| `get_currency_list` | POST JSON | — | `APP/lib/services/api/currency_api.dart:12-35` |
| `updatestudentcurrency` | POST JSON | student id + currency id | `APP/lib/services/api/currency_api.dart:73-96` |
| `updatestudentlanguage` | POST JSON | student id + language id | `APP/lib/services/api/currency_api.dart:116-139`; invoked from `APP/lib/screens/settings_page.dart:227` |
| `getSchoolDetails` | POST JSON | — | `APP/lib/services/api/enterprise_api_service.dart:83-85` |
| `getStudentFromLoginData` † / `getStudentList` † | POST JSON | — / parent id | `APP/lib/services/api/student_management_api.dart:14,51` — neither exists in the backend; dead helpers |
| Online course: `courselist` | POST JSON | `student_id` | `APP/lib/services/api/course_api.dart:11-18` |
| `coursedetail` (candidates `getcoursedetail`†, `coursedetails`†) | POST JSON | course id + `student_id` | `APP/lib/services/api/course_api.dart:58-68` |
| `coursereviews` | POST JSON | course id | `APP/lib/services/api/course_api.dart:107-114` |
| `coursecurriculum` | POST JSON | course id | `APP/lib/services/api/quiz_api.dart:10-20`; also `course_api.dart:151` |
| `getquestionbyquizid` | POST JSON | quiz id | `APP/lib/services/api/course_api.dart:401-408`; `quiz_api.dart:91-96` |
| `getOnlineCourseQuestion` | POST JSON | exam/quiz ids | `APP/lib/services/api/quiz_api.dart:103-108` |
| `submitquiz` | POST JSON | answers | `APP/lib/services/api/quiz_api.dart:202-213` |
| `quizresults` (candidate spelling; backend name is `quizresult`) | POST JSON | quiz/student ids | `APP/lib/services/api/quiz_api.dart:266-276` |
| `saveOnlineCourseExam` | POST JSON | exam answers | `APP/lib/services/api/quiz_api.dart:324-337` |
| `markascomplete` | POST JSON | lesson/quiz ids (candidate list in progress update) | `APP/lib/services/api/course_api.dart:313-322` |
| `saveCourseAssignment` | POST **multipart** | assignment fields + file | `APP/lib/services/api/course_api.dart:498-511` |
| `get_lessonattachments_by_lessonid` | POST JSON | lesson id | `APP/lib/services/api/course_api.dart:470-472` |
| `coursedownloadcertificatepdf/<certificate_id>/<student_id>/<course_id>` (path params) | POST | — | `APP/lib/services/api/course_api.dart:552-567`; candidate names also at `APP/lib/screens/course_detail_page.dart:2289-2295` |
| `deleteCertificateFile/<file_name>` (path param) | POST | — | `APP/lib/services/api/course_api.dart:604-607` |
| course rating (function `addCourseRating`) | POST JSON | course id + rating | `APP/lib/services/api/course_api.dart:198` |

### Payment-controller endpoints

| Path | Method / encoding | Params | Citation |
|---|---|---|---|
| `api/payment/paymentrequest` (PRIMARY in `payFees`) | POST JSON | `student_fees_master_id`, `fee_discount_group`, `student_transport_fee_id`, `student_id`, `fee_groups_feetype_id`, amount fields | `APP/lib/services/api/fees_api.dart:169-173,199-330` (endpoint list comment "Priority: /api/payment/paymentrequest" :321). **No `paymentrequest` method exists in `Payment.php`** — see §6 |
| `api/payment/fees_pay` | POST JSON | `payments: [{student_fees_master_id, fee_groups_feetype_id, amount, student_id, fee_type, fee_group, discounts}]`, root `student_id`, optional `fine_amount`, `fine_amount_balance` | `APP/lib/services/api/fees_api.dart:1095-1156` (doc comment :1097); backend `Payment::fees_pay()` IQRS Payment.php:365 |
| `api/payment/add_fees_deposit` / `addFeesDeposit` † (+ webservice candidates `addFeesDeposite`†, `add_fees_deposite`†, `feedeposit`†) | POST JSON | `payments`, `amount`, `student_id` | `APP/lib/services/api/fees_api.dart:1000-1041` — none of these exist in the backend; dead/experimental path |
| `api/course_payment/course_payment` | POST JSON | course + student + amount | `APP/lib/screens/course_payment_page.dart:513` → opens `PaymentWebViewPage` (:551) |

The "enterprise" service (`enterprise_api_service.dart`) is a second,
parallel client over the same webservice names (`fees`, `getProcessingfees`,
`getOfflineBankPayments`, `getBalanceFee`, `paymentrequest`,
`getAttendenceRecords`, exam/behaviour/lesson/hostel/library/teacher/
timeline wrappers at :83-404) feeding `enterprise_fees_page.dart` and
`enterprise_download_center_page.dart`. No new endpoints.

---

## 3. Per-feature verdicts vs the parity plan

Legend: **CONFIRMED** = plan's account of the legacy app matches the source;
**CORRECTED** = source differs from the plan (delta stated).

| # | Feature | Verdict |
|---|---|---|
| 1 | Login | CONFIRMED, with detail: POST `api/auth/login` JSON `{username, password, deviceToken}` (login_page.dart:156,180-182). Fallback probes at login_page.dart:149-155 (`webservice/login`†, `webservice/auth`†) |
| 2 | Dashboard | **CORRECTED**: legacy dashboard is a static tile grid (dashboard_page.dart:405-722) grouped by hard-coded sections (E-Learning/Academics/Communicate/Others). It calls **no** dashboard endpoint and reads **no** `public_events`/`date_lists`/counters. Plan §6.4's open question is answered: no event data is consumed at all |
| 3 | Profile | CONFIRMED + CORRECTED: view via `getStudentProfile`; documents via `getDocument`/`uploadDocument` ✔. Edit exists (`edit_profile_page` → `ProfileApi.updateProfile`) but the app **never calls `checkProfileUpdate` or `profileUpdateFields`** (zero hits) — no school-permission gating; it sprays 10 candidate endpoint names (profile_api.dart:56-67), of which only `editProfile`→`editprofile()` can resolve |
| 4 | Switch Child | **CORRECTED mechanism**: children arrive **inside the login response** as `record.parent_childs`, saved to prefs key `parent_childs` (`APP/lib/services/auth_service.dart:25,531-533,565-576`). `Parent_GetStudentsList` is **never called** (zero hits) |
| 5 | FCM + device token | CONFIRMED app-side: `firebase_messaging` + local notifications (`notification_service.dart:12-44`), token stored via `AppConfig.setDeviceToken`, sent at login as `deviceToken`, and re-registered via `webservice/updateDeviceToken`† — which **does not exist** in the backend (fire-and-forget, errors swallowed, notification_api.dart:17-44). The only registration that can work against stock 7.2 is the login `deviceToken` → `app_key`, exactly as the plan said |
| 6 | Class Timetable | CONFIRMED feature; **CORRECTED endpoint**: app uses `webservice/class_schedule` {student_id} (timetable_api.dart:27), a real backend method (Webservice.php:2513) the plan didn't list; `getClassTimetable` is used only as a probe (auth_api.dart:43) |
| 7 | Exam Schedule | CONFIRMED (`getExamList`, `getExamSchedule`) |
| 8 | Exam Result | CONFIRMED (`getExamResult`); CBSE variant CONFIRMED present (`cbseexamresult`, `cbseexamtimetable`, dedicated screens/routes) |
| 9 | Homework view + SUBMIT | CONFIRMED both: view `getHomework` {student_id, homework_status}; submit `addhomework` multipart with the exact field set in §2 (incl. `file` + `userfile` file parts). Evaluation fields are the backend's; the legacy detail screen is `complete_assignment_page` |
| 10 | Syllabus Status | CONFIRMED (`getsyllabussubjects`, `getSubjectsLessons`, `getsyllabus`) |
| 11 | Lesson Plan | CONFIRMED (`getlessonplan`) — **plus a sub-feature the plan missed: lesson forum comments** (`getforummessage`/`saveforummessage`/`deleteforummessage`, lesson_api.dart:575-965) |
| 12 | Attendance | CONFIRMED day-based only (`getAttendenceRecords`). **Subject-wise attendance: NOT present** — the word "subject" does not occur in `attendance_api.dart` or `attendance_page.dart` (§4d) |
| 13 | My Subjects | CONFIRMED (`getSubjectList` + fallbacks, `subjects_page`) |
| 14 | Live Classes | CONFIRMED list+join via `liveclasses`/`gmeetclasses` {student_id}; **CORRECTED**: the app never calls `livehistory`, `getzoomsettings`, `gmeethistory` or `getgmeetsettings` (zero hits). Join hand-off opens the Zoom/Meet apps, with `market://details?id=com.zoom.us` / `…com.google.android.apps.meetings` store fallbacks (zoom_live_classes_page.dart:599; gmeet_live_classes_page.dart:164) |
| 15 | Notice Board | CONFIRMED (`getNotifications` primary in common_api.dart:87-92) |
| 16 | Events / Calendar | **CORRECTED — the legacy app has NO events feature.** No screen, no endpoint, no `public_events` consumption (§0.5). Its only calendar-named feature is "Calendar To Do List" = personal tasks (`getTask` family). Plan row 16 should be re-scoped: events would be **new** value from the dashboard response (which our app already fetches), not legacy parity |
| 17 | Library | CONFIRMED both halves: issued (`getLibraryBookIssued`) **and** catalogue (`getLibraryBooks`) are implemented in the legacy app |
| 18 | Transport | CONFIRMED route list (`gettransportroutes`); **CORRECTED**: no `getTransportVehicleDetails` and no `getStudentTransportFeetypeBalance` calls (zero hits) — legacy shows no more transport depth than we do |
| 19 | Fees view + ONLINE PAYMENT | CONFIRMED both, mechanics in §6. Plan's payment description matches (`fees_pay`, `redirect_url = payment/pay/<session>`). Two corrections: (a) the app's **primary** pay call is `api/payment/paymentrequest`, which has **no matching method in Payment.php** — `fees_pay` is the second path (`payMultipleFees`); (b) the redirect opens in an **in-app WebView**, not a browser/Custom Tab (§6) |
| 20 | Previous Payment History | CONFIRMED as deposit-derived; plus the offline-payments list (`getOfflineBankPayments`). **CORRECTED**: `getOfflineBankPaymentStatus` and `getOfflineBankPaymentInstruction` are **never called** (zero hits) — legacy shows no status/instruction screens |
| 21 | Apply for Leave | CONFIRMED full CRUD: `getApplyLeave` JSON {student_id}; `addleave`/`updateLeave` **multipart** (fields in §2 — note the app uses multipart, not the plan's "form-encoded"; same field names, `file` part for the document); `deleteLeave` JSON |
| 22 | Chat | **DOES NOT EXIST** — §4a. Plan's "Blocked (Wave C)" becomes "not a legacy feature at all in this build; building it = new extension work, not parity" |
| 23 | Download Content | CONFIRMED (`getDownloadsLinks` {student_id}); **CORRECTED**: `getDownloadsLinksById` never called (zero hits) — the centre works from the one list call. Files are downloaded on tap (`download_center_page.dart:617,736`) and opened in in-app viewers (PDF/document/YouTube), with share-out via `Share.shareXFiles` (document_viewer_page.dart:166; pdf_viewer_page.dart:131) |
| 24 | Online Course | CONFIRMED in full (catalogue, detail, curriculum, quiz, course exams, assignments multipart, progress `markascomplete`, reviews, certificate download/delete, paid-course checkout via `api/course_payment/course_payment` → WebView). Plan's endpoint list is accurate; add `getOnlineCourseQuestion` and the path-param certificate calls (§2) |
| 25 | Change Password | **CORRECTED — effectively absent** (§4b): Settings entry is a TODO stub; the real page is unreachable; its endpoint doesn't exist. FORGOT password is the implemented flow (`forgot_password`, auth_api.dart:123) |
| 26 | Change Language | CONFIRMED with mechanism correction: language picker in Settings → `updatestudentlanguage` (settings_page.dart:227; currency_api.dart:116-139). UI translation is **runtime machine translation via the MyMemory API** (`APP/lib/services/translation_service.dart:8` `api.mymemory.translated.net/get`), not bundled locale files; the language list comes from the `/app` config. No RTL-specific code was found |
| 27 | Logout | CONFIRMED local-only: drawer/dashboard `logout` case clears prefs (dashboard_page.dart:387). `auth/logout` exists only as an unused constant (app_config.dart:25); `webservice/logout` never called |
| 28 | Rate App | **CORRECTED — absent.** No rate/store-link code anywhere in `APP/lib` (searches for rate-app and store patterns return only the Zoom/Meet `market://` fallbacks) |
| 29 | Share App | **CORRECTED — absent.** `share_plus` is used only to share downloaded document/PDF **files** (document_viewer_page.dart:166; pdf_viewer_page.dart:131); there is no share-the-app action |
| 30 | About & Privacy Policy | CONFIRMED + URL settled: About uses `getSchoolDetails` (enterprise_api_service.dart:83-85). Privacy Policy is a login-screen link that launches **`<school-base>/privacy-policy/`** in the browser (`APP/lib/screens/login_page.dart:764-768,878-892`) — i.e. for IQRS: `https://iqrs.edu.pk/privacy-policy/` |
| 31 | Offline downloaded content | PARTIAL in legacy: downloads land on-device from the Download Center and open in-app; there is no separate offline-library screen. Roughly what the plan assumed |

### Supplementary list verdicts

| Feature | Verdict |
|---|---|
| Online Examination | CONFIRMED full implementation: `getOnlineExam`, `getOnlineExamQuestion`, `saveOnlineExam` (JSON + multipart-with-attachments variants), `getOnlineExamResult`; screens incl. `exam_taking_page` |
| Daily Assignments | CONFIRMED: `getdailyassignment`, `addeditdailyassignment` (multipart, file `file`), `deletedailyassignment` |
| Calendar To-Do / Tasks | CONFIRMED full CRUD + mark-done (§2) |
| Student Timeline | CONFIRMED full CRUD: `getTimeline`, `addedittimeline` (multipart), `deletetimeline`, `getStudentTimelineStatus` |
| Visitors | CONFIRMED read + **add**: `getVisitors`, `addvisitor` (multipart) — the legacy app lets parents register visitors, more than the plan's "records" framing |
| Behaviour Records | CONFIRMED incl. comment add/delete: `getstudentbehaviour`, `getincidentcomments`, `addincidentcomments`, `deleteincidentcomments` |
| Student documents | CONFIRMED (`getDocument`, `uploadDocument`) |
| Video Tutorials | CONFIRMED (`getVideoTutorial`) |
| Hostel | CONFIRMED **implemented in the legacy app** (`getHostelList` + fallbacks, `hostel_page`) — plan's "skip" is an IQRS-data decision, not a legacy absence |
| Teachers list / rate a teacher | CONFIRMED: `getTeachersList`, `getTeacherSubject`, `getTeacherReviews`, `addStaffRating` |
| Multi-currency | CONFIRMED implemented in legacy (`get_currency_list`, `updatestudentcurrency`) — again an IQRS-scope skip, not a legacy gap |
| Module-status gating | **CORRECTED**: the app **never calls** `getModuleStatus`, `getELearningModuleStatus`, `getAcademicsModuleStatus`, `getCommunicateModuleStatus` or `getOthersModuleStatus` (zero hits for all five). Dashboard sections are hard-coded; tiles are not server-gated in this build |

### Endpoint-set diff (app ↔ backend), explicit

- **App calls that have NO backend method** (would 404 on stock 7.2):
  `changePassword`, `resetPassword`, `updateDeviceToken`,
  `getStudentFromLoginData`, `getStudentList`, `payment/paymentrequest`,
  all `add_fees_deposit`/`feedeposit` variants, and every † fallback
  spelling in §2.
- **Backend methods the app never calls** (selection): `dashboard`,
  `Parent_GetStudentsList`, `getDownloadsLinksById`,
  `getModuleStatus` + the four finer module-status methods,
  `checkProfileUpdate`, `profileUpdateFields`, `getTransportVehicleDetails`,
  `getStudentTransportFeetypeBalance`, `getOfflineBankPaymentStatus`,
  `getOfflineBankPaymentInstruction`, `livehistory`, `getzoomsettings`,
  `gmeethistory`, `getgmeetsettings`, `searchuser`, `addChatUser`,
  `getstudentcurrentlanguage` (the app posts language but never reads it
  back), `logout`, `getOnlineCourseSettings` (course gating endpoint —
  exists in backend, unused by the app).
- Because the two Webservice.php copies are md5-identical (§0.1), this diff
  is simultaneously the diff against the live IQRS API.

---

## 4. The open questions, answered

### 4a. CHAT — not implemented anywhere. Do not promise it as parity.

- **App side**: no chat screen in `APP/lib/screens/` (§1.1 inventory), no
  chat API class in `APP/lib/services/api/`. A case-insensitive search for
  `chat` across `APP/lib` returns only `_fetchAttachments` (substring) and
  one icon, `Icons.chat_bubble_outline`, on the behaviour-comments screen
  (`APP/lib/screens/student_behaviour_page.dart:251`). The strings
  `searchuser`, `addChatUser`, `Chatuser` occur **nowhere** in `APP/lib`.
- **Backend side**: the bundled backend is byte-identical to IQRS (§0.1);
  it routes only `searchuser()` (Webservice.php:2836) and `addChatUser()`
  (:2866). There is no chat controller in
  `API/application/controllers/` (App, Auth, Payment, Payment_request,
  Route, Webhooks, Webservice, Welcome + gateway/course_payment dirs only).
  `Chatuser_model.php` does contain `myChatAndUpdate()` (:84),
  `addMessage()` (:125) and `getUpdatedchat()` (:131) — model methods no
  controller exposes, in the bundled copy exactly as in the IQRS copy
  (same md5).
- The bundled documentation (`documentation/index.html`) contains no chat
  documentation either.
- **Conclusion**: the purchased app (v5.0) simply has no messaging. Any
  chat in our Family app would be net-new work on an additive extension
  endpoint (the plan's fallback route), not a parity item.

### 4b. CHANGE PASSWORD — stub + orphaned page + nonexistent endpoint

Three layers, each independently fatal:
1. **The reachable UI is a stub.** Settings → Change Password opens a
   dialog whose confirm button is literally
   `// TODO: Implement password change API` and shows the snackbar
   "Password change functionality coming soon!"
   (`APP/lib/screens/settings_page.dart:281` `_showChangePasswordDialog`,
   button handler at ~:330).
2. **The real page is unreachable.** `APP/lib/screens/change_password_page.dart`
   exists and its `_changePassword()` (:30) calls
   `ProfileApi.changePassword(...)` (:38) — but `ChangePasswordPage` is
   referenced by **no other file** in `APP/lib` (no route in
   `main.dart:100-113`, no navigation call).
3. **The endpoint doesn't exist.** `ProfileApi.changePassword` POSTs JSON
   `{current_password, new_password, confirm_password}` to
   `api/webservice/changePassword` (`APP/lib/services/api/profile_api.dart:103-118`),
   and `resetPassword` similarly targets `api/webservice/resetPassword`
   (:182-197). Neither `changePassword` nor `resetPassword` (any casing)
   exists in Webservice.php — verified against the identical method sets
   (§0.1). Against a stock Smart School 7.2 install both calls fail.
- What **does** work in the legacy app: **Forgot Password** —
  `forgot_password_page` → `AuthApi.forgotPassword` → POST
  `api/webservice/forgot_password` `{site_url, email, usertype}`
  (auth_api.dart:110-164), an endpoint that exists (Webservice.php
  `forgot_password`). This confirms the plan's interim cover as exactly
  what the legacy app itself ships.

### 4c. NOTIFICATIONS — a list screen exists; its data is the notice board; FCM is real

- Screen + route: `NotificationPage`, route `/notifications`
  (`APP/lib/main.dart:107`; `APP/lib/screens/notification_page.dart:9`).
- Data source: `_loadNotifications()` calls **`ApiService.getNoticeBoard()`**
  (notification_page.dart:27-35) — i.e. the same `getNotifications`-family
  endpoints as the Notice Board screen (common_api.dart:87-92). There is
  **no separate notifications endpoint and no server-side push history**;
  the two screens are two presentations of `send_notification`.
- Push: genuinely implemented — `NotificationService` wires
  `FirebaseMessaging.onMessage` / `onMessageOpenedApp` / background handler
  and `flutter_local_notifications` (`APP/lib/services/notification_service.dart:12-44`);
  token lifecycle in the same file (`registerCurrentToken` :82,
  `_registerToken` :101-144) ending in `NotificationApi.registerDeviceToken`
  → `webservice/updateDeviceToken`† (nonexistent, §3 #5) **and** the login
  body's `deviceToken` field, which is the path the stock backend actually
  stores (`app_key`). A `notification_debug_page` developer screen also
  ships.
- So the plan §6.4 hypothesis ("push history most likely lived on-device")
  is **corrected**: the legacy list screen is server-fed, but from the
  notice board — meaning our existing Notices screen already covers the
  legacy app's notifications content.

### 4d. Subject-wise attendance — absent

No occurrence of "subject" in `APP/lib/services/api/attendance_api.dart` or
`APP/lib/screens/attendance_page.dart`; the only attendance call is
`getAttendenceRecords` {student_id[, month, year]} (attendance_api.dart:30-32,115-130).
The inventory document's "subject attendance" phrase has no counterpart in
this app build or in the backend method set.

---

## 5. What the plan missed entirely

1. **School-URL onboarding + vendor licence verification.** First-run flow
   is a URL entry page (`url_page`, route `/url`) that fetches
   `<base>/app` config and additionally POSTs the school URL to QDOCS'
   licence server `https://sstrace.qdocs.in/postlic/verifyappjsonv2`
   {site_url} (`APP/lib/services/api_service.dart:408-470`); unlicensed
   schools get `school_verification_blocked_page`. (Our apps hard-code
   iqrs.edu.pk instead — a deliberate difference worth keeping, but the
   parity record should note the legacy flow exists.)
2. **The `/app` config endpoint** (`<base>/app`, POST with GET fallback,
   api_service.dart:555-640): school name, logo, theme colours, language
   list, currency, date format, app version — the source of the legacy
   app's per-school branding, backed by `API/application/controllers/App.php:17`.
   Our app hard-codes IQRS branding; the legacy app is multi-school by
   design.
3. **Lesson forum comments** — students comment on lessons:
   `getforummessage` / `saveforummessage` / `deleteforummessage`
   (lesson_api.dart:575-965), duplicated in communication_api.dart as
   `getForumMessage`/`saveComment` candidates.
4. **Course certificates** — download (path-param URL) and delete from the
   course detail screen (course_api.dart:552-607).
5. **A parallel "enterprise" UI + client** for fees and downloads
   (`enterprise_fees_page`, `enterprise_download_center_page`,
   `enterprise_api_service.dart`) — same endpoints, second implementation;
   evidence the vendor ships two generations of UI in one package.
6. **Report Card screen** (`report_card_page.dart`) as a distinct
   presentation over exam results, and a **Notification Debug** developer
   screen (`notification_debug_page.dart`, route `/notification_debug`).
7. **Offline mode service** (`APP/lib/services/offline_mode_service.dart`)
   — connectivity state handling scaffolding (no offline content library;
   cf. #31).

---

## 6. Config facts

- **Base URL / school domain**: user-entered on the URL page, persisted in
  SharedPreferences under key `base_url`
  (`APP/lib/config/app_config.dart` `_baseUrlKey = 'base_url'`;
  `APP/lib/utils/url_manager.dart`). Normalisation strips trailing `/` and
  a trailing `/api`. API root = `<base>/api`; webservice calls =
  `<base>/api/webservice/<name>` (`AppConfig.getApiEndpoint`,
  app_config.dart). `AppConfig.skip`/`skipUrl` exist but ship as
  `skip = 'no'`, `skipUrl = ''` (app_config.dart) — no school is baked in.
- **Client-Service / Auth-Key**: `clientService = 'smartschool'`,
  `authKey = 'schoolAdmin@'` (app_config.dart:9-10) — **identical** to the
  values our apps use. Sent on every call together with `Authorization:
  <raw token>` and `User-ID: <id>` (dynamic_api_headers.dart:28-40); some
  calls also replay a captured session `Cookie`.
- **Device-token registration**: two shapes —
  (1) at login: body field `deviceToken` (login_page.dart:182;
  auth_service.dart:331-339). Its value is `AppConfig.getDeviceToken()`:
  a **locally generated pseudo-token** (`'DT' + timestamp…`,
  app_config.dart `generateDeviceToken`) until the real FCM token is
  stored by `NotificationService._registerToken`
  (notification_service.dart:101-110), after which the FCM token is what
  login sends;
  (2) post-login: POST `webservice/updateDeviceToken` JSON
  `{student_id, device_token, token, platform}` (notification_api.dart:17-31)
  — an endpoint the stock backend does not implement (§4c).
- **Payment mechanics**: fee selection → POST `api/payment/paymentrequest`
  (primary; fees_api.dart `payFees` :174-330) or POST
  `api/payment/fees_pay` {payments:[…]} (`payMultipleFees` :1095-1156) →
  response's `redirect_url` (the code hunts `redirect_url`/`payment_url`/
  `checkout_url` aliases, fees_api.dart:373-460) → **opened in an in-app
  WebView** (`PaymentWebViewPage`, `webview_flutter`,
  `APP/lib/screens/payment_webview_page.dart:5-66`), which watches loaded
  URLs and diverts to `PaymentSuccessPage` when a URL matches its success
  patterns (:69-87). Opened from `fees/widgets/multi_fee_payment_dialog.dart:661`,
  `course_payment_page.dart:551`, `online_course_page.dart:891`.
  **Correction to the plan §3.1**: the legacy app does *not* hand off to a
  browser/Custom Tab — it embeds the hosted checkout in a WebView. (Our
  house rule against WebView still governs our own build; this is a
  record of legacy behaviour.) URL pattern of the checkout itself is the
  backend's: `redirect_url = <site>/payment/pay/<session_id>` from
  `Payment::fees_pay` (Payment.php:365), unchanged.
  Note `api/payment/paymentrequest` has **no corresponding method** in the
  bundled `Payment.php` (whose relevant method is `fees_pay`);
  `Payment_request.php` is a separate web-side controller (`make_request`
  :85) — so on a stock install the app's primary pay call is expected to
  fail over to `fees_pay`.

---

## 7. Net effect on the parity programme

- **Remove from parity scope**: Chat (#22 — never existed), Rate App
  (#28), Share App (#29), Change Password as a legacy behaviour (#25 —
  keep Forgot Password, which Wave A already has), Events/Calendar as a
  *legacy* feature (#16 — build it, if wanted, as new value from the
  dashboard response our app already fetches).
- **Downgrade surprises**: notifications list = notice board (already
  shipped); switch-child needs no extra endpoint (login payload);
  timetable's real endpoint is `class_schedule`.
- **Confirmed as real legacy deltas still to build**: homework submit
  (multipart contract now exact), daily assignments, leave CRUD
  (multipart), offline bank payment submit (multipart, exact fields in
  §2), profile documents + edit (ungated in legacy), syllabus + lesson
  plan (+ forum comments), online exam, tasks write-path, timeline CRUD,
  visitors add, behaviour comments, video tutorials, teachers + ratings,
  library catalogue (already in Wave A), downloads (already in Wave A),
  online course (XL, own milestone), FCM (Wave C config, as planned).
- **Wave C blockers unchanged**: every backend file in the package is
  byte-identical to the live IQRS API, so nothing in this ZIP unblocks
  FCM, gateways, Zoom/Gmeet or the Online Course addon — those remain
  school-side configuration, exactly as the plan states.
