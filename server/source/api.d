module api;

import d2sqlite3;
import std.typecons : Nullable;
import std.digest.md;

import vibe.core.log;
import vibe.data.json;
import vibe.http.server;

import dbhandler;


void addAction(HTTPServerRequest req, HTTPServerResponse res)
{
    auto DBH = DbHandler.get();

    string[string] response = ["success": "false", "error": ""];

    auto postedData = req.json;

    if (!("name" in postedData)) {
        response["error"] = "Missing name";
    }

    if (!("action" in postedData)) {
        response["error"] = "Missing action";
    }

    string ipHash = toHexString(md5Of(req.clientAddress.toAddressString()));
    logInfo(req.host); // This is to use for domain auth

    if (response["error"] == "")
    {
        DBH.insertAction(ipHash, postedData["action"].to!string, postedData["name"].to!string);

        response["success"] = "true";
    }

    res.writeBody(serializeToJsonString(response), "application/json");
}

