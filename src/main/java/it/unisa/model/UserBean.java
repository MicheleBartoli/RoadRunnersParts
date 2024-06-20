package it.unisa.model;

public class UserBean  implements java.io.Serializable{

    private static final long serialVersioneUID = 1L;
    private String userid;
    private String tipo;
    private String password_hash; 
    private String indirizzo; 
    private String citta;
    private String provincia;
    private String cap;
    private String telefono;
    private String metodo_pagamento;

    public UserBean(){
        userid = "";
        tipo = "";
        password_hash = "";
        indirizzo = "";
        citta = "";
        provincia = "";
        cap = "";
        telefono  = "";
        metodo_pagamento = "";
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getPasswordHash() {
        return password_hash;
    }

    public void setPasswordHash(String password_hash) {
        this.password_hash = password_hash;
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

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getMetodoPagamento() {
        return metodo_pagamento;
    }

    public void setMetodoPagamento(String metodo_pagamento) {
        this.metodo_pagamento = metodo_pagamento;
    }

  
}
