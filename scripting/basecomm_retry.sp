#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <basecomm>

#pragma newdecls required

public Plugin myinfo =
{
	name = "Basecomm Retry Manager",
	author = "Ilusion9",
	description = "Simple plugin that keeps players gagged or/and muted on retry",
	version = "1.1",
	url = "https://github.com/Ilusion9/"
};

/* Define our basecomm flags */
#define BASECOMM_GAGGED		1
#define BASECOMM_MUTED		2

StringMap g_Map_BaseComm;

public void OnPluginStart()
{
	/* Store the clients basecomm flags in a StringMap */
	g_Map_BaseComm = new StringMap();
}

public void OnMapStart()
{
	/* Clear all basecomm flags when a new map starts */
	g_Map_BaseComm.Clear();
}

public void OnClientDisconnect(int client)
{
	/* Get client's steamid */
	char steamId[64];
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		/* Invalid steamid */
		return;
	}
	
	/* Set client's basecomm flags on disconnecting */
	int flags = 0;
	if (BaseComm_IsClientGagged(client))
	{
		/* The client is gagged, we'll add the BASECOMM_GAGGED flag to his basecomm flags */
		flags |= BASECOMM_GAGGED;
	}
	
	if (BaseComm_IsClientMuted(client))
	{
		/* The client is muted, we'll add the BASECOMM_MUTED flag to his basecomm flags */
		flags |= BASECOMM_MUTED;
	}
	
	/* Store the client's basecomm flags in the StringMap */
	if (flags)
	{
		g_Map_BaseComm.SetValue(steamId, flags);
	}
}

public void OnClientPostAdminCheck(int client)
{
	/* Get client's steamid */
	char steamId[64];
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		/* Invalid steamid */
		return;
	}
	
	/* Get the client's basecomm flags from the StringMap */
	int flags = 0;
	if (!g_Map_BaseComm.GetValue(steamId, flags))
	{
		/* The client has no basecomm flags stored */
		return;
	}
	
	/* Check if the client has the BASECOMM_GAGGED flag */
	if (flags & BASECOMM_GAGGED)
	{
		BaseComm_SetClientGag(client, true);
	}
	
	/* Check if the client has the BASECOMM_MUTED flag */
	if (flags & BASECOMM_MUTED)
	{
		BaseComm_SetClientMute(client, true);
	}
	
	/* Remove the client's basecomm flags from the StringMap */
	g_Map_BaseComm.Remove(steamId);
}
