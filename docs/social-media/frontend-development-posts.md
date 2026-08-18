# EcoUnity App Front-End Development Social Posts

These drafts pair with the backend development post series. The framing is intentionally learner-facing and project-facing: the posts explain the native app work as a continuation of previous Erasmus+ digital learning delivery, reusable implementation foundations, and EcoUnity-specific learning innovation.

## Visual Assets

Generated/editable schematics:

- `docs/social-media/frontend-development-01-design-before-code.svg`
- `docs/social-media/frontend-development-02-reusable-foundation.svg`
- `docs/social-media/frontend-development-03-native-comic-player.svg`
- `docs/social-media/frontend-development-04-multilingual-offline.svg`

Export-ready PNG versions:

- `docs/social-media/png/frontend-development-01-design-before-code.png`
- `docs/social-media/png/frontend-development-02-reusable-foundation.png`
- `docs/social-media/png/frontend-development-03-native-comic-player.png`
- `docs/social-media/png/frontend-development-04-multilingual-offline.png`

Existing MVP screen exports that can be used directly or inserted into carousel slides:

- `docs/MVP screens/01-welcome-language.png`
- `docs/MVP screens/06-dashboard.png`
- `docs/MVP screens/07-sdg-list.png`
- `docs/MVP screens/08-sdg-detail-sdg-12.png`
- `docs/MVP screens/10-quiz-reflection.png`
- `docs/MVP screens/12-badges-and-progress.png`

## Post 1: Designing the Learner Journey Before Implementation

The EcoUnity mobile app development has started from an important front-end principle: before building screens, we need a clear visual target for the learner experience.

The first native app design work has focused on turning the EcoUnity learning model into mobile views that feel understandable, friendly and age-appropriate for the target learners.

This includes:

- language selection and onboarding,
- an SDG learning dashboard,
- module and activity views,
- quizzes and reflections,
- challenges,
- progress and badges.

The Figma MVP designs help the team review the learner journey before implementation details take over. They also create a shared visual language for developers, educators and project partners.

This matters because EcoUnity is not only delivering content. It is shaping how young learners meet sustainability topics, make choices and see their progress.

Good mobile learning design begins before the first production screen is built.

**Pairs with backend post:** Post 8, connecting curriculum, comics and mobile app.

**Suggested visual:** `docs/social-media/frontend-development-01-design-before-code.svg`

**Alternative visual:** Figma MVP screenshot set using `01-welcome-language.png`, `06-dashboard.png` and `08-sdg-detail-sdg-12.png`.

**Alt text:** EcoUnity front-end workflow showing Figma MVP screens becoming reusable Flutter components and native learner views.

**Hashtags:** `#EcoUnity #MobileLearning #LearningDesign #SustainabilityEducation #ErasmusPlus`

---

## Post 2: Building Efficiently From Reusable Mobile Foundations

EcoUnity benefits from front-end experience gathered through earlier Erasmus+ digital learning projects.

Rather than starting every technical choice from zero, the native app work builds on reusable foundations for mobile navigation, multilingual interfaces, API-based content delivery, progress tracking and classroom-friendly learning flows.

That gives the development process two advantages:

- more time can be spent adapting the experience to EcoUnity's educational goals,
- project resources can be used efficiently while still creating a dedicated EcoUnity app.

For learners, this should feel simple: open the app, choose a language, follow the SDG learning path and continue through stories, activities and challenges.

For the project team, the underlying goal is more complex: make sure reusable technical work supports new EcoUnity content without making the app feel generic.

Efficiency is not about doing less. It is about reusing the right foundations so the project can focus on what makes EcoUnity distinctive.

**Pairs with backend posts:** Post 1, building the digital foundation; Post 3, supporting partner authoring.

**Suggested visual:** `docs/social-media/frontend-development-02-reusable-foundation.svg`

**Alt text:** Diagram showing previous Erasmus+ mobile learning experience and the EcoUnity backend feeding into a reusable native app foundation.

**Hashtags:** `#EcoUnity #DigitalLearning #MobileAppDevelopment #ErasmusPlus #ReusableTechnology`

---

## Post 3: Making the App Feel Right for Young Learners

Visual design is not decoration in a learning app. It shapes whether learners understand where they are, what they can do next and how confident they feel while using the app.

For EcoUnity, the front-end direction is light, clear and approachable. The design uses strong SDG colour signals, readable typography, generous tap targets and simple progress cues.

The aim is to support learners without overwhelming them.

This is especially important because the app combines several activity types:

- short learning resources,
- quizzes and reflections,
- practical challenges,
- badges and progress,
- interactive comics.

Each screen needs to feel connected to the same learning journey, while still making the current task clear.

Age-appropriate design also means avoiding a style that feels too corporate or too childish. EcoUnity should feel curious, active and supportive: a learning space where sustainability topics can become understandable and discussable.

**Pairs with backend post:** Post 4, making quality part of the learning process.

**Suggested visual:** Use Figma MVP exports `06-dashboard.png`, `07-sdg-list.png`, `10-quiz-reflection.png` and `12-badges-and-progress.png` as a carousel.

**Alt text:** EcoUnity mobile app MVP screens showing dashboard, SDG list, quiz/reflection and progress views with a light learner-friendly design.

**Hashtags:** `#EcoUnity #UXDesign #InclusiveLearning #SustainabilityEducation #MobileLearning`

---

## Post 4: Bringing Interactive Comics Into the Native App

One of the most distinctive EcoUnity app features is the move from static learning materials to interactive native comic experiences.

The backend can provide scenes, backgrounds, characters, props, dialogue, audio timing and learner decisions. The front-end task is to turn that structured data into a smooth mobile story.

In the native app, a comic scene can be rendered from layers:

- a background image,
- character and prop layers,
- speech bubbles,
- optional spoken dialogue,
- decision buttons that move the learner through the story.

This approach makes the comic more flexible than a fixed image or embedded document. It can adapt to screen size, language, review changes and future content updates.

For learners, the result should be simple: follow the story, listen or read, make a choice and see what happens.

For the project, it creates an innovative bridge between WP4 storytelling and the WP3 SDG learning pathways.

**Pairs with backend posts:** Post 5, bringing comics into the app; Post 6, scene layers; Post 7, dialogue and audio.

**Suggested visual:** `docs/social-media/frontend-development-03-native-comic-player.svg`

**Alt text:** Native EcoUnity comic player schematic showing backend scene data rendered as a mobile comic with layers, speech timing, audio and decisions.

**Hashtags:** `#EcoUnity #InteractiveLearning #EducationalComics #MobileLearning #SDGs`

---

## Post 5: Preparing for Multilingual and Offline-Capable Learning

EcoUnity is a European learning project, so the mobile app must treat multilingual content as part of the core experience.

The front-end work is being shaped around content that can be updated from the backend, reviewed by partners and displayed in the learner's selected language.

This creates several practical challenges:

- translated labels can be much longer than the original,
- learning content can be updated after the app is installed,
- media and comic scenes need to remain connected to the right language version,
- classroom use may require content to remain available when the internet connection is not reliable.

Designing for these constraints early helps avoid treating translation, updates and offline use as afterthoughts.

The goal is that learners can move through the same EcoUnity learning journey in the supported project languages, while the app keeps the experience consistent and usable.

**Pairs with backend posts:** Post 3, portable content packages; Post 7, multilingual dialogue; Post 8, app-ready delivery.

**Suggested visual:** `docs/social-media/frontend-development-04-multilingual-offline.svg`

**Alt text:** EcoUnity app delivery diagram showing backend content updates, translation versions, local app cache and offline-capable mobile learning.

**Hashtags:** `#EcoUnity #MultilingualLearning #OfflineLearning #DigitalEducation #ErasmusPlus`

---

## Post 6: Building Review Into the App Without Putting It in the Learner's Way

EcoUnity learning content needs to be reviewed by project partners before it reaches learners.

The native app therefore also needs a careful distinction between the learner experience and the partner review experience.

For learners, login should not be the focus. The app should open into the learning journey as directly as possible.

For authorised project partners, login can later enable review tools inside learning and activity screens. These tools can support practical review tasks such as marking content as reviewed or identifying material that needs changes.

This connects the mobile app to the wider EcoUnity quality workflow without making review controls visible to the main learner audience.

It is a small design decision with a large usability impact: keep the learner path simple, while still supporting the project team as content moves through review, translation and publication.

**Pairs with backend post:** Post 4, making quality part of the learning process.

**Suggested visual:** Use `docs/MVP screens/01-welcome-language.png` beside a simple review-status card, or adapt `frontend-development-02-reusable-foundation.svg`.

**Alt text:** EcoUnity app concept showing a learner-first welcome screen with optional partner login leading to review controls for authorised users.

**Hashtags:** `#EcoUnity #LearningQuality #UXDesign #DigitalLearning #ErasmusPlus`
