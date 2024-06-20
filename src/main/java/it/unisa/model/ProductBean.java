package it.unisa.model;

import java.io.Serializable;

public class ProductBean implements Serializable {

	private static final long serialVersionUID = 1L;
	
	int idprodotto;
	String nome;
	String descrizione;
	float prezzo;
	int quantita;
	String marca;
	String modello_auto;
	byte[] immagine;

	public ProductBean() {
		idprodotto = -1;
		nome = "";
		descrizione = "";
		prezzo = 0;
		quantita = 0;
		marca = "";
		modello_auto = "";
		immagine = null;
	}

	public int getId() {
		return idprodotto;
	}

	public void setId(int id) {
		this.idprodotto = id;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getDescrizione() {
		return descrizione;
	}

	public void setDescrizione(String descrizione) {
		this.descrizione = descrizione;
	}

	public float getPrezzo() {
		return prezzo;
	}

	public void setPrezzo(float prezzo) {
		this.prezzo = prezzo;
	}

	public int getQuantita() {
		return quantita;
	}

	public void setQuantita(int quantita) {
		this.quantita = quantita;
	}

	public String getMarca(){
		return marca;
	}

	public void setMarca(String marca){
		this.marca = marca;
	}

	public String getModelloAuto(){
		return modello_auto;
	}

	public void setModelloAuto(String modello_auto){
		this.modello_auto = modello_auto ;
	}

	public byte[] getImmagine() {
		return immagine;
	}

	public void setImmagine(byte[] immagine) {
		this.immagine = immagine;
	}

	@Override
	public String toString() {
		return nome +  " (" + idprodotto + "), " + prezzo + " " + quantita + "." + descrizione + "." + marca + "." + modello_auto;
	}

}
