/*Number of record of the first_purchases file*/
SELECT * FROM dbo.first_purchases;

/*Number of unique User_ID of the first_purchases file*/
SELECT COUNT(DISTINCT dbo.first_purchases.User_ID)
FROM dbo.first_purchases;

/*Check whether there is any User_ID with two Purchase_ID in the first_purchases file*/
SELECT dbo.first_purchases.Purchase_ID, dbo.first_purchases.User_ID
FROM dbo.first_purchases
GROUP BY dbo.first_purchases.Purchase_ID, dbo.first_purchases.User_ID
HAVING COUNT(*) > 1;

/*Number of record of the purchases file*/
SELECT * FROM dbo.purchases;

/*Number of unique User_ID and purchases_ID of purchases file*/
SELECT	count(DISTINCT dbo.purchases.User_ID),
	count(DISTINCT dbo.purchases.Purchase_ID)
FROM dbo.purchases;

/* Check whether there is any duplicate (User_ID and Purchase_ID) in the purchases file*/
SELECT	dbo.purchases.User_ID,
	dbo.purchases.Purchase_ID,
	COUNT(*)
FROM dbo.purchases
GROUP BY dbo.purchases.User_ID, dbo.purchases.Purchase_ID
HAVING COUNT(*) > 1;

/*Unique User_ID appear in purchases file but not in first_purchases file*/
SELECT DISTINCT dbo.purchases.User_ID
FROM dbo.purchases
WHERE dbo.purchases.User_ID NOT IN (	SELECT dbo.first_purchases.User_ID
					FROM dbo.first_purchases);

/*Records appear in purchases file, but not in first_purchases file*/
SELECT * 
FROM dbo.purchases
WHERE dbo.purchases.User_ID NOT IN (	SELECT dbo.first_purchases.User_ID
					FROM dbo.first_purchases);

/*CUSTOMER RETENTION ANALYSIS - Restaurant line-Number of the customer in the end of every month and monthly number of customers acquired*/
SELECT * 
FROM
	(
	SELECT	DAY(dbo.purchases.Purchases_Time_Delivered) as MONTH,
		COUNT(distinct dbo.purchases.User_ID) AS Number_of_customer_in_the_end_of_month
	FROM dbo.purchases
	WHERE dbo.purchases.Product_line = 'Restaurant' AND dbo.purchases.User_ID IN (	SELECT dbo.first_purchases.User_ID
											FROM dbo.first_purchases)
	GROUP BY DAY(dbo.purchases.Purchases_Time_Delivered)
	) AS A
JOIN
(
SELECT 	DAY(dbo.first_purchases.User_First_Purchase_Month) as MONTH,
	COUNT(Distinct dbo.first_purchases.User_ID) AS New_acquired_customers
FROM dbo.first_purchases
WHERE dbo.first_purchases.First_Purchase_Product_Line = 'Restaurant'
GROUP BY DAY(dbo.first_purchases.User_First_Purchase_Month)
) AS B
ON A.MONTH = B.MONTH
ORDER BY A.MONTH;

/*CUSTOMER RETENTION ANALYSIS - Retail stores line-Number of the customer in the end of every month and monthly number of customers acquired*/
SELECT * 
FROM
	(
	SELECT	DAY(dbo.purchases.Purchases_Time_Delivered) as MONTH,
		COUNT(distinct dbo.purchases.User_ID) AS Number_of_customer_in_the_end_of_month
	FROM dbo.purchases
	WHERE dbo.purchases.Product_line = 'Retail store' AND dbo.purchases.User_ID IN (SELECT dbo.first_purchases.User_ID
											FROM dbo.first_purchases)
	GROUP BY DAY(dbo.purchases.Purchases_Time_Delivered)
	) AS A
JOIN
(
SELECT	DAY(dbo.first_purchases.User_First_Purchase_Month) as MONTH,
	COUNT(Distinct dbo.first_purchases.User_ID) AS New_acquired_customers
FROM dbo.first_purchases
WHERE dbo.first_purchases.First_Purchase_Product_Line = 'Retail store'
GROUP BY DAY(dbo.first_purchases.User_First_Purchase_Month)
) AS B
ON A.MONTH = B.MONTH
ORDER BY A.MONTH;

/*REPEAT CUSTOMER RATE ANALYSIS - Restaurant line - Number of repeat users and one time users of the month*/
SELECT	B.MONTH,
		COUNT(B.Number_Of_Order_of_repeat_customer) AS Number_of_repeat_users,
		COUNT(B.Number_of_order_of_one_time_customer) AS Number_of_one_time_users
FROM
		(
		SELECT 
				day(A.Purchases_Time_Delivered) as MONTH, 
				A.Product_line, 
				A.User_ID, 
				CASE WHEN COUNT(*) > 1 THEN COUNT(A.User_ID) END AS Number_Of_Order_of_repeat_customer,
				CASE WHEN COUNT(*) = 1 THEN COUNT(A.User_ID) END AS Number_of_order_of_one_time_customer
		FROM
					(
					SELECT * 
					FROM dbo.purchases
					WHERE dbo.purchases.Product_line = 'Restaurant' AND
					dbo.purchases.User_ID IN (	SELECT dbo.first_purchases.User_ID
									FROM dbo.first_purchases)
					) AS A
		GROUP BY A.Purchases_Time_Delivered, A.Product_line, A.User_ID
		) AS B
GROUP BY B.MONTH
ORDER BY B.MONTH;

/*REPEAT CUSTOMER RATE ANALYSIS - Restaurant line - Number of new users buy one order and more one order of the month*/
SELECT	C.MONTH,
	COUNT(C.number_of_customer_from_first_purchase_file_buy_one_order) AS Number_of_new_users_buy_one_order,
	COUNT(C.number_of_customer_from_first_purchase_file_buy_MORE_one_order) AS Number_of_new_users_buy_MORE_one_order
FROM 
	(
	SELECT	B.MONTH,
			CASE WHEN B.Number_of_order = 1 THEN COUNT (B.User_ID) END AS number_of_customer_from_first_purchase_file_buy_one_order,
			CASE WHEN B.Number_of_order > 1 THEN COUNT (B.User_ID) END AS number_of_customer_from_first_purchase_file_buy_MORE_one_order
	FROM
			(
			SELECT 
					day(A.Purchases_Time_Delivered) as MONTH, 
					A.User_ID,
					COUNT(*) AS Number_of_order
			FROM
					(
					SELECT * FROM dbo.purchases
					WHERE dbo.purchases.Product_line = 'Restaurant' AND
					dbo.purchases.User_ID IN (	SELECT dbo.first_purchases.User_ID
									FROM dbo.first_purchases)
					) AS A
			GROUP BY A.Purchases_Time_Delivered, A.Product_line, A.User_ID
			) AS B
	LEFT JOIN dbo.first_purchases
	ON B.User_ID = dbo.first_purchases.User_ID AND B.MONTH = day(dbo.first_purchases.User_First_Purchase_Month)
	WHERE dbo.first_purchases.First_Purchase_Product_Line = 'Restaurant'
	GROUP BY B.MONTH, B.User_ID, day(dbo.first_purchases.User_First_Purchase_Month), dbo.first_purchases.User_ID, B.Number_of_order
) AS C
GROUP BY MONTH
ORDER BY MONTH


/*REPEAT CUSTOMER RATE ANALYSIS - Retail stores line - Number of repeat users and one time users of the month*/
SELECT	B.MONTH,
		COUNT(B.Number_Of_Order_of_repeat_customer) AS Number_of_repeat_users,
		COUNT(B.Number_of_order_of_one_time_customer) AS Number_of_one_time_users
FROM
		(
		SELECT 
				day(A.Purchases_Time_Delivered) as MONTH, 
				A.Product_line, 
				A.User_ID, 
				CASE WHEN COUNT(*) > 1 THEN COUNT(A.User_ID) END AS Number_Of_Order_of_repeat_customer,
				CASE WHEN COUNT(*) = 1 THEN COUNT(A.User_ID) END AS Number_of_order_of_one_time_customer
		FROM
					(
					SELECT * 
					FROM dbo.purchases
					WHERE dbo.purchases.Product_line = 'Retail store' AND
					dbo.purchases.User_ID IN (	SELECT dbo.first_purchases.User_ID
									FROM dbo.first_purchases)
					) AS A
		GROUP BY A.Purchases_Time_Delivered, A.Product_line, A.User_ID
		) AS B
GROUP BY B.MONTH
ORDER BY B.MONTH;

/*REPEAT CUSTOMER RATE ANALYSIS - Restaurant line - Number of new users buy one order and more one order of the month*/
SELECT	C.MONTH,
		COUNT(C.number_of_customer_from_first_purchase_file_buy_one_order) AS Number_of_new_users_buy_one_order,
		COUNT(C.number_of_customer_from_first_purchase_file_buy_MORE_one_order) AS Number_of_new_users_buy_MORE_one_order
FROM 
	(
	SELECT	B.MONTH,
			CASE WHEN B.Number_of_order = 1 THEN COUNT (B.User_ID) END AS number_of_customer_from_first_purchase_file_buy_one_order,
			CASE WHEN B.Number_of_order > 1 THEN COUNT (B.User_ID) END AS number_of_customer_from_first_purchase_file_buy_MORE_one_order
	FROM
			(
			SELECT 
					day(A.Purchases_Time_Delivered) as MONTH, 
					A.User_ID,
					COUNT(*) AS Number_of_order
			FROM
					(
					SELECT * FROM dbo.purchases
					WHERE dbo.purchases.Product_line = 'Retail store' AND
					dbo.purchases.User_ID IN (	SELECT dbo.first_purchases.User_ID
									FROM dbo.first_purchases)
					) AS A
			GROUP BY A.Purchases_Time_Delivered, A.Product_line, A.User_ID
			) AS B
	LEFT JOIN dbo.first_purchases
	ON B.User_ID = dbo.first_purchases.User_ID AND B.MONTH = day(dbo.first_purchases.User_First_Purchase_Month)
	WHERE dbo.first_purchases.First_Purchase_Product_Line = 'Retail store'
	GROUP BY B.MONTH, B.User_ID, day(dbo.first_purchases.User_First_Purchase_Month), dbo.first_purchases.User_ID, B.Number_of_order
) AS C
GROUP BY MONTH
ORDER BY MONTH

/*Problem of the dataset - Number of unique User_ID of each product line in the first_purchases file*/
SELECT 
CASE WHEN dbo.first_purchases.First_Purchase_Product_Line = 'Restaurant' THEN COUNT(distinct dbo.first_purchases.User_ID) END,
CASE WHEN dbo.first_purchases.First_Purchase_Product_Line = 'Retail store' THEN COUNT(distinct dbo.first_purchases.User_ID) END
FROM dbo.first_purchases
GROUP BY dbo.first_purchases.First_Purchase_Product_Line

/*Problem of the dataset - Number of unique User_ID of each product line in the purchase file*/
SELECT 
CASE WHEN sub.Product_line = 'Restaurant' THEN COUNT(DISTINCT sub.User_ID) END,
CASE WHEN sub.Product_line = 'Retail store' THEN COUNT(DISTINCT sub.User_ID) END
FROM 
	(
	SELECT * FROM dbo.purchases
	WHERE dbo.purchases.User_ID IN (SELECT dbo.first_purchases.User_ID
					FROM dbo.first_purchases )) AS sub
GROUP BY sub.Product_line

/*Problem of the dataset - Number of unique User_ID having both restaurant and retail stores product line*/
SELECT COUNT(DISTINCT A.User_ID)
FROM 
	(	
	SELECT dbo.purchases.User_ID, dbo.purchases.Product_line
	FROM dbo.purchases 
	WHERE dbo.purchases.User_ID IN (SELECT dbo.first_purchases.User_ID FROM dbo.first_purchases)
	) AS A
	JOIN 
	(
	SELECT dbo.purchases.User_ID
	FROM dbo.purchases
	GROUP BY dbo.purchases.User_ID
	HAVING COUNT(DISTINCT dbo.purchases.Product_line)>1) AS B
ON A.User_ID = B.User_ID



