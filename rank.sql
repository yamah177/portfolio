-- Ranking Data

SELECT product_id
, unit_price,
RANK() OVER (ORDER BY unit_price desc) AS ranking
from products
