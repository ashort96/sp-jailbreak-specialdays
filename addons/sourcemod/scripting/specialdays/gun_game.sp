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

int g_playerGunLevel[MAXPLAYERS + 1] = {0, ...};

const int g_numRounds = 16;
static const char g_gunGameNames[g_numRounds][] =
{
    "weapon_glock",
    "weapon_usp",
    "weapon_mac10",
    "weapon_scout",
    "weapon_p228",
    "weapon_famas",
    "weapon_fiveseven",
    "weapon_mp5navy",
    "weapon_deagle",
    "weapon_xm1014",
    "weapon_m4a1",
    "weapon_m3",
    "weapon_awp",
    "weapon_ak47",
    "weapon_hegrenade",
    "weapon_knife"
};

public void SpecialDay_GunGame_Begin()
{

    RemoveAllWeapons();

    for (int i = 1; i <= MaxClients; i++)
    {
        g_playerGunLevel[i] = 0;

        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;

        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);

        GiveClientGunGameGun(i);
    }
}

public void SpecialDay_GunGame_End()
{

}

public void GunGame_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    char weapon[64];
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    event.GetString("weapon", weapon, sizeof(weapon));

    // If they got killed by someone other than a valid client
    if (!IsValidClient(attacker))
    {
        CreateTimer(3.0, Timer_GunGameRevive, victim);
        return;
    }

    // If someone got stabbed, drop them a level
    if (StrContains("weapon_knife", weapon) != -1)
    {
        if (g_playerGunLevel[victim] > 0)
            g_playerGunLevel[victim]--;
    }

    // Somehow they killed them with a gun they shouldn't have?
    else if (StrContains(g_gunGameNames[g_playerGunLevel[attacker]], weapon) == -1)
    {
        GiveClientGunGameGun(attacker);
        PrintToChat(attacker, "%s Don't use outside weapons", SD_PREFIX);
        CreateTimer(3.0, Timer_GunGameRevive, victim);
        return;
    }

    g_playerGunLevel[attacker]++;


    // Game over
    if (g_playerGunLevel[attacker] == g_numRounds)
    {
        PrintToChatAll("%s %N won the SpecialDay!", SD_PREFIX, attacker);

        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsValidClient(i) && IsPlayerAlive(i) && i != attacker)
                ForcePlayerSuicide(i);
        }
        return;
    }

    PrintToChat(attacker, "%s Level %d/%d", SD_PREFIX, g_playerGunLevel[attacker] + 1, g_numRounds);

    GiveClientGunGameGun(attacker);

    CreateTimer(3.0, Timer_GunGameRevive, victim);

}

public Action Timer_GunGameRevive(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Handled;

    if (IsValidClient(client))
    {
        CS_RespawnPlayer(client);
        GiveClientGunGameGun(client);
        SetEntProp(client, Prop_Data, "m_ArmorValue", 0.0);
    }

    return Plugin_Handled;
}

public void GunGame_OnEntityCreated(int entity, const char[] classname)
{
    if (StrEqual(classname, "hegrenade_projectile"))
        CreateTimer(1.4, GunGame_GiveGrenade, entity);
}

public Action GunGame_GiveGrenade(Handle timer, any entity)
{
    int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");

    if (IsValidClient(client) && IsPlayerAlive(client))
    {
        StripAllWeapons(client);
        GivePlayerItem(client, "weapon_hegrenade");
    }
}

void GiveClientGunGameGun(int client)
{
    StripAllWeapons(client);
    GivePlayerItem(client, "weapon_knife");
    if (g_playerGunLevel[client] < g_numRounds)
        GivePlayerItem(client, g_gunGameNames[g_playerGunLevel[client]]);
}
