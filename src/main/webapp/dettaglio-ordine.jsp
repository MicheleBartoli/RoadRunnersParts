<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.OrderBean" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- PAGINA CHE VISUALIZZA I PRODOTTI E I DETTAGLI DI UNO SPECIFICO ORDINE - dalla pagina che mostra tutti gli ordini -->
<%
    // Ottieni la lista dei prodotti dall'attributo della richiesta
    String idordine = request.getParameter("idordine");
    List<ProductBean> products = (List<ProductBean>) request.getAttribute("order");
    if (products == null || products.isEmpty()) {
        out.println("<p style='color: red;'>Non ci sono prodotti disponibili per questo ordine.</p>");
    } else {
        // Creare una mappa per aggregare i prodotti per ID e contare le quantità
        Map<String, ProductBean> productMap = new HashMap<>();
        Map<String, Integer> productCountMap = new HashMap<>();

        for (ProductBean product : products) {
            String productId = String.valueOf(product.getId());
            if (productMap.containsKey(productId)) {
                // Se il prodotto esiste già nella mappa, aggiorna la quantità
                int count = productCountMap.get(productId);
                productCountMap.put(productId, count + 1);
            } else {
                // Se il prodotto non esiste nella mappa, aggiungilo
                productMap.put(productId, product);
                productCountMap.put(productId, 1);
            }
        }

        // Convertire la mappa in una lista per iterare nella tabella
        List<ProductBean> aggregatedProducts = new ArrayList<>(productMap.values());
%>

<div class="containerProdotti">
    
<div class="table-container" id="containerTabella">

    <h1>ID Ordine: <%= idordine %></h1>
    <table border="1" class="tabellaProdotto">
        <tr>
            <th>ID Prodotto</th>
            <th>Nome</th>
            <th>Descrizione</th>
            <th>Prezzo</th>
            <th>Quantità</th>
            <th>Immagine</th>
        </tr>
        <% for (ProductBean product : aggregatedProducts) { 
            String productId = String.valueOf(product.getId());
            int quantity = productCountMap.get(productId);
        %>
            <tr>
                <td><%= product.getId() %></td>
                <td><%= product.getNome() %></td>
                <td><%= product.getDescrizione() %></td>
                <td><%= String.format("%.2f", product.getPrezzo()) %>€</td>
                <td><%= quantity %></td>
                <td>
                    <%
                        byte[] immagine = product.getImmagine();
                        if (immagine != null && immagine.length > 0) {
                            String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                    %>
                            <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= product.getNome() %>" style="width: 100px; height: 100px;">
                    <% 
                        } 
                    %>
                </td>
            </tr>
        <% } %>
    </table>
</div>
<% } %>

<!-- per capire se tornare alla pagina ordini degli admin o alla pagina ordine dei customer-->
<% 
String tipo = (String) session.getAttribute("tipo");
%>
<% if ("Admin".equals(tipo)) { %>
    <a href="ordini-admin.jsp" style="text-decoration: none; color: black;">
        <button type="button" id="bottoneCardProduct">Vai ai tuoi Ordini</button>
    </a>
<% } else if ("Customer".equals(tipo)) { %>
    <a href="ordini-customer.jsp" style="text-decoration: none; color: black;">
        <button type="button" id="bottoneCardProduct">Torna ai tuoi Ordini</button>
    </a>
<% } %>

</div>

<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>