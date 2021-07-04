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

int g_playerLives[MAXPLAYERS + 1] = {3, ...};

public void SpecialDay_OneInChamber_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
    RemoveAllWeapons();

    for (int i = 1; i <= MaxClients; i++)
    {
        g_playerLives[i] = 3;
        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue; 

        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        GiveClientOneInChamberItems(i);
    }
}

public void SpecialDay_OneInChamber_End()
{
    SetConVarBool(g_FriendlyFire, false);
}

public void OneInChamber_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    char weapon[64];
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    event.GetString("weapon", weapon, sizeof(weapon));
    PrintToChatAll("Victim: %N Attacker: %N", victim, attacker);

    g_playerLives[victim]--;
    if (StrContains(weapon, "knife") || StrContains(weapon, "usp"))
    {
        if (IsValidClient(attacker))
        {
            //In the case of a slay
            if(IsPlayerAlive(attacker))
            {
                AddToClip(attacker, 1);
            }
        }
    }
    if (GetNumAlivePlayers() == 1)
    {
        PrintToChatAll("%s %N won the Special Day!", g_SDPrefix, attacker);
        CS_TerminateRound(5.0, CSRoundEnd_Draw, true);
        return;
    }
    if (g_playerLives[victim] <= 0)
    {
        PrintToChat(victim, "%s You are out of lives", g_SDPrefix);
    }
    else
    {
        CreateTimer(1.0, Timer_OneInChamber_Revive, victim);
        PrintToChat(victim, "%s You have %i live(s) left", g_SDPrefix, g_playerLives[victim]);
    }
}

public Action OneInChamber_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!IsValidClient(attacker))
    {
        return Plugin_Continue;
    }

    char weapon[32];
    GetClientWeapon(attacker, weapon, sizeof(weapon));

    if (StrContains(weapon, "knife") || StrContains(weapon, "usp"))
    { 
        int weaponvictim = GetPlayerWeaponSlot(victim, CS_SLOT_SECONDARY);

        if (weaponvictim != -1)
        {
            RemovePlayerItem(victim, weaponvictim);
            AcceptEntityInput(weaponvictim, "Kill");
        }
        damage = 500.0;
    }
    return Plugin_Changed;
}

public Action Timer_OneInChamber_Revive(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
    {
        return Plugin_Handled;
    }
    if (IsValidClient(client))
    {
        CS_RespawnPlayer(client);
        GiveClientOneInChamberItems(client);
        SetEntProp(client, Prop_Data, "m_ArmorValue", 0.0);
    }
    return Plugin_Handled;
}

void GiveClientOneInChamberItems(int client)
{
    StripAllWeapons(client);
    GivePlayerItem(client, "weapon_usp", 0);
    GivePlayerItem(client, "weapon_knife");

    int weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);

    SetEntProp(weapon, Prop_Send, "m_iClip1", 1); 
    SetReserveAmmo(client, weapon, 0);
}

void AddToClip(int client, int ammo)
{
    int weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
    int currentAmmo = GetEntProp(weapon, Prop_Send, "m_iClip1");
    int newAmmo = currentAmmo+ammo;

    SetEntProp(weapon, Prop_Send, "m_iClip1", newAmmo); 
    SetReserveAmmo(client, weapon, 0);
}

int GetNumAlivePlayers()
{
    int counter = 0;

    for (int i=1; i<=MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i))
        {
            counter++;
        }
    }

    return counter;
}
