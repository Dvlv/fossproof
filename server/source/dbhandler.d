import d2sqlite3: Database, Statement;

import std.signals;
import std.conv;


class DbHandler
{
    private this()
    {
    }

    // Cache instantiation flag in thread-local bool
    // Thread local
    private static bool instantiated_;

    // Thread global
    private __gshared DbHandler instance_;

    static DbHandler get()
    {
        if (!instantiated_)
        {
            synchronized (DbHandler.classinfo)
            {
                if (!instance_)
                {
                    instance_ = new DbHandler();
                }

                instantiated_ = true;
            }
        }

        return instance_;
    }

    void initialise()
    {
        auto db = Database("storage/actions.db");
        bool exists = false;

        int count = db.execute("SELECT count(*) FROM sqlite_master WHERE type='table' AND name='actions';").oneValue!int;
        if (count > 0) {
            exists = true;
        }

        if (!exists) {
            db.run("CREATE TABLE IF NOT EXISTS actions (
                ip_hash TEXT NOT NULL,
                action TEXT NOT NULL,
                name TEXT NOT NULL,
                date TEXT NOT NULL
            );");
        }
    }

    void insertAction(string ipHash, string action, string name)
    {
        auto db = Database("storage/actions.db");
        Statement stmt = db.prepare("INSERT INTO actions (ip_hash, action, name, date)
                                    VALUES (:ip_hash, :action, :name, date('now'));");
        stmt.bindAll(ipHash, action, name);
        stmt.execute();
        stmt.reset();

        emit(action, name);
    }

    long countForAction(string action)
    {
        auto db = Database("storage/actions.db");
        Statement stmt = db.prepare("SELECT count(*) FROM actions WHERE action = :action");

        stmt.bindAll(action);
        long count = stmt.execute().oneValue!long;

        return count;
    }

    void pollAction(string action)
    {
        auto count = countForAction(action);
        emit(action, to!string(count));
    }

    mixin Signal!(string, string);
}
