--****PLEASE ENTER YOUR DETAILS BELOW****
--T4-rm-alter.sql

--Student ID: 32229070
--Student Name: SENG WEI HAN 
--Unit Code: FIT3171
--Applied Class No: TUTORIAL 7

/* Comments for your marker:




*/

--4(a)

ALTER TABLE entry ADD entry_elapsed_time NUMBER(6,2);

COMMENT ON COLUMN entry.entry_elapsed_time IS 'runner''s elapsed time in an event';

UPDATE entry
SET
    entry_elapsed_time = ROUND((entry_finishtime - entry_starttime) * 1440,2);

COMMIT;
--4(b)


DROP TABLE team_charity CASCADE CONSTRAINTS;

CREATE TABLE team_charity (
    char_id                 NUMBER(3) NOT NULL,
    team_id                 NUMBER(3) NOT NULL,
    team_charity_percentage NUMBER(3) NOT NULL
);

Comment ON COLUMN team_charity.char_id IS 
    'Charity unique identifier';
    
COMMENT ON COLUMN team_charity.team_id IS
    'Team identifier (unique)';

COMMENT ON COLUMN team_charity.team_charity_percentage IS
    'Percentage (0 to 100) of total raised funds that goes to each charity';
    
ALTER TABLE team_charity ADD CONSTRAINT team_charity_pk PRIMARY KEY ( char_id,
                                                                      team_id );
                                                                    

ALTER TABLE team_charity
    ADD CONSTRAINT charity_team_charity_fk FOREIGN KEY ( char_id )
        REFERENCES charity ( char_id );

ALTER TABLE team_charity
    ADD CONSTRAINT team_team_charity_fk FOREIGN KEY ( team_id )
        REFERENCES team ( team_id );


INSERT INTO team_charity VALUES (
    4,
    1,
    100
);

INSERT INTO team_charity VALUES (
    1,
    2,
    100
);

INSERT INTO team_charity VALUES (
    2,
    3,
    100
);

INSERT INTO team_charity VALUES (
    3,
    4,
    100
);

INSERT INTO team_charity VALUES (
    4,
    5,
    100
);

ALTER TABLE team DROP CONSTRAINT charity_team_fk;

ALTER TABLE team DROP COLUMN char_id;


COMMIT;


     
--4(c)
-- Since the questions stated that the list of roles may be expanded as required
-- meaning to say the list of roles is a look up table hence we will need to 
-- create a table for the roles as lookup table.

DROP TABLE officialrole CASCADE CONSTRAINTS;

CREATE TABLE officialrole (
    officialrole_code NUMBER(3) NOT NULL,
    officialrole_desc VARCHAR2(30) NOT NULL
);

COMMENT ON COLUMN officialrole.officialrole_code IS
    'Code of officialrole (unique identifier)';

COMMENT ON COLUMN officialrole.officialrole_desc IS
    'The description role of official in a carnival';


ALTER TABLE officialrole ADD CONSTRAINT officialrole_pk PRIMARY KEY ( officialrole_code);

ALTER TABLE officialrole ADD CONSTRAINT officialrole_uq UNIQUE (officialrole_desc);


DROP TABLE official CASCADE CONSTRAINTS;

CREATE TABLE official (
    comp_no           NUMBER(5) NOT NULL,
    carn_date         DATE NOT NULL,
    officialrole_code NUMBER(3) NOT NULL
);

COMMENT ON COLUMN official.comp_no IS
    'Unique identifier for a competitor';

COMMENT ON COLUMN official.carn_date IS
    'Date of carnival (unique identifier)';

COMMENT ON COLUMN official.officialrole_code IS 
    'Code of officialrole (unique identifier)';

ALTER TABLE official ADD CONSTRAINT official_pk PRIMARY KEY ( comp_no,
                                                              carn_date );

ALTER TABLE official
    ADD CONSTRAINT competitor_official_fk FOREIGN KEY ( comp_no )
        REFERENCES competitor ( comp_no );
        

ALTER TABLE official
    ADD CONSTRAINT carnival_official_fk FOREIGN KEY ( carn_date )
        REFERENCES carnival ( carn_date );
    

ALTER TABLE official
    ADD CONSTRAINT officialrole_official_fk FOREIGN KEY ( officialrole_code )
        REFERENCES officialrole ( officialrole_code );
    
    

-- POPULATING THE TABLES 
-- INSERT DATA INTO OFFICIALROLE TABLE.
INSERT INTO officialrole VALUES (
    1,
    'time keeper'
);

INSERT INTO officialrole VALUES (
    2,
    'marshal'
);

INSERT INTO officialrole VALUES (
    3,
    'starter'
);

INSERT INTO officialrole VALUES (
    4,
    'first aid'
);


COMMIT;
