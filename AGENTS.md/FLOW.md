# # FLOW.md — User Golden Paths  
#   
# This document defines the **canonical user flows**.    
# If an implementation deviates from these flows, it is incorrect.  
#   
# The app must optimize for **speed, clarity, and minimal taps**.  
#   
# ---  
#   
# ## FLOW 1: First Launch & Onboarding  
#   
# 1. App launches  
# 2. Onboarding screens appear (2–4 screens max):  
#    - What the app does (Inventory → Formulas → Auto Stock)  
#    - Privacy-first, local-first explanation  
#    - Optional iCloud sync explanation  
# 3. User completes onboarding  
# 4. Paywall appears (subscription required to create new data)  
# 5. User can:  
#    - Subscribe  
#    - Restore purchase  
#    - Continue in read-only mode (if applicable)  
#   
# Onboarding must only appear once unless reset manually.  
#   
# ---  
#   
# ## FLOW 2: Add Inventory Item (Fast Path)  
#   
# Goal: Add a new shade **in under 30 seconds**.  
#   
# 1. Inventory tab  
# 2. Select category (e.g. Hair Color)  
# 3. Tap “+”  
# 4. Sheet opens with Form:  
#    - Title (required)  
#    - Brand (optional)  
#    - Product Line (optional)  
#    - Shade (optional)  
#    - Product Size  
#    - Initial Stock  
# 5. Tap Save  
# 6. Item appears immediately in list  
# 7. Low-stock logic evaluated instantly  
#   
# No multi-screen wizard.    
# No unnecessary fields.  
#   
# ---  
#   
# ## FLOW 3: Customize Inventory Category  
#   
# 1. Settings → Inventory Categories  
# 2. Select existing category or tap “Add Category”  
# 3. Define:  
#    - Category name  
#    - Fields (text, number, picker, toggle)  
# 4. Reorder fields  
# 5. Save  
# 6. Inventory item forms immediately reflect new schema  
#   
# No app restart required.  
#   
# ---  
#   
# ## FLOW 4: Add Client & Visit  
#   
# 1. Clients tab  
# 2. Tap “+”  
# 3. Enter client name → Save  
# 4. Client detail opens  
# 5. Tap “New Visit”  
# 6. Visit defaults to today’s date  
#   
# ---  
#   
# ## FLOW 5: Add Visit With Multiple Formulas  
#   
# 1. Inside Visit screen  
# 2. Add Formula:  
#    - Name (Roots / Highlights / Toner)  
# 3. Inside Formula:  
#    - Add multiple line items:  
#      - Inventory item  
#      - Amount used (stepper)  
# 4. Repeat for additional formulas  
# 5. Save Visit  
#   
# Saving the visit must:  
# - Deduct inventory  
# - Create transaction records  
# - Update low-stock state  
# - Update Shopping List automatically  
#   
# ---  
#   
# ## FLOW 6: Negative Stock Handling  
#   
# If stock would go below zero:  
# 1. Alert appears:  
#    - “Allow Negative Stock”  
#    - “Edit Amount”  
#    - “Cancel Save”  
# 2. User must explicitly choose  
#   
# Silent negative stock is forbidden.  
#   
# ---  
#   
# ## FLOW 7: Shopping List  
#   
# 1. Shopping List tab  
# 2. Automatically populated with low-stock items  
# 3. Each row supports:  
#    - Checkmark toggle  
#    - Tap to view inventory item  
# 4. “Clear Purchased” action available  
#   
# Shopping List updates automatically when:  
# - Stock changes  
# - Threshold changes  
# - Units change  
#   
# ---  
#   
# ## FLOW 8: Units Toggle  
#   
# 1. Settings → Units  
# 2. Toggle between oz / grams  
# 3. Entire app updates:  
#    - Inputs  
#    - Displays  
#    - Steppers  
#    - Calculations  
#   
# No mixed units anywhere.  
#   
# ---  
#   
# ## FLOW 9: Subscription Management  
#   
# 1. Settings → Subscription  
# 2. View status  
# 3. Restore purchases  
# 4. Manage subscription via system sheet  
#   
# Subscription gating must feel native and non-hostile.  
