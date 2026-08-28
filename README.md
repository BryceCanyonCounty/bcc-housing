# bcc-housing

> This housing script offers an indepth and immersive home owning experience for players! With features like owning furniture, taxes, and more this script will give a quality experience to all home owners!

# Requirements
- oxmysql
- vorp_core
- vorp_inventory
- vorp_character
- bcc-utils
- bcc-doorlocks
- feather-menu
- [PolyZone](https://github.com/mkafrin/PolyZone/)

# Features
- Admin locked command to create houses!
- Each house can have a custom set inventory limit!
- Each house can have a cusstom tax amount!
- Houses have a ledger for players to store the money for thier tax in!
- Taxes and rent are taken from the property ledger monthly. Properties with insufficient funds are marked overdue instead of being deleted.
- Can add as many furniture items as you want in the config!
- House owners can buy furniture and place it around thier house!
- House owners can sell the furniture they bought!
- House owners can give and/or remove access to players
- When players approach a house, they will receive a notification indicating that they have entered private property.
- Ability to purchase the house specified in the configuration.
- Option to sell the house directly from the house menu.
- Collect proceeds from house sales through the house dealer.
- Players can now sell their house to another player at a price set in the config.
- When selling a house to another player, the seller has the option to include or exclude the inventory.
- No need for players to relog when buying or selling houses.
- Easy to translate!
- In depth webhooks!
- Built in hotel system!
- Version checking to help you keep up to date!

# New Version Additions
- Configured houses can use cash, gold, or Rol Tokens for purchases, rentals, and ledger payments.
- Renting can be enabled or disabled for each configured house.
- Tenants can end their current house rental from the house-management menu.
- Property boundaries can use the existing radius system or PolyZone polygons.
- Admins and configured realtor jobs can capture, export, preview, and update property PolyZones.
- Property-area previews are available from the purchase and admin-management menus.
- Property deed items with owner and house metadata are issued for purchased and rented properties.
- Deeds are removed and reissued when a property is transferred to another player.
- Taxes and rent are collected monthly on each property's purchase-date anniversary.
- New properties skip tax or rent collection during their first calendar month.
- Properties with insufficient ledger funds become overdue and have protected access restricted.
- Admins and configured realtor jobs can list overdue houses and release them for payment.
- Admins can view more property details, teleport to configured houses, preview boundaries, and open house inventories.
- Added server-side permission and ownership checks to sensitive house, door, ledger, and admin operations.
- Added protection against two players purchasing the same configured house simultaneously.

# New Version Configuration
- `configs/main.lua`: PolyZone controls, property deeds, rental defaults, allowed realtor jobs, and notification settings.
- `configs/houses.lua`: per-house `currencyType`, `allowRental`, `rentalDeposit`, `rentCharge`, and optional PolyZone fields.
- [PolyZone](https://github.com/mkafrin/PolyZone/) is now a required dependency.

# Rol Tokens
- `Rol Tokens` is the user-facing name for the VORP character `rol` balance.
- Set a configured house's `currencyType = 2` to use Rol Tokens for its purchase, rental, and ledger payments.
- The script checks `character.rol` for available tokens and uses VORP currency type `2` when removing or returning them.
- Houses purchased with Rol Tokens cannot be sold back or transferred through the normal house-sale workflow.

# Property Deeds
- Enable or disable property deeds with `Config.PropertyDocuments.enabled`.
- The configured deed item, `property_deed` by default, must exist in VORP inventory and support item metadata.
- A deed containing the property name, house ID, owner, ownership type, and issue date is issued when a property is purchased or rented.
- Property owners can request another deed from a configured real-estate agent.
- When a property is transferred to another player, the previous deed is removed and a new deed is issued when `removePreviousDeedOnTransfer` is enabled.
- The deed is only issued when the receiving player has enough inventory space.

# Taxes and Rent
- New purchases, rentals, and admin-created houses save the current database time in the `purchased_at` column.
- Monthly tax or rent collection is based on each property's `purchased_at` anniversary day instead of one global collection day.
- New properties are not charged during the same calendar month in which they were purchased or rented.
- Existing properties without a `purchased_at` value receive a legacy fallback date based on `Config.TaxDay` during the database migration.
- `Config.TaxDay` is only used for that legacy migration fallback. `Config.TaxResetDay` is no longer used by the anniversary-based collection process.
- The collection service checks once per hour and uses `last_tax_processed_at` to prevent duplicate monthly charges.
- Properties with insufficient ledger funds are marked overdue and protected access is restricted until staff releases the property for payment.

# Furniture Vendors
- Furniture-vendor NPCs support both `npc.active` and the legacy `npc.show` setting.
- `npc.active` takes priority when both settings are present. Vendors default to enabled when neither setting is configured.
- Vendor interaction checks use an adaptive delay, reducing client usage while players are away from furniture vendors.
- Vendor furniture can be previewed, rotated, and zoomed before purchase.
- Furniture books can be obtained from configured furniture vendors.
- Placed furniture can only be modified by players with property access, and overdue properties block furniture placement.

# How it works
- Admins can create and manage houses with only command "/HousingManager"
- You can easly change the command in config 
- The owner will be able to walk upto where his ranch is press "G" to open a menu to manage the house!

# How to install
- Install and ensure all resources listed under Requirements before ensuring `bcc-housing`.
- Add the configured property deed and furniture book items to VORP inventory when those features are enabled.
- Database tables and required migration columns are created automatically.

# Custom Interiors Coords (Credits to punchedgang/siddwell740)
- Siddin3 = {x = -1103.15, y = -2252.92, z = 50.65}
- Siddin4 = {x = -63.74, y = 14.05, z = 76.6}

# Side Notes
- This is a massive project there is most likely oversights if you have any suggestions or bugs report them asap!
- To delete houses you will currently have to delete them manually from the database!
- Do not place furniture directly ontop of one another they can be really close/sitting ontop of each other etc just make sure they are not in the exact same spot. If they are when you try to sell one of them it will sell every piece of furniture that is in the exact same spot as the one your trying to sell
- Need more help join the bcc discord heres the invite link: https://discord.gg/VrZEEpBgZJ
