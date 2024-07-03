package it.unisa.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

public class OrderBean implements Serializable {

    private static final long serialVersionUID = 1L;

    private String idordine;
    private String userid;
    private float prezzoTotale;
    private String indirizzo;
    private String citta;
    private String provincia;
    private String cap;
    private List<ProductBean> prodotti;
    private int telefono; 
    private Timestamp dataOrdine; 

    public OrderBean() {
        idordine = "";
        userid = "";
        prezzoTotale = 0;
        indirizzo = "";
        citta = "";
        provincia = "";
        cap = "";
        prodotti = null;
        telefono = 0; 
        dataOrdine = null; 
    }

    public String getIdordine() {
        return idordine;
    }

    public void setIdordine(String idordine) {
        this.idordine = idordine;
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public float getPrezzoTotale() {
        return prezzoTotale;
    }

    public void setPrezzoTotale(float prezzoTotale) {
        this.prezzoTotale = prezzoTotale;
    }

    public String getIndirizzo() {
        return indirizzo;
    }

    public void setIndirizzo(String indirizzo) {
        this.indirizzo = indirizzo;
    }

    public String getCitta() {
        return citta;
    }

    public void setCitta(String citta) {
        this.citta = citta;
    }

    public String getProvincia() {
        return provincia;
    }

    public void setProvincia(String provincia) {
        this.provincia = provincia;
    }

    public String getCap() {
        return cap;
    }

    public void setCap(String cap) {
        this.cap = cap;
    }

    public List<ProductBean> getProdotti() {
        return prodotti;
    }

    public void setProdotti(List<ProductBean> prodotti) {
        this.prodotti = prodotti;
        calcolaPrezzoTotale(); //aggiorna il prezzo dell'ordine ogni volta che viene aggiunto/rimosso un prodotto
    }

    public int getTelefono() {
        return telefono;
    }

    public void setTelefono(int telefono) {
        this.telefono = telefono;
    }

    public Timestamp getDataOrdine() {
        return dataOrdine;
    }

    public void setDataOrdine(Timestamp dataOrdine) {
        this.dataOrdine = dataOrdine;
    }

    //calcola il prezzo totale dell'ordine
    private void calcolaPrezzoTotale() {
        float totale = 0;
        if (prodotti != null) {
            for (ProductBean prodotto : prodotti) {
                totale += prodotto.getPrezzo();
            }
        }
        this.prezzoTotale = totale;
    }
}