

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
	start_time TIMESTAMP;
	end_time TIMESTAMP;
	batch_start_time TIMESTAMP;
	batch_end_time TIMESTAMP;
BEGIN
	batch_start_time := clock_timestamp();

	RAISE NOTICE '====================';
	RAISE NOTICE 'Loading Silver Layer';
	RAISE NOTICE '====================';

	RAISE NOTICE '====================';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '====================';
	

	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.CRM_CUST_INFO;
	RAISE NOTICE '>> Inserting Data: silver.crm_cust_info';
	INSERT INTO silver.CRM_CUST_INFO 
	(cst_id, cst_key, cst_firstname, cst_lastname,
	cst_marital_status, cst_gndr, cst_create_date)
	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) cst_firstname,
		TRIM(cst_lastname) cst_lastname,
		CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END cst_marital_status,
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a'
		END cst_gndr,
		cst_create_date
	FROM
	(SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date desc) flag_last
	FROM bronze.CRM_CUST_INFO)t
	WHERE flag_last = 1 AND cst_id is not null;
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> ------------------';
	
	RAISE NOTICE '';
	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.CRM_PRD_INFO;
	RAISE NOTICE '>> Inserting Data: silver.crm_prd_info';
	INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)
	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
		prd_nm,
		COALESCE(prd_cost, 0) prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END prd_line,
		prd_start_dt,
		LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
	FROM bronze.crm_prd_info;
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> ------------------';

	RAISE NOTICE '';
	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
	TRUNCATE TABLE silver.CRM_SALES_DETAILS;
	RAISE NOTICE '>> Inserting Data: silver.crm_sales_details';
	INSERT INTO silver.CRM_SALES_DETAILS(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price)
	SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN SLS_ORDER_DT = 0 OR LENGTH(sls_order_dt::text) != 8 THEN NULL
			ELSE TO_DATE(sls_order_dt::text, 'YYYYMMDD')
		END sls_order_dt, 
		CASE 
			WHEN SLS_SHIP_DT = 0 OR LENGTH(SLS_SHIP_DT::text) != 8 THEN NULL
			ELSE TO_DATE(SLS_SHIP_DT::text, 'YYYYMMDD')
		END SLS_SHIP_DT,
		CASE 
			WHEN SLS_DUE_DT = 0 OR LENGTH(SLS_DUE_DT::text) != 8 THEN NULL
			ELSE TO_DATE(SLS_DUE_DT::text, 'YYYYMMDD')
		END SLS_DUE_DT, 
		CASE
			WHEN sls_sales <= 0 OR sls_sales != (sls_quantity * ABS(sls_price)) THEN (sls_quantity * ABS(sls_price))
			ELSE sls_sales
		END sls_sales, 
		sls_quantity,
		CASE 
			WHEN sls_price is null OR sls_price <= 0
			THEN sls_sales/NULLIF(sls_quantity, 0)
			ELSE sls_price 
		END sls_price
	FROM bronze.CRM_SALES_DETAILS;
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> ------------------';

	RAISE NOTICE '';
	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
	TRUNCATE TABLE silver.erp_cust_az12;
	RAISE NOTICE '>> Inserting Data: silver.erp_cust_az12';
	INSERT INTO silver.ERP_CUST_AZ12 (cid, bdate, gen)
	SELECT 
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END cid,
	CASE 
		WHEN bdate > NOW() THEN NULL
		ELSE bdate
	END bdate,
	CASE 
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END gen
	from bronze.erp_cust_az12;
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> ------------------';
	
	RAISE NOTICE '';
	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;
	RAISE NOTICE '>> Inserting Data: silver.erp_loc_a101';
	INSERT INTO silver.ERP_LOC_A101 (cid, cntry)
	SELECT 
		REPLACE(cid, '-', '') cid,
		CASE
			WHEN UPPER(TRIM(cntry)) = 'AUSTRALIA' THEN 'Australia'
			WHEN UPPER(TRIM(cntry)) IN ('GERMANY', 'DE') THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('US', 'UNITED STATES', 'USA') THEN 'United States'
			WHEN UPPER(TRIM(cntry)) = 'CANADA' THEN 'Canada'
			WHEN UPPER(TRIM(cntry)) = ('FRANCE') THEN 'France'
			ELSE 'n/a'
		END cntry
	FROM bronze.erp_loc_a101;
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> ------------------';
	
	RAISE NOTICE '';
	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	RAISE NOTICE '>> Inserting Data: silver.erp_px_cat_g1v2';
	INSERT INTO silver.ERP_PX_CAT_G1V2 (id, cat, subcat, maintenance)
	SELECT 
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.ERP_PX_CAT_G1V2 EPCGV;
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> ------------------';

	batch_end_time = clock_timestamp();
	RAISE NOTICE '=========================================';
	RAISE NOTICE 'Silver Layer Load Completed';
	RAISE NOTICE '	- Total Load Duration: % seconds', ROUND(EXTRACT
				(EPOCH FROM (batch_end_time - batch_start_time))::numeric, 2);
	RAISE NOTICE '=========================================';
EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Error occured: %', SQLERRM;
END;
$$;
