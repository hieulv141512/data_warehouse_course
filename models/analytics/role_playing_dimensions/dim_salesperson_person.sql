SELECT
  person_key AS salesperson_person_key
  , full_name AS salesperson_fullname
FROM {{ ref("dim_person") }}