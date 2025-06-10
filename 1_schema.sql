create table users  (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

-- Habits table
CREATE TABLE habits (
    habit_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    habit_name VARCHAR(100),
    category VARCHAR(50),
    start_date DATE
);

-- Habit log table (tracks if the user did the habit each day)
CREATE TABLE habit_log (
    log_id SERIAL PRIMARY KEY,
    habit_id INT REFERENCES habits(habit_id),
    log_date DATE,
    status VARCHAR(20) CHECK (status IN ('done', 'skipped', 'partial'))
);

