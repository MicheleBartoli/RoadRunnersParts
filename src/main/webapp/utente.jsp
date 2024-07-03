<%@ page import="it.unisa.model.UserBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.sql.SQLException" %>
<%@ include file="includes/header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

    <%! 
    public String capitalizeWords(String str) { //metodi per gestire indirizzo, citta e provincia capitalizzate e maiuscole 
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
%>

<!-- PAGINA UTENTE DOVE SI POSSONO MODIFICARE I DATI DI PAGAMENTO E INDIRIZZO (lato utente registrato) E VISUALIZZARE CATALOGO, UTENTI E ORDINI (lato amministratore) -->

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Profilo Utente</title>
    <style>
        .form-container {
            margin-top: 20px;
        }
        .form-container form {
            margin-bottom: 20px;
        }
        .form-container input[type="text"], .form-container input[type="email"], .form-container input[type="password"] {
            width: 100%;
            padding: 12px;
            margin: 8px 0;
            box-sizing: border-box;
        }
        .form-container input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            padding: 14px 20px;
            margin: 8px 0;
            border: none;
            cursor: pointer;
        }
        .form-container input[type="submit"]:hover {
            background-color: #45a049;
        }

        .button {
            display: inline-block;
            background-color: #007bff;
            color: #fff;
            padding: 10px 20px;
            text-align: center;
            text-decoration: none;
            border-radius: 5px;
            margin-right: 10px;
            cursor: pointer;
        }
        .button:hover {
            background-color: #0056b3;
        }

    </style>
</head>
<body>
    <h2>Profilo Utente</h2>

    <% 
    String userId = (String) session.getAttribute("userid"); // Recupera l'userId dalla sessione
    if (userId != null) {
        ProductModelDS ps = new ProductModelDS(); // Istanza del modello degli utenti
        UserBean user = null;
        try {
            user = ps.doRetrieveByKeyUser(userId); // Recupera l'utente dal database
        } catch (SQLException e) {
            e.printStackTrace(); // Gestione dell'errore
        }
        
        if (user != null) { // Se l'utente è stato trovato nel database
    %>

    <!-- Dati personali dell'utente -->
    <div>
        <h3>Dati Personali</h3>
        <p>Username: <%= user.getUserid() %></p>
        <p>Telefono: <%= user.getTelefono() %></p>
        <p>Indirizzo: <%= capitalizeWords(user.getIndirizzo()) %>, <%= toUpperCase(user.getCitta()) %>, <%= toUpperCase(user.getProvincia()) %> - <%= user.getCap() %></p>
    </div>

    <!-- Form per la modifica dell'indirizzo e del telefono  -->
    <div class="form-container">
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
            
            <input class="button" type="submit" value="Aggiorna Indirizzo">
        </form>
    </div>

    <!-- Form per l'aggiunta o la modifica di un metodo di pagamento -->
    <form action="PagamentoControl?action=addmetodopagamento" method="post" id="payment-form">
    <input type="hidden" id="userid" name="userid" value="<%= user.getUserid() %>">

    <label for="tipo_pagamento">Tipo di pagamento:</label>
    <select id="tipo_pagamento" name="tipo_pagamento" onchange="togglePaymentFields()">
        <option value="PayPal">PayPal</option>
        <option value="Carta di Credito">Carta di Credito</option>
    </select>

    <div id="paypal_fields" style="display: none;">
        <label for="paypal_account_id">Email PayPal:</label>
        <input type="email" id="paypal_account_id" name="account_id">
    </div>

    <div id="credit_card_fields" style="display: none;">
        <label for="cc_account_id">Numero Carta:</label>
        <input type="text" id="cc_account_id" name="account_id">
        <label for="data_scadenza">Data di Scadenza:</label>
        <input type="date" id="data_scadenza" name="data_scadenza">
        <label for="cvv">CVV:</label>
        <input type="text" id="cvv" name="cvv">
    </div>

    <button class="button" type="submit">Aggiorna metodo di pagamento</button>
    </form>


    <script>
        document.getElementById("payment-form").addEventListener("submit", function(event) {
            if (!validateForm()) {
                event.preventDefault(); //se la validazione fallisce il form non viene submit
            }
        });
        
        function validateForm() { //validazione della correttezza dei dati 
            var tipoPagamento = document.getElementById("tipo_pagamento").value;
            var valid = true;
        
            if (tipoPagamento === "Carta di Credito") {
                var ccNumber = document.getElementById("cc_account_id").value;
                var dataScadenza = document.getElementById("data_scadenza").value;
                var cvv = document.getElementById("cvv").value;
                
                // Validazione del numero della carta di credito
                if (!/^\d{16}$/.test(ccNumber)) {
                    alert("Inserisci un nuemero di carta di credito valido (16 cifre).");
                    valid = false;
                }
        
                // Validazione della data di scadenza
                var today = new Date();
                var expirationDate = new Date(dataScadenza);
                if (expirationDate <= today) {
                    alert("Inserisci una data di scadenza valida.");
                    valid = false;
                }
        
                // Validazione del CVV
                if (!/^\d{3}$/.test(cvv)) {
                    alert("Inserisci un CVV valido (3 cifre).");
                    valid = false;
                }
            }
        
            return valid;
        }
        
        function togglePaymentFields() {
            var tipoPagamento = document.getElementById("tipo_pagamento").value;
            var paypalFields = document.getElementById("paypal_fields");
            var creditCardFields = document.getElementById("credit_card_fields");
        
            if (tipoPagamento === "PayPal") {
                paypalFields.style.display = "block";
                creditCardFields.style.display = "none";
                
                document.getElementById("paypal_account_id").disabled = false;
                document.getElementById("cc_account_id").disabled = true;
                document.getElementById("data_scadenza").disabled = true;
                document.getElementById("cvv").disabled = true;
            } else if (tipoPagamento === "Carta di Credito") {
                paypalFields.style.display = "none";
                creditCardFields.style.display = "block";
                
                document.getElementById("paypal_account_id").disabled = true;
                document.getElementById("cc_account_id").disabled = false;
                document.getElementById("data_scadenza").disabled = false;
                document.getElementById("cvv").disabled = false;
            } else {
                paypalFields.style.display = "none";
                creditCardFields.style.display = "none";
                
                document.getElementById("paypal_account_id").disabled = true;
                document.getElementById("cc_account_id").disabled = true;
                document.getElementById("data_scadenza").disabled = true;
                document.getElementById("cvv").disabled = true;
            }
        }
        
        togglePaymentFields(); //chiamata utile a inizializzare il form all'apertura della pagina
        </script>

    

    <!-- Tasti per admin -->
    <% if ("Admin".equals(user.getTipo())) { %>
        <a href="catalogo.jsp" class="button">Catalogo</a>
        <a href="ordini-admin.jsp" class="button">Ordini</a>
        <a href="lista-utenti.jsp" class="button">Utenti</a>
    <% } %>

    <% if("Customer".equals(user.getTipo())){ %>
        <a href="ordini-customer.jsp" class="button">Ordini</a>
    <% } %>

    <!-- Pulsante di logout -->
    <form action="UserControl?action=logoututente" method="post">
        <input type="submit" value="Logout">
    </form>
    
    <%} else {
        // Gestione nel caso in cui l'utente non sia stato trovato
        out.println("<p>Utente non trovato.</p>");
    }
    }
    %>

</body>
<%@ include file="includes/footer.jsp" %>
</html>