#define SD_PREFIX "\x04[GP Special Days]\x07F8F8FF"
#define SD_DELAY 20

Handle g_FriendlyFire;

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

stock void StripAllWeapons(int client)
{

    int weaponId;

    for (int i = 0; i < 6; i++)
    {
        if ((weaponId = GetPlayerWeaponSlot(client, i)) != -1)
        {
            RemovePlayerItem(client, weaponId);
            AcceptEntityInput(weaponId, "Kill");
        }
    }

    weaponId = GetPlayerWeaponSlot(client, 3);
    while (weaponId != -1)
    {
        RemovePlayerItem(client, weaponId);
        AcceptEntityInput(weaponId, "Kill");
        weaponId = GetPlayerWeaponSlot(client, 3);
    }

    for (int i = 0; i < 4; i++)
    {
        SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, 11 + i);
    }
}

stock void SetReserveAmmo(int client, int weapon, int ammo)
{
    if (weapon != -1)
    {
        int ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");
        int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
        SetEntData(client, ammoOffset + (ammoType * 4), ammo, _, true);
    }
}