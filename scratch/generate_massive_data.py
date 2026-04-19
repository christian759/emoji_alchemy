import json
import random

def generate_data():
    # Traits
    HEAT = "heat"; COLD = "cold"; LIQUID = "liquid"; SOLID = "solid"; GAS = "gas"
    LIFE = "life"; METAL = "metal"; TOOL = "tool"; FOOD = "food"; SPACE = "space"
    ELECTRIC = "electric"; SHARP = "sharp"; WOOD = "wood"; CLOTH = "cloth"

    # Base elements (Tier 0)
    base = ["💧", "🔥", "🌍", "💨"]
    emoji_to_traits = {
        "💧": [LIQUID, COLD],
        "🔥": [HEAT, GAS],
        "🌍": [SOLID],
        "💨": [GAS]
    }
    emoji_to_tier = {"💧": 0, "🔥": 0, "🌍": 0, "💨": 0}

    # Categories for pools
    pools = {
        "Elements": ["🔥", "💧", "🌍", "💨", "🌫️", "🌋", "🌊", "☀️", "⛰️", "🌧️", "☄️", "⛈️", "🌈", "🌀", "🏔️", "🌪️", "🧊", "🪨"],
        "Nature": ["🌱", "🌳", "🌿", "🏜️", "🌾", "🌸", "🌻", "🌲", "🌵", "🍄", "🍁", "🍂", "🍃", "🌴", "🍀", "🎋", "🐚"],
        "Fauna": ["🐻", "🦁", "🐯", "🐱", "🐶", "🐺", "🦊", "🦝", "🐮", "🐷", "🐭", "🐹", "🐰", "🐻‍❄️", "🐨", "🐼", "🐸", "🐉", "🐢", "🐍", "🐙", "🦑", "🦐", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🦜", "🦢", "🕊️", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜"],
        "Space": ["☀️", "🌙", "⭐", "🪐", "🌠", "🌌", "🌍", "🌎", "🚀", "🛰️", "🔭"],
        "Items": ["⚒️", "🛠️", "⚙️", "🕰️", "💎", "⚖️", "🗡️", "🛡️", "🏹", "🔮", "🪄", "💡", "💻", "⌨️", "🖥️", "📱", "📻", "📺", "📷", "🔋", "💉"],
        "Food": ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🥑", "🥦", "🥬", "🥒", "🌽", "🥕", "🥐", "🍞", "🌭", "🍔", "🍟", "🍕", "🍳", "🍣", "🥟", "🍦", "🍩", "🍪", "🎂", "🍫", "🍯"]
    }

    # Heuristic mapping for traits
    trait_map = {
        "HEAT": ["🔥", "🌋", "☀️", "☄️", "💡", "🍳"],
        "COLD": ["💧", "🧊", "🏔️", "❄️"],
        "LIQUID": ["💧", "🌊", "🌧️", "🧪", "🍯", "🥛"],
        "SOLID": ["🌍", "⛰️", "🪨", "🏔️", "⚒️", "🛠️", "💎", "🧱", "📦"],
        "LIFE": ["🌱", "🌳", "🌿", "🌸", "🐻", "🦁", "🐯", "🐱", "🐶", "🐸", "🍎", "🍐"],
        "METAL": ["⚒️", "🛠️", "⚙️", "🗡️", "🛡️", "🚀", "🛰️", "⛓️", "🪙"],
        "TOOL": ["⚒️", "🛠️", "🗡️", "🏹", "🔭", "💉", "🪚", "🪛", "🔨"],
        "FOOD": ["🍎", "🍐", "🍞", "🍔", "🍕", "🍳", "🍰"],
        "ELECTRIC": ["⚡", "💡", "💻", "🖱️", "🖥️", "📱", "🔋", "🔌"],
        "SHARP": ["🗡️", "🪚", "🏹", "🪡", "✂️"],
        "WOOD": ["🌳", "🌲", "🪵", "🪵", "🪜"],
    }

    all_emojis_list = []
    emoji_to_cat = {}
    
    for cat, items in pools.items():
        for item in items:
            if item not in all_emojis_list:
                all_emojis_list.append(item)
                emoji_to_cat[item] = cat
                if item not in emoji_to_traits:
                    emoji_to_traits[item] = []
                    # Assign traits based on heuristic
                    for trait, seed_list in trait_map.items():
                        if any(seed in item for seed in seed_list): # Very loose check
                             emoji_to_traits[item].append(trait)
                    if not emoji_to_traits[item]:
                        emoji_to_traits[item] = [SOLID]
                if item not in emoji_to_tier:
                    emoji_to_tier[item] = 1 # Initial tier for items in seed pools

    # Expand to 1,250 emojis
    target_count = 1250
    ranges = [(0x1F300, 0x1F5FF), (0x1F600, 0x1F64F), (0x1F680, 0x1F6FF), (0x1F900, 0x1F9FF), (0x1FA70, 0x1FAFF)]
    
    while len(all_emojis_list) < target_count:
        r_start, r_end = random.choice(ranges)
        new_emoji = chr(random.randint(r_start, r_end))
        if new_emoji not in all_emojis_list:
            all_emojis_list.append(new_emoji)
            emoji_to_cat[new_emoji] = "Misc"
            emoji_to_traits[new_emoji] = [SOLID] # Default
            emoji_to_tier[new_emoji] = random.randint(2, 5) # Random tier for fills

    # Semantic Engine for Recipes
    recipes = {
        "💧,🔥": "💨", "💧,🌍": "🌱", "🔥,🌍": "🌋", "💨,🌍": "🌪️",
        "💧,💧": "🌊", "🔥,🔥": "☀️", "🌍,🌍": "⛰️", "💨,💨": "🌬️",
        "🌱,💧": "🌳", "🌱,🔥": "🍂", "🌍,💨": "🏜️", "🌊,🔥": "🌫️",
        "⚡,🌍": "💎", "🌞,🌧️": "🌈", "☁️,⚡": "⛈️", "🧊,🔥": "💧",
    }
    
    recipe_keys = set()
    for k in recipes.keys():
        recipe_keys.add(tuple(sorted(k.split(","))))

    target_recipes = 25000
    print(f"Generating {target_recipes} REALISTIC combinations...")
    
    attempts = 0
    while len(recipes) < target_recipes and attempts < 10000000:
        a = random.choice(all_emojis_list)
        b = random.choice(all_emojis_list)
        if a == b: continue
        pair = tuple(sorted([a, b]))
        
        if pair not in recipe_keys:
            traits_a = set(emoji_to_traits.get(a, []))
            traits_b = set(emoji_to_traits.get(b, []))
            all_traits = traits_a.union(traits_b)
            
            # Semantic rules
            result = None
            
            # Growth/Biology
            if LIFE in all_traits and LIQUID in all_traits:
                # Find something living
                candidates = [e for e in all_emojis_list if LIFE in emoji_to_traits.get(e, [])]
                if candidates: result = random.choice(candidates)
            
            # Heat/Melting
            elif HEAT in all_traits and SOLID in traits_a and METAL in traits_a:
                # Melting metal
                result = "🌋" # Or a liquid metal if we had one
            
            # Tools/Crafting
            elif TOOL in all_traits and METAL in all_traits:
                # Improved tool
                candidates = [e for e in all_emojis_list if TOOL in emoji_to_traits.get(e, []) and METAL in emoji_to_traits.get(e, [])]
                if candidates: result = random.choice(candidates)

            # Fallback: Tier-based "Realistic-ish" matching
            if not result:
                target_tier = min(5, max(emoji_to_tier[a], emoji_to_tier[b]) + 1)
                # Filter results that share at least one trait OR are higher tier
                candidates = [e for e in all_emojis_list if emoji_to_tier[e] >= target_tier and any(t in emoji_to_traits.get(e, []) for t in all_traits)]
                if candidates:
                    result = random.choice(candidates)
            
            if result and result != a and result != b:
                recipes[f"{pair[0]},{pair[1]}"] = result
                recipe_keys.add(pair)
        attempts += 1

    data = {
        "base_emojis": base,
        "recipes": recipes,
        "emoji_to_cat": emoji_to_cat,
        "categories": list(pools.keys()) + ["Misc"]
    }

    with open('assets/game_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Success! Generated {len(recipes)} realistic recipes.")

if __name__ == "__main__":
    generate_data()
