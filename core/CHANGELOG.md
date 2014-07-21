## Spree 2.3.2 (unreleased) ##
* Added `actionable?` for Spree::Promotion::Rule. `actionable?` defines
  if a promotion action can be applied to a specific line item. This
  can be used to customize which line items can accept a promotion
  action by defining its logic within the promotion rule rather than
  relying on Spree's default behaviour. Fixes #5036

    Gregor MacDougall
