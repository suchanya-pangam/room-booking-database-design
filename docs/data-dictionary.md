# Data Dictionary

This dictionary describes the 21 tables in the Room Booking Database Design. Column types and constraints are defined in [`../sql/schema.sql`](../sql/schema.sql).

| Table | Purpose | Key relationships |
| --- | --- | --- |
| `users` | Stores Gmail login accounts, contact details, user type, role, and account status. | Referenced by bookings, approvals, activities, issues, notifications, and audit logs. |
| `student_profiles` | Stores student-specific academic details. | One-to-one with `users`. |
| `login_challenges` | Stores hashed one-time login challenges and their lifecycle. | Many-to-one with `users`. |
| `rooms` | Stores room identity, capacity, and the booking policy: Monday-Friday, 08:30-16:30, with at least 3 business days' notice. | Referenced by bookings, equipment items, and issue reports. |
| `bookings` | Stores room-reservation requests, schedule, purpose, and status. | Many-to-one with `users` and `rooms`; referenced by decisions, equipment requests, and activities. |
| `booking_decisions` | Records approval or rejection decisions for reservations. | Many-to-one with `bookings` and `users`. |
| `equipment_types` | Defines reusable equipment categories. | Referenced by equipment items and booking equipment requests. |
| `equipment_items` | Stores individual equipment assets and their home rooms. | Many-to-one with `equipment_types` and optionally `rooms`. |
| `booking_equipment_requests` | Captures equipment quantities requested for a booking. | Many-to-one with `bookings` and `equipment_types`. |
| `equipment_loans` | Tracks issue and return events for individual equipment items. | Connects an equipment request to an `equipment_items` record and staff users. |
| `issue_reports` | Records room or equipment problems reported by users or through a Google Form. | References a room, optionally an equipment item, and a reporting user; stores the external Form response ID when applicable. |
| `issue_attachments` | Stores metadata for files attached to an issue report. | Many-to-one with `issue_reports` and `users`. |
| `issue_status_history` | Preserves the status-change history of an issue. | Many-to-one with `issue_reports` and `users`. |
| `activity_requirements` | Defines activities or requirements students may need to complete. | Referenced by activities and student requirement records. |
| `activities` | Stores scheduled activity sessions and optional room bookings. | References a requirement, a creator, and optionally a booking. |
| `activity_participants` | Records attendance and results for each participant in an activity. | Connects `activities` and `users`; referenced by calendar links. |
| `student_requirements` | Tracks a student's completion status for each activity requirement. | Connects `users`, `activity_requirements`, and optionally `activity_participants`. |
| `calendar_connections` | Stores metadata and credential references for the central `ds_calendar@gmail.com` account. | Referenced by calendar event links. |
| `calendar_event_links` | Maps a room booking to a synchronized calendar event. | References `bookings` and `calendar_connections`. |
| `notification_deliveries` | Tracks scheduled and sent notifications. | References a user and optionally an activity. |
| `audit_logs` | Provides an immutable-style record of data-changing actions. | References the user who performed the action. |

## Relationship rules

- A booking belongs to one room and one requesting user; a cancelled booking may also reference the user who cancelled it.
- A booking can have multiple approval decisions and equipment requests.
- Equipment loans allocate individual equipment items to an equipment request, allowing item-level return tracking.
- An issue can concern either a room, a specific equipment item, or both.
- `student_profiles` uses `user_id` as both its primary key and foreign key, enforcing one profile per user.
- `student_requirements` is unique per student and activity requirement; `activity_participants` is unique per activity and user.
