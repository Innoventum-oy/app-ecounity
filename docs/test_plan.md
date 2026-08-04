# Test Suite Plan

## Objectives
- Prevent regressions in navigation, completion, and content rendering flows.
- Validate the new shared screen footer behavior across screen types.
- Add deterministic tests around pathway content transformations, including image placeholder replacement.

## Test Types
- **Unit tests**
  - Validate business logic utilities and data transformations in pure Dart objects.
- **Widget tests**
  - Validate footer behavior and button visibility with representative screen states.
- **Integration tests (later milestones)**
  - Validate end-to-end flow for quiz/challenge completion and progression.

## Milestones

### Milestone 1 — Foundation + deterministic core behavior
- Add test scaffolding under `test/` for:
  - `ScreenFooter` navigation logic and module filtering.
  - Pathway content placeholder transformation for `%image.N%` tokens.
- Keep unit/widget tests fully deterministic (no external network calls).
- Update test utilities where required to inject fake image objects and keep assertions stable.

### Milestone 2 — Content and completion flows
- Add coverage for:
  - Quiz clear/restart and mark-complete button state transitions.
  - Drag-drop state persistence, match completion, and completion banner navigation.
  - Completion workflow in wiki/article/video screens.

### Milestone 3 — Navigation robustness
- Cover transitions across modules/challenge/wiki/video screens.
- Verify “next/previous” behavior against ordered content across modules and submodules.
- Add safeguards for language switching and pathway filtering edge cases.

### Milestone 4 — Visual + interaction smoke tests
- Add targeted widget tests for modal/dialog interactions (e.g., completion dialog in video/wikipedia views).
- Add layout regressions for footer button rows and intro/completion banners.

## Milestone 1 Implementation Checklist
- [x] Add `test/screen_footer_test.dart`.
- [x] Add `test/pathway_contents_test.dart`.
- [x] Ensure tests use provided localizations and no network access.
- [x] Add helper builders for `core.WebPage` and language/module fixtures.
- [x] Validate via `flutter test`.

## Risks and assumptions
- The shared image loader path is asynchronous and can be test-flaky if not abstracted.
- Footer button labels depend on localization; tests should prefer icon presence where possible.
- Route navigation callbacks are intentionally not tapped in Milestone 1 to keep tests stable while validating render state.
