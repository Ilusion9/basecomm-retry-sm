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

/* Define our BASECOMM flags */
#define BASECOMM_NORMAL		0
#define BASECOMM_GAGGED		1
#define BASECOMM_MUTED		2

StringMap g_Map_BaseComm;

public void OnPluginStart()
{
	g_Map_BaseComm = new StringMap();
}

public void OnMapStart()
{
	/* Clear all info on map start */
	g_Map_BaseComm.Clear();
}

public void OnClientDisconnect(int client)
{
	char steamId[64];
	
	/* Get the client's steamid and check if it's valid */
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return;
	}
	
	int value = BASECOMM_NORMAL;
	
	/* If the client is gagged, add the BASECOMM_GAGGED flag to his BASECOMM flags */
	if (BaseComm_IsClientGagged(client))
	{
		value |= BASECOMM_GAGGED;
	}
	
	/* If the client is muted, add the BASECOMM_MUTED flag to his BASECOMM flags */
	if (BaseComm_IsClientMuted(client))
	{
		value |= BASECOMM_MUTED;
	}
	
	/* Store the client's BASECOMM flags */
	if (value != BASECOMM_NORMAL)
	{
		g_Map_BaseComm.SetValue(steamId, value);
	}
}

public void OnClientPostAdminCheck(int client)
{
	char steamId[64];
	
	/* Get the client's steamid and check if it's valid */
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return;
	}
	
	int value = BASECOMM_NORMAL;
	
	/* Check the state of this client when he left the server - get our BASECOMM flags */
	if (!g_Map_BaseComm.GetValue(steamId, value))
	{
		return;
	}
	
	/* If the client was gagged, gag him */
	if (value & BASECOMM_GAGGED)
	{
		BaseComm_SetClientGag(client, true);	
	}
	
	/* If the client was muted, mute him */
	if (value & BASECOMM_MUTED)
	{
		BaseComm_SetClientMute(client, true);	
	}
	
	/* Remove the client's flags */
	g_Map_BaseComm.Remove(steamId);
}
