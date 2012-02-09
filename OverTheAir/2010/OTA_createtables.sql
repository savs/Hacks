\c ota
CREATE TABLE friends (
    phone_number    varchar(12) NOT NULL,
    name            varchar(40) NOT NULL,
    avatar          varchar(256),
    twitter         varchar(140),
    email           varchar(140)
);

INSERT INTO friends (phone_number, name, avatar, twitter, email) values ('447711223344', 'Andrew Savory', 'http://a1.twimg.com/profile_images/521792353/savs_bigger.jpg', 'savs','ota@andrewsavory.com');
INSERT INTO friends (phone_number, name, avatar, twitter, email) values ('447716354419', 'Sir Tim Berners-Lee', 'http://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Tim_Berners-Lee.jpg/220px-Tim_Berners-Lee.jpg', 'timmy','tim@andrewsavory.com');
INSERT INTO friends (phone_number, name, avatar, twitter, email) values ('447716354432', 'Anne', 'http://t0.gstatic.com/images?q=tbn:ANd9GcQVIqm01EQrMYfxA95GxQ8DcXveJuH68AmNu7Wedc51SO0t0_0&t=1&usg=__k-5hA-RKfd8alrDX7BJ3vl2MtvU=', 'anne','anne@andrewsavory.com');
INSERT INTO friends (phone_number, name, avatar, twitter, email) values ('447716354406', 'Dick', 'http://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/RMS_iGNUcius_techfest_iitb.JPG/170px-RMS_iGNUcius_techfest_iitb.JPG', 'dick','dick@andrewsavory.com');

