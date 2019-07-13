import vibe.core.core : sleep;
import vibe.core.log;
import vibe.data.json;
import vibe.http.fileserver : serveStaticFiles;
import vibe.http.router : URLRouter;
import vibe.http.server;
import vibe.http.websockets : WebSocket, handleWebSockets;
import vibe.utils.array;

import core.time;
import std.conv : to;
import std.stdio : writeln;
import std.string : format;
import std.file;
import std.array;

import api;
import dbhandler: DbHandler;
import socketcollection: SocketCollection;

SocketCollection listeningSocketsSignup;
SocketCollection listeningSocketsActions;
private int signups;

string[] authorisedDomains;
ushort port;
Json settingsJson;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", staticRedirect("/index.html"))
          .get("/ws/live-signups", handleWebSockets(&handleSignups))
          .get("/ws/listen-action", handleWebSockets(&handleListenAction))
          .get("*", serveStaticFiles("public/"))
          .post("/api/action", &addAction);

    if(exists("./fossproof-settings.json")) {
        parseSettingsFile();
    } else {
        logInfo("File fossproof-settings.json could not be found.");
    }

    auto settings = new HTTPServerSettings;
    settings.port = port;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);

    listeningSocketsSignup = new SocketCollection(["signup"]);
    listeningSocketsActions = new SocketCollection(["subscribe"]);

    listeningSocketsActions.setAuthorisedDomains(authorisedDomains);
    listeningSocketsSignup.setAuthorisedDomains(authorisedDomains);

    auto DBH = DbHandler.get();
    DBH.connect(&listeningSocketsSignup.watch);
    DBH.connect(&listeningSocketsActions.watch);
}

void parseSettingsFile()
{
    string settingsContent = readText("./fossproof-settings.json");
    try
    {
        settingsJson = parseJson(settingsContent);
    }
    catch (JSONException e)
    {
        logInfo("fossproof-settings is invalid json: " ~ e.msg);
    }

    if ("port" in settingsJson)
    {
        port = settingsJson["port"].to!ushort;
    }
    else
    {
        port = 8080;
    }

    if ("domains" in settingsJson) {
        if (to!string(settingsJson["domains"].type()) == "array") {
            foreach(domain; settingsJson["domains"]) {
                authorisedDomains ~= domain.to!string;
            }
        } else {
            logInfo("fossproof-settings.json 'domains' must be an array! No domains will be authorised.");
        }
    }
}

void handleSignups(scope WebSocket socket)
{
    listeningSocketsSignup.addSocket(socket);
}

void handleListenAction(scope WebSocket socket)
{
    logInfo(to!string(socket.request.headers));
    listeningSocketsActions.addSocket(socket);
}
