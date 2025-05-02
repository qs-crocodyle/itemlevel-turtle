# ItemLevel

This AddOn is modified from **S_ItemTip** (a Chinese addon) to show item levels instead of item scores.

![character](https://github.com/user-attachments/assets/526b2176-a704-40fc-8aca-244092bb167f)


## Update
- The database has been updated to the lastest version (05/01/2025)
- The overall item level displayed in the inspection frame or the mouseover tooltip is a weighted average of all important slots. The coefficients are listed below.
    | Slot | Weight |
    | ---- | :----: |
    | head | 1 |
    | neck | 0.5625 |
    | shoulder | 0.75 |
    | chest |  1 |
    | waist | 0.5625 |
    | legs | 0.75 |
    | feet | 0.75 |
    | wrist | 0.75 |
    | hands | 0.75 |
    | finger 1 | 0.5625 |
    | finger 2 | 0.5625 |
    | trinket 1 | 0.5625 |
    | trinket 2 | 0.5625 |
    | back | 0.5625 |
    | main hand | 1 |
    | off hand | 1 |
    | ranged | 0.3164 |

  Before the calculation, the item levels are scaled based on quality.    
    | Quality   | Scale |  
    |-----------|------:|  
    | Legendary | 1.3   |  
    | Epic      | 1.0   |  
    | Rare      | 0.85  |  
    | Uncommon  | 0.6   |  
    | Common    | 0.25  |

## Installation

Option 1: Download the folder and copy it to Wow-Directory\Interface\AddOns

Option 2: Use [GitAddonsManager](https://woblight.gitlab.io/overview/gitaddonsmanager/). Click "+" on the menu and add this repo directly -- https://github.com/qs-crocodyle/itemlevel-turtle.git It is very convenient to keep your addons up to date with GitAddonsManager (simply click the upward arrow on the menu). 
