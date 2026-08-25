-----------------------------------
-- Mog Garden yield tables
--
-- Retail per-rank drop lists for the five geological locations, transcribed from
-- bg-wiki and FFXIclopedia. Where the two differ the union is used. Neither claims
-- to be exhaustive and every entry in either is a confirmed retail drop.
--
-- Vein and grove tables are per-rank ADDITIONS. Gathering at rank N draws from the
-- union of the lists for ranks 1 through N, which is what both wikis describe:
-- "if you gather from Mineral Vein #2, you will only get Mineral Vein #1 and #2
-- items, never Mineral Vein #3 nor #4 items."
--
-- Vein and grove each split into two node lists. Every rank tier has two entities
-- in npc_list.sql at different heights, and bg-wiki pins which is which: "The node
-- for precious metal ores is always the higher node." The grove splits the same way,
-- the tree for pruning and the ground for weeding.
--
-- Pond and coast are one raise per Earth day yielding eight items. From rank 6 the
-- normal pool stops growing and catch slots 4 and 8 draw from a separate list, so
-- the two pools are stored apart.
-----------------------------------
xi = xi or {}
xi.mog_garden = xi.mog_garden or {}
xi.mog_garden.yields = xi.mog_garden.yields or {}

-- Mineral vein. metals and precious are the two node lists, either is shared.
xi.mog_garden.yields.vein =
{
    [1] =
    {
        metals =
        {
            xi.item.CHUNK_OF_COPPER_ORE,
            xi.item.CHUNK_OF_DARKSTEEL_ORE,
            xi.item.IGNEOUS_ROCK,
            xi.item.CHUNK_OF_IRON_ORE,
            xi.item.CHUNK_OF_KOPPARNICKEL_ORE,
            xi.item.CHUNK_OF_TIN_ORE,
        },
        precious =
        {
            xi.item.HANDFUL_OF_AURIC_SAND,
            xi.item.CHUNK_OF_SILVER_ORE,
            xi.item.CHUNK_OF_ZINC_ORE,
        },
        either =
        {
            xi.item.BAT_FANG,
            xi.item.BEETLE_JAW,
            xi.item.BONE_CHIP,
            xi.item.SET_OF_FISH_BONES,
            xi.item.FLINT_STONE,
            xi.item.PEBBLE,
            xi.item.HANDFUL_OF_PUGIL_SCALES,
            xi.item.SCORPION_CLAW,
            xi.item.SHEEP_TOOTH,
            xi.item.SNAPPING_MOLE,
        },
    },

    [2] =
    {
        metals = {},
        precious =
        {
            xi.item.CHUNK_OF_MYTHRIL_ORE,
            xi.item.CHUNK_OF_PLATINUM_ORE,
        },
        either =
        {
            xi.item.CRAB_SHELL,
        },
    },

    [3] =
    {
        metals =
        {
            xi.item.CHUNK_OF_ADAMAN_ORE,
            xi.item.CHUNK_OF_KHROMA_ORE,
        },
        precious =
        {
            xi.item.CHUNK_OF_AHT_URHGAN_BRASS,
            xi.item.CHUNK_OF_GOLD_ORE,
        },
        either =
        {
            xi.item.DRAGON_BONE,
            xi.item.METEORITE,
            xi.item.SCORPION_SHELL,
        },
    },

    [4] =
    {
        metals = {},
        precious =
        {
            xi.item.CHUNK_OF_ORICHALCUM_ORE,
        },
        either =
        {
            xi.item.ANTLION_JAW,
            xi.item.DRAGON_TALON,
            xi.item.HIGH_QUALITY_CRAB_SHELL,
            xi.item.HIGH_QUALITY_SCORPION_SHELL,
            xi.item.RAM_HORN,
        },
    },

    [5] =
    {
        metals =
        {
            xi.item.DARKSTEEL_NUGGET,
        },
        precious =
        {
            xi.item.CHUNK_OF_FOOLS_GOLD_ORE,
            xi.item.CHUNK_OF_PHRYGIAN_ORE,
        },
        either =
        {
            xi.item.BUGARD_TUSK,
            xi.item.TURTLE_SHELL,
        },
    },

    [6] =
    {
        metals =
        {
            xi.item.CHUNK_OF_SWAMP_ORE,
            xi.item.CHUNK_OF_VANADIUM_ORE,
            xi.item.CHUNK_OF_WOOTZ_ORE,
        },
        precious = {},
        either =
        {
            xi.item.BLACK_TIGER_FANG,
            xi.item.VELKK_MASK,
            xi.item.VELKK_NECKLACE,
            xi.item.VOAY_STAFF_M1,
            xi.item.VOAY_SWORD_M1,
            xi.item.WIVRE_MAUL,
        },
    },

    [7] =
    {
        metals =
        {
            xi.item.CHUNK_OF_BISMUTH_ORE,
            xi.item.CHUNK_OF_DURIUM_ORE,
            xi.item.CHUNK_OF_TITANIUM_ORE,
        },
        precious =
        {
            xi.item.CHUNK_OF_RHODIUM_ORE,
        },
        either =
        {
            xi.item.CARRIER_CRAB_CARAPACE,
            xi.item.CHICKEN_BONE,
            xi.item.HIGH_QUALITY_ANTLION_JAW,
            xi.item.MATAMATA_SHELL,
            xi.item.PHILOSOPHERS_STONE,
            xi.item.RAAZ_TUSK,
            xi.item.URAGNITE_SHELL,
        },
    },
}

-- Arboreal grove. prune is the tree node, weeds is the ground node.
xi.mog_garden.yields.grove =
{
    [1] =
    {
        prune =
        {
            xi.item.ACORN,
            xi.item.ARROWWOOD_LOG,
            xi.item.ASH_LOG,
            xi.item.RONFAURE_CHESTNUT,
            xi.item.DOGWOOD_LOG,
            xi.item.DRYAD_ROOT,
            xi.item.ELM_LOG,
            xi.item.FAERIE_APPLE,
            xi.item.LACQUER_TREE_LOG,
            xi.item.MAHOGANY_LOG,
            xi.item.MAPLE_LOG,
        },
        weeds =
        {
            xi.item.PIECE_OF_CRAWLER_COCOON,
            xi.item.BAG_OF_FRUIT_SEEDS,
            xi.item.BAG_OF_GRAIN_SEEDS,
            xi.item.BAG_OF_HERB_SEEDS,
            xi.item.CLUMP_OF_MOKO_GRASS,
            xi.item.MUSHROOM_LOCUST,
            xi.item.CLUMP_OF_RED_MOKO_GRASS,
            xi.item.BALL_OF_SARUTA_COTTON,
            xi.item.SKULL_LOCUST,
            xi.item.SPIDER_WEB,
            xi.item.BAG_OF_VEGETABLE_SEEDS,
            xi.item.CLUMP_OF_WINDURSTIAN_TEA_LEAVES,
            xi.item.WOOZYSHROOM,
        },
    },

    [2] =
    {
        prune =
        {
            xi.item.HANDFUL_OF_PINE_NUTS,
            xi.item.BAG_OF_TREE_CUTTINGS,
            xi.item.WALNUT_LOG,
        },
        weeds =
        {
            xi.item.EGGPLANT,
            xi.item.FLAX_FLOWER,
            xi.item.SPRIG_OF_FRESH_MARJORAM,
            xi.item.SPRIG_OF_FRESH_MUGWORT,
            xi.item.INSECT_WING,
            xi.item.LOCUST_ELUTRIATOR,
        },
    },

    [3] =
    {
        prune =
        {
            xi.item.EBONY_LOG,
            xi.item.WALNUT,
        },
        weeds =
        {
            xi.item.FELICIFRUIT,
            xi.item.KING_LOCUST,
        },
    },

    [4] =
    {
        prune =
        {
            xi.item.ELSHIMO_PACHIRA_FRUIT,
            xi.item.BAG_OF_GROVE_CUTTINGS,
            xi.item.BUNCH_OF_PAMAMAS,
            xi.item.URUNDAY_LOG,
        },
        weeds =
        {
            xi.item.LESSER_CHIGOE,
            xi.item.RED_ROSE,
            xi.item.ROLANBERRY,
            xi.item.YAGUDO_CHERRY,
        },
    },

    [5] =
    {
        prune =
        {
            xi.item.PERSIKOS,
        },
        weeds =
        {
            xi.item.BURDOCK_ROOT,
            xi.item.LITTLE_WORM,
            xi.item.HEAD_OF_NAPA,
            xi.item.WATERMELON,
            xi.item.MARGUERITE,
            xi.item.WIJNRUIT,
        },
    },

    [6] =
    {
        prune =
        {
            xi.item.BAG_OF_CACTUS_STEMS,
            xi.item.GUATAMBU_LOG,
            xi.item.ULBUCONUT,
        },
        weeds =
        {
            xi.item.CLUMP_OF_AKASO,
            xi.item.HEAD_OF_ISLERACEA,
            xi.item.BOX_OF_TARUTARU_RICE,
            xi.item.WATER_LILY,
        },
    },

    [7] =
    {
        prune =
        {
            xi.item.CHESTNUT_LOG,
            xi.item.DIVINE_LOG,
            xi.item.DRAGON_FRUIT,
            xi.item.LAUAN_LOG,
            xi.item.OAK_LOG,
            xi.item.LANCEWOOD_LOG,
        },
        weeds =
        {
            xi.item.CHAPULI_WING,
            xi.item.TWITHERYM_WING,
            xi.item.PAIR_OF_NOPALES,
            xi.item.REISHI_MUSHROOM,
            xi.item.PURPLE_POLYPORE,
        },
    },
}

-- Pond dredger.
xi.mog_garden.yields.pond =
{
    normal =
    {
        [1] =
        {
            xi.item.COPPER_FROG_1,
            xi.item.CRAYFISH_1,
            xi.item.ELSHIMO_NEWT,
            xi.item.GIANT_CATFISH_1,
            xi.item.MOAT_CARP_1,
            xi.item.RED_TERRAPIN,
            xi.item.RUSTY_BUCKET,
            xi.item.ULBUKAN_LOBSTER,
        },
        [2] =
        {
            xi.item.BLACK_EEL_1,
        },
        [3] =
        {
            xi.item.DARK_BASS_1,
            xi.item.PIPIRA_1,
        },
        [4] =
        {
            xi.item.CA_CUONG,
            xi.item.CRESCENT_FISH,
            xi.item.YAYINBALIGI,
        },
        [5] =
        {
            xi.item.BLACK_GHOST,
            xi.item.BRASS_LOACH,
            xi.item.GAVIAL_FISH,
            xi.item.GOLD_CARP,
        },
    },

    special =
    {
        [6] =
        {
            xi.item.BLACK_GHOST,
            xi.item.BRASS_LOACH,
            xi.item.DWARF_PUGIL,
            xi.item.DWARF_REMORA,
            xi.item.EMPEROR_FISH,
            xi.item.GAVIAL_FISH,
            xi.item.GOLD_CARP,
            xi.item.RUDDY_SEEMA,
        },
        [7] =
        {
            xi.item.ABAIA,
            xi.item.CALICO_COMET,
            xi.item.PINCH_OF_HIGH_PURITY_BAYLD,
            xi.item.LIK,
            xi.item.TINY_GOLDFISH,
            xi.item.YORCHETE,
        },
    },
}

-- Coastal fishing net.
xi.mog_garden.yields.coast =
{
    normal =
    {
        [1] =
        {
            xi.item.CLUMP_OF_ADOULINIAN_KELP,
            xi.item.BARNACLE,
            xi.item.CONTORTOPUS,
            xi.item.MACKEREL,
            xi.item.QUUS_1,
            xi.item.RUSTY_BUCKET,
            xi.item.SENROH_SARDINE,
            xi.item.SHALL_SHELL,
        },
        [2] =
        {
            xi.item.BLUETAIL_1,
            xi.item.COBALT_JELLYFISH,
            xi.item.ZEBRA_EEL,
        },
        [3] =
        {
            xi.item.BLACK_PRAWN,
            xi.item.CONE_CALAMARY,
            xi.item.GUGRU_TUNA_1,
            xi.item.MOLA_MOLA,
        },
        [4] =
        {
            xi.item.BASTORE_BREAM,
            xi.item.BHEFHEL_MARLIN_1,
            xi.item.MOORISH_IDOL,
        },
        [5] =
        {
            xi.item.BLACK_SOLE,
            xi.item.GIGANT_SQUID,
            xi.item.GRIMMONITE,
            xi.item.THREE_EYED_FISH_2,
        },
    },

    special =
    {
        [6] =
        {
            xi.item.BLACK_SOLE,
            xi.item.BLOODBLOTCH,
            xi.item.DRAGONFISH,
            xi.item.GIGANT_SQUID,
            xi.item.GRIMMONITE,
            xi.item.SEA_ZOMBIE,
            xi.item.THREE_EYED_FISH_2,
        },
        [7] =
        {
            xi.item.DRILL_CALAMARY,
            xi.item.PIECE_OF_MALIYAKALEYA_CORAL,
            xi.item.MEGALODON,
            xi.item.TITANICTUS,
            xi.item.VEYDAL_WRASSE_1,
        },
    },
}

-- Garden furrow plantables. Grow time in Earth hours, how many harvests one
-- planting supports, and the min and max items per harvest, all from bg-wiki's
-- plantable table. Limited to the seeds obtainable inside the garden, which is the
-- Green Thumb Moogle's stock plus the flower seeds the opening chain hands out.
xi.mog_garden.yields.furrow =
{
    [xi.item.BAG_OF_CACTUS_STEMS] =
    {
        hours    = 40,
        harvests = 1,
        yieldMin = 4,
        yieldMax = 5,
        pool     =
        {
            xi.item.BUTTERPEAR,
            xi.item.CHUNK_OF_DARKSTEEL_ORE,
            xi.item.DATE,
            xi.item.DRAGON_FRUIT,
            xi.item.CHUNK_OF_GOLD_ORE,
            xi.item.CHUNK_OF_IRON_ORE,
            xi.item.KITRON,
            xi.item.PERSIKOS,
            xi.item.RONFAURE_CHESTNUT,
            xi.item.CHUNK_OF_SILVER_ORE,
            xi.item.CHUNK_OF_RHODIUM_ORE,
            xi.item.CHUNK_OF_VANADIUM_ORE,
        },
    },

    [xi.item.BAG_OF_FLOWER_SEEDS] =
    {
        hours    = 20,
        harvests = 1,
        yieldMin = 4,
        yieldMax = 4,
        pool     =
        {
            xi.item.AMARYLLIS,
            xi.item.AMERETAT_VINE,
            xi.item.ASPHODEL,
            xi.item.CARNATION,
            xi.item.CASABLANCA,
            xi.item.SPRIG_OF_DYERS_WOAD,
            xi.item.MARGUERITE,
            xi.item.RAFFLESIA_VINE,
            xi.item.SNOW_LILY,
            xi.item.WATER_LILY,
        },
    },

    [xi.item.BAG_OF_FRUIT_SEEDS] =
    {
        hours    = 20,
        harvests = 1,
        yieldMin = 4,
        yieldMax = 4,
        pool     =
        {
            xi.item.DERFLAND_PEAR,
            xi.item.FAERIE_APPLE,
            xi.item.SAN_DORIAN_CARROT,
            xi.item.YAGUDO_CHERRY,
            xi.item.WALNUT,
            xi.item.BUNCH_OF_BUBURIMU_GRAPES,
            xi.item.WATERMELON,
        },
    },

    [xi.item.BAG_OF_GRAIN_SEEDS] =
    {
        hours    = 6,
        harvests = 4,
        yieldMin = 4,
        yieldMax = 4,
        pool     =
        {
            xi.item.KUKURU_BEAN,
            xi.item.MARGUERITE,
            xi.item.HANDFUL_OF_SUNFLOWER_SEEDS,
            xi.item.BOX_OF_TARUTARU_RICE,
            xi.item.BAG_OF_RYE_FLOUR,
            xi.item.EAR_OF_MILLIONCORN,
            xi.item.BAG_OF_POISON_FLOUR,
            xi.item.POD_OF_BLUE_PEAS,
            xi.item.PUFFBALL,
            xi.item.CHUNK_OF_RHODIUM_ORE,
            xi.item.BAG_OF_SAN_DORIAN_FLOUR,
            xi.item.BAG_OF_SEMOLINA,
            xi.item.CORAL_FUNGUS,
        },
    },

    [xi.item.BAG_OF_HERB_SEEDS] =
    {
        hours    = 8,
        harvests = 3,
        yieldMin = 4,
        yieldMax = 6,
        pool     =
        {
            xi.item.HANDFUL_OF_BAY_LEAVES,
            xi.item.PINCH_OF_BLACK_PEPPER,
            xi.item.DEATHBALL,
            xi.item.BRANCH_OF_GNATBANE,
            xi.item.BUNCH_OF_HABANERO_PEPPERS,
            xi.item.SPRIG_OF_HOLY_BASIL,
            xi.item.BUNCH_OF_KAZHAM_PEPPERS,
            xi.item.KING_TRUFFLE,
            xi.item.BULB_OF_MHAURA_GARLIC,
            xi.item.SAFFRON_BLOSSOM,
            xi.item.SPRIG_OF_SAGE,
            xi.item.STICK_OF_VANILLA,
        },
    },

    [xi.item.BAG_OF_VEGETABLE_SEEDS] =
    {
        hours    = 12,
        harvests = 2,
        yieldMin = 3,
        yieldMax = 4,
        pool     =
        {
            xi.item.GINGER_ROOT,
            xi.item.WILD_ONION,
            xi.item.FROST_TURNIP,
            xi.item.BURDOCK_ROOT,
            xi.item.BALL_OF_SARUTA_COTTON,
            xi.item.POPOTO,
            xi.item.LILAC,
            xi.item.WINTERFLOWER,
            xi.item.HEAD_OF_GRAUBERG_LETTUCE,
            xi.item.HEAD_OF_NAPA,
            xi.item.HEAD_OF_ISLERACEA,
        },
    },

    [xi.item.BAG_OF_WILDGRASS_SEEDS] =
    {
        hours    = 20,
        harvests = 1,
        yieldMin = 4,
        yieldMax = 4,
        pool     =
        {
            xi.item.BUNCH_OF_AZOUPH_GREENS,
            xi.item.CUPID_WORM,
            xi.item.GREGARIOUS_WORM,
            xi.item.BUNCH_OF_GYSAHL_GREENS,
            xi.item.PARASITE_WORM,
            xi.item.BUNCH_OF_SHARUG_GREENS,
            xi.item.VOMP_CARROT,
            xi.item.ZEGHAM_CARROT,
            xi.item.PILE_OF_CHOCOBO_BEDDING,
        },
    },
}
