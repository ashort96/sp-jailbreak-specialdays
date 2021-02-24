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

int g_ScoutKnivesKills[MAXPLAYERS];

public void SpecialDay_Scoutknives_Begin()
{
    for (int i = 1; i < MAXPLAYERS; i++)
    {
        g_ScoutKnivesKills[i] = 0;
    }

    RemoveAllWeapons();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;
        
        StripAllWeapons(i);
        GivePlayerItem(i, "weapon_scout");
        GivePlayerItem(i, "weapon_knife");
        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        SetEntityGravity(i, 0.1);
    }

    SetConVarBool(g_FriendlyFire, false);

    CreateTimer(90.0, Timer_ScoutknivesEnd);
}

public void SpecialDay_Scoutknives_End()
{
    SetConVarBool(g_FriendlyFire, false);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            SetEntityGravity(i, 1.0);
        }
    }

}

public void Scoutknives_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));

    CreateTimer(3.0, Timer_ScoutknivesRevive, victim);
    g_ScoutKnivesKills[attacker]++;
}

public Action Scoutknives_OnWeaponEquip(int client, int weapon)
{
    char weaponString[32];
    GetEdictClassname(weapon, weaponString, sizeof(weaponString));

    if (GetClientTeam(client) == CS_TEAM_T)
    {
        if (!(StrEqual(weaponString, "weapon_knife") || StrEqual(weaponString, "weapon_scout")))
        {
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

public Action Timer_ScoutknivesRevive(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Handled;

    if (IsValidClient(client))
    {
        CS_RespawnPlayer(client);
        StripAllWeapons(client);
        GivePlayerItem(client, "weapon_scout");
        GivePlayerItem(client, "weapon_knife");
        SetEntProp(client, Prop_Data, "m_ArmorValue", 0.0);
        SetEntityGravity(client, 0.1);
    }
    return Plugin_Handled;
}

public Action Timer_ScoutknivesEnd(Handle timer)
{
    
    if (g_SpecialDayState == inactive || g_SpecialDay != scoutknives)
        return Plugin_Handled;

    int clientIndex = GetMaximumIndexFromArray(g_ScoutKnivesKills, sizeof(g_ScoutKnivesKills));

    if (IsValidClient(clientIndex))
    {
        PrintToChatAll("%s %N won Scoutzknivez!", g_Prefix, clientIndex);
    }
    else 
    {
        PrintToChatAll("%s The winner left the game!", g_Prefix);
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i))
        {
            if (i != clientIndex)
                ForcePlayerSuicide(i);
        }
    }
    return Plugin_Handled;

}