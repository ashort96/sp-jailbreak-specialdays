public void SpecialDay_Tank_Begin()
{
    int client = GetRandomClient();
    SaveTeams();

    SetEntityHealth(client, GetClientCount(true) * 250);
    SetEntityRenderColor(client, 255, 0, 0, 255);
    PrintCenterTextAll("%N is the Tank!", client);

    CS_SwitchTeam(client, CS_TEAM_CT);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT && i != client)
        {
            CS_SwitchTeam(i, CS_TEAM_T);
        }
    }

}

public void SpecialDay_Tank_End()
{
    RestoreTeams();
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