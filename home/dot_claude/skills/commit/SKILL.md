---
name: commit
description: Craft git commit messages for any repo. Always use when writing, reviewing, or executing a git commit. Enforces conventional commits with a 72-char header limit and a structured body that inventories every change by workstream.
---

# Commit Style

## Rules

- **Header** ≤ 72 chars — hard limit; trim scope or subject if needed
- **Type** must be one of: `feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert`
- **Imperative mood** in subject: "add", "fix", "remove" — not "added", "fixes"
- **No trailing period** on subject line
- **No empty subject**
- **Body is required** for any commit touching more than 1-2 files. Only truly trivial single-file changes (typo, EOF newline) may omit the body.
- **Wrap body lines at 72 chars**

## Format

```
<type>(<optional scope>): <what changed>

<structured body — see Body Structure below>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## Body Structure

Scale the body to match the commit size:

**Small commits (1-5 files):** 2-5 lines explaining what changed and why.

**Medium commits (5-20 files):** Group changes by category with bullet points. Include file counts and test status.

**Large commits (20+ files):** Full structured inventory:

1. **Opening line** — one sentence naming the initiative/phase/ticket this serves
2. **Workstream sections** — group related changes under labeled headers using bullet lists:
   - Name each workstream (e.g., "Catalog services:", "Auth enhancements:", "Cross-cutting fixes:")
   - List specific files, counts, and what they do — not vague summaries
   - Call out new vs modified files when the distinction matters
3. **Test status** — file count and pass/fail at the bottom
4. **No prose paragraphs** — use bullets and short phrases, not sentences

The body should let a reviewer understand the full scope without reading the diff. Be specific: "9 catalog service files" not "some services"; "queryCityById, querySpecialtyById" not "convenience methods".

## Voice: polite Linus

- State what and why — not how
- No "this commit", no "I", no "we", no filler
- If something was broken, say it was broken — blunt but civil
- Name real files, real methods, real counts — not abstractions

## .planning/ awareness

Never stage `.planning/` files unless GSD tooling explicitly handles it.
Planning artifacts are local-only and must not pollute history.

## Examples

### Small commit

```
fix(booking): reject transition when slot already released

transactWrite succeeded even with no ReservedSlot, leaving bookings
stuck in AWAITING_PAYMENT. Condition check added so it fails fast.
```

### Medium commit

```
feat(search): add availability masks and search quality

- TopCaregiverConfigCache: LRU cache for caregiver config lookups
- ZeroResultRecorder: tracks zero-result queries for analytics
- hospitalCoverageFilter: filters caregivers by hospital coverage area
- searchFunction: wire new filters into OpenSearch query builder
- 4 test files added, 591 tests passing

Enables availability-aware search results and tracks search quality
gaps for product iteration.
```

### Large commit

```
feat(onboarding): port catalog, auth, and onboarding from admin-develop

Phase 7 of the admin-develop integration plan. Three workstreams:

Catalog services & assets (Task 7.1):
- 6 JSON catalog assets (pricing guidance, bundles, experience,
  marketplace metadata, caregiver guidance, starter bundles)
- 9 catalog service files: pricing guidance/utils, offering pricing,
  bundles, service experience/UI, onboarding catalog, caregiver
  guidance, service copy resolver
- 6 catalog test files covering pricing, guidance, and copy resolution
- pubspec: register assets/catalog/ bundle, bump flutter_stripe 11.5.0

Auth enhancements (Task 7.2):
- profile_setup_gate: post-auth profile completion check
- signup_provider: auth flow state management (ChangeNotifier)
- social_sign_in_exceptions: typed social auth error handling
- auth_identity_attributes_reader + bootstrap service with tests

Onboarding screens & widgets (Task 7.3):
- Step-based onboarding: business_setup, license steps with widgets
- 21 reusable widgets: activation checklist, pricing panels,
  document upload/preview, hospital coverage, profile strength
- Profile strength service with weighted scoring
- 11 feature flags in OnboardingConstants (disabled until backend)
- 3 onboarding test files + caregiver_verification_test

Cross-cutting: flat-ID reference fixes after relationship removal:
- AddressService.formatAddress/formatShortAddress accept cityName param
- Booking components resolve specialty/city names via API lookups
- ApiManager: add queryCityById, querySpecialtyById

96 files changed, 687 tests passing.
```

## Anti-patterns

| Bad | Why |
|-----|-----|
| `fixed stuff` | No type, no scope, no information |
| `WIP` | Open a draft PR instead |
| `minor changes` | Describe what actually changed |
| Header > 72 chars | Will fail commitlint; trim scope or subject |
| Body restates the diff | Explain the problem, not the solution |
| "various improvements" | Name the actual changes |
| "updated services" | Which services? How many? What changed? |
| 1-line body on a 50-file commit | Body must scale with commit size |
