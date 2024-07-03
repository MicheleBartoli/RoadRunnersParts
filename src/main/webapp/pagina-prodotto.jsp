<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.sql.SQLException" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="includes/header.jsp" %>

<!-- PAGINE SPECIFICA DI UN PRODOTTO CHE MOSTRA TUTTI I SUOI DETTAGLI E OFFRE LA POSSIBILITA' DI ACQUISTARLO -->

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dettagli Prodotto</title>
    <style>
        /* Stili CSS per il pulsante */
        .add-to-cart-btn {
            background-color: #4CAF50; /* Colore di sfondo verde */
            color: white;
            padding: 12px 20px;
            text-alin: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin-top: 10px;
            border-radius: 4px;
            cursor: pointer;
            border: none;
        }
        .add-to-cart-btn:hover {
            background-color: #45a049; /* Cambia il colore al passaggio del mouse */
        }
    </style>
</head>
<body>
    <h2>Dettagli Prodotto</h2>

    <% 
    int productId = Integer.parseInt(request.getParameter("id")); // Recupera l'id del prodotto dalla richiesta
    ProductModelDS productModel = new ProductModelDS(); // Istanza del modello dei prodotti (assumendo un nome di classe simile)
    ProductBean product = null;
    try {
        product = productModel.doRetrieveByKey(productId); // Recupera il prodotto dal database
    } catch (SQLException e) {
        // Gestione dell'errore
        e.printStackTrace();
    }
    
    if (product != null) { // Se il prodotto è stato trovato nel database
    %>

    <div>
        <h3><%= product.getNome() %></h3>
        <p><%= product.getDescrizione() %></p>
        <p>Prezzo: € <%= product.getPrezzo() %></p>
        <p>Quantità disponibile: <%= product.getQuantita() %></p>
        <p>Marca: <%= product.getMarca() %></p>
        <p>Modello auto: <%= product.getModelloAuto() %></p>
        
        <!-- Mostra l'immagine del prodotto -->
        <%
        byte[] immagine = product.getImmagine();
        if (immagine != null && immagine.length > 0) {
            String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
        %>
        <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= product.getNome() %>" style="width: 100px; height: 100px;">
        <% 
        } 
        %>
        
        <!-- Pulsante per aggiungere al carrello -->
        <form action="ProductControl?action=addProduct&idprodotto=<%= product.getId() %>" method="post">
            <input type="hidden" name="productId" value="<%= product.getId() %>">
            <input type="submit" value="Aggiungi al carrello" class="add-to-cart-btn">
        </form>
    </div>

    <% 
    } else {
        // Gestione nel caso in cui il prodotto non sia stato trovato
        out.println("<p>Prodotto non trovato.</p>");
    }
    %>

</body>
<%@ include file="includes/footer.jsp" %>
</html>