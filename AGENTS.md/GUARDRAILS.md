# TintTracker Guardrails  
  
This file is non-negotiable. Any agent or contributor working on TintTracker must follow these rules.  
  
## The Goal  
  
TintTracker must feel like Apple built it:  
- Consistent navigation and layout  
- Clear hierarchy  
- Fast data entry  
- Reliable saves and updates  
- Accessible by default  
- Tested and production-ready  
  
If a change makes the app prettier but less reliable, it is a bad change.  
  
---  
  
## Golden Rules  
  
1) **Consistency beats creativity**  
- Do not invent new UI styles per screen.  
- Use shared components and tokens.  
  
2) **Nothing fails silently**  
- Every save must either succeed or show a human-readable error message.  
- Never swallow errors.  
  
3) **Two navigation patterns only**  
- **Push navigation** (NavigationStack) for viewing and editing existing items.  
  - Use the system back button.  
  - No “Cancel” button for push flows.  
- **Sheet presentation** for creating new items and quick add flows.  
  - Leading: Cancel  
  - Trailing: Save  
  - No back arrow on sheets.  
  - Unsaved changes confirmation required if dismissal would lose edits.  
  
4) **Forms must be fast**  
- Required fields are clearly indicated.  
- Validation is live or on Save, but errors are shown inline in plain English.  
- Save is disabled until the form is valid (preferred).  
- Use sensible defaults instead of starting everything at 0.00 unless truly unknown.  
  
5) **Accessibility is mandatory**  
- Dynamic Type supported everywhere (no clipped labels, no fixed heights that break).  
- VoiceOver labels on interactive controls.  
- Good contrast and readable hit targets.  
- Keyboard focus management for rapid entry where it matters (especially batch entry).  
  
6) **No third-party dependencies without approval**  
- If a library is needed, stop and ask. Otherwise do it with system frameworks.  
  
7) **Refactors are allowed**  
- If fixing something properly requires moving files, renaming types, or restructuring folders, do it.  
- But keep changes incremental, commit often, and keep tests passing.  
  
---  
  
## Naming and Brand  
  
- The app name is **TintTracker**.  
- Remove all old brand references in:  
  - UI text  
  - bundle display name  
  - project file settings  
  - documentation  
  - comments where it matters  
- Internal module/repo names can be left alone only if changing them would be overly risky, but user-facing text must be correct.  
  
---  
  
## Design System Requirements  
  
A minimal design system must exist and be used.  
  
Must include:  
- Spacing scale (few values, reused everywhere)  
- Corner radius rules (2–3 values max)  
- Typography usage rules (system fonts; consistent title/header/body usage)  
- Shared components:  
  - Section header  
  - Form row patterns  
  - Primary/secondary actions  
  - Empty state  
  - Inline error text  
  - (Optional) card container used sparingly  
  
Anti-patterns:  
- Every input wrapped in a giant rounded rectangle “because style.”  
- Nested cards inside cards inside cards.  
- Inconsistent paddings and random corner radii per screen.  
  
---  
  
## Data Integrity Rules  
  
- Saves are atomic when possible (all-or-nothing).  
- Prevent accidental duplicates for inventory items where duplicates create confusion.  
- When batch-creating items (Color Line + Shades):  
  - Shared fields must apply to all shades.  
  - Shade names must be unique within the batch (case-insensitive).  
  - If saving would create duplicates against existing inventory, block save by default unless the app already has a proven “merge stock” feature.  
  
---  
  
## Testing Requirements  
  
Minimum required tests:  
- Unit tests for:  
  - Validation rules (required fields, numeric constraints)  
  - Batch shade parsing (newline import, trimming, blank line removal)  
  - Duplicate detection (case-insensitive)  
- UI tests for:  
  - Create a client  
  - Add an inventory item  
  - Batch shade entry save success  
  
Every significant bug fix should get a test if feasible.  
  
---  
  
## Definition of Done (DoD)  
  
A feature is “done” only when:  
- The UX is consistent with the rest of TintTracker.  
- Navigation follows the two-pattern rule.  
- It works end-to-end on simulator (and device if available).  
- Errors are handled and visible to the user.  
- Accessibility basics are in place.  
- Tests pass, and new tests exist for new logic.  
  
---  
  
## Release Readiness Checklist  
  
Before calling the app production-ready:  
- No crashes in normal flows  
- No dead-end screens  
- Empty states exist for all primary lists  
- Saving always gives clear outcome (success or error)  
- Performance is acceptable (no noticeable stutters when navigating lists/forms)  
- Privacy usage strings exist for any permission used (camera/photos/etc.)  
- App follows Apple HIG patterns for lists, forms, sheets, and navigation  
  
---  
  
## Agent Operating Rules (for Codex / automated work)  
  
- Read `PLANS.md` first, then follow it exactly.  
- Update the ExecPlan living sections as you go:  
  - Progress (with timestamps)  
  - Surprises & Discoveries  
  - Decision Log  
  - Outcomes & Retrospective  
- Commit frequently with clear messages.  
- Don’t ask the user “what next.” Proceed milestone-by-milestone.  
- If blocked by a decision that only the user can make (e.g., adding a new dependency), stop and ask that single question only.  
  
---  
  
## If You Break These Rules  
  
Undo it. This app is meant to be used while someone’s hands are full of bleach and panic. It needs to be clean, predictable, and bulletproof.  
