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

public void SpecialDay_Knife_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
    RemoveAllWeapons();

    for (int i = 1; i <= MaxClients; i++)
    {

        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;

        StripAllWeapons(i);
        GivePlayerItem(i, "weapon_knife");
    }
}

public void SpecialDay_Knife_End()
{
    SetConVarBool(g_FriendlyFire, false);
}