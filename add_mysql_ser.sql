SET @salt = UNHEX(SHA2(UUID(), 256));
INSERT INTO guacamole_user (username, password_salt, password_hash, password_date) 
VALUES ('test123', @salt, UNHEX(SHA2(CONCAT('password', HEX(@salt)), 256)), NOW());

