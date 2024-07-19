<%@ page import="it.unisa.model.UserBean" %>
<%@ page import="it.unisa.model.MetodoPagamentoBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.sql.SQLException" %>
<%@ include file="includes/header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Area Personale</title>
</head>
<body>
<div class="bodyContainerUtente">
    <div class="areaPersonale">
        <h2>Area Personale</h2>

        <%
        String userId = (String) session.getAttribute("userid");
        if (userId != null) {
            ProductModelDS ps = new ProductModelDS();
            UserBean user = null;
            MetodoPagamentoBean metodoPagamento = null;
            try {
                user = ps.doRetrieveByKeyUser(userId);
                if (user != null){
                    metodoPagamento = ps.doRetrievePayamentMethod(userId);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        %>

        <div>
            <p>Username: <%= user.getUserid() %></p>
            <p>Telefono: <%= user.getTelefono() %></p>
            <p>Indirizzo: <%= capitalizeWords(user.getIndirizzo()) %>, <%= toUpperCase(user.getCitta()) %>, <%= toUpperCase(user.getProvincia()) %> - <%= user.getCap() %></p>
            <%
            String accountcensurato = "";
            if (metodoPagamento != null){
                String account_id = metodoPagamento.getAccountId();
                accountcensurato = maskAccountId(account_id);
            }
            %>
            <p> Metodo di pagamento: <%= metodoPagamento != null ? metodoPagamento.getTipoPagamento() + " - " + accountcensurato : "Non disponibile" %> </p>
        </div>

        <div id="reAdressButton">
            <button onclick="reAdressForm()" class="button"  id="userBoldButton">Cambia Indirizzo</button>
        </div>

        <div class="form-container" id="form-container">
            <h3>Modifica Dati Indirizzo</h3>
            <form action="UserControl?action=changeUserLocation" method="post">
                <input type="hidden" name="userid" value="<%= user.getUserid() %>">
                <label for="indirizzo">Indirizzo</label>
                <input type="text" id="indirizzo" name="indirizzo" value="<%= capitalizeWords(user.getIndirizzo()) %>" required>

                <label for="citta">Città</label>
                <input type="text" id="citta" name="citta" value="<%= toUpperCase(user.getCitta()) %>" required>

                <label for="provincia">Provincia</label>
                <input type="text" id="provincia" name="provincia" value="<%= toUpperCase(user.getProvincia()) %>" required>

                <label for="cap">CAP</label>
                <input type="text" id="cap" name="cap" value="<%= user.getCap() %>" required>

                <label for="telefono">Telefono</label>
                <input type="text" id="telefono" name="telefono" value="<%= user.getTelefono() %>" required>

                <input class="button" type="submit" value="Aggiorna Indirizzo" id="updateAdress" onclick="updateAdressForm()">
            </form>
        </div>

        <form action="PagamentoControl?action=addmetodopagamento" method="post" id="payment-form">
            <input type="hidden" id="userid" name="userid" value="<%= user.getUserid() %>">

            <label for="tipo_pagamento">Tipo di pagamento:</label>
            <select id="tipo_pagamento" name="tipo_pagamento" onchange="togglePaymentFields()">
                <option value="PayPal">PayPal</option>
                <option value="Carta di Credito">Carta di Credito</option>
            </select>

            <div id="paypal_fields" style="display: none;">
                <label for="paypal_account_id">Email PayPal:</label>
                <input type="email" id="paypal_account_id" name="account_id" required>
            </div>

            <div id="credit_card_fields" style="display: none;">
                <label for="cc_account_id">Numero Carta:</label>
                <input type="text" id="cc_account_id" name="account_id" required>
                <label for="data_scadenza">Data di Scadenza:</label>
                <input type="date" id="data_scadenza" name="data_scadenza" required>
                <label for="cvv">CVV:</label>
                <input type="text" id="cvv" name="cvv" required>
            </div>

            <button class="button" type="submit" id="userBoldButton">Aggiorna metodo di pagamento</button>
        </form>
    </div>
    <div class="areaPersonale">
        <% if ("Admin".equals(user.getTipo())) { %>
            <h2>Area Admin</h2>
            <a href="catalogo.jsp" class="button" id="userButton">Catalogo</a>
            <a href="ordini-admin.jsp" class="button" id="userButton">Ordini</a>
            <a href="lista-utenti.jsp" class="button" id="userButton">Utenti</a>
        <% } %>

        <% if("Customer".equals(user.getTipo())){ %>
            <a href="ordini-customer.jsp" class="button" id="userButton">Ordini</a>
        <% } %>

        <form action="UserControl?action=logoututente" method="post">
            <input type="submit" class="button" value="Logout" id="userBoldButton">
        </form>

        <% } else { %>
        <p>Utente non trovato.</p>
        <% } %>
    </div>
</div>

</body>
<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>
</html>