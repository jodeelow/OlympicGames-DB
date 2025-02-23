use OlympicGames;

drop table if exists Results
drop table if exists Events
drop table if exists Medals
drop table if exists Athletes
drop table if exists Teams
drop table if exists Referees
drop table if exists Coaches
drop table if exists Countries
drop table if exists Sports
drop table if exists SportsTypes


create table SportsTypes
(
	SportTypeId int identity(1, 1) not null constraint PK_SportsTypes_SportTypeId primary key,
	SportTypeName varchar(200)
)

create table Sports
(
	SportId int identity(1, 1) not null primary key,
	SportName varchar(200),
	SportTypeId int constraint FK_Sports_SportTypeId references SportsTypes(SportTypeId) on delete cascade
)

create table Countries
(
	CountryId int identity(1, 1) not null primary key,
	CountryName varchar(200),
	Continent varchar(200),

	--number of editions when the country was in top 3(number of medals)
	NumberOfWinningCampaigns int constraint DEF_NumberOfWinningCampaigns default 0
)

create table Coaches
(
	CoachId int identity(1, 1) not null primary key,
	CoachName varchar(200),
	CoachDateOfBirth date,
	CoachGender char(1) check (CoachGender in ('M', 'F')),
	SportId int references Sports(SportId) on delete cascade,
	CountryId int references Countries(CountryId) on delete cascade
)

create table Referees
(
	RefereeId int identity(1, 1) not null primary key,
	RefereeName varchar(200),
	RefereeDateOfBirth date,
	RefereeGender char(1) check (RefereeGender in ('M', 'F')),

	RefereeStatus varchar(50) default null,

	SportId int references Sports(SportId) on delete cascade,
	CountryId int references Countries(CountryId) on delete cascade
)

create table Teams
(
	TeamId int identity(1, 1) not null constraint PK_Teams primary key,
	TeamName varchar(200),
	-- CountryId int references Countries(CountryId),
)

create table Athletes
(
	AthleteId int identity(1, 1) not null primary key,
	AthleteName varchar(200),
	AthleteDateOfBirth date,
	AthleteGender char(1) check (AthleteGender in ('M', 'F')),
	SportId int references Sports(SportId) on delete cascade,
	CountryId int references Countries(CountryId) on delete cascade,
	TeamId int constraint FK_Athletes_TeamId references Teams(TeamId) on delete cascade constraint DEF_Athletes_TeamId default null
)

--insert into Athletes(AthleteName, AthleteDateOfBirth, AthleteGender, CountryId, TeamId)
--values('Julian Alvarez', '2000-01-31', 'M', 3, 1), ('Goncalo Ramos', '2001-01-20', 'M', 5, 3), ('David Popovici', '2004-09-15', 'M', 1, null)

create table Medals
(
	MedalId int identity(1, 1) not null primary key,
	MedalName varchar(200)
)

create table Events
(
	EventId int identity(1, 1) not null primary key,
	EventName varchar(200),
	EventDate date
)

create table Results
(
    --if the athlete is deleted, the result is deleted too
	AthleteId int references Athletes(AthleteId) on delete cascade,
	EventId int references Events(EventId) on delete cascade,
	primary key(AthleteId, EventId),
	ResultDetails varchar(200) default null,
	MedalId int references Medals(MedalId) on delete cascade
)


--ADDING PART
insert into SportsTypes(SportTypeName)
values('Ball Sport'), ('Combat Sport'), ('Artistic Sport'), ('Water Sport')

insert into Countries(CountryName, Continent, NumberOfWinningCampaigns)
values('Romania', 'Europe', 6), ('Germany', 'Europe', 1), ('Argentina', 'America', 1), ('USA', 'America', 12), ('Portugal', 'Europe', 0), ('France', 'Europe', 3), ('Italy', 'Europe', 2), ('China', 'Asia', 6)

insert into Teams(TeamName)
values('Argentinian Men''s Olympic Football Team'), ('USA Tennis Double(Mike & Bob Bryan)'), ('Portugal Men''s Olympic Football Team')

insert into Medals(MedalName)
values('Gold Medal'), ('Silver Medal'), ('Bronze Medal'), ('Non-podium')
--non-podium is for a win and a loss too(but it was not a decisive match(group stage etc))

insert into Events(EventName, EventDate)
values('Football Group Stage Match(Portugal-Argentina)', '2024-08-15'), ('Swimming 200m Men''s finals(freestyle)', '2024-08-27')
INSERT INTO Events(EventName, EventDate)
VALUES('Swimming 100m Men''s finals(butterfly)', '2024-08-29')

insert into Sports(SportName, SportTypeId)
values('Football', 1), ('Box', 2), ('Gymnastics', 3), ('Swimming', 4), ('Tennis', 1)

--trying to insert a sport with a sport type that doesn't exist
--insert into Sports(SportName, SportTypeId)
--values('Dancing', 15)

insert into Coaches(CoachName, CoachDateOfBirth, CoachGender, SportId, CountryId)
values('Mircea Lucescu', '1945-07-29', 'M', 1, 1), ('Patrick Mouratoglou', '1970-06-08', 'M', 5, 6), ('Adrian Radulescu', '1990-09-24', 'M', 4, 1)

insert into Referees(RefereeName, RefereeDateOfBirth, RefereeGender, SportId, CountryId)
values('Mauro Di Fiore', '1971-03-20', 'M', 2, 7), ('Stephanie Frappart', '1983-12-14', 'F', 1, 6), ('Istvan Kovacs', '1984-09-16', 'M', 1, 1)

insert into Athletes(AthleteName, AthleteDateOfBirth, AthleteGender, SportId, CountryId, TeamId)
values('Julian Alvarez', '2000-01-31', 'M', 1, 3, 1), ('Goncalo Ramos', '2001-01-20', 'M', 1, 5, 3)
insert into Athletes(AthleteName, AthleteDateOfBirth, AthleteGender, SportId, CountryId)
values('David Popovici', '2004-09-15', 'M', 4, 1)
insert into Athletes(AthleteName, AthleteDateOfBirth, AthleteGender, SportId, CountryId)
values('Pan Zhalne', '1998-03-03', 'M', 4, 8)

insert into Results(AthleteId, EventId, ResultDetails, MedalId)
values(2, 1, 'Winner-Portugal', 4), (3, 2, 'Winner-David Popovici', 1)
INSERT INTO Results(AthleteId, EventId, ResultDetails, MedalId)
VALUES(3, 3, 'David was close', 3), (4, 3, 'Pan won the gold medal', 1)

--UPDATING PART

--update the results details by adding an '!' for the results ending with podium
update Results
set ResultDetails = ResultDetails + '!'
where MedalId in (1, 2) or MedalId = 3

--update the referee status to 'Expert' for Istvan Kovacs and Stephanie Frappart(they have to be older than 39)
update Referees
set Refereestatus = 'Expert'
where RefereeDateOfBirth <= '1985-01-01' and (RefereeName = 'Istvan Kovacs' or RefereeName = 'Stephanie Frappart')

--increment the number of winning campaings for countries which end in "a"
update Countries 
set NumberOfWinningCampaigns = NumberOfWinningCampaigns + 1
where CountryName like '%a' or CountryName like '%A'


-- DELETING PART

--delete the athletes which don't belong to any team
delete from Athletes
where TeamId is null

--delete the events from 15 to 20 august 2024 because they were rigged
delete from Events
where EventDate between '2024-08-15' and '2024-08-20'


--SELECT PART

--a) UNION
--display the athlete name and the medal name received for atheletes that got gold or silver medals
--OR
SELECT A.AthleteName, M.MedalName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId AND R.MedalId = M.MedalId
	AND (M.MedalName = 'Gold Medal' OR M.MedalName = 'Silver Medal')

--UNION
SELECT A.AthleteName, M.MedalName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId AND R.MedalId = M.MedalId
	AND M.MedalName = 'Gold Medal'
UNION
SELECT A.AthleteName, M.MedalName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId AND R.MedalId = M.MedalId
	AND M.MedalName = 'Silver Medal'


--b) INTERSECTION
--display the athlete name for athletes who won both gold and bronze medals

--INTERSECT
SELECT A.AthleteName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId
	AND R.MedalId = M.MedalId
	AND M.MedalName = 'Gold Medal'
INTERSECT
SELECT A.AthleteName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId
	AND R.MedalId = M.MedalId
	AND M.MedalName = 'Bronze Medal'

--IN
--choose first the ones with gold medals, if they can be found in the set with 
--ones that got bronze medals ===> they have both
SELECT A.AthleteName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId
	AND R.MedalId = M.MedalId
	AND M.MedalName = 'Gold Medal'
	AND A.AthleteName IN (SELECT A2.AthleteName
						  FROM Athletes A2, Results R2, Medals M2
						  WHERE A2.AthleteId = R2.AthleteId 
						      AND R2.MedalId = M2.MedalId
						      AND M2.MedalName = 'Bronze Medal')

--c) DIFFERENCE
--display the athlete name for athletes who did't finish any event 
--in top 3(only non-podium "medals" from group stages or something)

--EXCEPT
SELECT A.AthleteName 
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId
	AND R.MedalId = M.MedalId
	AND NOT M.MedalName != 'Non-podium'  --==(AND M.MedalName = 'Non-podium')
EXCEPT
SELECT A2.AthleteName
FROM Athletes A2, Results R2, Medals M2
WHERE A2.AthleteId = R2.AthleteId
	AND R2.MedalId = M2.MedalId
	AND M2.MedalName IN ('Gold Medal', 'Silver Medal', 'Bronze Medal')


--NOT IN
SELECT A.AthleteName 
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId
	AND R.MedalId = M.MedalId
	AND NOT M.MedalName != 'Non-podium'   --M.MedalName = 'Non-podium'
	AND A.AthleteName NOT IN (SELECT A2.AthleteName
							  FROM Athletes A2, Results R2, Medals M2
							  WHERE A2.AthleteId = R2.AthleteId
							      AND R2.MedalId = M2.MedalId
								  AND M2.MedalName IN ('Gold Medal', 'Silver Medal', 'Bronze Medal'))

--d) INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN 
--INNER JOIN
--display the names and age(+1) (-> ONCE) of coaches from Romania which are not tennis coaches
--top 10 oldest coaches
SELECT DISTINCT TOP 10 C.CoachName, DATEDIFF(YEAR, C.CoachDateOfBirth, '2024-11-03') + 1 as Age
FROM Coaches C INNER JOIN Countries Co ON C.CountryId = Co.CountryId
	INNER JOIN Sports S ON (C.SportId = S.SportId AND NOT S.SportName = 'Tennis')
WHERE Co.CountryName = 'Romania'
ORDER BY Age DESC

--LEFT OUTER JOIN
--many to many relationships: Countries - Sports, Countries - Teams
--display the names, the ages(+1), sports names, the atheletes names, teams(corresponding to athlete + coach), 
--country(corresponding to athlete + coach + team)(-> ONCE) of Romanian coaches
--who trained athletes in a team or not
--top 5 youngest coaches
SELECT DISTINCT TOP 5 C.CoachName, 
    DATEDIFF(YEAR, C.CoachDateOfBirth, '2024-11-03') + 1 AS Age, 
    S.SportName, 
    A.AthleteName, 
    T.TeamName, 
    Co.CountryName
FROM Coaches C LEFT OUTER JOIN Sports S ON C.SportId = S.SportId
	LEFT OUTER JOIN Athletes A ON A.SportId = S.SportId AND A.CountryId = C.CountryId
	LEFT OUTER JOIN Teams T ON T.TeamId = A.TeamId
	LEFT OUTER JOIN Countries Co ON Co.CountryId = C.CountryId 
WHERE C.CountryId IN (SELECT Cou.CountryId
					  FROM Countries Cou
					  WHERE Cou.CountryName = 'Romania')
ORDER BY Age ASC


--RIGHT OUTER JOIN
--display the sport type name, sport name, and referee name for every sport type(include the sport types with no referee too)
SELECT DISTINCT ST.SportTypeName, S.SportName, R.RefereeName
FROM Referees R RIGHT OUTER JOIN Sports S ON R.SportId = S.SportId
	RIGHT OUTER JOIN SportsTypes ST ON S.SportTypeId = ST.SportTypeId

--FULL OUTER JOIN
--display the coach name and the sport name associated to the coach for all coaches
--include coaches with no country, countries with no coach, coaches with no sport, sports with no coach
SELECT C.CoachName, S.SportName
FROM Coaches C FULL OUTER JOIN Countries Co ON C.CountryId = Co.CountryId
	FULL OUTER JOIN Sports S ON C.SportId = S.SportId

--e) 
--WHERE ... IN (subquery)
--display the athlete name and the medal name received for atheletes that got gold or silver medals
SELECT A.AthleteName, M.MedalName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId 
    AND R.MedalId = M.MedalId
	AND M.MedalId IN (SELECT M2.MedalId
					  FROM Medals M2
					  WHERE (M2.MedalName = 'Gold Medal' OR M2.MedalName = 'Silver Medal'))

--WHERE ... IN (subquery in subquery)
--display the athlete name and the medal name received for atheletes that got gold or silver medals
SELECT A.AthleteName, M.MedalName
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId 
    AND R.MedalId = M.MedalId
	AND M.MedalId IN (SELECT M2.MedalId
					  FROM Medals M2
					  WHERE M2.MedalName IN (SELECT M3.MedalName
											 FROM Medals M3
											 WHERE M3.MedalName IN ('Gold Medal', 'Silver Medal')))

--f)
--EXISTS
--display the athlete name and the medal name received for atheletes that got gold or silver medals
SELECT A.AthleteName, M.MedalName 
FROM Athletes A, Results R, Medals M
WHERE A.AthleteId = R.AthleteId
	AND R.MedalId = M.MedalId
	AND EXISTS (SELECT 1
				FROM Medals M2
				WHERE M.MedalId = M2.MedalId
					AND M2.MedalName IN ('Gold Medal', 'Silver Medal'))

--display the referees (and their corresponding sport) which are specialized in a sport of type 'Ball Sport'
SELECT R.RefereeName, S.SportName
FROM Referees R, Sports S, SportsTypes ST
WHERE R.SportId = S.SportId 
	AND S.SportTypeId = ST.SportTypeId
	AND EXISTS (SELECT 1
				FROM SportsTypes ST2
				WHERE ST.SportTypeId = ST2.SportTypeId
				AND ST2.SportTypeName = 'Ball Sport')


--g)
--subquery in the FROM clause
--display the athlete name and the medal name received for atheletes that got gold or silver medals

--put in cross product only the gold and silver medals--
SELECT A.AthleteName, M2.MedalName
FROM Athletes A, Results R, (SELECT *
							 FROM Medals M
							 WHERE M.MedalName IN ('Gold Medal', 'Silver Medal')) M2
WHERE A.AthleteId = R.AthleteId
	AND R.MedalId = M2.MedalId


--display the oldest football coach who is not from France
SELECT DISTINCT TOP 1 C2.CoachName, C2.Age
FROM (SELECT *, DATEDIFF(YEAR, C.CoachDateOfBirth, '2024-11-03') AS Age
	  FROM Coaches C
	  ) C2, Countries Co, (SELECT *
						   FROM Sports S
						   WHERE S.SportName = 'Football') S2
WHERE C2.CountryId = Co.CountryId 
	AND C2.SportId = S2.SportId
	AND NOT Co.CountryName = 'France'
ORDER BY C2.Age DESC


--h)
--GROUP BY

--GROUP BY + HAVING subquery + COUNT
--display the leaderboard of countries based on medals(gold/silver/bronze) won by all athletes
--excluding USA because we know that they had the most
--make sure Romania has at least 2 medals, if not don't display the leaderboard
SELECT Co.CountryName, COUNT(M.MedalName) AS NumberOfMedals
FROM Countries Co, Athletes A, Results R, Medals M
WHERE Co.CountryId = A.CountryId
	AND A.AthleteId = R.AthleteId
	AND R.MedalId = M.MedalId
	AND Co.CountryName != 'USA'
	AND M.MedalName NOT IN ('Non-podium')
GROUP BY Co.CountryName
HAVING COUNT(M.MedalId) > 0
	AND (SELECT COUNT(M2.MedalName)
		 FROM Countries Co2, Athletes A2, Results R2, Medals M2
		 WHERE Co2.CountryId = A2.CountryId
			 AND A2.AthleteId = R2.AthleteId
			 AND R2.MedalId = M2.MedalId
			 AND Co2.CountryName = 'Romania'
			 AND M2.MedalName NOT IN ('Non-podium')) > 1
ORDER BY NumberOfMedals DESC


--GROUP BY + HAVING subquery + SUM
--display the countries with a total number of winning campaigns greater than the average number of winning campaigns
SELECT Co.CountryName, SUM(Co.NumberOfWinningCampaigns) AS TotalNumber
FROM Countries Co
GROUP BY Co.CountryName
HAVING SUM(Co.NumberOfWinningCampaigns) > (SELECT AVG(Co2.NumberOfWinningCampaigns)
										   FROM Countries Co2)



--GROUP BY + HAVING + MIN
--display the countries with a total number of winning campaigns greater than the minimum number of winning campaigns
SELECT Co.CountryName, SUM(Co.NumberOfWinningCampaigns) AS TotalNumber
FROM Countries Co
GROUP BY Co.CountryName
HAVING SUM(Co.NumberOfWinningCampaigns) > (SELECT MIN(Co2.NumberOfWinningCampaigns)
										   FROM Countries Co2)

--GROUP BY + HAVING + MAX
--display the countries with a total number of winning campaigns greater than 5 and lower than the max number of winning campaigns
SELECT Co.CountryName, SUM(Co.NumberOfWinningCampaigns) AS TotalNumber
FROM Countries Co
GROUP BY Co.CountryName
HAVING SUM(Co.NumberOfWinningCampaigns) > 5
	AND SUM(Co.NumberOfWinningCampaigns) < (SELECT MAX(Co2.NumberOfWinningCampaigns)
											FROM Countries Co2)


--i)
--ANY and ALL to introduce subquery in WHERE clause
--rewrite 2 of them with aggregation operators
--rewrite 2 of them with IN/NOT IN

--ANY
--display all countries which have the number of winning campaigns
--smaller than any country which ends with 'y'/'Y'
SELECT Co.CountryName, Co.NumberOfWinningCampaigns
FROM Countries Co
WHERE Co.NumberOfWinningCampaigns < ANY (SELECT Co2.NumberOfWinningCampaigns
									     FROM Countries Co2
									     WHERE Co2.CountryName LIKE '%y' OR Co2.CountryName LIKE '%Y')


--ALL
--display all countries which have the number of winning campaigns
--smaller than all countries which end with 'y'/'Y'
SELECT Co.CountryName, Co.NumberOfWinningCampaigns
FROM Countries Co
WHERE Co.NumberOfWinningCampaigns < ALL (SELECT Co2.NumberOfWinningCampaigns
									     FROM Countries Co2
									     WHERE Co2.CountryName LIKE '%y' OR Co2.CountryName LIKE '%Y')


--ANY
--display all coaches which are older than any male referee
--SELECT C.CoachName, DATEDIFF(YEAR, C.CoachDateOfBirth, '2024-11-03') AS Age
--FROM Coaches C
--WHERE DATEDIFF(YEAR, C.CoachDateOfBirth, '2024-11-03') > ANY (SELECT DATEDIFF(YEAR, R.RefereeDateOfBirth, '2024-11-03') AS Age2
--															  FROM Referees R
--															  WHERE R.RefereeGender = 'M')

--ALL
--display all coaches which are older than all male referees
--SELECT C.CoachName, DATEDIFF(YEAR, C.CoachDateOfBirth, '2024-11-03') AS Age
--FROM Coaches C
--WHERE DATEDIFF(YEAR, C.CoachDateOfBirth, '2024-11-03') > ALL (SELECT DATEDIFF(YEAR, R.RefereeDateOfBirth, '2024-11-03') AS Age2
--															  FROM Referees R
--															  WHERE R.RefereeGender = 'M')
 

--MAX
--display all countries which have the number of winning campaigns
--smaller than any country which ends with 'y'/'Y'
SELECT Co.CountryName, Co.NumberOfWinningCampaigns
FROM Countries Co
WHERE Co.NumberOfWinningCampaigns < (SELECT MAX(Co2.NumberOfWinningCampaigns)
									 FROM Countries Co2
									 WHERE Co2.CountryName LIKE '%y' OR Co2.CountryName LIKE '%Y')


--MIN
--display all countries which have the number of winning campaigns
--smaller than all countries which end with 'y'/'Y'
SELECT Co.CountryName, Co.NumberOfWinningCampaigns
FROM Countries Co
WHERE Co.NumberOfWinningCampaigns < (SELECT MIN(Co2.NumberOfWinningCampaigns)
									 FROM Countries Co2
									 WHERE Co2.CountryName LIKE '%y' OR Co2.CountryName LIKE '%Y')



--ANY
--display all countries which are part of a continent ending in 'a'
SELECT Co.CountryName, Co.Continent
FROM Countries Co
WHERE Co.Continent = ANY (SELECT Co2.Continent
						  FROM Countries Co2
						  WHERE Co2.Continent LIKE '%a')

--ALL
--display all countries which are part of a continent that doesn't end in 'a'
SELECT Co.CountryName, Co.Continent
FROM Countries Co
WHERE Co.Continent <> ALL (SELECT Co2.Continent
						   FROM Countries Co2
						   WHERE Co2.Continent LIKE '%a')

--IN
--display all countries which are part of a continent ending in 'a'
SELECT Co.CountryName, Co.Continent
FROM Countries Co
WHERE Co.Continent IN (SELECT Co2.Continent
					   FROM Countries Co2
					   WHERE Co2.Continent LIKE '%a')

--NOT IN
--display all countries which are part of a continent that doesn't end in 'a'
SELECT Co.CountryName, Co.Continent
FROM Countries Co
WHERE Co.Continent NOT IN (SELECT Co2.Continent
						   FROM Countries Co2
						   WHERE Co2.Continent LIKE '%a')



-- select * from SportsTypes
-- select * from Sports
-- select * from Coaches
-- select * from Referees
-- select * from Teams
-- select * from Countries
-- select * from Athletes
-- select * from Results
-- select * from Medals
-- select * from Events

-- select s.SportName, st.SportTypeName from Sports s join SportsTypes st on s.SportTypeId = st.SportTypeId

-- select t.TeamName, c.CountryName, s.SportName from Teams t join Countries c on t.CountryId = c.CountryId join Sports s on t.SportId = s.SportId

-- select s.SportId, s.SportName, st.SportTypeName from Sports s join SportsTypes st on s.SportTypeId = st.SportTypeId

