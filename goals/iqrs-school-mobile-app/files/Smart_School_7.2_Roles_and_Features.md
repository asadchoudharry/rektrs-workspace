# Smart School 7.2 – Roles & Complete Feature Inventory

## 1. Built-in login/role structure

- **Super Admin** – unrestricted system-level control.
- **Admin** – general administration based on assigned permissions.
- **Teacher** – academic/teaching functions based on assigned permissions.
- **Accountant** – fees, finance and payroll functions based on assigned permissions.
- **Librarian** – library operations.
- **Receptionist** – front office and enquiry operations.
- **Student portal user** – separate student login; not a staff RBAC role.
- **Parent/Guardian portal user** – separate parent login; not a staff RBAC role.

## 2. Custom roles

Unlimited uniquely named staff roles can be created. Each custom role can be granted **View, Add, Edit and Delete** rights for each available permission item. The standard staff form assigns one role per staff member.

Recommended custom roles: Principal, Vice Principal, Academic Coordinator, Admission Officer, Fee Clerk/Cashier, Finance Manager, HR Manager, Payroll Officer, Examination Controller, Discipline Officer, Transport Manager, Hostel Warden, Storekeeper, IT/System Operator, Auditor/Read Only, Branch Admin, and Management Viewer.

## 3. Core web-system features

The base package contains **30 major permission groups** and **234 permission-controlled functions**.

### Student Information (7)
- Student — rights: View, Add, Edit, Delete
- Import Student — rights: View
- Student Categories — rights: View, Add, Edit, Delete
- Student Houses — rights: View, Add, Edit, Delete
- Disable Student — rights: View
- Student Timeline — rights: View, Add, Edit, Delete
- Disable Reason — rights: View, Add, Edit, Delete

### Fees Collection (12)
- Collect Fees — rights: View, Add, Delete
- Fees Carry Forward — rights: View
- Fees Master — rights: View, Add, Edit, Delete
- Fees Group — rights: View, Add, Edit, Delete
- Fees Group Assign — rights: View
- Fees Type — rights: View, Add, Edit, Delete
- Fees Discount — rights: View, Add, Edit, Delete
- Fees Discount Assign — rights: View
- Search Fees Payment — rights: View
- Search Due Fees — rights: View
- Fees Reminder — rights: View, Edit
- Offline Bank Payments — rights: View

### Income (3)
- Income — rights: View, Add, Edit, Delete
- Income Head — rights: View, Add, Edit, Delete
- Search Income — rights: View

### Expense (3)
- Expense — rights: View, Add, Edit, Delete
- Expense Head — rights: View, Add, Edit, Delete
- Search Expense — rights: View

### Student Attendance (3)
- Student / Period Attendance — rights: View, Add, Edit
- Attendance By Date — rights: View
- Approve Leave — rights: View, Add, Edit, Delete

### Examination (17)
- Marks Grade — rights: View, Add, Edit, Delete
- Exam Group — rights: View, Add, Edit, Delete
- Design Admit Card — rights: View, Add, Edit, Delete
- Print Admit Card — rights: View
- Design Marksheet — rights: View, Add, Edit, Delete
- Print Marksheet — rights: View
- Exam Result — rights: View
- Marks Import — rights: View
- Exam — rights: View, Add, Edit, Delete
- Exam Publish — rights: View
- Link Exam — rights: View, Edit
- Assign / View student — rights: View, Edit
- Exam Subject — rights: View, Edit
- Exam Marks — rights: View, Edit
- Marks Division — rights: View, Add, Edit, Delete
- Exam Schedule — rights: View
- Generate Rank — rights: View

### Academics (8)
- Class Timetable — rights: View, Edit
- Subject — rights: View, Add, Edit, Delete
- Class — rights: View, Add, Edit, Delete
- Section — rights: View, Add, Edit, Delete
- Promote Student — rights: View
- Assign Class Teacher — rights: View, Add, Edit, Delete
- Teachers Timetable — rights: View
- Subject Group — rights: View, Add, Edit, Delete

### Download Center (4)
- Upload Content — rights: View, Add, Delete
- Content Type — rights: View, Add, Edit, Delete
- Content Share List — rights: View, Delete
- Video Tutorial — rights: View, Add, Edit, Delete

### Library (5)
- Books List — rights: View, Add, Edit, Delete
- Issue Return — rights: View
- Add Staff Member — rights: View
- Add Student — rights: View
- Import Book — rights: View

### Inventory (6)
- Issue Item — rights: View, Add, Edit, Delete
- Add Item Stock — rights: View, Add, Edit, Delete
- Add Item — rights: View, Add, Edit, Delete
- Item Store — rights: View, Add, Edit, Delete
- Item Supplier — rights: View, Add, Edit, Delete
- Item Category — rights: View, Add, Edit, Delete

### Transport (7)
- Routes — rights: View, Add, Edit, Delete
- Vehicle — rights: View, Add, Edit, Delete
- Assign Vehicle — rights: View, Add, Edit, Delete
- Fees Master — rights: View, Edit
- Pickup Point — rights: View, Add, Edit, Delete
- Route Pickup Point — rights: View, Add, Edit, Delete
- Student Transport Fees — rights: View, Add, Edit

### Hostel (3)
- Hostel — rights: View, Add, Edit, Delete
- Room Type — rights: View, Add, Edit, Delete
- Hostel Rooms — rights: View, Add, Edit, Delete

### Communicate (8)
- Notice Board — rights: View, Add, Edit, Delete
- Email — rights: View
- Email / SMS Log — rights: View
- SMS — rights: View
- Schedule Email SMS Log — rights: View, Edit
- Login Credentials Send — rights: View
- Email Template — rights: View, Add, Edit, Delete
- SMS Template — rights: View, Add, Edit, Delete

### System Settings (19)
- Languages — rights: Add, Delete
- General Setting — rights: View, Edit
- Session Setting — rights: View, Add, Edit, Delete
- Notification Setting — rights: View, Edit
- SMS Setting — rights: View, Edit
- Email Setting — rights: View, Edit
- Front CMS Setting — rights: View, Edit
- Payment Methods — rights: View, Edit
- User Status — rights: View
- Backup — rights: View, Add, Delete
- Restore — rights: View
- Language Switcher — rights: View
- Custom Fields — rights: View
- System Fields — rights: View
- Print Header Footer — rights: View
- Student Profile Update — rights: View
- Sidebar Menu — rights: View
- Currency — rights: View
- Currency Switcher — rights: View

### Front CMS (7)
- Menus — rights: View, Add, Delete
- Media Manager — rights: View, Add, Delete
- Banner Images — rights: View, Add, Delete
- Pages — rights: View, Add, Edit, Delete
- Gallery — rights: View, Add, Edit, Delete
- Event — rights: View, Add, Edit, Delete
- News — rights: View, Add, Edit, Delete

### Front Office (8)
- Admission Enquiry — rights: View, Add, Edit, Delete
- Follow Up Admission Enquiry — rights: View, Add, Delete
- Visitor Book — rights: View, Add, Edit, Delete
- Phone Call Log — rights: View, Add, Edit, Delete
- Postal Dispatch — rights: View, Add, Edit, Delete
- Postal Receive — rights: View, Add, Edit, Delete
- Complain — rights: View, Add, Edit, Delete
- Setup Front Office — rights: View, Add, Edit, Delete

### Human Resource (12)
- Staff — rights: View, Add, Edit, Delete
- Disable Staff — rights: View
- Staff Attendance — rights: View, Add, Edit
- Staff Payroll — rights: View, Add, Delete
-  Approve Leave Request — rights: View, Edit, Delete
- Apply Leave — rights: View, Add
- Leave Types  — rights: View, Add, Edit, Delete
- Department — rights: View, Add, Edit, Delete
- Designation — rights: View, Add, Edit, Delete
- Can See Other Users Profile — rights: View
- Staff Timeline — rights: View, Add, Edit, Delete
- Teachers Rating — rights: View, Edit, Delete

### Homework (3)
- Homework — rights: View, Add, Edit, Delete
- Homework Evaluation — rights: View, Add
- Daily Assignment — rights: View

### Certificate (6)
- Student Certificate — rights: View, Add, Edit, Delete
- Generate Certificate — rights: View
- Student ID Card — rights: View, Add, Edit, Delete
- Generate ID Card — rights: View
- Staff ID Card — rights: View, Add, Edit, Delete
- Generate Staff ID Card — rights: View

### Calendar To Do List (1)
- Calendar To Do List — rights: View, Add, Edit, Delete

### Dashboard and Widgets (20)
- Quick Session Change — rights: View
- Fees Collection And Expense Monthly Chart — rights: View
- Fees Collection And Expense Yearly Chart — rights: View
- Monthly Fees Collection Widget — rights: View
- Monthly Expense Widget — rights: View
- Student Count Widget — rights: View
- Staff Role Count Widget — rights: View
- Fees Awaiting Payment Widegts — rights: View
- Converted Leads Widegts — rights: View
- Fees Overview Widegts — rights: View
- Enquiry Overview Widegts — rights: View
- Library Overview Widegts — rights: View
- Student Today Attendance Widegts — rights: View
- Income Donut Graph — rights: View
- Expense Donut Graph — rights: View
- Staff Present Today Widegts — rights: View
- Student Present Today Widegts — rights: View
- Student Head Count Widget — rights: View
- Staff Approved Leave Widegts — rights: View
- Student Approved Leave Widegts — rights: View

### Reports (51)
- Student Report — rights: View
- Guardian Report — rights: View
- Student History — rights: View
- Student Login Credential Report — rights: View
- Class Subject Report — rights: View
- Admission Report — rights: View
- Sibling Report — rights: View
- Homework Evaluation Report — rights: View
- Student Profile — rights: View
- Fees Statement — rights: View
- Balance Fees Report — rights: View
- Fees Collection Report — rights: View
- Online Fees Collection Report — rights: View
- Income Report — rights: View
- Expense Report — rights: View
- PayRoll Report — rights: View
- Income Group Report — rights: View
- Expense Group Report — rights: View
- Attendance Report — rights: View
- Staff Attendance Report — rights: View
- Transport Report — rights: View
- Hostel Report — rights: View
- Audit Trail Report — rights: View
- User Log — rights: View
- Book Issue Report — rights: View
- Book Due Report — rights: View
- Book Inventory Report — rights: View
- Stock Report — rights: View
- Add Item Report — rights: View
- Issue Item Report — rights: View
- Student Attendance Type Report — rights: View
- Exam Marks Report — rights: View
- Online Exam Wise Report — rights: View
- Online Exams Report — rights: View
- Online Exams Attempt Report — rights: View
- Online Exams Rank Report — rights: View
- Staff Report — rights: View
- Student / Period Attendance Report — rights: View
- Biometric Attendance Log — rights: View
- Book Issue Return Report — rights: View
- Rank Report — rights: View
- Syllabus Status Report — rights: View
- Teacher Syllabus Status Report — rights: View
- Alumni Report — rights: View
- Student Gender Ratio Report — rights: View
- Student Teacher Ratio Report — rights: View
- Daily Attendance Report — rights: View
- Balance Fees Report With Remark — rights: View
- Balance Fees Statement — rights: View
- Daily Collection Report — rights: View
- Online Admission Report — rights: View

### Online Examination (5)
- Online Examination — rights: View, Add, Edit, Delete
- Question Bank — rights: View, Add, Edit, Delete
- Add Questions in Exam  — rights: View, Edit
- Assign / View Student — rights: View, Edit
- Import Question — rights: View

### Chat (1)
- Chat — rights: View

### Multi Class (1)
- Multi Class Student — rights: View, Add, Edit, Delete

### Online Admission (1)
- Online Admission — rights: View, Edit, Delete

### Alumni (2)
- Manage Alumni — rights: View, Add, Edit, Delete
- Events — rights: View, Add, Edit, Delete

### Lesson Plan (6)
- Manage Lesson Plan — rights: View, Add, Edit
- Manage Syllabus Status — rights: View, Edit
- Lesson — rights: View, Add, Edit, Delete
- Topic — rights: View, Add, Edit, Delete
- Comments — rights: View, Add, Delete
- Copy Old Lessons — rights: View

### Annual Calendar (2)
- Annual Calendar — rights: View, Add, Edit, Delete
- Holiday Type — rights: View, Add, Edit, Delete

### Student CV (3)
- Download CV — rights: View
- Build CV — rights: View, Add, Delete
- Setting — rights: View

## 4. Add-on bundle features

The uploaded bundle contains **10 add-ons** with **76 additional permission items**.

### Smart School Behaviour Records v3.0
Behaviour Records addon adds Behaviour Records module in Smart School. Using this module teacher/staff can create different incidents with positive/negative marks and then assign these incidents on students.
- Behaviour Records Assign Incident
- Behaviour Records Incident
- Student Incident Report
- Student Behaviour Rank Report
- Class Wise Rank Report
- Class Section Wise Rank Report
- House Wise Rank Report
- Incident Wise Report
- Behaviour Records Setting

### Smart School CBSE Examination v3.0
CBSE Examination addon adds CBSE Examination module in Smart School. Using this module teacher/staff can create and print marksheets with advance features.
- CBSE Exam
- CBSE Exam Schedule
- CBSE Exam Assign / View Student
- CBSE Exam Subjects
- CBSE Exam Marks
- CBSE Exam Attendance
- CBSE Exam Teacher Remark
- CBSE Exam Print Marksheet
- CBSE Exam Grade
- CBSE Exam Assign Observation
- CBSE Exam Observation
- CBSE Exam Observation Parameter
- CBSE Exam Assessment
- CBSE Exam Term
- CBSE Exam Template
- CBSE Exam Link Exam
- CBSE Exam Subject Marks Report
- CBSE Exam Template Marks Report
- CBSE Exam Setting
- CBSE Exam Generate Rank

### Smart School Gmeet Live Class v6.0
Gmeet Live Class addon adds Gmeet Live Class module in Smart School. Using this module teacher/staff can create live online classes using http://meet.google.com service. Further students can join these classes.
- Live Classes
- Live Meeting
- Live Meeting Report
- Live Classes Report
- Setting

### Smart School Multi Branch v3.0
Multi Branch addon adds Multi Branch module in Smart School. Using this module Superadmin user can add other any number of schools/branches.
- Overview
- Daily Collection Report
- Payroll Report
- Income Report
- Expense Report
- User Log Report
- Setting

### Smart School Online Course v4.0
Online Course addon adds Online Course module in Smart School. Using this module teacher/staff can create free or paid online course with their study material based on video, audio or in document content format.
- Online Course
- Course Publish
- Course Section
- Course Lesson
- Course Quiz
- Offline Payment
- Student Course Purchase Report
- Course Sell Count Report
- Course Trending Report
- Course Complete Report
- Setting
- Course Rating Report
- Guest Report
- Course Category
- Course Exam Attempt Report
- Course Exam Report
- Course Exam Result Report
- Course Assignment Report
- Course Evalute Assignment
- Course Add Questions in Exam 
- Course Assignment
- Course Exam
- Question Tag
- Question Bank

### Smart School QR Code Attendance v2.0
QR Code Attendance addon adds automated Student/Staff attendance using QR/Barcode module in Smart School. Using this module Student/Staff can submit their attendance by just scanning their ID Card.
- Attendance
- Setting

### Smart School Quick Fees Create v1.0
Quick Fees Create addon adds one click fees create feature in Smart School Fees Collection module. Using this you can create and assign fees on students in just few seconds and all Fees Category, Fees Groups, Fees Masters will be create automatically in your Smart School.
- Quick Fees Create

### Smart School Thermal Print v1.0
Thermal Print addon adds Thermal Printer compatible small size fees receipt print capability in Smart School. Using this module you can utilize modern cost effective fees receipt printing in Smart School.
- Thermal Print

### Smart School Two Factor Authentication v3.0
Two Factor Authentication addon adds Two Factor Authentication module in Smart School. Using this module you can enhance login security of your Smart School users.
- Setting
- Setup 2FA

### Smart School Zoom Live Classes v7.0
Zoom Live Class addon adds Zoom Live Class module in Smart School. Using this module teacher/staff can create live online classes using Zoom.us service. Further students can join these classes.
- Setting
- Live Classes
- Live Meeting
- Live Meeting Report
- Live Classes Report

## 5. Android student/parent app functions

- Student and parent login with child switching
- Dashboard and notifications
- Student profile, personal details, parent details and documents
- Fees, fee details, discounts, multiple payments, online/offline payments
- Attendance and subject attendance
- Class timetable and subject list
- Homework, upload homework, daily assignments and assignment downloads
- Examination schedule, results, report cards and CBSE examination views
- Online examinations, quizzes and results
- Lesson plans, syllabus, lesson/topic progress and video tutorials
- Library books and issued books
- Transport route and hostel details
- Notice board, downloads and shared content
- Leave application, timeline, tasks and visitor information
- Zoom and Google Meet live classes
- Online courses, curriculum, lessons, quizzes, exams, assignments, performance, payment and reviews
- Behaviour records and comments
- Push notifications and password recovery

## 6. Custom Rektrs/Iqra enhancements known in the current project

- Owner-perpetual/local license handling and disabled external vendor validation calls.
- Local add-on activation hotfix for installed QDOCS add-ons.
- Fee Allocation & Discount Matrix: base-fee hierarchy, percentage/fixed/custom discounts, 12-month allocation, native vouchers, Excel/CSV import-export, audit trail and automation.
- Custom Add-on Deployment Manager is part of the approved roadmap; treat it as planned unless verified on the live installation.

## Notes

- Student and Parent are portal account types, while the editable RBAC roles apply to staff.
- Super Admin is a protected system role conceptually and should not be duplicated for routine users.
- Add-on features appear only after the relevant add-on is installed and activated.
- Exact live availability can differ if a module has been disabled from System Settings or has not yet been installed on the deployed site.