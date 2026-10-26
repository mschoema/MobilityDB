-------------------------------------------------------------------------------
-- Temporal equal
-------------------------------------------------------------------------------

SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #= cbuffer 'Cbuffer(Point(1 1), 0.5)';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #= cbuffer 'Cbuffer(Point(1 1), 0.5)';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #= cbuffer 'Cbuffer(Point(1 1), 0.5)';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #= cbuffer 'Cbuffer(Point(1 1), 0.5)';

SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #= tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #= tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #= tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #= tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #= tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #= tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #= tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #= tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #= tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #= tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #= tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #= tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #= tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #= tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #= tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #= tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #= tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #= tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #= tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #= tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

-------------------------------------------------------------------------------
-- Temporal not equal
-------------------------------------------------------------------------------

SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #<> cbuffer 'Cbuffer(Point(1 1), 0.5)';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #<> cbuffer 'Cbuffer(Point(1 1), 0.5)';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #<> cbuffer 'Cbuffer(Point(1 1), 0.5)';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #<> cbuffer 'Cbuffer(Point(1 1), 0.5)';

SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #<> tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #<> tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #<> tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT cbuffer 'Cbuffer(Point(1 1), 0.5)' #<> tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #<> tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #<> tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #<> tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01' #<> tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #<> tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #<> tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #<> tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}' #<> tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #<> tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #<> tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #<> tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]' #<> tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #<> tcbuffer 'Cbuffer(Point(1 1), 0.5)@2001-01-01';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #<> tcbuffer '{Cbuffer(Point(1 1), 0.3)@2001-01-01, Cbuffer(Point(1 1), 0.5)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03}';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #<> tcbuffer '[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03]';
SELECT tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}' #<> tcbuffer '{[Cbuffer(Point(1 1), 0.2)@2001-01-01, Cbuffer(Point(1 1), 0.4)@2001-01-02, Cbuffer(Point(1 1), 0.5)@2001-01-03], [Cbuffer(Point(2 2), 0.6)@2001-01-04, Cbuffer(Point(2 2), 0.6)@2001-01-05]}';

/* Errors */
SELECT tcbuffer 'Cbuffer(Point(1 1),1)@2001-01-01' #= tcbuffer 'SRID=3812;Cbuffer(Point(1 1),1)@2001-01-01';

-------------------------------------------------------------------------------/
