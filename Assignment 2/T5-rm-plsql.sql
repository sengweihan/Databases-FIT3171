--****PLEASE ENTER YOUR DETAILS BELOW****
--T5-rm-alter.sql

--Student ID: 32229070
--Student Name: SENG WEI HAN
--Unit Code: FIT3171
--Applied Class No: TUTORIAL 7 

/* Comments for your marker:




*/

--5(a)
CREATE OR REPLACE TRIGGER comp_event_check BEFORE
    INSERT ON entry 
    FOR EACH ROW
DECLARE
    chk_date DATE;
    competitor_event_count NUMBER;
    
BEGIN
    SELECT carn_date INTO chk_date FROM event WHERE event_id = :new.event_id; 
    
    SELECT
    COUNT(*)
INTO competitor_event_count
FROM
         event
    JOIN entry
    ON event.event_id = entry.event_id
WHERE
        comp_no = :new.comp_no
    AND carn_date = chk_date;
    
    IF( competitor_event_count <> 0 ) THEN
    raise_application_error(-20000,'Competitor cannot enroll in multiple events in the same carnival');
    
    ELSE 
        dbms_output.put_line('Record is successfully inserted');
    
    END IF;

END;
/


-- Test Harness for 5(a) --
-- TEST CASE 1
-- BEFORE
SELECT * FROM entry;

-- EXECUTING TRIGGER 
-- FAIL
INSERT INTO entry VALUES (
    2,
    100,
    NULL,
    NULL,
    1,
    NULL,
    3,
    NULL
);

-- AFTER
SELECT * FROM entry;


-- TEST 2 
-- BEFORE 
SELECT * FROM entry;

-- EXECUTING THE TRIGGER
-- SUCCESS
INSERT INTO entry VALUES (
    14,
    100,
    NULL,
    NULL,
    1,
    NULL,
    2,
    NULL
);

-- AFTER 
SELECT * FROM entry;

rollback;
--5(b)

-- ADD TWO NEW ATTRIBUTES IN EVENTTYPE NAMED eventtype_record and eventtype_recordholder.

ALTER TABLE eventtype ADD eventtype_record NUMBER(6,2) ;

ALTER TABLE eventtype ADD eventtype_recordholder NUMBER(5);

COMMENT ON COLUMN eventtype.eventtype_record IS
    'fastest elapsed time for each event type';
    
COMMENT ON COLUMN eventtype.eventtype_recordholder IS
    'competitor (competitor number) who holds the record';
    

CREATE OR REPLACE TRIGGER update_eventtype_trigger BEFORE
    UPDATE OF entry_finishtime ON entry
FOR EACH ROW 

DECLARE 
    elapsedtime   entry.entry_elapsed_time%type;
    eventtypecode eventtype.eventtype_code%type;
    currenttime   eventtype.eventtype_record%type;
    competitor    entry.comp_no%type;

BEGIN

    SELECT eventtype_code INTO eventtypecode FROM event WHERE event_id = :new.event_id;

    
    IF (:new.entry_finishtime IS NOT NULL) THEN
        elapsedtime := ROUND((:new.entry_finishtime - :new.entry_starttime)*1440,2);
    END IF;
    
    IF (:new.entry_finishtime IS NOT NULL) THEN
        competitor := :new.comp_no;
    END IF;
    
   -- Here we are changing the :new value not directly writing to the table
   -- via say an update which would cause a mutating table error
    :new.entry_elapsed_time := elapsedtime;
    
    
    SELECT eventtype_record INTO currenttime FROM eventtype WHERE eventtype_code = eventtypecode;
    
    IF ( currenttime IS NULL ) THEN
    UPDATE eventtype
    SET
        eventtype_record = elapsedtime,
        eventtype_recordholder = competitor
    WHERE
        eventtype_code = eventtypecode;
    
    ELSIF (currenttime IS NOT NULL AND elapsedtime < currenttime) THEN 
        UPDATE eventtype SET eventtype_record = elapsedtime , eventtype_recordholder = competitor
            WHERE eventtype_code = eventtypecode;
    
    END IF;
    
END;
/


-- Test harness for 5(b)
SELECT * FROM entry;

-- FIRST COMPETITOR 
INSERT INTO entry VALUES (
    14,
    4,
    NULL,
    NULL,
    1,
    NULL,
    NULL,
    NULL
);

SELECT * FROM entry;

-- TEST TRIGGER 
-- TEST UPDATE
UPDATE entry SET entry_finishtime = TO_DATE('11:35:30', 'HH24:MI:SS'), entry_starttime = TO_DATE('08:30:10', 'HH24:MI:SS')
WHERE event_id = 14 AND entry_no =4 AND comp_no =1;

select * from entry;

-- SECOND COMPETITOR
INSERT INTO entry VALUES (
    14,
    5,
    NULL,
    NULL,
    3,
    NULL,
    NULL,
    NULL
);

select * from entry;

-- TEST TRIGGER
-- TEST UPDATE
UPDATE entry SET entry_finishtime = TO_DATE('11:10:30', 'HH24:MI:SS'), entry_starttime = TO_DATE('08:30:10', 'HH24:MI:SS')
WHERE event_id = 14 AND entry_no =5 AND comp_no =3;

select * from entry;

rollback;

--5(c)
CREATE OR REPLACE PROCEDURE event_registration(
    in_comp_no        IN NUMBER,
    in_carn_date      IN DATE,
    in_eventtype_desc IN VARCHAR2,
    in_team_name      IN VARCHAR2,
    out_message       OUT VARCHAR2
)AS
    valid_carn_date NUMBER;
    valid_event_name NUMBER;
    valid_team_name NUMBER;
    entryno  NUMBER;
    eventid  NUMBER;

BEGIN 
    SELECT COUNT(*) INTO valid_carn_date FROM carnival WHERE carn_date = in_carn_date;
    
    SELECT COUNT(*) INTO valid_event_name FROM eventtype WHERE eventtype_desc = in_eventtype_desc;
    
    IF ( valid_carn_date = 0 OR valid_event_name =  0 ) THEN 
        out_message := 'carnival date and event name must be valid';
    ELSE 
        SELECT event_id INTO eventid FROM event WHERE carn_date = in_carn_date AND eventtype_code = (SELECT eventtype_code FROM 
        eventtype WHERE eventtype_desc = in_eventtype_desc);
    
        SELECT entry_no INTO entryno FROM entry WHERE event_id = eventid AND comp_no = in_comp_no;
        
       IF (in_team_name IS NOT NULL) THEN 
        SELECT COUNT(*) INTO valid_team_name FROM team WHERE team_name = in_team_name AND carn_date = in_carn_date;
        
        IF ( valid_team_name = 0 ) THEN 
            INSERT INTO team VALUES(
                team_seq.NEXTVAL,
                in_team_name,
                in_carn_date,
                1,
                eventid,
                entryno
                );
                
            out_message := 'A team record has been inserted';
            
        ELSE
            -- update the entry's team id for that competitor into the existing team 
            -- increase the number of the team by 1 since a new competitor had joined the team.
            UPDATE entry SET team_id = (SELECT team_id FROM team WHERE team_name = in_team_name 
            AND carn_date = in_carn_date) WHERE event_id = eventid AND entry_no = entryno;
            
            UPDATE team SET team_no_members = (SELECT team_no_members FROM team WHERE team_name = in_team_name
            AND carn_date = in_carn_date) + 1 WHERE team_name = in_team_name AND carn_date = in_carn_date;
            
            out_message := 'A competitor''s team id has been updated in the entry table as well as number of 
            members in the team table';
            
        END IF ;
    ELSE 
        out_message := 'A team name is not being provided';
        
    END IF;
    
END IF;

END event_registration;
/
           

-- Test Harness for 5(c)

-- INITIAL DATA
SELECT * FROM entry; 

-- INSERT 2 COMPETITOR FOR TESTING PURPOSES
INSERT INTO entry VALUES (
    14,
    7,
    NULL,
    NULL,
    11,
    NULL,
    NULL,
    NULL
);

INSERT INTO entry VALUES (
    14,
    10,
    NULL,
    NULL,
    12,
    NULL,
    NULL,
    NULL
);

select * from entry;

-- EXECUTE PROCEDURE
DECLARE 
    output VARCHAR2(200);
BEGIN
    -- call the procedure with valid carnival date but invalid event type desc;
    -- FAILED 
    event_registration(11,TO_DATE('29/May/2022','DD/MON/YYYY'),'Run Power Rangers','Titans',output);
    dbms_output.put_line(output);
END;
/

-- EXECUTE PROCEDURE
DECLARE 
    output VARCHAR2(200);
BEGIN
    -- call the procedure with valid event name but invalid carnival date;
    -- FAILED 
    event_registration(11,TO_DATE('30/May/2022','DD/MON/YYYY'),'21.1 Km Half Marathon','Titans',output);
    dbms_output.put_line(output);
END;
/

-- EXECUTE PROCEDURE
DECLARE 
    output VARCHAR2(200);
BEGIN
    -- call the procedure with both invalid event name and carnival date;
    -- FAILED 
    event_registration(11,TO_DATE('30/May/2022','DD/MON/YYYY'),'Power Rangers','Titans',output);
    dbms_output.put_line(output);
END;
/

-- EXECUTE PROCEDURE
DECLARE 
    output VARCHAR2(200);
BEGIN
    -- call the procedure with no team name ;
    -- FAILED 
    event_registration(11,TO_DATE('29/May/2022','DD/MON/YYYY'),'21.1 Km Half Marathon',NULL,output);
    dbms_output.put_line(output);
END;
/

-- EXECUTE PROCEDURE
DECLARE 
    output VARCHAR2(200);
BEGIN
    -- call the procedure with a team name but does not exist yet in this carnival ;
    -- PASSED
    event_registration(11,TO_DATE('29/May/2022','DD/MON/YYYY'),'21.1 Km Half Marathon','Databases Runner',output);
    dbms_output.put_line(output);
END;
/

-- EXECUTE PROCEDURE
DECLARE 
    output VARCHAR2(200);
BEGIN
    -- call the procedure with a team name that is exist in this carnival ;
    -- PASSED
    event_registration(12,TO_DATE('29/May/2022','DD/MON/YYYY'),'21.1 Km Half Marathon','Giants',output);
    dbms_output.put_line(output);
END;
/

SELECT * from entry;

rollback;

    
