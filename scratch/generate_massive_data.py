import json
import random

def generate_data():
    # Base emojis
    base = ["💧", "🔥", "🌍", "💨"]
    
    # Categorized pools
    pools = {
        "Elements": ["🔥", "💧", "🌍", "💨", "🌫️", "🌋", "🌊", "☀️", "⛰️", "🌧️", "☄️", "⛈️", "🌈", "🌀", "🏔️", "🌪️", "🗻", "🧊", "🪨"],
        "Nature": ["🌱", "🌳", "🌿", "🏜️", "🌾", "🌸", "🌻", "🌲", "🌵", "🍄", "🍁", "🍂", "🍃", "🌴", "🍀", "🎋", "🐚"],
        "Fauna": ["🐻", "🦁", "🐯", "🐱", "🐶", "🐺", "🦊", "🦝", "🐮", "🐷", "🐭", "🐹", "🐰", "🐻‍❄️", "🐨", "🐼", "🐸", "🐉", "🦖", "🦕", "🐢", "🐍", "🦎", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓", "🦍", "🦧", "🐘", "🦛", "🦏", "🐪", "🐫", "🦒", "🦘", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏", "🐑", "🐐", "🦌", "🐕", "🐩", "🐈", "🐓", "🦃", "🦚", "🦜", "🦢", "🕊️", "🐇", "🦝", "🦨", "🦥", "🦦", "🦫", "🦘", "🦡"],
        "Space": ["☀️", "🌙", "⭐", "🪐", "🌠", "🌌", "🌍", "🌎", "🌏", "☄️", "🛸", "🚀", "🛰️", "🔭", "👽", "👾"],
        "Items": ["⚒️", "🛠️", "⚙️", "🕰️", "💎", "⚖️", "🗡️", "🛡️", "🏹", "🔮", "🪄", "🪔", "🕯️", "📖", "📜", "📂", "🔋", "💡", "🔦", "💻", "🖱️", "🖥️", "📱", "📻", "📺", "📷", "📽️", "🎬", "🎭", "🎨", "🧵", "🧶", "🧪", "🧫", "🧬", "💊", "💉"],
        "Food": ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", " eggplant", "🥑", "🥦", "🥬", "🥒", "🌽", "🥕", "🧄", "🧅", "🥔", "🥐", "🍞", "🌭", "🍔", "🍟", "🍕", "🍳", "🍱", "🍣", "🥟", "🍦", "🍩", "🍪", "🎂", "🍫", "🍯"]
    }

    # Flatten categories for easier random pick while keeping mapping
    all_emojis_with_cat = []
    emoji_to_cat = {}
    
    for cat, items in pools.items():
        for item in items:
            all_emojis_with_cat.append(item)
            emoji_to_cat[item] = cat
            
    all_emojis_list = list(set(all_emojis_with_cat))
    
    # Expand to 250 emojis to reach 10,000 combinations
    current_count = len(all_emojis_list)
    target_count = 250
    start_code = 0x1F300
    while len(all_emojis_list) < target_count:
        new_emoji = chr(start_code)
        if new_emoji not in all_emojis_list:
            all_emojis_list.append(new_emoji)
            emoji_to_cat[new_emoji] = "Misc"
        start_code += 1

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

    print(f"Generating combinations for {len(all_emojis_list)} emojis across categories...")
    
    recipe_keys = set()
    for k in recipes.keys():
        recipe_keys.add(tuple(sorted(k.split(","))))

    attempts = 0
    while len(recipes) < 10000 and attempts < 2000000:
        a = random.choice(all_emojis_list)
        b = random.choice(all_emojis_list)
        pair = tuple(sorted([a, b]))
        
        if pair not in recipe_keys:
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
