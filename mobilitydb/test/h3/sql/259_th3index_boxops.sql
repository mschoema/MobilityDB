-- The bounding box of an H3 cell CONTAINS the cell, and the containment is
-- what the index keys on. A box taken as the plain minimum and maximum of the
-- boundary vertices does not have that property: a cell holding a pole reaches
-- a latitude no vertex carries, a cell crossing the antimeridian has vertex
-- longitudes near both -180 and +180 whose extremes name the complement of the
-- cell, and every cell edge is a geodesic that rises beyond both of the
-- vertices it joins.

-------------------------------------------------------------------------------
-- A cell holding a pole reaches it and spans every longitude
-------------------------------------------------------------------------------

SELECT round(stbox(h3index '8001fffffffffff'), 6);
SELECT round(stbox(h3index '81033ffffffffff'), 6);
SELECT round(stbox(h3index '80f3fffffffffff'), 6);
SELECT round(stbox(h3index '81f2bffffffffff'), 6);

-------------------------------------------------------------------------------
-- A cell crossing the antimeridian takes the full longitude range
-------------------------------------------------------------------------------

SELECT round(stbox(h3index '807ffffffffffff'), 6);
SELECT round(stbox(h3index '817ebffffffffff'), 6);

-------------------------------------------------------------------------------
-- A cell away from both takes the extent of its own boundary
-------------------------------------------------------------------------------

SELECT round(stbox(h3index '801ffffffffffff'), 6);
SELECT round(stbox(h3index '821fa7fffffffff'), 6);

-------------------------------------------------------------------------------
-- A temporal cell carries the same spatial extent as the cell it takes
-------------------------------------------------------------------------------

SELECT round(stbox(th3index '8001fffffffffff@2001-01-01'), 6);
SELECT round(stbox(th3index '807ffffffffffff@2001-01-01'), 6);
SELECT round(stbox(th3index '[8001fffffffffff@2001-01-01, 801ffffffffffff@2001-01-02]'), 6);

-------------------------------------------------------------------------------
-- No parent/child containment property is asserted here. H3 cells are NOT
-- geometrically nested: a child's boundary vertices reach beyond the parent's
-- boundary, measured at up to 1.93 degrees over the fixture above, so
-- `stbox(child) <@ stbox(parent)` is false for H3 by construction and says
-- nothing about this box.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- A cell composed with a time keeps the space it covers
--
-- `stbox(cell)` and `stbox(cell, <time>)` bound the same region; the second
-- adds the period and nothing else, so its X and Y are those of the first.
-------------------------------------------------------------------------------

SELECT round(stbox(h3index '8001fffffffffff', timestamptz '2001-01-01'), 6);
SELECT round(stbox(h3index '8001fffffffffff', tstzspan '[2001-01-01, 2001-01-02]'), 6);
SELECT round(stbox(h3index '8001fffffffffff', timestamptz '2001-01-01')::stbox, 6)
  && round(stbox(h3index '8001fffffffffff'), 6);
SELECT hasX(stbox(h3index '8001fffffffffff', timestamptz '2001-01-01')),
  hasT(stbox(h3index '8001fffffffffff', timestamptz '2001-01-01'));
SELECT SRID(stbox(h3index '8001fffffffffff', tstzspan '[2001-01-01, 2001-01-02]'));

-------------------------------------------------------------------------------
