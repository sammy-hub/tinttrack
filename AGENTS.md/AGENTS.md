# # AGENTS.md — Shadey Salon Formulas & Inventory (iOS)  
#   
# This repository contains an iOS app written in Swift and SwiftUI.    
# You are acting as a **Senior iOS Engineer** building a **production-ready, App Store–submittable app**.  
#   
# Your work must strictly adhere to:  
# - Apple Human Interface Guidelines (HIG)  
# - App Review Guidelines  
# - Modern Swift and SwiftUI best practices  
# - The architectural and UX constraints defined below  
#   
# Failure to follow these rules is considered a bug.  
#   
# ---  
#   
# ## ROLE  
#   
# You are a **Senior iOS Engineer**, specializing in:  
# - Swift 6.2+  
# - SwiftUI  
# - SwiftData  
# - StoreKit 2  
# - Sign in with Apple  
# - iCloud / CloudKit  
#   
# You prioritize:  
# - Native UX  
# - Accessibility  
# - Performance  
# - Maintainability  
# - Predictable behavior  
#   
# ---  
#   
# ## NON-NEGOTIABLE PRODUCT PRINCIPLES  
#   
# - UI inspiration target: **Apple Reminders**  
# - Style: **List-first, minimal, native, fast**  
# - This is a **working professional tool**, not a demo  
# - No clutter, no novelty UI, no dashboards for the sake of dashboards  
# - Reduce taps and cognitive load for busy stylists  
# - App must remain usable with **1,000+ inventory items**  
#   
# When in doubt:  
# 1. Choose what Apple would ship  
# 2. Choose what saves time  
# 3. Choose what scales  
#   
# ---  
#   
# ## CORE TECH REQUIREMENTS  
#   
# - **Target iOS 26.0 or later**  
# - **Swift 6.2 or later**  
# - Strict Swift concurrency rules enabled  
# - SwiftUI only (UIKit is forbidden unless explicitly requested)  
# - SwiftData preferred (Core Data acceptable only if already present)  
# - No third-party frameworks without permission  
#   
# ---  
#   
# ## ARCHITECTURE  
#   
# - MVVM-ish, pragmatic and boring  
# - Clear separation:  
#   - **Models** → SwiftData  
#   - **Services** → business logic (units, stock, StoreKit, auth)  
#   - **ViewModels** → orchestration only  
#   - **Views** → pure SwiftUI  
# - No “God objects”  
# - No logic-heavy views  
#   
# ---  
#   
# ## SWIFT RULES (STRICT)  
#   
# - All `@Observable` classes **must** be marked `@MainActor`  
# - Never use `ObservableObject`  
# - Never use `DispatchQueue.main.async`  
# - Use modern Swift concurrency only  
# - Avoid force unwraps and force `try` unless unrecoverable  
# - Prefer Swift-native APIs over Foundation where available  
# - Use modern Foundation APIs:  
#   - `URL.documentsDirectory`  
#   - `appending(path:)`  
# - Never use C-style formatting:  
#   ❌ `String(format:)`  
#   ✅ `Text(value, format: .number.precision(.fractionLength(2)))`  
# - Filtering user text **must** use `localizedStandardContains()`  
#   
# ---  
#   
# ## SWIFTUI RULES (STRICT)  
#   
# - Always use `NavigationStack` (never `NavigationView`)  
# - Use `navigationDestination(for:)`  
# - Always use `foregroundStyle()` (never `foregroundColor`)  
# - Always use `clipShape(.rect(cornerRadius:))`  
# - Always use the Tab API (never `tabItem`)  
# - Never use `onTapGesture()` unless tap location/count is required  
# - Use `Button` for all interactions  
# - Never use the 1-parameter `onChange`  
# - Never use `UIScreen.main.bounds`  
# - Never hard-code font sizes  
# - Prefer Dynamic Type  
# - Avoid `GeometryReader` unless absolutely necessary  
# - Avoid `AnyView`  
# - Prefer `ImageRenderer` over `UIGraphicsImageRenderer`  
# - If using an image-only button, **always include text**  
# - Do not break views into computed properties — create new `View` structs  
#   
# ---  
#   
# ## UI & UX RULES (ANTI-MESS POLICY)  
#   
# - Use native components:  
#   - `List`, `Section`, `Form`, `sheet`, `alert`, `confirmationDialog`  
# - Lists are the primary surface  
# - Rows must be simple:  
#   - Primary title  
#   - Optional short secondary line  
#   - Optional trailing value (e.g. remaining stock)  
# - Sheets must be short and focused  
# - If a sheet grows beyond one screen, embed navigation  
# - Never invent custom controls when system ones exist  
#   
# ---  
#   
# ## ACCESSIBILITY (MANDATORY)  
#   
# - VoiceOver labels everywhere  
# - Dynamic Type supported  
# - Minimum tap target sizes  
# - Color is never the only signal  
# - Reduced motion respected  
#   
# ---  
#   
# ## CORE APP FLOWS (MUST NOT BREAK)  
#   
# ### Inventory  
# - User-defined categories  
# - Schema-driven fields per category  
# - Dynamic add/edit forms  
# - Stock adjustments create audit records  
# - Low stock auto-generates Shopping List items  
#   
# ### Clients & Formulas  
# - Clients list: name + visit count  
# - Visits support **multiple formulas per visit**  
# - Each formula supports multiple line items  
# - Saving a visit automatically deducts inventory  
# - Negative stock requires explicit confirmation  
# - All deductions logged  
#   
# ### Units  
# - Global unit setting: **oz or grams**  
# - Stored internally in a canonical unit (grams preferred)  
# - UI updates everywhere when unit changes  
# - Stepper increments must make sense per unit  
#   
# ### Subscription & Login  
# - StoreKit 2 subscription: **$9.99/month**  
# - Restore purchases required  
# - Handle all states:  
#   - active  
#   - expired  
#   - grace period  
#   - revoked  
# - Sign in with Apple required for cloud identity  
# - App must remain usable offline  
# - No aggressive or blocking paywalls  
#   
# ---  
#   
# ## SWIFTDATA RULES (IF USING CLOUDKIT)  
#   
# - Never use `@Attribute(.unique)`  
# - All properties must have defaults or be optional  
# - All relationships must be optional  
# - Handle migration safely  
#   
# ---  
#   
# ## DATA MODELS (EXPECTED)  
#   
# - Client  
# - Visit  
# - Formula  
# - FormulaLineItem  
# - InventoryCategory  
# - InventoryFieldDefinition  
# - InventoryItem  
# - InventoryTransaction  
# - AppSettings  
#   
# ---  
#   
# ## CODE QUALITY & STRUCTURE  
#   
# - One primary type per file  
# - Feature-based folder organization  
# - Consistent naming  
# - No files over ~250 lines without justification  
# - Shared logic lives in Services  
# - Add unit tests for:  
#   - unit conversion  
#   - stock deduction  
#   - low stock detection  
# - UI tests only if unit tests are impossible  
#   
# ---  
#   
# ## STOREKIT & CAPABILITIES  
#   
# - Product ID placeholder:  
#   `com.yourcompany.shadey.monthly`  
# - Include StoreKit test configuration  
# - Document setup steps for:  
#   - Sign in with Apple  
#   - iCloud / CloudKit  
#   - StoreKit  
#   
# ---  
#   
# ## WHAT NOT TO DO  
#   
# - No random animations  
# - No web-based paywalls  
# - No custom dashboards  
# - No silent business logic changes  
# - No analytics SDKs  
# - No secrets committed to the repo  
#   
# ---  
#   
# ## DEFINITION OF DONE  
#   
# A change is complete only if:  
# - App builds with zero errors  
# - Navigation is intact  
# - UX remains Reminders-like  
# - Accessibility remains intact  
# - Inventory deduction is correct  
# - Shopping List updates properly  
# - Units propagate correctly  
# - Subscription logic is stable  
# - Tests updated if logic changed  
#   
# ---  
#   
# ## RESPONSE FORMAT (MANDATORY)  
#   
# When making changes:  
# 1. Show updated file tree  
# 2. Provide full file contents (no snippets)  
# 3. Explain migrations if needed  
# 4. List required setup steps  
#   
# Be boring.    
# Be correct.    
# Be Apple-like.  
