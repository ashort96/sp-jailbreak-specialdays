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

int tankClient;

public void SpecialDay_Tank_Begin()
{
    tankClient = GetRandomClient();
    SaveTeams();

    SetEntityHealth(tankClient, GetClientCount(true) * 250);
    SetEntityRenderColor(tankClient, 255, 0, 0, 255);
    PrintCenterTextAll("%N is the Tank!", tankClient);

    CS_SwitchTeam(tankClient, CS_TEAM_CT);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT && i != tankClient)
        {
            CS_SwitchTeam(i, CS_TEAM_T);
        }
    }

}

public void SpecialDay_Tank_End()
{
    RestoreTeams();
}

public void Tank_OnPlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if (client == tankClient)
    {
        tankClient = GetRandomClient();
        SetEntityHealth(tankClient, GetClientCount(true) * 250);
        SetEntityRenderColor(tankClient, 255, 0, 0, 255);
        PrintToChatAll("%s The tank has left the game! %N is the new tank!", SD_PREFIX, tankClient);
        PrintCenterTextAll("%N IS THE NEW TANK!", tankClient);
        CS_SwitchTeam(tankClient, CS_TEAM_CT);
    }
}

public Action Tank_JoinTeam(int client, int args)
{
    char teamString[3];
    GetCmdArg(1, teamString, sizeof(teamString));
    int newTeam = StringToInt(teamString);

    // We want them to be on the T team
    if (newTeam == CS_TEAM_CT)
    {
        CS_SwitchTeam(client, CS_TEAM_T);
    }

}