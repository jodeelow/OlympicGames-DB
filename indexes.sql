USE OlympicGames

ALTER TABLE Teams
ADD TeamRank INT CONSTRAINT CK_Teams_TeamRank UNIQUE

insert into Teams(TeamName, TeamRank)
values('Argentinian Men''s Olympic Football Team', 7), ('USA Tennis Double(Mike & Bob Bryan)', 2), ('Portugal Men''s Olympic Football Team', 1)

DROP PROCEDURE IF EXISTS addTeams
GO

CREATE PROCEDURE addTeams(@number INT)
AS
	BEGIN

		DELETE FROM Teams

		DECLARE @insertSql VARCHAR(100)
		SET @insertSql = 'INSERT INTO Teams(TeamName, TeamRank) VALUES(''a'', ' 
		DECLARE @sql VARCHAR(100)

		WHILE @number > 0
		BEGIN
			SET @sql = @insertSql + CAST(@number AS VARCHAR(100)) + ')'
			EXEC(@sql)
			SET @number = @number - 1
		END
	END
GO

EXECUTE addTeams 100

--a)

--clustered index with Search Key TeamId

--clustered index scan(all rows)
SELECT * 
FROM Teams
ORDER BY TeamId

--clustered index seek(rows that match the '=' selection)
SELECT * 
FROM Teams
WHERE TeamId = 2

--create non-clustered index on TeamRank
--DROP INDEX IF EXISTS IX_Teams_TeamRank ON Teams
CREATE NONCLUSTERED INDEX IX_Teams_TeamRank
ON Teams(TeamRank)

--non-clustered index scan
SELECT TeamRank
FROM Teams
ORDER BY TeamRank

--non-clustered index seek
SELECT TeamRank
FROM Teams
WHERE TeamRank = 1

--key lookup --> query on Search Key from non_clustered index(TeamRank), select additional field
--looks up for fields that are not in non-clustered index
SELECT *
FROM Teams
WHERE TeamRank = 1

--b) work with Countries
DROP PROCEDURE IF EXISTS addCountries
GO

--add new value every 20 records
CREATE PROCEDURE addCountries(@number INT)
AS
	BEGIN

		DELETE FROM Countries

		DECLARE @insertSql VARCHAR(100)
		SET @insertSql = 'INSERT INTO Countries(CountryName, Continent, NumberOfWinningCampaigns) VALUES(''a'', ''b'', ' 
		DECLARE @sql VARCHAR(100)
		DECLARE @i INT
		SET @i = 1
		DECLARE @value INT
		SET @value = 1

		WHILE @number > 0
		BEGIN
			SET @sql = @insertSql + CAST(@value AS VARCHAR(100)) + ')'
			EXEC(@sql)
			SET @number = @number - 1
			SET @i = @i + 1

			IF @i % 20 = 1 AND @i != 1
			BEGIN
				SET @value = @value + 1
			END
		END
	END
GO

EXECUTE addCountries 100

--performs a clustered index scan
--0.003392(estimated subtree cost)
DROP INDEX IF EXISTS IX_Countries_NumberOfWinningCampaigns ON Countries

SELECT CountryName, NumberOfWinningCampaigns
FROM Countries
WHERE NumberOfWinningCampaigns = 2

--create non-clustered index on (NumberOfWinningCampaigns, CountryName) to avoid lookups
DROP INDEX IF EXISTS IX_Countries_NumberOfWinningCampaigns ON Countries
CREATE NONCLUSTERED INDEX IX_Countries_NumberOfWinningCampaigns ON Countries(NumberOfWinningCampaigns, CountryName)

--do it again with index
--performs a non-clustered index seek
--0.003304(estimated subtree cost)
SELECT CountryName, NumberOfWinningCampaigns
FROM Countries
WHERE NumberOfWinningCampaigns = 2

--c)
DROP PROCEDURE IF EXISTS addAthletes
GO

CREATE OR ALTER PROCEDURE addAthletes(@number INT)
AS
BEGIN
    DELETE FROM Athletes

    DECLARE @insertSql VARCHAR(200)
    SET @insertSql = 'INSERT INTO Athletes(AthleteName, AthleteDateOfBirth, AthleteGender, SportId, CountryId, TeamId) 
                      VALUES(''a'', ''' + CAST(CAST(GETDATE() AS DATE) AS VARCHAR(10)) + ''', ''M'', 1, '

    DECLARE @sql VARCHAR(200)
    DECLARE @i INT = 1
    DECLARE @value INT = 1

    WHILE @number > 0
    BEGIN
        SET @sql = @insertSql + CAST(@value AS VARCHAR(10)) + ', ' + CAST(@value AS VARCHAR(10)) + ')'

        EXEC(@sql);

        SET @number = @number - 1
        SET @i = @i + 1

        IF @i % 20 = 1 AND @i != 1
        BEGIN
            SET @value = @value + 1
        END
    END
END
GO

insert into SportsTypes(SportTypeName)
values('Ball Sport')

insert into Sports(SportName, SportTypeId)
values('Football', 1)

EXECUTE addAthletes 100

DROP VIEW IF EXISTS AthletesView
GO

CREATE OR ALTER VIEW AthletesView
AS
	SELECT A.AthleteName, T.TeamName, C.CountryName
	FROM Athletes A
	INNER JOIN (
		SELECT TOP 20 *
		FROM Teams
		ORDER BY TeamRank DESC
	) T ON A.TeamId = T.TeamId
	INNER JOIN (
		SELECT CountryId, CountryName, NumberOfWinningCampaigns
		FROM Countries
		WHERE NumberOfWinningCampaigns = 1
	) C ON A.CountryId = C.CountryId

GO

--for Teams it is performed a key lookup => adjust the index(add TeamName column to it)
--DROP INDEX IF EXISTS IX_Teams_TeamRank ON Teams

--in this case the index will be sorted in terms of TeamName too
--CREATE NONCLUSTERED INDEX IX_Teams_TeamRank ON Teams(TeamRank, TeamName)

--here the index will be sorted only in terms of TeamRank(TeamName will be included too to avoid lookups) 
CREATE NONCLUSTERED INDEX IX_Teams_TeamRank ON Teams(TeamRank)
INCLUDE (TeamName)

SELECT * FROM AthletesView
