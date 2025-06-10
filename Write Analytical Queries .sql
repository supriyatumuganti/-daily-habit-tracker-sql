
--List all habits tracked by each user
select u.user_id,u.name,h.habit_name,h.category from users as u
join habits as h
on u.user_id = h.user_id;

--Show all log entries for a specific user.
select u.name,h.habit_name,hl.log_date,hl.status from users as u
join habits as h
on u.user_id = h.user_id
join habit_log as hl
on h.habit_id = hl.habit_id
where u.name ='Alice Johnson'
ORDER BY hl.log_date;

--Count how many times each habit was marked as 'done'.
select habit_id,count(status) from habit_log
where status='done'
group by habit_id;

--Display all habits that were never skipped.

select distinct habit_id,habit_name 
from habits 
where habit_id not in(
select habit_id from habit_log 
where status ='skipped'
);

--Find all users who have at least two habits in the same category.

select u.name,h.category from users as u
join habits as h
on u.user_id = h.user_id
group by  u.name,h.category
having count(*)>=2;

--6 Show a monthly summary (done, skipped, partial) for each habit.

select h.habit_id,h.habit_name,
TO_CHAR(hl.log_date,'yyyy-mm')as month,
count(case when hl.status ='done' then 1 end )as done_count ,
count(case when hl.status='skipped' then 1 end)as skipped_count ,
count(case when hl.status='partial'then 1 end)as partial_count
from habits as h
join habit_log as hl
on h.habit_id =hl.habit_id
group by h.habit_id,h.habit_name,
to_char(hl.log_date,'yyyy-mm')

--List the top 3 most consistent habits across all users.

select h.habit_name,count(*) as habitcount from habits as h
join habit_log as hl
on h.habit_id = hl.habit_id
where hl.status= 'done'
group by h.habit_name
order by habitcount desc
limit 3;

--Identify the habits most frequently skipped
select h.habit_name,count(*) as habitcount from habits as h
join habit_log as hl
on h.habit_id = hl.habit_id
where hl.status='skipped'
group by h.habit_name
order by habitcount desc

-- Compare two users’ consistency on the  habits
SELECT 
    u.name AS user_name,
    h.habit_name,
    COUNT(hl.status) AS total_logs,
    COUNT(CASE WHEN hl.status = 'done' THEN 1 END) AS done_count,
    ROUND(
        100.0 * COUNT(CASE WHEN hl.status = 'done' THEN 1 END) / COUNT(hl.status),
        2
    ) AS consistency_rate
FROM users u
JOIN habits h ON u.user_id = h.user_id
JOIN habit_log hl ON h.habit_id = hl.habit_id
WHERE u.name IN ('Alice Johnson', 'Bob Smith') -- change as needed
GROUP BY u.name, h.habit_name
ORDER BY u.name, consistency_rate DESC;


--
WITH skipped_logs AS (
    SELECT 
        u.name AS user_name,
        h.habit_name,
        hl.log_date,
        ROW_NUMBER() OVER (PARTITION BY h.habit_id ORDER BY hl.log_date) AS rn
    FROM habit_log hl
    JOIN habits h ON hl.habit_id = h.habit_id
    JOIN users u ON h.user_id = u.user_id
    WHERE hl.status = 'skipped'
),
grouped_skips AS (
    SELECT 
        user_name,
        habit_name,
        log_date,
        log_date - (rn || ' days')::INTERVAL AS streak_group
    FROM skipped_logs
),
streak_counts AS (
    SELECT 
        user_name,
        habit_name,
        streak_group,
        COUNT(*) AS skipped_days
    FROM grouped_skips
    GROUP BY user_name, habit_name, streak_group
)
SELECT 
    user_name,
    habit_name,
    skipped_days
FROM streak_counts
WHERE skipped_days > 3
ORDER BY user_name, habit_name;

-- Determine the Longest Streak of 'done' Entries for Any Habit
WITH done_logs AS (
  SELECT 
    habit_id,
    log_date,
    ROW_NUMBER() OVER (PARTITION BY habit_id ORDER BY log_date) AS rn
  FROM habit_log
  WHERE status = 'done'
),
streak_groups AS (
  SELECT 
    habit_id,
    log_date,
    log_date - (rn || ' days')::INTERVAL AS streak_group
  FROM done_logs
),
streak_counts AS (
  SELECT 
    habit_id,
    COUNT(*) AS streak_length
  FROM streak_groups
  GROUP BY habit_id, streak_group
),
longest_streaks AS (
  SELECT 
    habit_id,
    MAX(streak_length) AS max_streak
  FROM streak_counts
  GROUP BY habit_id
)
SELECT 
  h.habit_name,
  ls.max_streak
FROM longest_streaks ls
JOIN habits h ON h.habit_id = ls.habit_id
ORDER BY ls.max_streak DESC
LIMIT 1;

--for each user, find their most frequently practiced habit
WITH habit_done_counts AS (
  SELECT 
    u.user_id,
    u.name AS user_name,
    h.habit_name,
    COUNT(*) AS done_count
  FROM habit_log hl
  JOIN habits h ON hl.habit_id = h.habit_id
  JOIN users u ON h.user_id = u.user_id
  WHERE hl.status = 'done'
  GROUP BY u.user_id, u.name, h.habit_name
),
ranked_habits AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY done_count DESC) AS rn
  FROM habit_done_counts
)
SELECT user_name, habit_name, done_count
FROM ranked_habits
WHERE rn = 1



