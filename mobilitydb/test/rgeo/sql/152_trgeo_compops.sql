-------------------------------------------------------------------------------
-- Temporal equal
-------------------------------------------------------------------------------

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #= geometry 'Polygon((1 1,2 2,3 1,1 1))';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= geometry 'Polygon((1 1,2 2,3 1,1 1))';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= geometry 'Polygon((1 1,2 2,3 1,1 1))';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= geometry 'Polygon((1 1,2 2,3 1,1 1))';

SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

-------------------------------------------------------------------------------
-- Temporal not equal
-------------------------------------------------------------------------------

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #<> geometry 'Polygon((1 1,2 2,3 1,1 1))';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> geometry 'Polygon((1 1,2 2,3 1,1 1))';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> geometry 'Polygon((1 1,2 2,3 1,1 1))';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> geometry 'Polygon((1 1,2 2,3 1,1 1))';

SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT geometry 'Polygon((1 1,2 2,3 1,1 1))' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> trgeometry 'Polygon((1 1,2 2,3 1,1 1));{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

/* Errors */
SELECT trgeometry 'Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01' #= trgeometry 'SRID=3812;Polygon((1 1,2 2,3 1,1 1));Pose(Point(1 1), 0.5)@2001-01-01';

-------------------------------------------------------------------------------/
