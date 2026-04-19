import json
import random

def generate_data():
    # Base emojis
    base = ["💧", "🔥", "🌍", "💨"]
    
    # Categorized pools (Initial seeds)
    pools = {
        "Elements": ["🔥", "💧", "🌍", "💨", "🌫️", "🌋", "🌊", "☀️", "⛰️", "🌧️", "☄️", "⛈️", "🌈", "🌀", "🏔️", "🌪️", "🗻", "🧊", "🪨"],
        "Nature": ["🌱", "🌳", "🌿", "🏜️", "🌾", "🌸", "🌻", "🌲", "🌵", "🍄", "🍁", "🍂", "🍃", "🌴", "🍀", "🎋", "🐚"],
        "Fauna": ["🐻", "🦁", "🐯", "🐱", "🐶", "🐺", "🦊", "🦝", "🐮", "🐷", "🐭", "🐹", "🐰", "🐻‍❄️", "🐨", "🐼", "🐸", "🐉", "🦖", "🦕", "🐢", "🐍", "🦎", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓", "🦍", "🦧", "🐘", "🦛", "🦏", "🐪", "🐫", "🦒", "🦘", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏", "🐑", "🐐", "🦌", "🐕", "🐩", "🐈", "🐓", "🦃", "🦚", "🦜", "🦢", "🕊️", "🐇", "🦝", "🦨", "🦥", "🦦", "🦫", "🦘", "🦡"],
        "Space": ["☀️", "🌙", "⭐", "🪐", "🌠", "🌌", "🌍", "🌎", "🌏", "☄️", "🛸", "🚀", "🛰️", "🔭", "👽", "👾"],
        "Items": ["⚒️", "🛠️", "⚙️", "🕰️", "💎", "⚖️", "🗡️", "🛡️", "🏹", "🔮", "🪄", "🪔", "🕯️", "📖", "📜", "📂", "🔋", "💡", "🔦", "💻", "鼠标", "⌨️", "🖥️", "📱", "📻", "📺", "📷", "📽️", "🎬", "🎭", "🎨", "🧵", "🧶", "🧪", "🧫", "🧬", "💊", "💉"],
        "Food": ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🥑", "🥦", "🥬", "🥒", "🌽", "🥕", "🧄", "🧅", "🥔", "🥐", "🍞", "🌭", "🍔", "🍟", "🍕", "🍳", "🍱", "🍣", "🥟", "🍦", "🍩", "🍪", "🎂", "🍫", "🍯"]
    }

    all_emojis_with_cat = []
    emoji_to_cat = {}
    
    for cat, items in pools.items():
        for item in items:
            all_emojis_with_cat.append(item)
            emoji_to_cat[item] = cat
            
    all_emojis_list = list(set(all_emojis_with_cat))
    
    # Expand to 1,250 emojis as requested (1000 more than the previous ~250)
    target_count = 1250
    
    # Use multiple Unicode ranges for variety
    ranges = [
        (0x1F300, 0x1F5FF), # Misc Symbols and Pictographs
        (0x1F600, 0x1F64F), # Emoticons
        (0x1F680, 0x1F6FF), # Transport and Map Symbols
        (0x1F900, 0x1F9FF), # Supplemental Symbols and Pictographs
        (0x1FA70, 0x1FAFF), # Symbols and Pictographs Extended-A
    ]
    
    print(f"Expanding emoji pool to {target_count}...")
    
    while len(all_emojis_list) < target_count:
        r_start, r_end = random.choice(ranges)
        new_emoji = chr(random.randint(r_start, r_end))
        if new_emoji not in all_emojis_list:
            all_emojis_list.append(new_emoji)
            emoji_to_cat[new_emoji] = "Misc"

    # Hand-crafted base recipes (seed)
    recipes = {
        "💧,🔥": "💨",
        "💧,🌍": "🌱",
        "🔥,🌍": "🌋",
        "💨,🌍": "🌪️",
        "💧,💧": "🌊",
        "🔥,🔥": "☀️",
        "🌍,🌍": "⛰️",
        "💨,💨": "🌬️",
        "🌱,💧": "🌳",
        "🌱,🔥": "🍂",
        "🌍,💨": "🏜️",
        "🌊,🔥": "🌫️",
        "🌩️,🌍": "💎",
        "🌞,🌧️": "🌈",
        "☁️,⚡": "⛈️",
        "🧊,🔥": "💧",
        "🌱,🌱": "🌿",
        "🌳,🌳": "🌲",
        "💨,🔥": "⚡",
    }

    recipe_keys = set()
    for k in recipes.keys():
        recipe_keys.add(tuple(sorted(k.split(","))))

    # Update recipe goal: Scaling up recipes to keep the game dense enough
    # With 1250 emojis, 10000 was okay, but let's go for 25000 for more discovery fun
    target_recipes = 25000
    print(f"Generating {target_recipes} combinations for {len(all_emojis_list)} emojis...")
    
    attempts = 0
    while len(recipes) < target_recipes and attempts < 5000000:
        a = random.choice(all_emojis_list)
        b = random.choice(all_emojis_list)
        pair = tuple(sorted([a, b]))
        
        if pair not in recipe_keys:
            # Result is picked from the pool
            result = random.choice(all_emojis_list)
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

    print(f"Success! Generated {len(recipes)} recipes and categorized {len(emoji_to_cat)} emojis.")

if __name__ == "__main__":
    generate_data()
