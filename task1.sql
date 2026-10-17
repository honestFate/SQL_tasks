-- 1
SELECT d.*, s.name AS squad_name, s.mission
FROM Dwarves d
JOIN Squads s ON s.squad_id = d.squad_id;

-- 2
SELECT *
FROM Dwarves
WHERE profession = 'miner'
  AND squad_id IS NULL;

-- 3
SELECT *
FROM Tasks
WHERE status = 'pending'
  AND priority = (SELECT MAX(priority) FROM Tasks WHERE status = 'pending');

-- 4
SELECT d.dwarf_id, d.name, COUNT(*) AS items_count
FROM Dwarves d
JOIN Items i ON i.owner_id = d.dwarf_id
GROUP BY d.dwarf_id, d.name;

-- 5
SELECT s.squad_id, s.name, COUNT(d.dwarf_id) AS dwarves_count
FROM Squads s
LEFT JOIN Dwarves d ON d.squad_id = s.squad_id
GROUP BY s.squad_id, s.name;

-- 6
WITH prof_tasks AS (
    SELECT d.profession, COUNT(*) AS cnt
    FROM Tasks t
    JOIN Dwarves d ON d.dwarf_id = t.assigned_to
    WHERE t.status IN ('pending', 'in_progress')
    GROUP BY d.profession
)
SELECT profession, cnt
FROM prof_tasks
WHERE cnt = (SELECT MAX(cnt) FROM prof_tasks);

-- 7
SELECT type, AVG(age) AS avg_age
FROM (
    SELECT DISTINCT i.type, d.dwarf_id, d.age
    FROM Items i
    JOIN Dwarves d ON d.dwarf_id = i.owner_id
) x
GROUP BY type;

-- 8
SELECT d.*
FROM Dwarves d
WHERE d.age > (SELECT AVG(age) FROM Dwarves)
  AND NOT EXISTS (
      SELECT 1 FROM Items i WHERE i.owner_id = d.dwarf_id
  );
