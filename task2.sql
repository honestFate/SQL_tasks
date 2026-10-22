-- 1
SELECT *
FROM Squads
WHERE leader_id IS NULL;

-- 2
SELECT *
FROM Dwarves
WHERE age > 150
  AND profession = 'Warrior';

-- 3
SELECT d.*
FROM Dwarves d
WHERE EXISTS (
    SELECT 1
    FROM Items i
    WHERE i.owner_id = d.dwarf_id
      AND i.type = 'weapon'
);

-- 4
SELECT d.dwarf_id, d.name, t.status, COUNT(t.task_id) AS tasks_count
FROM Dwarves d
LEFT JOIN Tasks t ON t.assigned_to = d.dwarf_id
GROUP BY d.dwarf_id, d.name, t.status
ORDER BY d.dwarf_id, t.status;

-- 5
SELECT t.*
FROM Tasks t
JOIN Dwarves d ON d.dwarf_id = t.assigned_to
JOIN Squads s ON s.squad_id = d.squad_id
WHERE s.name = 'Guardians';

-- 6
SELECT d.dwarf_id,
       d.name,
       r.relationship,
       rel.dwarf_id AS relative_id,
       rel.name AS relative_name
FROM Dwarves d
LEFT JOIN Relationships r ON r.dwarf_id = d.dwarf_id
LEFT JOIN Dwarves rel ON rel.dwarf_id = r.related_to
ORDER BY d.dwarf_id;
