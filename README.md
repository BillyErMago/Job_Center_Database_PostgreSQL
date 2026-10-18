<div align="center">

# 🏛️ Job Center Database Management System

**An enterprise-grade Relational Database engineering project modeling an Employment Agency, featuring formal E-R design, mathematical I/O access cost optimization, and advanced PostgreSQL / PL-pgSQL stored procedures.**

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![PL/pgSQL](https://img.shields.io/badge/PL%2FpgSQL-Procedural_SQL-blue?style=for-the-badge)
![Database Design](https://img.shields.io/badge/Methodology-Batini--Ceri--Navathe-orange?style=for-the-badge)
![Academic Context](https://img.shields.io/badge/University-UniPG-red?style=for-the-badge)

</div>

---

## 📌 Project Overview

This project provides a comprehensive database management solution for a regional **Employment Agency (*Centro per l'Impiego*)** in Perugia. The system coordinates the complex workflows between:
- **Citizens:** Tracking demographics, educational degrees, language certifications, and prior employment histories (separating first-time job seekers from the unemployed).
- **Companies:** Managing corporate profiles, workforce sizes, and immediate hiring requests (**DIA** - *Dichiarazione Immediata Assunzione*).
- **Agency Branches & Personnel:** Office hierarchies, employee shifts, and branch director allocations.
- **Services & Training Programs:** Availability declarations (**DID** - *Dichiarazione di Immediata Disponibilità*) and accredited external professional training courses.

Developed for the **Databases** course (BSc in Computer & Electronics Engineering, University of Perugia), the project rigorously follows the classic engineering lifecycle: **Conceptual Design ➔ Logical Optimization ➔ Relational Normalization ➔ Physical DBMS Implementation**.

---

## 📐 Engineering Lifecycle & Methodology

```
 [ Requirements & Glossary ]
             │
             ▼
 1. Conceptual Design (E-R)     ──► 8-level incremental E-R schema + business constraints
             │
             ▼
 2. Logical Optimization        ──► Volume tables, operation load tables & redundancy cost study
             │
             ▼
 3. Relational Mapping          ──► 3NF translation, foreign key cascades, domain integrity
             │
             ▼
 4. Physical Implementation     ──► PostgreSQL DDL, PL/pgSQL procedures, views & analytical queries
```

---

## ⚡ Logical Optimization & Redundancy Cost Analysis

A central highlight of this project is the **formal mathematical analysis of I/O access costs** evaluating the trade-off between strict normalization and performance-driven redundancy:

- **The Problem:** Whether to dynamically calculate each branch's workforce by querying staff records or maintain a redundant counter (`N_dipendenti`) directly on the `UFFICIO` table.
- **Workload Evaluation:** Based on operational frequencies ($OP_4$ and $OP_{13}$ at 1/year vs. $OP_{16}$ reading office sizes 960 times/year, with a write cost weighted at $2 \times \text{read}$):
  - **With Redundancy:** $\approx 86,400$ total annual read accesses.
  - **Without Redundancy (Dynamic Joins):** $\approx 230,400$ total annual read accesses.
- **Result:** Keeping the redundant counter yielded a **~62% reduction in database I/O overhead**, mathematically justifying denormalization in high-read workloads.

---

## 🛠️ PostgreSQL & PL/pgSQL Architecture

The schema implements 29 distinct operations ($OP_1$ to $OP_{29}$) supported by custom constraints and procedural routines:

### 🛡️ Domain & Temporal Integrity Constraints
- **Citizen Age Verification:** Custom interval checking ensuring enrolled citizens are between 18 and 65 years old using a multi-unit `datediff()` function.
- **Workflow Auditing:** CHECK constraints guaranteeing chronological integrity (`DataFine > DataInizio`, `DataStipula <= CURRENT_DATE`, `OraFineTurno > OraInizioTurno`).
- **Office Naming Conventions:** Pattern matching constraints enforcing specific branch responsibilities (`LIKE 'Assunzione%'`).

### ⚙️ PL/pgSQL Stored Procedures
- `aggufficio(nomeuff, capouff)`: Transactionally initializes new offices, checks director eligibility, and reallocates department headcounts.
- `aggpersonale(...)`: Adds staff members and atomically increments branch personnel statistics.
- `eliminapersonale(mat)`: Safely removes an employee and decrements office counters.
- `datediff(date_part, start_t, end_t)`: Generic date-part difference function across dynamic units (years, months, weeks, days, hours, minutes, seconds).

### 📊 Analytical Views & Advanced Queries
- `v1`: Tracks citizen engagement frequency within specific fiscal years.
- `v2` & `stipendio_erogato_ufficio`: Aggregates and calculates department-level payroll expenditures to determine the most cost-efficient branch offices.
- **Complex Subqueries:** Queries leveraging nested aggregations (`HAVING COUNT(*) >= ALL(...)`), outer joins, and grouping.

---

## 📁 Repository Structure

```text
├── docs/
│   └── Relazione_Basi_di_Dati.pdf    # Complete academic documentation and technical report
├── sql/
│   ├── 01_schema.sql                 # DDL: Tables, PRIMARY KEYs, FOREIGN KEYs, CHECKs, datediff()
│   ├── 02_functions.sql              # PL/pgSQL Stored Procedures (aggufficio, aggpersonale, etc.)
│   └── 03_queries.sql                # DML: Insert scripts, Views, and OP1-OP29 operations
└── README.md
```

---

## 🚀 Deployment & Local Execution

### Prerequisites
- [PostgreSQL 12+](https://www.postgresql.org/download/) installed.

### Setup via `psql` CLI

```bash
# 1. Clone the repository
git clone https://github.com/BillyErMago/Job_Center_Database_PostgreSQL.git
cd Job_Center_Database_PostgreSQL

# 2. Create the target database
createdb centro_impiego -U postgres

# 3. Execute the schema (DDL & table constraints)
psql -U postgres -d centro_impiego -f sql/01_schema.sql

# 4. Load the procedural functions (PL/pgSQL)
psql -U postgres -d centro_impiego -f sql/02_functions.sql

# 5. Run test operations, views, and analytical queries
psql -U postgres -d centro_impiego -f sql/03_queries.sql
```

---

## 👥 Authors & Academic Context

- **Billal Nadi** - [BillyErMago](https://github.com/BillyErMago)
- **Piercarmine De Marco**
- **Redon Karakaci**
