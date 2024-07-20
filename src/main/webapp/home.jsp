<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="java.util.Base64" %>


<!DOCTYPE html>
<html>
<head>
	<%@ include file="includes/header.jsp" %>
    <meta charset="UTF-8">
    <title>RoadRunnerParts</title>

</head>
<body>
	
    <div class="bodyContainer">
        

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
        
        
        <div class="catalog-container-home">
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
        
        
    </div>

    
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="script.js"></script>
    
<%@ include file="includes/footer.jsp" %>
</body>
</html>