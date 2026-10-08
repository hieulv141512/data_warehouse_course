WITH dim_product__source AS (
  SELECT *
  FROM `vit-lam-data.wide_world_importers.warehouse__stock_items`
)

, dim_product__rename_column AS (
  SELECT
    stock_item_id AS	product_key
    , stock_item_name AS	product_name
    , lead_time_days AS lead_time_days
    , is_chiller_stock AS is_chiller_stock_boolean
    , supplier_id AS supplier_key
    , color_id AS color_key
    , unit_package_id AS unit_package_type_key
    , outer_package_id AS outer_package_type_key
  FROM dim_product__source
)

, dim_product__cast_type AS (
  SELECT 
    CAST(product_key AS INTEGER) AS	product_key
    , CAST(product_name AS STRING) AS	product_name
    , CAST(lead_time_days AS INTEGER) AS lead_time_days
    , CAST(is_chiller_stock_boolean AS BOOLEAN) AS is_chiller_stock_boolean
    , CAST(supplier_key AS INTEGER) AS supplier_key
    , CAST(color_key AS INTEGER) AS color_key
    , CAST(unit_package_type_key AS INTEGER) AS unit_package_type_key
    , CAST(outer_package_type_key AS INTEGER) AS outer_package_type_key
  FROM dim_product__rename_column
)

, dim_product__handle_null AS (
  SELECT 
    dim_product.product_key
    , dim_product.product_name
    , dim_product.lead_time_days
    , CASE 
        WHEN dim_product.is_chiller_stock_boolean IS TRUE THEN "Chiller Stock"
        WHEN dim_product.is_chiller_stock_boolean IS FALSE THEN "Not Chiller Stock"
        WHEN dim_product.is_chiller_stock_boolean IS NULL THEN "Undefined"
        ELSE "Invalid"
      END AS is_chiller_stock
    , dim_product.supplier_key
    , COALESCE(dim_supplier.supplier_name, "Undefined") AS supplier_name
    , COALESCE(dim_supplier.supplier_reference, "Undefined") AS supplier_reference
    , COALESCE(dim_supplier.primary_contact_person_key, -1) AS primary_contact_person_key
    , COALESCE(dim_supplier.primary_contact_person_name, "Undefined") AS primary_contact_person_name
    , COALESCE(dim_supplier.alternate_contact_person_key, -1) AS alternate_contact_person_key
    , COALESCE(dim_supplier.alternate_contact_person_name, "Undefined") AS alternate_contact_person_name
    , COALESCE(dim_supplier.delivery_method_key, -1) AS delivery_method_key
    , COALESCE(dim_supplier.delivery_method_name, "Undefined") AS delivery_method_name
    , COALESCE(dim_supplier.delivery_city_key, -1) AS delivery_city_key
    , COALESCE(dim_supplier.delivery_city_name, "Undefined") AS delivery_city_name
    , COALESCE(dim_supplier.delivery_state_province_key, -1) AS delivery_state_province_key
    , COALESCE(dim_supplier.delivery_state_province_name, "Undefined") AS delivery_state_province_name
    , COALESCE(dim_supplier.postal_city_key, -1) AS postal_city_key
    , COALESCE(dim_supplier.postal_city_name, "Undefined") AS postal_city_name
    , COALESCE(dim_supplier.postal_state_province_key, -1) AS postal_state_province_key
    , COALESCE(dim_supplier.postal_state_province_name, "Undefined") AS postal_state_province_name
    , dim_product.color_key
    , COALESCE(dim_color.color_name, "Undefined") AS color_name
    , dim_product.unit_package_type_key
    , COALESCE(dim_unit_package_type.package_type_name, "Undefined") AS unit_package_type_name
    , dim_product.outer_package_type_key
    , COALESCE(dim_outer_package_type.package_type_name, "Undefined") AS outer_package_type_name
  FROM dim_product__cast_type AS dim_product
  LEFT JOIN {{ ref('stg_dim_supplier') }} AS dim_supplier
    ON dim_product.supplier_key = dim_supplier.supplier_key
  LEFT JOIN {{ ref("stg_dim_color") }} AS dim_color
    ON dim_product.color_key = dim_color.color_key
  LEFT JOIN {{ ref("dim_package_type") }} AS dim_unit_package_type
    ON dim_product.unit_package_type_key = dim_unit_package_type.package_type_key
  LEFT JOIN {{ ref("dim_package_type") }} AS dim_outer_package_type
    ON dim_product.outer_package_type_key = dim_outer_package_type.package_type_key
)

, dim_product__add_undefined_record AS (
  SELECT 
    product_key
    , product_name
    , lead_time_days
    , is_chiller_stock
    , supplier_key
    , supplier_name
    , supplier_reference
    , primary_contact_person_key
    , primary_contact_person_name
    , alternate_contact_person_key
    , alternate_contact_person_name
    , delivery_method_key
    , delivery_method_name
    , delivery_city_key
    , delivery_city_name
    , delivery_state_province_key
    , delivery_state_province_name
    , postal_city_key
    , postal_city_name
    , postal_state_province_key
    , postal_state_province_name
    , color_key
    , color_name
    , unit_package_type_key
    , unit_package_type_name
    , outer_package_type_key
    , outer_package_type_name
  FROM dim_product__handle_null

  UNION ALL

  SELECT 
    0 AS product_key
    , "Undefined" AS product_name
    , 0 AS lead_time_days
    , "Undefined" AS is_chiller_stock
    , 0 AS supplier_key
    , "Undefined" AS supplier_name
    , "Undefined" AS supplier_reference
    , 0 AS primary_contact_person_key
    , "Undefined" AS primary_contact_person_name
    , 0 AS alternate_contact_person_key
    , "Undefined" AS alternate_contact_person_name
    , 0 AS delivery_method_key
    , "Undefined" AS delivery_method_name
    , 0 AS delivery_city_key
    , "Undefined" AS delivery_city_name
    , 0 AS delivery_state_province_key
    , "Undefined" AS delivery_state_province_name
    , 0 AS postal_city_key
    , "Undefined" AS postal_city_name
    , 0 AS postal_state_province_key
    , "Undefined" AS postal_state_province_name
    , 0 AS color_key
    , "Undefined" AS color_name
    , 0 AS unit_package_type_key
    , "Undefined" AS unit_package_type_name
    , 0 AS outer_package_type_key
    , "Undefined" AS outer_package_type_name

  UNION ALL

  SELECT 
    -1 AS product_key
    , "Invalid" AS product_name
    , -1 AS lead_time_days
    , "Invalid" AS is_chiller_stock
    , -1 AS supplier_key
    , "Invalid" AS supplier_name
    , "Invalid" AS supplier_reference
    , -1 AS primary_contact_person_key
    , "Invalid" AS primary_contact_person_name
    , -1 AS alternate_contact_person_key
    , "Invalid" AS alternate_contact_person_name
    , -1 AS delivery_method_key
    , "Invalid" AS delivery_method_name
    , -1 AS delivery_city_key
    , "Invalid" AS delivery_city_name
    , -1 AS delivery_state_province_key
    , "Invalid" AS delivery_state_province_name
    , -1 AS postal_city_key
    , "Invalid" AS postal_city_name
    , -1 AS postal_state_province_key
    , "Invalid" AS postal_state_province_name
    , -1 AS color_key
    , "Invalid" AS color_name
    , -1 AS unit_package_type_key
    , "Invalid" AS unit_package_type_name
    , -1 AS outer_package_type_key
    , "Invalid" AS outer_package_type_name
)

SELECT 
  product_key
  , product_name
  , lead_time_days
  , is_chiller_stock
  , supplier_key
  , supplier_name
  , supplier_reference
  , primary_contact_person_key
  , primary_contact_person_name
  , alternate_contact_person_key
  , alternate_contact_person_name
  , delivery_method_key
  , delivery_method_name
  , delivery_city_key
  , delivery_city_name
  , delivery_state_province_key
  , delivery_state_province_name
  , postal_city_key
  , postal_city_name
  , postal_state_province_key
  , postal_state_province_name
  , color_key
  , color_name
  , unit_package_type_key
  , unit_package_type_name
  , outer_package_type_key
  , outer_package_type_name
FROM dim_product__add_undefined_record