# DATA_MODEL.md — Canonical Data Model & Invariants  
  
This document defines the **required entities, relationships, and invariants**.  
Breaking these rules is a data integrity bug.  
  
---  
  
## GLOBAL RULES  
  
- All quantities are stored internally in **grams**  
- Display/input units are converted via UnitsService  
- No silent data mutation  
- All deductions are auditable  
  
---  
  
## ENTITIES  
  
### Client  
- id  
- name  
- createdAt  
- visits [Visit]  
  
---  
  
### Visit  
- id  
- date  
- client  
- formulas [Formula]  
- notes (optional)  
  
Saving a Visit triggers inventory deduction.  
  
---  
  
### Formula  
- id  
- name (Roots, Highlights, Toner, etc.)  
- visit  
- lineItems [FormulaLineItem]  
  
---  
  
### FormulaLineItem  
- id  
- inventoryItem  
- amountUsed (grams)  
  
---  
  
### InventoryCategory  
- id  
- name  
- fieldDefinitions [InventoryFieldDefinition]  
- isSystem (bool)  
  
---  
  
### InventoryFieldDefinition  
- id  
- name  
- type (text, number, toggle, picker, barcode)  
- pickerOptions (optional)  
- order  
  
Defines dynamic form UI.  
  
---  
  
### InventoryItem  
- id  
- category  
- fieldValues (key-value)  
- currentStock (grams)  
- lowStockThreshold (grams)  
- isArchived  
  
---  
  
### InventoryTransaction  
- id  
- inventoryItem  
- date  
- delta (grams, positive or negative)  
- reason (visit, manual adjustment)  
- relatedVisit (optional)  
  
Every stock change creates a transaction.  
  
---  
  
### AppSettings  
- preferredUnits (oz | grams)  
- stepSizeGrams  
- stepSizeOunces  
- iCloudEnabled  
  
---  
  
## INVARIANTS (NON-NEGOTIABLE)  
  
- Inventory stock may not go negative **without confirmation**  
- Deleting a Visit must reverse its inventory deductions  
- Units conversion occurs in exactly one service  
- Category schema changes must not corrupt existing data  
- Archived items cannot be used in new formulas  
- Transactions are append-only (never mutated)  
  
---  
  
## SERVICES (EXPECTED)  
  
- UnitsService  
- InventoryService  
- FormulaService  
- SubscriptionService  
- AuthService  
  
No business logic inside Views.  
