<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="includes/header.jsp" %>

<!-- PAGINA SPECIFICA DI UN PRODOTTO CHE MOSTRA TUTTI I SUOI DETTAGLI E OFFRE LA POSSIBILITA' DI ACQUISTARLO -->

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dettagli Prodotto</title>
</head>
<body>

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
<div class="bodyContainerCart">
    <div class="containerProdotto">
    
        <!-- Mostra l'immagine del prodotto -->
        <%
        byte[] immagine = product.getImmagine();
        if (immagine != null && immagine.length > 0) {
            String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
        %>
        <div class="leftColumn">
            <div class="imgCornice">
            <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= product.getNome() %>">
            </div>
        </div>
        <% 
        } 
        %>
        <div class="centerColumn">
        <h3 style="font-weight: bolder;"><%= product.getNome() %></h3>
        <p>Marca: <%= product.getMarca() %></p>
        <p>Compatibile con: <%= product.getModelloAuto() %></p>
        <p><%= product.getDescrizione() %></p>
        
        
     </div>
        <div class="rightColumn">
        <p>Prezzo: € <%= String.format("%.2f", product.getPrezzo()) %></p>
        <% if(product.getQuantita() < 1 ) {%>
            <p class="outOfStock">Prodotto esaurito!</p> 
            <%
            }
            else { %>
             <p>Quantità disponibile: </p> 
            <p><%= product.getQuantita() %></p>
            
        
        
        
         <!-- Pulsante per aggiungere al carrello -->
         <form id="addToCartForm" method="post">
            <input type="hidden" name="productId" value="<%= product.getId() %>">
            <button type="button" onclick="addToCart()">Aggiungi al carrello</button>
        </form>
        <!--ESPERIMENTO -->
        <form action="OrdineControl" method="post">
                        <input type='hidden' name='action' value='saveorder'>
                        <button type='submit' id="addButton">Compra subito!</button>
           <% }%>
        </form>
       </div>
   </div>


    <% 
    } else {
        // Gestione nel caso in cui il prodotto non sia stato trovato
        out.println("<p>Prodotto non trovato.</p>");
    }
    %>
    </div>
</body>
<script src="script.js"></script>

<script>
    function addToCart() {
        const form = document.getElementById('addToCartForm');
        const formData = new FormData(form);
    
        fetch('ProductControl?action=addProduct', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())  // Assicurati che il server restituisca una risposta JSON
        .then(data => {
            const feedbackElement = document.getElementById('cartFeedback');
            if (data.success) {
                feedbackElement.innerText = 'Prodotto aggiunto al carrello!';
                feedbackElement.style.color = 'green';
            } else {
                feedbackElement.innerText = 'Errore nell\'aggiunta del prodotto al carrello.';
                feedbackElement.style.color = 'red';
            }
        })
        .catch(error => {
            console.error('Error:', error);
            const feedbackElement = document.getElementById('cartFeedback');
            feedbackElement.innerText = 'Errore di comunicazione con il server.';
            feedbackElement.style.color = 'red';
        });
    }
    </script>
<%@ include file="includes/footer.jsp" %>
</html>