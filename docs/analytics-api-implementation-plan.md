# EcoUnity analytics app API integration

This document defines the app-side API contract for EcoUnity Flutter app analytics, group enrollment, and teacher-mode aggregate reporting.

The backend stores pseudonymous analytics only. Do not send learner names, emails, phone numbers, school pupil IDs, exact birth dates, GPS/device location, free-text reflections, answer text, comments, notes, stack traces, or raw error messages.

## Base URL and headers

Use the normal EcoUnity iCMS host as the base URL.

```text
https://<ecounity-cms-host>
```

Analytics ingestion calls are `POST` requests with JSON bodies.

```http
Content-Type: application/json
Accept: application/json
X-EcoUnity-Analytics-Token: <configured app analytics token>
```

The token must match `settings.analytics.ingestionToken` in `site/modules/ecounitylearning/settings.json`.

Public enrollment and teacher-mode report endpoints do not use `X-EcoUnity-Analytics-Token`. Enrollment is protected by the generated join token in the URL. Teacher-mode reporting is protected by a generated six-letter uppercase teacher token and returns aggregate group statistics only.

## Recommended app lifecycle

1. On first app launch, generate a random UUID and store it locally as `analytics_user_id`.
2. If the app opens from a QR/deep link, resolve the join token with `GET /api/ecounitylearning/group/{join_token}`.
3. Store the returned `group_key` / `pilot_key` locally as the user's current group context.
4. Call `POST /api/ecounitylearning/analytics/identity`.
5. When a foreground app session starts, generate a random UUID as `session_id`.
6. Call `POST /api/ecounitylearning/analytics/session/start`.
7. Queue analytics events locally and send them to `POST /api/ecounitylearning/analytics/events/batch`.
8. When the app session ends or is backgrounded long enough to count as ended, call `POST /api/ecounitylearning/analytics/session/end`.
9. Retry failed event batches later. Keep `event_id` stable across retries so the backend can de-duplicate.

## Common fields

These fields are accepted on identity, session, and event payloads.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `analytics_user_id` | string | Required except identity may omit | Random UUID or opaque app id. If identity omits it, the backend generates one and returns it. |
| `session_id` | string | Required for session calls, optional for events | Random UUID for one foreground app session. |
| `pilot_key` | string | Optional | Stable non-PII group key, for example `FI-01`. The analytics tables still store this field as `pilot_key` for compatibility. |
| `pilot_enrolment_token` | string | Optional | Generated join token from a QR/deep link. Also accepted as `pilot_enrollment_token`, `enrolment_token`, or `enrollment_token`; the backend resolves it to `pilot_key`, `country`, and `language` when enrollment is active. |
| `pilot_participant_code` | string | Optional | Non-PII participant matching code. `participant_code` is also accepted. |
| `country` | string | Optional | Pilot/project country code, for example `FI`. Not GPS. |
| `language` | string | Optional | App/content language, for example `en`, `fi`, `el`. Defaults to `en`. |
| `platform` | string | Optional | One of `ios`, `android`, `web`, `unknown`. |
| `app_version` | string | Optional | App version/build string. |

Timestamps may be ISO 8601 strings or Unix timestamps in seconds or milliseconds. The backend accepts timestamps from `2020-01-01` up to 24 hours in the future.

## Endpoint: group enrollment

```http
GET /api/ecounitylearning/group/{join_token}
GET /api/ecounitylearning/pilot/{join_token}
```

Resolves a generated group join token into non-PII group context. New app code should prefer the `/group/` path. The `/pilot/` path remains available for older clients and existing printed QR links.

The app may also be opened directly by the Universal Link / Android App Link paths:

```text
/ecounitylearning/group/{join_token}
/ecounitylearning/pilot/{join_token}
```

When this happens, extract the final path segment as the join token and call the API endpoint above to get structured group context.

### Response

```json
{
  "status": "ok",
  "group": {
    "id": 1,
    "pilot_key": "FI-01",
    "pilot_group_identifier": "FI-01",
    "group_key": "FI-01",
    "group_identifier": "FI-01",
    "name": "Finland group 1",
    "country": "FI",
    "language": "fi",
    "status": "active",
    "enrolment_token": "f4k9x7p2q8mn",
    "join_token": "f4k9x7p2q8mn",
    "deep_link_url": "https://ecounity.devsite.fi/ecounitylearning/pilot/f4k9x7p2q8mn",
    "enrolment_enabled": 1
  },
  "pilot": {
    "...": "same payload as group for backward compatibility"
  }
}
```

Store `group.group_key` as the current group identifier and send it as `pilot_key` on analytics calls. Alternatively, the app may send the raw join token as `pilot_enrolment_token`; the backend resolves active secure join tokens during ingestion.

### Invalid or disabled link

```json
{
  "status": "error",
  "message": "Group enrollment link was not found or is not active."
}
```

Invalid, disabled, missing, or weak legacy tokens return `404`.

## Endpoint: identity

```http
POST /api/ecounitylearning/analytics/identity
```

Creates or updates the pseudonymous analytics user context.

### Request

```json
{
  "analytics_user_id": "7d130810-9f2f-43cc-bfa4-f94d0f3e1d9a",
  "seen_at": "2026-08-18T12:00:00Z",
  "pilot_key": "FI-01",
  "pilot_participant_code": "FI01-A7K2",
  "country": "FI",
  "language": "fi",
  "platform": "android",
  "app_version": "1.0.0+42"
}
```

`analytics_user_id` may be omitted on this endpoint. If omitted, store the returned `analytics_user_id` locally and use it for all future calls.

If the app only has a join token and has not yet resolved it, this endpoint may include `pilot_enrolment_token` instead of `pilot_key`.

### Response

```json
{
  "status": "ok",
  "analytics_user_id": "7d130810-9f2f-43cc-bfa4-f94d0f3e1d9a",
  "analytics_user_record_id": 123,
  "created": true
}
```

## Endpoint: session start

```http
POST /api/ecounitylearning/analytics/session/start
```

Starts or updates an app session.

### Request

```json
{
  "analytics_user_id": "7d130810-9f2f-43cc-bfa4-f94d0f3e1d9a",
  "session_id": "018fe096-8d90-46b5-a6d7-6fc9550b5b4b",
  "started_at": "2026-08-18T12:01:00Z",
  "pilot_key": "FI-01",
  "country": "FI",
  "language": "fi",
  "platform": "android",
  "app_version": "1.0.0+42"
}
```

`event_time` is also accepted as a fallback for `started_at`.

### Response

```json
{
  "status": "ok",
  "session_id": "018fe096-8d90-46b5-a6d7-6fc9550b5b4b",
  "session_record_id": 456,
  "created": true
}
```

## Endpoint: session end

```http
POST /api/ecounitylearning/analytics/session/end
```

Ends or updates an app session.

### Request

```json
{
  "analytics_user_id": "7d130810-9f2f-43cc-bfa4-f94d0f3e1d9a",
  "session_id": "018fe096-8d90-46b5-a6d7-6fc9550b5b4b",
  "ended_at": "2026-08-18T12:24:30Z",
  "duration_seconds": 1410,
  "pilot_key": "FI-01",
  "country": "FI",
  "language": "fi",
  "platform": "android",
  "app_version": "1.0.0+42"
}
```

`event_time` is also accepted as a fallback for `ended_at`. If `duration_seconds` is omitted and the backend knows the start time, it calculates the duration.

## Endpoint: single event

```http
POST /api/ecounitylearning/analytics/events
```

Stores one analytics event. `event_id` is an idempotency key. Retrying the same `event_id` is safe.

### Common event envelope

```json
{
  "event_id": "5dd32a35-b743-4cbd-84d7-0cf06d8cc2a8",
  "analytics_user_id": "7d130810-9f2f-43cc-bfa4-f94d0f3e1d9a",
  "session_id": "018fe096-8d90-46b5-a6d7-6fc9550b5b4b",
  "event_type": "module_opened",
  "event_time": "2026-08-18T12:04:00Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 108,
  "question_id": null,
  "comic_id": null,
  "scene_id": null,
  "decision_id": null,
  "badge_id": null,
  "activity_type": "mlr",
  "pilot_key": "FI-01",
  "country": "FI",
  "language": "fi",
  "platform": "android",
  "app_version": "1.0.0+42",
  "event_data": {
    "module_key": "sdg-5",
    "activity_key": "sdg-5-mlr-1"
  }
}
```

### Required event fields

| Field | Required | Notes |
| --- | --- | --- |
| `event_id` | Yes | Generate one UUID per event and persist it for retries. |
| `analytics_user_id` | Yes | The stored app analytics UUID. |
| `event_type` | Yes | Must be one of the whitelisted event types below. |
| `event_time` | Yes | `occurred_at` is also accepted. |
| `session_id` | Recommended | If present, the backend upserts the session shell if needed. |

### Indexed content fields

Send CMS ids where available. These make dashboard filters and drill-downs fast.

| Field | Notes |
| --- | --- |
| `sdg_number` | 1-17. `sdg` is also accepted. |
| `module_id` | CMS id for `ecounitysdgmodule`. `sdg_module_id` is also accepted. |
| `activity_id` | CMS id for `ecounitylearningactivity`. |
| `question_id` | CMS id for `ecounityquestion`. |
| `comic_id` | Comic activity id. |
| `scene_id` | CMS id for `ecounitycomicscene`. |
| `decision_id` | CMS id for `ecounitycomicdecision`. |
| `badge_id` | CMS id for `badge`. |
| `activity_type` | One of `comic`, `mlr`, `quiz`, `reflection`, `challenge`. |

### Safe event data

Use `event_data` for small structured values. Recommended keys:

```text
score
max_score
maximum_score
correct_count
question_count
passed
badge_type
badge_slug
branch_key
decision_label
activity_key
module_key
scene_key
duration_seconds
attempt_number
error_code
screen
previous_language
new_language
```

Other small structured keys are accepted if they are not PII/free-text. Scalar strings are truncated to 256 characters.

Do not send keys such as `name`, `first_name`, `last_name`, `email`, `phone`, `birthdate`, `student_id`, `pupil_id`, `gps`, `latitude`, `longitude`, `reflection_text`, `answer_text`, `free_text`, `comment`, `notes`, `message`, `error_message`, `stack`, or `stack_trace`. The backend rejects the whole payload if these appear anywhere in the JSON.

### Event response

New event:

```json
{
  "status": "ok",
  "event_id": "5dd32a35-b743-4cbd-84d7-0cf06d8cc2a8",
  "event_record_id": 789,
  "duplicate": false
}
```

Duplicate retry:

```json
{
  "status": "ok",
  "event_id": "5dd32a35-b743-4cbd-84d7-0cf06d8cc2a8",
  "event_record_id": 789,
  "duplicate": true
}
```

## Endpoint: batch events

```http
POST /api/ecounitylearning/analytics/events/batch
```

Stores up to `settings.analytics.maxBatchSize` events. The current default is `100`.

### Request

```json
{
  "pilot_key": "FI-01",
  "country": "FI",
  "language": "fi",
  "platform": "android",
  "app_version": "1.0.0+42",
  "events": [
    {
      "event_id": "fbf2f63b-28d4-421d-9a10-4c7a4c11a67b",
      "analytics_user_id": "7d130810-9f2f-43cc-bfa4-f94d0f3e1d9a",
      "session_id": "018fe096-8d90-46b5-a6d7-6fc9550b5b4b",
      "event_type": "module_opened",
      "event_time": "2026-08-18T12:04:00Z",
      "sdg_number": 5,
      "module_id": 42
    },
    {
      "event_id": "8afbe9b2-8a35-4968-9b36-e03fbc13d519",
      "analytics_user_id": "7d130810-9f2f-43cc-bfa4-f94d0f3e1d9a",
      "session_id": "018fe096-8d90-46b5-a6d7-6fc9550b5b4b",
      "event_type": "quiz_completed",
      "event_time": "2026-08-18T12:18:00Z",
      "sdg_number": 5,
      "module_id": 42,
      "activity_id": 118,
      "activity_type": "quiz",
      "event_data": {
        "score": 7,
        "max_score": 10,
        "passed": true,
        "attempt_number": 1
      }
    }
  ]
}
```

Only context fields are inherited from the batch envelope: `pilot_key`, `pilot_participant_code`, `country`, `language`, `platform`, and `app_version`. Every event must still include its own `event_id`, `analytics_user_id`, `event_type`, and `event_time`. Include `session_id` on every event when available.

### Response

```json
{
  "status": "ok",
  "accepted": 2,
  "duplicates": 0,
  "rejected": 0,
  "results": [
    {
      "index": 0,
      "status": "accepted",
      "event_id": "fbf2f63b-28d4-421d-9a10-4c7a4c11a67b",
      "event_record_id": 790
    },
    {
      "index": 1,
      "status": "accepted",
      "event_id": "8afbe9b2-8a35-4968-9b36-e03fbc13d519",
      "event_record_id": 791
    }
  ]
}
```

Batch-level errors return an error response. Per-event validation errors are reported in `results` with `status: "rejected"` while valid events in the same batch are still accepted.

## Endpoint: teacher group report

```http
GET /api/ecounitylearning/groups/{teacher_token}/report
GET /api/ecounitylearning/group/{teacher_token}/report
```

Returns aggregate teacher-mode statistics for one group. The teacher token is a generated six-letter uppercase code stored on the group object. It is intentionally easy to type, so the endpoint never returns learner identifiers, participant codes, raw events, or event payload JSON.

Optional query filters:

```text
date_from=2026-08-01
date_to=2026-08-31
sdg_number=5
country=FI
language=fi
platform=android
app_version=1.0.0
```

### Response

```json
{
  "status": "ok",
  "report": {
    "group": {
      "id": 1,
      "group_key": "FI-01",
      "pilot_key": "FI-01",
      "name": "Finland group 1",
      "country": "FI",
      "language": "fi",
      "status": "active"
    },
    "filters": {
      "date_from": "2026-08-01",
      "date_to": "2026-08-31",
      "pilot_key": "FI-01",
      "sdg_number": 5,
      "country": "",
      "language": "",
      "platform": "",
      "app_version": ""
    },
    "summary": {
      "enrolled_users": 24,
      "participant_code_rows": 0,
      "active_users": 22,
      "sessions": 68,
      "events": 340,
      "activity_opened_users": 21,
      "activity_completed_users": 17,
      "activity_completion_rate": 81.0
    },
    "sdgs": [
      {
        "sdg_number": 5,
        "module_opened_users": 20,
        "module_completed_users": 14,
        "activity_opened_users": 19,
        "activity_completed_users": 15,
        "activity_completion_rate": 78.9,
        "activities": [
          {
            "sdg_number": 5,
            "activity_id": 17,
            "activity_type": "mlr",
            "title": "What is Gender Equality?",
            "slug": "sdg-5-mlr-1",
            "opened_users": 18,
            "completed_users": 14,
            "completion_rate": 77.8
          }
        ]
      }
    ],
    "schemaReady": true,
    "schemaMissing": false,
    "lastUpdated": "2026-08-20 09:30:00"
  }
}
```

`activity_completion_rate` is `null` when there are no opened users in the denominator.

### Invalid teacher token

```json
{
  "status": "error",
  "message": "Group report token was not found."
}
```

Invalid or unknown teacher tokens return `404`.

## Endpoint: teacher group comparison

```http
POST /api/ecounitylearning/groups/compare
POST /api/ecounitylearning/group/compare
```

Compares aggregate teacher-mode statistics for multiple groups. The endpoint accepts up to 12 valid teacher tokens per request. Unknown tokens are ignored; if no valid groups are found, the endpoint returns `404`.

### Request

```json
{
  "tokens": ["ABCDEF", "QWERTY"],
  "date_from": "2026-08-01",
  "date_to": "2026-08-31",
  "sdg_number": 5
}
```

Accepted token field aliases: `tokens`, `teacher_tokens`, `teacherTokens`, `group_tokens`, and `groupTokens`.

### Response

```json
{
  "status": "ok",
  "requested_group_count": 2,
  "returned_group_count": 2,
  "comparison": {
    "filters": {
      "date_from": "2026-08-01",
      "date_to": "2026-08-31",
      "pilot_key": "",
      "sdg_number": 5,
      "country": "",
      "language": "",
      "platform": "",
      "app_version": ""
    },
    "groups": [
      {
        "group_key": "FI-01",
        "pilot_key": "FI-01",
        "name": "Finland group 1",
        "enrolled_users": 24,
        "active_users": 22,
        "activity_opened_users": 21,
        "activity_completed_users": 17,
        "activity_completion_rate": 81.0
      }
    ],
    "sdgs": [
      {
        "sdg_number": 5,
        "groups": [
          {
            "group_key": "FI-01",
            "name": "Finland group 1",
            "module_opened_users": 20,
            "module_completed_users": 14,
            "activity_opened_users": 19,
            "activity_completed_users": 15,
            "activity_completion_rate": 78.9
          }
        ]
      }
    ],
    "reports": [
      {
        "...": "full per-group report objects"
      }
    ],
    "hasReports": true,
    "lastUpdated": "2026-08-20 09:30:00"
  }
}
```

The real response includes full per-group `reports`; clients that only need a compact comparison can read `comparison.groups` and `comparison.sdgs`.

## Whitelisted event types

```text
app_session_started
app_session_ended
module_opened
module_completed
activity_started
activity_completed
quiz_completed
quiz_answered
comic_started
comic_scene_viewed
comic_decision_selected
comic_completed
badge_earned
language_changed
app_error
```

Session lifecycle events may be sent either through the session endpoints or as analytics events. For reporting, keep using the session endpoints for session duration and the event endpoint for chronological event history.

## Recommended event payloads

### Module opened

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "module_opened",
  "event_time": "2026-08-18T12:04:00Z",
  "sdg_number": 5,
  "module_id": 42,
  "event_data": {
    "module_key": "sdg-5"
  }
}
```

### Module completed

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "module_completed",
  "event_time": "2026-08-18T13:10:00Z",
  "sdg_number": 5,
  "module_id": 42
}
```

### Activity started or completed

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "activity_completed",
  "event_time": "2026-08-18T12:12:00Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 108,
  "activity_type": "mlr",
  "event_data": {
    "activity_key": "sdg-5-mlr-1",
    "duration_seconds": 420
  }
}
```

Use `event_type: "activity_started"` for starts. Use the same indexed ids and `activity_type`.

### Quiz answered

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "quiz_answered",
  "event_time": "2026-08-18T12:16:30Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 118,
  "question_id": 501,
  "activity_type": "quiz",
  "event_data": {
    "passed": true,
    "attempt_number": 1
  }
}
```

Do not send the learner's answer text. If needed later, send structured choice ids only after the backend whitelist is extended.

### Quiz completed

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "quiz_completed",
  "event_time": "2026-08-18T12:18:00Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 118,
  "activity_type": "quiz",
  "event_data": {
    "score": 7,
    "max_score": 10,
    "passed": true,
    "attempt_number": 1
  }
}
```

The dashboard uses `score / max_score`, or `correct_count / question_count`, for quiz averages.

### Comic started

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "comic_started",
  "event_time": "2026-08-18T12:05:00Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 101,
  "comic_id": 101,
  "activity_type": "comic",
  "event_data": {
    "activity_key": "sdg-5-comic"
  }
}
```

### Comic scene viewed

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "comic_scene_viewed",
  "event_time": "2026-08-18T12:06:15Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 101,
  "comic_id": 101,
  "scene_id": 301,
  "activity_type": "comic",
  "event_data": {
    "scene_key": "sdg-5-comic-scene-03"
  }
}
```

### Comic decision selected

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "comic_decision_selected",
  "event_time": "2026-08-18T12:08:40Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 101,
  "comic_id": 101,
  "scene_id": 301,
  "decision_id": 701,
  "activity_type": "comic",
  "event_data": {
    "branch_key": "reuse_water",
    "decision_label": "Reuse water"
  }
}
```

### Comic completed

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "comic_completed",
  "event_time": "2026-08-18T12:11:00Z",
  "sdg_number": 5,
  "module_id": 42,
  "activity_id": 101,
  "comic_id": 101,
  "activity_type": "comic",
  "event_data": {
    "duration_seconds": 360
  }
}
```

### Badge earned

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "badge_earned",
  "event_time": "2026-08-18T13:12:00Z",
  "sdg_number": 5,
  "module_id": 42,
  "badge_id": 81,
  "event_data": {
    "badge_type": "sdg",
    "badge_slug": "sdg-5-water-champion"
  }
}
```

For the final EcoUnity badge, send:

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "badge_earned",
  "event_time": "2026-08-18T13:12:00Z",
  "badge_id": 99,
  "event_data": {
    "badge_type": "final",
    "badge_slug": "ecounity-final"
  }
}
```

`badge_type: "canvas"` is also counted as a final badge by the dashboard.

### Language changed

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "language_changed",
  "event_time": "2026-08-18T12:03:00Z",
  "language": "fi",
  "event_data": {
    "previous_language": "en",
    "new_language": "fi"
  }
}
```

### App error

```json
{
  "event_id": "uuid",
  "analytics_user_id": "uuid",
  "session_id": "uuid",
  "event_type": "app_error",
  "event_time": "2026-08-18T12:20:00Z",
  "event_data": {
    "error_code": "asset_audio_load_failed",
    "screen": "comic_scene"
  }
}
```

Do not send raw exception text, stack traces, URLs containing personal data, or user-entered content.

## HTTP status handling

| Status | Meaning | App behavior |
| --- | --- | --- |
| `200` | Successful update or duplicate event retry | Mark sent. |
| `201` | New identity/session/event accepted | Mark sent. |
| `400` | Invalid payload, disallowed event type, prohibited PII/free-text, bad timestamp | Drop or quarantine the event; fix client payload. |
| `401` | Missing or invalid analytics token | Stop sending until app configuration is fixed. |
| `404` | Enrollment link, teacher token, or comparison groups were not found | Ask for a new QR/code or show an unavailable group state. |
| `503` | Token not configured or analytics schema unavailable | Retry later after backend configuration/deployment. |
| `500` | Unexpected ingestion failure | Retry later with the same `event_id`. |

## Flutter implementation notes

Generate ids with UUID v4 or an equivalent random opaque id.

```dart
final headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'X-EcoUnity-Analytics-Token': analyticsToken,
};
```

Keep a local queue of unsent events. Store at least:

```text
event_id
analytics_user_id
session_id
event_type
event_time
payload json
retry count
```

Recommended retry behavior:

- Send batches of 25-100 events.
- Keep `event_id` unchanged on retry.
- Treat duplicate responses as successfully sent.
- Do not retry `400` events automatically.
- Retry `500`, network failures, and `503`.
- Pause retries on `401` until the app has a valid token.

## Minimal Dart-style request helper

```dart
Future<Map<String, dynamic>> postAnalytics(
  Uri baseUri,
  String path,
  Map<String, dynamic> payload,
  String token,
) async {
  final response = await http.post(
    baseUri.resolve(path),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-EcoUnity-Analytics-Token': token,
    },
    body: jsonEncode(payload),
  );

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return decoded;
  }

  throw AnalyticsIngestionException(response.statusCode, decoded);
}
```

Keep the analytics token out of source control. Inject it through the app's environment/configuration pipeline.
