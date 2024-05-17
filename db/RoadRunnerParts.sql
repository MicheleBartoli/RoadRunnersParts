DROP DATABASE IF EXISTS RoadRunnerParts;
CREATE DATABASE RoadRunnerParts;
USE RoadRunnerParts;

DROP TABLE IF EXISTS prodotto;

CREATE TABLE prodotto (	
  idprodotto int primary key AUTO_INCREMENT,
  nome varchar(50) not null,
  descrizione varchar(200),
  prezzo float default 0,
  quantita int default 0,
  marca varchar(255),
  modello_auto varchar(255),
);

CREATE TABLE user (
  userid varchar(255) primary key,
  tipo enum('Admin','Customer') default 'Customer' not null,
  password_hash char(64) not null,
  indirizzo varchar(255),
  citta varchar(255),
  provincia varchar(255),
  cap varchar(10),
  telefono int,
  email varchar(255),
);
	
CREATE TABLE ordine (
  idordine int primary key AUTO_INCREMENT,
  userid varchar(255) not null,
  idprodotto_ordinato int not null,
  prezzo_ordine float not null,
  data_ordine DATE,
  indirizzo varchar(255),
  citta varchar(255),
  provincia varchar(255),
  cap varchar(10) not null,

  FOREIGN KEY (userid) REFERENCES user(userid),
  FOREIGN KEY (idprodotto_ordinato) REFERENCES prodotto(idprodotto),
);

INSERT INTO prodotto values (1,"Paraurti anteriore RRS","Paraurti anteriore RangeRover sport 2018", 1000,1,"RangeRover","Sport");
INSERT INTO prodotto values (2,"Sistema Infotaiment BMWS5","Sistema Infotaiment per BMW Serie 5", 800, 2, "BMW", "SERIE 5");
INSERT INTO prodotto values (3,"Scarico Porsche 911","Scarico Sportivo per Porsche 911", 10000,1,"Porsche","911");
INSERT INTO prodotto values (4,"Cerchi Ford Mustang","Cerchi in alluminio per Ford Mustang", 4,4000,"Ford", "Mustang");
INSERT INTO prodotto values (5, "Faro anteriore sinistro Opel Agila","Faro Alogeno Anteriore Sinistro Opel Agila",100,1,"Opel","Agila");
INSERT INTO user values (useid,tipo,password_hash) values ("RoadRunnerAdmin", "Admin", "0b575dc9bb48efa5fbf2eef15cb26c1129b3d5a085ba631e7f36b62bc912e1fb")