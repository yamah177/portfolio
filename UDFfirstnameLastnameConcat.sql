CREATE FUNCTION full_name(first_name VARCHAR(50), last_name VARCHAR(50))
RETURNS VARCHAR(50) DETERMINISTIC
RETURN concat(first_name, ' ', last_name);

SELECT full_name(first_name, last_name) AS name
from customers

