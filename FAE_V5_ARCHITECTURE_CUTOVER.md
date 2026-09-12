# Fae 5 Architecture Cutover Plan

## Purpose

Complete the switch from the legacy Slim, Simple Form, Sprockets, and jQuery admin
architecture to the generated Inertia and Vue architecture already established in this
repository.

This document is the execution plan for the final cutover phase. Update it as decisions
or scope change so future sessions can use it as the source of truth.

## Release Assumption

Fae 5 is a major-version release for new host applications. Existing Fae host apps do
not need an in-place upgrade path.

Therefore:

- Inertia and Vue will be the only Fae 5 admin architecture.
- Vite is a required part of every Fae 5 host application.
- Generated Vue resource pages are application source code that host apps own and edit.
- No migration generator for arbitrary legacy Slim overrides is required.
- No dual-runtime release, deprecation cycle, or long-term compatibility layer is
  required.
- Legacy code may be removed once the dummy app and engine-owned screens prove the new
  architecture's intended feature set.

## Target Architecture

### Resource pages

Top-level resources use generated, editable pages under:

```text
app/frontend/pages/Admin/<PluralResource>/Form.vue
app/frontend/pages/Admin/<PluralResource>/Index.vue
```

Controllers render explicit page names such as `Admin/Cars/Form` and
`Admin/Cars/Index`.

Resource pages own composition and field order. They use semantic components such as
`FaeInput`, `FaeImageInput`, `FaeFileInput`, and `FaeRankedSelect`. They do not own form
state, submission, validation errors, draft handling, language visibility, translation,
or other shared behavior.

### Shared shells

`app/frontend/pages/Fae/Form.vue` and `app/frontend/pages/Fae/Index.vue` own shared
behavior and remain generic fallbacks. `provideFaeFormContext` exposes the parent form
state to fields composed by resource pages.

Nested-table and flex-component forms resolve generated resource pages through the
merged engine and host page registry. Generic descriptor rendering remains a fallback
inside the shared nested form shell.

### Controllers

After all behavior is proven:

- Fold `Fae::InertiaRenderable` into `Fae::BaseController`.
- Fold nested Inertia behavior into the appropriate nested and flex base controllers.
- Remove `request.inertia?` compatibility branches and legacy `super` fallbacks.
- Make Inertia serialization and rendering the normal controller contract rather than
  an opt-in concern.

### Host application contract

Every Fae 5 host app must provide:

- Vite and Vue dependencies.
- The Fae frontend entry point.
- `createFaeApp({ pages })` with the host page registry.
- Production Vite asset compilation and deployment.
- Generated resource pages for application-owned resources.

## Phase 1: Define and Complete Feature Parity

Use the dummy application as the acceptance fixture for the feature set Fae 5 intends
to support. Do not preserve a legacy helper merely because it existed; decide whether
the capability belongs in Fae 5, should become a resource-specific component, or should
be removed.

The complex Releases and Wines forms are the primary parity inventory. Resolve the
following legacy capabilities:

- Prefix and suffix fields.
- Radio groups and checkbox collections.
- Date ranges.
- Color picker.
- Grouped selects.
- Two-pane multiselect.
- Video URL fields.
- Rich HTML editing.
- Hidden and form-manager-specific behavior.
- Advanced image options, including captions where supported.
- CTA objects.
- SEO sets.
- Association quick-create variations.
- CSV export and custom index actions.

Completed in the Release/Wine increment:

- Grouped selects use `FaeGroupedSelect` with server-serialized option groups. Release
  exercises this with Wines grouped alphabetically.
- Two-pane multiselects use `FaeTwoPaneMultiselect`; Release exercises this with Selling
  Points and submits through the existing `*_ids` normalization path.
- CTA objects use `FaeCtaInput` and submit label, link, and alt text through nested
  attributes. Wine exercises three localized CTA associations.
- Release and Wine now have resource-specific Form and Index pages. Wine's regional
  Winemaker tables were also moved to the nested Inertia flow, including their hidden
  `region_type` values.

For each capability, choose one outcome and record it here:

1. Add a reusable semantic Vue component.
2. Implement it as explicit resource-page composition.
3. Replace it with a simpler native control.
4. Exclude it from Fae 5.

### Phase 1 completion gate

- Every supported field type has a documented Vue implementation.
- Releases and Wines can be represented without legacy form helpers.
- Unsupported legacy features have explicit removal decisions.
- Shared components preserve accessibility, errors, draft behavior, and form context.

## Phase 2: Convert Every Resource

Convert simple top-level resources first, then nested resources, then special engine and
flex resources. For each top-level resource:

1. Define its index columns and form field descriptors.
2. Render explicit resource-specific Index and Form page names.
3. Generate or create editable `Index.vue` and `Form.vue` pages.
4. Compose fields explicitly in the resource form.
5. Port custom filtering, grouping, sorting, exports, and actions.
6. Verify create, update, validation, draft cancellation, deletion, authorization,
   localized fields, and assets as applicable.

For nested and flex resources:

1. Use the nested Inertia write path.
2. Generate a conventional nested or flex Form page.
3. Verify parent refresh, error bags, add, edit, cancel, delete, and sorting.
4. Retain generic descriptor rendering only as a deliberate fallback.

### Current converted examples

- Beers and ranked aromas.
- Poly Things.
- Articles, Article Categories, and Article Subcategories.
- Flex component examples including Hero Components, Text Components, Knobs, Zig Zag
  Components, and Zig Zag Items.
- Trucks.
- Cars and Car Categories.
- Spirits and Sub Spirits.
- Releases.
- Wines and Winemakers.

### Remaining inventory to verify and convert

Re-audit controllers before beginning this phase. At the time this plan was written,
the legacy dummy-app surface included resources such as:

- Acclaims.
- Aromas and Sub Aromas.
- Cats.
- Events.
- Jerseys.
- Locations.
- Milestones.
- People.
- Players.
- Release Notes.
- Selling Points.
- Teams.
- Validation Testers.
- Varietals.

Also audit engine-owned singleton, deploy, options, site, user, asset, and flex screens.
Some already use Inertia but may still have legacy templates that should not be mistaken
for active routes.

### Phase 2 completion gate

- Every reachable admin route renders through the Inertia layout.
- Every top-level resource has an explicit generated resource page.
- Every nested and flex resource resolves its generated page or an intentional fallback.
- No reachable admin workflow depends on a Slim form, legacy modal, or jQuery behavior.
- The dummy app exercises every supported resource and field pattern.

## Phase 3: Make the New Architecture Native

Once all resources run through Inertia:

1. Move Inertia rendering into `Fae::BaseController`.
2. Move nested behavior into the nested and flex base controllers.
3. Remove per-controller `include Fae::InertiaRenderable` declarations.
4. Remove compatibility branches that delegate non-Inertia requests to legacy actions.
5. Simplify routes and response handling around a single frontend architecture.
6. Ensure authentication, dashboard, navigation, settings, singleton pages, errors, and
   utility endpoints follow the intended Fae 5 contract.

### Phase 3 completion gate

- A newly generated controller works without opt-in concerns.
- Direct browser visits and Inertia visits follow one controller path.
- Nested and flex controllers have one write path.
- No application behavior requires the legacy admin layout.

## Phase 4: Harden the Release

Add durable automated coverage before deleting the compatibility stack:

- Request specs for Inertia page names and serialized props.
- Controller specs for create, update, validation errors, drafts, and error bags.
- Component tests for shared field types and form context.
- End-to-end tests for nested forms, flex forms, uploads, translation, ranking,
  quick-create, and unsaved-change guards.
- Generator tests for controllers and all generated Vue page variants.
- A production Vite build in CI.
- A fixture host app that demonstrates page overrides through `createFaeApp({ pages })`.

Update installation, generator, controller, frontend override, and feature documentation
for greenfield Fae 5 applications. Document the supported public component API and the
boundary between generated composition and shared shell behavior.

### Phase 4 completion gate

- CI builds production frontend assets.
- Core workflows have repeatable automated coverage.
- A clean host app can install Fae 5, generate a resource, and run it without legacy
  frontend dependencies.
- Documentation describes only the Fae 5 architecture unless historical context is
  explicitly useful.

## Phase 5: Delete the Legacy Stack

Perform this cleanup only after the earlier completion gates pass:

- Delete legacy Slim admin forms, indexes, and shared form partials.
- Delete legacy form and view helpers such as `fae_input`, `fae_association`,
  `fae_image_form`, and `fae_ranked_select`.
- Delete legacy nested AJAX behavior.
- Delete obsolete Slim generator templates and dormant generation methods.
- Delete jQuery form manager, validation, uploader, modal, language, and navigation code.
- Remove the legacy admin application layout.
- Remove unused Sprockets admin bundles.
- Remove `jquery-rails`, Simple Form, Slim, and related dependencies when no remaining
  non-admin runtime requires them.
- Remove compatibility concerns and dead controller branches.

Server-rendered static error pages may remain if they are useful independently of the
admin application. The cutover requires all admin workflows to use Inertia and Vue; it
does not require converting unrelated static responses into SPA pages.

### Phase 5 completion gate

- Searches find no active legacy helper calls or legacy admin JavaScript entry points.
- The application boots, builds, and passes tests without the removed gems and packages.
- Every admin route works with only the Vite-powered layout.
- A fresh scaffold produces no Slim or jQuery artifacts.

## Generator Requirements

The scaffold generator must become the canonical Fae 5 resource path:

- Generate both resource `Form.vue` and `Index.vue` pages.
- Generate nested and flex form pages consistently.
- Map every supported type to a semantic Vue component.
- Infer slug sources where appropriate.
- Emit a clear warning or fail when a requested field type is unsupported.
- Remove legacy template-engine options and dormant Slim generation.
- Test generated controller and page output.
- Never overwrite application-owned resource pages during routine updates.

Before editing `lib/generators/fae/base_generator.rb`, reread it. It changed externally
during the architecture work and should not be modified from remembered state.

## Validation Workflow

Use Docker Compose for authoritative checks:

```sh
docker compose exec -T vite npx vite build
docker compose exec -w /app -e RAILS_ENV=test app bundle exec rspec
```

Use focused request or component tests while iterating, then run the broader suite at
phase gates. Verify representative workflows in the browser, including console warnings
and errors. New engine page files may require restarting the Vite service because the
engine page glob is outside the dummy app's Vite root.

## Guardrails

- Preserve generated resource pages as the composition layer; do not move resource
  layout back into a monolithic schema renderer.
- Keep generic shared pages as useful fallbacks, not the primary customization model.
- Keep state and cross-resource behavior in shared shells and composables.
- Prefer existing semantic components before adding another abstraction.
- Do not retain legacy dependencies solely for upgrade compatibility; this is a major
  release without an in-place host-app migration requirement.
- Do not remove legacy code before its reachable replacement is verified.
- Do not broaden Fae 5 parity by accident. Explicitly accept, replace, or reject each
  historical capability.

## Definition of Done

The architecture cutover is complete when:

- Inertia and Vue power every reachable Fae admin workflow.
- Resource-specific generated Vue pages are the standard composition API.
- Base controllers natively implement the Inertia contract.
- Nested tables and flex components use the same architecture.
- New host apps require only the Fae 5 Vite/Vue frontend contract.
- Generators produce no legacy frontend artifacts.
- The legacy Slim, Simple Form, jQuery, and admin Sprockets stack is absent.
- CI and the dummy app prove the complete supported Fae 5 feature set.