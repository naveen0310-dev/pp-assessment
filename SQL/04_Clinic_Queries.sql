-- 1. Find the revenue we got from each sales channel in a given year (e.g., 2021)
SELECT 
    sales_channel,
    SUM(amount) as total_revenue
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY sales_channel;

-- 2. Find top 10 the most valuable customers for a given year (e.g., 2021)
SELECT 
    c.uid,
    c.name,
    SUM(s.amount) as total_spent
FROM clinic_sales s
JOIN customer c ON s.uid = c.uid
WHERE EXTRACT(YEAR FROM s.datetime) = 2021
GROUP BY c.uid, c.name
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Find month wise revenue, expense, profit , status (profitable / not-profitable) for a given year (e.g., 2021)
WITH MonthlyRevenue AS (
    SELECT 
        EXTRACT(MONTH FROM datetime) as month_num,
        SUM(amount) as total_revenue
    FROM clinic_sales
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY EXTRACT(MONTH FROM datetime)
),
MonthlyExpense AS (
    SELECT 
        EXTRACT(MONTH FROM datetime) as month_num,
        SUM(amount) as total_expense
    FROM expenses
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY EXTRACT(MONTH FROM datetime)
)
SELECT 
    COALESCE(r.month_num, e.month_num) as billing_month,
    COALESCE(r.total_revenue, 0) as revenue,
    COALESCE(e.total_expense, 0) as expense,
    COALESCE(r.total_revenue, 0) - COALESCE(e.total_expense, 0) as profit,
    CASE 
        WHEN (COALESCE(r.total_revenue, 0) - COALESCE(e.total_expense, 0)) > 0 THEN 'profitable'
        ELSE 'not-profitable'
    END as status
FROM MonthlyRevenue r
FULL OUTER JOIN MonthlyExpense e ON r.month_num = e.month_num;

-- 4. For each city find the most profitable clinic for a given month (e.g., September 2021)
WITH ClinicProfits AS (
    SELECT 
        c.city,
        c.cid,
        c.clinic_name,
        COALESCE(SUM(s.amount), 0) - COALESCE(SUM(e.amount), 0) as profit
    FROM clinics c
    LEFT JOIN clinic_sales s ON c.cid = s.cid AND EXTRACT(YEAR FROM s.datetime) = 2021 AND EXTRACT(MONTH FROM s.datetime) = 9
    LEFT JOIN expenses e ON c.cid = e.cid AND EXTRACT(YEAR FROM e.datetime) = 2021 AND EXTRACT(MONTH FROM e.datetime) = 9
    GROUP BY c.city, c.cid, c.clinic_name
),
RankedProfits AS (
    SELECT 
        city,
        cid,
        clinic_name,
        profit,
        RANK() OVER(PARTITION BY city ORDER BY profit DESC) as rnk
    FROM ClinicProfits
)
SELECT 
    city,
    cid,
    clinic_name,
    profit
FROM RankedProfits
WHERE rnk = 1;

-- 5. For each state find the second least profitable clinic for a given month (e.g., September 2021)
WITH ClinicProfits AS (
    SELECT 
        c.state,
        c.cid,
        c.clinic_name,
        COALESCE(SUM(s.amount), 0) - COALESCE(SUM(e.amount), 0) as profit
    FROM clinics c
    LEFT JOIN clinic_sales s ON c.cid = s.cid AND EXTRACT(YEAR FROM s.datetime) = 2021 AND EXTRACT(MONTH FROM s.datetime) = 9
    LEFT JOIN expenses e ON c.cid = e.cid AND EXTRACT(YEAR FROM e.datetime) = 2021 AND EXTRACT(MONTH FROM e.datetime) = 9
    GROUP BY c.state, c.cid, c.clinic_name
),
RankedProfits AS (
    SELECT 
        state,
        cid,
        clinic_name,
        profit,
        DENSE_RANK() OVER(PARTITION BY state ORDER BY profit ASC) as rnk
    FROM ClinicProfits
)
SELECT 
    state,
    cid,
    clinic_name,
    profit
FROM RankedProfits
WHERE rnk = 2;
