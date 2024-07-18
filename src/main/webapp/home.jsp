<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.util.Base64" %>


<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>RoadRunnerParts</title>

    <style>
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
    </style>
</head>
<body>
    <div class="bodyContainer">
        <%@ include file="includes/header.jsp" %>

        <div class="slideshow-container">
            <div class="mySlides">
                <img src="images/slideshow/image1.jpg" style="width:100%">
            </div>
            <div class="mySlides">
                <img src="images/slideshow/image2.jpg" style="width:100%">
            </div>
            <div class="mySlides">
                <img src="images/slideshow/image3.jpg" style="width:100%">
            </div>
        </div>
    </div>

    <div class="catalog-container">
        <%
            List<ProductBean> prodotti = (List<ProductBean>) request.getAttribute("randomProducts");
            if (prodotti == null || prodotti.isEmpty()) {
                RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ProductControl?action=prodottirandom");
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
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="script.js"></script>
    
<%@ include file="includes/footer.jsp" %>
</body>
</html>