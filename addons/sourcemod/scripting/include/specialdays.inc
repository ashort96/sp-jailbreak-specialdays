// sp-jailbreak-specialdays
// Copyright (C) 2021  Adam Short

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#if defined _jailbreak_specialdays_included
    #endinput
#endif
#define _jailbreak_specialdays_included

// #define DEBUG

#define SD_PREFIX "\x04[GP Special Days]\x07F8F8FF"
#define SD_DELAY 19

Handle g_FriendlyFire;

int g_WeaponParent;

int g_Teams[MAXPLAYERS + 1];

enum SpecialDay 
{
    deathMatch,
    dodgeball,
    friendlyFire,
    grenade,
    gunGame,
    headshot,
    juggernaut,
    knife,
    oneInChamber,
    scoutknives,
    // skyWars,
    // spectre,
    tank,
    zombie,
    normal
};

enum SpecialDayState 
{
    started,
    active,
    inactive
};

SpecialDay g_SpecialDay;
SpecialDayState g_SpecialDayState;

const int SD_LIST_SIZE = 12;

char SD_LIST[][] = 
{
    "Death Match",
    "Dodgeball",
    "Friendly Fire",
    "Grenade",
    "Gun Game",
    "Headshot",
    "Juggernaut",
    "Knife",
    "One In The Chamber",
    "Scoutzknivez",
    // "Sky Wars",
    // "Spectre",
    "Tank",
    "Zombie",
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

stock int GetMaximumIndexFromArray(int[] array, int size)
{
    int max = 0;
    int returnIndex = 1;

    for (int i = 1; i <= size; i++)
    {
        if (array[i] > max)
        {
            max = array[i];
            returnIndex = i;
        }
    }

    return returnIndex;
}

stock bool IsPlayerOnTeam(int client)
{
    return GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T;
}

stock void RemoveAllWeapons()
{
    int maxent = GetMaxEntities();
    char weapon[64];

    for (int i = MaxClients; i < maxent; i++)
    {
        if (IsValidEdict(i) && IsValidEntity(i))
        {
            GetEdictClassname(i, weapon, sizeof(weapon));
            if (StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 && GetEntDataEnt2(i, g_WeaponParent) == -1)
            {
                RemoveEdict(i);
            }
        }
    }
}

stock void SaveTeams()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerOnTeam(i))
        {
            g_Teams[i] = GetClientTeam(i);
        }
    }
}

stock void RestoreTeams()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerOnTeam(i) && g_Teams[i] != GetClientTeam(i))
        {
            CS_SwitchTeam(i, g_Teams[i]);
        }
        g_Teams[i] = 0;
    }
}

stock int GetRandomClient()
{
    int client;
    
    for (;;)
    {
        client = GetRandomInt(0, MaxClients);
        if (IsValidClient(client) && IsPlayerOnTeam(client) && IsPlayerAlive(client))
            break;
    }
    return client;
}