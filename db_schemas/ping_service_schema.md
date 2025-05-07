# Ping Service Database Schema (SQLite)

This schema defines the structure for a service that tracks daily changes to specified URLs and notifies users via email.

## Tables

We'll use three main tables:

1.  `users`: Stores user information (primarily their email).
2.  `tracked_urls`: Stores the URLs being tracked, linking them to users and keeping track of the last known state.
3.  `url_history`: Logs each check performed on a URL, noting if a change was detected.

---

### 1. `users` Table

Stores information about the users who want to track URLs.

| Column        | Data Type     | Constraints                               | Description                                   |
|---------------|---------------|-------------------------------------------|-----------------------------------------------|
| `id`          | `INTEGER`     | `PRIMARY KEY AUTOINCREMENT`               | Unique identifier for the user.               |
| `email`       | `TEXT`        | `NOT NULL UNIQUE`                         | User's email address.                         |
| `created_at`  | `TIMESTAMP`   | `NOT NULL DEFAULT CURRENT_TIMESTAMP`      | Timestamp of when the user was added.         |

**Example:**

| id  | email             | created_at          |
|-----|-------------------|---------------------|
| 1   | user@example.com  | 2024-05-07 10:00:00 |
| 2   | another@test.io   | 2024-05-07 10:05:00 |

---

### 2. `tracked_urls` Table

Stores the URLs that users want to monitor.

| Column              | Data Type     | Constraints                               | Description                                                                 |
|---------------------|---------------|-------------------------------------------|-----------------------------------------------------------------------------|
| `id`                | `INTEGER`     | `PRIMARY KEY AUTOINCREMENT`               | Unique identifier for the tracked URL.                                      |
| `user_id`           | `INTEGER`     | `NOT NULL, FOREIGN KEY(user_id) REFERENCES users(id)` | ID of the user who registered this URL.                                     |
| `url`               | `TEXT`        | `NOT NULL`                                | The actual URL to be tracked.                                               |
| `last_content_hash` | `TEXT`        |                                           | SHA256 hash of the URL's content from the last successful check. Used to detect changes. |
| `last_checked_at`   | `TIMESTAMP`   |                                           | Timestamp of the last time this URL was checked.                            |
| `status_code`       | `INTEGER`     |                                           | HTTP status code from the last check.                                       |
| `is_active`         | `BOOLEAN`     | `NOT NULL DEFAULT 1`                      | Flag to indicate if the URL is currently being actively tracked (1=True, 0=False). |
| `created_at`        | `TIMESTAMP`   | `NOT NULL DEFAULT CURRENT_TIMESTAMP`      | Timestamp of when this URL tracking was added.                              |
| **Composite Unique**|               | `UNIQUE (user_id, url)`                   | Ensures a user doesn't track the same URL multiple times.                   |

**Example:**

| id  | user_id | url                   | last_content_hash | last_checked_at     | status_code | is_active | created_at          |
|-----|---------|-----------------------|-------------------|---------------------|-------------|-----------|---------------------|
| 1   | 1       | http://example.com    | abc123def456...   | 2024-05-07 11:00:00 | 200         | 1         | 2024-05-07 10:15:00 |
| 2   | 1       | http://anotherexample.com |                   |                     |             | 1         | 2024-05-07 10:16:00 |

---

### 3. `url_history` Table

Logs the results of each check performed on a tracked URL. This helps in understanding the history of changes or issues.

| Column            | Data Type     | Constraints                               | Description                                                       |
|-------------------|---------------|-------------------------------------------|-------------------------------------------------------------------|
| `id`              | `INTEGER`     | `PRIMARY KEY AUTOINCREMENT`               | Unique identifier for the history log entry.                      |
| `tracked_url_id`  | `INTEGER`     | `NOT NULL, FOREIGN KEY(tracked_url_id) REFERENCES tracked_urls(id)` | ID of the tracked URL this log entry pertains to.           |
| `checked_at`      | `TIMESTAMP`   | `NOT NULL DEFAULT CURRENT_TIMESTAMP`      | Timestamp of when this specific check was performed.              |
| `status_code`     | `INTEGER`     |                                           | HTTP status code received during this check.                      |
| `content_hash`    | `TEXT`        |                                           | SHA256 hash of the content at the time of this check.             |
| `change_detected` | `BOOLEAN`     | `NOT NULL DEFAULT 0`                      | Flag indicating if a change was detected in this check (1=True, 0=False). |
| `error_message`   | `TEXT`        |                                           | Stores any error message if the check failed (e.g., timeout, DNS error). |

**Example:**

| id  | tracked_url_id | checked_at          | status_code | content_hash    | change_detected | error_message |
|-----|----------------|---------------------|-------------|-----------------|-----------------|---------------|
| 1   | 1              | 2024-05-06 11:00:00 | 200         | xyz789uvw012... | 0               | NULL          |
| 2   | 1              | 2024-05-07 11:00:00 | 200         | abc123def456... | 1               | NULL          |
| 3   | 2              | 2024-05-07 11:05:00 | 404         | NULL            | 0               | Not Found     |

---

This schema provides a solid foundation for your ping service. The `url_history` table is particularly useful for auditing and understanding when changes occurred.
