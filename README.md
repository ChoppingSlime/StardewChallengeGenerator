# 🎯 Purpose

This tool aims to enhance long-term Stardew Valley playthroughs by introducing a dynamic challenge system. It incorporates seasonal and yearly quests, a scoring mechanism, stacking penalties (maluses), and rewards for successful completion. The primary goals are to increase replayability, encourage strategic planning, and foster a light competitive or cooperative framework for both solo and multiplayer experiences.

# 🧩 Core Systems Overview

## Quests

The Stardew Valley Challenge Tool features two types of quests: Seasonal Quests and Yearly Quests.

Both quest types share these core elements:

* Categories: Define the type of quest (e.g., Growing, Fishing, Mining).
* Tags: Metadata used internally to filter the pool of specific quests within a category based on game settings.
* Conflicting Maluses: A list of maluses that would make a specific quest impossible to complete.

Differences between Seasonal and Yearly Quests:

* Seasonal Quests are activated at the beginning of each season, while Yearly Quests are activated at the beginning of Spring each year.
* Seasonal Quests are additionally filtered by the quest's assigned seasons (e.g., Spring, Summer, All-Year).
* Completing a Seasonal Quest adds 1 point to the Score counter
* Failing a Yearly Quest removes 4 points from the score counter.

## Maluses

Maluses are negative conditions or penalties applied to the player's playthrough.

* Maluses are applied when the player fails a Seasonal Quest.
* Upon user interaction ("the roll"), one malus is randomly selected from the wheel.
* Tags: Metadata used internally to filter maluses based on game settings (singleplayer only, co-op only).

## Rewards

Rewards are item codes that the player is permitted to obtain In-Game through the Item code exploit one time per reward.

* Spinning a reward wheel will give the player 3 different item codes
* Tags

# 🌀 Wheels

## Seasonal Quest Wheel (SQW)

* Activated at the beginning of each season.
* Displays only the different seasonal quest categories
* Upon user interaction, one of these categories is randomly selected from the wheel.
* Off-screen, after a category is selected, the app randomly picks one specific quest from the pool of challenges belonging to that chosen category by filtering out unavailable quests checking “season” and “tags”
* Upon a quest is chosen, the player is asked to confirm the quest or reroll it.
* Rerolling the quest will just make the wheel roll again.
* Confirming the quest will select it
* After selecting a quest, it will be added to the “current seasonal quest” tab.

## Yearly Quest Wheel (YQW)

* Activated at the start of Spring each year.
* Displays only the different yearly quest categories
* Upon user interaction, one of these categories is randomly selected from the wheel.
* Off-screen, after a category is selected, the app randomly picks one specific quest from the pool of challenges belonging to that chosen category by filtering out unavailable quests checking “tags”
* Upon a quest is chosen, the player is asked to confirm the quest or reroll it.
* Rerolling the quest will just make the wheel roll again.
* Confirming the quest will select it
* After selecting a quest, it will be added to the “current yearly quest” tab.

## Malus Wheel (MW)

* Activated upon failing a Seasonal Quest.
* Before appearing, unavailable quests are filtered out by checking tags
* Displays only the short names of the available maluses.
* Upon user interaction, one malus is randomly selected from the wheel and added to the “Active Maluses” tab.

## Reward Wheel (RW)

* Activated upon successful completion of a Yearly Quest.
* The wheel displayed to the user shows the names of potential reward items or outcomes.
* Upon user interaction ("the roll"), one reward is randomly selected from the wheel.

# 📱 App Structure

## Scene: New Challenge

* Button: “Create New Challenge Generator”
* Triggers:
    * Prompts the user to set the challenge generator name.
    * Prompts the user to set the starting year and season.
    * Initiates the roll for the initial Seasonal and Yearly Quests.
    * Navigates to the Challenge Dashboard Scene.

## Scene: Challenge Dashboard

* Header Information:
    * Current Year / Season
    * Current Score
    * Active Maluses (displayed as a list with descriptions)
    * Current Seasonal Quest (full description)
    * Current Yearly Quest (full description)
    * Recent Rewards (list of obtained rewards)
* Toggle Buttons (reflecting game state for challenge filtering):
    * Co-op / Singleplayer
    * Bus Unlocked (Yes/No)
    * Ginger Island Unlocked (Yes/No)
* Main Action Button: “Proceed to Next Season”
* Triggers:
    * Opens a 3-tab panel:
        * Tab 1: Confirmation
            * Asks the user to confirm completion (or failure) of the previous Seasonal Quest (and Yearly Quest in Spring).
        * Tab 2: Results
            * Displays the outcome of the Seasonal and Yearly Quests.
            * Opens the Reward Wheel (if Yearly Quest completed).
            * Opens the Malus Wheel (if Seasonal Quest failed).
        * Tab 3: New Quests
            * Initiates the roll for the new Seasonal Quest (and Yearly Quest in Spring).
            * Updates the Current Year/Season.
            * Updates the Current Score.
            * Updates the Active Maluses.
            * Updates the Recent Rewards.

# 🔄 Game Flow Logic

## At Game Start:

* User selects "Create New Challenge Generator."
* User sets the challenge generator name.
* User sets the starting year and season.
* Since there is no active Yearly quest, a YQW rolls, and a category is selected.
* The app automatically picks a random specific Seasonal Quest from the chosen category, filtered by the tags.
* Player is asked to confirm or reroll the yearly quest
* If reroll the process repeats from the start
* If confirm, the quest is added to the “current yearly quest” tab
* Since there is no active Seasonal quest, a SQW rolls, and a category is selected.
* The app automatically picks a random specific Seasonal Quest from the chosen category, filtered by the tags and current season.
* Player is asked to confirm or reroll the seasonal quest
* If reroll the process repeats from the start
* If confirm, the quest is added to the “current seasonal quest” tab

## On "Proceed to Next Season" button:

* In the background, the game advances by one season (if it's Winter, it goes to Spring and adds 1 year).
* A 3-tab panel opens:
    * Tab 1: Confirmation
        * Asks if the player has completed or not the Yearly challenge (only if the current season is Spring, meaning a new year has begun).
        * Asks if the player has completed or not the Seasonal challenge.
        * "Confirm" button.
    * Tab 2: Results
        * After selecting the options and clicking "Confirm," this tab displays the outcome:
            * Winning a Yearly Quest: Reward Wheel opens.
            * Losing a Yearly Quest: Panel displays "-4 points."
            * Winning a Seasonal Quest: Panel displays "+1 point" and clears all active maluses.
            * Losing a Seasonal Quest: Malus Wheel opens.
        * Wheel panels won't start spinning until a button is clicked.
        * "Continue" button (clickable only after all existing wheels have been used). Clicking it moves the player to Tab 3.
    * Tab 3: New Quests
        * Displays the Seasonal Quest Wheel (and Yearly Quest Wheel if it's Spring).
        * Rolling each wheel selects the new Seasonal/Yearly quests and removes the previous one.
        * "Close" button (clickable after all wheels are rolled). Clicking it closes the panel and returns the player to the main game screen.

# 🌀 SQW Categories and Examples

For all Seasonal Quests, 'X' represents a quantity or target that increases based on the current in-game year, and 'Y' represents a random target within the specified group.

Growing:

* Harvest and ship X of a Y crop of the current season. \[all\_year\]
* Harvest and ship X total of a Y crop of the current season of golden quality. \[all\_year\]

Foraging:

* Collect X salmonberries. \[spring\]
* Collect X blackberries. \[fall\]

Fishing:

* Catch X total of a Y fish from the current season. \[all\_year\]
* Catch the current season’s legendary fish. (Tags: one-time-only) \[all\_year\]

Farming:

* Build X total of a Y building. \[all\_year\]
* Buy X farming animals. \[all\_year\]

Social:

* Reach a friendship level of X hearts with a Y villager. \[all\_year\]
* Give a 'liked' or 'loved' gift to X different villagers. \[all\_year\]
* Give a liked or loved gift to every villager. \[all\_year\]
* Complete X “help wanted” quests from the town board \[all\_year\]

Mining:

* Reach Skull Cavern level X. (Tags: post-year-one, bus-unlocked) \[all\_year\]
* Find X total of a Y ore. \[all\_year\]
* Find X total of a Y gem. \[all\_year\]
* Break open X Geodes. \[all\_year\]
* Reach Mine level 80. (Tags: first-year) \[spring\]
* Reach Mine level 120. (Tags: first-year, singleplayer) \[spring\]
* Reach Mine level 120. (Tags: first-year, co-op) \[summer\]

Festival:

* Win the Egg Hunt. (Tags: co-op) \[spring\]
* Purchase X Strawberry seeds from the Egg Festival market \[spring\].
* Purchase X seasonal plants. \[spring\]
* Reach a total of 250 Calico Eggs in the Desert Festival. (Tags: bus-unlocked) \[spring\]
* Dance at the flower dance festival with a Y villager. \[spring\]
* Get a Y response from the Luau event. \[summer\]
* Purchase X Starfruit at the Luau. \[summer\]
* Purchase X Moonlight Jellies Banner at the Dance of the Moonlight Jellies. \[summer\]
* Get 10 golden tags at the Trout Derby. \[summer\]
* Reach 10000 points in the Stardew Valley Fair. \[fall\]
* Purchase X grave stones at the Spirit’s Eve festival. \[fall\]
* Be the first to get the golden pumpkin at the Spirit’s Eve festival. (Tags: co-op) \[fall\]
* Win the festival of ice. (Tags: co-op) \[winter\]
* Buy X Winter End Table at the festival of ice. \[winter\]
* Reach iridium tier both days of the SquidFest. \[winter\]
* Buy X of a Y (200g cost) item in the Night Market. \[winter\]
* Buy X of a Y (500g cost) item in the Night Market. \[winter\]
* Buy 1 of each item from every shop in the Night Market. \[winter\]
* Buy X Tree of the Winter Star at the Feast of the Winter Star. \[winter\]

# 🌍 YQW Categories and Examples

For all Yearly Quests, 'X' represents a quantity or target that increases based on the current in-game year, and 'Y' represents a random target within the specified group.

Community Restoration:

* Complete all the JojaMart development form. (Tags: first-year)
* Complete all the community center bundles. (Tags: second-year)

Skill:

* Reach level 10 in all skills. (Tags: first-year)
* Unlock mastery in 2 new skills (Tags: post-year-one)

Production:

* Produce a total of X of an Y artisan good.
* Earn a total of X gold within the year.
* Accumulate a total of X of Y ore bar.
* Grow and harvest X total Ancient Fruit.
* Process X total items using the Mill.

Completion:

* Complete all Gill’s Quest. (Tags: post-year-one)
* Complete the museum. (Tags: post-year-one)
* Catch every type of fish available in Stardew Valley. (Tags: post-year-two)
* Get all of Ginger Island parrot upgrades. (Tags: post-year-one)
* Discover all Secret Notes. (Tags: post-year-one)
* Cook every recipe in the game at least once. (Tags: post-year-two)
* Craft every craftable item in the game at least once. (Tags: post-year-two)

Farmhouse:

* Remove every possible natural debri from the farmland
* Fully upgrade your farmhouse.
* Fully cover every possible tile in the farmland

Social:

* Get married and have two children. (Tags: post-year-one)
* Reach maximum friendship with X new Y villagers.
* Invite X different villagers to the Movie Theater. (Tags: post-year-one)
* Complete X number of "Help Wanted" quests from the town board.

# ☠️ MW Categories and Examples:

* 75% Profit: You must sell all items at 75% of their normal selling price.
* 50% Profit: You must sell all items at 50% of their normal selling price.
* 25% Profit: You must sell all items at 25% of their normal selling price. (Tags: single player)
* Inverted Shared Income: You must invert the shared income setting at the mayor's house.. (Tags: coop)
* Daily Trash Disposal: Each in-game day, you must discard 5 different items in a trash can (these items cannot be retrieved by any means).
* Daily Meal Purchase: You must purchase at least one of the daily meals offered by Gus each in-game day.
* No Selling to Specific Vendor: You are prohibited from selling any items to a Y vendor.
* No Fishing Rod Use: You are not allowed to use the fishing rod under any circumstances.
* No Pickaxe Use: You are not allowed to use the pickaxe under any circumstances.
* No Watering Can Use: You are not allowed to use the watering can under any circumstances (relying solely on rain or other potential watering methods).
* No Hoe Use: You are not allowed to use the hoe under any circumstances (restricting planting to wild seeds or other potential methods).
* No Axe Use: You are not allowed to use the axe under any circumstances (relying solely on found wood or other potential sources).
* Combat Knives Only: You may only use knives when engaged in combat.
* No Seed Purchases: You are not allowed to purchase any seeds in any way.
* Sneak Walk Only: You must move by holding the sneak key down.
* Farm Confinement: You are not allowed to leave your farm.
* Pelican Town Lockdown: You are not allowed to leave Pelican Town; access to the Desert, Ginger Island, or other outlying areas is prohibited.
* No Speed: You are not allowed to move faster by riding a horse, drinking coffee, etc..
* No Crafting: You are not allowed to craft any items.
* Chest Loss: You have to completely trash the contents of one of your chests (but tools).
* Half Energy: You must use each tool twice in order to consume twice the energy.
* No Eating: You are not allowed to consume any food items to replenish your energy.
* Pacifist Farmer: You are not allowed to kill any monsters.
* No Upgrades: You are not allowed to upgrade any of your tools at the Blacksmith.
* Wild seeds: You are only allowed to plant and harvest wild seeds.
* Reverse Controls: You must invert the keybindings for moving (left right and up down)

# 🎁 Reward Wheel Items and Codes

* Statue of Perfection \[280\]
* Statue of True Perfection \[890\]
* Statue of Endless Fortune \[889\]
* Prismatic Shard \[74\]
* Clay \[330\]
* Ancient Seed \[499\]
* ??? (Concerned Ape Hat) \[903\]
* Magic Rock Candy \[279\]
* Lucky Ring \[527\]
* Burglar's Ring \[526\]
* Napalm Ring \[525\]
* Blobfish \[797\]
* Legend II \[871\]
* Chicken Statue (Artifact) \[113\]
* Crystallarium \[262\]
* Iridium Sprinkler \[645\]
* Blue Grass Starter \[944\]
* Mysterious Tree Seed \[801\]
* Tea Sapling \[251\]
* Iridium Band \[535\]
* Warp Totem: Island \[885\]
* Solar Panel \[809\]
* Ostrich Egg \[289\]
* Ostrich Incubator \[891\]
* Deluxe Scarecrow \[412\]
* Dwarf King Statue \[125\]
* Statue of Blessings \[938\]
* Anvil \[919\]
* Mini-Forge \[918\]
* Heavy Furnace \[920\]
* Advanced Iridium Rod \[856\]
* Iridium Scythe \[927\]
* Horse Flute \[608\]
* Golden Egg \[928\]
* Infinity Blade \[850\]
* Stardrop \[434\]
* Hot Java Ring \[528\]
* Stardrop Tea \[907\]
* Book of Stars \[912\]
* Marnie's Catalogue \[910\]
* Pierre's Missing Stocklist \[911\]
* One item of your choice
