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

private WebSocket[] listeningSocketsSignup;
private WebSocket[] listeningSocketsActions;
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
}

void handleSignups(scope WebSocket socket)
{
    listeningSocketsSignup ~= socket;
    while (true)
    {
        sleep(1.seconds);
        if (!socket.connected)
        {
            listeningSocketsSignup.removeFromArray!WebSocket(socket);
            break;
        }

        string data = format(`{"total_signups": %d}`,
                signups);
        socket.send(data);
    }
    socket.close;
    listeningSocketsSignup.removeFromArray!WebSocket(socket);
}

void handleListenAction(scope WebSocket socket)
{
    listeningSocketsActions ~= socket;
}
