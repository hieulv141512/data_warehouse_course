WITH fact_sales_order_line__source AS (
  SELECT *
  FROM `vit-lam-data.wide_world_importers.sales__order_lines`
)

, fact_sales_order_line__rename_column AS (
  SELECT 
    order_line_id AS sales_order_line_key
    , description AS description
    , picking_completed_when AS line_picking_completed_when
    , quantity
    , unit_price
    , tax_rate
    , order_id AS sales_order_key
    , stock_item_id AS product_key
    , package_type_id AS package_type_key
  FROM fact_sales_order_line__source
)

, fact_sales_order_line__cast_type_column AS (
  SELECT 
    CAST(sales_order_line_key AS INTEGER) AS sales_order_line_key
    , CAST(description AS STRING) AS description
    , CAST(line_picking_completed_when AS DATETIME) AS line_picking_completed_when
    , CAST(quantity AS INTEGER) AS quantity
    , CAST(unit_price AS NUMERIC) AS unit_price
    , CAST(tax_rate AS NUMERIC) AS tax_rate
    , CAST(sales_order_key AS INTEGER) AS sales_order_key
    , CAST(product_key AS INTEGER) AS product_key
    , CAST(package_type_key AS INTEGER) AS package_type_key
  FROM fact_sales_order_line__rename_column
)

, fact_sales_order_line__handle_null AS (
  SELECT 
    fact_line.sales_order_line_key
    , fact_line.description
    , fact_line.line_picking_completed_when
    , fact_line.quantity
    , fact_line.unit_price
    , fact_line.tax_rate
    , fact_line.quantity * fact_line.unit_price AS gross_amount
    , fact_line.quantity * fact_line.unit_price * fact_line.tax_rate AS tax_amount
    , (fact_line.quantity * fact_line.unit_price) * (1 - fact_line.tax_rate) AS net_amount
    , CONCAT(
        COALESCE(fact_header.is_undersupply_backordered, "Undefined")
        , "_"
        , CAST(fact_line.package_type_key AS STRING)
      ) AS sales_order_line_indicator_key
    , COALESCE(fact_header.order_date, DATE '1900-01-01') AS order_date
    , COALESCE(fact_header.expected_delivery_date, DATE '1900-01-01') AS expected_delivery_date
    , COALESCE(fact_header.picking_completed_when, DATETIME '1900-01-01 00:00:00') AS order_picking_completed_when
    , COALESCE(fact_header.salesperson_person_key, -1) AS salesperson_person_key
    , COALESCE(fact_header.picked_by_person_key, -1) AS picked_by_person_key
    , COALESCE(fact_header.customer_key, -1) AS customer_key
    , fact_line.product_key
  FROM fact_sales_order_line__cast_type_column AS fact_line
  LEFT JOIN {{ ref('stg_fact_sales_order') }} AS fact_header
    ON fact_line.sales_order_key = fact_header.sales_order_key
)

SELECT 
  sales_order_line_key
  , description 
  , line_picking_completed_when
  , quantity
  , unit_price
  , tax_rate
  , gross_amount
  , tax_amount
  , net_amount
  , sales_order_line_indicator_key
  , order_date
  , expected_delivery_date
  , order_picking_completed_when
  , salesperson_person_key
  , picked_by_person_key
  , customer_key
  , product_key
FROM fact_sales_order_line__handle_null