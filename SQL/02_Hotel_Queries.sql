-- 1. For every user in the system, get the user_id and last booked room_no
WITH RankedBookings AS (
    SELECT 
        user_id, 
        room_no,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY booking_date DESC) as rnk
    FROM bookings
)
SELECT user_id, room_no
FROM RankedBookings
WHERE rnk = 1;

-- 2. Get booking_id and total billing amount of every booking created in November, 2021
SELECT 
    b.booking_id, 
    SUM(c.item_quantity * i.item_rate) as total_billing_amount
FROM bookings b
JOIN booking_commercials c ON b.booking_id = c.booking_id
JOIN items i ON c.item_id = i.item_id
WHERE EXTRACT(MONTH FROM b.booking_date) = 11 AND EXTRACT(YEAR FROM b.booking_date) = 2021
GROUP BY b.booking_id;

-- 3. Get bill_id and bill amount of all the bills raised in October, 2021 having bill amount >1000
SELECT 
    c.bill_id, 
    SUM(c.item_quantity * i.item_rate) as bill_amount
FROM booking_commercials c
JOIN items i ON c.item_id = i.item_id
WHERE EXTRACT(MONTH FROM c.bill_date) = 10 AND EXTRACT(YEAR FROM c.bill_date) = 2021
GROUP BY c.bill_id
HAVING SUM(c.item_quantity * i.item_rate) > 1000;

-- 4. Determine the most ordered and least ordered item of each month of year 2021
WITH MonthlyItemCounts AS (
    SELECT 
        EXTRACT(MONTH FROM c.bill_date) as billing_month,
        c.item_id,
        i.item_name,
        SUM(c.item_quantity) as total_quantity
    FROM booking_commercials c
    JOIN items i ON c.item_id = i.item_id
    WHERE EXTRACT(YEAR FROM c.bill_date) = 2021
    GROUP BY EXTRACT(MONTH FROM c.bill_date), c.item_id, i.item_name
),
RankedItems AS (
    SELECT 
        billing_month,
        item_id,
        item_name,
        total_quantity,
        RANK() OVER(PARTITION BY billing_month ORDER BY total_quantity DESC) as highest_rank,
        RANK() OVER(PARTITION BY billing_month ORDER BY total_quantity ASC) as lowest_rank
    FROM MonthlyItemCounts
)
SELECT 
    billing_month, 
    item_id, 
    item_name, 
    total_quantity,
    CASE 
        WHEN highest_rank = 1 THEN 'Most Ordered'
        WHEN lowest_rank = 1 THEN 'Least Ordered'
    END as status
FROM RankedItems
WHERE highest_rank = 1 OR lowest_rank = 1;

-- 5. Find the customers with the second highest bill value of each month of year 2021
WITH MonthlyBills AS (
    SELECT 
        EXTRACT(MONTH FROM c.bill_date) as billing_month,
        b.user_id,
        c.bill_id,
        SUM(c.item_quantity * i.item_rate) as bill_amount
    FROM booking_commercials c
    JOIN bookings b ON c.booking_id = b.booking_id
    JOIN items i ON c.item_id = i.item_id
    WHERE EXTRACT(YEAR FROM c.bill_date) = 2021
    GROUP BY EXTRACT(MONTH FROM c.bill_date), b.user_id, c.bill_id
),
RankedBills AS (
    SELECT 
        billing_month,
        user_id,
        bill_id,
        bill_amount,
        DENSE_RANK() OVER(PARTITION BY billing_month ORDER BY bill_amount DESC) as rnk
    FROM MonthlyBills
)
SELECT 
    billing_month,
    user_id,
    bill_id,
    bill_amount
FROM RankedBills
WHERE rnk = 2;
