GO
CREATE SCHEMA RPG;
GO

CREATE TABLE RPG.PlayerLogin (
    PlayerLoginID INT PRIMARY KEY IDENTITY(1,1),
    UserName VARCHAR(50) NOT NULL,
    Email VARCHAR(25) NOT NULL,
    LoginDate DATETIME,
);

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
    PlayerLoginID INT,
    DateModified DATETIME DEFAULT GETDATE(),
    ActionTaken VARCHAR(50)
);

-- DATA for tables: ChatGPT 4
-- Inserting data into PlayerLogin
INSERT INTO RPG.PlayerLogin (PlayerLoginID, UserName, Email, LoginDate) VALUES
(1, 'PlayerOne', 'playerone@example.com', '2023-01-01 08:00:00'),
(2, 'PlayerTwo', 'playertwo@example.com', '2023-01-02 09:00:00'),
(3, 'PlayerThree', 'playerthree@example.com', '2023-01-03 10:00:00'),
(4, 'PlayerFour', 'playerfour@example.com', '2023-01-04 11:00:00'),
(5, 'PlayerFive', 'playerfive@example.com', '2023-01-05 12:00:00');
SELECT * FROM RPG.PlayerLogin
-- Inserting data into Locations
INSERT INTO RPG.Locations ([Name], Weather, EncounterLevel, QuestID, PlayerID) VALUES
('Forest of Shadows', 'Rainy', 5, NULL, NULL),
('Crystal Caverns', 'Foggy', 10, NULL, NULL),
('Mystic Mountains', 'Snowy', 15, NULL, NULL),
('Sunken City', 'Cloudy', 20, NULL, NULL),
('Desert of Mirages', 'Sunny', 25, NULL, NULL);
SELECT * FROM RPG.Locations
UPDATE RPG.Locations SET QuestID = 5, PlayerID = 5 WHERE LocationID = 5;
-- Inserting data into Players
INSERT INTO RPG.Players ([Name], Class, [Level], RegistrationDate, LocationID) VALUES
('Arthas', 'Warrior', 10, '2023-01-01', 1),
('Luna', 'Mage', 20, '2023-02-01', 2),
('Thorin', 'Ranger', 30, '2023-03-01', 3),
('Arya', 'Assassin', 40, '2023-04-01', 4),
('Zara', 'Cleric', 50, '2023-05-01', 5);
SELECT * FROM RPG.Players
UPDATE RPG.Players SET PlayerName = 'Zara', Class = 'Cleric', PlayerLevel = 50, 
RegistrationDate = '2023-05-01', LocationID = 5, PlayerLoginID = 5
WHERE PlayerID = 5;

UPDATE RPG.Players SET PlayerLoginID = 5 WHERE PlayerID = 5;
INSERT INTO RPG.Players ([Name], Class, [Level], RegistrationDate, LocationID, PlayerLoginID) VALUES (@Name, @Class, @Level, @RegistrationDate, @LocationID, @PlayerLoginID);
SELECT * FROM RPG.Players WHERE PlayerID = 6;
-- Inserting data into Quests
INSERT INTO RPG.Quests ([Name], EXP, LocationID, ItemID) VALUES
('The Lost Sword', 500, 1, NULL),
('Mystic Orb Recovery', 1000, 2, NULL),
('Dragon Slayer', 1500, 3, NULL),
('Underwater Exploration', 2000, 4, NULL),
('The Desert Treasure', 2500, 5, NULL);
SELECT * FROM RPG.Quests
SELECT * FROM RPG.Items
SELECT * FROM RPG.Locations
UPDATE RPG.Quests SET ItemID = 5 WHERE QuestID = 5;
-- Inserting data into Items
INSERT INTO RPG.Items ([Name], Quantity, QuestID, PlayerID) VALUES
('Healing Potion', 10, NULL, 1),
('Magic Sword', 1, 1, NULL),
('Invisibility Cloak', 1, NULL, 2),
('Dragon Armor', 1, 3, NULL),
('Ancient Amulet', 1, 5, NULL);
SELECT * FROM RPG.Items
-- Inserting data into Player_Quests
INSERT INTO RPG.Player_Quests (PlayerID, QuestID, Completion) VALUES
(1, 1, 0),
(2, 2, 0),
(3, 3, 0),
(4, 4, 0),
(5, 5, 0);
-- End Data Insert

GO
CREATE TRIGGER RPG.AfterPlayerUpdate
ON RPG.Players
AFTER UPDATE
AS
BEGIN
    INSERT INTO RPG.PlayerHistory(PlayerID, PlayerName, Class, PlayerLevel, RegistrationDate, LocationID, PlayerLoginID, DateModified, ActionTaken)
    SELECT d.PlayerID, d.PlayerName, d.Class, d.PlayerLevel, d.RegistrationDate, d.LocationID, d.PlayerLoginID, GETDATE(), 'UPDATE'
    FROM deleted d;
END;
GO
CREATE TRIGGER RPG.AfterPlayerDelete
ON RPG.Players
AFTER DELETE
AS
BEGIN
    INSERT INTO RPG.PlayerHistory(PlayerID, PlayerName, Class, PlayerLevel, RegistrationDate, LocationID, PlayerLoginID, DateModified, ActionTaken)
    SELECT d.PlayerID, d.PlayerName, d.Class, d.PlayerLevel, d.RegistrationDate, d.LocationID, d.PlayerLoginID, GETDATE(), 'DELETE'
    FROM deleted d;
END;
GO
SELECT * FROM RPG.PlayerHistory
SELECT * FROM RPG.Players
SELECT * FROM RPG.PlayerLogin
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
GRANT INSERT, UPDATE, DELETE ON RPG.PlayerLogin TO RPG_Web_API;
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
        p.PlayerName AS CharacterName,
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
EXEC RPG.GetPlayerQuestItems @PlayerID = 1;
EXEC RPG.GetQuestLocations @QuestID = 2;
EXEC RPG.GetPlayerItems @PlayerID = 2;
EXEC RPG.GetPlayerQuests @PlayerID = 4;
GO
CREATE INDEX idx_RPG_Email ON RPG.PlayerLogin(Email);
GO
CREATE INDEX idx_RPG_PlayerLogin ON RPG.PlayerLogin(PlayerLoginID);
GO
CREATE INDEX idx_RPG_Player ON RPG.Players(PlayerID);
GO


