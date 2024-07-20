<%@ page import="java.util.List" %>
<%@ page import="it.unisa.model.OrderBean" %>
<%@ page import="it.unisa.model.ProductBean" %>
<%@ include file="includes/header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<!-- PAGINA CHE MOSTRA, LATO CUSTOMER LOGGATO, TUTTI GLI ORDINI CHE HA EFFETTUATO -->


<%
    String userid = (String) session.getAttribute("userid");
    if (userid == null) {
        response.sendRedirect("login.jsp");
        return;
    } else {
        String tipo = (String) session.getAttribute("tipo");
        if (tipo == null || !tipo.equals("Customer")) {
            response.sendRedirect("login.jsp");
            return;
        } else {
            List<OrderBean> orders = (List<OrderBean>) request.getAttribute("orders");
                if (orders == null || orders.isEmpty()) {
                    RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/OrdineControl?action=listaordini");
                    dispatcher.forward(request, response);
                    return;
                }
%>
<div class="bodyContainer">
<div style="display: flex; justify-content: center; margin-top:400px;">
    <h2 style="color: #2074b0; font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">I tuoi Ordini : </h2>
</div>
<div class="table-container ">
<table border="1" class="tabellaProdotto">
    <tr style="color:black; font-weight: bolder;">
        <th>Order ID</th>
        <th>User ID</th>
        <th>Indirizzo</th>
        <th>Città</th>
        <th>Provincia</th>
        <th>Cap</th>
        <th>Data Ordine</th>
        <th>Stato</th>
        <th>Prezzo Totale</th>
        <th>Azioni</th>
    </tr>
    <% for (OrderBean order : orders) { %>
        <tr style="color: #2074b0;">
            <td><%= order.getIdordine() %></td>
            <td><%= order.getUserid() %></td>
            <td><%= order.getIndirizzo() %></td>
            <td><%= order.getCitta() %></td>
            <td><%= order.getProvincia() %></td>
            <td><%= order.getCap() %></td>
            <td><%= order.getDataOrdine() %></td>
            <td class="<%= order.getStato() ? "spedito" : "non-spedito" %>">
                <%= order.getStato() ? "Spedito" : "Non Spedito" %>
            </td>
            <td><%= String.format("%.2f", order.getPrezzoTotale()) %> €</td>
            <td>
                <a href="OrdineControl?action=orderdetails&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-circle-info" aria-hidden="true"></i></a>
                <a href="OrdineControl?action=generafattura&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-file-invoice-dollar" aria-hidden="true"></i></a>
            </td>
        </tr>
    <% } %>
</table>
</div>
<%
        }
    }
%>
</div>
<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>