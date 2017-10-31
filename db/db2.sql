-- Quality Assurance (QA) Database
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE AppData (
    login TEXT UNIQUE NOT NULL,
    name TEXT,
    password TEXT
);
INSERT INTO AppData
VALUES ('root','qa admins','admin_password'),
       ('test','qa testers','user_password');
COMMIT;
