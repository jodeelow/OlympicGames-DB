USE OlympicGames;

DROP TABLE IF EXISTS DBVersions;

DROP PROCEDURE IF EXISTS ChangeType_V1
DROP PROCEDURE IF EXISTS Undo_ChangeType_V1
DROP PROCEDURE IF EXISTS AddColumn_V2
DROP PROCEDURE IF EXISTS Undo_AddColumn_V2
DROP PROCEDURE IF EXISTS RemoveConstraint_V3
DROP PROCEDURE IF EXISTS Undo_RemoveConstraint_V3
DROP PROCEDURE IF EXISTS RemovePKey_V4
DROP PROCEDURE IF EXISTS Undo_RemovePKey_V4
DROP PROCEDURE IF EXISTS AddCKey_V5
DROP PROCEDURE IF EXISTS Undo_AddCKey_V5
DROP PROCEDURE IF EXISTS RemoveFKey_V6
DROP PROCEDURE IF EXISTS Undo_RemoveFKey_V6
DROP PROCEDURE IF EXISTS DropTable_V7
DROP PROCEDURE IF EXISTS Undo_DropTable_V7
DROP PROCEDURE IF EXISTS getCurrentVersion
DROP PROCEDURE IF EXISTS getCurrentProcedure
DROP PROCEDURE IF EXISTS main

CREATE TABLE DBVersions
(
	VersionId INT PRIMARY KEY,
	VersionDate DATETIME DEFAULT GETDATE(),  --date and time of modification
	VersionDescription VARCHAR(255)
)
GO

--THE INITIAL DB STATE IS 0!!!
INSERT INTO DBVersions(VersionId, VersionDescription)
VALUES (0, 'Initial version')
GO

--modify the type of column NumberOfWinningCampaigns from table Countries 

CREATE PROCEDURE ChangeType_V1
AS
	BEGIN
		ALTER TABLE Countries
		DROP CONSTRAINT DEF_NumberOfWinningCampaigns
	END
	BEGIN
		ALTER TABLE Countries
		ALTER COLUMN NumberOfWinningCampaigns TINYINT
	END
	BEGIN
		ALTER TABLE Countries
		ADD CONSTRAINT DEF_NumberOfWinningCampaigns DEFAULT 0 FOR NumberOfWinningCampaigns
	END
	BEGIN
		INSERT INTO DBVersions(VersionId, VersionDescription)
		VALUES (1, 'NumberOfWinningCampaigns from Countries: INT -> TINYINT')
	END
GO
--EXECUTE ChangeType_V1

--undo

CREATE PROCEDURE Undo_ChangeType_V1
AS
	BEGIN
		ALTER TABLE Countries
		DROP CONSTRAINT DEF_NumberOfWinningCampaigns
	END
	BEGIN
		ALTER TABLE Countries
		ALTER COLUMN NumberOfWinningCampaigns INT
	END
	BEGIN
		ALTER TABLE Countries
		ADD CONSTRAINT DEF_NumberOfWinningCampaigns DEFAULT 0 FOR NumberOfWinningCampaigns
	END
	BEGIN
		DELETE FROM DBVersions
		WHERE VersionId = 1
	END
GO
--EXECUTE Undo_ChangeType_V1

--add column MedalDescription in table Medals

CREATE PROCEDURE AddColumn_V2
AS
	BEGIN 
		ALTER TABLE Medals
		ADD MedalDescription VARCHAR(100)

		INSERT INTO DBVersions(VersionId, VersionDescription)
		VALUES (2, 'added column MedalDescription in Medals')
	END
GO
--EXECUTE AddColumn_V2

--undo

CREATE PROCEDURE Undo_AddColumn_V2
AS
	BEGIN 
		ALTER TABLE Medals
		DROP COLUMN MedalDescription

		DELETE FROM DBVersions
		WHERE VersionId = 2
	END
GO
--EXECUTE Undo_AddColumn_V2

--remove default constraint of TeamId in Athletes Table

CREATE PROCEDURE RemoveConstraint_V3
AS
	BEGIN
		ALTER TABLE Athletes
		DROP CONSTRAINT DEF_Athletes_TeamId 

		INSERT INTO DBVersions(VersionId, VersionDescription)
		VALUES (3, 'Removed default NULL constraint for TeamId in Athletes table')
	END
GO
--EXECUTE RemoveConstraint_V3

--undo

CREATE PROCEDURE Undo_RemoveConstraint_V3
AS
	BEGIN
		ALTER TABLE Athletes
		ADD CONSTRAINT DEF_Athletes_TeamId DEFAULT NULL FOR TeamId

		DELETE FROM DBVersions
		WHERE VersionId = 3
	END
GO
--EXECUTE Undo_RemoveConstraint_V3

--remove primary key(TeamId) from Teams table

CREATE PROCEDURE RemovePKey_V4
AS
	BEGIN
		ALTER TABLE Athletes
		DROP CONSTRAINT FK_Athletes_TeamId
	END
	BEGIN
		ALTER TABLE Teams
		DROP CONSTRAINT PK_Teams
	END
	BEGIN
		INSERT INTO DBVersions(VersionId, VersionDescription)
		VALUES (4, 'Removed pkey from Teams table')
	END
GO
--EXECUTE RemovePKey_V4

--undo

CREATE PROCEDURE Undo_RemovePKey_V4
AS
	BEGIN
		ALTER TABLE Teams
		ADD CONSTRAINT PK_Teams PRIMARY KEY (TeamId)
	END
	BEGIN
		ALTER TABLE Athletes
		ADD CONSTRAINT FK_Athletes_TeamId FOREIGN KEY (TeamId) REFERENCES Teams(TeamId)
	END
	BEGIN
		DELETE FROM DBVersions
		WHERE VersionId = 4
	END
GO
--EXECUTE Undo_RemovePKey_V4

--add candidate key constraint for SportName in Sports

CREATE PROCEDURE AddCKey_V5
AS
	BEGIN
		ALTER TABLE Sports
		ADD CONSTRAINT CKey_Sports_SportName UNIQUE (SportName)

		INSERT INTO DBVersions(VersionId, VersionDescription)
		VALUES (5, 'Added candidate key constraint for SportName in Sports table')
	END
GO
--EXECUTE AddCKey_V5

--undo

CREATE PROCEDURE Undo_AddCKey_V5
AS
	BEGIN
		ALTER TABLE Sports
		DROP CONSTRAINT CKey_Sports_SportName

		DELETE FROM DBVersions
		WHERE VersionId = 5
	END
GO
--EXECUTE Undo_AddCKey_V5

--remove foreign key constraint for SportTypeId in Sports table

CREATE PROCEDURE RemoveFKey_V6
AS
	BEGIN
		ALTER TABLE Sports
		DROP CONSTRAINT FK_Sports_SportTypeId

		INSERT INTO DBVersions(VersionId, VersionDescription)
		VALUES (6, 'Removed fkey constraint for SportTypeId in Sports table')
	END
GO
--EXECUTE RemoveFKey_V6

--undo

CREATE PROCEDURE Undo_RemoveFKey_V6
AS
	IF NOT EXISTS(
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'Sports'
			AND CONSTRAINT_NAME = 'FK_Sports_SportTypeId'
	)
	BEGIN
		ALTER TABLE Sports
		ADD CONSTRAINT FK_Sports_SportTypeId FOREIGN KEY (SportTypeId) REFERENCES SportsTypes(SportTypeId)
	END
	BEGIN
		DELETE FROM DBVersions
		WHERE VersionId = 6
	END
GO
--EXECUTE RemoveFKey_V6

--drop table SportsTypes
CREATE PROCEDURE DropTable_V7
AS
	IF EXISTS(
		SELECT 1 
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'Sports'
			AND CONSTRAINT_NAME = 'FK_Sports_SportTypeId'
	)
	BEGIN
		ALTER TABLE Sports
		DROP CONSTRAINT FK_Sports_SportTypeId 
	END
	BEGIN
		DROP TABLE SportsTypes

		INSERT INTO DBVersions(VersionId, VersionDescription)
		VALUES (7, 'Dropped table SportsTypes from the DB')
	END
GO
--EXECUTE DropTable_V7
--SELECT * FROM SportsTypes

--undo

CREATE PROCEDURE Undo_DropTable_V7
AS
	IF NOT EXISTS(
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE TABLE_NAME = 'SportsTypes'
	)
	BEGIN
		CREATE TABLE SportsTypes
		(
			SportTypeId INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_SportsTypes_SportTypeId PRIMARY KEY,
			SportTypeName VARCHAR(200)
		)

		INSERT INTO SportsTypes(SportTypeName)
		VALUES ('Ball Sport'), ('Combat Sport'), ('Artistic Sport'), ('Water Sport')
	END
	BEGIN
		ALTER TABLE Sports
		ADD CONSTRAINT FK_Sports_SportTypeId FOREIGN KEY (SportTypeId) REFERENCES SportsTypes(SportTypeId)

		DELETE FROM DBVersions
		WHERE VersionId = 7
	END
GO
--EXECUTE Undo_DropTable_V7
--SELECT * FROM SportsTypes


--SELECT * FROM DBVersions

--creating main procedure for switching versions

--auxiliary proc for selecting the current version
CREATE PROCEDURE getCurrentVersion(@current INT OUTPUT) --output variable
AS
	BEGIN
		SELECT TOP 1 @current = DBV.VersionId
		FROM DBVersions DBV
		GROUP BY DBV.VersionId
		ORDER BY DBV.VersionId DESC
	END
GO
--DECLARE @a INT
--EXECUTE getCurrentVersion @a OUTPUT
--PRINT @a

--auxiliary procedure for getting the procedure that has to be executed
--@version - tells procedure for what version to retrieve
--@option - tells if do or undo
--@currentP - in this we will store the procedure name
--DROP PROCEDURE IF EXISTS getCurrentProcedure
CREATE PROCEDURE getCurrentProcedure(@version INT, @option VARCHAR(200), @currentP VARCHAR(200) OUTPUT)
AS
	IF @option = 'do'
	BEGIN
		SELECT TOP 1 @currentP = name
		FROM sys.procedures
		WHERE name NOT LIKE 'Undo%'
			AND name LIKE '%' + CAST(@version AS VARCHAR(10))
	END

	ELSE IF @option = 'undo'
	BEGIN
		SELECT TOP 1 @currentP = name
		FROM sys.procedures
		WHERE name LIKE 'Undo%'
			AND name LIKE '%' + CAST(@version AS VARCHAR(10))
	END
		
	ELSE
	BEGIN
		RAISERROR('The option must be do/undo!', 16, 2)
		RETURN
	END
GO
--declare @c varchar(200)
--EXECUTE getCurrentProcedure 4, 'undo', @c OUTPUT
--print @c
--go

CREATE PROCEDURE main(@versionNumber INT)
AS
--check if version is valid
	IF @versionNumber < 0 OR @versionNumber > 7
	BEGIN
		RAISERROR('The version must be in the interval [0, 7]!', 16, 1)
		RETURN   --stop the execution
	END
	--store the current version in a variable
	DECLARE @currentVersion INT 
	BEGIN
		EXECUTE getCurrentVersion @currentVersion OUTPUT

		DECLARE @currentProcedure VARCHAR(200)
		DECLARE @i INT

		--if we have to go with the version up
		IF @currentVersion < @versionNumber
		BEGIN
			SET @i = @currentVersion + 1

			WHILE @i <= @versionNumber
			BEGIN
				EXECUTE getCurrentProcedure @i, 'do', @currentProcedure OUTPUT
				EXECUTE @currentProcedure
				SET @i = @i + 1
			END
		END

		--if we have to go with the version down
		ELSE IF @currentVersion > @versionNumber
		BEGIN
			SET @i = @currentVersion

			WHILE @i > @versionNumber
			BEGIN
				EXECUTE getCurrentProcedure @i, 'undo', @currentProcedure OUTPUT
				EXECUTE @currentProcedure
				SET @i = @i - 1
			END
		END

		ELSE
		BEGIN
			PRINT 'The DB is already in version ' + CAST(@versionNumber AS VARCHAR(10)) + '!'
		END
	END

	--PRINT 'GOOD'
GO

--EXECUTE main 0
--SELECT * FROM DBVersions
