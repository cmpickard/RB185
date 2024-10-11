CREATE TABLE expenses(
  id serial PRIMARY KEY,
  amount decimal(6,2) NOT NULL CHECK (amount > 0.0),
  memo text NOT NULL,
  created_on date NOT NULL
);

INSERT INTO expenses (amount, memo, created_on)
  VALUES (14.56, 'pencils and erasers', NOW()),
         (3.29, 'coffee', NOW()),
         (49.99, 'text editor', NOW());