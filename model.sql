BEGIN TRANSACTION;
	DROP TABLE Track;
	DROP TABLE Featuring;
	DROP TABLE Album;
	DROP TABLE Artist;
	DROP TABLE Grp;
	DROP TABLE Person;
	DROP TABLE MemberOf;
	DROP TABLE Playlist;
	DROP TABLE InPlaylist;
COMMIT;

BEGIN TRANSACTION;
	CREATE TABLE Track (
		-- id INTEGER PRIMARY KEY AUTOINCREMENT,
		file VARCHAR(256),
		title VARCHAR(128),
		album_id INTEGER,
		number INTEGER,
		artist_id INTEGER,
		comment TEXT,

		PRIMARY KEY(file),
		--PRIMARY KEY(album_id,number),
		FOREIGN KEY(album_id) REFERENCES Album(id),
		FOREIGN KEY(artist_id) REFERENCES Artist(id)
	);

	CREATE TABLE Featuring (
		track_id INTEGER,
		artist_id INTEGER,

		PRIMARY KEY(track_id,artist_id),
		FOREIGN KEY(track_id) REFERENCES Track(id),
		FOREIGN KEY(artist_id) REFERENCES Artist(id)
	);

	CREATE TABLE Album (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		title VARCHAR(128),
		disc_number INTEGER,
		artist_id INTEGER,
		year INTEGER,

		FOREIGN KEY(artist_id) REFERENCES Artist(id)
	);

	CREATE TABLE Artist (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name VARCHAR(128),
		isGrp INTEGER
	);

	CREATE TABLE Grp (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name VARCHAR(128),
		byear INTEGER,
		eyear INTEGER,

		FOREIGN KEY(id) REFERENCES Artist(id)
	);

	CREATE TABLE Person (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		first_name VARCHAR(64),
		last_name VARCHAR(64),
		byear INTEGER,
		dyear INTEGER,
		
		FOREIGN KEY(id) REFERENCES Artist(id)
	);

	CREATE TABLE MemberOf (
		person_id INTEGER,
		grp_id INTEGER,
		byear INTEGER,
		eyear INTEGER,
		PRIMARY KEY(person_id,grp_id,byear,eyear),
		FOREIGN KEY(person_id) REFERENCES Person(id),
		FOREIGN KEY(grp_id) REFERENCES Grp(id)
	);

	CREATE TABLE Playlist (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name VARCHAR(128),
	);

	CREATE TABLE InPlaylist (
		playlist_id INTEGER,
		track_id INTEGER,
		position INTEGER,
		PRIMARY KEY(playlist_id,position),
		FOREIGN KEY(playlist_id) REFERENCES Playlist(id),
		FOREIGN KEY(track_id) REFERENCES Track(id)
	);

	PRAGMA foreign_keys=on;
COMMIT;

