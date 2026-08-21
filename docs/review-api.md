# EcoUnity Learning Review API

Date: 2026-08-21

## Purpose

The review API lets authenticated partner/editor clients read and update
language-specific review markers for EcoUnity SDG content. It is designed for
both the iCMS admin review workspace and Flutter review controls.

Review markers are stored in `ecounitycontentlocale`. The actual translated
content remains on the language-versioned content objects; locale rows are
workflow sidecars for translation, accessibility, review, approval, and
publication state.

## Authentication and Access

All review routes are module routes under `ecounitylearning`, so iCMS checks the
route `accesslevel` before the action runs.

- Read routes require `ACL_READ`.
- Update routes require `ACL_MODIFY`.
- Clients must use the normal authenticated iCMS session or API authentication
  configured for the site.
- Flutter should use the read routes to populate review UI, but must still
  handle `401` and `403` responses from update routes as the source of truth.

The backend route gate uses the framework module ACL checks. The client must not
treat hidden UI controls as security.

## Review Scopes

The generic marker endpoints accept these scope tokens:

| Scope | Object type | Typical app view |
| --- | --- | --- |
| `module` | `ecounitysdgmodule` | SDG overview |
| `activity` | `ecounitylearningactivity` | MLR, quiz, reflection, challenge, comic wrapper |
| `question` | `ecounityquestion` | Quiz question/options |
| `note` | `ecounitynote` | Teacher or accessibility note |
| `comic_scene` | `ecounitycomicscene` | Native comic scene |
| `comic_dialogue` | `ecounityscenedialogue` | Native comic dialogue line |
| `comic_decision` | `ecounitycomicdecision` | Native comic branch choice |

Common aliases are normalized server-side. For example `ecounitysdgmodule`,
`sdg_module`, and `sdg` resolve to `module`; `dialogue` resolves to
`comic_dialogue`.

## Review Statuses

Allowed `review_status` values:

| Status | Meaning |
| --- | --- |
| `not_ready` | Content is not ready for partner review. |
| `needs_review` | Content is ready and waiting for review. |
| `needs_changes` | Reviewer found issues that should be adapted. |
| `approved` | Reviewer accepted the language version. |
| `published` | Language version is accepted and publishable in the app. |

When a marker is updated, the API also mirrors the translation workflow:

| Review status | Mirrored `translation_status` |
| --- | --- |
| `not_ready` | `draft` |
| `needs_review` | `review` |
| `needs_changes` | `review` |
| `approved` | `approved` |
| `published` | `published` |

## Trace Fields

Each update records:

- `reviewed_by`: user who last changed the review marker.
- `reviewed_at`: timestamp of the last review marker change.

Approval actions additionally record:

- `approved_by`: user who last set the marker to `approved` or `published`.
- `approved_at`: timestamp of that approval action.

`published` also sets `published_at`.

These fields represent the current/latest marker trace. They are not an
immutable event log; add a separate review event object if a full audit trail is
needed later.

## Endpoints

### Get SDG Language Review Queue

```http
GET /api/ecounitylearning/sdg/{objectid}/review/{language}
```

Returns the review queue for one SDG module and one language. The queue includes
the SDG module itself, activities, quiz questions, notes, and native comic
scene/dialogue/decision items.

Access: `ACL_READ`

Example:

```http
GET /api/ecounitylearning/sdg/12/review/es
Accept: application/json
```

Response shape:

```json
{
  "status": "success",
  "sdg": {
    "id": 12,
    "number": "12",
    "title": "SDG 12: Responsible Consumption and Production"
  },
  "language": "es",
  "languageLabel": "ES",
  "summary": {
    "total": 34,
    "notReady": 2,
    "needsReview": 8,
    "needsChanges": 1,
    "approved": 20,
    "published": 3,
    "ready": 23,
    "overallStatus": "needs_changes",
    "overallLabel": "Needs changes",
    "overallKey": "needs-changes"
  },
  "statuses": [
    {"value": "not_ready", "label": "Not ready"},
    {"value": "needs_review", "label": "Needs review"},
    {"value": "needs_changes", "label": "Needs changes"},
    {"value": "approved", "label": "Approved"},
    {"value": "published", "label": "Published"}
  ],
  "items": [],
  "groups": [],
  "hasItems": true
}
```

The `groups` array contains the same item payloads as `items`, grouped for admin
UI rendering.

### Get One Review Marker

```http
GET /api/ecounitylearning/review/{scope}/{objectid}/{language}
```

Returns the marker for one language-scoped item. If no locale marker exists yet,
the response still returns a marker with `localeId: 0` and `reviewStatus:
"not_ready"`.

Access: `ACL_READ`

Example:

```http
GET /api/ecounitylearning/review/activity/345/es
Accept: application/json
```

Response:

```json
{
  "status": "success",
  "marker": {
    "localeId": 882,
    "scopeType": "activity",
    "scopeLabel": "Activity",
    "scopeId": 345,
    "objectType": "ecounitylearningactivity",
    "objectId": 345,
    "language": "es",
    "title": "What happens to the things we buy?",
    "summary": "Short preview of the translated body or fallback text.",
    "hasSummary": true,
    "objectStatus": "approved",
    "objectStatusLabel": "Approved",
    "objectStatusKey": "approved",
    "reviewStatus": "approved",
    "reviewStatusLabel": "Approved",
    "reviewStatusKey": "approved",
    "translationStatus": "approved",
    "translationStatusLabel": "Approved",
    "translationStatusKey": "approved",
    "accessibilityStatus": "not_checked",
    "accessibilityStatusLabel": "Not checked",
    "reviewNotes": "",
    "hasReviewNotes": false,
    "reviewedBy": {
      "id": 52,
      "label": "Alex Reviewer",
      "email": "alex@example.test"
    },
    "reviewedByLabel": "Alex Reviewer",
    "hasReviewTrace": true,
    "reviewedAt": "2026-08-21 12:45:00",
    "approvedBy": {
      "id": 52,
      "label": "Alex Reviewer",
      "email": "alex@example.test"
    },
    "approvedByLabel": "Alex Reviewer",
    "approvedAt": "2026-08-21 12:45:00",
    "hasApprovalTrace": true,
    "isCurrentlyApproved": true,
    "markerUrl": "/api/ecounitylearning/review/activity/345/es",
    "updateUrl": "/api/ecounitylearning/review/activity/345/es/update",
    "editUrl": "/admin/ecounitylearning/edit/ecounitylearningactivity/345?form_language=es"
  },
  "statuses": [
    {"value": "not_ready", "label": "Not ready"},
    {"value": "needs_review", "label": "Needs review"},
    {"value": "needs_changes", "label": "Needs changes"},
    {"value": "approved", "label": "Approved"},
    {"value": "published", "label": "Published"}
  ]
}
```

### Update One Review Marker

```http
POST /api/ecounitylearning/review/{scope}/{objectid}/{language}/update
Content-Type: application/json
```

Creates or updates one `ecounitycontentlocale` marker for the requested
scope/object/language.

Access: `ACL_MODIFY`

Request body:

```json
{
  "review_status": "approved",
  "review_notes": "Spanish copy approved by partner reviewer.",
  "accessibility_status": "approved"
}
```

Fields:

- `review_status` is required. Aliases such as `status` or `value` are also
  accepted.
- `review_notes` is optional. Alias: `notes`.
- `accessibility_status` is optional and must be one of
  `not_checked`, `needs_work`, or `approved`.

Response:

```json
{
  "status": "success",
  "marker": {
    "localeId": 882,
    "scopeType": "activity",
    "scopeId": 345,
    "language": "es",
    "reviewStatus": "approved",
    "reviewStatusLabel": "Approved",
    "reviewedByLabel": "Alex Reviewer",
    "reviewedAt": "2026-08-21 12:45:00",
    "approvedByLabel": "Alex Reviewer",
    "approvedAt": "2026-08-21 12:45:00",
    "hasApprovalTrace": true
  },
  "statuses": [
    {"value": "not_ready", "label": "Not ready"},
    {"value": "needs_review", "label": "Needs review"},
    {"value": "needs_changes", "label": "Needs changes"},
    {"value": "approved", "label": "Approved"},
    {"value": "published", "label": "Published"}
  ]
}
```

The real response includes the full marker payload shown in the read endpoint.

## Admin Workspace

The same API powers this admin page:

```http
GET /admin/ecounitylearning/sdg/{objectid}/review/{language}
```

Access: `ACL_READ`

Editors can open it from the SDG dashboard language chips. Each row saves via
the authenticated update endpoint.

## Flutter Integration Notes

Recommended Flutter flow:

1. Load the current SDG language review queue with
   `/api/ecounitylearning/sdg/{sdgId}/review/{language}`.
2. For view-level controls, use the current view's scope and object id:
   `/api/ecounitylearning/review/{scope}/{objectId}/{language}`.
3. Show review controls only to authenticated partner/editor users, but still
   treat `401` and `403` from the update endpoint as authoritative.
4. On save, `POST` JSON to the marker `updateUrl` returned by the API.
5. Update the local UI from the returned `marker`, especially `reviewStatus`,
   `reviewedByLabel`, `reviewedAt`, `approvedByLabel`, and `approvedAt`.

For cookie-based sessions, send credentials with the request. For native app
authentication, use the site's configured iCMS API authentication.

## Error Responses

Typical errors:

```json
{"status": "error", "message": "Unsupported review scope."}
```

Common status codes:

- `400`: invalid scope, language, object id, or status.
- `401`: authentication required.
- `403`: authenticated user does not have sufficient module access.
- `404`: target object could not be loaded.
- `500`: marker could not be saved.


