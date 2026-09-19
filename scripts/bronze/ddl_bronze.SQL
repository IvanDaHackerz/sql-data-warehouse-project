/*
====================================================
DDL Script: Create and Load Bronze Tables
====================================================
Script Purpose:
  This script creates tables in the 'bronze' schema, dropping existing tables
  if they already exist. Run this script to re-define the DDL Structure of 'bronze' Tables.
*/


CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
	RAISE NOTICE 'Loading Bronze Layer';
	RAISE NOTICE '====================';

	RAISE NOTICE '---------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '---------------------';
	
	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;
	RAISE NOTICE '>> Inserting Data: bronze.crm_cust_info';
	COPY bronze.crm_cust_info
	FROM 'D:/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
	WITH (
		FORMAT csv,
		HEADER true,
		DELIMITER ','
	);
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> --------------------';
	

	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info;
	RAISE NOTICE '>> Inserting Data: bronze.crm_prd_info';
	COPY bronze.crm_prd_info
	FROM 'D:/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
	WITH (
		FORMAT csv,
		HEADER true,
		DELIMITER ','
	);
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> --------------------';

	start_time := clock_timestamp();	
	RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details;
	
	RAISE NOTICE '>> Inserting Data: bronze.crm_sales_details';
	COPY bronze.crm_sales_details
	FROM 'D:/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
	WITH (
		FORMAT csv,
		HEADER true,
		DELIMITER ','
	);
	end_time := clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> --------------------';

	RAISE NOTICE '---------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE '---------------------';
	
	start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12;
	
	RAISE NOTICE '>> Inserting Data: bronze.erp_cust_az12';
	COPY bronze.erp_cust_az12
	FROM 'D:/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
	WITH (
		FORMAT csv,
		HEADER true,
		DELIMITER ','
	);
	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> --------------------';

	start_time = clock_timestamp();
	RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
	TRUNCATE TABLE bronze.erp_loc_a101;
	
	RAISE NOTICE '>> Inserting Data: bronze.erp_loc_a101';
	COPY bronze.erp_loc_a101
	FROM 'D:/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
	WITH (
		FORMAT csv,
		HEADER true,
		DELIMITER ','
	);
	end_time = clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> --------------------';

	start_time = clock_timestamp();
	RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
	RAISE NOTICE '>> Inserting Data: bronze.erp_px_cat_g1v2';
	COPY bronze.erp_px_cat_g1v2
	FROM 'D:/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
	WITH (
		FORMAT csv,
		HEADER true,
		DELIMITER ','
	);
	end_time = clock_timestamp();
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 2);
	RAISE NOTICE '>> --------------------';

	batch_end_time = clock_timestamp();	
	RAISE NOTICE '=========================================';
	RAISE NOTICE 'Bronze Layer Load Completed';
	RAISE NOTICE '	- Total Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (batch_end_time -
															batch_start_time))::numeric, 2);
	RAISE NOTICE '=========================================';
EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Error occurred: %', SQLERRM;
END;
$$;



