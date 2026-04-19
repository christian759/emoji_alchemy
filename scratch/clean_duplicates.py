import json

def clean_recipes():
    with open('assets/game_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    recipes = data.get('recipes', {})
    new_recipes = {}
    
    for pair_str, result in recipes.items():
        pair = pair_str.split(',')
        # Remove if result is same as either input
        if result not in pair:
            new_recipes[pair_str] = result
        else:
            # For some specific ones like Water + Water = Ocean, we might want to keep if result is DIFFERENT but related
            # But the user specifically said "if theresult is same as input"
            pass
            
    data['recipes'] = new_recipes
    
    with open('assets/game_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Cleaned! Removed {len(recipes) - len(new_recipes)} duplicate result recipes.")

if __name__ == "__main__":
    clean_recipes()
