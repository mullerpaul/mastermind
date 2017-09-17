CREATE USER mastermind
IDENTIFIED BY test
DEFAULT TABLESPACE users
QUOTA 20m ON users;

GRANT create session, create table, create procedure, create type, create view
   TO mastermind;

