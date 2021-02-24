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

public void SpecialDay_One_In_Chamber_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
    RemoveAllWeapons(); //remove guns on map
    for(int i=1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i))
        {
            continue; 
        }
        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        GiveClientOneInChamberItems(i);
    }
}
public void One_In_Chamber_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) //I only use this instead of OnPlayerHurt because of other factors that can lead to death.
{
    char weapon[64];
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    event.GetString("weapon", weapon, sizeof(weapon));
    g_playerLives[victim]--;
    if(g_playerLives[victim] <= 0)
    {
        PrintToChat(victim, "%s You are out of lives", SD_PREFIX);
        return; //stops respawn when no lives
    }

    if(StrContains(weapon, "knife"))
    {
        one_in_chamber_setclipammo(attacker, 1); //gives attacker extra bullet because they didnt shoot to kill
    }
    else if(StrContains(weapon, "usp"))
    {
        one_in_chamber_setclipammo(attacker, 1); //gives attacker back their spent bullet
    }
    if (AlivePlayers() == 1) //This means if victim has more than 3 lives but dies when only 2 players left, game will end. Keeps SD from running on too long.
    {
        PrintToChatAll("%s %N won the Special Day!", SD_PREFIX, attacker);
        CS_TerminateRound(5.0, CSRoundEnd_Draw, true);
        return;
    }
    CreateTimer(1.0, Timer_One_In_Chamber_Revive, victim);
    PrintToChat(victim, "%s You have %i live(s) left", SD_PREFIX, g_playerLives[victim]);
}

public Action One_In_Chamber_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!IsValidClient(attacker))
    {
        return Plugin_Continue;
    }
    char weapon[32];
    GetClientWeapon(attacker, weapon, sizeof(weapon));

    if((StrContains(weapon, "knife"))||(StrContains(weapon, "usp")))
    { 
        int weaponvictim = GetPlayerWeaponSlot(victim, CS_SLOT_SECONDARY);
        if(weaponvictim != -1) //removes victims gun on death, prevents pickup
        {
            RemovePlayerItem(victim, weaponvictim);
            AcceptEntityInput(weaponvictim, "Kill");
        }
        damage = 500.0;
    }
    return Plugin_Changed;
}

public Action Timer_One_In_Chamber_Revive(Handle timer, int client)
{
    if(g_SpecialDayState == inactive)
    {
        return Plugin_Handled;
    }
    if(IsValidClient(client))
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

void one_in_chamber_setclipammo(int client, int ammo)//ammo isn't the int the clip is being set to, its the extra bullets to be added to clip. Ammo should always be 1
{
    int weapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
    int currentAmmo = GetEntProp(weapon, Prop_Send, "m_iClip1");
    int newAmmo = currentAmmo+ammo;
    SetEntProp(weapon, Prop_Send, "m_iClip1", newAmmo); 
    SetReserveAmmo(client, weapon, 0);
}

public void SpecialDay_One_In_Chamber_End()
{
    SetConVarBool(g_FriendlyFire, false);
}

int AlivePlayers()
{
    int counter = 0;
    for(int i=1; i<=MaxClients; i++)
    {
        if(IsValidClient(i) && IsPlayerAlive(i))
        {
            counter++;
        }
    }
    return counter;
}