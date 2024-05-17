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
    private int telefono;
    private String email;

    public UserBean(){
        userid = "";
        tipo = "";
        password_hash = "";
        indirizzo = "";
        citta = "";
        provincia = "";
        cap = "";
        email = "";
        telefono  = 0;
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

    public int getTelefono() {
        return telefono;
    }

    public void setTelefono(int telefono) {
        this.telefono = telefono;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @Override
    public String toString() {
        return "UserBean{" +
                "indirizzo='" + indirizzo + '\'' +
                ", citta='" + citta + '\'' +
                ", provincia='" + provincia + '\'' +
                ", CAP='" + cap + '\'' + ", telefono='" + telefono + '\'' + ", email= " + email + '\'' +
                '}';
    }
}
