--****PLEASE ENTER YOUR DETAILS BELOW****
--T3-rm-dm.sql

--Student ID: 32229070
--Student Name: SENG WEI HAN
--Unit Code: FIT3171
--Applied Class No: TUTORIAL 7

/* Comments for your marker:




*/

--3(a)
DROP SEQUENCE competitor_seq;

DROP SEQUENCE team_seq;

CREATE SEQUENCE competitor_seq START WITH 100 INCREMENT BY 1;

CREATE SEQUENCE team_seq START WITH 100 INCREMENT BY 1;



--3(b)
INSERT INTO emercontact VALUES (
    '0476541234',
    'Jack',
    'Kai'
);

INSERT INTO competitor VALUES (
    competitor_seq.NEXTVAL,
    'Daniel',
    'Kai',
    'M',
    TO_DATE('22-Nov-1999', 'dd-Mon-yyyy'),
    'DanielKai@gmail.com',
    'Y',
    '0353603775',
    'P',
    (
        SELECT
            ec_phone
        FROM
            emercontact
        WHERE
                ec_fname = 'Jack'
            AND ec_lname = 'Kai'
    )
);

INSERT INTO competitor VALUES (
    competitor_seq.NEXTVAL,
    'Annabelle',
    'Kai',
    'F',
    TO_DATE('18-May-2000', 'dd-Mon-yyyy'),
    'AnnabelleKai@gmail.com',
    'Y',
    '0882903359',
    'P',
    (
        SELECT
            ec_phone
        FROM
            emercontact
        WHERE
                ec_fname = 'Jack'
            AND ec_lname = 'Kai'
    )
);

INSERT INTO entry VALUES (
    (
        SELECT
            event_id
        FROM
            event
        WHERE
                carn_date = (
                    SELECT
                        carn_date
                    FROM
                        carnival
                    WHERE
                        carn_name = 'RM Autumn Series Caulfield 2022'
                )
            AND eventtype_code = (
                SELECT
                    eventtype_code
                FROM
                    eventtype
                WHERE
                    eventtype_desc = '21.1 Km Half Marathon'
            )
    ),
    (
        SELECT
            MAX(entry_no) + 1
        FROM
            entry
        WHERE
            event_id = (
                SELECT
                    event_id
                FROM
                    event
                WHERE
                        carn_date = (
                            SELECT
                                carn_date
                            FROM
                                carnival
                            WHERE
                                carn_name = 'RM Autumn Series Caulfield 2022'
                        )
                    AND eventtype_code = (
                        SELECT
                            eventtype_code
                        FROM
                            eventtype
                        WHERE
                            eventtype_desc = '21.1 Km Half Marathon'
                    )
            )
    ),
    NULL,
    NULL,
    (
        SELECT
            comp_no
        FROM
            competitor
        WHERE
                comp_fname = 'Daniel'
            AND comp_lname = 'Kai'
            AND comp_unistatus = 'Y'
            AND ec_phone = (
                SELECT
                    ec_phone
                FROM
                    emercontact
                WHERE
                        ec_fname = 'Jack'
                    AND ec_lname = 'Kai'
            )
    ),
    NULL,
    (
        SELECT
            char_id
        FROM
            charity
        WHERE
            char_name = 'Beyond Blue'
    )
);

INSERT INTO entry VALUES (
    (
        SELECT
            event_id
        FROM
            event
        WHERE
                carn_date = (
                    SELECT
                        carn_date
                    FROM
                        carnival
                    WHERE
                        carn_name = 'RM Autumn Series Caulfield 2022'
                )
            AND eventtype_code = (
                SELECT
                    eventtype_code
                FROM
                    eventtype
                WHERE
                    eventtype_desc = '21.1 Km Half Marathon'
            )
    ),
    (
        SELECT
            MAX(entry_no) + 1
        FROM
            entry
        WHERE
            event_id = (
                SELECT
                    event_id
                FROM
                    event
                WHERE
                        carn_date = (
                            SELECT
                                carn_date
                            FROM
                                carnival
                            WHERE
                                carn_name = 'RM Autumn Series Caulfield 2022'
                        )
                    AND eventtype_code = (
                        SELECT
                            eventtype_code
                        FROM
                            eventtype
                        WHERE
                            eventtype_desc = '21.1 Km Half Marathon'
                    )
            )
    ),
    NULL,
    NULL,
    (
        SELECT
            comp_no
        FROM
            competitor
        WHERE
                comp_fname = 'Annabelle'
            AND comp_lname = 'Kai'
            AND comp_unistatus = 'Y'
            AND ec_phone = (
                SELECT
                    ec_phone
                FROM
                    emercontact
                WHERE
                        ec_fname = 'Jack'
                    AND ec_lname = 'Kai'
            )
    ),
    NULL,
    (
        SELECT
            char_id
        FROM
            charity
        WHERE
            char_name = 'Amnesty International'
    )
);

COMMIT;



--3(c)

INSERT INTO team VALUES (
    team_seq.NEXTVAL,
    'Kai Speedstars',
    (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    ),
    1,
 (SELECT
    entry.event_id
FROM
    (
             competitor
        JOIN entry
        ON competitor.comp_no = entry.comp_no
    )
    JOIN event
    ON event.event_id = entry.event_id
WHERE
        comp_fname = 'Annabelle'
    AND comp_lname = 'Kai'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    )),
    (
        SELECT
    entry.entry_no
FROM
    (
             competitor
        JOIN entry
        ON competitor.comp_no = entry.comp_no
    )
    JOIN event
    ON event.event_id = entry.event_id
WHERE
        comp_fname = 'Annabelle'
    AND comp_lname = 'Kai'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    )
    ),
    (
        SELECT
            char_id
        FROM
            charity
        WHERE
            char_name = 'Beyond Blue'
    )
);

UPDATE entry
SET
    team_id = (
        SELECT
            team_id
        FROM
            team
        WHERE
            team_name = 'Kai Speedstars'
    )
WHERE
    event_id = (
        SELECT
    entry.event_id
FROM
    (
             competitor
        JOIN entry
        ON competitor.comp_no = entry.comp_no
    )
    JOIN event
    ON event.event_id = entry.event_id
WHERE
        comp_fname = 'Annabelle'
    AND comp_lname = 'Kai'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    ) 
    ) AND entry_no =(SELECT
    entry.entry_no
FROM
    (
             competitor
        JOIN entry
        ON competitor.comp_no = entry.comp_no
    )
    JOIN event
    ON event.event_id = entry.event_id
WHERE
        comp_fname = 'Annabelle'
    AND comp_lname = 'Kai' AND carn_date = ( SELECT
                      carn_date
                  FROM
                      carnival
                  WHERE
                      carn_name = 'RM Autumn Series Caulfield 2022'));

COMMIT;
--3(d)

UPDATE entry
SET
    event_id = (
        SELECT
            event_id
        FROM
            event
        WHERE
                eventtype_code = (
                    SELECT
                        eventtype_code
                    FROM
                        eventtype
                    WHERE
                        eventtype_desc = '10 Km Run'
                )
            AND carn_date = (
                SELECT
                    carn_date
                FROM
                    carnival
                WHERE
                    carn_name = 'RM Autumn Series Caulfield 2022'
            )
    ),
    entry_no = (
        SELECT
            MAX(entry_no) + 1
        FROM
            entry
        WHERE
            event_id = (
                SELECT
                    event_id
                FROM
                    event
                WHERE
                        eventtype_code = (
                            SELECT
                                eventtype_code
                            FROM
                                eventtype
                            WHERE
                                eventtype_desc = '10 Km Run'
                        )
                    AND carn_date = (
                        SELECT
                            carn_date
                        FROM
                            carnival
                        WHERE
                            carn_name = 'RM Autumn Series Caulfield 2022'
                    )
            )
    ),
    team_id = (
        SELECT
            team_id
        FROM
            team
        WHERE
                team_name = 'Kai Speedstars'
            AND carn_date = (
                SELECT
                    carn_date
                FROM
                    carnival
                WHERE
                    carn_name = 'RM Autumn Series Caulfield 2022'
            )
    )
WHERE
    comp_no = (
        SELECT
    entry.comp_no
FROM
    (
             competitor
        JOIN entry
        ON competitor.comp_no = entry.comp_no
    )
    JOIN event
    ON event.event_id = entry.event_id
WHERE
        comp_fname = 'Daniel'
    AND comp_lname = 'Kai'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    )
    );
    



UPDATE team
SET
    team_no_members = (
        SELECT
            COUNT(team_id)
        FROM
            entry
        WHERE
            team_id = (
                SELECT
                    team_id
                FROM
                    team
                WHERE
                        team_name = 'Kai Speedstars'
                    AND carn_date = (
                        SELECT
                            carn_date
                        FROM
                            carnival
                        WHERE
                            carn_name = 'RM Autumn Series Caulfield 2022'
                    )
            )
    )
WHERE
        team_name = 'Kai Speedstars'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    );

COMMIT;
--3(e)

DELETE FROM entry
WHERE
    comp_no = (
SELECT
    entry.comp_no
FROM
    (
             competitor
        JOIN entry
        ON competitor.comp_no = entry.comp_no
    )
    JOIN event
    ON event.event_id = entry.event_id
WHERE
        comp_fname = 'Daniel'
    AND comp_lname = 'Kai'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    )
    );
    


UPDATE entry
SET
    team_id = NULL,
    char_id = (
        SELECT
            char_id
        FROM
            charity
        WHERE
            char_name = 'Beyond Blue'
    )
WHERE
    comp_no = (
        SELECT
    entry.comp_no
FROM
    (
             competitor
        JOIN entry
        ON competitor.comp_no = entry.comp_no
    )
    JOIN event
    ON event.event_id = entry.event_id
WHERE
        comp_fname = 'Annabelle'
    AND comp_lname = 'Kai'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    )
    );


DELETE FROM team
WHERE
        team_name = 'Kai Speedstars'
    AND carn_date = (
        SELECT
            carn_date
        FROM
            carnival
        WHERE
            carn_name = 'RM Autumn Series Caulfield 2022'
    );
    
COMMIT;
