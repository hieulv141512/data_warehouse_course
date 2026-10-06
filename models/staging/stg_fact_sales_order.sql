WITH fact_sales_order__source AS (
  SELECT *
  FROM `vit-lam-data.wide_world_importers.sales__orders`
),

fact_sales_order__rename_column AS (
  SELECT
    order_id AS sales_order_key,
    customer_id AS customer_key,
    picked_by_person_id AS picked_by_person_key,
    order_date AS order_date
  FROM fact_sales_order__source
),

fact_sales_order__cast_type AS (
  SELECT
    CAST(sales_order_key AS INTEGER) AS sales_order_key,
    CAST(customer_key AS INTEGER) AS customer_key,
    CAST(picked_by_person_key AS INTEGER) AS picked_by_person_key,
    CAST(order_date AS DATE) AS order_date
  FROM fact_sales_order__rename_column
),

fact_sales_order__handle_null AS (
  SELECT
    fact_order.sales_order_key,
    fact_order.customer_key,
    COALESCE(fact_order.picked_by_person_key, 0) AS picked_by_person_key,
    fact_order.order_date,
    COALESCE(dim_person.full_name, "Undefined") AS full_name
  FROM fact_sales_order__cast_type AS fact_order
  LEFT JOIN {{ ref("dim_person") }} AS dim_person
    ON fact_order.picked_by_person_key = dim_person.person_key
)

SELECT
  sales_order_key,
  customer_key,
  picked_by_person_key,
  order_date,
  full_name
FROM fact_sales_order__handle_null