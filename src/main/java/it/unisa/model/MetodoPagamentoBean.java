package it.unisa.model;
import java. io.Serializable;
import java.util.Date;

public class MetodoPagamentoBean implements Serializable {

    private static final long serialVersioneUID = 1L;

    private String id; //id del metodo di pagamento
    private String userId; //id dell utente collegato al metodo di pagamento
    private String tipoPagamento; // 'PayPal' o 'Carta di Credito'
    private String accountId; //mail per paypal o numero carta per carta di credito
    private Date dataScadenza; //carta di credito 
    private String cvv; //carta di credito

    public MetodoPagamentoBean() {
    }

    public String getIdPagamento() { 
        return id;
    }

    public void setIdPagamento(String id) {
        this.id = id;
    }

    public String getUserIdPagamento() {
        return userId;
    }

    public void setUserIdPagamento(String userId) {
        this.userId = userId;
    }

    public String getTipoPagamento() {
        return tipoPagamento;
    }

    public void setTipoPagamento(String tipoPagamento) {
        this.tipoPagamento = tipoPagamento;
    }

    public String getAccountId() {
        return accountId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }

    public Date getDataScadenza() {
        return dataScadenza;
    }

    public void setDataScadenza(Date dataScadenza) {
        this.dataScadenza = dataScadenza;
    }

    public String getCvv() {
        return cvv;
    }

    public void setCvv(String cvv) {
        this.cvv = cvv;
    }

    @Override
    public String toString() {
        return "MetodoPagamentoBean{" +
                "id=" + id +
                ", userId=" + userId +
                ", tipoPagamento='" + tipoPagamento + '\'' +
                ", accountId='" + accountId + '\'' +
                ", dataScadenza=" + dataScadenza +
                ", cvv='" + cvv + '\'' +
                '}';
    }
}
    

