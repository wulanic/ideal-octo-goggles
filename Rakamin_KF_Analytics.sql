-- Step 1: Define a Common Table Expression (CTE) named cte_transaction
-- This CTE prepares the data needed for further analysis
WITH cte_transaction AS (
   -- Step 2: Select relevant columns from kf_final_transaction table (f) and join with other tables
  SELECT
    f.transaction_id,
    f.date,
    f.branch_id,
    c.branch_name,
    c.kota,
    c.provinsi,
    c.rating AS rating_cabang,
    f.customer_name,
    f.product_id,
    p.product_name,
    f.price AS actual_price,
    f.discount_percentage,
    -- Step 3: Calculate gross profit percentage based on product price
    CASE
      WHEN f.price <= 50000 THEN 0.1
      WHEN f.price > 50000 AND f.price <= 100000 THEN 0.15
      WHEN f.price > 100000 AND f.price <= 300000 THEN 0.2
      WHEN f.price > 300000 AND f.price <= 500000 THEN 0.25
      ELSE 0.3
    END AS persentase_gross_laba,
    -- Step 4: Calculate net sales after applying discount
    CASE
      WHEN f.price <= 50000 THEN f.price - (f.price * 0.1)
      WHEN f.price > 50000 AND f.price <= 100000 THEN f.price - (f.price * 0.15)
      WHEN f.price > 100000 AND f.price <= 300000 THEN f.price - (f.price * 0.2)
      WHEN f.price > 300000 AND f.price <= 500000 THEN f.price - (f.price * 0.25)
      ELSE f.price - (f.price * 0.3)
    END AS nett_sales,
    f.rating AS rating_transaksi 
  FROM kimia_farma.kf_final_transaction AS f
   -- Join with kf_product table (p) to get product information
  JOIN
    kimia_farma.kf_product AS p ON f.product_id = p.product_id
    -- Join with kf_inventory table (i) to ensure product availability in the branch
  JOIN
    kimia_farma.kf_inventory AS i ON f.branch_id = i.branch_id AND f.product_id = i.product_id
    -- Join with kf_kantor_cabang table (c) to get branch information
  JOIN
    kimia_farma.kf_kantor_cabang AS c ON f.branch_id = c.branch_id
)
-- Step 5: Select columns from the cte_transaction CTE and calculate net profit
-- Calculate net profit by multiplying nett_sales with persentase_gross_laba
SELECT
  transaction_id,
  date,
  branch_id,
  branch_name,
  kota,
  provinsi,
  rating_cabang,
  customer_name,
  product_id,
  product_name,
  actual_price,
  discount_percentage,
  persentase_gross_laba,
  nett_sales,
  nett_sales * persentase_gross_laba AS nett_profit,
  rating_transaksi 
FROM cte_transaction;
