#define SD_PREFIX "\x04[GP Special Days]\x07F8F8FF"
#define SD_DELAY 20.0

Handle g_FriendlyFire;

// If you enable friendly fire, change this to true. Make sure to set this to
// false at the end of the round in your cleanup function.

bool g_FriendlyFireEnabled;

enum SpecialDay 
{
    deathMatch,
    dodgeball,
    friendlyFire,
    grenade,
    gunGame,
    headshot,
    hideAndSeek,
    juggernaut,
    knife,
    laserWars,
    scoutknives,
    skyWars,
    spectre,
    tank,
    zombie,
    normal
};

const int SD_LIST_SIZE = 15;

char SD_LIST[][] = 
{
    "Death Match",
    "Dodgeball",
    "Friendly Fire",
    "Grenade",
    "Gun Game",
    "Headshot",
    "Hide and Seek",
    "Juggernaut",
    "Knife",
    "Laser Wars",
    "Scoutknives",
    "Sky Wars",
    "Spectre",
    "Tank",
    "Zombie",
};

enum SpecialDayState 
{
    started,
    active,
    inactive
};