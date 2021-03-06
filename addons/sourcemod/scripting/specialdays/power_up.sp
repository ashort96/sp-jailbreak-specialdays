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


//Speed uses frags
int g_PlayerFrags[MAXPLAYERS + 1] = {0, ...};
float g_Speed[] = {1.0, 1.5, 2.0, 2.2, 2.4, 2.6, 2.8, 3.0, 3.1, 3.2, 3.3, 3.4, 3.5};

public void SpecialDay_PowerUp_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
    RemoveAllWeapons();
    
    for(int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue; 
        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        g_PlayerFrags[i] = 0;
        GiveClientPowerUpItems(i);
    }
}
public void SpecialDay_PowerUp_End()
{
    for(int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i))
            continue; 
        PrintToConsoleAll("Player %N | Kills: %i", i, g_PlayerFrags[i]);
        PrintToConsoleAll("Player %N | Kills: %i", i, g_PlayerFrags[i]);
    }
    SetConVarBool(g_FriendlyFire, false);
}
public Action PowerUp_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int weaponvictim = GetPlayerWeaponSlot(victim, CS_SLOT_PRIMARY);
    if (weaponvictim != -1)
    {
        RemovePlayerItem(victim, weaponvictim);
        AcceptEntityInput(weaponvictim, "Kill");
    }
    g_PlayerFrags[attacker]++;
    SetSpeed(attacker);
}
void GiveClientPowerUpItems(int client)
{
    SetEntProp(client, Prop_Data, "m_iMaxHealth", 1000);
    SetEntityHealth(client, 1000);
    StripAllWeapons(client);
    GivePlayerItem(client, "weapon_m249");
    int weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);

    SetEntProp(weapon, Prop_Send, "m_iClip1", 999999999);
    SetReserveAmmo(client, weapon, 999999999);
}
void SetSpeed(int client)
{
    //Prevents index out of bounds
    if(g_PlayerFrags[client] >= 12)
    {
        return; 
    }
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_Speed[g_PlayerFrags[client]]);
}
