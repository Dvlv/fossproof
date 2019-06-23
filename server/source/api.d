module api;

import d2sqlite3;
import std.typecons : Nullable;
import std.digest.md;

import vibe.core.log;
import vibe.data.json;
import vibe.http.server;


void addAction(HTTPServerRequest req, HTTPServerResponse res)
{
    auto db = Database("storage/actions.db");
    db.run("CREATE TABLE IF NOT EXISTS actions (
        ip_hash TEXT NOT NULL,
        action TEXT NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL
    );");

    string[string] response = ["success": "false", "error": ""];

    Statement stmt = db.prepare("INSERT INTO actions (ip_hash, action, name, date)
                                VALUES (:ip_hash, :action, :name, date('now'));");

    auto postedData = req.json;

    if (!("name" in postedData)) {
        response["error"] = "Missing name";
    }

    if (!("action" in postedData)) {
        response["error"] = "Missing action";
    }

    string ipHash = toHexString(md5Of(req.clientAddress.toAddressString()));

    if (response["error"] == "")
    {
        stmt.bindAll(ipHash, postedData["action"].to!string, postedData["name"].to!string);
        stmt.execute();
        stmt.reset();

        response["success"] = "true";
    }

    res.writeBody(serializeToJsonString(response), "application/json");
}

