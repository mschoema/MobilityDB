SELECT wmin(temp, NULL) FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wmin(temp, NULL) FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);
SELECT wmin(temp, interval '5 minutes') FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wmin(temp, interval '5 minutes') FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);

SELECT wmax(temp, NULL) FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wmax(temp, NULL) FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);
SELECT wmax(temp, interval '5 minutes') FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wmax(temp, interval '5 minutes') FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);

SELECT wcount(temp, NULL) FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wcount(temp, NULL) FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);
SELECT wcount(temp, interval '5 minutes') FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wcount(temp, interval '5 minutes') FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);

SELECT wsum(temp, NULL) FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wsum(temp, NULL) FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);
SELECT wsum(temp, interval '5 minutes') FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wsum(temp, interval '5 minutes') FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);

SELECT wavg(temp, NULL) FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wavg(temp, NULL) FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);
SELECT wavg(temp, interval '5 minutes') FROM (VALUES (NULL::tint),(NULL::tint)) t(temp);
SELECT wavg(temp, interval '5 minutes') FROM (VALUES (NULL::tint),('1@2001-01-01'::tint)) t(temp);

-------------------------------------------------------------------------------

SELECT wmin(temp, NULL) FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wmin(temp, NULL) FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);
SELECT wmin(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wmin(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);

SELECT wmax(temp, NULL) FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wmax(temp, NULL) FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);
SELECT wmax(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wmax(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);

SELECT wcount(temp, NULL) FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wcount(temp, NULL) FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);
SELECT wcount(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wcount(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);
-- The count is a tint, as for every temporal type
SELECT pg_typeof(wcount(temp, interval '2 days')) FROM (VALUES ('1@2001-01-01'::tbigint),('2@2001-01-02'::tbigint)) t(temp);
SELECT wcount(temp, interval '2 days') #= tint '[1@2001-01-01, 1@2001-01-05]' FROM (VALUES ('1@2001-01-01'::tbigint),('2@2001-01-02'::tbigint)) t(temp);

SELECT wsum(temp, NULL) FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wsum(temp, NULL) FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);
SELECT wsum(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wsum(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);

SELECT wavg(temp, NULL) FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wavg(temp, NULL) FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);
SELECT wavg(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),(NULL::tbigint)) t(temp);
SELECT wavg(temp, interval '5 minutes') FROM (VALUES (NULL::tbigint),('1@2001-01-01'::tbigint)) t(temp);
-- The average of the values themselves, a bigint beyond 32 bits included
SELECT wavg(temp, interval '2 days') FROM (VALUES ('1@2001-01-01'::tbigint),('2@2001-01-02'::tbigint)) t(temp);
SELECT wavg(temp, interval '1 day') FROM (VALUES ('[5000000000@2001-01-01, 5000000002@2001-01-02]'::tbigint),('[5000000004@2001-01-01, 5000000004@2001-01-03]'::tbigint)) t(temp);
SELECT wavg(temp, interval '1 day') FROM (VALUES ('{[5000000000@2001-01-01, 5000000002@2001-01-02], [7000000000@2001-01-04, 7000000000@2001-01-05]}'::tbigint)) t(temp);

-------------------------------------------------------------------------------

SELECT wmin(temp, NULL) FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wmin(temp, NULL) FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);
SELECT wmin(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wmin(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);

SELECT wmax(temp, NULL) FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wmax(temp, NULL) FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);
SELECT wmax(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wmax(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);

SELECT wcount(temp, NULL) FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wcount(temp, NULL) FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);
SELECT wcount(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wcount(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);

SELECT wsum(temp, NULL) FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wsum(temp, NULL) FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);
SELECT wsum(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wsum(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);

SELECT wavg(temp, NULL) FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wavg(temp, NULL) FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);
SELECT wavg(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),(NULL::tfloat)) t(temp);
SELECT wavg(temp, interval '5 minutes') FROM (VALUES (NULL::tfloat),('1@2001-01-01'::tfloat)) t(temp);

-------------------------------------------------------------------------------

SELECT wmax(temp, interval '1 day') FROM (VALUES (tfloat '[1@2001-01-01, 1@2001-01-02]'),('[1@2001-01-03, 1@2001-01-04]')) t(temp);

/* Errors */
SELECT wsum(temp, interval '1 day') FROM (VALUES (tfloat '[1@2001-01-01, 1@2001-01-02]'),('[1@2001-01-03, 1@2001-01-04]')) t(temp);

-------------------------------------------------------------------------------



