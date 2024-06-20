<%@ page import="it.unisa.model.UserBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.sql.SQLException" %>
<%@ include file="includes/header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
        <p>Indirizzo: <%= user.getIndirizzo() %>, <%= user.getCitta() %>, <%= user.getProvincia() %> - <%= user.getCap() %></p>
    </div>

    <!-- Form per la modifica dell'indirizzo e del telefono  -->
    <div class="form-container">
        <h3>Modifica Dati Indirizzo</h3>
        <form action="ProductControl?action=changeUserLocation" method="post">
            <input type="hidden" name="userid" value="<%= user.getUserid() %>">
            <label for="indirizzo">Indirizzo</label>
            <input type="text" id="indirizzo" name="indirizzo" value="<%= user.getIndirizzo() %>" required>
            
            <label for="citta">Città</label>
            <input type="text" id="citta" name="citta" value="<%= user.getCitta() %>" required>
            
            <label for="provincia">Provincia</label>
            <input type="text" id="provincia" name="provincia" value="<%= user.getProvincia() %>" required>
            
            <label for="cap">CAP</label>
            <input type="text" id="cap" name="cap" value="<%= user.getCap() %>" required>
            
            <label for="telefono">Telefono</label>
            <input type="text" id="telefono" name="telefono" value="<%= user.getTelefono() %>" required>
            
            <input type="submit" value="Aggiorna Indirizzo">
        </form>
    </div>

    <!-- Form per l'aggiunta o la modifica di un metodo di pagamento -->
    <form action="ProductControl?action=addMetodoPagamento" method="post" id="payment-form";">
        <input type="hidden" name="userid" value="<%= user.getUserid() %>">
        <label for="payment-method">Metodo di pagamento:</label>
        <select id="payment-method" name="payment-method">
            <option value="credit-card">Carta di credito</option>
            <option value="paypal">PayPal</option>
        </select>
        <div id="credit-card-info">
            <label for="card-number">Numero della carta:</label>
            <input type="text" id="card-number" name="card-number" required>
            <label for="expiry-date">Data di scadenza:</label>
            <input type="text" id="expiry-date" name="expiry-date" required>
            <label for="cvv">CVV:</label>
            <input type="text" id="cvv" name="cvv">
        </div>
        <input type="submit" value="Aggiorna metodo di pagamento">
    </form>

    <!-- Tasti per admin -->
    <% if ("Admin".equals(user.getTipo())) { %>
        <a href="catalogo.jsp" class="button">Catalogo</a>
        <a href="ordini.jsp" class="button">Ordini</a>
    <% } %>

    <!-- Pulsante di logout -->
    <form action="ProductControl?action=logoututente" method="post">
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
