#include <sourcemod>
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
	
	int flags;
	if (BaseComm_IsClientGagged(client))
	{
		flags |= BASECOMM_GAGGED;
	}
	
	if (BaseComm_IsClientMuted(client))
	{
		flags |= BASECOMM_MUTED;
	}
	
	if (flags)
	{
		g_Map_BaseComm.SetValue(steamId, flags);
	}
}

public void OnClientPostAdminCheck(int client)
{
	char steamId[64];
	if (!GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId)))
	{
		return;
	}
	
	int flags;
	if (!g_Map_BaseComm.GetValue(steamId, flags))
	{
		return;
	}
	
	if (flags & BASECOMM_GAGGED)
	{
		BaseComm_SetClientGag(client, true);
	}
	
	if (flags & BASECOMM_MUTED)
	{
		BaseComm_SetClientMute(client, true);
	}
	
	g_Map_BaseComm.Remove(steamId);
}
