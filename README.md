# Room Booking Database Design

Relational database design for an academic room-booking system. The schema supports room reservations, equipment requests and loans, issue reporting, student activities, calendar connections, notifications, and audit history.

This repository documents the database-design contribution to an in-progress system. It contains no production data, credentials, or application source code.

## Contents

- [`docs/room-booking-erd.drawio`](docs/room-booking-erd.drawio) — editable entity-relationship diagram (ERD)
- [`docs/erd/`](docs/erd/) — PNG previews of all 10 ERD pages for quick viewing on GitHub
- [`docs/data-dictionary.md`](docs/data-dictionary.md) — purpose and relationships of the 21 tables
- [`sql/schema.sql`](sql/schema.sql) — PostgreSQL DDL inferred from the ERD

## ERD previews

Open a page below to view its tables and relationships without a draw.io editor:

- [Overview](docs/erd/00-overview.png)
- [Users and students](docs/erd/01-users-and-students.png)
- [Rooms and bookings](docs/erd/02-rooms-and-bookings.png)
- [Equipment requests](docs/erd/03-equipment-requests.png)
- [Equipment loans](docs/erd/04-equipment-loans.png)
- [Issue reporting](docs/erd/05-issue-reporting.png)
- [Activities and participants](docs/erd/06-activities-and-participants.png)
- [Student requirements](docs/erd/07-student-requirements.png)
- [Google Calendar](docs/erd/08-google-calendar.png)
- [Notifications and audit history](docs/erd/09-notifications-and-audit-history.png)

## Design overview

The schema uses UUID primary keys, foreign-key constraints, timestamps, and JSONB fields where flexible structured data is useful. It supports Gmail login, bookings from Monday through Friday between 08:30 and 16:30 with a three-business-day notice rule, a central `ds_calendar` integration, and optional Google Form issue reports.

## Use

The DDL targets PostgreSQL 14+ and can be applied to an empty database:

```bash
psql -d room_booking -f sql/schema.sql
```

The project is a database-design artifact. Application integration, authentication, and production deployment are outside this repository's scope.

## Author contribution

Designed the ERD, relational schema, primary and foreign key relationships, and data dictionary for the room-booking domain.
