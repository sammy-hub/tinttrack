# TintTracker — Apple-Quality Production Execution Plan  
  
This ExecPlan is a living document.    
The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.  
  
This repository includes a process file at `PLANS.md` (repo root). This document must be maintained in accordance with that file.  
  
---  
  
## Purpose / Big Picture  
  
TintTracker is a professional iOS app for hairstylists to manage:  
  
- Client records    
- Hair color formulas    
- Color inventory (including bulk shade entry)    
- Product cost tracking    
- Stock usage and shopping lists    
  
The current app is functional but visually inconsistent, cluttered, and difficult to reason about. Screens follow different navigation rules, UI components vary wildly, and some flows feel unfinished or unreliable.  
  
After completing this plan, TintTracker should feel like **Apple designed it internally**:  
  
- Clean hierarchy  
- Predictable navigation  
- Zero UI confusion  
- Extremely fast data entry  
- Rock-solid persistence  
- Fully compliant with Apple’s Human Interface Guidelines  
- Production-ready for App Store submission  
  
A user should be able to install the app and instantly understand:  
  
- Where they are  
- What they can do  
- What will happen when they tap something  
- Whether their data saved successfully  
  
No guessing. No clutter. No jank.  
  
---  
  
## Product Principles (Non-Negotiable)  
  
TintTracker must obey the following rules at all times:  
  
1. **Consistency beats creativity**  
   - No one-off UI decisions.  
   - Every screen must feel related.  
  
2. **Apple HIG over personal preference**  
   - If Apple recommends it, we do it.  
   - If Apple discourages it, we remove it.  
  
3. **Speed matters**  
   - Hairstylists use this app while working.  
   - Data entry must be fast, not decorative.  
  
4. **Forms must never feel heavy**  
   - Fewer containers.  
   - Fewer borders.  
   - More hierarchy.  
  
5. **Nothing fails silently**  
   - Every save succeeds or explains why it didn’t.  
  
6. **The UI should disappear**  
   - The user should think about hair, not the app.  
  
---  
  
## Progress  
  
- [ ] (2026-01-17) Read and confirm all PLANS.md rules.  
- [ ] (2026-01-17) Run the current app and document pain points.  
- [ ] (2026-01-17) Create TintTracker Design System.  
- [ ] (2026-01-17) Normalize navigation patterns.  
- [ ] (2026-01-17) Refactor all forms to shared components.  
- [ ] (2026-01-17) Rebuild Inventory flows including batch shade entry.  
- [ ] (2026-01-17) Clean up Clients UI and Custom Fields system.  
- [ ] (2026-01-17) Add empty states, loading states, and error states.  
- [ ] (2026-01-17) Add accessibility and testing.  
- [ ] (2026-01-17) Final production-readiness audit.  
  
---  
  
## Surprises & Discoveries  
  
(To be updated during development.)  
  
- Observation:  
- Evidence:  
  
---  
  
## Decision Log  
  
- **Decision:** Rename product everywhere to TintTracker    
  **Rationale:** Final brand decision. All references to previous names must be removed.    
  **Date:** 2026-01-17  
  
- **Decision:** Codex is allowed to refactor views, models, navigation, and folder structure.    
  **Rationale:** Incremental fixes cannot solve structural inconsistency.    
  **Date:** 2026-01-17  
  
- **Decision:** Introduce a Design System layer.    
  **Rationale:** Prevent future UI drift and inconsistency.    
  **Date:** 2026-01-17  
  
---  
  
## Context and Orientation  
  
TintTracker is a SwiftUI-first iOS app using modern Apple frameworks.  
  
Expected architecture:  
  
- SwiftUI  
- NavigationStack  
- @Observable state models  
- SwiftData or Core Data persistence  
- No UIKit unless absolutely required  
- No third-party UI frameworks  
  
Primary tabs:  
  
- Clients  
- Inventory  
- Shopping List  
- Settings  
  
Current problems observed:  
  
- Inconsistent navigation bars  
- Cancel + back button appearing together  
- Oversized card containers everywhere  
- Inconsistent spacing  
- Forms requiring excessive taps  
- Weak visual hierarchy  
- UI feels heavier than Apple apps  
  
---  
  
## Design System (Mandatory)  
  
Before continuing feature work, a design system must exist.  
  
### Folder Structure  
  
TintTracker/  
└── DesignSystem/  
├── TintTokens.swift  
├── TintSpacing.swift  
├── TintTypography.swift  
├── TintColors.swift  
└── Components/  
├── TintSectionHeader.swift  
├── TintFormRow.swift  
├── TintPrimaryButton.swift  
├── TintSecondaryButton.swift  
├── TintCard.swift  
├── TintEmptyStateView.swift  
└── TintInlineError.swift  
  
### Design Rules  
  
- Use **system fonts only**  
- Use **Dynamic Type everywhere**  
- Corner radius: limited to 2–3 values max  
- Avoid nested rounded rectangles  
- Lists over cards unless grouping is required  
- Animations subtle and purposeful  
  
If it doesn’t look like Apple Notes, Reminders, Health, or Settings — it’s wrong.  
  
---  
  
## Navigation Rules (Strict)  
  
TintTracker must follow exactly two navigation styles:  
  
### 1. Push Navigation  
  
Used for:  
  
- Viewing details  
- Editing existing records  
  
Rules:  
  
- Uses system back button  
- No “Cancel” button  
- Save only appears if data changed  
  
---  
  
### 2. Sheet Presentation  
  
Used for:  
  
- Creating new items  
- Quick add flows  
  
Rules:  
  
- Cancel on leading side  
- Save on trailing side  
- No back arrow  
- Swipe-to-dismiss enabled  
- Unsaved changes confirmation required  
  
---  
  
## Forms Standardization  
  
All forms must follow the same structure:  
  
- Clear section headers  
- Minimal container styling  
- Required fields validated live  
- Save disabled until valid  
- Inline human-readable error messages  
  
Bad:  
  
> “Invalid input”  
  
Good:  
  
> “Unit size must be greater than 0 oz.”  
  
---  
  
## Inventory System (Critical Feature)  
  
Inventory must support:  
  
- Single product entry  
- Batch shade creation for color lines  
- Accurate cost per ounce  
- Accurate stock tracking  
- Reliable updates when formulas are used  
  
### Batch Shade Entry (“Color Line + Shades”)  
  
This is a first-class workflow.  
  
Shared fields:  
  
- Brand  
- Color line  
- Category  
- Unit size  
- Cost  
- Default thresholds  
  
Shade-specific fields:  
  
- Shade name/code  
- Starting stock  
  
Features:  
  
- Shared fields lock once shades begin  
- Add/remove shade rows  
- Bulk paste import (one per line)  
- Duplicate detection  
- Safe saving (all-or-nothing)  
  
This workflow must feel **fast and frictionless**.  
  
---  
  
## Clients System  
  
Clients must support:  
  
- Clear list layout  
- Empty state with CTA  
- Fast add/edit  
- Formula history per client  
- Clean visual hierarchy  
  
No clutter. No dense cards.  
  
---  
  
## Custom Fields System  
  
Custom fields must:  
  
- Follow the same form design rules  
- Use standard pickers  
- Clearly indicate where the data is used  
- Never exist as “dead UI”  
  
If a field isn’t used anywhere, it should not exist.  
  
---  
  
## Accessibility Requirements  
  
TintTracker must fully support:  
  
- Dynamic Type  
- VoiceOver labels  
- Button traits  
- Accessible color contrast  
- Keyboard navigation where applicable  
  
Accessibility is not optional.  
  
---  
  
## Testing Requirements  
  
Minimum test coverage:  
  
- Inventory validation logic  
- Batch shade parsing  
- Duplicate detection  
- Client creation  
- Persistence save/load  
  
UI tests required for:  
  
- Create client  
- Add inventory item  
- Batch shade entry  
  
---  
  
## Production Readiness Checklist  
  
Before completion:  
  
- No silent save failures  
- No inconsistent navigation  
- No visual drift  
- No data duplication bugs  
- No broken empty states  
- All privacy usage strings added  
- App Store–safe permissions only  
- Crash-free navigation  
  
---  
  
## Outcomes & Retrospective  
  
At completion, document:  
  
- What was rebuilt  
- What was simplified  
- What improved UX the most  
- Remaining wishlist features  
- Lessons learned for future updates  
  
---  
  
## Final Directive  
  
TintTracker is not a demo app.  
  
It is a **professional production iOS application**.  
  
If Apple assigned a team to build a hair-color inventory app in 2026,    
**this is exactly how it would behave**.  
  
That is the bar.  
