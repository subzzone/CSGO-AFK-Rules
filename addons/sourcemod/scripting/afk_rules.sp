
 /* 
***********************************************************[ AFK RULES ]************************************************************

		Plugin created by: Alexelmanco

		Github: https://github.com/subzzone
		Discord: Alexelmanco#7184
		Steam: https://steamcommunity.com/id/alexelmanco/
		________________________________________________________________________

		THANKS TO:
		- JoanJuan = https://github.com/JoanJuan10 | To help in "VALIDADOR COOLDOWN RONDA USUARIO| AFK RULES" and fix a little bug.

		USABILITY:
		- This plugin is created for JailBreak servers.
		- This plugin is used to send an alarm to the CT so that it realizes that a T wants the rules because he was AFK.

		USABILITY:
		- CTs cannot use the command.
		- You can't use the command if you're dead.
		- You can't use the command if you are spectating.
************************************************************************************************************************************
*/


// ===========================================================================
// INCLUDES| AFK RULES
// ===========================================================================

#include <sourcemod>
#include <sdkhooks>
#include <sdktools_gamerules>
#include <sdktools_sound>
#include <sdktools_stringtables>

// ===========================================================================
// PRGAMA| AFK RULES
// ===========================================================================

#pragma semicolon 1

// ===========================================================================
// DEFINITION| AFK RULES
// ===========================================================================

#define warmup 1


// ===========================================================================
// MY INFO| AFK RULES
// ===========================================================================

public Plugin myinfo =
{
	name		= "AFK RULES",
	author		= "Alexelmanco",
	description = "This plugin is used to alert the CT that you return from AFK and want the rules",
	version		= "1.0",
	url			= "https://github.com/subzzone"
};


// ===========================================================================
// PUBLIC VARIABLES | AFK RULES
// ===========================================================================

new LastUsed[MAXPLAYERS + 1];
new bool:CmdUsed[MAXPLAYERS + 1];



// ===========================================================================
// BEGINNING | AFK RULES
// ===========================================================================
public OnPluginStart()
{
	// SPANISH

	RegConsoleCmd("sm_afkn", AFK_Rules, "Se usa para indicar al ct AFK NORMAS");
	RegConsoleCmd("sm_afknormas", AFK_Rules, "Se usa para indicar al ct AFK NORMAS");

	// ENGLISH

	RegConsoleCmd("sm_afkr", AFK_Rules, "It is used to indicate to the ct AFK RULES");
	RegConsoleCmd("sm_afkrules", AFK_Rules, "It is used to indicate to the ct AFK RULES");
	HookEvent("round_start", RoundStart);
}

public OnMapStart()
{
	AddFileToDownloadsTable("sound/afk_rules/alerta.mp3");
	PrecacheSound("afk_rules/alerta.mp3", true);

}

// ===========================================================================
// RESET RESTRICTION COMMAND | AFK RULES
// ===========================================================================
public Action RoundStart (Handle event, const char[] name, bool dontBroadcast)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		CmdUsed[i] = false;
	}
	return Plugin_Handled;
}

// ===========================================================================
// COMMAND | AFK RULES
// ===========================================================================
public Action AFK_Rules(int client, int args)
{
	// ===========================================================================
	// VALIDADOR DE CLIENTE| AFK RULES
	// ===========================================================================

	if (client == 0)
	{
		PrintToServer("[AFK RULES] Cannot be used directly on the server.");
		return Plugin_Handled;
	}

	if (IsClientInGame(client))
	{
		new team = GetClientTeam(client);

		// ===========================================================================
		// VALIDATOR IF HE IS A SPECTATOR| AFK RULES
		// ===========================================================================

		if (!IsPlayerAlive(client))
		{
			PrintToChat(client, "\x07 \x07[AFK RULES]\x08 \x08 You can't use this, you're a spectator.");
			return Plugin_Handled;
		}

		// ===========================================================================
		// VALIDATOR IF IS DEAD| AFK RULES
		// ===========================================================================

		if (team == 1)
		{
			PrintToChat(client, "\x07 \x07[AFK RULES]\x08 \x08 You can't use this, you're dead.");
			return Plugin_Handled;
		}

		// ===========================================================================
		// VALIDADOR IF IS CT| AFK RULES
		// ===========================================================================

		// TERRORIST = 2 , COUNTER TERRORIST = 3

		if (team == 3)
		{
			ReplyToCommand(client, "\x07 \x07[AFK RULES]\x08 \x08 You are anti-terrorist, you can't use this command.");
			return Plugin_Handled;
		 }

		//  ===========================================================================
		//  VALIDATOR IF YOU MISUSE THE COMMAND | AFK RULES
		//  ===========================================================================

		if (args > 0)
		{
			ReplyToCommand(client, "\x07 \x07[AFK RULES]\x08 \x08 Use the command correctly [!afkr or !afkrules].");
			return Plugin_Handled;
		}

		// ===========================================================================
		// VALIDATOR IF IT IS WARMUP | AFK RULES
		// ===========================================================================

		if (GameRules_GetProp("m_bWarmupPeriod") == 1)
		{
			ReplyToCommand(client, "\x07 \x07[AFK RULES]\x08 \x08 Estas en calentamiento no puedes usar este comando.");
			return Plugin_Handled;
		}
		
		// ===========================================================================
		// USER ROUND COOLDOWN VALIDATOR| AFK RULES
		// ===========================================================================
		
		if (CmdUsed[client] == true) {
			PrintToChat(client, "\x07 \x07[AFK RULES]\x08 \x08 You are in warm-up you cannot use this command.");
			return Plugin_Handled;
		}


		// ===========================================================================
		// COOLDOWN VALIDATOR TO ALL| AFK RULES
		// ===========================================================================
		new currentTime = GetTime();
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (currentTime - LastUsed[i] < 20)
			{
				PrintToChat(client, "\x07 \x07[AFK RULES]\x08 \x08 You cannot use the command there is a player who used it recently.");
				return Plugin_Handled;
			}
		}
		
		
		// ===========================================================================
		// CONTINUE PROGRAM | AFK RULES
		// ===========================================================================
		
		LastUsed[client] = GetTime();
		CmdUsed[client] = true;

		// MENSAJE DE CONFIRMACION AL CLIENTE

		ReplyToCommand(client, "\x07 \x07[AFK RULES]\x08 \x08 Sent to the captain.");

		// MENSAJE A TODOS LOS CT'S
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && GetClientTeam(i) == 3)
			{
				EmitSoundToClient(i, "afk_rules/alerta.mp3");
				PrintCenterText(i, "\x07 \x07 HAVE REQUESTED AFK RULES");
			}
		}

		return Plugin_Handled;
	}

	PrintToChat(client, "\x07 \x07[AFK RULES]\x08 \x08 You can't use this.");
	return Plugin_Handled;
}

// ===========================================================================
// VALIDATE CLIENT | AFK RULES
// ===========================================================================
bool: IsValidClient(client)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client))
		return false;

	return true;
}

public OnClientPutInServer(client)
{
	LastUsed[client] = 0;
	CmdUsed[client] = false;
}
