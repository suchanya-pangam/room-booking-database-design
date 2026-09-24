# Room Booking Database Design

Relational database design for an academic room-booking system. The schema supports room reservations, equipment requests and loans, issue reporting, student activities, calendar connections, notifications, and audit history.

This repository documents the database-design contribution to an in-progress system. It contains no production data, credentials, or application source code.

## Contents

- [`docs/room-booking-erd.drawio`](docs/room-booking-erd.drawio) — editable entity-relationship diagram (ERD)
- [`docs/erd/`](docs/erd/) — PNG previews of all 10 ERD pages for quick viewing on GitHub
- [`docs/data-dictionary.md`](docs/data-dictionary.md) — earlier design reference; pending alignment with the current application model
- [`sql/schema.sql`](sql/schema.sql) — earlier PostgreSQL design reference; pending alignment with the current application model

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

The ERD reflects the current data model in `datasciroombooking/src/lib/types.ts`: 18 planned tables for the in-memory prototype, including users, locations, bookable units, bookings, equipment, issues, approvals, audit logs, and notifications. Embedded arrays are labelled as JSON/embedded fields.

## Use

The DDL targets PostgreSQL 14+ and can be applied to an empty database:

```bash
psql -d room_booking -f sql/schema.sql
```

The project is a database-design artifact. Application integration, authentication, and production deployment are outside this repository's scope.

## Author contribution

Designed the ERD, relational schema, primary and foreign key relationships, and data dictionary for the room-booking domain.
