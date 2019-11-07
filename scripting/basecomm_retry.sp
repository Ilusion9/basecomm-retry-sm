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
	g_Map_BaseComm.Clear();
}

public void OnClientDisconnect(int client)
{
	char steamId[64];
	
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return;
	}
	
	int value = BASECOMM_NORMAL;
	
	if (BaseComm_IsClientGagged(client))
	{
		value |= BASECOMM_GAGGED;
	}
	
	if (BaseComm_IsClientMuted(client))
	{
		value |= BASECOMM_MUTED;
	}
	
	if (value != BASECOMM_NORMAL)
	{
		g_Map_BaseComm.SetValue(steamId, value);
	}
}

public void OnClientPostAdminCheck(int client)
{
	char steamId[64];

	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return;
	}

	int value = BASECOMM_NORMAL;

	if (!g_Map_BaseComm.GetValue(steamId, value))
	{
		return;
	}
	
	if (value & BASECOMM_GAGGED)
	{
		BaseComm_SetClientGag(client, true);	
	}
	
	if (value & BASECOMM_MUTED)
	{
		BaseComm_SetClientMute(client, true);	
	}
	
	g_Map_BaseComm.Remove(steamId);
}
