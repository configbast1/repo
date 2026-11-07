USE [Store]
GO

-- 1. Всі продажі, де є продукти з відділу "Молочка" (в БД: "Молочна продукція")
CREATE OR ALTER VIEW vw_DairySales AS
SELECT s.id           AS sale_id,
       s.date_of_sale,
       p.name         AS product,
       s.quantity,
       s.price,
       s.quantity * s.price AS total
FROM Sale s
JOIN Product  p ON p.id = s.id_product
JOIN Category c ON c.id = p.id_category
WHERE c.name = N'Молочна продукція';
GO

-- 2. Продукти з категорії "М'ясо", яких на складі менше 50 одиниць
CREATE OR ALTER VIEW vw_MeatLowStock AS
SELECT p.id, p.name, p.quantity, p.price
FROM Product p
JOIN Category c ON c.id = p.id_category
WHERE c.name = N'М''ясо'
  AND p.quantity < 50;
GO

-- 3. Найбільш продавані товари з відділу "Канцтовари" за останні 3 місяці
CREATE OR ALTER VIEW vw_TopStationery3M AS
SELECT TOP (10) WITH TIES
       p.id,
       p.name,
       SUM(s.quantity)           AS total_sold,
       SUM(s.quantity * s.price) AS revenue
FROM Sale s
JOIN Product  p ON p.id = s.id_product
JOIN Category c ON c.id = p.id_category
WHERE c.name = N'Канцтовари'
  AND s.date_of_sale >= DATEADD(MONTH, -3, CAST(GETDATE() AS date))
GROUP BY p.id, p.name
ORDER BY total_sold DESC;
GO

-- 4. Статистика продажів по "Молочка" і "М'ясо" по місяцях за останній рік
CREATE OR ALTER VIEW vw_DairyMeatMonthlyStats AS
SELECT c.name                    AS category,
       p.name                    AS product,
       YEAR(s.date_of_sale)      AS [year],
       MONTH(s.date_of_sale)     AS [month],
       COUNT(*)                  AS sales_count,
       SUM(s.quantity)           AS total_quantity,
       SUM(s.quantity * s.price) AS revenue
FROM Sale s
JOIN Product  p ON p.id = s.id_product
JOIN Category c ON c.id = p.id_category
WHERE c.name IN (N'Молочна продукція', N'М''ясо')
  AND s.date_of_sale >= DATEADD(YEAR, -1, CAST(GETDATE() AS date))
GROUP BY c.name, p.name, YEAR(s.date_of_sale), MONTH(s.date_of_sale);
GO

-- 5. Товари з "Канцтовари", які жодного разу не продавались за останні 90 днів
CREATE OR ALTER VIEW vw_StationeryNotSold90D AS
SELECT p.id, p.name, p.quantity, p.price
FROM Product p
JOIN Category c ON c.id = p.id_category
WHERE c.name = N'Канцтовари'
  AND NOT EXISTS (
        SELECT 1
        FROM Sale s
        WHERE s.id_product = p.id
          AND s.date_of_sale >= DATEADD(DAY, -90, CAST(GETDATE() AS date))
      );
GO

-- Перевірка (виконуйте по одному і робіть скріни):
-- SELECT * FROM vw_DairySales ORDER BY date_of_sale;
-- SELECT * FROM vw_MeatLowStock;
-- SELECT * FROM vw_TopStationery3M;
-- SELECT * FROM vw_DairyMeatMonthlyStats ORDER BY category, product, [year], [month];
-- SELECT * FROM vw_StationeryNotSold90D;
