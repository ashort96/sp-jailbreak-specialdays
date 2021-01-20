public void SpecialDay_FriendlyFire_Begin()
{
    g_FriendlyFireEnabled = true;
    SetConVarBool(g_FriendlyFire, true);
}

public void SpecialDay_FriendlyFire_End()
{
    g_FriendlyFireEnabled = false;
    SetConVarBool(g_FriendlyFire, false);
}