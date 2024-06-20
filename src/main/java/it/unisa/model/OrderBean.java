package it.unisa.model;
import java. io. Serializable;


public class OrderBean implements Serializable{

    private static final long serialVersioneUID = 1L;
    
    private int idordine;
    private String userid;
    private int idprodotto_ordinato;
    private float prezzo;
    private String indirizzo;
    private String citta;
    private String provincia;
    private String cap;
    private String nome;
    private String descrizione;
    

    public OrderBean() {
    }

    public int getIdordine() {
        return idordine;
    }

    public void setIdordine(int idordine) {
        this.idordine = idordine;
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public float getPrezzo() {
        return prezzo;
    }

    public void setPrezzo(float prezzo) {
        this.prezzo = prezzo;
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

    public int getIdProdottoOrdinato(){
        return idprodotto_ordinato;
    }

    public void setIDProdottoOrdinato(int idprodotto_ordinato){
        this.idprodotto_ordinato = idprodotto_ordinato;
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

}
