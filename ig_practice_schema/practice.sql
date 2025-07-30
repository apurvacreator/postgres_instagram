ALTER TABLE comments
RENAME COLUMN contents TO body;

BEGIN;
UPDATE accounts
SET balance = balance - 50
WHERE name = 'Alyson';

UPDATE accounts
SET balance = balance + 50
WHERE name = 'Gia';

COMMIT;
ROLLBACK;

REFRESH MATERIALIZED VIEW weekly_likes;

DELETE FROM posts
WHERE created_at < '2010-02-01';

CREATE MATERIALIZED VIEW weekly_likes AS (
	SELECT 
		date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week,
		COUNT(posts.id) AS num_posts_likes,
		COUNT(comments.id) AS num_comments_likes
	FROM likes
	LEFT JOIN posts ON posts.id = likes.post_id
	LEFT JOIN comments ON comments.id = likes.comment_id
	GROUP BY week
	ORDER BY week
) WITH DATA;

SELECT 
	date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week,
	COUNT(posts.id) AS num_posts_likes,
	COUNT(comments.id) AS num_comments_likes
FROM likes
LEFT JOIN posts ON posts.id = likes.post_id
LEFT JOIN comments ON comments.id = likes.comment_id
GROUP BY week
ORDER BY week;

SELECT 
	date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week
FROM likes
LEFT JOIN posts ON posts.id = likes.post_id
LEFT JOIN comments ON comments.id = likes.comment_id
ORDER BY week;

SELECT *
FROM likes
LEFT JOIN posts ON posts.id = likes.post_id
LEFT JOIN comments ON comments.id = likes.comment_id; 

DROP VIEW recent_posts;

CREATE OR REPLACE VIEW recent_posts AS (
	SELECT *
	FROM posts
	ORDER BY created_at DESC
	LIMIT 15
);

SELECT username
FROM recent_posts
JOIN users ON users.id = recent_posts.user_id;

CREATE VIEW recent_posts AS (
	SELECT *
	FROM posts
	ORDER BY created_at DESC
	LIMIT 10
);

CREATE VIEW tags AS (
	SELECT id, created_at, user_id, post_id, 'photo_tag' AS type FROM photo_tags
	UNION
	SELECT id, created_at, user_id, post_id, 'caption_tag' AS type FROM caption_tags
);

SELECT username, COUNT(*)
FROM users
JOIN (
	SELECT user_id FROM photo_tags
	UNION ALL
	SELECT user_id FROM caption_tags
) AS tags ON tags.user_id = users.id
GROUP BY username
ORDER BY COUNT(*) DESC;

WITH RECURSIVE suggestions(leader_id, follower_id, depth) AS (
		SELECT leader_id, follower_id, 1 AS depth
		FROM followers
		WHERE follower_id = 1000
	UNION
		SELECT followers.leader_id, followers.follower_id, depth + 1
		FROM followers
		JOIN suggestions ON suggestions.leader_id = followers.follower_id
		WHERE depth < 3
)
SELECT DISTINCT users.id, users.username
FROM suggestions
JOIN users ON users.id = suggestions.leader_id
WHERE depth > 1
LIMIT 30;

WITH RECURSIVE countdown(val) AS (
	SELECT 10 AS val
	UNION
	SELECT val - 1 FROM countdown WHERE val > 1
)
SELECT *
FROM countdown;

WITH tags AS (
	SELECT user_id, created_at FROM caption_tags
	UNION
	SELECT user_id, created_at FROM photo_tags
)
SELECT username, tags.created_at
FROM users
JOIN tags ON tags.user_id = users.id
WHERE tags.created_at < '2010-01-07';


SELECT username, tags.created_at
FROM users
JOIN(
	SELECT user_id, created_at FROM caption_tags
	UNION
	SELECT user_id, created_at FROM photo_tags
) AS tags ON tags.user_id = users.id
WHERE tags.created_at < '2010-01-07';

SELECT * FROM users
ORDER BY id DESC
LIMIT 3;

SELECT username, caption
FROM users
JOIN posts ON posts.user_id = users.id
WHERE users.id = 200;

SELECT username, COUNT(*)
FROM users
JOIN likes ON likes.user_id = users.id
GROUP BY username;

SHOW data_directory;

SELECT oid, datname
FROM pg_database;

SELECT * FROM pg_class;

CREATE INDEX ON users (username);
DROP INDEX users_username_idx;

EXPLAIN ANALYZE SELECT * 
FROM users 
WHERE username = 'Emil30';

SELECT pg_size_pretty(pg_relation_size('users_username_idx'));

SELECT relname, relkind
FROM pg_class
WHERE relkind = 'i';

CREATE EXTENSION pageinspect;

SELECT *
FROM bt_metap('users_username_idx');

SELECT *
FROM bt_page_items('users_username_idx', 3);

SELECT ctid, * FROM users WHERE username = 'Aaliyah_Treutel76';

EXPLAIN SELECT username, contents
FROM users
JOIN comments ON comments.user_id = users.id
WHERE username = 'Alyson14';

EXPLAIN ANALYZE SELECT username, contents
FROM users
JOIN comments ON comments.user_id = users.id
WHERE username = 'Alyson14';

SELECT *
FROM pg_stats
WHERE tablename = 'users';