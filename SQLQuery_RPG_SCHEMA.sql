GO
CREATE SCHEMA RPG;
GO

CREATE TABLE RPG.Locations (
    LocationID INT PRIMARY KEY IDENTITY(1,1),
    [Name] VARCHAR(50) NOT NULL,
    Weather VARCHAR(25),
    EncounterLevel INT NOT NULL,
    QuestID INT,
    PlayerID INT,
    -- FOREIGN KEY (QuestID) REFERENCES RPG.Quests(QuestID),
    -- FOREIGN KEY (PlayerID) REFERENCES RPG.Players(PlayerID)
);
ALTER TABLE RPG.Locations
ADD FOREIGN KEY (QuestID) REFERENCES RPG.Quests(QuestID), FOREIGN KEY (PlayerID) REFERENCES RPG.Players(PlayerID)

CREATE TABLE RPG.Players (
    PlayerID INT PRIMARY KEY IDENTITY(1,1),
    [Name] VARCHAR(50) NOT NULL,
    Class VARCHAR(25) NOT NULL,
    [Level] INT NOT NULL,
    RegistrationDate DATETIME,
    LocationID INT,
    -- FOREIGN KEY (LocationID) REFERENCES RPG.Locations(LocationID)
);
ALTER TABLE RPG.Players
ADD FOREIGN KEY (LocationID) REFERENCES RPG.Locations(LocationID)

CREATE TABLE RPG.Quests (
    QuestID INT PRIMARY KEY IDENTITY(1,1),
    [Name] VARCHAR(50) NOT NULL,
    EXP INT NOT NULL,
    LocationID INT,
    ItemID INT,
    -- FOREIGN KEY (LocationID) REFERENCES RPG.Locations(LocationID),
    -- FOREIGN KEY (ItemID) REFERENCES RPG.Items(ItemID)
);
ALTER TABLE RPG.Quests
ADD FOREIGN KEY (LocationID) REFERENCES RPG.Locations(LocationID), FOREIGN KEY (ItemID) REFERENCES RPG.Items(ItemID)

CREATE TABLE RPG.Items (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    [Name] VARCHAR(50) NOT NULL,
    Quantity INT,
    QuestID INT,
    PlayerID INT,
    -- FOREIGN KEY (QuestID) REFERENCES RPG.Quests(QuestID),
    -- FOREIGN KEY (PlayerID) REFERENCES RPG.Players(PlayerID)
);
ALTER TABLE RPG.Items
ADD FOREIGN KEY (QuestID) REFERENCES RPG.Quests(QuestID), FOREIGN KEY (PlayerID) REFERENCES RPG.Players(PlayerID)

CREATE TABLE RPG.Player_Quests (
    PlayerID INT,
    QuestID INT,
    Completion BIT,
    PRIMARY KEY (PlayerID, QuestID),
    FOREIGN KEY (PlayerID) REFERENCES RPG.Players(PlayerID),
    FOREIGN KEY (QuestID) REFERENCES RPG.Quests(QuestID)
);


CREATE TABLE RPG.PlayerHistory (
    HistoryID INT PRIMARY KEY IDENTITY(1,1),
    PlayerID INT,
    [Name] VARCHAR(50) NOT NULL,
    Class VARCHAR(25) NOT NULL,
    [Level] INT NOT NULL,
    RegistrationDate DATETIME,
    LocationID INT,
    DateModified DATETIME DEFAULT GETDATE(),
    ActionTaken VARCHAR(50)
);


GO
CREATE TRIGGER RPG.AfterPlayerUpdateOrDelete
ON RPG.Players
AFTER UPDATE
AS
BEGIN
    INSERT INTO RPG.PlayerHistory(PlayerID, [Name], Class, [Level], RegistrationDate, LocationID, DateModified, ActionTaken)
    SELECT d.PlayerID, d.Name, d.Class, d.[Level], d.RegistrationDate, d.LocationID, GETDATE(), 'UPDATE'
    FROM deleted d;
END;
GO
CREATE TRIGGER RPG.AfterPlayerDelete
ON RPG.Players
AFTER DELETE
AS
BEGIN
    INSERT INTO RPG.PlayerHistory(PlayerID, [Name], Class, [Level], RegistrationDate, LocationID, DateModified, ActionTaken)
    SELECT d.PlayerID, d.Name, d.Class, d.[Level], d.RegistrationDate, d.LocationID, GETDATE(), 'DELETE'
    FROM deleted d;
END;
GO
-- API LOGIN
-- run on master
CREATE LOGIN RPG_Web_API WITH PASSWORD = 'abc@1234';
-- RUN on the database
CREATE USER RPG_Web_API
FROM LOGIN RPG_Web_API
GO
REVOKE EXECUTE TO RPG_Web_API;
REVOKE SELECT, INSERT, UPDATE, DELETE ON SCHEMA::RPG TO RPG_Web_API;
GRANT SELECT ON SCHEMA::RPG TO RPG_Web_API;
GRANT SELECT ON RPG.Players TO RPG_Web_API;
GRANT EXECUTE TO RPG_Web_API;
-- PROCEDURES
GO
CREATE PROCEDURE RPG.GetPlayerQuests
    @PlayerID INT
AS
BEGIN
    SELECT 
        q.QuestID, 
        q.Name AS QuestName, 
        q.EXP, 
        pq.Completion
    FROM 
        RPG.Player_Quests pq
    JOIN 
        RPG.Quests q ON pq.QuestID = q.QuestID
    WHERE 
        pq.PlayerID = @PlayerID;
END;
GO
CREATE PROCEDURE RPG.GetPlayerItems
    @PlayerID INT
AS
BEGIN
    SELECT 
        i.ItemID, 
        i.Name AS ItemName, 
        i.Quantity
    FROM 
        RPG.Items i
    WHERE 
        i.PlayerID = @PlayerID;
END;

GO
CREATE PROCEDURE RPG.GetQuestLocations
    @QuestID INT
AS
BEGIN
    SELECT 
        l.LocationID, 
        l.Name AS LocationName, 
        l.Weather, 
        l.EncounterLevel
    FROM 
        RPG.Locations l
    WHERE 
        l.QuestID = @QuestID;
END;
GO
CREATE PROCEDURE RPG.GetPlayerQuestItems
    @PlayerID INT
AS
BEGIN
    SELECT 
        p.PlayerID, 
        p.Name AS PlayerName,
        q.QuestID,
        q.Name AS QuestName,
        i.ItemID,
        i.Name AS ItemName,
        i.Quantity
    FROM 
        RPG.Players p
    JOIN 
        RPG.Player_Quests pq ON p.PlayerID = pq.PlayerID
    JOIN 
        RPG.Quests q ON pq.QuestID = q.QuestID
    LEFT JOIN 
        RPG.Items i ON q.QuestID = i.QuestID
    WHERE 
        p.PlayerID = @PlayerID;
END;
GO

