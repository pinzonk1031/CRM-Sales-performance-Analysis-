-- Removes safe between GTXPro allowing for proper measurements
UPDATE sales_pipeline
SET product = 'GTX Pro'
WHERE product = 'GTXPro';

-- Top Product  Sales Revenue 
SELECT p.product, p.series,COUNT(pl.opportunity_id) AS opportunities,
		ROUND(SUM(pl.close_value),2) AS total_sales_revenue
FROM products p 
INNER JOIN sales_pipeline pl
ON p.product = pl.product
GROUP BY p.product, p.series
ORDER BY total_sales_revenue DESC;

-- Quarterly Sales and Percent of Total Sales.
SELECT year,
		quarter,
        total_per_quarter,
        ROUND(total_per_quarter/ SUM(total_per_quarter) OVER() * 100, 2) AS per_per_quarter
        FROM
(SELECT YEAR(close_date) AS year,
		QUARTER(close_date) AS quarter,
        SUM(close_value) AS total_per_quarter
	FROM sales_pipeline
    WHERE deal_stage = 'Won'
    GROUP BY YEAR(close_date),QUARTER(close_date)
    )AS t
    ORDER BY quarter;
        
-- Flagging lagging Sales agent
SELECT sales_agent,
	   total_revenue,
       CASE 
			WHEN total_revenue < company_avg THEN 'Yes'
            ELSE  'No'
	  END AS flag
      FROM 
(SELECT st.sales_agent,
	ROUND(SUM(sp.close_value),2) AS total_revenue,
    ROUND(AVG(SUM(sp.close_value)) OVER() ,2) AS company_avg
FROM sales_teams st
JOIN sales_pipeline sp
ON st.sales_agent = sp.sales_agent
WHERE sp.deal_stage = 'Won'
GROUP BY sales_agent) AS t 
ORDER BY total_revenue DESC;

-- Team Performances Summary
SELECT st.manager,
	   st.regional_office,
       COUNT(*) AS deal_closed,
       SUM(pl.close_value) AS total_value_closed,
       ROUND(AVG(pl.close_value),2) AS Avg_value_closed
	FROM sales_teams st
    JOIN sales_pipeline pl
    ON st.sales_agent = pl.sales_agent
    WHERE pl.deal_stage = 'Won'
    GROUP BY st.manager, st.regional_office
    ORDER BY total_value_closed DESC;