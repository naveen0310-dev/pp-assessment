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
SELECT billing_month, item_name, total_quantity,
       CASE 
           WHEN r_desc = 1 THEN 'Most Ordered'
           WHEN r_asc = 1 THEN 'Least Ordered'
       END AS status
FROM (
    SELECT 
        EXTRACT(MONTH FROM c.bill_date) AS billing_month,
        i.item_name,
        SUM(c.item_quantity) AS total_quantity,
        RANK() OVER(PARTITION BY EXTRACT(MONTH FROM c.bill_date) 
                    ORDER BY SUM(c.item_quantity) DESC) AS r_desc,
        RANK() OVER(PARTITION BY EXTRACT(MONTH FROM c.bill_date) 
                    ORDER BY SUM(c.item_quantity) ASC) AS r_asc
    FROM booking_commercials c
    JOIN items i ON c.item_id = i.item_id
    WHERE EXTRACT(YEAR FROM c.bill_date) = 2021
    GROUP BY billing_month, i.item_name
) t
WHERE r_desc = 1 OR r_asc = 1;

-- 5. Find the customers with the second highest bill value of each month of year 2021
SELECT billing_month, user_id, bill_id, bill_amount
FROM (
    SELECT 
        EXTRACT(MONTH FROM c.bill_date) AS billing_month,
        b.user_id,
        c.bill_id,
        SUM(c.item_quantity * i.item_rate) AS bill_amount,
        DENSE_RANK() OVER(PARTITION BY EXTRACT(MONTH FROM c.bill_date) 
                          ORDER BY SUM(c.item_quantity * i.item_rate) DESC) AS rnk
    FROM booking_commercials c
    JOIN bookings b ON c.booking_id = b.booking_id
    JOIN items i ON c.item_id = i.item_id
    WHERE EXTRACT(YEAR FROM c.bill_date) = 2021
    GROUP BY billing_month, b.user_id, c.bill_id
) t
WHERE rnk = 2;
