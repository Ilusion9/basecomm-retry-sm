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
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

#define BASECOMM_GAGGED		1
#define BASECOMM_MUTED		2

StringMap g_Map_BaseComm;

public void OnPluginStart()
{
	g_Map_BaseComm = new StringMap();
}

public void OnMapStart()
{
	g_Map_BaseComm.Clear();
}

public void OnClientDisconnect(int client)
{
	/* Get client's steamid */
	char steamId[64];
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return; // invalid steamid
	}
	
	/* Set client's BASECOMM flags on disconnecting */
	int flags = 0;
	if (BaseComm_IsClientGagged(client))
	{
		flags |= BASECOMM_GAGGED; // add this flag if the client's gagged
	}
	
	if (BaseComm_IsClientMuted(client))
	{
		flags |= BASECOMM_MUTED; // add this flag if the client's muted
	}
	
	/* Store client's flags */
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
		return; // invalid steamid
	}
	
	/* Get client's BASECOMM flags on connect */
	int flags = 0;
	if (!g_Map_BaseComm.GetValue(steamId, flags))
	{
		return; // the client has no BASECOMM flags stored
	}
	
	/* Check if the client was gagged on his last session */
	if (flags & BASECOMM_GAGGED)
	{
		BaseComm_SetClientGag(client, true);	
	}
	
	/* Check if the client was muted on his last session */
	if (flags & BASECOMM_MUTED)
	{
		BaseComm_SetClientMute(client, true);	
	}
	
	/* Remove the client's BASECOMM flags */
	g_Map_BaseComm.Remove(steamId);
}
