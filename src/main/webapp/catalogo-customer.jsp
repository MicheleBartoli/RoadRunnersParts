<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/header.jsp" %>

<head>
    <title>Catalogo Prodotti</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        h1 {
            text-align: center;
            padding: 20px;
            background-color: #333;
            color: #fff;
            margin: 0;
        }
        .catalog-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            padding: 20px;
        }
        .tile {
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin: 10px;
            padding: 20px;
            width: 200px;
            text-align: center;
        }
        .tile img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
        }
        .tile .product-name {
            font-size: 1.2em;
            margin: 10px 0;
        }
        .tile .product-price {
            font-size: 1.1em;
            color: green;
            margin: 10px 0;
        }
        .tile button {
            margin-top: 10px;
            padding: 10px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .tile button:hover {
            background-color: #0056b3;
        }
        .tile .details-button:hover {
            background-color: #218838;
        }
        .search-container {
            text-align: center;
            padding: 20px;
            margin-top: 50px;
        }
    </style>
</head>

<body>
    <h1>Catalogo Prodotti</h1>

    <div class="search-container">
        <form action="ProductControl" method="get">
            <input type="hidden" name="action" value="cercamarcamodello">
            <input type="text" name="marca" placeholder="Marca Auto" required>
            <input type="text" name="modello" placeholder="Modello Auto" required>
            <button type="submit">Cerca Ricambio</button>
        </form>
    </div>
    
    <div class="catalog-container">
        <%
            List<ProductBean> prodotti = (List<ProductBean>) request.getAttribute("prodotti");
            if (prodotti == null || prodotti.isEmpty()) {
                RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ProductControl?action=products-customer");
                dispatcher.forward(request, response);
                return;
            }

            if (prodotti != null) {
                for (ProductBean prodotto : prodotti) {
                    %>
                    <div class='tile'>
                        
                        <%
                        byte[] immagine = prodotto.getImmagine();
                        if (immagine != null && immagine.length > 0) {
                            String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                    %>
                        <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= prodotto.getNome() %>" style="width: 100px; height: 100px;">
                    <% 
                        } 
                    %>
                        <div class='product-name'><%= prodotto.getNome() %></div>
                        <div class='product-price'>€<%= prodotto.getPrezzo() %></div>
                        <form action="ProductControl?action=addproduct&idprodotto=<%= prodotto.getId() %>" method="post">
                            <input type="hidden" name="productId" value="<%= prodotto.getId() %>" />
                            <button type="submit">Aggiungi al carrello</button>
                        </form>
                        <a href="pagina-prodotto.jsp?id=<%= prodotto.getId() %>" class="details-button">Mostra dettagli</a>
                    </div>
                    <%
                }
            }
        %>
    </div>
</body>

<%@ include file="includes/footer.jsp" %>
</html>