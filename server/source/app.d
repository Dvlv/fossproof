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

private WebSocket[] listeningSockets;
private string[] signups;

shared static this()
{
    auto router = new URLRouter;
    router.get("/", staticRedirect("/index.html"))
          .get("/ws/live-signups", handleWebSockets(&handleSignups))
          .get("/ws/send-event", handleWebSockets(&handleEvent))
          .get("*", serveStaticFiles("public/"))
          .post("/api/action", &addAction);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);
}

void handleEvent(scope WebSocket socket)
{
    while (socket.waitForData)
    {
        if (!socket.connected)
            break;

        auto msg = socket.receiveText;
        auto jsonMsg = parseJsonString(msg);

        string msgType = jsonMsg["type"].to!string;
        auto msgData = jsonMsg["data"];

        if (msgType == "signup")
        {
            signups ~= msgData["name"].to!string;
        }
    }
}

void handleSignups(scope WebSocket socket)
{
    listeningSockets ~= socket;
    while (true)
    {
        sleep(1.seconds);
        if (!socket.connected)
        {
            listeningSockets.removeFromArray!WebSocket(socket);
            break;
        }
        string latestSignup = "";
        if (signups.length > 0)
        {
            latestSignup = signups[$ - 1];
        }
        string data = format(`{"total_signups": %d, "new_signup": "%s"}`,
                signups.length, latestSignup);
        socket.send(data);
    }
    socket.close;
    listeningSockets.removeFromArray!WebSocket(socket);
}
