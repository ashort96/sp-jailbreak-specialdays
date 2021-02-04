public void SpecialDay_Grenade_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
    RemoveAllWeapons();
    for (int i = 1; i <= MaxClients; i++)
    {

        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;

        SetEntityHealth(i, 250);
        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        StripAllWeapons(i);
        GivePlayerItem(i, "weapon_hegrenade");
    }

}

public void SpecialDay_Grenade_End()
{
    SetConVarBool(g_FriendlyFire, false);
}

public void Grenade_OnEntityCreated(int entity, const char[] classname)
{
    if (StrEqual(classname, "hegrenade_projectile"))
        CreateTimer(1.4, Timer_GiveGrenade, entity);
}

public Action Timer_GiveGrenade(Handle timer, any entity)
{
    int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");

    if (IsValidClient(client) && IsPlayerAlive(client))
    {
        StripAllWeapons(client);
        GivePlayerItem(client, "weapon_hegrenade");
    }
}