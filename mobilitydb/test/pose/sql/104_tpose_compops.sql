-------------------------------------------------------------------------------
-- Temporal equal
-------------------------------------------------------------------------------

SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #= pose 'Pose(Point(1 1), 0.5)';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= pose 'Pose(Point(1 1), 0.5)';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= pose 'Pose(Point(1 1), 0.5)';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= pose 'Pose(Point(1 1), 0.5)';

SELECT pose 'Pose(Point(1 1), 0.5)' #= tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT pose 'Pose(Point(1 1), 0.5)' #= tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT pose 'Pose(Point(1 1), 0.5)' #= tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT pose 'Pose(Point(1 1), 0.5)' #= tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #= tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #= tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #= tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #= tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #= tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #= tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #= tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

-------------------------------------------------------------------------------
-- Temporal not equal
-------------------------------------------------------------------------------

SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #<> pose 'Pose(Point(1 1), 0.5)';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> pose 'Pose(Point(1 1), 0.5)';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> pose 'Pose(Point(1 1), 0.5)';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> pose 'Pose(Point(1 1), 0.5)';

SELECT pose 'Pose(Point(1 1), 0.5)' #<> tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT pose 'Pose(Point(1 1), 0.5)' #<> tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT pose 'Pose(Point(1 1), 0.5)' #<> tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT pose 'Pose(Point(1 1), 0.5)' #<> tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #<> tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #<> tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #<> tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #<> tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}' #<> tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]' #<> tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> tpose 'Pose(Point(1 1), 0.5)@2001-01-01';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> tpose '{Pose(Point(1 1), 0.3)@2001-01-01, Pose(Point(1 1), 0.5)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03}';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> tpose '[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03]';
SELECT tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}' #<> tpose '{[Pose(Point(1 1), 0.2)@2001-01-01, Pose(Point(1 1), 0.4)@2001-01-02, Pose(Point(1 1), 0.5)@2001-01-03], [Pose(Point(2 2), 0.6)@2001-01-04, Pose(Point(2 2), 0.6)@2001-01-05]}';

/* Errors */
SELECT tpose 'Pose(Point(1 1), 0.5)@2001-01-01' #= tpose 'SRID=3812;Pose(Point(1 1), 0.5)@2001-01-01';

-------------------------------------------------------------------------------/
