<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="it.unisa.model.CartBean, it.unisa.model.ProductBean, it.unisa.model.UserBean, it.unisa.model.MetodoPagamentoBean" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="java.sql.SQLException" %>

<%!
    public String capitalizeWords(String str) {
        if (str == null || str.isEmpty()) {
            return str;
        }
        String[] words = str.split(" ");
        StringBuilder capitalizedWords = new StringBuilder();
        for (String word : words) {
            if (word.length() > 0) {
                capitalizedWords.append(Character.toUpperCase(word.charAt(0)))
                                .append(word.substring(1).toLowerCase())
                                .append(" ");
            }
        }
        return capitalizedWords.toString().trim();
    }

    public String toUpperCase(String str) {
        return (str == null) ? null : str.toUpperCase();
    }
    
    public String maskAccountId(String account_id) {
        if (account_id == null || account_id.isEmpty()) {
            return "";
        }
        
        if (account_id.contains("@")) { // Se l'account_id sembra essere un'email
            int atIndex = account_id.indexOf("@");
            if (atIndex > 0) {
                String domain = account_id.substring(atIndex);
                String masked = account_id.substring(0, 4) + "****" + domain;
                return masked;
            }
        } else { // Altrimenti, trattalo come un numero di carta di credito o altro
            return  "****" + account_id.substring(account_id.length() - 4);
        }
        
        return account_id; // Ritorna l'account_id originale se non rientra nei casi sopra
    }
%>

<!-- PAGINE DEL CARRELLO ACCESSIBILE SIA LATO ADMIN SIA LATO UTENTE REGISTRATO DALL'INTERFACCIA DEL SITO -->

<link rel="stylesheet" href="styles/cart.css">
<style>
    table {
        border-collapse: collapse;
        width: 100%;
    }
    td, th {
        border: 1px solid #ddd;
        padding: 8px;
    }
    td {
        text-align: center;
    }
    .img-column img {
        width: 100px;
        height: auto;
    }
    .full-width-button {
        width: 100%;
        padding: 10px;
        background-color: #4CAF50;
        color: white;
        border: none;
        cursor: pointer;
    }
    .delete-button {
        background-color: red;
        color: white;
        border: none;
        cursor: pointer;
    }
    .fa-trash {
        font-size: 1.5rem;
    }
    @media (max-width: 600px) {
        .fa-trash {
            font-size: 1rem;
        }
    }
</style>

<div class="bodyContainerCart" id="cart-container">
    <h1 id="cart-title">Carrello</h1>
    <%
    	String userid = (String) session.getAttribute("userid");
        CartBean cart = (CartBean) session.getAttribute("cart");
    	UserBean user = (UserBean) session.getAttribute("user");
        
        if (cart != null && !cart.getProducts().isEmpty()) {
            Map<Integer, ProductBean> productMap = new HashMap<>();
            Map<Integer, Integer> quantityMap = new HashMap<>();
            
            // Aggrega i prodotti in base al loro ID
            for (ProductBean product : cart.getProducts()) {
                int productId = product.getId();
                if (productMap.containsKey(productId)) {
                    quantityMap.put(productId, quantityMap.get(productId) + 1);
                } else {
                    productMap.put(productId, product);
                    quantityMap.put(productId, 1);
                }
            }
    %>
        <table>
            <tr>
                <th>Immagine</th>
                <th>Nome</th>
                <th>Prezzo</th>
                <th>Quantità</th>
                <th>Rimuovi</th>
            </tr>
            <% 
                for (Map.Entry<Integer, ProductBean> entry : productMap.entrySet()) { 
                    ProductBean product = entry.getValue();
                    int quantity = quantityMap.get(product.getId());
            %>
                <tr>
                    <td class="img-column">
                        <% 
                            String imgSrc = "images/" + product.getNome().toLowerCase() + ".png"; 
                            byte[] immagine = product.getImmagine(); 
                            if (immagine != null && immagine.length > 0) {
                                String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                        %>
                                <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= product.getNome() %>" style="width: 100px; height: 100px;">
                        <% } else { %>
                                <img src="<%= imgSrc %>" alt="<%= product.getNome() %>">
                        <% } %>
                    </td>
                    <td><%= product.getNome() %></td>
                    <td><%= String.format("%.2f", product.getPrezzo()) %>€</td>
                    <td><%= quantity %></td>
                    <td>
                        <form action="ProductControl" method="post">
                            <input type="hidden" name="action" value="deleteCart">
                            <input type="hidden" name="idprodotto" value="<%= product.getId() %>">
                            <button type="submit" class="delete-button"><i class="fa fa-trash" aria-hidden="true"></i></button>
                        </form>
                    </td>
                </tr>
            <% } %>
        </table>
        <% 
            boolean canPurchase = user != null && user.getIndirizzo() != null && user.getCitta() != null && user.getProvincia() != null && user.getCap() != null && user.getTelefono() != null;
            if (userid != null && canPurchase) { %>
                <form action="OrdineControl" method="post">
                    <input type="hidden" name="action" value="saveorder">
                    <button type="submit" class="full-width-button">Finalizza l'acquisto</button>
                </form>
            <% } else { %>
                <p style="text-align: center;">Per completare l'acquisto, aggiungi il tuo indirizzo metodo di pagamento nel tuo profilo</p>
            <% } %>
    <% } else { %>
        <p style="text-align: center;">Il carrello è vuoto.</p>
    <% } %>
</div>

<div class="informazioni-utenti">
    <%
    MetodoPagamentoBean metodoPagamento = null;
    ProductModelDS ps = new ProductModelDS();
    try {
        if (userid != null) {
            metodoPagamento = ps.doRetrievePayamentMethod(userid);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    %>
    <p>Username: <%= user != null ? user.getUserid() : "" %></p>
    <p>Telefono: <%= user != null ? user.getTelefono() : "" %></p>
    <p>Indirizzo: <%= user != null ? capitalizeWords(user.getIndirizzo()) + ", " + toUpperCase(user.getCitta()) + ", " + toUpperCase(user.getProvincia()) + " - " + user.getCap() : "" %></p>
    <%
    String accountcensurato = "";
    if (metodoPagamento != null){
        String account_id = metodoPagamento.getAccountId();
        accountcensurato = maskAccountId(account_id);
    }
    %>
    <p> Metodo di pagamento: <%= metodoPagamento != null ? metodoPagamento.getTipoPagamento() + " - " + accountcensurato : "Non disponibile" %> </p>

    <a href="utente.jsp" class="user-button">Modifica Indirizzo o Metodo di Pagamento</a> 
</div>
<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>