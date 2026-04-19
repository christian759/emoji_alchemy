import json

def generate_data():
    base = ["💧", "🔥", "🌍", "💨"]
    
    # Hand-curated realistic recipes (Tier 1: Basic Matters)
    tier1_recipes = {
        "💧,🔥": "💨", "💧,🌍": "🌱", "🔥,🌍": "🌋", "💨,🌍": "🌪️",
        "💧,💧": "🌊", "🔥,🔥": "☀️", "🌍,🌍": "⛰️", "💨,💨": "🌬️",
        "💨,💧": "🌧️", "☀️,💧": "🌫️", "🌬️,🌍": "🏜️", "⛰️,💧": "🏔️",
        "🏔️,🔥": "💧", "🌧️,☀️": "🌈", "🌋,💧": "🪨", "🪨,💧": "🏖️",
        "🌧️,💨": "☁️", "☁️,🔥": "🌩️", "🌩️,🌍": "🔥", "❄️,☀️": "💧",
        "❄️,🌍": "🏔️", "🌫️,🌬️": "☁️", "🌊,🌬️": "🌪️", "🌊,☀️": "🌫️"
    }

    # Tier 2: Life & Nature
    tier2_recipes = {
        "🌱,💧": "🌿", "🌿,💧": "🌳", "🌳,🔥": "💨", "🌳,🌍": "🌲",
        "🌱,🌍": "🌾", "🌾,💧": "🌽", "🌱,☀️": "🌻", "🌻,🐝": "🍯",
        "🌳,🌳": "🌲", "🌲,❄️": "⛄", "🏜️,🌱": "🌵", "🌵,💧": "🌸",
        "🌸,🌬️": "🍃", "🌿,🔥": "🌫️", "🍂,🌍": "🍄", "🍄,💧": "🌱",
        "🥚,☀️": "🐣", "🐣,🌾": "🐔", "🐔,🥚": "🍳", "🐛,🌳": "🦋",
        "🦋,🌸": "✨", "🐜,🌍": "🍂", "🐝,🌸": "🍯", "🕷️,🌍": "🕸️"
    }

    # Tier 3: Animals & Biology
    tier3_recipes = {
        "🐾,🌳": "🐒", "🐒,🌍": "🦍", "🐾,❄️": "🐻", "🐻,❄️": "🐻‍❄️",
        "🐾,🌊": "🐟", "🐟,🌊": "🦈", "🦈,🌊": "🐋", "🐟,💧": "🐠",
        "🐾,🏜️": "🐪", "🐪,🏜️": "🐫", "🐾,🌾": "🐄", "🐄,🥛": "🧀",
        "🐾,🔥": "🐉", "🐉,⛰️": "🌋", "🐾,☁️": "🦅", "🦅,🐭": "🦉",
        "🐭,🧀": "🐁", "🐾,🏠": "🐶", "🐶,🦴": "🐕", "🐾,🧶": "🐱"
    }

    # Tier 4: Materials & Crafting
    tier4_recipes = {
        "🪨,⚒️": "🧱", "🧱,🧱": "🏠", "🏠,🏠": "🏘️", "🏘️,🏘️": "🏙️",
        "🌳,🪚": "🪵", "🪵,🔥": "🔥", "🪵,⚒️": "🪑", "🪵,🪧": "🏠",
        "🌍,🔥": "🧱", "🧱,💧": "🏺", "🏺,🔥": "🍶", "💎,⚒️": "💍",
        "⛓️,⚒️": "🛡️", "🛡️,🗡️": "⚔️", "⚔️,🛡️": "💂", "🧵,🪡": "👕",
        "👕,🎨": "👗", "🧶,🪡": "🧣", "🐑,✂️": "🧶", "🧶,🧶": "🧵"
    }

    # Tier 5: Tech & Advanced
    tier5_recipes = {
        "⚡,🌍": "🔋", "🔋,⚙️": "🤖", "🤖,💻": "🛰️", "🚀,🪐": "🌌",
        "🔭,✨": "🌌", "💻,📱": "📶", "📶,📱": "🌐", "🌐,💻": "💾",
        "💾,💿": "📼", "📷,🎞️": "🎥", "🎥,📺": "🎬", "🎬,🎭": "🎪"
    }

    # Merge all into one manual dictionary
    manual_recipes = {}
    manual_recipes.update(tier1_recipes)
    manual_recipes.update(tier2_recipes)
    manual_recipes.update(tier3_recipes)
    manual_recipes.update(tier4_recipes)
    manual_recipes.update(tier5_recipes)

    # Convert keys to sorted tuples to ensure commutativity
    processed_recipes = {}
    for k, v in manual_recipes.items():
        pair = tuple(sorted(k.split(",")))
        processed_recipes[",".join(pair)] = v

    # Final data structure
    # We'll gather all emojis used as results to ensure they are in the pool
    all_used_emojis = set(base)
    for k, v in processed_recipes.items():
        all_used_emojis.update(k.split(","))
        all_used_emojis.add(v)

    emoji_to_cat = {e: "Misc" for e in all_used_emojis}
    # Better categorization
    cat_map = {
        "Atmosphere": ["☁️", "🌧️", "❄️", "🌩️", "🌪️", "☀️", "🌈"],
        "Terrain": ["⛰️", "🏔️", "🏜️", "🌋", "🪨", "💎", "🧱", "🏠", "🏙️"],
        "Life": ["🌱", "🌿", "🌳", "🌲", "🌸", "🍄", "🐾", "🐻", "🐔", "🦋", "🐝", "🐄", "🐶", "🐱"],
        "Items": ["⚒️", "🪚", "🗡️", "🛡️", "⛓️", "🧵", "🎨", "👗", "🔋", "💻", "📱", "🚀", "🤖"],
        "Food": ["🍳", "🍯", "🧀", "🥛", "🍶", "🥣"]
    }
    for cat, items in cat_map.items():
        for item in items:
            if item in emoji_to_cat: emoji_to_cat[item] = cat

    data = {
        "base_emojis": base,
        "recipes": processed_recipes,
        "emoji_to_cat": emoji_to_cat,
        "categories": list(cat_map.keys()) + ["Misc"]
    }

    with open('assets/game_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Success! Generated {len(processed_recipes)} HAND-CURATED recipes.")

if __name__ == "__main__":
    generate_data()
