# DONE.md — Definition of Done  
  
A feature or build is NOT complete unless ALL items below pass.  
  
---  
  
## BUILD  
  
- App builds with zero errors  
- No critical runtime warnings  
- Runs on simulator and device  
  
---  
  
## UX  
  
- Feels like Apple Reminders  
- List-first UI  
- No clutter  
- No novelty controls  
- Sheets are short and focused  
  
---  
  
## CORE FUNCTIONALITY  
  
- Add inventory item successfully  
- Customize category schema  
- Add client  
- Add visit with multiple formulas  
- Inventory deducts correctly  
- Transactions recorded  
- Low stock detected  
- Shopping List auto-updates  
  
---  
  
## UNITS  
  
- Toggle oz ↔ grams  
- Entire app updates consistently  
- No mixed-unit displays  
  
---  
  
## SUBSCRIPTION  
  
- Paywall appears correctly  
- Purchase works in StoreKit test config  
- Restore purchases works  
- Subscription states handled gracefully  
  
---  
  
## ACCESSIBILITY  
  
- VoiceOver works  
- Dynamic Type supported  
- No color-only indicators  
  
---  
  
## PERFORMANCE  
  
- Handles 1,000+ inventory items  
- Lists scroll smoothly  
  
---  
  
## DATA SAFETY  
  
- No silent data loss  
- No silent negative stock  
- Visit deletion reverses deductions  
  
---  
  
## TESTING  
  
- Unit tests pass:  
  - units conversion  
  - stock deduction  
  - low stock detection  
  
If any item fails, the implementation is incomplete.  
