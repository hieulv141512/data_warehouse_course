WITH dim_product__source AS (
  SELECT *
  FROM `vit-lam-data.wide_world_importers.warehouse__stock_items`
),

dim_product__rename_column AS (
  SELECT
    stock_item_id AS	product_key,
    stock_item_name AS	product_name,
    supplier_id AS supplier_key,
    brand AS brand_name_nullable,
    is_chiller_stock AS is_chiller_stock_boolean
  FROM dim_product__source
),

dim_product__cast_type AS (
  SELECT 
    CAST(product_key AS INTEGER) AS	product_key,
    CAST(product_name AS STRING) AS	product_name,
    CAST(supplier_key AS INTEGER) AS supplier_key,
    CAST(brand_name_nullable AS STRING) AS brand_name_nullable,
    CAST(is_chiller_stock_boolean AS BOOLEAN) AS is_chiller_stock_boolean
  FROM dim_product__rename_column
),

dim_product__convert_boolean AS (
  SELECT 
    *,
    CASE 
      WHEN is_chiller_stock_boolean IS TRUE THEN 'Chiller Stock'
      WHEN is_chiller_stock_boolean IS FALSE THEN 'Not Chiller Stock'
      WHEN is_chiller_stock_boolean IS NULL THEN 'Undefined'
      ELSE 'Invalid' END 
    AS is_chiller_stock
  FROM dim_product__cast_type
),

dim_product__handle_null AS (
  SELECT 
    dim_product.product_key,
    dim_product.product_name,
    dim_product.supplier_key,
    COALESCE(dim_supplier.supplier_name, "Undefined") AS supplier_name,
    COALESCE(dim_product.brand_name_nullable, "Undefined") AS brand_name,
    dim_product.is_chiller_stock
  FROM dim_product__convert_boolean AS dim_product
  LEFT JOIN {{ ref('dim_supplier') }} AS dim_supplier
  ON dim_product.supplier_key = dim_supplier.supplier_key
)

SELECT 
  product_key,
  product_name,
  supplier_key,
  supplier_name,
  brand_name,
  is_chiller_stock
FROM dim_product__handle_null