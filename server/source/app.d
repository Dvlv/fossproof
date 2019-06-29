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

import api;
import dbhandler: DbHandler;
import socketcollection: SocketCollection;

SocketCollection listeningSocketsSignup;
SocketCollection listeningSocketsActions;
private int signups;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", staticRedirect("/index.html"))
          .get("/ws/live-signups", handleWebSockets(&handleSignups))
          .get("/ws/listen-action", handleWebSockets(&handleListenAction))
          .get("*", serveStaticFiles("public/"))
          .post("/api/action", &addAction);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);

    listeningSocketsSignup = new SocketCollection(["signup"]);
    listeningSocketsActions = new SocketCollection(["subscribe"]);

    auto DBH = DbHandler.get();
    DBH.connect(&listeningSocketsSignup.watch);
    DBH.connect(&listeningSocketsActions.watch);
}

void handleSignups(scope WebSocket socket)
{
    listeningSocketsSignup.addSocket(socket);
}

void handleListenAction(scope WebSocket socket)
{
    listeningSocketsActions.addSocket(socket);
}
