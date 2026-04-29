import '../models/emoji_element.dart';
import '../models/element_category.dart';
import '../models/combination.dart';

class ElementData {
  static const Map<String, EmojiElement> elements = {
    // Base
    'fire': EmojiElement(id: 'fire', emoji: '🔥', name: 'Fire', category: ElementCategory.base, isBase: true),
    'water': EmojiElement(id: 'water', emoji: '💧', name: 'Water', category: ElementCategory.base, isBase: true),
    'earth': EmojiElement(id: 'earth', emoji: '🌍', name: 'Earth', category: ElementCategory.base, isBase: true),
    'wind': EmojiElement(id: 'wind', emoji: '💨', name: 'Wind', category: ElementCategory.base, isBase: true),

    // Tier 1
    'steam': EmojiElement(id: 'steam', emoji: '💨', name: 'Steam', category: ElementCategory.weather),
    'plant': EmojiElement(id: 'plant', emoji: '🌱', name: 'Plant', category: ElementCategory.nature),
    'lava': EmojiElement(id: 'lava', emoji: '🌋', name: 'Lava', category: ElementCategory.nature),
    'tornado': EmojiElement(id: 'tornado', emoji: '🌪️', name: 'Tornado', category: ElementCategory.weather),
    'ocean': EmojiElement(id: 'ocean', emoji: '🌊', name: 'Ocean', category: ElementCategory.nature),
    'mountain': EmojiElement(id: 'mountain', emoji: '⛰️', name: 'Mountain', category: ElementCategory.nature),
    'sun': EmojiElement(id: 'sun', emoji: '☀️', name: 'Sun', category: ElementCategory.space),

    // Tier 2
    'tree': EmojiElement(id: 'tree', emoji: '🌳', name: 'Tree', category: ElementCategory.nature),
    'wood': EmojiElement(id: 'wood', emoji: '🪵', name: 'Wood', category: ElementCategory.nature),
    'rainbow': EmojiElement(id: 'rainbow', emoji: '🌈', name: 'Rainbow', category: ElementCategory.weather),
    'eagle': EmojiElement(id: 'eagle', emoji: '🦅', name: 'Eagle', category: ElementCategory.animals),
    'mushroom': EmojiElement(id: 'mushroom', emoji: '🍄', name: 'Mushroom', category: ElementCategory.nature),
    'house': EmojiElement(id: 'house', emoji: '🏠', name: 'House', category: ElementCategory.human),
    'sunflower': EmojiElement(id: 'sunflower', emoji: '🌻', name: 'Sunflower', category: ElementCategory.nature),
    'rock': EmojiElement(id: 'rock', emoji: '🪨', name: 'Rock', category: ElementCategory.nature),
    'hurricane': EmojiElement(id: 'hurricane', emoji: '🌀', name: 'Hurricane', category: ElementCategory.weather),

    // Tier 3
    'city': EmojiElement(id: 'city', emoji: '🏙️', name: 'City', category: ElementCategory.human),
    'forest': EmojiElement(id: 'forest', emoji: '🌲', name: 'Forest', category: ElementCategory.nature),
    'owl': EmojiElement(id: 'owl', emoji: '🦉', name: 'Owl', category: ElementCategory.animals),
    'diamond': EmojiElement(id: 'diamond', emoji: '💎', name: 'Diamond', category: ElementCategory.nature),
    'island': EmojiElement(id: 'island', emoji: '🏝️', name: 'Island', category: ElementCategory.nature),
    'honey': EmojiElement(id: 'honey', emoji: '🍯', name: 'Honey', category: ElementCategory.food),
    'ring': EmojiElement(id: 'ring', emoji: '💍', name: 'Ring', category: ElementCategory.human),
    'night_city': EmojiElement(id: 'night_city', emoji: '🌆', name: 'Night City', category: ElementCategory.human),
    'airplane': EmojiElement(id: 'airplane', emoji: '✈️', name: 'Airplane', category: ElementCategory.technology),

    // Extra needed for Tier 3
    'bee': EmojiElement(id: 'bee', emoji: '🐝', name: 'Bee', category: ElementCategory.animals),
    'rain': EmojiElement(id: 'rain', emoji: '🌧️', name: 'Rain', category: ElementCategory.weather),

    // Tier 4
    'rocket': EmojiElement(id: 'rocket', emoji: '🚀', name: 'Rocket', category: ElementCategory.space),
    'ufo': EmojiElement(id: 'ufo', emoji: '🛸', name: 'UFO', category: ElementCategory.space),
    'alien': EmojiElement(id: 'alien', emoji: '👽', name: 'Alien', category: ElementCategory.space),
    'crystal_ball': EmojiElement(id: 'crystal_ball', emoji: '🔮', name: 'Crystal Ball', category: ElementCategory.magic),
    'wizard': EmojiElement(id: 'wizard', emoji: '🧙', name: 'Wizard', category: ElementCategory.magic),
    'dragon': EmojiElement(id: 'dragon', emoji: '🐉', name: 'Dragon', category: ElementCategory.mythology),
    'dinosaur': EmojiElement(id: 'dinosaur', emoji: '🦕', name: 'Dinosaur', category: ElementCategory.animals),
    'ancient_world': EmojiElement(id: 'ancient_world', emoji: '🌏', name: 'Ancient World', category: ElementCategory.space),

    // Extra needed for Tier 4
    'human': EmojiElement(id: 'human', emoji: '👤', name: 'Human', category: ElementCategory.human),
    'moon': EmojiElement(id: 'moon', emoji: '🌙', name: 'Moon', category: ElementCategory.space),

    // Easter egg
    'teddy_bear': EmojiElement(id: 'teddy_bear', emoji: '🧸', name: 'Teddy Bear', category: ElementCategory.human),
    'magic': EmojiElement(id: 'magic', emoji: '✨', name: 'Magic', category: ElementCategory.magic),
    'zombie': EmojiElement(id: 'zombie', emoji: '🧟', name: 'Zombie', category: ElementCategory.mythology),
    'rock_music': EmojiElement(id: 'rock_music', emoji: '🎸', name: 'Rock Music', category: ElementCategory.human),
    'haunted_house': EmojiElement(id: 'haunted_house', emoji: '🏚️', name: 'Haunted House', category: ElementCategory.human),
    'dream': EmojiElement(id: 'dream', emoji: '💭', name: 'Dream', category: ElementCategory.human),
    'deep_sleep': EmojiElement(id: 'deep_sleep', emoji: '😴', name: 'Deep Sleep', category: ElementCategory.human),

    // Extra needed for Easter egg
    'bear': EmojiElement(id: 'bear', emoji: '🐻', name: 'Bear', category: ElementCategory.animals),
    'unicorn': EmojiElement(id: 'unicorn', emoji: '🦄', name: 'Unicorn', category: ElementCategory.mythology),
    'skull': EmojiElement(id: 'skull', emoji: '💀', name: 'Skull', category: ElementCategory.human),
    'music': EmojiElement(id: 'music', emoji: '🎵', name: 'Music', category: ElementCategory.human),
    'ghost': EmojiElement(id: 'ghost', emoji: '👻', name: 'Ghost', category: ElementCategory.mythology),
    'sleep': EmojiElement(id: 'sleep', emoji: '💤', name: 'Sleep', category: ElementCategory.human),
    'sheep': EmojiElement(id: 'sheep', emoji: '🐑', name: 'Sheep', category: ElementCategory.animals),
  };

  static const List<Combination> combinations = [
    // Tier 1
    Combination(element1: 'fire', element2: 'water', result: 'steam'),
    Combination(element1: 'water', element2: 'earth', result: 'plant'),
    Combination(element1: 'fire', element2: 'earth', result: 'lava'),
    Combination(element1: 'wind', element2: 'wind', result: 'tornado'),
    Combination(element1: 'water', element2: 'water', result: 'ocean'),
    Combination(element1: 'earth', element2: 'earth', result: 'mountain'),
    Combination(element1: 'fire', element2: 'fire', result: 'sun'),

    // Tier 2
    Combination(element1: 'plant', element2: 'plant', result: 'tree'),
    Combination(element1: 'tree', element2: 'fire', result: 'wood'),
    Combination(element1: 'ocean', element2: 'sun', result: 'rainbow'),
    Combination(element1: 'mountain', element2: 'wind', result: 'eagle'),
    Combination(element1: 'plant', element2: 'water', result: 'mushroom'),
    Combination(element1: 'wood', element2: 'wood', result: 'house'),
    Combination(element1: 'sun', element2: 'earth', result: 'sunflower'),
    Combination(element1: 'lava', element2: 'water', result: 'rock'),
    Combination(element1: 'tornado', element2: 'ocean', result: 'hurricane'),

    // Extra for Tier 3
    Combination(element1: 'sunflower', element2: 'wind', result: 'bee'), // Created bee
    Combination(element1: 'steam', element2: 'water', result: 'rain'),   // Created rain

    // Tier 3
    Combination(element1: 'house', element2: 'house', result: 'city'),
    Combination(element1: 'tree', element2: 'tree', result: 'forest'),
    Combination(element1: 'forest', element2: 'eagle', result: 'owl'),
    Combination(element1: 'rock', element2: 'rock', result: 'diamond'),
    Combination(element1: 'ocean', element2: 'lava', result: 'island'),
    Combination(element1: 'sunflower', element2: 'bee', result: 'honey'),
    Combination(element1: 'diamond', element2: 'fire', result: 'ring'),
    Combination(element1: 'city', element2: 'rain', result: 'night_city'),
    Combination(element1: 'eagle', element2: 'wind', result: 'airplane'),

    // Extra for Tier 4
    Combination(element1: 'earth', element2: 'sun', result: 'human'),      // Created human
    Combination(element1: 'sun', element2: 'rock', result: 'moon'),        // Created moon

    // Tier 4
    Combination(element1: 'airplane', element2: 'sun', result: 'rocket'),
    Combination(element1: 'rocket', element2: 'earth', result: 'ufo'),
    Combination(element1: 'ufo', element2: 'human', result: 'alien'),
    Combination(element1: 'diamond', element2: 'alien', result: 'crystal_ball'),
    Combination(element1: 'crystal_ball', element2: 'moon', result: 'wizard'),
    Combination(element1: 'wizard', element2: 'fire', result: 'dragon'),
    Combination(element1: 'dragon', element2: 'ocean', result: 'dinosaur'),
    Combination(element1: 'dinosaur', element2: 'mountain', result: 'ancient_world'),

    // Extra for Easter Egg
    Combination(element1: 'tree', element2: 'mushroom', result: 'bear'),      // Created bear
    Combination(element1: 'rainbow', element2: 'eagle', result: 'unicorn'),   // Created unicorn
    Combination(element1: 'human', element2: 'fire', result: 'skull'),        // Created skull
    Combination(element1: 'eagle', element2: 'sun', result: 'music'),         // Created music
    Combination(element1: 'skull', element2: 'wind', result: 'ghost'),        // Created ghost
    Combination(element1: 'human', element2: 'moon', result: 'sleep'),        // Created sleep
    Combination(element1: 'human', element2: 'mushroom', result: 'sheep'),    // Created sheep

    // Easter Egg
    Combination(element1: 'honey', element2: 'bear', result: 'teddy_bear'),
    Combination(element1: 'rainbow', element2: 'unicorn', result: 'magic'),
    Combination(element1: 'wizard', element2: 'skull', result: 'zombie'),
    Combination(element1: 'music', element2: 'fire', result: 'rock_music'),
    Combination(element1: 'house', element2: 'ghost', result: 'haunted_house'),
    Combination(element1: 'sleep', element2: 'moon', result: 'dream'),
    Combination(element1: 'dream', element2: 'sheep', result: 'deep_sleep'),
  ];
}
