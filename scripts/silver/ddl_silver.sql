/*
====================================================
DDL Script: Create Silver Tables
====================================================
Script Purpose:
  This script creates tables in the 'silver' schema, dropping existing tables
  if they already exist. Run this script to re-define the DDL Structure of 'silver' Tables.
*/

DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
	cst_id int4 NULL,
	cst_key varchar(50) NULL,
	cst_firstname varchar(50) NULL,
	cst_lastname varchar(50) NULL,
	cst_marital_status varchar(50) NULL,
	cst_gndr varchar(50) NULL,
	cst_create_date date NULL,
	dwh_create_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
	prd_id int4 NULL,
	cat_id varchar(50),
	prd_key varchar(50) NULL,
	prd_nm varchar(100) NULL,
	prd_cost float8 NULL,
	prd_line varchar(50) NULL,
	prd_start_dt date NULL,
	prd_end_dt date NULL,
	dwh_create_date TIMESTAMP DEFAULT NOW()
);


DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
	sls_ord_num varchar(50) NULL,
	sls_prd_key varchar(50) NULL,
	sls_cust_id int4 NULL,
	sls_order_dt DATE NULL,
	sls_ship_dt DATE NULL,
	sls_due_dt DATE NULL,
	sls_sales float8 NULL,
	sls_quantity int4 NULL,
	sls_price float8 NULL,
	dwh_create_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
	cid varchar(50) NULL,
	bdate date NULL,
	gen varchar(20) NULL,
	dwh_create_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
	cid varchar(50) NULL,
	cntry varchar(50) NULL,
	dwh_create_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
	id varchar(50) NULL,
	cat varchar(50) NULL,
	subcat varchar(50) NULL,
	maintenance varchar(10) NULL,
	dwh_create_date TIMESTAMP DEFAULT NOW()
);
