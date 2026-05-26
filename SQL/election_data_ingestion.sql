=========================================================================

--Creating schema for constituency master table

CREATE TABLE constituency_master (
   ac_number INT PRIMARY KEY,
   constituency VARCHAR,
   district VARCHAR,
   region VARCHAR,
   reserved VARCHAR
)
------------------------------------------------------------------------
--Ingesting csv dataset into postgres database

COPY constituency_master
FROM 'path\constituency_master.csv'
CSV HEADER
DELIMITER ','
NULL ''

=====================================================================================

--Creating table to store 2021 election results

CREATE TABLE tn_2021_election(
  constituency VARCHAR,
  ac_number INT,
  candidate VARCHAR,
  party VARCHAR,
  votes INT,
  turnout NUMERIC(5,2),
  reserved VARCHAR,
  region VARCHAR,
  
  FOREIGN KEY (ac_number)
        REFERENCES constituency_master(ac_number)
		)
------------------------------------------------------------------------
--Ingesting csv dataset into postgres database

COPY tn_2021_election
FROM 'path\tn_2021_results.csv'
CSV HEADER
DELIMITER ','
NULL ''

==========================================================================



--Creating table to store 2026 election results

CREATE TABLE tn_2026_election(
  constituency VARCHAR,
  ac_number INT,
  candidate VARCHAR,
  party VARCHAR,
  votes INT,
  turnout NUMERIC(5,2),
  reserved VARCHAR,
  region VARCHAR,
  
  FOREIGN KEY (ac_number)
        REFERENCES constituency_master(ac_number)
)
------------------------------------------------------------------------
--Ingesting csv dataset into postgres database

COPY tn_2026_election
FROM 'D:\input_files_for_participants_rpc\data\tn_2026_results.csv'
CSV HEADER
DELIMITER ','
NULL ''


============================================================================



--combining both 2021 and 2026 tables into one single table for analytics.
--also normalizing the table by removing constituency, region and reserved.

CREATE TABLE tn_election(
  result_id BIGSERIAL PRIMARY KEY,
  
--adding election_year for easier analytics
    election_year INT NOT NULL,

    ac_number INT NOT NULL,

    candidate VARCHAR(150) NOT NULL,

    party VARCHAR(100) NOT NULL,

    votes INT NOT NULL CHECK (votes >= 0),

    turnout NUMERIC(5,2),

    FOREIGN KEY (ac_number)
        REFERENCES constituency_master(ac_number)
)

--------------------------------------------------------------------------
--inserting 2021 data into the table

INSERT INTO tn_election(
  election_year, ac_number, candidate, party, votes, turnout
)
SELECT 2021, ac_number, candidate, party, votes, turnout 
FROM tn_2021_election

----------------------------------------------------------------------------
--inserting 202 data into the table

INSERT INTO tn_election(
  election_year, ac_number, candidate, party, votes, turnout
)
SELECT 2026, ac_number, candidate, party, votes, turnout 
FROM tn_2026_election

=============================================================================

--Dropping tables

DROP TABLE tn_2021_election
DROP TABLE tn_2026_election

============================================================================


