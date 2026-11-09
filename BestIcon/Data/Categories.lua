local ADDON, BI = ...

BI.Categories = {
    { key = "camps", tokens = {"camp", "campfire", "camping", "tent", "bedroll", "log", "fire"} },
    { key = "food", tokens = {
        "food", "meat", "fish", "bread", "cheese", "fruit", "drink", "cooking",
        "feast", "stew", "soup", "pie", "cake", "egg", "potato", "wheat",
        "rice", "banana", "apple", "berry", "water", "beer", "wine",
    } },
    { key = "weapons", tokens = {
        "sword", "axe", "mace", "dagger", "knife", "staff", "bow", "crossbow",
        "gun", "rifle", "polearm", "wand", "weapon", "blade", "hammer",
        "spear", "glaive", "halberd", "arrow", "bullet", "scythe",
    } },
    { key = "armor", tokens = {
        "armor", "helm", "chest", "shoulder", "belt", "boot", "glove",
        "bracer", "cape", "cloth", "leather", "mail", "plate", "robe",
        "pants", "shirt", "tabard", "ring", "necklace", "trinket", "jewelry",
    } },
    { key = "shields", tokens = {"shield", "bulwark"} },
    { key = "magic", tokens = {
        "magic", "arcane", "shadow", "holy", "fel", "frost", "enchant",
        "rune", "glyph", "scroll", "wand", "orb", "crystal", "potion",
        "elixir", "tome", "book",
    } },
    { key = "fire", tokens = {"fire", "flame", "ember", "lava", "inferno", "molten", "burning"} },
    { key = "water", tokens = {"water", "sea", "river", "fish", "frost", "ice", "wave", "tide", "aquatic"} },
    { key = "nature", tokens = {
        "nature", "plant", "flower", "leaf", "tree", "herb", "mushroom",
        "seed", "moss", "forest", "jungle", "grass", "thorn", "vine",
    } },
    { key = "totems", tokens = {"totem", "idol", "relic", "libram", "sigil", "talisman"} },
    { key = "creatures", tokens = {
        "beast", "dragon", "wolf", "bear", "cat", "spider", "snake", "fish",
        "bird", "demon", "undead", "elemental", "giant", "troll", "orc",
        "murloc", "boar", "raptor", "wasp", "scorpion",
    } },
    { key = "professions", tokens = {
        "alchemy", "blacksmithing", "enchanting", "engineering", "herbalism",
        "inscription", "jewelcrafting", "leatherworking", "mining", "skinning",
        "tailoring", "cooking", "fishing", "archaeology", "firstaid",
    } },
    { key = "items", tokens = {
        "bag", "box", "key", "coin", "gem", "ore", "ingot", "cloth", "leather",
        "herb", "potion", "scroll", "book", "map", "toy", "trophy", "reagent",
    } },
    { key = "mounts", tokens = {
        "mount", "horse", "wolf", "drake", "dragon", "raptor", "elekk", "kodo",
        "ram", "saber", "wyvern", "gryphon", "hippogryph", "talbuk", "flying",
        "riding", "saddle",
    } },
    { key = "pets", tokens = {
        "pet", "companion", "critter", "whelpling", "cat", "dog", "rabbit",
        "squirrel", "bird", "turtle", "fox",
    } },
    { key = "dungeons", tokens = {"dungeon", "raid", "boss", "cave", "crypt"} },
    { key = "misc", tokens = {} },
}
