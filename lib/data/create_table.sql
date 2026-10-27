CREATE TABLE Dogs (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
);

CREATE TABLE Walks (
    id TEXT PRIMARY KEY,
    dog_id TEXT NOT NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    route TEXT,
    comment TEXT,
    sync_status INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (dog_id)
        REFERENCES Dogs(id)
        ON DELETE CASCADE
);