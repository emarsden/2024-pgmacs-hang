;; Create a single table with two rows.
(let ((con (pg-connect "pgeltestdb" "pgeltestuser" "pgeltest" "localhost" 5426)))
  (pg-exec con "CREATE TABLE data(id SERIAL, counter INTEGER)")
  (pg-exec con "INSERT INTO data(counter) VALUES(1)")
  (pg-exec con "INSERT INTO data(counter) VALUES(2)"))
