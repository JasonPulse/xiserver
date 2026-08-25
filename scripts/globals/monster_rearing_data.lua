-----------------------------------
-- Monster Rearing data tables.
--
-- Generated from the bg-wiki "Monster Rearing" family tables joined to the
-- client's own species menus. Two things come from the client rather than the
-- wiki, because the client is what the player sees:
--   * family order and id, from dialog 8663's choice list;
--   * which rank unlocks which family, from the per-rank menus 8635-8641.
--
-- A form id IS its memento key item id. The mementos run 2642-2715 in exactly
-- family-then-growth order and 3192-3201 for the mandragora line added later,
-- and every cheer is its memento plus a fixed offset, so one number identifies
-- a creature, names its memento and names its cheer.
-----------------------------------
xi = xi or {}
xi.monsterRearing = xi.monsterRearing or {}

---@enum xi.monsterRearing.foodType
xi.monsterRearing.foodType =
{
    CRYSTALS = 1,
    FISH     = 2,
    FRUITS   = 3,
    FUNGI    = 4,
    GREENS   = 5,
    LIQUIDS  = 6,
    MEATS    = 7,
    SEEDS    = 8,
}

---@enum xi.monsterRearing.interaction
xi.monsterRearing.interaction =
{
    PET   = 1,
    POKE  = 2,
    SLAP  = 3,
    YELL  = 4,
    ANGRY = 5,
}

-- Every item a creature will eat, mapped to the food group it belongs to.
xi.monsterRearing.foodGroup =
{
    -- Crystals
    [xi.item.DARK_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.EARTH_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.FIRE_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.GEM_OF_THE_EAST] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.GEM_OF_THE_NORTH] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.GEM_OF_THE_SOUTH] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.GEM_OF_THE_WEST] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.ICE_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.LIGHT_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.LIGHTNING_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.WATER_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    [xi.item.WIND_CLUSTER] = xi.monsterRearing.foodType.CRYSTALS,
    -- Fish
    [xi.item.BASTORE_SARDINE_1] = xi.monsterRearing.foodType.FISH,
    [xi.item.BIBIKI_SLUG] = xi.monsterRearing.foodType.FISH,
    [xi.item.BIBIKI_URCHIN] = xi.monsterRearing.foodType.FISH,
    [xi.item.CORAL_BUTTERFLY] = xi.monsterRearing.foodType.FISH,
    [xi.item.DENIZANASI] = xi.monsterRearing.foodType.FISH,
    [xi.item.NOBLE_LADY] = xi.monsterRearing.foodType.FISH,
    [xi.item.QUUS_1] = xi.monsterRearing.foodType.FISH,
    [xi.item.THREE_EYED_FISH_1] = xi.monsterRearing.foodType.FISH,
    -- Fruits
    [xi.item.ACORN] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.RONFAURE_CHESTNUT] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.DATE] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.DRAGON_FRUIT] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.FAERIE_APPLE] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.BUNCH_OF_KAZHAM_PEPPERS] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.KITRON] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.EAR_OF_MILLIONCORN] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.PERSIKOS] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.HANDFUL_OF_PINE_NUTS] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.BUNCH_OF_ROYAL_GRAPES] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.SARUTA_ORANGE] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.YAGUDO_CHERRY] = xi.monsterRearing.foodType.FRUITS,
    [xi.item.WATERMELON] = xi.monsterRearing.foodType.FRUITS,
    -- Fungi
    [xi.item.CLUMP_OF_ACIDIC_HUMUS] = xi.monsterRearing.foodType.FUNGI,
    [xi.item.AGARICUS_MUSHROOM] = xi.monsterRearing.foodType.FUNGI,
    [xi.item.CLUMP_OF_ALKALINE_HUMUS] = xi.monsterRearing.foodType.FUNGI,
    [xi.item.CORAL_FUNGUS] = xi.monsterRearing.foodType.FUNGI,
    [xi.item.REISHI_MUSHROOM] = xi.monsterRearing.foodType.FUNGI,
    [xi.item.SOBBING_FUNGUS] = xi.monsterRearing.foodType.FUNGI,
    -- Greens
    [xi.item.CLUMP_OF_BATAGREENS] = xi.monsterRearing.foodType.GREENS,
    [xi.item.CLUMP_OF_BLUE_PONDWEED] = xi.monsterRearing.foodType.GREENS,
    [xi.item.CLUMP_OF_BOYAHDA_MOSS] = xi.monsterRearing.foodType.GREENS,
    [xi.item.CLUMP_OF_GREAT_BOYAHDA_MOSS] = xi.monsterRearing.foodType.GREENS,
    [xi.item.BUNCH_OF_HABANERO_PEPPERS] = xi.monsterRearing.foodType.GREENS,
    [xi.item.LA_THEINE_CABBAGE] = xi.monsterRearing.foodType.GREENS,
    [xi.item.CLUMP_OF_MOKO_GRASS] = xi.monsterRearing.foodType.GREENS,
    [xi.item.HEAD_OF_NAPA] = xi.monsterRearing.foodType.GREENS,
    [xi.item.PAPAKA_GRASS] = xi.monsterRearing.foodType.GREENS,
    [xi.item.CLUMP_OF_RED_MOKO_GRASS] = xi.monsterRearing.foodType.GREENS,
    [xi.item.CLUMP_OF_RED_PONDWEED] = xi.monsterRearing.foodType.GREENS,
    [xi.item.THUNDERMELON] = xi.monsterRearing.foodType.GREENS,
    -- Liquids
    [xi.item.BOTTLE_OF_AHRIMAN_TEARS] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.BOWL_OF_AMBROSIA] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.BOTTLE_OF_AMRITA] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.VIAL_OF_BEASTMAN_BLOOD] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.VIAL_OF_CHIMERA_BLOOD] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.FLASK_OF_DISTILLED_WATER] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.ELIXIR] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.VIAL_OF_FIEND_BLOOD] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.FLASK_OF_HOLY_WATER] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.JUG_OF_HONEY_WINE] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.BOTTLE_OF_MULSUM] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.UNAPPRAISED_POTION] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.CUP_OF_SWEET_TEA] = xi.monsterRearing.foodType.LIQUIDS,
    [xi.item.PIECE_OF_YELLOW_GINSENG] = xi.monsterRearing.foodType.LIQUIDS,
    -- Meats
    [xi.item.BEASTLY_SHANK] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_BUFFALO_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_CERBERUS_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_COCKATRICE_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_DRAGON_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_GABBRATH_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_GIANT_SHEEP_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_HARE_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.CHUNK_OF_HYDRA_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.LESSER_CHIGOE] = xi.monsterRearing.foodType.MEATS,
    [xi.item.PIECE_OF_ROTTEN_MEAT] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SAVORY_SHANK] = xi.monsterRearing.foodType.MEATS,
    [xi.item.TAVNAZIAN_LIVER] = xi.monsterRearing.foodType.MEATS,
    [xi.item.SLICE_OF_WARTHOG_MEAT] = xi.monsterRearing.foodType.MEATS,
    -- Seeds
    [xi.item.POD_OF_BLUE_PEAS] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.BURDOCK_ROOT] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.DELUXE_CARROT] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.MOON_CARROT] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.POPOTO] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.SAN_DORIAN_CARROT] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.HANDFUL_OF_SUNFLOWER_SEEDS] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.VOMP_CARROT] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.WALNUT] = xi.monsterRearing.foodType.SEEDS,
    [xi.item.ZEGHAM_CARROT] = xi.monsterRearing.foodType.SEEDS,
}

-- Family id is the client's own ordering. `blurb` is the dialog id Chacharoon
-- reads out when the species is highlighted in the "new creature" menu.
xi.monsterRearing.families =
{
    [1] =
    {
        name     = 'Sheep',
        rank     = 1,
        baby     = xi.ki.LAMB_MEMENTO,
        blurb    = 8642,
        lateStar = true,
    },
    [2] =
    {
        name     = 'Rabbit',
        rank     = 1,
        baby     = xi.ki.BABY_RABBIT_MEMENTO,
        blurb    = 8643,
        lateStar = false,
    },
    [3] =
    {
        name     = 'Treant',
        rank     = 1,
        baby     = xi.ki.SAPLING_MEMENTO,
        blurb    = 8644,
        lateStar = false,
    },
    [4] =
    {
        name     = 'Lizard',
        rank     = 1,
        baby     = xi.ki.BABY_LIZARD_MEMENTO,
        blurb    = 8645,
        lateStar = false,
    },
    [5] =
    {
        name     = 'Cockatrice',
        rank     = 2,
        baby     = xi.ki.BABY_COCKATRICE_MEMENTO,
        blurb    = 8646,
        lateStar = false,
    },
    [6] =
    {
        name     = 'Raptor',
        rank     = 2,
        baby     = xi.ki.BABY_RAPTOR_MEMENTO,
        blurb    = 8647,
        lateStar = false,
    },
    [7] =
    {
        name     = 'Eft',
        rank     = 2,
        baby     = xi.ki.BABY_EFT_MEMENTO,
        blurb    = 8648,
        lateStar = false,
    },
    [8] =
    {
        name     = 'Dhalmel',
        rank     = 3,
        baby     = xi.ki.DHALMEL_CALF_MEMENTO,
        blurb    = 8649,
        lateStar = true,
    },
    [9] =
    {
        name     = 'Sea Monk',
        rank     = 3,
        baby     = xi.ki.SEA_MONK_LARVA_MEMENTO,
        blurb    = 8650,
        lateStar = false,
    },
    [10] =
    {
        name     = 'Uragnite',
        rank     = 3,
        baby     = xi.ki.URAGNITE_YOUNGLING_MEMENTO,
        blurb    = 8651,
        lateStar = false,
    },
    [11] =
    {
        name     = 'Crab',
        rank     = 3,
        baby     = xi.ki.IMMATURE_CRAB_MEMENTO,
        blurb    = 8652,
        lateStar = true,
    },
    [12] =
    {
        name     = 'Colibri',
        rank     = 3,
        baby     = xi.ki.BABY_COLIBRI_MEMENTO,
        blurb    = 8653,
        lateStar = false,
    },
    [13] =
    {
        name     = 'Coeurl',
        rank     = 4,
        baby     = xi.ki.COEURL_CUB_MEMENTO,
        blurb    = 8654,
        lateStar = false,
    },
    [14] =
    {
        name     = 'Buffalo',
        rank     = 4,
        baby     = xi.ki.BUFFALO_CALF_MEMENTO,
        blurb    = 8655,
        lateStar = false,
    },
    [15] =
    {
        name     = 'Slime',
        rank     = 4,
        baby     = xi.ki.MINI_SLIME_MEMENTO,
        blurb    = 8656,
        lateStar = true,
    },
    [16] =
    {
        name     = 'Mandragora',
        rank     = 4,
        baby     = xi.ki.MANDRAGORA_SPROUTLING_MEMENTO,
        blurb    = 8751,
        lateStar = true,
    },
    [17] =
    {
        name     = 'Bugard',
        rank     = 5,
        baby     = xi.ki.TINY_BUGARD_MEMENTO,
        blurb    = 8657,
        lateStar = false,
    },
    [18] =
    {
        name     = 'Adamantoise',
        rank     = 5,
        baby     = xi.ki.BABY_ADAMANTOISE_MEMENTO,
        blurb    = 8658,
        lateStar = true,
    },
    [19] =
    {
        name     = 'Bomb',
        rank     = 6,
        baby     = xi.ki.CLUSTER_MEMENTO,
        blurb    = 8659,
        lateStar = true,
    },
    [20] =
    {
        name     = 'Behemoth',
        rank     = 6,
        baby     = xi.ki.BEHEMOTH_CUB_MEMENTO,
        blurb    = 8660,
        lateStar = true,
    },
    [21] =
    {
        name     = 'Sabotender',
        rank     = 7,
        baby     = xi.ki.PEQUETENDER_MEMENTO,
        blurb    = 8661,
        lateStar = true,
    },
    [22] =
    {
        name     = 'Dragon',
        rank     = 7,
        baby     = xi.ki.DRAGON_HATCHLING_MEMENTO,
        blurb    = 8662,
        lateStar = true,
    },
}

-- One entry per creature form, keyed by its memento key item id.
xi.monsterRearing.forms =
{
    [xi.ki.LAMB_MEMENTO] =
    {
        name         = 'Lamb',
        family       = 1,
        tier         = 1,
        cheer        = xi.ki.CHEER_LAMB,
        collectItem  = xi.item.FLAX_FLOWER,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   =
        {
            { form = xi.ki.SHEEP_MEMENTO, food = xi.item.CLUMP_OF_BOYAHDA_MOSS, natural = true },
            { form = xi.ki.KARAKUL_MEMENTO, food = xi.item.HEAD_OF_NAPA, natural = false },
        },
    },
    [xi.ki.SHEEP_MEMENTO] =
    {
        name         = 'Sheep',
        family       = 1,
        tier         = 2,
        cheer        = xi.ki.CHEER_SHEEP,
        collectItem  = xi.item.CLUMP_OF_WINDURSTIAN_TEA_LEAVES,
        interactions = { xi.monsterRearing.interaction.PET, xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   =
        {
            { form = xi.ki.RAM_MEMENTO, food = xi.item.CLUMP_OF_GREAT_BOYAHDA_MOSS, natural = false },
        },
    },
    [xi.ki.RAM_MEMENTO] =
    {
        name         = 'Ram',
        family       = 1,
        tier         = 3,
        cheer        = xi.ki.CHEER_RAM,
        collectItem  = xi.item.RAM_SKIN,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   = { },
    },
    [xi.ki.KARAKUL_MEMENTO] =
    {
        name         = 'Karakul',
        family       = 1,
        tier         = 2,
        cheer        = xi.ki.CHEER_KARAKUL,
        collectItem  = xi.item.CLUMP_OF_IMPERIAL_TEA_LEAVES,
        interactions = { xi.monsterRearing.interaction.PET, xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   = { },
    },
    [xi.ki.BABY_RABBIT_MEMENTO] =
    {
        name         = 'Baby Rabbit',
        family       = 2,
        tier         = 1,
        cheer        = xi.ki.CHEER_BABY_RABBIT,
        collectItem  = xi.item.RABBIT_HIDE,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS, xi.monsterRearing.foodType.FRUITS, xi.monsterRearing.foodType.SEEDS },
        resonating   = { xi.monsterRearing.foodType.SEEDS },
        evolutions   =
        {
            { form = xi.ki.RABBIT_MEMENTO, food = xi.item.SAN_DORIAN_CARROT, natural = true },
            { form = xi.ki.WHITE_RABBIT_MEMENTO, food = xi.item.CLUMP_OF_RED_MOKO_GRASS, natural = false },
        },
    },
    [xi.ki.RABBIT_MEMENTO] =
    {
        name         = 'Rabbit',
        family       = 2,
        tier         = 2,
        cheer        = xi.ki.CHEER_RABBIT,
        collectItem  = xi.item.SLICE_OF_HARE_MEAT,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS, xi.monsterRearing.foodType.FRUITS, xi.monsterRearing.foodType.SEEDS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.WHITE_RABBIT_MEMENTO] =
    {
        name         = 'White Rabbit',
        family       = 2,
        tier         = 2,
        cheer        = xi.ki.CHEER_WHITE_RABBIT,
        collectItem  = xi.item.FROST_TURNIP,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS, xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.SAPLING_MEMENTO] =
    {
        name         = 'Sapling',
        family       = 3,
        tier         = 1,
        cheer        = xi.ki.CHEER_SAPLING,
        collectItem  = xi.item.BAG_OF_FLOWER_SEEDS,
        interactions = { xi.monsterRearing.interaction.PET, xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.GREEN_FOLIAGE_TREANT_MEMENTO, food = xi.item.VIAL_OF_FIEND_BLOOD, natural = true },
            { form = xi.ki.RED_FOLIAGE_TREANT_MEMENTO, food = xi.item.UNAPPRAISED_POTION, natural = false },
        },
    },
    [xi.ki.GREEN_FOLIAGE_TREANT_MEMENTO] =
    {
        name         = 'Green Foliage Treant',
        family       = 3,
        tier         = 2,
        cheer        = xi.ki.CHEER_G_FOL_TREANT,
        collectItem  = xi.item.BAG_OF_TREE_CUTTINGS,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.RED_FOLIAGE_TREANT_MEMENTO] =
    {
        name         = 'Red Foliage Treant',
        family       = 3,
        tier         = 2,
        cheer        = xi.ki.CHEER_R_FOL_TREANT,
        collectItem  = xi.item.ELM_LOG,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.BABY_LIZARD_MEMENTO] =
    {
        name         = 'Baby Lizard',
        family       = 4,
        tier         = 1,
        cheer        = xi.ki.CHEER_BABY_LIZARD,
        collectItem  = xi.item.LIZARD_SKIN,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.MEATS, xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.LIZARD_MEMENTO, food = nil, natural = true },
            { form = xi.ki.ALABASTER_LIZARD_MEMENTO, food = xi.item.PIECE_OF_ROTTEN_MEAT, natural = false },
        },
    },
    [xi.ki.LIZARD_MEMENTO] =
    {
        name         = 'Lizard',
        family       = 4,
        tier         = 2,
        cheer        = xi.ki.CHEER_LIZARD,
        collectItem  = xi.item.LIZARD_EGG,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.ALABASTER_LIZARD_MEMENTO] =
    {
        name         = 'Alabaster Lizard',
        family       = 4,
        tier         = 2,
        cheer        = xi.ki.CHEER_ALABASTER_LIZARD,
        collectItem  = xi.item.VIAL_OF_LIZARD_BLOOD,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.BABY_COCKATRICE_MEMENTO] =
    {
        name         = 'Baby Cockatrice',
        family       = 5,
        tier         = 1,
        cheer        = xi.ki.CHEER_BABY_COCKATRICE,
        collectItem  = xi.item.SABIKI_RIG,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.FISH },
        resonating   = { xi.monsterRearing.foodType.FISH },
        evolutions   =
        {
            { form = xi.ki.COCKATRICE_MEMENTO, food = nil, natural = true },
            { form = xi.ki.ZIZ_MEMENTO, food = xi.item.QUUS_1, natural = false },
        },
    },
    [xi.ki.COCKATRICE_MEMENTO] =
    {
        name         = 'Cockatrice',
        family       = 5,
        tier         = 2,
        cheer        = xi.ki.CHEER_COCKATRICE,
        collectItem  = xi.item.SLICE_OF_COCKATRICE_MEAT,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.FISH },
        resonating   = { xi.monsterRearing.foodType.FISH },
        evolutions   = { },
    },
    [xi.ki.ZIZ_MEMENTO] =
    {
        name         = 'Ziz',
        family       = 5,
        tier         = 2,
        cheer        = xi.ki.CHEER_ZIZ,
        collectItem  = xi.item.SLICE_OF_ZIZ_MEAT,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.FISH },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.BABY_RAPTOR_MEMENTO] =
    {
        name         = 'Baby Raptor',
        family       = 6,
        tier         = 1,
        cheer        = xi.ki.CHEER_BABY_RAPTOR,
        collectItem  = xi.item.PIECE_OF_ROTTEN_MEAT,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   =
        {
            { form = xi.ki.RAPTOR_MEMENTO, food = nil, natural = true },
            { form = xi.ki.RED_RAPTOR_MEMENTO, food = xi.item.SLICE_OF_COCKATRICE_MEAT, natural = false },
        },
    },
    [xi.ki.RAPTOR_MEMENTO] =
    {
        name         = 'Raptor',
        family       = 6,
        tier         = 2,
        cheer        = xi.ki.CHEER_RAPTOR,
        collectItem  = xi.item.RAPTOR_SKIN,
        interactions = { xi.monsterRearing.interaction.ANGRY },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.RED_RAPTOR_MEMENTO] =
    {
        name         = 'Red Raptor',
        family       = 6,
        tier         = 2,
        cheer        = xi.ki.CHEER_RED_RAPTOR,
        collectItem  = xi.item.BONE_CHIP,
        interactions = { xi.monsterRearing.interaction.ANGRY },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.BABY_EFT_MEMENTO] =
    {
        name         = 'Baby Eft',
        family       = 7,
        tier         = 1,
        cheer        = xi.ki.CHEER_BABY_EFT,
        collectItem  = xi.item.SHELL_BUG,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.MEATS, xi.monsterRearing.foodType.FISH },
        resonating   = { },
        evolutions   =
        {
            { form = xi.ki.EFT_MEMENTO, food = nil, natural = true },
            { form = xi.ki.TARICHUK_MEMENTO, food = xi.item.LESSER_CHIGOE, natural = false },
        },
    },
    [xi.ki.EFT_MEMENTO] =
    {
        name         = 'Eft',
        family       = 7,
        tier         = 2,
        cheer        = xi.ki.CHEER_EFT,
        collectItem  = xi.item.EFT_SKIN,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.TARICHUK_MEMENTO] =
    {
        name         = 'Tarichuk',
        family       = 7,
        tier         = 2,
        cheer        = xi.ki.CHEER_TARICHUK,
        collectItem  = xi.item.HELMET_MOLE,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.DHALMEL_CALF_MEMENTO] =
    {
        name         = 'Dhalmel Calf',
        family       = 8,
        tier         = 1,
        cheer        = xi.ki.CHEER_DHALMEL_CALF,
        collectItem  = xi.item.CLUMP_OF_BATAGREENS,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   =
        {
            { form = xi.ki.DHALMEL_MEMENTO, food = xi.item.PAPAKA_GRASS, natural = true },
        },
    },
    [xi.ki.DHALMEL_MEMENTO] =
    {
        name         = 'Dhalmel',
        family       = 8,
        tier         = 2,
        cheer        = xi.ki.CHEER_DHALMEL,
        collectItem  = xi.item.GIANT_FEMUR,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   =
        {
            { form = xi.ki.GREAT_DHALMEL_MEMENTO, food = xi.item.CLUMP_OF_BATAGREENS, natural = false },
        },
    },
    [xi.ki.GREAT_DHALMEL_MEMENTO] =
    {
        name         = 'Great Dhalmel',
        family       = 8,
        tier         = 3,
        cheer        = xi.ki.CHEER_GREAT_DHALMEL,
        collectItem  = xi.item.DHALMEL_HIDE,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.SEA_MONK_LARVA_MEMENTO] =
    {
        name         = 'Sea Monk Larva',
        family       = 9,
        tier         = 1,
        cheer        = xi.ki.CHEER_SEA_MONK_LARVA,
        collectItem  = xi.item.CONTORTOPUS,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.FISH },
        resonating   = { xi.monsterRearing.foodType.FISH },
        evolutions   =
        {
            { form = xi.ki.SEA_MONK_MEMENTO, food = nil, natural = true },
            { form = xi.ki.BLUE_SEA_MONK_MEMENTO, food = xi.item.DENIZANASI, natural = false },
        },
    },
    [xi.ki.SEA_MONK_MEMENTO] =
    {
        name         = 'Sea Monk',
        family       = 9,
        tier         = 2,
        cheer        = xi.ki.CHEER_SEA_MONK,
        collectItem  = xi.item.MERCANBALIGI,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.FISH },
        resonating   = { xi.monsterRearing.foodType.FISH },
        evolutions   = { },
    },
    [xi.ki.BLUE_SEA_MONK_MEMENTO] =
    {
        name         = 'Blue Sea Monk',
        family       = 9,
        tier         = 2,
        cheer        = xi.ki.CHEER_BLUE_SEA_MONK,
        collectItem  = xi.item.ISTAVRIT_1,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.FISH },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.URAGNITE_YOUNGLING_MEMENTO] =
    {
        name         = 'Uragnite Youngling',
        family       = 10,
        tier         = 1,
        cheer        = xi.ki.CHEER_URAGNITE_YOUNGLING,
        collectItem  = xi.item.SEASHELL,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.URAGNITE_MEMENTO, food = nil, natural = true },
            { form = xi.ki.LIMASCABRA_MEMENTO, food = xi.item.THREE_EYED_FISH_1, natural = false },
        },
    },
    [xi.ki.URAGNITE_MEMENTO] =
    {
        name         = 'Uragnite',
        family       = 10,
        tier         = 2,
        cheer        = xi.ki.CHEER_URAGNITE,
        collectItem  = xi.item.URAGNITE_SHELL,
        interactions = { xi.monsterRearing.interaction.ANGRY },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.LIMASCABRA_MEMENTO] =
    {
        name         = 'Limascabra',
        family       = 10,
        tier         = 2,
        cheer        = xi.ki.CHEER_LIMASCABRA,
        collectItem  = xi.item.DENIZANASI,
        interactions = { xi.monsterRearing.interaction.ANGRY },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.IMMATURE_CRAB_MEMENTO] =
    {
        name         = 'Immature Crab',
        family       = 11,
        tier         = 1,
        cheer        = xi.ki.CHEER_IMMATURE_CRAB,
        collectItem  = xi.item.JUG_OF_FISH_BROTH,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   =
        {
            { form = xi.ki.CRAB_MEMENTO, food = nil, natural = true },
        },
    },
    [xi.ki.CRAB_MEMENTO] =
    {
        name         = 'Crab',
        family       = 11,
        tier         = 2,
        cheer        = xi.ki.CHEER_CRAB,
        collectItem  = xi.item.SLICE_OF_LAND_CRAB_MEAT,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   =
        {
            { form = xi.ki.PORTER_CRAB_MEMENTO, food = xi.item.CORAL_BUTTERFLY, natural = false },
        },
    },
    [xi.ki.PORTER_CRAB_MEMENTO] =
    {
        name         = 'Porter Crab',
        family       = 11,
        tier         = 3,
        cheer        = xi.ki.CHEER_PORTER_CRAB,
        collectItem  = xi.item.BARNACLE,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.BABY_COLIBRI_MEMENTO] =
    {
        name         = 'Baby Colibri',
        family       = 12,
        tier         = 1,
        cheer        = xi.ki.CHEER_BABY_COLIBRI,
        collectItem  = xi.item.BEEHIVE_CHIP,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { },
        evolutions   =
        {
            { form = xi.ki.COLIBRI_MEMENTO, food = nil, natural = true },
            { form = xi.ki.TOUCALIBRI_MEMENTO, food = xi.item.BOTTLE_OF_MULSUM, natural = false },
        },
    },
    [xi.ki.COLIBRI_MEMENTO] =
    {
        name         = 'Colibri',
        family       = 12,
        tier         = 2,
        cheer        = xi.ki.CHEER_COLIBRI,
        collectItem  = xi.item.POT_OF_HONEY,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.TOUCALIBRI_MEMENTO] =
    {
        name         = 'Toucalibri',
        family       = 12,
        tier         = 2,
        cheer        = xi.ki.CHEER_TOUCALIBRI,
        collectItem  = xi.item.JAR_OF_ENTISYRUP,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.COEURL_CUB_MEMENTO] =
    {
        name         = 'Coeurl Cub',
        family       = 13,
        tier         = 1,
        cheer        = xi.ki.CHEER_COEURL_CUB,
        collectItem  = xi.item.PIPIRA_1,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.COEURL_MEMENTO, food = nil, natural = true },
            { form = xi.ki.LYNX_MEMENTO, food = xi.item.THUNDERMELON, natural = false },
        },
    },
    [xi.ki.COEURL_MEMENTO] =
    {
        name         = 'Coeurl',
        family       = 13,
        tier         = 2,
        cheer        = xi.ki.CHEER_COEURL,
        collectItem  = xi.item.GOLD_LOBSTER_1,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.LYNX_MEMENTO] =
    {
        name         = 'Lynx',
        family       = 13,
        tier         = 2,
        cheer        = xi.ki.CHEER_LYNX,
        collectItem  = xi.item.LYNX_COLLARS,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.BUFFALO_CALF_MEMENTO] =
    {
        name         = 'Buffalo Calf',
        family       = 14,
        tier         = 1,
        cheer        = xi.ki.CHEER_BUFFALO_CALF,
        collectItem  = xi.item.EAR_OF_MILLIONCORN,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.GREENS, xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.GREENS, xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.BUFFALO_MEMENTO, food = nil, natural = true },
        },
    },
    [xi.ki.BUFFALO_MEMENTO] =
    {
        name         = 'Buffalo',
        family       = 14,
        tier         = 2,
        cheer        = xi.ki.CHEER_BUFFALO,
        collectItem  = xi.item.JUG_OF_ULEGUERAND_MILK,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.MINI_SLIME_MEMENTO] =
    {
        name         = 'Mini Slime',
        family       = 15,
        tier         = 1,
        cheer        = xi.ki.CHEER_MINI_SLIME,
        collectItem  = xi.item.FLASH_OF_VITRIOL,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.SLIME_MEMENTO, food = nil, natural = true },
            { form = xi.ki.CLOT_MEMENTO, food = xi.item.BIBIKI_SLUG, natural = false },
        },
    },
    [xi.ki.SLIME_MEMENTO] =
    {
        name         = 'Slime',
        family       = 15,
        tier         = 2,
        cheer        = xi.ki.CHEER_SLIME,
        collectItem  = xi.item.VIAL_OF_SLIME_OIL,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.HECTEYES_MEMENTO, food = xi.item.VIAL_OF_CHIMERA_BLOOD, natural = false },
        },
    },
    [xi.ki.HECTEYES_MEMENTO] =
    {
        name         = 'Hecteyes',
        family       = 15,
        tier         = 3,
        cheer        = xi.ki.CHEER_HECTEYES,
        collectItem  = xi.item.HECTEYES_EYE,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.CLOT_MEMENTO] =
    {
        name         = 'Clot',
        family       = 15,
        tier         = 2,
        cheer        = xi.ki.CHEER_CLOT,
        collectItem  = xi.item.VIAL_OF_BEASTMAN_BLOOD,
        interactions = { xi.monsterRearing.interaction.ANGRY },
        foodTypes    = { xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.MEATS },
        resonating   = { },
        evolutions   = { },
    },
    [xi.ki.MANDRAGORA_SPROUTLING_MEMENTO] =
    {
        name         = 'Mandragora Sproutling',
        family       = 16,
        tier         = 1,
        cheer        = xi.ki.CHEER_MANDRAGORA_SPROUTLING,
        collectItem  = xi.item.RARAB_TAIL,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.MANDRAGORA_MEMENTO, food = nil, natural = true },
            { form = xi.ki.ADENIUM_MEMENTO, food = xi.item.CLUMP_OF_ALKALINE_HUMUS, natural = false },
            { form = xi.ki.KORRIGAN_MEMENTO, food = xi.item.CLUMP_OF_ACIDIC_HUMUS, natural = false },
        },
    },
    [xi.ki.MANDRAGORA_MEMENTO] =
    {
        name         = 'Mandragora',
        family       = 16,
        tier         = 2,
        cheer        = xi.ki.CHEER_MANDRAGORA,
        collectItem  = xi.item.BALL_OF_SARUTA_COTTON,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.ELDER_MANDRAGORA_MEMENTO, food = nil, natural = true },
            { form = xi.ki.LYCOPODIUM_MEMENTO, food = xi.item.FLASK_OF_DISTILLED_WATER, natural = false },
        },
    },
    [xi.ki.ELDER_MANDRAGORA_MEMENTO] =
    {
        name         = 'Elder Mandragora',
        family       = 16,
        tier         = 3,
        cheer        = xi.ki.CHEER_ELDER_MANDRAGORA,
        collectItem  = xi.item.PINCH_OF_SULFUR,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.LYCOPODIUM_MEMENTO] =
    {
        name         = 'Lycopodium',
        family       = 16,
        tier         = 3,
        cheer        = xi.ki.CHEER_LYCOPODIUM,
        collectItem  = xi.item.LYCOPODIUM_FLOWER,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.AKE_OME_MEMENTO, food = xi.item.FLASK_OF_HOLY_WATER, natural = false },
        },
    },
    [xi.ki.AKE_OME_MEMENTO] =
    {
        name         = 'Ake-Ome',
        family       = 16,
        tier         = 4,
        cheer        = xi.ki.CHEER_AKE_OME,
        collectItem  = xi.item.SARUTA_ORANGE,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.ADENIUM_MEMENTO] =
    {
        name         = 'Adenium',
        family       = 16,
        tier         = 2,
        cheer        = xi.ki.CHEER_ADENIUM,
        collectItem  = xi.item.CLUMP_OF_RED_MOKO_GRASS,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.ELDER_ADENIUM_MEMENTO, food = nil, natural = true },
        },
    },
    [xi.ki.ELDER_ADENIUM_MEMENTO] =
    {
        name         = 'Elder Adenium',
        family       = 16,
        tier         = 3,
        cheer        = xi.ki.CHEER_ELDER_ADENIUM,
        collectItem  = xi.item.MOON_CARROT,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.KORRIGAN_MEMENTO] =
    {
        name         = 'Korrigan',
        family       = 16,
        tier         = 2,
        cheer        = xi.ki.CHEER_KORRIGAN,
        collectItem  = xi.item.VIAL_OF_BEAST_BLOOD,
        interactions = { xi.monsterRearing.interaction.ANGRY },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.PACHYPODIUM_MEMENTO, food = nil, natural = true },
        },
    },
    [xi.ki.PACHYPODIUM_MEMENTO] =
    {
        name         = 'Pachypodium',
        family       = 16,
        tier         = 3,
        cheer        = xi.ki.CHEER_PACHYPODIUM,
        collectItem  = xi.item.VIAL_OF_CHIMERA_BLOOD,
        interactions = { xi.monsterRearing.interaction.ANGRY },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS, xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.CITRULLUS_MEMENTO, food = xi.item.WATERMELON, natural = false },
        },
    },
    [xi.ki.CITRULLUS_MEMENTO] =
    {
        name         = 'Citrullus',
        family       = 16,
        tier         = 4,
        cheer        = xi.ki.CHEER_CITRULLUS,
        collectItem  = xi.item.WATERMELON,
        interactions = { xi.monsterRearing.interaction.SLAP },
        foodTypes    = { xi.monsterRearing.foodType.FRUITS },
        resonating   = { xi.monsterRearing.foodType.FRUITS },
        evolutions   = { },
    },
    [xi.ki.TINY_BUGARD_MEMENTO] =
    {
        name         = 'Tiny Bugard',
        family       = 17,
        tier         = 1,
        cheer        = xi.ki.CHEER_TINY_BUGARD,
        collectItem  = xi.item.CHICKEN_BONE,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.SEEDS, xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.SEEDS },
        evolutions   =
        {
            { form = xi.ki.BUGARD_MEMENTO, food = nil, natural = true },
            { form = xi.ki.ABYSSOBUGARD_MEMENTO, food = xi.item.VIAL_OF_BEASTMAN_BLOOD, natural = false },
        },
    },
    [xi.ki.BUGARD_MEMENTO] =
    {
        name         = 'Bugard',
        family       = 17,
        tier         = 2,
        cheer        = xi.ki.CHEER_BUGARD,
        collectItem  = xi.item.BUGARD_SKIN,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   = { },
    },
    [xi.ki.ABYSSOBUGARD_MEMENTO] =
    {
        name         = 'Abyssobugard',
        family       = 17,
        tier         = 2,
        cheer        = xi.ki.CHEER_ABYSSOBUGARD,
        collectItem  = xi.item.BUGARD_TUSK,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.BABY_ADAMANTOISE_MEMENTO] =
    {
        name         = 'Baby Adamantoise',
        family       = 18,
        tier         = 1,
        cheer        = xi.ki.CHEER_BABY_ADAMANTOISE,
        collectItem  = xi.item.TURTLE_SHELL,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS, xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   =
        {
            { form = xi.ki.ADAMANTOISE_MEMENTO, food = nil, natural = true },
            { form = xi.ki.FERROMANTOISE_MEMENTO, food = xi.item.DATE, natural = false },
        },
    },
    [xi.ki.ADAMANTOISE_MEMENTO] =
    {
        name         = 'Adamantoise',
        family       = 18,
        tier         = 2,
        cheer        = xi.ki.CHEER_ADAMANTOISE,
        collectItem  = xi.item.BRONZE_NUGGET,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   =
        {
            { form = xi.ki.GREAT_ADAMANTOISE_MEMENTO, food = xi.item.CLUMP_OF_BLUE_PONDWEED, natural = false },
            { form = xi.ki.WHITE_ADAMANTOISE_MEMENTO, food = xi.item.CLUMP_OF_RED_PONDWEED, natural = false },
        },
    },
    [xi.ki.GREAT_ADAMANTOISE_MEMENTO] =
    {
        name         = 'Great Adamantoise',
        family       = 18,
        tier         = 3,
        cheer        = xi.ki.CHEER_GREAT_ADAMANTOISE,
        collectItem  = xi.item.ADAMAN_NUGGET,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.GREENS },
        evolutions   = { },
    },
    [xi.ki.WHITE_ADAMANTOISE_MEMENTO] =
    {
        name         = 'White Adamantoise',
        family       = 18,
        tier         = 3,
        cheer        = xi.ki.CHEER_WHITE_ADAMANTOISE,
        collectItem  = xi.item.ADAMANTOISE_SHELL,
        interactions = { },
        foodTypes    = { xi.monsterRearing.foodType.CRYSTALS, xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.CRYSTALS },
        evolutions   = { },
    },
    [xi.ki.FERROMANTOISE_MEMENTO] =
    {
        name         = 'Ferromantoise',
        family       = 18,
        tier         = 2,
        cheer        = xi.ki.CHEER_FERROMANTOISE,
        collectItem  = xi.item.IRON_NUGGET,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.FRUITS },
        resonating   = { xi.monsterRearing.foodType.FRUITS },
        evolutions   =
        {
            { form = xi.ki.GREAT_FERROMANTOISE_MEMENTO, food = xi.item.BUNCH_OF_ROYAL_GRAPES, natural = false },
        },
    },
    [xi.ki.GREAT_FERROMANTOISE_MEMENTO] =
    {
        name         = 'Great Ferromantoise',
        family       = 18,
        tier         = 3,
        cheer        = xi.ki.CHEER_GREAT_FERROMANTOISE,
        collectItem  = xi.item.STEEL_NUGGET,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.FRUITS },
        resonating   = { xi.monsterRearing.foodType.FRUITS },
        evolutions   = { },
    },
    [xi.ki.CLUSTER_MEMENTO] =
    {
        name         = 'Cluster',
        family       = 19,
        tier         = 1,
        cheer        = xi.ki.CHEER_CLUSTER,
        collectItem  = xi.item.PINCH_OF_BOMB_ASH,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.CRYSTALS },
        resonating   = { xi.monsterRearing.foodType.CRYSTALS },
        evolutions   =
        {
            { form = xi.ki.BOMB_MEMENTO, food = xi.item.FIRE_CLUSTER, natural = true },
            { form = xi.ki.SNOLL_MEMENTO, food = xi.item.ICE_CLUSTER, natural = false },
        },
    },
    [xi.ki.BOMB_MEMENTO] =
    {
        name         = 'Bomb',
        family       = 19,
        tier         = 2,
        cheer        = xi.ki.CHEER_BOMB,
        collectItem  = xi.item.BOMB_ARM,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.CRYSTALS },
        resonating   = { xi.monsterRearing.foodType.CRYSTALS },
        evolutions   =
        {
            { form = xi.ki.DJINN_MEMENTO, food = xi.item.DARK_CLUSTER, natural = false },
        },
    },
    [xi.ki.DJINN_MEMENTO] =
    {
        name         = 'Djinn',
        family       = 19,
        tier         = 3,
        cheer        = xi.ki.CHEER_DJINN,
        collectItem  = xi.item.DJINN_ARM,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.CRYSTALS },
        resonating   = { xi.monsterRearing.foodType.CRYSTALS },
        evolutions   = { },
    },
    [xi.ki.SNOLL_MEMENTO] =
    {
        name         = 'Snoll',
        family       = 19,
        tier         = 2,
        cheer        = xi.ki.CHEER_SNOLL,
        collectItem  = xi.item.SNOLL_ARM,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.CRYSTALS },
        resonating   = { xi.monsterRearing.foodType.CRYSTALS },
        evolutions   = { },
    },
    [xi.ki.BEHEMOTH_CUB_MEMENTO] =
    {
        name         = 'Behemoth Cub',
        family       = 20,
        tier         = 1,
        cheer        = xi.ki.CHEER_BEHEMOTH_CUB,
        collectItem  = xi.item.SLICE_OF_BUFFALO_MEAT,
        interactions = { },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.BEHEMOTH_MEMENTO, food = xi.item.BEASTLY_SHANK, natural = true },
        },
    },
    [xi.ki.BEHEMOTH_MEMENTO] =
    {
        name         = 'Behemoth',
        family       = 20,
        tier         = 2,
        cheer        = xi.ki.CHEER_BEHEMOTH,
        collectItem  = xi.item.BEHEMOTH_HIDE,
        interactions = { },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.KING_BEHEMOTH_MEMENTO, food = xi.item.SAVORY_SHANK, natural = true },
        },
    },
    [xi.ki.KING_BEHEMOTH_MEMENTO] =
    {
        name         = 'King Behemoth',
        family       = 20,
        tier         = 3,
        cheer        = xi.ki.CHEER_KING_BEHEMOTH,
        collectItem  = xi.item.BEHEMOTH_HORN,
        interactions = { },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.ELASMOTH_MEMENTO, food = xi.item.SLICE_OF_DRAGON_MEAT, natural = false },
        },
    },
    [xi.ki.ELASMOTH_MEMENTO] =
    {
        name         = 'Elasmoth',
        family       = 20,
        tier         = 4,
        cheer        = xi.ki.CHEER_ELASMOTH,
        collectItem  = xi.item.FLASK_OF_HOLY_WATER,
        interactions = { },
        foodTypes    = { xi.monsterRearing.foodType.MEATS, xi.monsterRearing.foodType.FISH, xi.monsterRearing.foodType.CRYSTALS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.SKORMOTH_MEMENTO, food = xi.item.SLICE_OF_GABBRATH_MEAT, natural = false },
        },
    },
    [xi.ki.SKORMOTH_MEMENTO] =
    {
        name         = 'Skormoth',
        family       = 20,
        tier         = 5,
        cheer        = xi.ki.CHEER_SKORMOTH,
        collectItem  = xi.item.ICARUS_WING,
        interactions = { },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.PEQUETENDER_MEMENTO] =
    {
        name         = 'Pequetender',
        family       = 21,
        tier         = 1,
        cheer        = xi.ki.CHEER_PEQUETENDER,
        collectItem  = xi.item.PILE_OF_RED_GRAVEL,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.SABOTENDER_MEMENTO, food = xi.item.BURDOCK_ROOT, natural = true },
        },
    },
    [xi.ki.SABOTENDER_MEMENTO] =
    {
        name         = 'Sabotender',
        family       = 21,
        tier         = 2,
        cheer        = xi.ki.CHEER_SABOTENDER,
        collectItem  = xi.item.CACTUAR_ROOT,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.JUMBOTENDER_MEMENTO, food = xi.item.HANDFUL_OF_SUNFLOWER_SEEDS, natural = false },
        },
    },
    [xi.ki.JUMBOTENDER_MEMENTO] =
    {
        name         = 'Jumbotender',
        family       = 21,
        tier         = 3,
        cheer        = xi.ki.CHEER_JUMBOTENDER,
        collectItem  = xi.item.HERMES_QUENCHER,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.DRAGON_HATCHLING_MEMENTO] =
    {
        name         = 'Dragon Hatchling',
        family       = 22,
        tier         = 1,
        cheer        = xi.ki.CHEER_DRAGON_HATCHLING,
        collectItem  = xi.item.HANDFUL_OF_WYVERN_SCALES,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.FRUITS, xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.ABYSSAL_WYRM_MEMENTO, food = xi.item.JUG_OF_HONEY_WINE, natural = true },
            { form = xi.ki.WYVERN_MEMENTO, food = xi.item.BUNCH_OF_KAZHAM_PEPPERS, natural = false },
        },
    },
    [xi.ki.ABYSSAL_WYRM_MEMENTO] =
    {
        name         = 'Abyssal Wyrm',
        family       = 22,
        tier         = 2,
        cheer        = xi.ki.CHEER_ABYSSAL_WYRM,
        collectItem  = xi.item.DRAGON_TALON,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   =
        {
            { form = xi.ki.BLAZING_WYRM_MEMENTO, food = xi.item.SLICE_OF_CERBERUS_MEAT, natural = false },
            { form = xi.ki.LUNAR_WYRM_MEMENTO, food = xi.item.CUP_OF_SWEET_TEA, natural = false },
        },
    },
    [xi.ki.BLAZING_WYRM_MEMENTO] =
    {
        name         = 'Blazing Wyrm',
        family       = 22,
        tier         = 3,
        cheer        = xi.ki.CHEER_BLAZING_WYRM,
        collectItem  = xi.item.LOCK_OF_SIRENS_HAIR,
        interactions = { xi.monsterRearing.interaction.PET },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.LUNAR_WYRM_MEMENTO] =
    {
        name         = 'Lunar Wyrm',
        family       = 22,
        tier         = 3,
        cheer        = xi.ki.CHEER_LUNAR_WYRM,
        collectItem  = xi.item.CLUMP_OF_CASHMERE_WOOL,
        interactions = { xi.monsterRearing.interaction.YELL },
        foodTypes    = { xi.monsterRearing.foodType.LIQUIDS },
        resonating   = { xi.monsterRearing.foodType.LIQUIDS },
        evolutions   = { },
    },
    [xi.ki.WYVERN_MEMENTO] =
    {
        name         = 'Wyvern',
        family       = 22,
        tier         = 2,
        cheer        = xi.ki.CHEER_WYVERN,
        collectItem  = xi.item.WYVERN_SKIN,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   =
        {
            { form = xi.ki.BLUE_WYVERN_MEMENTO, food = xi.item.GEM_OF_THE_EAST, natural = false },
            { form = xi.ki.GREEN_WYVERN_MEMENTO, food = xi.item.TAVNAZIAN_LIVER, natural = false },
        },
    },
    [xi.ki.BLUE_WYVERN_MEMENTO] =
    {
        name         = 'Blue Wyvern',
        family       = 22,
        tier         = 3,
        cheer        = xi.ki.CHEER_BLUE_WYVERN,
        collectItem  = xi.item.VIAL_OF_DRAGON_BLOOD,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.MEATS },
        resonating   = { xi.monsterRearing.foodType.MEATS },
        evolutions   = { },
    },
    [xi.ki.GREEN_WYVERN_MEMENTO] =
    {
        name         = 'Green Wyvern',
        family       = 22,
        tier         = 3,
        cheer        = xi.ki.CHEER_GREEN_WYVERN,
        collectItem  = xi.item.WYVERN_TAILSKIN,
        interactions = { xi.monsterRearing.interaction.POKE },
        foodTypes    = { xi.monsterRearing.foodType.FRUITS, xi.monsterRearing.foodType.GREENS },
        resonating   = { xi.monsterRearing.foodType.FRUITS, xi.monsterRearing.foodType.GREENS },
        evolutions   = { },
    },
}

-- What each cheer grants while it is the active one.
--
-- Taken from the bg-wiki effect list for every memento. Craft skill gains map
-- to SYNTH_SKILL_GAIN, magic skill gains to MAGIC_SKILLUP_RATE and weapon or
-- defensive skill gains to COMBAT_SKILLUP_RATE, because the server tracks skill
-- gain rate by category and not per skill.
--
-- The 100 "Alter Ego" lines in that list are not here. They raise the stats of
-- summoned trusts and the server has no mod for that, so a cheer that grants
-- only alter ego bonuses grants nothing yet. Adding trust-side mods would close
-- it without touching this table.
xi.monsterRearing.cheerMods =
{
    [xi.ki.CHEER_LAMB] = { { xi.mod.EXP_BONUS, 2 } },
    [xi.ki.CHEER_SHEEP] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_RAM] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_KARAKUL] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_BABY_RABBIT] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_RABBIT] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_WHITE_RABBIT] = { { xi.mod.CAPACITY_BONUS, 1 } },
    [xi.ki.CHEER_SAPLING] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_G_FOL_TREANT] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_R_FOL_TREANT] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 }, { xi.mod.MAGIC_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_BABY_LIZARD] = { { xi.mod.MAGIC_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_LIZARD] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_ALABASTER_LIZARD] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_BABY_COCKATRICE] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_COCKATRICE] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_ZIZ] = { { xi.mod.SYNTH_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_BABY_RAPTOR] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_RAPTOR] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_RED_RAPTOR] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_BABY_EFT] = { { xi.mod.FISHING_SKILL_GAIN, 1 } },
    [xi.ki.CHEER_EFT] = { { xi.mod.MAGIC_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_TARICHUK] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 }, { xi.mod.MAGIC_SKILLUP_RATE, 10 } },
    [xi.ki.CHEER_DHALMEL_CALF] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 }, { xi.mod.MND, 2 } },
    [xi.ki.CHEER_DHALMEL] = { { xi.mod.MND, 3 } },
    [xi.ki.CHEER_GREAT_DHALMEL] = { { xi.mod.MND, 4 } },
    [xi.ki.CHEER_SEA_MONK_LARVA] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 }, { xi.mod.DEX, 2 } },
    [xi.ki.CHEER_SEA_MONK] = { { xi.mod.DEX, 3 } },
    [xi.ki.CHEER_BLUE_SEA_MONK] = { { xi.mod.DEX, 3 } },
    [xi.ki.CHEER_URAGNITE_YOUNGLING] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 }, { xi.mod.MAGIC_SKILLUP_RATE, 10 }, { xi.mod.VIT, 2 } },
    [xi.ki.CHEER_URAGNITE] = { { xi.mod.CAPACITY_BONUS, 3 }, { xi.mod.EXP_BONUS, 5 } },
    [xi.ki.CHEER_LIMASCABRA] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.EXP_BONUS, 3 } },
    [xi.ki.CHEER_IMMATURE_CRAB] = { { xi.mod.SYNTH_SKILL_GAIN, 1 }, { xi.mod.VIT, 2 } },
    [xi.ki.CHEER_CRAB] = { { xi.mod.VIT, 3 } },
    [xi.ki.CHEER_PORTER_CRAB] = { { xi.mod.VIT, 4 } },
    [xi.ki.CHEER_BABY_COLIBRI] = { { xi.mod.COMBAT_SKILLUP_RATE, 10 }, { xi.mod.INT, 2 } },
    [xi.ki.CHEER_COLIBRI] = { { xi.mod.INT, 3 } },
    [xi.ki.CHEER_TOUCALIBRI] = { { xi.mod.INT, 3 } },
    [xi.ki.CHEER_COEURL_CUB] = { { xi.mod.AGI, 2 } },
    [xi.ki.CHEER_COEURL] = { { xi.mod.AGI, 3 }, { xi.mod.EXP_BONUS, 3 } },
    [xi.ki.CHEER_LYNX] = { { xi.mod.AGI, 3 }, { xi.mod.CAPACITY_BONUS, 3 } },
    [xi.ki.CHEER_BUFFALO_CALF] = { { xi.mod.VIT, 2 } },
    [xi.ki.CHEER_BUFFALO] = { { xi.mod.CAPACITY_BONUS, 3 }, { xi.mod.VIT, 3 } },
    [xi.ki.CHEER_MINI_SLIME] = { { xi.mod.STR, 2 } },
    [xi.ki.CHEER_SLIME] = { { xi.mod.CAPACITY_BONUS, 3 }, { xi.mod.STR, 3 } },
    [xi.ki.CHEER_HECTEYES] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.INT, 4 } },
    [xi.ki.CHEER_CLOT] = { { xi.mod.CAPACITY_BONUS, 3 }, { xi.mod.STR, 3 } },
    [xi.ki.CHEER_MANDRAGORA_SPROUTLING] = { { xi.mod.VIT, 2 } },
    [xi.ki.CHEER_MANDRAGORA] = { { xi.mod.VIT, 3 } },
    [xi.ki.CHEER_ELDER_MANDRAGORA] = { { xi.mod.VIT, 4 } },
    [xi.ki.CHEER_LYCOPODIUM] = { { xi.mod.CHR, 3 } },
    [xi.ki.CHEER_AKE_OME] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.CHR, 4 } },
    [xi.ki.CHEER_ADENIUM] = { { xi.mod.SLEEPRES, 10 } },
    [xi.ki.CHEER_ELDER_ADENIUM] = { { xi.mod.SLEEPRES, 10 } },
    [xi.ki.CHEER_KORRIGAN] = { { xi.mod.POISONRES, 10 } },
    [xi.ki.CHEER_PACHYPODIUM] = { { xi.mod.POISONRES, 10 } },
    [xi.ki.CHEER_CITRULLUS] = { { xi.mod.BLINDRES, 10 } },
    [xi.ki.CHEER_TINY_BUGARD] = { { xi.mod.EXP_BONUS, 4 } },
    [xi.ki.CHEER_BUGARD] = { { xi.mod.CAPACITY_BONUS, 4 }, { xi.mod.STR, 5 } },
    [xi.ki.CHEER_ABYSSOBUGARD] = { { xi.mod.ATTP, 2 }, { xi.mod.CAPACITY_BONUS, 4 }, { xi.mod.RATTP, 2 } },
    [xi.ki.CHEER_BABY_ADAMANTOISE] = { { xi.mod.EXP_BONUS, 3 }, { xi.mod.VIT, 4 } },
    [xi.ki.CHEER_ADAMANTOISE] = { { xi.mod.CAPACITY_BONUS, 4 }, { xi.mod.VIT, 6 } },
    [xi.ki.CHEER_GREAT_ADAMANTOISE] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.VIT, 8 } },
    [xi.ki.CHEER_WHITE_ADAMANTOISE] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.REGEN, 1 } },
    [xi.ki.CHEER_FERROMANTOISE] = { { xi.mod.CAPACITY_BONUS, 4 }, { xi.mod.MDEF, 1 } },
    [xi.ki.CHEER_GREAT_FERROMANTOISE] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.MDEF, 2 } },
    [xi.ki.CHEER_CLUSTER] = { { xi.mod.EXP_BONUS, 5 }, { xi.mod.MACC, 2 }, { xi.mod.MAGIC_SKILLUP_RATE, 5 } },
    [xi.ki.CHEER_BOMB] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.CHR, 2 }, { xi.mod.INT, 2 }, { xi.mod.MATT, 2 }, { xi.mod.MND, 2 } },
    [xi.ki.CHEER_DJINN] = { { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.CHR, 2 }, { xi.mod.INT, 2 }, { xi.mod.MACC, 2 }, { xi.mod.MND, 2 } },
    [xi.ki.CHEER_SNOLL] = { { xi.mod.CAPACITY_BONUS, 6 }, { xi.mod.MPP, 16 }, { xi.mod.SILENCERES, 10 } },
    [xi.ki.CHEER_BEHEMOTH_CUB] = { { xi.mod.ACC, 3 }, { xi.mod.COMBAT_SKILLUP_RATE, 5 }, { xi.mod.EXP_BONUS, 5 }, { xi.mod.RACC, 3 } },
    [xi.ki.CHEER_BEHEMOTH] = { { xi.mod.ATTP, 2 }, { xi.mod.CAPACITY_BONUS, 5 }, { xi.mod.RATTP, 2 } },
    [xi.ki.CHEER_KING_BEHEMOTH] = { { xi.mod.ATTP, 2 }, { xi.mod.CAPACITY_BONUS, 7 }, { xi.mod.RATTP, 2 } },
    [xi.ki.CHEER_ELASMOTH] = { { xi.mod.CAPACITY_BONUS, 8 }, { xi.mod.CURSERES, 10 } },
    [xi.ki.CHEER_SKORMOTH] = { { xi.mod.AMNESIARES, 10 }, { xi.mod.CAPACITY_BONUS, 9 } },
    [xi.ki.CHEER_PEQUETENDER] = { { xi.mod.AGI, 3 }, { xi.mod.EXP_BONUS, 6 }, { xi.mod.VIT, 3 } },
    [xi.ki.CHEER_SABOTENDER] = { { xi.mod.AGI, 4 }, { xi.mod.EXP_BONUS, 6 }, { xi.mod.VIT, 4 } },
    [xi.ki.CHEER_JUMBOTENDER] = { { xi.mod.CAPACITY_BONUS, 7 }, { xi.mod.MOVE_SPEED_CHEER, 2 } },
    [xi.ki.CHEER_DRAGON_HATCHLING] = { { xi.mod.AGI, 2 }, { xi.mod.CHR, 2 }, { xi.mod.DEX, 2 }, { xi.mod.INT, 2 }, { xi.mod.MAGIC_SKILLUP_RATE, 10 }, { xi.mod.MND, 2 }, { xi.mod.STR, 2 }, { xi.mod.VIT, 2 } },
    [xi.ki.CHEER_ABYSSAL_WYRM] = { { xi.mod.CAPACITY_BONUS, 6 }, { xi.mod.DEMON_KILLER, 10 } },
    [xi.ki.CHEER_BLAZING_WYRM] = { { xi.mod.CAPACITY_BONUS, 8 }, { xi.mod.COUNTER, 2 } },
    [xi.ki.CHEER_LUNAR_WYRM] = { { xi.mod.CAPACITY_BONUS, 8 }, { xi.mod.MDEF, 3 } },
    [xi.ki.CHEER_WYVERN] = { { xi.mod.CAPACITY_BONUS, 6 }, { xi.mod.DEX, 3 }, { xi.mod.STR, 3 }, { xi.mod.ZANSHIN, 2 } },
    [xi.ki.CHEER_BLUE_WYVERN] = { { xi.mod.ACC, 4 }, { xi.mod.CAPACITY_BONUS, 6 }, { xi.mod.DEX, 4 }, { xi.mod.RACC, 4 }, { xi.mod.STR, 4 } },
    [xi.ki.CHEER_GREEN_WYVERN] = { { xi.mod.CAPACITY_BONUS, 6 }, { xi.mod.DEX, 4 }, { xi.mod.HASTE_GEAR, 100 }, { xi.mod.STR, 4 } },
}

return xi.monsterRearing
