# EcoUnity Flutter Architecture and Development Plan

Date: 2026-01-02

This document describes the planned Flutter architecture for the EcoUnity app and the recommended development steps. It is based on the current repository structure and the PDF specification documents in `docs/`.

## Source Material

Specification documents reviewed:

- `docs/WP5.A2 Output 1 - App architecture.pdf`
- `docs/WP5.2 App content architecture overview.pdf`
- `docs/WP5.A2 – EcoUnity App Content Architecture and Key Screens.pdf`

Current Flutter implementation:

- `lib/main.dart`
- `lib/src/util/router.dart`
- `lib/src/util/settings.dart`
- `lib/src/util/ecounity_storage.dart`
- `lib/src/objects/pathway.dart`
- `lib/src/objects/ecounity_badge.dart`
- `lib/src/providers/ecounity_badge_provider.dart`
- `lib/src/providers/selected_pathway_notifier.dart`
- `lib/src/screens/**`
- `lib/src/widgets/**`
- `lib/l10n/**`

## Product Goal

EcoUnity is planned as a multilingual, inclusive, mobile-first learning app for students aged 10-14 and their teachers. The app should connect sustainability education, social mixing, and practical in-service learning into one guided learning journey.

The target content model is a modular SDG learning system:

- 17 SDG learning modules.
- 1 interactive comic or scenario link per SDG.
- 3 micro-learning resources per SDG, for 51 total MLRs.
- 1 quiz or reflection per SDG.
- 1 practical action challenge per SDG.
- 1 SDG badge per SDG.
- 1 final EcoUnity completion badge.
- Lightweight teacher notes and accessibility notes attached to each module.

The first complete prototype module should be SDG 12, Responsible Consumption and Production, because it is practical for ages 10-14 and can be tested through everyday school examples.

## Current App Snapshot

The current app is structured as a Flutter app with Provider state management, Hive-backed local storage through the shared `core` package, and backend-driven content loaded as `core.WebPage` objects.

### App Shell

`lib/main.dart` is the application entry point. It:

- Initializes Flutter bindings.
- Initializes `core.FileStorage`.
- Registers app-specific Hive adapters through `EcoUnityStorage`.
- Recovers from storage schema errors by clearing Hive storage and reinitializing.
- Sets up app-wide providers with `MultiProvider`.
- Uses `MaterialApp` with generated localization delegates, supported locales, `appTheme`, and a global navigator key.
- Uses `LoaderOverlay` to show API activity from `core.ApiClient().isProcessingNotifier`.
- Gates the first screen based on `core.AuthProvider().user`, showing `DashBoard` for logged-in or guest users and `Login` otherwise.

Current app-wide providers:

- `LocaleProvider`
- `core.AuthProvider`
- `core.UserProvider`
- `core.WebPageProvider`
- `EcoUnityBadgeProvider`
- `SelectedPathwayNotifier`
- `core.FileStorage`
- `AppImageProvider`

### Navigation

Navigation is centralized in `lib/src/util/router.dart` through `AppRouter.navigate(...)`.

Current route targets include:

- Dashboard
- Login and register
- Modules and submodules
- Resources
- Pathways
- Video list and video detail
- Wiki article list and article detail
- Slides
- Quiz
- Drag-and-drop challenge
- Challenges
- Badge view
- Achievements
- Settings

Bottom navigation is configured in `lib/src/util/settings.dart`. The active bottom tabs are currently:

- Home
- Modules
- Resources

Several earlier areas, such as pathways, videos, lessons, and challenges, are present in the codebase but currently commented out of the bottom navigation.

### Content Loading

The app uses `core.WebPageProvider` and `pathwayLoadParameters` to load backend pages with fields such as:

- `id`
- `title`
- `pagetitle`
- `textcontents`
- `thumbnailid`
- `pagecategory`
- `maincategory`
- `pageid`
- `video`
- `stage`
- `imagefolders`
- `introductionimage`
- `introductiontext`
- `completionimage`
- `completiontext`
- `form`
- `contentlanguages`

The `Pathway` extension in `lib/src/objects/pathway.dart` adds app-specific behavior to `core.WebPage`, including:

- Typed accessors for title, description, thumbnail, introduction, completion text, parent, type, and sort order.
- Content type mapping from `pagecategory` into `PathwayType`.
- Helpers for module, submodule, resource, and pathway classification.
- Completion status updates.
- Parent completion propagation.
- Badge awarding after pathway completion.
- Backend completion reporting through `addCompletion`.

### Local Progress and Badges

Local progress is stored through `core.FileStorage` and Hive.

Key local objects:

- `PathwayStatusItem`
- `PathwayStatus`
- `PathwayStage`
- `PathwayType`
- `BadgeStatusItem`
- `EcoUnityBadge`

`EcoUnityStorage` registers Hive adapters and normalizes duplicate pathway status entries.

`EcoUnityBadge` extends `core.Badge` and calculates badge completion from required pathways. Badge completion is language-aware, using `contentlanguages` on required pathways to avoid awarding language-specific badges incorrectly.

### Localization

App shell localization uses Flutter generated localization from `lib/l10n`.

Current supported app locales:

- German
- English
- Finnish
- Spanish
- Polish
- Romanian
- Ukrainian

The app base now matches the PDF-required language baseline exactly: English, Polish, Ukrainian, German, Finnish, Romanian, and Spanish. Romanian and Spanish currently have app-shell locale entries and should receive full translation review during content production.

## Planned Architecture

The recommended architecture is an incremental evolution of the current app. The app should keep the existing backend-driven `core.WebPage` and provider approach, while formalizing the SDG module model and separating app concerns more clearly.

### Architectural Layers

#### 1. App Bootstrap Layer

Responsibilities:

- Flutter initialization.
- Hive and `core.FileStorage` setup.
- Adapter registration.
- App-wide provider registration.
- Locale initialization.
- Authentication gate.
- Loader overlay and global navigator setup.

Primary files:

- `lib/main.dart`
- `lib/src/util/ecounity_storage.dart`
- `lib/src/providers/locale_provider.dart`

#### 2. Data and Backend Layer

Responsibilities:

- Fetch structured content from the backend.
- Cache remote content through `core.FileStorage`.
- Load badges and images.
- Sync completion events back to the backend.
- Preserve language-specific content filtering.

Primary files:

- `lib/src/util/settings.dart`
- `lib/src/providers/ecounity_badge_provider.dart`
- `lib/src/util/image_from_url.dart`
- Shared `core` package providers such as `WebPageProvider`, `BadgeProvider`, `ApiClient`, and `FileStorage`.

Planned backend object types:

- SDG Module
- Micro-Learning Resource
- Quiz
- Question
- Reflection Activity
- Practical Challenge
- Comic Link
- Badge
- Language Version
- Teacher Note
- Accessibility Note

#### 3. Domain Model Layer

Responsibilities:

- Convert generic backend objects into app concepts.
- Encapsulate completion rules.
- Encapsulate badge rules.
- Provide typed helpers for SDG metadata and learning activity order.

Current files:

- `lib/src/objects/pathway.dart`
- `lib/src/objects/ecounity_badge.dart`
- `lib/src/objects/pathway_status_item.dart`
- `lib/src/objects/badge_status_item.dart`
- `lib/src/objects/pathway_type.dart`
- `lib/src/objects/pathway_stage.dart`

Recommended additions or refinements:

- Add SDG-specific helpers on `core.WebPage`, for example `sdgNumber`, `sdgTitle`, `learningType`, `teacherNote`, `accessibilityNote`, and `estimatedDuration`.
- Add a small content contract document for expected backend fields.
- Keep `core.WebPage` as the transport object unless the backend model becomes stable enough to justify dedicated Dart models.
- Avoid duplicating backend data into separate app-only models unless the app needs offline editing or complex local transformations.

#### 4. State and Persistence Layer

Responsibilities:

- Keep local completion state responsive.
- Keep selected pathway/module state.
- Store badge notification state.
- Support offline-tolerant reads where cached content exists.
- Provide deterministic progress calculations.

Current files:

- `lib/src/util/ecounity_storage.dart`
- `lib/src/providers/selected_pathway_notifier.dart`
- `lib/src/providers/ecounity_badge_provider.dart`

Planned state model:

- `PathwayStatus.opened` marks started content.
- `PathwayStatus.completed` marks completed content.
- A module is complete when required child activities are complete.
- A badge is complete when all language-relevant required pathways are complete.
- The final EcoUnity badge is complete when the agreed threshold is met, either all 17 modules or a defined subset for pilot testing.

#### 5. Feature Screen Layer

Responsibilities:

- Present content screens for students and teachers.
- Enforce the SDG learning flow.
- Delegate persistence and backend concerns to providers/domain helpers.

Current feature areas:

- `lib/src/screens/dashboard`
- `lib/src/screens/modules`
- `lib/src/screens/resources`
- `lib/src/screens/wiki_articles`
- `lib/src/screens/video_list`
- `lib/src/screens/slides`
- `lib/src/screens/challenges`
- `lib/src/screens/badge_view`
- `lib/src/screens/achievements`
- `lib/src/screens/login`
- `lib/src/screens/register`

Planned feature areas:

- Home Dashboard
- Learn / SDG Module List
- SDG Module Detail
- Micro-Learning Resource
- Interactive Comic Launcher
- Quiz / Reflection
- Practical Challenge
- Progress and Badges
- My Learning Journey
- Teacher Resources
- Settings and Accessibility

#### 6. Shared UI Layer

Responsibilities:

- Provide reusable app chrome and cards.
- Keep visual treatment consistent.
- Handle content HTML, images, introduction/completion pages, and dialogs.

Current shared widgets:

- `ScreenScaffold`
- `bottomNavigation`
- `module_card`
- `submodule_card`
- `pathway_card`
- `resource_card`
- `content_page`
- `introduction_page`
- `completion_page`
- `badge_completion_page`
- `language_selector`
- `popupdialog`
- `notifydialog`

Recommended refinements:

- Use `ScreenScaffold` consistently for standard screens.
- Keep content activity screens focused on one content type.
- Move repeated progress and activity card patterns into reusable widgets.
- Keep HTML rendering contained and avoid spreading HTML parsing behavior across feature screens.

## SDG Learning Flow

Each SDG module should implement the same student-friendly path:

1. Discover
   - Short SDG introduction.
   - Why it matters.
   - Everyday connection to school, home, friends, and community.
   - What young people can do.

2. Explore
   - Interactive comic or scenario link.
   - Realistic dilemma.
   - Sustainability choice.
   - Inclusion or social mixing theme.

3. Learn
   - Three micro-learning resources.
   - MLR 1: Understand the issue.
   - MLR 2: See real-life examples.
   - MLR 3: Take action.

4. Reflect
   - Short quiz, decision task, or reflection prompt.
   - Encouraging feedback.
   - No formal-test feeling.

5. Act
   - Practical challenge.
   - Individual or group mode.
   - Inclusion prompt.
   - Completion confirmation.

6. Progress
   - Progress feedback.
   - SDG badge when the module completion rules are met.
   - Final EcoUnity badge based on agreed global completion rules.

## Content Metadata Contract

Each content item should include enough metadata for filtering, translation, progress, and reporting.

Recommended fields:

- Internal ID
- Title
- Short description
- Content type
- SDG number
- SDG title
- Language
- Age group
- Estimated duration
- Difficulty level or user level
- Learning objective
- Learning type tag
- Inclusion theme
- Sustainability theme
- Partner responsible
- Content status: draft, review, approved, published
- Translation status
- Accessibility status
- Last updated date

Recommended tags:

- SDG tags: SDG 1 through SDG 17.
- Learning type tags: Watch, Read, Play, Reflect, Discuss, Act, Quiz, Challenge.
- Inclusion tags: Teamwork, Empathy, Intercultural dialogue, Anti-discrimination, Accessibility, Conflict resolution, Belonging.
- Sustainability tags: Climate action, Biodiversity, Water, Waste, Energy, Responsible consumption, Food, Community action.
- User level tags: Beginner, Intermediate, Classroom activity, Home activity, Group challenge.

## Screen Plan

### Home Dashboard

Purpose:

- Provide the main entry point for learners.

Should include:

- Continue learning.
- Current or next activity.
- Progress summary.
- Badge preview.
- Latest challenge.
- Access to modules, resources, settings, and teacher content as appropriate.

Current basis:

- `DashBoard`
- `DashboardProgressCard`
- `NextPathway`
- `BadgesWidget`

### Learn / SDG Module List

Purpose:

- Display all 17 SDG modules.

Should include:

- SDG icons.
- Module title.
- Short description.
- Completion status.
- Estimated time.
- Badge status.
- Filters for not started, in progress, completed, and challenges.

Current basis:

- `ModulesView`
- `SubModulesView`

### SDG Module Detail

Purpose:

- Show the full learning path for one SDG module.

Should include:

- SDG title and description.
- Learning objectives.
- Comic card.
- Three MLR cards.
- Quiz or reflection card.
- Challenge card.
- Progress indicator.
- Teacher note link when available.

Current basis:

- `SubModulesView`
- `SelectedPathwayNotifier`
- Existing pathway cards and content type screens.

### Micro-Learning Resource

Purpose:

- Deliver short, visual, mobile-first learning content.

Should include:

- Title.
- Media or content area.
- Key message.
- Interactive element where relevant.
- Reflection question.
- Mark complete button.
- Next activity button.

Current basis:

- `WikiArticle`
- `Video`
- `Slides`
- `ContentPage`
- `WebpageScreen`

### Interactive Comic Launcher

Purpose:

- Connect learners to the branching scenario comic without duplicating the full WP4 repository structure.

Should include:

- Comic cover.
- Scenario summary.
- Characters.
- Related SDG.
- Inclusion theme.
- Sustainability theme.
- Start or continue button.
- Reflection prompt after completion.

Current basis:

- Existing route and content-card patterns.
- May be represented initially as a `WebPage` category or external URL.

### Quiz / Reflection

Purpose:

- Check understanding and encourage reflection.

Should include:

- Question card.
- Multiple choice, true/false, matching, choose-the-best-action, or reflection prompt.
- Feedback after answer.
- Progress bar.
- Final result.
- Continue to challenge button.

Current basis:

- `Quiz`
- quiz components under `lib/src/screens/challenges/quiz/components`
- backend form loading through the shared `core` API.

### Practical Challenge

Purpose:

- Move learning from the app into real-world action.

Should include:

- Challenge title.
- What to do.
- Why it matters.
- Individual or group mode.
- Estimated time.
- Materials needed.
- Inclusion prompt.
- Reflection question.
- Completion checkbox.
- Submit or mark complete button.

Current basis:

- `ChallengesScreen`
- `DragDrop`
- existing pathway completion flow.

### Progress and Badges

Purpose:

- Show achievements without competitive ranking.

Should include:

- Earned badges.
- Locked badges.
- SDG progress.
- Challenge progress.
- Final EcoUnity badge progress.
- No public leaderboard.

Current basis:

- `BadgeView`
- `AchievementsView`
- dashboard badge components.
- `EcoUnityBadge`.

### Teacher Resources

Purpose:

- Support teachers using EcoUnity in class.

Should include:

- How to use the app in lessons.
- SDG lesson links.
- Suggested classroom activities.
- Discussion questions.
- Challenge facilitation notes.
- Accessibility and inclusion tips.

Current basis:

- Can be implemented as a `ResourcesView` subsection first.
- Later can become a dedicated screen and route.

### Settings and Accessibility

Purpose:

- Allow personalization and access to project information.

Should include:

- Language.
- Text size.
- High contrast mode.
- Audio or subtitle options.
- Privacy information.
- About EcoUnity.
- Partner logos.
- Contact or support.

Current basis:

- `SettingsScreen`
- `Privacy`
- `Account`
- `LanguageSelector`
- `LocaleProvider`

## Navigation Plan

The PDF specifications recommend four main bottom tabs:

1. Home
2. Learn
3. Challenges
4. Progress

The current app has Home, Modules, and Resources. The recommended migration is:

- Keep Home as `dashboard`.
- Rename or present Modules as Learn.
- Add Challenges back to bottom navigation when the SDG challenge flow is ready.
- Add Progress as a dedicated entry for achievements and badges.
- Move Resources, Teacher Resources, Settings, About, and Privacy into dashboard cards or the app bar/menu.

This keeps the student journey simple while preserving access to support areas.

## Prototype Plan: SDG 12

The first testable complete module should include:

- SDG 12 introduction.
- Comic scenario: The Zero-Waste School Day.
- MLR 1: What is waste?
- MLR 2: How can schools reduce waste?
- MLR 3: What can I do this week?
- Quiz: 5 short questions.
- Challenge: Create a zero-waste classroom plan.
- Badge: Responsible Consumer Badge.
- Teacher note: How to run the activity in mixed groups.

Completion rules for the prototype:

- Each MLR can be marked complete independently.
- Quiz or reflection completion marks the knowledge check complete.
- Challenge completion marks the active citizenship part complete.
- Completing all required module activities awards the SDG 12 badge.
- The prototype should record local progress immediately and sync completion to the backend when possible.

## Development Steps

### Phase 1: Baseline Stabilization

1. Confirm the Flutter SDK and dependency versions in `pubspec.yaml`.
2. Run `flutter pub get`.
3. Run `dart format` on changed Dart files.
4. Run `dart analyze`.
5. Run `flutter test`.
6. Document any existing failing tests or analyzer findings before feature work.
7. Preserve existing in-progress user changes in the worktree.

### Phase 2: Content Contract and Backend Mapping

1. Agree on backend categories or fields for SDG modules, MLRs, comic links, quizzes, challenges, teacher notes, and accessibility notes.
2. Add or document typed helper accessors in `Pathway` for SDG-specific metadata.
3. Confirm how `pagecategory`, `maincategory`, `pageid`, `stage`, and `contentlanguages` map to the SDG learning flow.
4. Confirm badge `requiredpathways` rules for module badges and the final EcoUnity badge.
5. Create reusable content templates for SDG module, MLR, quiz, reflection, challenge, comic link, badge, teacher note, translation, and accessibility checklist.

### Phase 3: Navigation Alignment

1. Update `navItems` toward Home, Learn, Challenges, and Progress.
2. Keep Resources and Teacher Resources accessible outside the bottom nav.
3. Normalize route names in `AppRouter`.
4. Add missing route targets only when corresponding screens are ready.
5. Add navigation tests or focused widget tests for the main route flows.

### Phase 4: SDG Module List and Detail

1. Adapt `ModulesView` to clearly represent the 17 SDG modules.
2. Add SDG number, icon, estimated time, and completion status.
3. Adapt `SubModulesView` or introduce a module detail view that shows the full Discover -> Explore -> Learn -> Reflect -> Act -> Progress path.
4. Use `SelectedPathwayNotifier` to continue the first incomplete activity.
5. Keep language filtering based on `contentlanguages`.

### Phase 5: Activity Screens

1. Standardize introduction and completion behavior across videos, wiki/articles, slides, quizzes, drag-drop, and future comic/challenge screens.
2. Add a comic launcher screen or content type.
3. Ensure each activity has a clear mark-complete or completion event.
4. Add next-activity navigation based on module order.
5. Keep teacher notes visible but not intrusive for students.

### Phase 6: Progress and Badges

1. Finalize module completion rules.
2. Finalize badge completion rules per language.
3. Add a Progress tab or screen that consolidates achievements, badge progress, and next recommended activity.
4. Add final EcoUnity badge support.
5. Avoid leaderboards and public ranking.
6. Add tests for `EcoUnityStorage.completedPathwaysEqual`, duplicate status normalization, badge completion, and language-specific badge behavior.

### Phase 7: Localization and Content Languages

1. Maintain the PDF-required locale baseline: English, Polish, Ukrainian, German, Finnish, Romanian, and Spanish.
2. Do not add app locales that are outside the approved PDF language set without a project-level scope change.
3. Complete Romanian and Spanish translation review beyond the initial app-shell locale entries.
4. Verify generated localization files and `missingTranslations.txt`.
5. Keep app chrome strings in ARB files.
6. Keep backend content language versions attached to content objects.
7. Add translation status metadata for content production.

### Phase 8: Accessibility and Inclusion

1. Add text size and high contrast settings if not already supported by the design system.
2. Ensure videos have subtitles or transcripts where available.
3. Avoid long text blocks in MLR screens.
4. Ensure content cards work with screen readers.
5. Add inclusion prompts to module, challenge, and reflection templates.
6. Ensure low-cost or no-cost alternatives are available for practical tasks.

### Phase 9: Teacher Resources

1. Add a lightweight Teacher Resources screen or resource subsection.
2. Attach teacher notes to each SDG module.
3. Include discussion questions, group work tips, curriculum links, and inclusion adaptations.
4. Keep teacher content available from both the module detail and a central resource area.

### Phase 10: Pilot Readiness

1. Load the complete SDG 12 prototype content.
2. Test the complete student journey:
   - language selection
   - home
   - SDG module list
   - SDG 12 detail
   - comic link
   - three MLRs
   - quiz or reflection
   - challenge
   - badge award
   - progress screen
   - teacher note
3. Run the app on representative mobile screen sizes.
4. Verify offline/cache behavior for already-loaded content.
5. Collect teacher and partner feedback.
6. Adjust templates before scaling to all 17 modules.

## Testing Strategy

Recommended automated checks:

- Unit tests for storage normalization and completion comparisons.
- Unit tests for badge completion calculations.
- Unit tests for language-specific badge requirements.
- Unit tests for SDG metadata helper parsing.
- Widget tests for bottom navigation and core route entry points.
- Widget tests for module list empty, loading, loaded, and filtered states.
- Widget tests for completion and badge award feedback where practical.
- Localization checks for missing generated strings.

Recommended manual checks:

- Login and guest entry.
- Language switching.
- Content refresh.
- Module completion and parent completion propagation.
- Badge notification shown once per relevant language group.
- SDG 12 end-to-end prototype flow.
- Accessibility settings.
- Teacher resource access.

## Key Implementation Decisions

- Keep the shared `core` package as the source for API, authentication, file storage, web page loading, badges, forms, and images.
- Keep Provider for app state unless there is a separate reason to migrate state management.
- Keep Hive-backed `core.FileStorage` for local user progress and badge notification state.
- Use `core.WebPage` plus typed extension helpers for content until the backend schema stabilizes.
- Prefer incremental screen evolution over a large folder restructure.
- Treat SDG modules as the main learning surface and resources as supporting content.
- Build progress and badges around completion and encouragement, not competition.
- Embed inclusion and accessibility into every content type instead of isolating them in a single section.

## Open Questions

- What exact backend field should represent the SDG number?
- Should teacher resources be public to all users or hidden behind a teacher/classroom mode?
- Should comic links open inside a web view, as an external URL, or as native app content?
- What completion threshold awards the final EcoUnity badge during pilot testing?
- Does the backend need separate object types for MLRs and challenges, or can they remain categorized `WebPage` objects?
- How should practical challenge submissions be represented: local checkbox, reflection text, uploaded evidence, or teacher confirmation?

## Near-Term Definition of Done

The first milestone is complete when:

- The app has a clear Home -> Learn -> SDG 12 -> activity flow.
- SDG 12 has one complete prototype package.
- The three MLRs, quiz/reflection, challenge, badge, and teacher note are visible and usable.
- Completion state is stored locally and badge progress is calculated correctly.
- Language filtering works for prototype content.
- The app passes formatting, analysis, and existing tests, or known failures are documented.
- The architecture can scale to all 17 SDG modules without changing the core flow.
