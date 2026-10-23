-- Wafer Yield Intelligence - SQL views (Jira card WYI-12)
-- WHERE TO RUN: Lakehouse -> switch (top right) to "SQL analytics endpoint" -> New SQL query.
-- PREREQUISITE: notebook 01 has created the table dbo.wafer_clean (refresh the endpoint if it is not listed yet).
-- Run each CREATE VIEW statement once. To change one later, use ALTER VIEW.

CREATE VIEW dbo.vw_yield_by_node AS
SELECT technology_node,
       COUNT(*)                                   AS wafers,
       COUNT(DISTINCT lot_id)                     AS lots,
       ROUND(AVG([yield]), 4)                     AS avg_yield,
       ROUND(STDEV([yield]), 4)                   AS yield_stddev,
       ROUND(100.0 * SUM(low_yield_flag) / COUNT(*), 1) AS low_yield_pct
FROM dbo.wafer_clean
GROUP BY technology_node;
GO

CREATE VIEW dbo.vw_yield_by_product AS
SELECT product_type,
       COUNT(*)                                   AS wafers,
       COUNT(DISTINCT lot_id)                     AS lots,
       ROUND(AVG([yield]), 4)                     AS avg_yield,
       ROUND(STDEV([yield]), 4)                   AS yield_stddev,
       ROUND(100.0 * SUM(low_yield_flag) / COUNT(*), 1) AS low_yield_pct
FROM dbo.wafer_clean
GROUP BY product_type;
GO

-- One row per tool, for all four tool types (long format is easiest for Power BI)
CREATE VIEW dbo.vw_yield_by_tool AS
SELECT tool_type, tool_name,
       COUNT(*)                                   AS wafers,
       COUNT(DISTINCT lot_id)                     AS lots,
       ROUND(AVG([yield]), 4)                     AS avg_yield,
       ROUND(100.0 * SUM(low_yield_flag) / COUNT(*), 1) AS low_yield_pct
FROM (
    SELECT 'Etch' AS tool_type, etch_tool AS tool_name, lot_id, [yield], low_yield_flag FROM dbo.wafer_clean
    UNION ALL
    SELECT 'Litho', litho_tool, lot_id, [yield], low_yield_flag FROM dbo.wafer_clean
    UNION ALL
    SELECT 'Deposition', deposition_tool, lot_id, [yield], low_yield_flag FROM dbo.wafer_clean
    UNION ALL
    SELECT 'Implant', implant_tool, lot_id, [yield], low_yield_flag FROM dbo.wafer_clean
) t
GROUP BY tool_type, tool_name;
GO

-- Tool x node: controls for the fact that tools run different nodes (confounding)
CREATE VIEW dbo.vw_yield_by_tool_and_node AS
SELECT tool_type, tool_name, technology_node,
       COUNT(*)                                   AS wafers,
       COUNT(DISTINCT lot_id)                     AS lots,
       ROUND(AVG([yield]), 4)                     AS avg_yield
FROM (
    SELECT 'Etch' AS tool_type, etch_tool AS tool_name, technology_node, lot_id, [yield] FROM dbo.wafer_clean
    UNION ALL
    SELECT 'Litho', litho_tool, technology_node, lot_id, [yield] FROM dbo.wafer_clean
    UNION ALL
    SELECT 'Deposition', deposition_tool, technology_node, lot_id, [yield] FROM dbo.wafer_clean
    UNION ALL
    SELECT 'Implant', implant_tool, technology_node, lot_id, [yield] FROM dbo.wafer_clean
) t
GROUP BY tool_type, tool_name, technology_node;
GO

-- One row per lot (the natural unit for SPC / control charts)
CREATE VIEW dbo.vw_lot_summary AS
SELECT lot_id, process_date, product_type, technology_node,
       etch_tool, litho_tool, deposition_tool, implant_tool,
       COUNT(*)                                   AS wafers,
       ROUND(AVG([yield]), 4)                     AS avg_yield,
       ROUND(MIN([yield]), 4)                     AS min_yield,
       ROUND(MAX([yield]), 4)                     AS max_yield,
       ROUND(STDEV([yield]), 4)                   AS within_lot_stddev,
       ROUND(100.0 * SUM(low_yield_flag) / COUNT(*), 1) AS low_yield_pct,
       ROUND(AVG(critical_dimension), 3)          AS avg_critical_dimension,
       ROUND(AVG(oxide_thickness), 3)             AS avg_oxide_thickness,
       ROUND(AVG(vth), 4)                         AS avg_vth
FROM dbo.wafer_clean
GROUP BY lot_id, process_date, product_type, technology_node,
         etch_tool, litho_tool, deposition_tool, implant_tool;
GO

-- Wafers below the low-yield threshold (for drill-down tables)
CREATE VIEW dbo.vw_low_yield_wafers AS
SELECT lot_id, wafer_id, process_date, product_type, technology_node,
       etch_tool, litho_tool, deposition_tool, implant_tool,
       [yield], critical_dimension, oxide_thickness, vth, defect_density, outlier_count
FROM dbo.wafer_clean
WHERE low_yield_flag = 1;
GO

-- CHECKS (run after creating the views; paste results into Jira WYI-12)
SELECT COUNT(*) AS wafers FROM dbo.wafer_clean;                 -- expect 1250
SELECT COUNT(*) AS lots   FROM dbo.vw_lot_summary;              -- expect 50
SELECT * FROM dbo.vw_yield_by_node ORDER BY avg_yield DESC;
SELECT * FROM dbo.vw_yield_by_tool ORDER BY tool_type, avg_yield DESC;
