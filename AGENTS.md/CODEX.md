# CODEX.md — TintTracker Repo Guide (for Codex + humans)  
  
This file is a practical “don’t get lost” guide for working in this repository. It is intentionally direct and prescriptive.  
  
## Non-negotiable starting point  
  
1) Read `PLANS.md` completely.  
2) Read `GUARDRAILS.md` completely.  
3) Only then start changing code.  
  
If `PLANS.md` and `GUARDRAILS.md` disagree, follow `PLANS.md` first and record the conflict in the ExecPlan `Decision Log`.  
  
## What success looks like  
  
TintTracker should feel like Apple made it:  
- predictable navigation  
- consistent layout/components  
- fast data entry  
- reliable saves  
- accessible by default  
- tests that prove key flows work  
  
If it’s prettier but confusing or flaky, it’s worse.  
  
## How to orient yourself in this repo  
  
Start by finding these things (do not assume names, verify them):  
  
1) **App entry point**  
   - Look for `@main` and the root app type (example: `TintTrackerApp.swift` or similar).  
   - Identify the initial view and the Tab container.  
  
2) **Navigation**  
   - Find where `TabView` is defined (likely a `RootTabView`).  
   - Identify how each tab routes to detail screens (NavigationStack, NavigationLink, sheets).  
  
3) **Persistence**  
   - Determine whether this uses SwiftData, Core Data, or custom storage.  
   - Find model types (Inventory items, Clients, Formulas).  
   - Locate the “save” path and any data store layer.  
  
4) **Core screens**  
   - Clients list + client detail  
   - Inventory list + add/edit item  
   - Shopping List  
   - Settings  
  
5) **Design system**  
   - Check whether a design system already exists.  
   - If not, create one (as defined in `PLANS.md`) before you refactor lots of UI.  
  
## Required work style  
  
- Work in small, safe steps.  
- Commit frequently.  
- Keep the app runnable at every milestone.  
- Add tests as you add logic.  
- Make UI consistent through shared components, not repeated one-off styling.  
  
## Navigation rules (repeat, because they get broken)  
  
Only two patterns are allowed:  
  
1) Push navigation (NavigationStack)  
   - For viewing and editing existing items.  
   - Uses system back.  
   - No Cancel button.  
  
2) Sheet presentation  
   - For creating new items and quick-add flows.  
   - Cancel (leading), Save (trailing).  
   - No back arrow.  
   - If dismissing would lose changes, confirm first.  
  
If you see back arrow + Cancel together for the same purpose, fix it.  
  
## Form rules (repeat, because they get messy)  
  
- Required fields must be obvious.  
- Validation must be human-readable.  
- Save is disabled until valid (preferred).  
- Errors never fail silently.  
- Use sensible defaults.  
- Avoid “everything is a giant rounded rectangle.” Prefer native list/form structure + selective emphasis.  
  
## File structure expectations (target shape)  
  
Do not blindly reorganize everything. Move toward this as you refactor:  
  
- `TintTracker/`  
  - `App/` (entry, root navigation/tab container)  
  - `DesignSystem/` (tokens + shared components)  
  - `Models/` (SwiftData/Core Data model types)  
  - `Features/`  
    - `Clients/`  
    - `Inventory/`  
    - `ShoppingList/`  
    - `Settings/`  
  - `Services/` (persistence helpers, import/export, etc.)  
  - `Tests/` and `UITests/` (existing conventions may differ; follow them)  
  
If the repo currently uses a different structure, respect it and migrate gradually.  
  
## Required “first hour” workflow  
  
Before making real changes, do this:  
  
1) Build the project.  
2) Run on a simulator.  
3) Click through every tab and record the top 10 issues in the ExecPlan “Audit Notes” (in `PLANS.md`).  
4) Identify the single worst screen (most inconsistent/cluttered) and refactor it using a new/updated design system.  
5) Commit that refactor as a proof of pattern.  
  
## Commands to run (adjust scheme names after verifying)  
  
From repo root:  
  
- Build (CI-style):  
    xcodebuild -scheme TintTracker -destination 'platform=iOS Simulator,name=iPhone 16' build  
  
- Test:  
    xcodebuild -scheme TintTracker -destination 'platform=iOS Simulator,name=iPhone 16' test  
  
If the scheme is not `TintTracker`, list schemes and use the actual name:  
  
    xcodebuild -list  
  
If your simulator device name differs, list devices:  
  
    xcrun simctl list devices  
  
## Commit conventions  
  
Commit early and often. Use messages that explain intent:  
  
- `chore: rename app to TintTracker`  
- `ui: add Tint design tokens + section header component`  
- `ui: refactor New Lightener form to standardized form layout`  
- `nav: normalize sheet vs push conventions across Inventory`  
- `feat: add batch shade entry for color lines`  
- `test: add validation tests for inventory item creation`  
- `fix: prevent duplicate shade creation (case-insensitive)`  
  
Each commit should keep the app building. If you must do a larger refactor, use a sequence of commits that keep it compiling.  
  
## Testing requirements (minimum)  
  
- Unit tests:  
  - validation rules  
  - batch shade parsing  
  - duplicate detection (case-insensitive)  
  
- UI tests:  
  - create client  
  - add inventory item  
  - batch shade entry save  
  
Add accessibility identifiers for UI test reliability.  
  
## How to handle unknowns  
  
If you find something that contradicts the plan (e.g., the data model makes “batch shades” hard):  
- Build a tiny prototype (a spike).  
- Record what you discovered in `Surprises & Discoveries`.  
- Record the decision you make in `Decision Log`.  
- Update the plan so a future contributor can restart from only the plan.  
  
Do not leave hidden “tribal knowledge” in your head.  
  
## When to stop and ask the user  
  
Only stop if you hit a true decision the user must make, such as:  
- adding a third-party dependency  
- changing subscription/business logic  
- deleting a major feature  
- a breaking data migration with data-loss risk  
  
Otherwise, keep moving milestone-by-milestone.  
  
## End note  
  
TintTracker is meant to be used mid-appointment. That means: clarity, speed, reliability. Anything else is decorative.  
