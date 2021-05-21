drop table if exists contents;

create table contents (
  id integer primary key,
  title text,
  name text,
  price integer,
  description text,
  pass text,
  created datetime default (datetime('now', '+09:00:00')),
  archived integer default 0
);

drop table if exists campaigns;

create table campaigns (
  id integer primary key,
  name text,
  price integer,
  content_id integer
);

drop table if exists comments;

create table comments (
  id integer primary key,
  name text,
  comment text,
  content_id integer,
  created datetime default (datetime('now', '+09:00:00'))
);
