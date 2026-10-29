
# Work 5: Working with Views (SQL)

**Goal:** Learn how to create and modify SQL views (`VIEW`), combine view filters with main queries, and work with grouped and updatable views in MySQL.

---

## 1. Core Concepts

- **Virtual tables (`CREATE OR REPLACE VIEW`):** Views don't store actual data on disk. They just save a `SELECT` query and run it dynamically whenever you access the view, so you always get fresh data from the base tables.
- **How MySQL processes views (`MERGE` vs `TEMPTABLE`):**
  1. **`ALGORITHM = MERGE`:** MySQL takes the view's query and merges it directly into your main query (for example, combining both `WHERE` conditions with `AND`). This only works when there is a 1-to-1 match between the rows in the view and the base table.
  2. **`ALGORITHM = TEMPTABLE`:** MySQL runs the view query first, saves the result into a hidden temporary table in memory, and then runs your outer query on top of it. This is used when the view has `GROUP BY` or aggregate functions (`COUNT`, `SUM`, `MAX`). Because the rows are grouped together, these views are read-only.
- **Access control and cleaner queries:** Views are useful for hiding sensitive columns (like phone numbers) so users only see what they need to see, and for wrapping long `JOIN` queries so you don't have to rewrite them every time.
- **Updatable views & `WITH CHECK OPTION`:** If a view is simple enough, you can `UPDATE` the original tables right through it. Adding `WITH CASCADED CHECK OPTION` makes sure you can't update or insert a row if the new values don't match the view's `WHERE` filter (MySQL will block it with `Error Code: 1369. CHECK OPTION failed`).
- **MySQL limitations & variables:**
  - You can't pass system or user variables (`@var`), stored procedure parameters, or `PREPARE` parameters into a view definition.
  - You can't attach triggers to a view or create temporary views based on temporary tables.

---

## 2. Quick Syntax & Command Notes

- **`VIEW`** - a virtual table. It doesn't copy data to the disk; it's just a saved query that runs on the fly whenever you call it.
- **`CREATE OR REPLACE`** - creates a new view, or overwrites it if one with the same name already exists (so the script doesn't crash with an error).
- **`AS`** - alias / separator:
  - Before `SELECT` (`VIEW name AS SELECT...`): separates the view name from the query itself.
  - In the column list (`id AS manager_id`): renames a column in the final output.
- **`ALGORITHM = MERGE`** - merges the view logic directly into your query without making temporary copies. Works fast and lets you edit data via `UPDATE`.
- **`ALGORITHM = TEMPTABLE`** - calculates the view data first and puts it into a temp table in memory before showing the result. Needed for `SUM`, `COUNT`, and `GROUP BY`, but makes the view read-only.
- **`WITH CHECK OPTION`** - acts as a filter check. It blocks any `INSERT` or `UPDATE` if the changed row wouldn't match the view's `WHERE` condition anymore.
- **Table prefixes (`s.`, `m.`, `c.`)** - short table aliases that tell MySQL which table a column comes from (`s` for `sales`, `m` for `managers`, `c` for `cars`) so identical names like `id` don't clash.
- **`INNER JOIN`** - links tables and keeps only the rows that have matches in both tables.
- **`LEFT JOIN`** - keeps all rows from the left table (`managers`), even if they have no matches in `sales` (fills missing data with `NULL`).
- **`ON`** - sets the rule for how tables are linked together (`ON s.manager_id = m.id`).
- **`COUNT(s.id)`** - counts actual sale IDs and ignores `NULL` values, so a new manager with no sales properly gets `0` instead of `1`.
- **`SUM(s.price)`** - adds up all values in the `price` column to get the total revenue.
- **`GROUP BY`** - groups rows by manager so `COUNT` and `SUM` are calculated per person instead of one single total for the whole table.

---

## 3. Views Created for the Dealership DB

- **`v_managers_public` (Public manager list):** Hides personal phone numbers (`phone`) from the `managers` table and leaves only `id`, `name`, and `surname` for basic privacy/access control.
- **`v_full_sales_report` (Full sales report):** Connects `sales`, `managers`, and `cars` via `INNER JOIN` and gives the columns clean names. Saves time so we don't have to write out two joins every time we want a readable sales table.
- **`v_manager_kpi` (Manager stats / `TEMPTABLE`):** Counts how many cars each manager sold (`COUNT(s.id)`) and their total revenue (`SUM(s.price)`). Uses `LEFT JOIN` so new hires with zero sales still show up in the stats.
- **`v_luxury_sales` (High-value sales / `MERGE` + `CHECK OPTION`):** Shows only deals from `60000.00` and up. Because of `WITH CHECK OPTION`, you can edit deals through this view, but MySQL won't let you drop the price below `60000.00`.
