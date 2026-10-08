WITH fact_sales_order__source AS (
  SELECT *
  FROM `vit-lam-data.wide_world_importers.sales__orders`
)

, fact_sales_order__rename_column AS (
  SELECT
    order_id AS sales_order_key
    , is_undersupply_backordered AS is_undersupply_backordered_boolean
    , order_date AS order_date
    , expected_delivery_date AS expected_delivery_date
    , picking_completed_when AS picking_completed_when
    , customer_id AS customer_key
    , salesperson_person_id AS salesperson_person_key
    , picked_by_person_id AS picked_by_person_key
    , contact_person_id AS contact_person_key
    , backorder_order_id AS backorder_order_key
  FROM fact_sales_order__source
)

, fact_sales_order__cast_type AS (
  SELECT
    CAST(sales_order_key AS INTEGER) AS sales_order_key
    , CAST(is_undersupply_backordered_boolean AS BOOLEAN) AS is_undersupply_backordered_boolean
    , CAST(order_date AS DATE) AS order_date
    , CAST(expected_delivery_date AS DATE) AS expected_delivery_date
    , CAST(picking_completed_when AS DATETIME) AS picking_completed_when
    , CAST(customer_key AS INTEGER) AS customer_key
    , CAST(salesperson_person_key AS INTEGER) AS salesperson_person_key
    , CAST(picked_by_person_key AS INTEGER) AS picked_by_person_key
    , CAST(contact_person_key AS INTEGER) AS contact_person_key
    , CAST(backorder_order_key AS INTEGER) AS backorder_order_key
  FROM fact_sales_order__rename_column
)

, fact_sales_order__handle_null AS (
  SELECT
    fact_order.sales_order_key
    , CASE 
        WHEN fact_order.is_undersupply_backordered_boolean IS TRUE THEN "Undersupply Backordered"
        WHEN fact_order.is_undersupply_backordered_boolean IS FALSE THEN "Not Undersupply Backordered"
        WHEN fact_order.is_undersupply_backordered_boolean IS NULL THEN "Undefined"
        ELSE "Invalid"
      END AS is_undersupply_backordered
    , fact_order.order_date
    , fact_order.expected_delivery_date
    , fact_order.picking_completed_when
    , fact_order.customer_key
    , COALESCE(dim_customer.customer_name, "Invalid") AS customer_name
    , fact_order.salesperson_person_key
    , COALESCE(dim_sales_person.full_name, "Invalid") AS sales_person_name
    , fact_order.picked_by_person_key
    , COALESCE(dim_picked_by_person.full_name, "Invalid") AS picked_by_person_name
    , fact_order.contact_person_key
    , COALESCE(dim_contact_person.full_name, "Invalid") AS contact_person_name
    , fact_order.backorder_order_key
  FROM fact_sales_order__cast_type AS fact_order
  LEFT JOIN {{ ref("dim_customer") }} AS dim_customer
    ON fact_order.customer_key = dim_customer.customer_key
  LEFT JOIN {{ ref("dim_person") }} AS dim_sales_person
    ON fact_order.salesperson_person_key = dim_sales_person.person_key
  LEFT JOIN {{ ref("dim_person") }} AS dim_picked_by_person
    ON fact_order.picked_by_person_key = dim_picked_by_person.person_key
  LEFT JOIN {{ ref("dim_person") }} AS dim_contact_person
    ON fact_order.contact_person_key = dim_contact_person.person_key
  LEFT JOIN fact_sales_order__cast_type AS fact_backorder
    ON fact_order.backorder_order_key = fact_backorder.sales_order_key
)

SELECT
  sales_order_key
    , is_undersupply_backordered
    , order_date
    , expected_delivery_date
    , picking_completed_when
    , customer_key
    , customer_name
    , salesperson_person_key
    , sales_person_name
    , picked_by_person_key
    , picked_by_person_name
    , contact_person_key
    , contact_person_name
    , backorder_order_key
FROM fact_sales_order__handle_null