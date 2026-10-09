WITH dim_is_undersupply_backordered AS (
  SELECT
    TRUE AS is_undersupply_backordered_boolean
    , "Undersupply Backordered" AS is_undersupply_backordered
  
  UNION ALL

  SELECT
    FALSE AS is_undersupply_backordered_boolean
    , "Not Undersupply Backordered" AS is_undersupply_backordered
)

, dim_sales_order_line_indicator__cross_join AS (
  SELECT *
  FROM dim_is_undersupply_backordered
  CROSS JOIN {{ ref("dim_package_type") }} AS dim_package_type
  ORDER BY 1, 3
)

SELECT 
  CONCAT(
    is_undersupply_backordered,
    "_", 
    CAST(package_type_key AS STRING)
  ) AS sales_order_line_indicator_key
  , *
FROM dim_sales_order_line_indicator__cross_join
