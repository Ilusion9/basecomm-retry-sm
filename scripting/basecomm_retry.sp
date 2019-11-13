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

/* Basecomm flags */
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
	/* Clear all basecomm flags on map start */
	g_Map_BaseComm.Clear();
}

public void OnClientDisconnect(int client)
{
	/* Get the client's steamid */
	char steamId[64];
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return;
	}
	
	/* Set the client's basecomm flags */
	int flags = 0;
	if (BaseComm_IsClientGagged(client))
	{
		flags |= BASECOMM_GAGGED; // add this flag if the client is gagged
	}
	
	if (BaseComm_IsClientMuted(client))
	{
		flags |= BASECOMM_MUTED; // add this flag if the client is muted
	}
	
	/* Save the client's basecomm flags */
	if (flags)
	{
		g_Map_BaseComm.SetValue(steamId, flags);
	}
}

public void OnClientPostAdminCheck(int client)
{
	/* Get the client's steamid */
	char steamId[64];
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return;
	}
	
	/* Get the client's basecomm flags */
	int flags = 0;
	if (!g_Map_BaseComm.GetValue(steamId, flags))
	{
		return;
	}
	
	/* Check the client's basecomm flags */
	if (flags & BASECOMM_GAGGED)
	{
		BaseComm_SetClientGag(client, true); // the client was gagged on his last session - gag him
	}
	
	if (flags & BASECOMM_MUTED)
	{
		BaseComm_SetClientMute(client, true); // the client was muted on his last session - mute him
	}
	
	/* Remove the client's basecomm flags */
	g_Map_BaseComm.Remove(steamId);
}
