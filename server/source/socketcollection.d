import vibe.utils.array;
import vibe.http.websockets : WebSocket;

import std.algorithm: canFind;
import std.string;




class SocketCollection
{
    WebSocket[] mySockets;
    string[] myActions;

    this(string[] myActions) {
        this.myActions = myActions;
    }

    void addSocket(scope WebSocket socket)
    {
        this.mySockets ~= socket;
    }

    void watch(string action, string name)
    {
        if (myActions.canFind(action)) {
            foreach(socket; this.mySockets)
            {
                if (!socket.connected) {
                    socket.close;
                    this.mySockets.removeFromArray!WebSocket(socket);
                    continue;
                }

                socket.send(format(`{"action": %s, "name": %s}`, action, name));
            }
        }
    }
    void ree(string a, string n)
    {
        auto s = a ~ n;
    }
}


