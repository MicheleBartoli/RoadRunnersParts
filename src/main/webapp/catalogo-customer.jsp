<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/header.jsp" %>

<head>
    <title>Catalogo Prodotti</title>
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
                    <div class='cardProduct'>
                        
                        <%
                        byte[] immagine = prodotto.getImmagine();
                        if (immagine != null && immagine.length > 0) {
                            String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                    %>
                        <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= prodotto.getNome() %>" style="width: 200px; height: 200px;">
                    <% 
                        } 
                    %>
                        <div class='product-name'><a href="pagina-prodotto.jsp?id=<%= prodotto.getId() %>" > <%= prodotto.getNome() %></a></div>
                        <div class='product-price'><%= String.format("%.2f", prodotto.getPrezzo())%>€</div>
                        
                        <% if(prodotto.getQuantita() < 1 ) {%>
        						<p class="outOfStock">Prodotto esaurito!</p> 
        					<%
        					}
        					else { %>
                        
                        <form action="ProductControl?action=addproduct&idprodotto=<%= prodotto.getId() %>" method="post">
                            <input type="hidden" name="productId" value="<%= prodotto.getId() %>" />
                            <button type="submit" id="bottoneCardProduct">Aggiungi al carrello</button>
                        </form>
                        <% 
                        } 
                        %>
                        <a href="pagina-prodotto.jsp?id=<%= prodotto.getId() %>" class="details-button">Apri pagina prodotto</a>
                    </div>
                    <%
                }
            }
        %>
    </div>
</body>
<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>
</html>