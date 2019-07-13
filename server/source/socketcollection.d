import vibe.utils.array;
import vibe.http.websockets : WebSocket;
import vibe.core.log;

import std.algorithm : canFind;
import std.string;
import std.conv : to;

class SocketCollection
{
    WebSocket[] mySockets;
    string[] myActions;
    string[] authorisedDomains;

    this(string[] myActions)
    {
        this.myActions = myActions;
    }

    void setAuthorisedDomains(string[] domains)
    {
        authorisedDomains = domains;
    }

    void addSocket(scope WebSocket socket)
    {
        string socketHost = socket.request.host;
        logInfo("adding socket from " ~ socketHost);
        if (!(authorisedDomains.canFind(socketHost))) {
            logInfo("Rejecting unauthorised socket from " ~ socketHost ~ " \n allowed: " ~ to!string(authorisedDomains));
            //socket.close;
        }
        logInfo("Socket listening for " ~ to!string(myActions));
        this.mySockets ~= socket;
        while (socket.waitForData)
        {
            auto text = socket.receiveText;
            if (text == "terminate")
            {
                break;
            }
        }
        socket.close;
        this.mySockets.removeFromArray!WebSocket(socket);
    }

    void watch(string action, string name)
    {
        logInfo("received " ~ action);
        if (myActions.canFind(action))
        {
            logInfo("found action");
            logInfo(to!string(this.mySockets.length));
            foreach (socket; this.mySockets)
            {
                if (!socket.connected)
                {
                    logInfo("closing socket");
                    socket.close;
                    this.mySockets.removeFromArray!WebSocket(socket);
                    continue;
                }

                logInfo(format("sending to %d ", this.mySockets.length));
                socket.send(format(`{"action": "%s", "name": "%s"}`, action, name));
            }
        }
    }
}
