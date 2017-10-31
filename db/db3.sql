-- Production Database
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE AppData (
    login TEXT UNIQUE NOT NULL,
    name TEXT,
    password TEXT
);
INSERT INTO AppData
VALUES ('root','production',
        '$1$Ax6DIG/K$TDPdujixy5DDscpTWD5HU0'),
       ('deploy','devops deploy tools',
        '$1$hgTsycNO$FmJInHWROtkX6q7eWiJ1p/');
COMMIT;
