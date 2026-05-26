--1.) QUERY TO FIND OUT PARTIES AND SEATS WON IN EACH REGION IN 2021 AND 2026,
--AND DIFFERENCE IN SEATS WON
CREATE MATERIALIZED VIEW primary_parties_and_seats_won_region_wise AS

WITH constituency_winners AS (
    SELECT
        te.election_year,
        te.ac_number,
        cm.region,
        te.party,
        te.votes,
        
        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn
        
    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (
    SELECT
        election_year,
        region,
        party
    FROM constituency_winners
    WHERE rn = 1
),

regional_party_seats AS (
    SELECT
        region,
        party,
        
        COUNT(*) FILTER (
            WHERE election_year = 2021
        ) AS seats_won_2021,
        
        COUNT(*) FILTER (
            WHERE election_year = 2026
        ) AS seats_won_2026
        
    FROM winner_rows
    GROUP BY region, party
)

SELECT
    region,
    party,
    seats_won_2021,
    seats_won_2026,
    
    (seats_won_2026 - seats_won_2021)
        AS difference_in_seats,

    ROUND(
        (
            (seats_won_2026 - seats_won_2021)::numeric
            /
            NULLIF(seats_won_2021, 0)
        ) * 100,
        2
    ) AS pct_change

FROM regional_party_seats

WHERE seats_won_2021 > 0
   OR seats_won_2026 > 0

ORDER BY
    region,
    GREATEST(seats_won_2021, seats_won_2026) DESC,
    difference_in_seats DESC;

===============================================================================================================

--2.) QUERY TO FIND OUT DMK'S REGION WISE PERFORMANCE 

CREATE MATERIALIZED VIEW dmk_region_wise_performance AS

WITH constituency_winners AS (
    SELECT
        te.election_year,
        te.ac_number,
        cm.region,
        te.party,
        te.votes,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (
    SELECT
        election_year,
        region,
        party
    FROM constituency_winners
    WHERE rn = 1
)

SELECT
    region,

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'DMK'
    ) AS dmk_won_2021,

    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'DMK'
    ) AS dmk_won_2026,

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'DMK'
    )
    -
    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'DMK'
    ) AS seat_loss

FROM winner_rows

GROUP BY region

ORDER BY seat_loss DESC;

===================================================================================

-- QUERY TO FIND OUT AIADMK'S REGION WISE PERFORMANCE 

CREATE MATERIALIZED VIEW aidmk_region_wise_performance AS

WITH constituency_winners AS (
    SELECT
        te.election_year,
        te.ac_number,
        cm.region,
        te.party,
        te.votes,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (
    SELECT
        election_year,
        region,
        party
    FROM constituency_winners
    WHERE rn = 1
)

SELECT
    region,

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'AIADMK'
    ) AS aiadmk_won_2021,

    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'AIADMK'
    ) AS aiadmk_won_2026,

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'AIADMK'
    )
    -
    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'AIADMK'
    ) AS seat_loss

FROM winner_rows

GROUP BY region

ORDER BY seat_loss DESC;


===========================================================================================

--3.) Which party dominated which region — and did that dominance survive?

WITH constituency_winners AS (
    SELECT
        te.election_year,
        cm.region,
        te.ac_number,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (
    SELECT *
    FROM constituency_winners
    WHERE rn = 1
),

regional_party_seats AS (
    SELECT
        election_year,
        region,
        party,
        COUNT(*) AS seats_won

    FROM winner_rows
    GROUP BY election_year, region, party
),

ranked_parties AS (
    SELECT *,
    
        RANK() OVER (
            PARTITION BY election_year, region
            ORDER BY seats_won DESC
        ) AS party_rank

    FROM regional_party_seats
)

SELECT
    election_year,
    region,
    party AS dominant_party,
    seats_won

FROM ranked_parties
WHERE party_rank = 1

ORDER BY election_year, region;

===============================================================================================

--4) Which region saw the BIGGEST political shift?

WITH constituency_winners AS (
    SELECT
        te.election_year,
        cm.region,
        te.ac_number,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (
    SELECT *
    FROM constituency_winners
    WHERE rn = 1
),

seat_counts AS (
    SELECT
        region,
        party,

        COUNT(*) FILTER (
            WHERE election_year = 2021
        ) AS seats_2021,

        COUNT(*) FILTER (
            WHERE election_year = 2026
        ) AS seats_2026

    FROM winner_rows
    GROUP BY region, party
)

SELECT
    region,

    SUM(
        ABS(seats_2026 - seats_2021)
    ) AS total_seat_shift

FROM seat_counts
GROUP BY region

ORDER BY total_seat_shift DESC;

========================================================================================

5.) Which party gained the MOST ground geographically?

WITH constituency_winners AS (
    SELECT
        te.election_year,
        cm.region,
        te.ac_number,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (
    SELECT *
    FROM constituency_winners
    WHERE rn = 1
),

party_region_counts AS (
    SELECT
        region,
        party,

        COUNT(*) FILTER (
            WHERE election_year = 2021
        ) AS seats_2021,

        COUNT(*) FILTER (
            WHERE election_year = 2026
        ) AS seats_2026

    FROM winner_rows
    GROUP BY region, party
)

SELECT
    party,

    SUM(seats_2026 - seats_2021)
        AS net_statewide_seat_gain

FROM party_region_counts

GROUP BY party

ORDER BY net_statewide_seat_gain DESC;

=================================================================================

--6.) Which constituencies flipped parties between 2021 and 2026?

WITH constituency_winners AS (
    SELECT
        te.election_year,
        te.ac_number,
        cm.constituency,
        cm.region,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (
    SELECT *
    FROM constituency_winners
    WHERE rn = 1
),

party_shift AS (
    SELECT
        w2021.ac_number,
        w2021.constituency,
        w2021.region,

        w2021.party AS winner_2021,
        w2026.party AS winner_2026

    FROM winner_rows w2021

    JOIN winner_rows w2026
        ON w2021.ac_number = w2026.ac_number

    WHERE w2021.election_year = 2021
      AND w2026.election_year = 2026
)

SELECT *
FROM party_shift
WHERE winner_2021 <> winner_2026
ORDER BY region, constituency;

==============================================================================================
--VOTE TRANSFER 1
 WITH regional_election_summary AS (
    SELECT 
        cm.region,
        -- 2021 Vote Aggregations
        SUM(CASE WHEN te.election_year = 2021 AND te.party IN ('DMK', 'INC', 'VCK', 'CPI', 'CPIM') THEN te.votes ELSE 0 END) AS dmk_votes_2021,
        SUM(CASE WHEN te.election_year = 2021 AND te.party IN ('AIADMK', 'PMK', 'BJP', 'TMC') THEN te.votes ELSE 0 END) AS aiadmk_votes_2021,
        
        -- 2026 Vote Aggregations
        SUM(CASE WHEN te.election_year = 2026 AND te.party IN ('DMK', 'INC', 'VCK', 'CPI', 'CPIM') THEN te.votes ELSE 0 END) AS dmk_votes_2026,
        SUM(CASE WHEN te.election_year = 2026 AND te.party IN ('AIADMK', 'BJP', 'PMK') THEN te.votes ELSE 0 END) AS aiadmk_votes_2026,
        
        -- 2026 TVK Performance
        SUM(CASE WHEN te.election_year = 2026 AND te.party = 'TVK' THEN te.votes ELSE 0 END) AS tvk_votes_2026
    FROM constituency_master cm
    LEFT JOIN tn_election te ON cm.ac_number = te.ac_number
    GROUP BY cm.region
),
swing_calculations AS (
    SELECT 
        region,
        dmk_votes_2021,
        dmk_votes_2026,
        (dmk_votes_2026 - dmk_votes_2021) AS dmk_vote_change,
        aiadmk_votes_2021,
        aiadmk_votes_2026,
        (aiadmk_votes_2026 - aiadmk_votes_2021) AS aiadmk_vote_change,
        tvk_votes_2026
    FROM regional_election_summary
)
SELECT 
    region,
    TO_CHAR(dmk_votes_2021, '99,99,999') AS "2021 DMK+ Votes",
    TO_CHAR(dmk_votes_2026, '99,99,999') AS "2026 DMK+ Votes",
    TO_CHAR(dmk_vote_change, 'S99,99,999') AS "DMK Vote Change",
    TO_CHAR(aiadmk_votes_2021, '99,99,999') AS "2021 AIADMK+ Votes",
    TO_CHAR(aiadmk_votes_2026, '99,99,999') AS "2026 AIADMK+ Votes",
    TO_CHAR(aiadmk_vote_change, 'S99,99,999') AS "AIADMK Vote Change",
    TO_CHAR(tvk_votes_2026, '99,99,999') AS "2026 TVK Total Votes",
    CASE 
        WHEN tvk_votes_2026 = 0 THEN 'No TVK Presence'
        WHEN dmk_vote_change < 0 AND aiadmk_vote_change < 0 THEN
            CASE WHEN ABS(dmk_vote_change) > ABS(aiadmk_vote_change) THEN ' DMK Heavy Drain' ELSE ' AIADMK Heavy Drain' END
        WHEN dmk_vote_change < 0 AND aiadmk_vote_change >= 0 THEN ' Pure DMK Drain'
        WHEN aiadmk_vote_change < 0 AND dmk_vote_change >= 0 THEN ' Pure AIADMK Drain'
        ELSE ' Complex Shift / Others'
    END AS "Primary Source of TVK Growth"
FROM swing_calculations
ORDER BY tvk_votes_2026 DESC;


====================================================================================================

--VOTE TRANSFER 2

WITH regional_vote_summary AS (

    SELECT
        cm.region,
        te.election_year,

        -- Total Votes
        SUM(te.votes) AS total_votes,

        -- DMK Bloc Votes
        SUM(
            CASE
                WHEN te.party IN ('DMK', 'INC', 'VCK', 'CPI', 'CPIM')
                THEN te.votes
                ELSE 0
            END
        ) AS dmk_bloc_votes,

        -- AIADMK Bloc Votes
        SUM(
            CASE
                WHEN te.party IN ('AIADMK', 'PMK', 'BJP', 'TMC')
                THEN te.votes
                ELSE 0
            END
        ) AS aiadmk_bloc_votes,

        -- TVK Votes
        SUM(
            CASE
                WHEN te.party = 'TVK'
                THEN te.votes
                ELSE 0
            END
        ) AS tvk_votes

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number

    GROUP BY cm.region, te.election_year
),

vote_share_calc AS (

    SELECT
        region,
        election_year,

        ROUND(
            (dmk_bloc_votes::numeric / total_votes) * 100,
            2
        ) AS dmk_vote_share,

        ROUND(
            (aiadmk_bloc_votes::numeric / total_votes) * 100,
            2
        ) AS aiadmk_vote_share,

        ROUND(
            (tvk_votes::numeric / total_votes) * 100,
            2
        ) AS tvk_vote_share

    FROM regional_vote_summary
)

SELECT
    v2021.region,

    -- DMK Bloc Share Change
    ROUND(
        v2026.dmk_vote_share
        - v2021.dmk_vote_share,
        2
    ) AS "DMK Δ",

    -- AIADMK Bloc Share Change
    ROUND(
        v2026.aiadmk_vote_share
        - v2021.aiadmk_vote_share,
        2
    ) AS "AIADMK Δ",

    -- TVK Vote Share
    v2026.tvk_vote_share
        AS "TVK %",

    -- Interpretation Layer
    CASE

        WHEN v2026.tvk_vote_share < 3
            THEN 'Minimal TVK Presence'

        WHEN (
            v2026.dmk_vote_share
            - v2021.dmk_vote_share
        ) < 0

        AND

        (
            v2026.aiadmk_vote_share
            - v2021.aiadmk_vote_share
        ) < 0

        THEN
            CASE
                WHEN ABS(
                    v2026.dmk_vote_share
                    - v2021.dmk_vote_share
                )
                >
                ABS(
                    v2026.aiadmk_vote_share
                    - v2021.aiadmk_vote_share
                )

                THEN 'Stronger DMK Bloc Erosion'

                ELSE 'Stronger AIADMK Bloc Erosion'
            END

        WHEN (
            v2026.dmk_vote_share
            - v2021.dmk_vote_share
        ) < 0

        AND

        (
            v2026.aiadmk_vote_share
            - v2021.aiadmk_vote_share
        ) >= 0

            THEN 'Mostly DMK Bloc Impact'

        WHEN (
            v2026.aiadmk_vote_share
            - v2021.aiadmk_vote_share
        ) < 0

        AND

        (
            v2026.dmk_vote_share
            - v2021.dmk_vote_share
        ) >= 0

            THEN 'Mostly AIADMK Bloc Impact'

        ELSE 'Mixed / Unclear Shift'

    END AS "Interpretation"

FROM vote_share_calc v2021

JOIN vote_share_calc v2026
    ON v2021.region = v2026.region

WHERE v2021.election_year = 2021
  AND v2026.election_year = 2026

ORDER BY "TVK %" DESC;

==================================================================================================

--district wise seat flip DMK

WITH constituency_winners AS (

    SELECT
        te.election_year,
        cm.region,
        cm.district,
        te.ac_number,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (

    SELECT
        election_year,
        region,
        district,
        party

    FROM constituency_winners
    WHERE rn = 1
)

SELECT
    district,
    region,

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'DMK'
    ) AS dmk_seats_2021,

    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'DMK'
    ) AS dmk_seats_2026,

    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'DMK'
    )

    -

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'DMK'
    ) AS seat_flip

FROM winner_rows

GROUP BY district, region

ORDER BY
    seat_flip DESC,
    dmk_seats_2026 DESC;

=================================================================================================

--district wise seatflip AIADMK


WITH constituency_winners AS (

    SELECT
        te.election_year,
        cm.region,
        cm.district,
        te.ac_number,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (

    SELECT
        election_year,
        region,
        district,
        party

    FROM constituency_winners
    WHERE rn = 1
)

SELECT
    district,
    region,

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'AIADMK'
    ) AS aiadmk_seats_2021,

    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'AIADMK'
    ) AS aiadmk_seats_2026,

    COUNT(*) FILTER (
        WHERE election_year = 2026
          AND party = 'AIADMK'
    )

    -

    COUNT(*) FILTER (
        WHERE election_year = 2021
          AND party = 'AIADMK'
    ) AS seat_flip

FROM winner_rows

GROUP BY district, region

ORDER BY
    seat_flip DESC,
    aiadmk_seats_2026 DESC;
=============================================================================================

--2021 Data
WITH constituency_winners AS (

    SELECT
        te.election_year,
        cm.region,
        cm.district,
        te.ac_number,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (

    SELECT
        election_year,
        region,
        district,
        party

    FROM constituency_winners
    WHERE rn = 1
),

district_party_seats AS (

    SELECT
        district,
        region,
        party,
        COUNT(*) AS seats

    FROM winner_rows

    WHERE election_year = 2021
      AND party IN ('DMK', 'AIADMK')

    GROUP BY district, region, party
),

ranked_parties AS (

    SELECT *,
    
        RANK() OVER (
            PARTITION BY district
            ORDER BY seats DESC
        ) AS party_rank

    FROM district_party_seats
)

SELECT
    district,
    region,
    party,
    seats,
    2021 AS year

FROM ranked_parties

WHERE party_rank = 1

ORDER BY
    region,
    seats DESC,
    district;

===============================================================================================

--2026 Data

WITH constituency_winners AS (

    SELECT
        te.election_year,
        cm.region,
        cm.district,
        te.ac_number,
        te.party,

        ROW_NUMBER() OVER (
            PARTITION BY te.election_year, te.ac_number
            ORDER BY te.votes DESC
        ) AS rn

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number
),

winner_rows AS (

    SELECT
        election_year,
        region,
        district,
        party

    FROM constituency_winners
    WHERE rn = 1
),

district_party_seats AS (

    SELECT
        district,
        region,
        party,
        COUNT(*) AS seats

    FROM winner_rows

    WHERE election_year = 2026
      AND party IN ('DMK', 'AIADMK', 'TVK')

    GROUP BY district, region, party
),

ranked_parties AS (

    SELECT *,
    
        RANK() OVER (
            PARTITION BY district
            ORDER BY seats DESC
        ) AS party_rank

    FROM district_party_seats
)

SELECT
    district,
    region,
    party,
    seats,
    2026 AS year

FROM ranked_parties

WHERE party_rank = 1

ORDER BY
    region,
    seats DESC,
    district;

===============================================================================================

WITH constituency_vote_totals AS (

    SELECT
        te.election_year,
        te.ac_number,
        cm.constituency,
        cm.region,

        SUM(te.votes) AS total_votes

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number

    GROUP BY
        te.election_year,
        te.ac_number,
        cm.constituency,
        cm.region
),

constituency_party_votes AS (

    SELECT
        te.election_year,
        te.ac_number,
        cm.constituency,
        cm.region,

        -- DMK Bloc Votes
        SUM(
            CASE
                WHEN te.party IN ('DMK', 'INC', 'VCK', 'CPI', 'CPIM')
                THEN te.votes
                ELSE 0
            END
        ) AS dmk_bloc_votes,

        -- AIADMK Bloc Votes
        SUM(
            CASE
                WHEN te.party IN ('AIADMK', 'PMK', 'BJP', 'TMC')
                THEN te.votes
                ELSE 0
            END
        ) AS aiadmk_bloc_votes,

        -- TVK Votes
        SUM(
            CASE
                WHEN te.party = 'TVK'
                THEN te.votes
                ELSE 0
            END
        ) AS tvk_votes

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number

    GROUP BY
        te.election_year,
        te.ac_number,
        cm.constituency,
        cm.region
),

vote_share_calc AS (

    SELECT
        cpv.election_year,
        cpv.ac_number,
        cpv.constituency,
        cpv.region,

        ROUND(
            (cpv.dmk_bloc_votes::numeric / cvt.total_votes) * 100,
            2
        ) AS dmk_vote_share,

        ROUND(
            (cpv.aiadmk_bloc_votes::numeric / cvt.total_votes) * 100,
            2
        ) AS aiadmk_vote_share,

        ROUND(
            (cpv.tvk_votes::numeric / cvt.total_votes) * 100,
            2
        ) AS tvk_vote_share

    FROM constituency_party_votes cpv
    JOIN constituency_vote_totals cvt
        ON cpv.election_year = cvt.election_year
       AND cpv.ac_number = cvt.ac_number
)

SELECT
    v2021.constituency,
    v2021.region,

    ROUND(
        v2026.dmk_vote_share
        - v2021.dmk_vote_share,
        2
    ) AS dmk_vote_share_change,

    ROUND(
        v2026.aiadmk_vote_share
        - v2021.aiadmk_vote_share,
        2
    ) AS aiadmk_vote_share_change,

    v2026.tvk_vote_share
        AS tvk_vote_share_2026

FROM vote_share_calc v2021

JOIN vote_share_calc v2026
    ON v2021.ac_number = v2026.ac_number

WHERE v2021.election_year = 2021
  AND v2026.election_year = 2026

ORDER BY
    tvk_vote_share_2026 DESC,

    ABS(
        v2026.dmk_vote_share
        - v2021.dmk_vote_share
    ) DESC;

==========================================================================================

WITH regional_2021 AS (

    SELECT
        cm.region,

        SUM(CASE WHEN r.party = 'DMK'
            THEN r.votes ELSE 0 END) * 100.0
            / SUM(r.total_votes) AS dmk_vs_2021,

        SUM(CASE WHEN r.party = 'AIADMK'
            THEN r.votes ELSE 0 END) * 100.0
            / SUM(r.total_votes) AS aiadmk_vs_2021

    FROM tn_election r
    JOIN constituency_master cm
        ON r.constituency = cm.constituency

    GROUP BY cm.region
),

regional_2026 AS (

    SELECT
        cm.region,

        SUM(CASE WHEN r.party = 'DMK'
            THEN r.votes ELSE 0 END) * 100.0
            / SUM(r.total_votes) AS dmk_vs_2026,

        SUM(CASE WHEN r.party = 'AIADMK'
            THEN r.votes ELSE 0 END) * 100.0
            / SUM(r.total_votes) AS aiadmk_vs_2026,

        SUM(CASE WHEN r.party = 'TVK'
            THEN r.votes ELSE 0 END) * 100.0
            / SUM(r.total_votes) AS tvk_vs_2026

    FROM tn_2026_results r
    JOIN constituency_master cm
        ON r.constituency = cm.constituency

    GROUP BY cm.region
)

SELECT
    r21.region,

    ROUND(
        r26.dmk_vs_2026 - r21.dmk_vs_2021,
        2
    ) AS dmk_vote_share_change,

    ROUND(
        r26.aiadmk_vs_2026 - r21.aiadmk_vs_2021,
        2
    ) AS aiadmk_vote_share_change,

    ROUND(
        r26.tvk_vs_2026,
        2
    ) AS tvk_vote_share_2026

FROM regional_2021 r21
JOIN regional_2026 r26
    ON r21.region = r26.region;

===========================================================================================

WITH regional_vote_totals AS (

    SELECT
        te.election_year,
        cm.region,

        SUM(te.votes) AS total_votes

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number

    GROUP BY
        te.election_year,
        cm.region
),

regional_party_votes AS (

    SELECT
        te.election_year,
        cm.region,

        -- DMK Bloc Votes
        SUM(
            CASE
                WHEN te.party IN ('DMK', 'INC', 'VCK', 'CPI', 'CPIM')
                THEN te.votes
                ELSE 0
            END
        ) AS dmk_bloc_votes,

        -- AIADMK Bloc Votes
        SUM(
            CASE
                WHEN te.party IN ('AIADMK', 'PMK', 'BJP', 'TMC')
                THEN te.votes
                ELSE 0
            END
        ) AS aiadmk_bloc_votes,

        -- TVK Votes
        SUM(
            CASE
                WHEN te.party = 'TVK'
                THEN te.votes
                ELSE 0
            END
        ) AS tvk_votes

    FROM tn_election te
    JOIN constituency_master cm
        ON te.ac_number = cm.ac_number

    GROUP BY
        te.election_year,
        cm.region
),

vote_share_calc AS (

    SELECT
        rpv.election_year,
        rpv.region,

        ROUND(
            (rpv.dmk_bloc_votes::numeric / rvt.total_votes) * 100,
            2
        ) AS dmk_vote_share,

        ROUND(
            (rpv.aiadmk_bloc_votes::numeric / rvt.total_votes) * 100,
            2
        ) AS aiadmk_vote_share,

        ROUND(
            (rpv.tvk_votes::numeric / rvt.total_votes) * 100,
            2
        ) AS tvk_vote_share

    FROM regional_party_votes rpv
    JOIN regional_vote_totals rvt
        ON rpv.election_year = rvt.election_year
       AND rpv.region = rvt.region
)

SELECT
    v2021.region,

    ROUND(
        v2026.dmk_vote_share
        - v2021.dmk_vote_share,
        2
    ) AS dmk_vote_share_change,

    ROUND(
        v2026.aiadmk_vote_share
        - v2021.aiadmk_vote_share,
        2
    ) AS aiadmk_vote_share_change,

    v2026.tvk_vote_share
        AS tvk_vote_share_2026

FROM vote_share_calc v2021

JOIN vote_share_calc v2026
    ON v2021.region = v2026.region

WHERE v2021.election_year = 2021
  AND v2026.election_year = 2026

ORDER BY
    tvk_vote_share_2026 DESC,
    ABS(
        v2026.dmk_vote_share
        - v2021.dmk_vote_share
    ) DESC;