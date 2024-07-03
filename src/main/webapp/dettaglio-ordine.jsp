<%@ page import="it.unisa.model.ProductBean" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- PAGINA CHE VISUALIZZA I PRODOTTI E I DETTAGLI DI UNO SPECIFCO ORDINE - dalla pagina che mostra tutti gli ordini -->
<%
    // Ottieni la lista dei prodotti dall'attributo della richiesta
    List<ProductBean> products = (List<ProductBean>) request.getAttribute("order");

    if (products == null || products.isEmpty()) {
        out.println("<p style='color: red;'>Non ci sono prodotti disponibili per questo ordine.</p>");
    } else {
%>
    <table border="1">
        <tr>
            <th>ID Prodotto</th>
            <th>Nome</th>
            <th>Descrizione</th>
            <th>Prezzo</th>
            <th>Immagine</th>
        </tr>
        <% for (ProductBean product : products) { %>
            <tr>
                <td><%= product.getId() %></td>
                <td><%= product.getNome() %></td>
                <td><%= product.getDescrizione() %></td>
                <td><%= product.getPrezzo() %></td>
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
<% } %>

<!-- per capire se tornare alla pagina ordini degli admin o alla pagina ordine dei customer-->
<% 
String tipo = (String) session.getAttribute("tipo");
%>
<% if ("Admin".equals(tipo)) { %>
    <a href="ordini-admin.jsp" style="text-decoration: none; color: black;">
        <button type="button">Vai ai tuoi Ordini</button>
    </a>
<% } else if ("Customer".equals(tipo)) { %>
    <a href="ordini-customer.jsp" style="text-decoration: none; color: black;">
        <button type="button">Torna ai tuoi Ordini</button>
    </a>
<% } %>

<%@ include file="includes/footer.jsp" %>