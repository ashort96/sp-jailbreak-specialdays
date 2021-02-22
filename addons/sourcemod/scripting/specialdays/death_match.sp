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

int g_DeathMatchKills[MAXPLAYERS];

public void SpecialDay_DeathMatch_Begin()
{
    // Make sure everything is zero'd out
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        g_DeathMatchKills[i] = 0;
    }

    CreateTimer(90.0, Timer_DeathMatchEnd);

}

public void SpecialDay_DeathMatch_End()
{

}

public void DeathMatch_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));

    CreateTimer(3.0, Timer_DeathMatchRevive, victim);
    g_DeathMatchKills[attacker]++;
}

public Action Timer_DeathMatchRevive(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Handled;

    if (IsValidClient(client))
    {
        CS_RespawnPlayer(client);
        DisplayGunMenu(client);
    }
    return Plugin_Handled;
}

public Action Timer_DeathMatchEnd(Handle timer)
{

    if (g_SpecialDayState == inactive || g_SpecialDay != deathMatch)
        return Plugin_Handled;

    int clientIndex = GetMaximumIndexFromArray(g_DeathMatchKills, sizeof(g_DeathMatchKills));
    if (IsValidClient(clientIndex))
    {
        PrintToChatAll("%s %N won the Death Match!", SD_PREFIX, clientIndex);
    }
    else 
    {
        PrintToChatAll("%s The winner left the game!", SD_PREFIX);
    }

    // Slay everyone but the person that won
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