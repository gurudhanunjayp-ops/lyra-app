# Lyra – A Fertility Care Companion App

## Project Report

---

## Abstract

Lyra is a cross-platform mobile application that digitises infertility care follow-up: fertility specialists at Saveetha register and manage patients through the complete work-up cycle — history taking, follicular scan reports, hormone panels, semen analysis, cycle tracking, medications and treatment advice — while patients use the same app to view their own reports, advice, medications and cycle information.

Today, infertility work-up data at small clinics lives in paper files and informal phone calls. Scans are reported on paper slips, cycle dates are remembered or noted loosely, and patients have no view into their own records between visits. Lyra replaces that with a structured, role-based workflow:

1. The doctor registers a new patient with detailed gynaecological and obstetric history, then records the spouse's details and semen-analysis results.
2. On each visit, the doctor enters the follicular study report (endometrial thickness, follicular diameter, perifollicular blood flow, RI, PSV), hormone values (FSH, LH, TSH, Prolactin, AMH) and the HSG report, and can attach scan images.
3. The doctor prescribes medications with dosage, route and time, and writes advice the patient can read in the app.
4. The app tracks the patient's menstrual cycle and marks the fertile window for both doctor and patient.
5. The patient logs in to see her own profile, reports, medications, advice and cycle chart, and can reach the clinic on WhatsApp.

An administrator manages doctor accounts.

The app is built with Flutter (Android, Windows and web), a PHP REST backend and a MySQL database, served from the institute server and administered through phpMyAdmin.

**Keywords:** infertility, fertility tracking, follicular monitoring, Flutter, PHP, MySQL, role-based access, cycle tracking, patient records

**Developed by:** [Register no. — Name]

---

## List of Figures

| Figure | Title | Image name | Chapter |
|--------|-------|-----------|---------|
| 5.1 | System architecture of Lyra | Fig_5.1_System_Architecture.png | 5 |
| 5.2 | Database tables in phpMyAdmin | Fig_5.2_DB_Overview.png | 5 |
| 5.3 | Structure of the doctor_profile table | Fig_5.3_doctor_profile.png | 5 |
| 5.4 | Structure of the addpatient table | Fig_5.4_addpatient.png | 5 |
| 5.5 | Structure of the addreport table | Fig_5.5_addreport.png | 5 |
| 5.6 | Structure of the addspouse table | Fig_5.6_addspouse.png | 5 |
| 5.7 | Structure of the medicationdetails table | Fig_5.7_medicationdetails.png | 5 |
| 5.8 | Structure of the uploadimage table | Fig_5.8_uploadimage.png | 5 |
| 6.1 | Splash screen | Fig_6.1_Splash.jpg | 6 |
| 6.2 | Role selection | Fig_6.2_Role_Select.jpg | 6 |
| 6.3 | Doctor login | Fig_6.3_Doctor_Login.jpg | 6 |
| 6.4 | Doctor dashboard | Fig_6.4_Doctor_Dashboard.jpg | 6 |
| 6.5 | Add patient – basic details | Fig_6.5_Add_Patient.jpg | 6 |
| 6.6 | Patient list | Fig_6.6_Patient_List.jpg | 6 |
| 6.7 | Patient detail hub with slide-out menu | Fig_6.7_Patient_Detail.jpg | 6 |
| 6.8 | Scan report entry | Fig_6.8_Add_Report.jpg | 6 |
| 6.9 | Cycle view and fertile window | Fig_6.9_Cycle.jpg | 6 |
| 6.10 | Patient dashboard | Fig_6.10_Patient_Dashboard.jpg | 6 |
| 6.11 | Patient reports view | Fig_6.11_Patient_Reports.jpg | 6 |
| 6.12 | Admin dashboard | Fig_6.12_Admin.jpg | 6 |
| 10.1 | Release APK build output | Fig_10.1_Release_APK.png | 10 |

## List of Tables

| Table | Title | Chapter |
|-------|-------|---------|
| 2.1 | Weaknesses of paper-based infertility follow-up | 2 |
| 2.2 | Users and roles | 2 |
| 2.3 | Comparison of Lyra with existing alternatives | 2 |
| 3.1 | Functional requirements | 3 |
| 3.2 | Non-functional requirements | 3 |
| 3.3 | Hardware and software requirements | 3 |
| 4.1 | Technology stack | 4 |
| 5.1 | Database tables and key fields | 5 |
| 5.2 | PHP REST API endpoints | 5 |
| 6.1 | UX design process followed | 6 |
| 6.2 | Design review findings and changes | 6 |
| 7.1 | Module summary | 7 |
| 8.1 | Project stages | 8 |
| 9.1 | Test strategy | 9 |
| 9.2 | Functional test cases | 9 |
| 9.3 | Defects found | 9 |
| 11.1 | Security threats and controls | 11 |
| 12.1 | Future enhancements | 12 |

---

# Chapter 1 – Introduction

## 1.1 Background

Infertility affects roughly one in six couples of reproductive age worldwide, and in India the demand for fertility treatment is rising faster than the supply of specialists. Effective infertility management is not a single consultation — it is a longitudinal process spread over many cycles: detailed history, serial transvaginal follicular scans, hormone panels (FSH, LH, TSH, Prolactin, AMH), hysterosalpingography (HSG), semen analysis of the partner, timed medications, and cycle-based advice.

Most of this work-up still runs on paper. Scan findings are written on slips, cycle dates are exchanged verbally, and the patient has no consolidated record of her own treatment. The treating doctor flips through a physical file to reconstruct where the patient is in her cycle; the patient depends on memory or phone calls to know her medication schedule and fertile days.

## 1.2 Problem Statement

A fertility clinic managing infertility patients has no structured digital channel that:

* Keeps one patient-wise record covering history, scans, hormones, semen analysis and medications;
* Tracks the menstrual cycle and fertile window for both doctor and patient;
* Lets the patient view her own reports, medication schedule and advice between visits;
* Avoids paper files that are lost, incomplete or unavailable when the patient arrives.

## 1.3 Objectives

1. Let a registered doctor create a complete patient record — personal, gynaecological, obstetric, surgical and lifestyle history — in a guided multi-section form.
2. Record spouse details and semen-analysis parameters against the same patient ID.
3. Enter per-visit follicular study reports and hormone investigations with dated, queryable fields rather than free text.
4. Attach scan images to the patient record and view them in a zoomable viewer.
5. Prescribe medications (drug, dosage, route, time) and write patient-visible advice.
6. Track menstrual cycle dates and compute the cycle day and fertile window for both roles.
7. Give the patient a login with read access to her profile, reports, medications, advice and cycle chart.
8. Restrict access by role (Doctor, Patient, Admin) over a single PHP/MySQL backend.

## 1.4 Scope

* Role-based login: Admin, Doctor, Patient.
* Patient registration (two steps: patient details, spouse details) and specifications editor.
* Follicular study and blood-investigation entry; scan-image upload and viewing.
* Medication prescriptions and dated advice.
* Menstrual cycle tracking with fertile-window display and graphs.
* Doctor profile management and password reset.
* Patient self-service views for reports, advice, medications and cycle.
* Android release build (signed APK); Windows and web builds supported by the same codebase.

---

# Chapter 2 – Gap Analysis, Product Description, Comparison and Uniqueness (GPCU)

## 2.1 Gap Analysis

No lightweight, clinic-owned tool exists that keeps the full infertility work-up — history, serial follicular scans, hormones, semen analysis, cycle dates and medications — in one patient-wise record that both the doctor and the patient can open on a phone.

### 2.1.1 How Infertility Follow-up Runs Today

1. Paper case files and printed scan slips carried by the patient between visits.
2. Verbal or phone communication of cycle dates and medication changes.
3. Standalone period-tracker apps used by the patient that the doctor never sees.

### 2.1.2 Weaknesses of the Existing Method

**Table 2.1: Weaknesses of paper-based infertility follow-up**

| Weakness | Consequence |
|----------|-------------|
| Paper files and slips | Records are lost, illegible or left at home on the visit day |
| No shared cycle tracking | Doctor and patient compute fertile days separately and differently |
| Free-text or verbal medication instructions | Dose and timing errors; no record of what was advised |
| Scan images separated from reports | The picture and the numbers are never seen together |
| Patient blind between visits | She cannot check her own reports, medicines or fertile window |
| No record of advice | No traceable account of what was advised, by whom and when |
| Single-person dependency | The whole record depends on one physical file in one clinic |

## 2.2 Product Description

Lyra is a clinical record and follow-up app, not a diagnostic device. It carries the patient's infertility work-up — structured fields, scan images, cycle dates, medications and advice — between the doctor's clinic and the patient's phone.

### 2.2.1 Users and Roles

**Table 2.2: Users and roles**

| Role | Who | What they do in the app |
|------|-----|------------------------|
| Doctor | Fertility specialist / gynaecologist | Registers patients; records history, spouse details and semen analysis; enters scan reports and blood investigations; uploads scan images; prescribes medications; writes advice; tracks each patient's cycle |
| Patient | Woman under infertility treatment | Views her profile, scan reports, medications, advice and cycle chart; sees cycle day and fertile window; contacts the clinic on WhatsApp |
| Admin | Clinic / app administrator | Logs in, adds and manages doctor accounts, views the doctor list |

### 2.2.2 Core Workflow

1. Admin creates doctor accounts; the doctor logs in.
2. The doctor registers a patient (basic details and medical history), then adds spouse details and semen-analysis values.
3. Each visit, the doctor adds a dated report — follicular measurements and hormone values — and uploads scan images.
4. The doctor prescribes medications and posts advice; both become visible to the patient.
5. Cycle dates are saved per patient; the app shows the current cycle day and fertile window on both dashboards.
6. The patient logs in with her own ID and reviews her reports, medicines, advice and cycle chart.

## 2.3 Comparison

### 2.3.1 Existing Alternatives

**Generic hospital information systems (HIS/EMR)** cover billing, appointments and broad EMR, but do not carry infertility-specific fields such as follicular diameter, perifollicular flow, RI/PSV or AMH, and are far too heavy for a single fertility clinic workflow.

**Consumer period-tracker apps (Flo, Clue, Period Tracker)** give the patient a cycle calendar and fertile-window estimate, but they are patient-only: the doctor cannot see the same cycle state, and they hold no scan reports, medications or advice from the treating doctor.

**WhatsApp / phone follow-up** is free and universal, but keeps no patient-wise structured record, mixes clinical data with personal chats and leaves data on personal phones.

### 2.3.2 Comparison with Existing Alternatives

**Table 2.3: Comparison of Lyra with existing alternatives**

| Criterion | Lyra | Generic HIS/EMR | Period-tracker apps | WhatsApp |
|-----------|------|-----------------|---------------------|----------|
| Infertility-specific fields (follicle, AMH, HSG, semen analysis) | Yes | No | No | No |
| Doctor and patient see the same record | Yes | Partial | No | Partial |
| Cycle tracking with fertile window | Yes | No | Yes | No |
| Scan image attached to the report | Yes | Yes | No | Unstructured |
| Medications and advice pushed to the patient | Yes | Partial | No | Free text only |
| Setup cost for a single clinic | Minimal | High | Free | Free |
| Patient-wise audit trail | Yes | Yes | No | No |

## 2.4 Uniqueness

1. **Infertility-native schema.** The record speaks the language of a fertility work-up — endometrial thickness, follicular diameter, perifollicular rate, RI, PSV, FSH/LH/TSH/Prolactin/AMH, HSG, and WHO semen parameters — not generic notes.
2. **Two sides of one record.** The doctor writes; the patient reads the same reports, medicines, advice and cycle state. The consumer trackers show only half of this.
3. **Cycle-aware.** Cycle dates drive a shared day-counter and fertile-window indicator for both roles.
4. **Couple as one record.** Spouse details and semen analysis live inside the same patient file — matching how infertility is actually evaluated.
5. **Runs on commodity infrastructure.** A PHP + MySQL backend on the institute server; no subscription, no special hardware.
6. **Image + numbers together.** Scan images are filed inside the same dated report as the measurements.

---

# Chapter 3 – Requirements

## 3.1 Functional Requirements

**Table 3.1: Functional requirements**

| ID | Requirement | Role |
|----|-------------|------|
| FR-1 | Role selection screen; separate login for Doctor, Patient and Admin | All |
| FR-2 | Log in with user ID and password against the PHP backend | All |
| FR-3 | Add and list doctor accounts | Admin |
| FR-4 | Register a patient: name, contact, age, gender, height, weight, blood group, occupation, marriage year, BMI, contraceptive history, LMP, menstrual history, flow, consanguinity, coital/obstetric/surgical history, smoking, alcohol | Doctor |
| FR-5 | Record spouse details and semen-analysis values (volume, concentration, total sperm number, motility, progressive motility, morphology, viability) | Doctor |
| FR-6 | Create a dated report: endometrial thickness, follicular diameter, perifollicular rate, RI, PSV, FSH, LH, TSH, Prolactin, AMH, HSG | Doctor |
| FR-7 | Upload scan images to a patient record and view them in a zoomable viewer | Doctor |
| FR-8 | Prescribe medications with drug, dosage, route and time | Doctor |
| FR-9 | Write dated advice entries for a patient | Doctor |
| FR-10 | Save cycle dates; display cycle day and fertile window | System |
| FR-11 | Patient views her profile, reports, medications, advice and cycle chart | Patient |
| FR-12 | Patient reaches the clinic through a WhatsApp deep link | Patient |
| FR-13 | Doctor profile display and edit; doctor and patient password reset | Doctor, Patient |
| FR-14 | List and search patients; open a patient's detail hub | Doctor |
| FR-15 | Cycle graph view for doctor and patient | Doctor, Patient |

## 3.2 Non-Functional Requirements

**Table 3.2: Non-functional requirements**

| Area | Requirement | Target |
|------|-------------|--------|
| Performance | Save a visit report or upload a scan image on 4G | ≤ 10 s |
| Performance | API response for list/detail views | ≤ 2 s |
| Availability | Backend uptime during clinic hours | 99% |
| Security | Role-gated login; server-side validation; no direct DB access from the app | Mandatory |
| Privacy | Clinical data visible only to the treating doctor and that patient | Mandatory |
| Usability | Doctor registers a new patient in one guided flow | Mandatory |
| Usability | Readable on a 5-inch phone; consistent Material design | Mandatory |
| Portability | One Flutter codebase: Android APK, Windows and web | Mandatory |
| Maintainability | Shared UI kit (`app_ui.dart`); one PHP file per endpoint | Mandatory |

## 3.3 Hardware and Software

**Table 3.3: Hardware and software requirements**

| Item | Specification |
|------|---------------|
| Client devices | Android phone (API 21+) with camera; Windows desktop and Chrome for development |
| Development | Flutter SDK 3.44, Dart 3.12, Android Studio / VS Code, Android emulator |
| Server | Institute web server (14.139.187.229:8081) running Apache/PHP; REST API in the `Infertilityapp/` folder |
| Database | MySQL database `infertilityapp` administered through phpMyAdmin |
| Build | Signed release APK via `flutter build apk --release` with the `lyra.jks` keystore |
| Libraries | http, dio, shared_preferences, image_picker, url_launcher, intl, fl_chart, table_calendar |

---

# Chapter 4 – Technology Stack

The app uses one Flutter codebase for all platforms. A PHP backend on the institute server holds all business logic; a MySQL database stores the records.

**Table 4.1: Technology stack**

| Layer | Technology | Role in Lyra | Why chosen |
|-------|-----------|--------------|------------|
| Frontend | Flutter and Dart | All screens for the three roles; camera/gallery upload; zoomable scan viewer; dashboards; cycle ring widget | One codebase for Android, Windows and web; consistent Material 3 UI; fast iteration |
| Backend | PHP on Apache | REST endpoints for authentication, doctors, patients, spouse, medications, reports, images, advice, graph and cycle dates (`comman.dart`) | Runs on the existing institute server with no framework overhead; one file per endpoint |
| Validation | PHP input checks | Each endpoint checks required fields before writing | Rejects malformed requests early |
| Database | MySQL | Thirteen tables (Table 5.1) covering doctors, patients, spouse, reports, medications, advices, cycle and images | Relational, reliable, administered through phpMyAdmin already in use at the institute |
| Images | PHP file upload + `uploadimage` table | Scan files saved on the server; paths stored per patient | Simple storage model; files served back by URL |
| Contact | url_launcher deep link | Patient login screen opens WhatsApp chat with the clinic | No extra backend needed |
| Charts | fl_chart / table_calendar | Cycle graph and calendar views | Mature Flutter charting |
| Android release | Signed APK | `app-release.apk` signed with `lyra.jks` | Direct install and Play-upload ready |

## 4.1 Frontend: Flutter

* Single codebase: Android APK (release-signed), Windows desktop and Chrome web.
* Shared design system in `lib/app_ui.dart`: teal medical palette, gradients, `PageScaffold`, `SectionCard`, `AppTextField`, `AppDropdown`, `YesNoField`, `ListCard`, `FeatureCard`, `GradientIconBadge`, `FadeSlideIn` entrance animations and painted vector backgrounds (waves, hearts, EKG line, medical crosses, dot grid) selected per page.
* ~30 screens under `lib/`, one file per screen; API constants centralised in `lib/comman.dart`.
* All backend calls are HTTP JSON/POST through `http`/`dio`; images picked via `image_picker` and uploaded multipart.

## 4.2 Backend: PHP

* Each endpoint is a separate PHP file under `Infertilityapp/` returning JSON (Table 5.2).
* Login endpoints: `dr_login.php` (doctor and admin share it), `patientlogin.php`.
* Image endpoints: `uploadimg.php` stores a scan file; `viewimg.php` returns the patient's image list.
* Cycle endpoints: `save_date.php`, `fetchdate.php`, `save_period_date.php`, `fetch_period_date.php`.

## 4.3 Database: MySQL

* Thirteen tables (Table 5.1); patients keyed by `Userid`, doctors by `dr_userid`.
* Scan image files are stored on the server; `uploadimage` holds the path and date per `Userid`.
* `cycleupdate` stores each patient's saved date, computed day, and fertile-window bounds (`fertileStart`, `fertileEnd`).

---

# Chapter 5 – System Architecture and Design

Lyra uses a three-tier client–server design. The Flutter app never talks to the database directly; every request goes through the PHP REST API, which is the only component that reads or writes MySQL.

```
Flutter app (Doctor / Patient / Admin)
        │  HTTP POST/GET (JSON)
        ▼
PHP REST API  ── Infertilityapp/*.php
        │
        ▼
MySQL database: infertilityapp  (13 tables)
        │
        └── scan image files on server (uploadimage paths)
```

**Figure 5.1: System architecture of Lyra**

## 5.1 Database Design

The backend stores its data in the MySQL database `infertilityapp`, in thirteen tables administered through phpMyAdmin. The dump ships with the project (`infertilityapp.sql`).

**Table 5.1: Database tables and key fields**

| Table | Key fields | Purpose |
|-------|-----------|---------|
| doctor_profile | dr_userid, dr_name, email, password, designation, contact_no, doctorimage | Doctor accounts; also used for admin login |
| addpatient | Userid, Name, ContactNo, Age, Gender, Height, Weight, Marriageyear, Bloodgroup, Medicalhistory, Specifications, password, image, occupation, BMI, contraceptive_history, last_menstrual_period, menstrual_history, flow, consanguineous, coital_history, obstetric_history, surgical_history, smoking, alcohol | One row per patient: identity + full infertility history |
| addspouse | id, Userid, Name, Contactnumber, occupation, Age, significanthistory, smoking, alcohol, sexualdisfunction, Volume, Concentration, Total_sperm_number, Motility, Progressive_Motility, Morphology, Viability | Spouse identity + WHO semen-analysis parameters |
| addreport | id, Userid, date, endometrium_thickness, follicular_diameter, perifollicular_rate, RI, PSV, FSH, LH, TSH, Prolactin, AMH, HSG_report | One dated follicular-study + hormone report per visit |
| medicationdetails | id, Userid, Medication, Time, Dosage, Route, date | Prescriptions per patient |
| advices | id, Userid, Date, Addadvices | Dated advice entries shown to the patient |
| uploadimage | id, Userid, image, date | Scan image file paths per patient |
| cycleupdate | id, userid, date, days, fertileStart, fertileEnd | Saved cycle entry with computed day and fertile window |
| cycleupdate2 | userid, date | Secondary cycle-date store |
| datep | id, userid, datep | Period dates |
| degignation | id, role, did | Role/designation lookup |
| signup | id, role, Userid, Password, FirstName, Email, PhoneNumber, specification | Sign-up staging table |
| update | id, Userid, Date | Update markers per patient |

Figures 5.3–5.8 show the structure of the main tables in phpMyAdmin.

## 5.2 REST API (PHP Endpoints)

All endpoints live under `http://14.139.187.229:8081/Infertilityapp/` and are centralised in `lib/comman.dart`.

**Table 5.2: PHP REST API endpoints**

| Endpoint | Purpose | Role |
|----------|---------|------|
| dr_login.php | Doctor and admin login | Public |
| patientlogin.php | Patient login | Public |
| passdoc.php / password.php | Doctor / patient password reset | Public |
| adddocterid.php, adddoctor.php, doctorlist.php | Generate doctor ID; add and list doctors | Admin |
| dr_profile.php, dr_profiledisplay.php, dr_profileupdate.php | Doctor profile create/view/edit | Doctor |
| patientid.php | Next patient ID | Doctor |
| addpatient.php | Register patient (history fields) | Doctor |
| addspouse.php, viewspousedetails.php | Add/view spouse + semen analysis | Doctor |
| patientlist.php, viewpatientdetails.php, viewmedicaldetails.php | Patient list and detail views | Doctor |
| medications.php | Add medication entry | Doctor |
| addreports.php, viewreports.php | Add a dated report; view report status | Doctor |
| uploadimg.php, viewimg.php | Upload and list scan images | Doctor, Patient |
| viewadvices.php | Write/read advice entries | Doctor, Patient |
| graph.php | Cycle/graph data for charts | Doctor, Patient |
| save_date.php, fetchdate.php | Save/read cycle dates | Doctor, Patient |
| save_period_date.php, fetch_period_date.php | Period-date tracking | Patient |

---

# Chapter 6 – User Experience Design

The app is used by a doctor moving quickly between patients and by patients who are often anxious and non-technical. The design goal: clinical density for the doctor, calm clarity for the patient.

## 6.1 UX Process Followed

**Table 6.1: UX design process followed**

| Stage | UX activity | Output |
|-------|-------------|--------|
| 1. Research | Review of the paper-based infertility follow-up flow; competitor review (period trackers, EMR screens) | Pain points; role list |
| 2. Define | Personas; per-role task flows | Three role dashboards and navigation |
| 3. Low fidelity | Screen sketches for registration, reports and cycle | Wireframe sheets |
| 4. High fidelity | Modern teal medical theme; shared component kit | `app_ui.dart` design system |
| 5. Evaluate | Design review; user feedback ("old-looking" UI rejected) | Redesign to modern teal, iconography, animations |
| 6. Build and release | Flutter implementation across all screens | Signed release APK |

## 6.2 Design Principles Applied

1. **One shared design system.** Colours, fields, cards, buttons and animations are defined once in `app_ui.dart` and reused by every screen, so no page drifts out of style.
2. **Icon-based visuals, no clip-art.** Every screen uses Material icons in gradient badges; painted medical-vector backgrounds (waves, EKG line, crosses, dots, hearts) replace dated images.
3. **Sectioned long forms.** The ~25-field patient registration is split into Basic Details / Medical History / Spouse cards with dropdowns and yes-no chips instead of a wall of text boxes.
4. **The cycle is the hero.** The patient dashboard leads with a teal ring showing the cycle day and fertile window.
5. **Calm failure.** Empty and failed responses show designed empty/error states — never a crash or a raw error.
6. **Motion with restraint.** Cards and badges animate in with staggered fade/slide; backgrounds carry subtle painted decoration per page type.

## 6.3 Design Review Findings and Changes

**Table 6.2: Design review findings and changes**

| # | Finding | Change | Status |
|---|---------|--------|--------|
| 1 | Original pink palette and clip-art looked dated | Rebuilt theme on teal `#0D9488`→mint gradients; removed all clip-art | Fixed |
| 2 | Inner pages still showed the old basic UI after entry screens were modernised | All ~26 reachable screens rewritten on the shared kit | Fixed |
| 3 | `CircleAvatar` crashed when a patient had no image | Avatar renders image only when a URL exists; icon fallback otherwise | Fixed |
| 4 | Backend `status:false` responses crashed report/advice lists | Type-checked parsing with empty/error states | Fixed |
| 5 | Response shapes varied (list vs map) | Safe map conversion guards on profile/patient/spouse fetches | Fixed |

## 6.4 Screens

* **Splash** — animated teal heart mark on a gradient.
* **Role selection** — gradient welcome banner; Doctor/Patient cards.
* **Login** — frosted card, gradient button, loading state; patient login keeps the WhatsApp deep link.
* **Doctor dashboard** — patient-care banner, action tiles (Patients, Add Patient, Profile, Logout).
* **Add patient** — photo picker, Basic Details and Medical History section cards.
* **Patient hub** — avatar header, sectioned details, slide-out icon menu (Reports, Medications, Advice, Graph, Cycle, Spouse, Semen analysis).
* **Patient dashboard** — cycle-day ring, fertile-window chip, Reports/Advice/Graphs/Medications grid.
* **Admin** — add-doctor form and doctor list with search.

---

# Chapter 7 – Implementation

The app is implemented as three role modules on one Flutter codebase, backed by per-endpoint PHP files.

## 7.1 Project Structure

```
infertilityapp/                     # Flutter
 lib/
   app_ui.dart          shared design system (theme, widgets, backgrounds, animations)
   comman.dart          all API endpoint URLs
   main.dart            splash → role selection
   second_page.dart     role select
   third_page.dart      doctor login       fourth_page.dart   patient login
   admin.dart/alogin.dart/adddoctor.dart/viewdoctor.dart   admin flow
   fifth_page.dart      doctor dashboard  sixth_page.dart    doctor profile
   seventh/eight/ninth  patient registration (details, spouse, specifications)
   eleventh_page.dart   patient list      twelfth_page.dart  patient detail hub
   addreports/reports/addpreports/viewstatus   scan reports
   medications.dart / advice.dart / viewadvice2.dart       prescriptions & advice
   graph.dart / cycle.dart / results.dart                  cycle & charts
   spouse.dart / semenanalysis.dart                        couple record
   plogin/pprofile/preports/padvice/pgraph/pmedication     patient-side screens
   tenth_page.dart, forgot_password_page.dart, doctor_forgot_pass.dart
```

## 7.2 Module Summary

**Table 7.1: Module summary**

| Module | Frontend | Backend | Key rule |
|--------|----------|---------|----------|
| Authentication | Role select; doctor/patient/admin login; forgot-password | dr_login.php, patientlogin.php, passdoc.php, password.php | Separate login endpoints per role |
| Doctor administration | Add-doctor form, doctor list with search | adddocterid.php, adddoctor.php, doctorlist.php | Doctor accounts created by admin |
| Patient registration | Two-step form + specifications | patientid.php, addpatient.php, addspecifications.php | Full infertility history captured at intake |
| Couple record | Spouse form + semen analysis | addspouse.php, viewspousedetails.php | Semen parameters stored on the patient ID |
| Visit reports | Sectioned report form; scan upload + zoom viewer | addreports.php, viewreports.php, uploadimg.php, viewimg.php | One dated report per visit |
| Medications & advice | Prescription form; advice editor and lists | medications.php, viewadvices.php | Advice is patient-visible |
| Cycle tracking | Date saving, cycle ring, fertile window, graph | save_date.php, fetchdate.php, save_period_date.php, fetch_period_date.php, graph.php | Day and fertile window computed per patient |
| Patient self-service | Patient dashboard, profile, reports, advice, medications, graph | same read endpoints | Patient reads only her own Userid data |

---

# Chapter 8 – Project Management

## 8.1 Project Stages

**Table 8.1: Project stages**

| Stage | Deliverable |
|-------|-------------|
| 1 | Gap analysis, product definition, comparison |
| 2 | Screen design and data-model mapping to the SQL dump |
| 3 | UI design system (teal theme, shared widgets) |
| 4 | Screen implementation across all roles |
| 5 | Backend integration; runtime defect fixing |
| 6 | Signed release APK; emulator/device verification |
| 7 | [Symposium / review] |
| 8 | [Incubation / pitch] |

## 8.2 Tools

* **Version control:** Git in the project folder.
* **Design system:** code-first in `app_ui.dart` (single source of truth).
* **API contract:** `lib/comman.dart` endpoint list shared by all screens.
* **Build:** `flutter build apk --release`, signed by `lyra.jks` (alias `lyra`).
* **Verification:** `flutter analyze`, Windows run, Android release build.

---

# Chapter 9 – Testing and Validation

## 9.1 Test Strategy

**Table 9.1: Test strategy**

| Level | Tool | Scope |
|-------|------|-------|
| Static | `flutter analyze` | All rewritten screens — 0 errors |
| Build | `flutter build apk --release` | Signed release APK produced |
| Runtime | `flutter run -d windows` + log inspection | Navigation, backend calls, exception tracing |
| Integration | Live API at 14.139.187.229:8081 | Login, registration, patient fetch, reports, advice |
| Device | Android emulator (HostelHub AVD, Android 9) | Emulator provisioning |

## 9.2 Functional Test Cases

**Table 9.2: Functional test cases**

| ID | Test case | Expected | Result |
|----|-----------|----------|--------|
| TC-01 | Splash → role selection navigation | Auto-advances after ~3 s | Pass |
| TC-02 | Doctor login (valid ID) | Lands on doctor dashboard | Pass* |
| TC-03 | Patient login (valid ID) | Lands on patient dashboard with cycle card | Pass* |
| TC-04 | Register new patient | New Userid returned (e.g. 457, 458 observed) | Pass |
| TC-05 | Add spouse / select medication route | Saved; route logged | Pass |
| TC-06 | Open reports for patient with no data | Shows designed empty state, not a crash | Pass |
| TC-07 | Open advice list with no entries | Empty state; no null-iterable crash | Pass |
| TC-08 | Patient detail with missing image | Icon fallback, no CircleAvatar assert | Pass |
| TC-09 | Backend returns list where map expected | Handled gracefully, no cast exception | Pass |
| TC-10 | Release build | Signed APK generated (66.9 MB) | Pass |

\* *Login passes when the live server database contains matching accounts; test IDs verified against the SQL dump (Doctor 1920/20, Patient 361/gayu).*

## 9.3 Defects Found and Fixed

**Table 9.3: Defects found**

| Defect | Severity | Status |
|--------|----------|--------|
| `win32` transitive dep broke Windows build on Dart 3.12 | Blocker | Fixed — upgraded path_provider_windows |
| CircleAvatar assertion with null backgroundImage | High | Fixed |
| `List→Map` cast crash on patient/doctor/spouse fetches | High | Fixed — type-checked parsing |
| Null `images`/`viewadvices` crash on empty reports/advice | High | Fixed — guarded parsing + empty states |
| Gradle/AGP/Kotlin too old for current Flutter SDK | Blocker | Fixed — Gradle 9.1, AGP 9.0.1, Kotlin 2.3.20 |
| Old plugins using removed v1 embedding (image_picker, path_provider, shared_preferences, url_launcher, plugin lifecycle) | Blocker | Fixed — dependency_overrides to v2-embedding versions |
| Manifest `package=` rejected by AGP 9 | Medium | Fixed — removed attribute |

---

# Chapter 10 – Deployment

## 10.1 Backend

* PHP API served from `http://14.139.187.229:8081/Infertilityapp/` on the institute server.
* MySQL database `infertilityapp` (13 tables) on the same server, administered via phpMyAdmin; schema shipped as `infertilityapp.sql`.
* Scan images stored as files on the server, referenced in `uploadimage`.

## 10.2 Android Release

1. Signing configured in `android/app/build.gradle` and `android/key.properties` using `lyra.jks` (alias `lyra`).
2. `flutter build apk --release` → **`build/app/outputs/flutter-apk/app-release.apk` (66.9 MB)**, verified with `apksigner` (SHA-256 `24:25:5F:90:93:4F:8E:DF…`).
3. Package `com.simats.Lyra`, label "Lyra", versionName 1.0.0, versionCode 2, minSdk 21, targetSdk 34.
4. For Google Play: switch to `flutter build appbundle --release` and upload the AAB through Play Console.

## 10.3 Other Targets

* Windows desktop build verified (`infertilityapp.exe`).
* Web build available via `flutter build web`.
* Backend must be reachable (HTTP, port 8081) for login and all data screens.

---

# Chapter 11 – Security, Privacy and Clinical Responsibility

Patient fertility records are sensitive health data. The app limits who can join and what each role can see.

## 11.1 Security Controls

**Table 11.1: Security threats and controls**

| Threat | Control |
|--------|---------|
| Unauthorised access | Role-gated logins; doctor accounts created only by admin |
| Data intercepted in transit | *[Backend currently uses HTTP on port 8081 — move to HTTPS before wide release]* |
| A patient seeing another patient's data | Patient-side screens request only the logged-in Userid's records |
| Weak stored passwords | *[Passwords are currently stored/compared in plaintext in the dump — migrate to hashed passwords]* |
| Image links shared outside the app | Scan images served from the server path; add authentication on image endpoints before release |

## 11.2 Privacy

* **Data minimisation:** clinical fields only; no national-ID or address fields are required.
* **Role separation:** patients get read-only views of their own record; write access is doctor/admin only.

## 11.3 Clinical Responsibility

* Lyra is a record-keeping and follow-up tool. It does not diagnose infertility or make treatment decisions.
* Medication and advice shown in the app reflect what the treating doctor entered; the doctor remains responsible for clinical decisions.
* The fertile-window display is an estimate from recorded cycle dates and must not be the sole basis for clinical timing.

---

# Chapter 12 – Limitations, Future Work and Conclusion

## 12.1 Limitations

1. Traffic is plain HTTP on the institute server — no TLS yet.
2. Passwords in the existing data are stored in plaintext.
3. No push notifications — patients must open the app to see new advice.
4. Image access is not token-gated on the backend.
5. Dead legacy screens (`periodtracker.dart`, `pcycle.dart`, `thirteenth_page.dart`, `pplogin.dart`) remain in the codebase unreachable from navigation.

## 12.2 Future Enhancements

**Table 12.1: Future enhancements**

| Enhancement | Benefit |
|-------------|---------|
| HTTPS + hashed passwords (bcrypt) | Production-grade security |
| Firebase push notifications | Patient alerted on new report/advice |
| Appointment scheduling | Clinic visits booked in-app |
| PDF visit summary / report download | Patient keeps a portable record |
| Cycle predictions from history | More accurate fertile windows |
| Tamil + regional-language UI | Wider patient reach |
| Lab-report OCR on scan upload | Faster data entry |

## 12.3 Conclusion

Lyra turns the paper file-and-phone-call model of infertility follow-up into a structured, two-sided digital record. The doctor enters the work-up — history, scans, hormones, semen analysis, medications, advice — once, and the patient sees the same record on her phone, anchored by a shared cycle tracker.

The project delivered:

* a working Flutter app for three roles with a consistent modern design system;
* a PHP + MySQL backend with 13-table schema covering the full infertility work-up;
* a signed Android release APK verified end-to-end.

---

## References

1. WHO, "Infertility Prevalence Estimates, 1990–2021".
2. WHO Laboratory Manual for the Examination and Processing of Human Semen, 6th ed.
3. Government of India, Digital Personal Data Protection Act, 2023.
4. Board of Governors, Medical Council of India, Telemedicine Practice Guidelines, 2020.
5. Flutter documentation (flutter.dev); PHP documentation (php.net); MySQL documentation (dev.mysql.com/doc).
6. Material Design 3 guidelines (m3.material.io).
7. W3C, Web Content Accessibility Guidelines (WCAG) 2.2.

## Course Context

*This project was carried out as the course project of Product Design and Development (PDD). Fill in course code, programme, semester, credits, coordinator and course-outcome mapping as per the syllabus (mirroring the reference report's Tables C.1–C.4).*
