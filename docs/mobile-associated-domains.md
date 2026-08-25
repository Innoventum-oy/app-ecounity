# Mobile Associated Domains

The app declares Universal Link / Android App Link support for:

- `https://ecounity.app/ecounitylearning/...`
- `https://ecounity.devsite.fi/ecounitylearning/...`

The current enrollment parser supports these path forms:

- `/ecounitylearning/group/{join_token}`
- `/ecounitylearning/pilot/{join_token}`

## iOS

The Runner target uses `ios/Runner/Runner.entitlements` with:

- `applinks:ecounity.app`
- `applinks:ecounity.devsite.fi`

When an App Clip target is added, give that App Clip target its own associated
domains entitlement with:

- `appclips:ecounity.app`
- `appclips:ecounity.devsite.fi`

The public and development domains must serve an Apple App Site Association file
from `/.well-known/apple-app-site-association`. The file must be returned as
JSON without a `.json` file extension.

Example shape:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": ["6GB259Z94P.app.ecounity.ecounity"],
        "components": [
          { "/": "/ecounitylearning/group/*" },
          { "/": "/ecounitylearning/pilot/*" }
        ]
      }
    ]
  },
  "appclips": {
    "apps": ["6GB259Z94P.app.ecounity.ecounity.Clip"]
  }
}
```

Replace the App Clip bundle id once the App Clip target exists.

## Android

The main Android activity declares verified App Links for both domains and the
`/ecounitylearning` path prefix.

Each domain must serve `/.well-known/assetlinks.json` with the release app
signing certificate fingerprint.

Example shape:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "app.ecounity.ecounity",
      "sha256_cert_fingerprints": [
        "REPLACE_WITH_RELEASE_SIGNING_CERT_SHA256"
      ]
    }
  }
]
```

## Remaining App Work

The native projects can now claim the domains, but the Flutter runtime still
needs a native link listener before installed-app Universal/App Links can resolve
join tokens outside Flutter web. The web path currently uses `Uri.base`.
