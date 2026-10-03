/*
======================================================
DDL Script: Create Gold Views
======================================================
Script Purpose:
  This script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)

  Each view performs transformations and combines data from the Silver layer
  to produce a clean, enriched, and business-ready dataset.

Usage:
  - These views can be queried directly for analytics and reporting.
======================================================
*/

CREATE OR REPLACE VIEW gold.Dim_Customers AS (
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	ci.cst_id customer_id,
	ci.cst_key customer_number,
	ci.cst_firstname first_name,
	ci.cst_lastname last_name,
	ci.cst_marital_status marital_status,
	eca.bdate birth_date,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(eca.gen, 'n/a')
	END gender,
	ela.cntry country,
	ci.cst_create_date create_date
FROM silver.CRM_CUST_INFO ci
LEFT JOIN silver.ERP_CUST_AZ12 eca
ON ci.cst_key = eca.cid
LEFT JOIN silver.ERP_LOC_A101 ela
ON ci.cst_key = ela.cid);

CREATE OR REPLACE VIEW gold.Dim_Products AS
(SELECT
	ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
	cpi.prd_id product_id,
	cpi.prd_key product_number,
	cpi.prd_nm product_name,
	cpi.cat_id category_id,
	epcgv.cat category,
	epcgv.subcat subcategory,
	epcgv.maintenance,
	cpi.prd_cost cost,
	cpi.prd_line product_line,
	cpi.prd_start_dt start_date
FROM SILVER.CRM_PRD_INFO CPI 
LEFT JOIN SILVER.ERP_PX_CAT_G1V2 EPCGV
ON CPI.CAT_ID = EPCGV.id
WHERE prd_end_dt is null)

CREATE OR REPLACE VIEW gold.fact_sales AS(
SELECT 
	CSD.sls_ord_num order_number,
	dp.PRODUCT_KEY, 
	dc.CUSTOMER_KEY,
	CSD.sls_order_dt order_date,
	CSD.sls_ship_dt shipping_date,
	CSD.sls_due_dt due_date,
	CSD.sls_sales sales_amount,
	CSD.sls_quantity quantity,
	CSD.sls_price price
FROM silver.CRM_SALES_DETAILS CSD
LEFT JOIN gold.DIM_CUSTOMERS DC 
ON CSD.SLS_CUST_ID = dc.CUSTOMER_ID
LEFT JOIN gold.DIM_PRODUCTS DP 
ON CSD.SLS_PRD_KEY = dp.PRODUCT_NUMBER);



