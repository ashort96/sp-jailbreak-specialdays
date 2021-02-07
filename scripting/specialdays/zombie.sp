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

int patientZero;
int fogEnt;

float deathPositions[MAXPLAYERS][3];

public void SpecialDay_Zombie_Begin()
{
    patientZero = GetRandomClient();
    SaveTeams();

    // Setup the initial zombie
    MakeZombie(patientZero);
    SetEntityRenderColor(patientZero, 255, 0, 0, 255);
    SetEntityHealth(patientZero, GetClientCount(true) * 1000);
    CS_SwitchTeam(patientZero, CS_TEAM_T);

    // Make sure everyone else is set
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && i != patientZero)
        {
            CS_SwitchTeam(i, CS_TEAM_CT);
            SetEntityCollisionGroup(i, COLLISION_GROUP_DEBRIS_TRIGGER);
        }
    }

    PrintCenterTextAll("%N IS PATIENT ZERO!", patientZero);
    EmitSoundToAll("music/hla.mp3");
    AcceptEntityInput(fogEnt, "TurnOn");

}

public void SpecialDay_Zombie_End()
{
    RestoreTeams();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            SetEntityGravity(i, 1.0);
        }
    }

    AcceptEntityInput(fogEnt, "TurnOff");
}

public void Zombie_OnMapStart()
{
    int zombieModelListSize = 33;
    char zombieModelList[][] = {
        "models/player/slow/aliendrone/slow_alien.dx80.vtx",
        "models/player/slow/aliendrone/slow_alien.dx90.vtx",
        "models/player/slow/aliendrone/slow_alien.mdl",
        "models/player/slow/aliendrone/slow_alien.phy",
        "models/player/slow/aliendrone/slow_alien.sw.vtx",
        "models/player/slow/aliendrone/slow_alien.vvd",
        "models/player/slow/aliendrone/slow_alien.xbox.vtx",
        "models/player/slow/aliendrone/slow_alien_head.dx80.vtx",
        "models/player/slow/aliendrone/slow_alien_head.dx90.vtx",
        "models/player/slow/aliendrone/slow_alien_head.mdl",
        "models/player/slow/aliendrone/slow_alien_head.phy",
        "models/player/slow/aliendrone/slow_alien_head.sw.vtx",
        "models/player/slow/aliendrone/slow_alien_head.vvd",
        "models/player/slow/aliendrone/slow_alien_head.xbox.vtx",
        "models/player/slow/aliendrone/slow_alien_hs.dx80.vtx",
        "models/player/slow/aliendrone/slow_alien_hs.dx90.vtx",
        "models/player/slow/aliendrone/slow_alien_hs.mdl",
        "models/player/slow/aliendrone/slow_alien_hs.phy",
        "models/player/slow/aliendrone/slow_alien_hs.sw.vtx",
        "models/player/slow/aliendrone/slow_alien_hs.vvd",
        "models/player/slow/aliendrone/slow_alien_hs.xbox.vtx",
        "materials/models/player/slow/aliendrone/drone_arms.vmt",
        "materials/models/player/slow/aliendrone/drone_arms.vtf",
        "materials/models/player/slow/aliendrone/drone_arms_normal.vtf",
        "materials/models/player/slow/aliendrone/drone_head.vmt",
        "materials/models/player/slow/aliendrone/drone_head.vtf",
        "materials/models/player/slow/aliendrone/drone_head_normal.vtf",
        "materials/models/player/slow/aliendrone/drone_legs.vmt",
        "materials/models/player/slow/aliendrone/drone_legs.vtf",
        "materials/models/player/slow/aliendrone/drone_legs_normal.vtf",
        "materials/models/player/slow/aliendrone/drone_torso.vmt",
        "materials/models/player/slow/aliendrone/drone_torso.vtf",
        "materials/models/player/slow/aliendrone/drone_torso_normal.vtf"        
    };

    // Precache the zombie skin
    for (int i = 0; i < zombieModelListSize; i++)
    {
        AddFileToDownloadsTable(zombieModelList[i]);
        PrecacheModel(zombieModelList[i]);
    }

    // Sounds
    AddFileToDownloadsTable("sound/music/HLA.mp3");
    PrecacheSound("music/HLA.mp3");
    PrecacheSound("npc/zombie/zombie_voice_idle1.wav");

    // Fog

    fogEnt = FindEntityByClassname(-1, "env_fog_controller");

    if (fogEnt == -1)
    {
        fogEnt = CreateEntityByName("env_fog_controller");
        DispatchSpawn(fogEnt);
    }


    DispatchKeyValue(fogEnt, "fogblend", "0");
    DispatchKeyValue(fogEnt, "fogcolor", "0 0 0");
    DispatchKeyValue(fogEnt, "fogcolor2", "0 0 0");
    DispatchKeyValueFloat(fogEnt, "fogstart", 350.0);
    DispatchKeyValueFloat(fogEnt, "fogend", 750.0);
    DispatchKeyValueFloat(fogEnt, "fogmaxdensity", 50.0);        


    AcceptEntityInput(fogEnt, "TurnOff");

}

public void Zombie_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));

    if (GetClientTeam(victim) == CS_TEAM_CT)
    {
        GetClientAbsOrigin(victim, deathPositions[victim]);
        deathPositions[victim][2] -= 45.0;
        CreateTimer(0.5, Timer_ZombieMake, victim);

        EmitSoundToAll("npc/zombie/zombie_voice_idle1.wav");

        // Check to see if there is only one CT left...
        int numberOfCts = 0;
        int lastManId;
        
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
            {
                lastManId = i;
                numberOfCts++;
            }
        }

        if (numberOfCts == 1)
        {
            PrintCenterTextAll("%N IS THE LAST MAN STANDING!", lastManId);
            SetEntityHealth(lastManId, 350);
            int weapon = GetPlayerWeaponSlot(lastManId, CS_SLOT_SECONDARY);
            SetReserveAmmo(lastManId, weapon, 999);
            weapon = GetPlayerWeaponSlot(lastManId, CS_SLOT_PRIMARY);
            SetReserveAmmo(lastManId, weapon, 999);
        }

    }
    else if (GetClientTeam(victim) == CS_TEAM_T)
    {
        CreateTimer(3.0, Timer_ZombieRevive, victim);
    }

}

public void Zombie_OnPlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if (client == patientZero)
    {
        PrintToChatAll("%s Patient zero has left the game! Kill the remaining zombies!", SD_PREFIX);
    }
}

public Action Zombie_JoinTeam(int client, int args)
{
    char teamString[3];
    GetCmdArg(1, teamString, sizeof(teamString));
    int newTeam = StringToInt(teamString);

    // Make them a zombie
    if (newTeam == CS_TEAM_CT)
    {
        CS_SwitchTeam(client, CS_TEAM_T);
        CreateTimer(0.5, Timer_ZombieRevive, client);
    }
}

public Action Zombie_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!IsValidClient(attacker))
        return Plugin_Continue;

    if (GetClientTeam(victim) == CS_TEAM_T)
    {
        float attackerAngles[3];
        float attackerPosition[3];
        float victimPosition[3];

        GetClientEyeAngles(attacker, attackerAngles);
        GetClientEyePosition(attacker, attackerPosition);

        TR_TraceRayFilter(attackerPosition, attackerAngles, MASK_ALL, RayType_Infinite, TraceFilter_IgnorePlayers);
        TR_GetEndPosition(victimPosition);

        float pushBack[3];
        MakeVectorFromPoints(attackerPosition, victimPosition, pushBack);

        NormalizeVector(pushBack, pushBack);

        float scale = damage * 3;
        ScaleVector(pushBack, scale);

        float velocity[3];
        GetEntPropVector(victim, Prop_Data, "m_vecAbsVelocity", velocity);

        float newVelocity[3];
        AddVectors(velocity, pushBack, newVelocity);

        SetEntPropVector(victim, Prop_Data, "m_vecAbsVelocity", newVelocity);
    }

    if (attacker == patientZero)
    {
        damage = 999.0;
    }

    return Plugin_Changed;

}

public Action Zombie_OnWeaponEquip(int client, int weapon)
{
    char weaponString[32];
    GetEdictClassname(weapon, weaponString, sizeof(weaponString));

    if (GetClientTeam(client) == CS_TEAM_T)
    {
        if (!StrEqual(weaponString, "weapon_knife"))
        {
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

public Action Timer_ZombieRevive(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Handled;

    if (IsValidClient(patientZero) && IsPlayerAlive(patientZero))
    {
        float position[3];
        GetClientAbsOrigin(patientZero, position);
        CS_RespawnPlayer(client);
        TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
        MakeZombie(client);
    }

    return Plugin_Handled;
}

public Action Timer_ZombieMake(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Handled;

    CS_RespawnPlayer(client);
    TeleportEntity(client, deathPositions[client], NULL_VECTOR, NULL_VECTOR);
    CS_SwitchTeam(client, CS_TEAM_T);
    MakeZombie(client);

    return Plugin_Handled;
}

void MakeZombie(int client)
{
    StripAllWeapons(client);
    SetEntityHealth(client, 250);
    SetEntityGravity(client, 0.4);
    GivePlayerItem(client, "weapon_knife");
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
    SetEntityModel(client, "models/player/slow/aliendrone/slow_alien.mdl");
    SetEntityCollisionGroup(client, COLLISION_GROUP_DEBRIS_TRIGGER);
}