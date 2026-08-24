# EcoUnity Learning Comic Package JSON

Date: 2026-08-24

## Purpose

Native comic activities are exported into static hierarchical JSON files so the
mobile app can load one package file instead of resolving the comic through many
API relation calls. The app still downloads and caches image/audio assets from
the URLs listed in the package.

## Generated Files

For comic activity `{activityId}`, the package builder writes:

```http
GET /ecounitylearning/comics/{activityId}/manifest.json
GET /ecounitylearning/comics/{activityId}/{language}.json
```

Example:

```http
GET /ecounitylearning/comics/345/manifest.json
GET /ecounitylearning/comics/345/es.json
```

The activity API also exposes:

- `comic_package_base_url`
- `comic_package_manifest_url`
- `comic_package_status`
- `comic_package_version`

Use the manifest when the app needs to discover available languages or compare
package hashes. If the app already knows the selected language, it may request
the language JSON directly.

## Update Flow

Comic package generation runs outside editor requests:

1. A comic activity save, or a listenable relation change below the comic graph,
   marks `ecounitylearningactivity.comic_package_update_pending`.
2. The activity queues one `tasktimer` job targeting
   `ecounitylearningactivity::buildComicPackageTaskTimer`.
3. The task writes the manifest and language JSON files under the public webroot.
4. If more changes arrive while the task is running, the activity remains pending
   and the task requeues one more build pass.

The listenable relation graph covers scenes, backgrounds, viewports, cast rows,
dialogue, speech audio, props, pose layers, branch decisions, and embedded
image/file relations used by the package.

## Manifest Format

```json
{
  "schemaVersion": "1.0.0",
  "packageType": "ecounity_comic_manifest",
  "activityId": 345,
  "activitySlug": "sdg-12-comic-1",
  "sdgNumber": 12,
  "generatedAt": "2026-08-24 12:00:00",
  "packageVersion": "a1b2c3d4e5f60789",
  "languages": [
    {
      "language": "es",
      "url": "/ecounitylearning/comics/345/es.json",
      "contentHash": "8f1f...",
      "bytes": 42813,
      "sceneCount": 7
    }
  ]
}
```

`packageVersion` and each `contentHash` are content-derived tokens. The app can
use them to decide whether a cached package should be refreshed.

## Language Package Format

```json
{
  "schemaVersion": "1.0.0",
  "packageType": "ecounity_comic",
  "generatedAt": "2026-08-24 12:00:00",
  "contentLanguage": "es",
  "packageVersion": "8f1f2a3b4c5d6e7f",
  "activity": {},
  "startSceneKey": "intro",
  "sceneIndex": {"intro": 0},
  "scenes": [],
  "assets": {"images": [], "audio": []},
  "counts": {"scenes": 7, "images": 21, "audio": 14}
}
```

### Activity

```json
{
  "id": 345,
  "slug": "sdg-12-comic-1",
  "sdgNumber": 12,
  "title": "What happens to the things we buy?",
  "shortDescription": "Short intro copy.",
  "contentStatus": "published",
  "heroImageUrl": "/images/open.php?...",
  "mediaImageUrls": ["/images/open.php?..."]
}
```

### Scene

Each scene contains all renderable children:

```json
{
  "id": 9001,
  "sceneKey": "intro",
  "orderno": 1,
  "title": "Intro",
  "narration": "Narration text",
  "altText": "Accessibility description",
  "contentStatus": "published",
  "backgrounds": [],
  "viewportBackgrounds": {},
  "props": [],
  "cast": [],
  "decisions": []
}
```

`sceneIndex` maps `sceneKey` to array position. `startSceneKey` is the first
ordered scene.

### Backgrounds And Viewports

```json
{
  "id": 120,
  "category": "school",
  "title": "Classroom",
  "altText": "A classroom with recycling bins.",
  "contentStatus": "published",
  "referenceImageUrl": "/images/open.php?...",
  "viewports": [
    {
      "id": 121,
      "viewport": "portrait",
      "canvasWidth": 1024,
      "canvasHeight": 1365,
      "imageUrl": "/images/open.php?...",
      "generationStatus": "ready",
      "generatedAt": "2026-08-24 11:30:00"
    }
  ]
}
```

`viewportBackgrounds` is a convenience map keyed by `portrait` and `landscape`
when available.

### Props, Cast, Dialogue, And Speech

Props and cast rows include `layout.portrait` and `layout.landscape` objects.
Layout values are editor-managed relative coordinates such as `x`, `y`, `scale`,
`rotation`, `flip_x`, `bubble_x`, `bubble_y`, and `z_index`.

Cast rows include:

- `character`: id, slug, localized name, age, voice, personality definition.
- `poseLayer`: generated layer id, slug, image URL, generation status, pose.
- `dialogueEntries`: ordered dialogue lines for the selected language.

Speech rows are filtered to the package language and include audio metadata:

```json
{
  "id": 501,
  "dialogueEntryId": 400,
  "language": "es",
  "audioUrl": "/file/open.php?...",
  "generationStatus": "ready",
  "startMs": 0,
  "durationMs": 2400,
  "orderno": 1,
  "voice": "alloy",
  "responseFormat": "mp3"
}
```

### Decisions

```json
{
  "id": 700,
  "orderno": 1,
  "label": "Choose the reusable bottle",
  "consequenceSummary": "The learner moves to the reuse branch.",
  "altText": "Reusable bottle choice",
  "choiceImageUrl": "/images/open.php?...",
  "targetSceneId": 9002,
  "targetSceneKey": "reuse-branch",
  "zIndex": 50,
  "contentStatus": "published",
  "layout": {"portrait": {}, "landscape": {}}
}
```

## Asset Caching

Every image and audio URL used in the package also appears in `assets`:

```json
{
  "url": "/images/open.php?...&icms_image_v=abcdef123456",
  "kind": "background",
  "ownerType": "ecounitysceneviewport",
  "ownerId": 121,
  "field": "background_image",
  "cacheKey": "123456abcdef"
}
```

Image URLs include `icms_image_v` and file URLs include `icms_file_v` cache
tokens. The app should cache by URL or `cacheKey`, and refresh assets when the
package hash or asset URL changes.

## Front-End Loading Flow

Recommended Flutter flow:

1. Fetch `manifest.json` for the comic activity.
2. Select the best language row, falling back to the app default language.
3. Fetch the language package JSON.
4. Cache `assets.images[].url` and `assets.audio[].url`.
5. Render `startSceneKey`, then navigate branches through
   `decisions[].targetSceneKey`.
6. Refresh cached package/assets when the manifest `packageVersion`, language
   `contentHash`, or asset URL changes.

Treat the static JSON as read-only app content. Editorial/review writes still go
through the authenticated API routes.
