drop table movies;

CREATE TABLE movies (
    key SERIAL PRIMARY KEY,
    title   VARCHAR(50) NOT NULL,
    country VARCHAR(20) NOT NULL,
    release_year INT NOT NULL,
    duration     INT NOT NULL
);

INSERT INTO movies (title, country, release_year, duration)
SELECT
    -- 生成随机电影标题
    CASE
        WHEN mod(i, 10) = 0 THEN (ARRAY['The', 'A', 'An', 'Lost', 'Forgotten', 'Secret', 'Hidden', 'Final', 'Eternal', 'Last'                                                                      ])[floor(random() * 10 + 1)::int] || ' ' ||
                                 (ARRAY['Mystery', 'Journey', 'Adventure', 'Legend', 'Prophecy', 'Vision', 'Dream', 'Nightmare', 'Memory', 'Truth'                                                 ])[floor(random() * 10 + 1)::int] || ' ' ||
                                 (ARRAY['of Time', 'Beyond Stars', 'In Darkness', 'Beneath Waves', 'Through Fire', 'Across Lands', 'Among Shadows', 'Within Souls', 'After Midnight', 'Before Dawn'])[floor(random() * 10 + 1)::int]
        WHEN mod(i, 10) = 1 THEN (ARRAY['Escape from', 'Return to', 'Attack on', 'Defense of', 'Quest for', 'Search for', 'Hunt for', 'Chase for', 'Race to', 'Flight to'])[floor(random() * 10 + 1)::int] || ' ' ||
                                 (ARRAY['Atlantis', 'Nowhere', 'Paradise', 'Hell', 'Labyrinth', 'Mountain', 'City', 'Island', 'Forest', 'Desert'                         ])[floor(random() * 10 + 1)::int]
        WHEN mod(i, 10) = 2 THEN (ARRAY['Fast &', 'Slow &', 'High &', 'Low &', 'Hot &', 'Cold &', 'Dark &', 'Light &', 'Young &', 'Old &'          ])[floor(random() * 10 + 1)::int] || ' ' ||
                                 (ARRAY['Furious', 'Steady', ' Mighty', 'Calm', 'Burning', 'Freezing', 'Mysterious', 'Bright', 'Rebellious', 'Wise'])[floor(random() * 10 + 1)::int]
        WHEN mod(i, 10) = 3 THEN (ARRAY['Once Upon a', 'Twice in a', 'Three Times a', 'Forever in a', 'Never in a'])[floor(random() * 5 + 1)::int] || ' ' ||
                                 (ARRAY['Time', 'Lifetime', 'Dream', 'Night', 'Season'                            ])[floor(random() * 5 + 1)::int] || ' in ' ||
                                 (ARRAY['Paris', 'New York', 'Tokyo', 'London', 'Berlin'                          ])[floor(random() * 5 + 1)::int]
        ELSE (ARRAY['Midnight', 'Sunset', 'Dawn', 'Noon', 'Twilight', 'Morning', 'Evening', 'Night', 'Day', 'Star'                     ])[floor(random() * 10 + 1)::int] || ' ' ||
             (ARRAY['Rider', 'Hunter', 'Warrior', 'Traveler', 'Wanderer', 'Seeker', 'Finder', 'Keeper', 'Guardian', 'Warrior'          ])[floor(random() * 10 + 1)::int] || ' ' ||
             (ARRAY['Chronicles', 'Stories', 'Tales', 'Legends', 'Adventures', 'Journeys', 'Dreams', 'Nightmares', 'Memories', 'Truths'])[floor(random() * 10 + 1)::int]
    END AS title,

    -- 随机国家
    (ARRAY['United States', 'United Kingdom', 'France', 'Germany', 'Japan', 'China', 'India', 'Canada', 'Australia', 'Italy',
           'Spain', 'Russia', 'South Korea', 'Brazil', 'Mexico', 'Argentina', 'Sweden', 'Denmark', 'Norway', 'Netherlands',
           'Belgium', 'Switzerland', 'Austria', 'Turkey', 'South Africa', 'New Zealand', 'Thailand', 'Singapore', 'Ireland', 'Poland'])[floor(random() * 30 + 1)::int] AS country,

    -- 随机发行年份 (1920-2023)
    floor(random() * 104 + 1920)::INT AS release_year,

    -- 随机时长 (60-240分钟)
    floor(random() * 181 + 60)::INT AS duration

FROM generate_series(1, 1000000) AS i;

ANALYZE movies;

explain analyse update movies set release_year = release_year + 1;

explain analyse select * from movies where ( key # ( select count(*) from movies ) ) % 5 = 0;

explain analyse SELECT * FROM movies m1 JOIN movies m2 ON m1.key < m2.key WHERE ABS(m1.release_year - m2.release_year) <= 20 AND (m1.duration # m2.duration) % 3 = 0;

create index idx_year ON movies USING btree (release_year);
explain analyse select * from movies where release_year between 1991 and 1993;
drop index idx_year;

create index idx_country ON movies USING hash (country);
explain analyse select * from movies where country = 'China';
drop index idx_country;

CREATE INDEX idx_title ON movies USING gist (to_tsvector('english', title));
explain analyse SELECT * FROM movies WHERE to_tsvector('english', title) @@ to_tsquery('english', 'Time');
drop index idx_title;

CREATE INDEX idx_title ON movies USING gin (to_tsvector('english', title));
explain analyse SELECT * FROM movies WHERE to_tsvector('english', title) @@ to_tsquery('english', 'Time');
drop index idx_title;
