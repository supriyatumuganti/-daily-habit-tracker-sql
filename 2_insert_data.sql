

INSERT INTO users (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Lee', 'charlie@example.com');

INSERT INTO habits (user_id, habit_name, category, start_date) VALUES
(1, 'Morning Jog', 'Health', '2024-06-01'),
(1, 'Reading Books', 'Learning', '2024-06-01'),
(2, 'Yoga', 'Health', '2024-06-03'),
(2, 'Learn SQL', 'Learning', '2024-06-05'),
(3, 'Meditation', 'Mental Wellness', '2024-06-02');


INSERT INTO habit_log (habit_id, log_date, status) VALUES
-- Alice's Morning Jog
(1, '2024-06-01', 'done'),
(1, '2024-06-02', 'done'),
(1, '2024-06-03', 'skipped'),

-- Alice's Reading
(2, '2024-06-01', 'partial'),
(2, '2024-06-02', 'done'),

-- Bob's Yoga
(3, '2024-06-03', 'done'),
(3, '2024-06-04', 'skipped'),

-- Bob's SQL
(4, '2024-06-05', 'done'),

-- Charlie's Meditation
(5, '2024-06-02', 'done'),
(5, '2024-06-03', 'partial'),
(5, '2024-06-04', 'done');

