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

    this(string[] myActions)
    {
        this.myActions = myActions;
    }

    void addSocket(scope WebSocket socket)
    {
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
        if (myActions.canFind(action))
        {
            foreach (socket; this.mySockets)
            {
                if (!socket.connected)
                {
                    socket.close;
                    this.mySockets.removeFromArray!WebSocket(socket);
                    continue;
                }

                socket.send(format(`{"action": "%s", "name": "%s"}`, action, name));
            }
        }
    }
}
