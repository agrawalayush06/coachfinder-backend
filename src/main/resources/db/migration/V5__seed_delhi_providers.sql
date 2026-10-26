-- V5: Seed Delhi providers across 5 major sports: Cricket, Badminton, Football, Tennis, Swimming
-- Covering realistic neighborhoods with actual GPS coordinates

-- ==============================================================
-- USERS (coach accounts for Delhi providers)
-- ==============================================================
INSERT INTO users (email, name, role) VALUES
-- Cricket
('rohit.cricket@delhicoach.in',       'Rohit Sharma Academy',         'COACH'),
('vikram.cricket@delhicoach.in',      'Vikram Singh Cricket Club',    'COACH'),
('delhi.cricket.acad@gmail.com',      'Delhi Cricket Academy',        'COACH'),
-- Badminton
('saina.badminton@delhicoach.in',     'Saina Badminton Training',     'COACH'),
('shuttlers.delhi@gmail.com',         'Delhi Shuttlers Academy',      'COACH'),
('rajeev.badminton@delhicoach.in',    'Rajeev Sethi Badminton',       'COACH'),
-- Football
('delhi.fc.academy@gmail.com',        'Delhi FC Academy',             'COACH'),
('anil.football@delhicoach.in',       'Anil Kapoor Football School',  'COACH'),
('sports.arena.football@gmail.com',   'Sports Arena Football Delhi',  'COACH'),
-- Tennis
('delhi.tennis.club@gmail.com',       'Delhi Lawn Tennis Club',       'COACH'),
('priya.tennis@delhicoach.in',        'Priya Mehta Tennis Academy',   'COACH'),
('vasant.tennis@delhicoach.in',       'Vasant Vihar Tennis Centre',   'COACH'),
-- Swimming
('delhi.aqua.club@gmail.com',         'Delhi Aqua Sports Club',       'COACH'),
('naveen.swimming@delhicoach.in',     'Naveen Kumar Swimming Academy','COACH'),
('dwarka.swim@delhicoach.in',         'Dwarka Aquatic Centre',        'COACH');

-- ==============================================================
-- PROVIDERS (linked to users above, with real Delhi GPS coords)
-- ==============================================================
INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'COACH', 'Rohit Sharma Cricket Academy', 'Delhi', 28.7041, 77.1025
FROM users WHERE email = 'rohit.cricket@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Vikram Singh Cricket Club', 'Delhi', 28.6280, 77.2190
FROM users WHERE email = 'vikram.cricket@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Delhi Cricket Academy – Patel Nagar', 'Delhi', 28.6470, 77.1540
FROM users WHERE email = 'delhi.cricket.acad@gmail.com';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'COACH', 'Saina Badminton Training Centre', 'Delhi', 28.5355, 77.3910
FROM users WHERE email = 'saina.badminton@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Delhi Shuttlers Academy – Lajpat Nagar', 'Delhi', 28.5700, 77.2430
FROM users WHERE email = 'shuttlers.delhi@gmail.com';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'COACH', 'Rajeev Sethi Badminton Coaching', 'Delhi', 28.6860, 77.0974
FROM users WHERE email = 'rajeev.badminton@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Delhi FC Football Academy – Dwarka', 'Delhi', 28.5921, 77.0460
FROM users WHERE email = 'delhi.fc.academy@gmail.com';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'COACH', 'Anil Kapoor Football School', 'Delhi', 28.6748, 77.0960
FROM users WHERE email = 'anil.football@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Sports Arena Football – Rohini', 'Delhi', 28.7360, 77.1152
FROM users WHERE email = 'sports.arena.football@gmail.com';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Delhi Lawn Tennis Club – RK Khanna', 'Delhi', 28.5916, 77.2108
FROM users WHERE email = 'delhi.tennis.club@gmail.com';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'COACH', 'Priya Mehta Tennis Academy', 'Delhi', 28.6550, 77.2308
FROM users WHERE email = 'priya.tennis@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Vasant Vihar Tennis Centre', 'Delhi', 28.5631, 77.1656
FROM users WHERE email = 'vasant.tennis@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Delhi Aqua Sports Club – Siri Fort', 'Delhi', 28.5488, 77.2168
FROM users WHERE email = 'delhi.aqua.club@gmail.com';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'COACH', 'Naveen Kumar Swimming Academy', 'Delhi', 28.6970, 77.1344
FROM users WHERE email = 'naveen.swimming@delhicoach.in';

INSERT INTO providers (user_id, type, name, city, lat, lng)
SELECT id, 'ACADEMY', 'Dwarka Aquatic Centre', 'Delhi', 28.5830, 77.0680
FROM users WHERE email = 'dwarka.swim@delhicoach.in';

-- ==============================================================
-- PROVIDER_ACTIVITIES (link each provider to their sports)
-- ==============================================================

-- Cricket providers
INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 600.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Cricket'
WHERE u.email = 'rohit.cricket@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 900.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Cricket'
WHERE u.email = 'rohit.cricket@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 500.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Cricket'
WHERE u.email = 'vikram.cricket@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'ADVANCED', 1200.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Cricket'
WHERE u.email = 'vikram.cricket@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 450.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Cricket'
WHERE u.email = 'delhi.cricket.acad@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 750.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Cricket'
WHERE u.email = 'delhi.cricket.acad@gmail.com';

-- Badminton providers
INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 400.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Badminton'
WHERE u.email = 'saina.badminton@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'ADVANCED', 1100.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Badminton'
WHERE u.email = 'saina.badminton@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 350.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Badminton'
WHERE u.email = 'shuttlers.delhi@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 650.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Badminton'
WHERE u.email = 'shuttlers.delhi@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 300.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Badminton'
WHERE u.email = 'rajeev.badminton@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 550.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Badminton'
WHERE u.email = 'rajeev.badminton@delhicoach.in';

-- Football providers
INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 500.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Cricket'  -- reuse Cricket activity as placeholder for Football (need to add Football activity)
WHERE u.email = 'delhi.fc.academy@gmail.com';

-- Add Football activity if missing, then link
INSERT INTO activities (name, category)
SELECT 'Football', 'Sports'
WHERE NOT EXISTS (SELECT 1 FROM activities WHERE name = 'Football');

INSERT INTO activities (name, category)
SELECT 'Tennis', 'Sports'
WHERE NOT EXISTS (SELECT 1 FROM activities WHERE name = 'Tennis');

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 500.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Football'
WHERE u.email = 'delhi.fc.academy@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 800.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Football'
WHERE u.email = 'delhi.fc.academy@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 450.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Football'
WHERE u.email = 'anil.football@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'ADVANCED', 1000.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Football'
WHERE u.email = 'anil.football@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 400.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Football'
WHERE u.email = 'sports.arena.football@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 700.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Football'
WHERE u.email = 'sports.arena.football@gmail.com';

-- Tennis providers
INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 700.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Tennis'
WHERE u.email = 'delhi.tennis.club@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'ADVANCED', 1500.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Tennis'
WHERE u.email = 'delhi.tennis.club@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 600.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Tennis'
WHERE u.email = 'priya.tennis@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 900.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Tennis'
WHERE u.email = 'priya.tennis@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 550.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Tennis'
WHERE u.email = 'vasant.tennis@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 850.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Tennis'
WHERE u.email = 'vasant.tennis@delhicoach.in';

-- Swimming providers
INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 400.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Swimming'
WHERE u.email = 'delhi.aqua.club@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'ADVANCED', 900.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Swimming'
WHERE u.email = 'delhi.aqua.club@gmail.com';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 350.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Swimming'
WHERE u.email = 'naveen.swimming@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 600.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Swimming'
WHERE u.email = 'naveen.swimming@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'BEGINNER', 300.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Swimming'
WHERE u.email = 'dwarka.swim@delhicoach.in';

INSERT INTO provider_activities (provider_id, activity_id, skill_level, price_per_session)
SELECT p.id, a.id, 'INTERMEDIATE', 550.00
FROM providers p JOIN users u ON p.user_id = u.id
JOIN activities a ON a.name = 'Swimming'
WHERE u.email = 'dwarka.swim@delhicoach.in';

-- Remove the incorrect Cricket placeholder for Football academy
DELETE FROM provider_activities
WHERE provider_id = (
    SELECT p.id FROM providers p JOIN users u ON p.user_id = u.id
    WHERE u.email = 'delhi.fc.academy@gmail.com'
)
AND activity_id = (SELECT id FROM activities WHERE name = 'Cricket');
