/*
===========================================================
PROYECTO: Análisis de Ventas y Crecimiento - E-commerce
FASE 1: Análisis en SQL Server
Autor: Bryan Barrios
Objetivo: Evaluar comportamiento de ventas y crecimiento
===========================================================
*/

USE EcommerceDB;
GO

/*===========================================================
1️⃣ EXPLORACIÓN INICIAL
===========================================================*/

-- Total de registros
SELECT COUNT(*) AS total_rows
FROM ecommerce;

-- Rango de fechas
SELECT 
    MIN(Order_Date) AS start_date,
    MAX(Order_Date) AS end_date
FROM ecommerce;


/*===========================================================
2️⃣ KPIs PRINCIPALES
===========================================================*/

-- Ventas Totales
SELECT 
    SUM(Sales) AS total_sales
FROM ecommerce;

-- Total de órdenes (cada fila representa una orden)
SELECT 
    COUNT(*) AS total_orders
FROM ecommerce;

-- Ticket promedio por orden
SELECT 
    AVG(Sales) AS average_ticket
FROM ecommerce;


/*===========================================================
3️⃣ VENTAS MENSUALES
===========================================================*/

-- Ventas por mes
SELECT 
    FORMAT(Order_Date, 'yyyy-MM') AS month,
    SUM(Sales) AS monthly_sales
FROM ecommerce
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY month;

-- Estadísticas de ventas mensuales (min, max, promedio)
SELECT 
    MIN(monthly_sales) AS min_sales,
    MAX(monthly_sales) AS max_sales,
    AVG(monthly_sales) AS avg_sales
FROM (
    SELECT 
        FORMAT(Order_Date, 'yyyy-MM') AS month,
        SUM(Sales) AS monthly_sales
    FROM ecommerce
    GROUP BY FORMAT(Order_Date, 'yyyy-MM')
) t;


/*
ANÁLISIS:
Las ventas mensuales presentan variaciones moderadas (~45% respecto al promedio),
lo que sugiere comportamiento estacional sin evidencia de crisis estructural.
*/


/*===========================================================
4️⃣ CRECIMIENTO MENSUAL (%)
===========================================================*/

WITH monthly_sales AS (
    SELECT 
        FORMAT(Order_Date, 'yyyy-MM') AS month,
        SUM(Sales) AS monthly_sales
    FROM ecommerce
    GROUP BY FORMAT(Order_Date, 'yyyy-MM')
)

SELECT 
    month,
    monthly_sales,
    LAG(monthly_sales) OVER (ORDER BY month) AS previous_month,
    ROUND(
        ((monthly_sales - LAG(monthly_sales) OVER (ORDER BY month)) * 100.0 
        / LAG(monthly_sales) OVER (ORDER BY month)), 2
    ) AS growth_percentage
FROM monthly_sales;


/*
ANÁLISIS:
Se observan fluctuaciones mensuales con meses de caída y recuperación,
indicando variabilidad estacional y no deterioro continuo.
*/


/*===========================================================
5️⃣ VENTAS ANUALES
===========================================================*/

SELECT 
    YEAR(Order_Date) AS year,
    SUM(Sales) AS total_sales
FROM ecommerce
GROUP BY YEAR(Order_Date)
ORDER BY year;


/*
RESULTADOS OBSERVADOS:
2022 → 3,255,970
2023 → 3,786,592
2024 → 3,625,319
*/


/*===========================================================
6️⃣ CRECIMIENTO ANUAL (%)
===========================================================*/

WITH yearly_sales AS (
    SELECT 
        YEAR(Order_Date) AS year,
        SUM(Sales) AS total_sales
    FROM ecommerce
    GROUP BY YEAR(Order_Date)
)

SELECT 
    year,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year) AS previous_year,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY year)) * 100.0 
        / LAG(total_sales) OVER (ORDER BY year)), 2
    ) AS growth_percentage
FROM yearly_sales;


/*
ANÁLISIS:
2022 → 2023: +16.30% (crecimiento fuerte)
2023 → 2024: -4.26% (leve desaceleración)

Conclusión:
El negocio experimentó expansión acelerada en 2023,
seguida de estabilización en 2024.
*/


/*===========================================================
7️⃣ CRECIMIENTO ACUMULADO 2022-2024
===========================================================*/

SELECT 
    SUM(CASE WHEN YEAR(Order_Date) = 2022 THEN Sales END) AS sales_2022,
    SUM(CASE WHEN YEAR(Order_Date) = 2024 THEN Sales END) AS sales_2024
FROM ecommerce;


/*
Cálculo manual:
(3,625,319 - 3,255,970) / 3,255,970 ≈ 11.35%

Conclusión:
A pesar de la desaceleración en 2024, el negocio mantiene
un crecimiento acumulado positivo del 11.35%.
*/


/*===========================================================
8️⃣ ANÁLISIS POR CATEGORÍA
===========================================================*/

SELECT 
    YEAR(Order_Date) AS year,
    Category,
    SUM(Sales) AS total_sales
FROM ecommerce
GROUP BY YEAR(Order_Date), Category
ORDER BY year, total_sales DESC;


/*
Hallazgo:
No hubo una categoría con colapso significativo en 2024.
La categoría Office mostró la mayor reducción (~8.5%),
pero el comportamiento general fue de ligera desaceleración.
*/


/*===========================================================
CONCLUSIÓN GENERAL – FASE 1
===========================================================*/

-- El negocio creció 11.35% desde 2022.
-- 2023 fue el año de mayor expansión (+16.3%).
-- 2024 presentó una leve corrección (-4.26%).
-- No se identifican caídas estructurales.
-- El comportamiento sugiere estacionalidad y estabilización.

