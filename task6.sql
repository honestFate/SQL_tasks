-- 2
SELECT
    d.dwarf_id,
    d.name,
    d.age,
    d.profession,
    JSON_OBJECT(
        'skill_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(s.skill_id), JSON_ARRAY())
            FROM skills s
            WHERE EXISTS (
                SELECT 1
                FROM dwarf_skills ds
                WHERE ds.skill_id = s.skill_id
                  AND ds.dwarf_id = d.dwarf_id
            )
        ),
        'assignment_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(da.assignment_id), JSON_ARRAY())
            FROM dwarf_assignments da
            WHERE da.dwarf_id = d.dwarf_id
              AND da.start_date <= CURRENT_DATE
              AND (da.end_date IS NULL OR da.end_date >= CURRENT_DATE)
        ),
        'squad_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(sm.squad_id), JSON_ARRAY())
            FROM squad_members sm
            WHERE sm.dwarf_id = d.dwarf_id
              AND sm.exit_date IS NULL
        ),
        'equipment_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(de.equipment_id), JSON_ARRAY())
            FROM dwarf_equipment de
            WHERE de.dwarf_id = d.dwarf_id
        )
    ) AS related_entities
FROM dwarves d;

-- 3
SELECT
    w.workshop_id,
    w.name,
    w.type,
    w.quality,
    JSON_OBJECT(
        'craftsdwarf_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(wc.dwarf_id), JSON_ARRAY())
            FROM workshop_craftsdwarves wc
            WHERE wc.workshop_id = w.workshop_id
        ),
        'project_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(p.project_id), JSON_ARRAY())
            FROM projects p
            WHERE p.workshop_id = w.workshop_id
              AND p.status NOT IN ('Completed', 'Cancelled')
        ),
        'input_material_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(wm.material_id), JSON_ARRAY())
            FROM workshop_materials wm
            WHERE wm.workshop_id = w.workshop_id
              AND wm.is_input = TRUE
        ),
        'output_product_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(pr.product_id), JSON_ARRAY())
            FROM products pr
            WHERE EXISTS (
                SELECT 1
                FROM workshop_products wp
                WHERE wp.product_id = pr.product_id
                  AND wp.workshop_id = w.workshop_id
            )
        )
    ) AS related_entities
FROM workshops w;

-- 4
SELECT
    ms.squad_id,
    ms.name,
    ms.formation_type,
    ms.leader_id,
    JSON_OBJECT(
        'member_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(sm.dwarf_id), JSON_ARRAY())
            FROM squad_members sm
            WHERE sm.squad_id = ms.squad_id
              AND sm.exit_date IS NULL
        ),
        'equipment_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(e.equipment_id), JSON_ARRAY())
            FROM equipment e
            WHERE EXISTS (
                SELECT 1
                FROM squad_equipment se
                WHERE se.equipment_id = e.equipment_id
                  AND se.squad_id = ms.squad_id
            )
        ),
        'operation_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(so.operation_id), JSON_ARRAY())
            FROM squad_operations so
            WHERE so.squad_id = ms.squad_id
              AND so.start_date <= CURRENT_DATE
        ),
        'training_schedule_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(st.schedule_id), JSON_ARRAY())
            FROM squad_training st
            WHERE st.squad_id = ms.squad_id
        ),
        'battle_report_ids', (
            SELECT COALESCE(JSON_ARRAYAGG(sb.report_id), JSON_ARRAY())
            FROM squad_battles sb
            WHERE sb.squad_id = ms.squad_id
        )
    ) AS related_entities
FROM military_squads ms;
