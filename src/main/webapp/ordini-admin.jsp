<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="it.unisa.model.OrderBean" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ include file="includes/header.jsp" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<!-- PAGINA CHE MOSTRA TUTTI GLI ORDINI LATO AMMINISTRATORE CHE PERMETTE LA RICERCA DI ORDINI PER UTENTE, DALLA DATA ALLA DATA E MOSTRA TUTTI GLI ORDINI-->
<%
    String userid = (String) session.getAttribute("userid");
    if (userid == null) {
        response.sendRedirect("login.jsp");
        return;
    } else {
        String tipo = (String) session.getAttribute("tipo");
        if (tipo != null && tipo.equals("Customer")) {
            response.sendRedirect("login.jsp");
            return;
        } else if (tipo != null && tipo.equals("Admin")) {
            List<OrderBean> orders = (List<OrderBean>) request.getAttribute("orders");
            if (orders == null || orders.isEmpty()) {
                RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/OrdineControl?action=ordiniadmin");
                dispatcher.forward(request, response);
                return;
            }

            List<OrderBean> searchedOrders = (List<OrderBean>) request.getAttribute("searchedOrders");
            boolean hasSearchedOrders = searchedOrders != null && !searchedOrders.isEmpty();

            List<OrderBean> filteredOrders = (List<OrderBean>) request.getAttribute("filteredOrders");
            boolean hasFilteredOrders = filteredOrders != null && !filteredOrders.isEmpty();
%>

<div style="display: flex; justify-content: center; margin-right: 50%;">
    <h2 style="color: black; font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Storico Ordini: </h2>
</div>

<!-- Form per la ricerca per utente -->
<form action="OrdineControl" method="GET" style="margin-top: 10px;">
    <input type="hidden" name="action" value="ordiniutente">
    <label for="ordine">Cerca un ordine per utente: </label>
    <input type="text" id="ordine" name="userId">
    <input type="submit" value="Cerca">
</form>

<!-- Tabella per mostrare risultati ricerca per utente -->
<% if (hasSearchedOrders) { %>
    <div style="display: flex; justify-content: center; margin-right: 50%;">
        <h2 style="color: black; font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Risultati della ricerca per utente: </h2>
    </div>
    <table border="1" style="background-color: #90EE90;">
        <tr>
            <th>Order ID</th>
            <th>User ID</th>
            <th>Indirizzo</th>
            <th>Città</th>
            <th>Provincia</th>
            <th>Cap</th>
            <th>Data Ordine</th>
            <th>Prezzo Totale</th>
            <th>Azioni</th>
        </tr>
        <% for (OrderBean order : searchedOrders) { %>
            <tr>
                <td><%= order.getIdordine() %></td>
                <td><%= order.getUserid() %></td>
                <td><%= order.getIndirizzo() %></td>
                <td><%= order.getCitta() %></td>
                <td><%= order.getProvincia() %></td>
                <td><%= order.getCap() %></td>
                <td><%= order.getDataOrdine() %></td>
                <td><%= String.format("%.2f", order.getPrezzoTotale()) %> €</td>
                <td>
                    <a href="OrdineControl?action=orderdetails&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-circle-info" aria-hidden="true"></i></a>
                    <a href="OrdineControl?action=orderdetails&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-file-invoice-dollar" aria-hidden="true"></i></a>
                </td>
            </tr>
        <% } %>
    </table>
<% } else { %>
    <p style="color: red;">Utente non trovato o inserisci un utente per ricercarlo.</p>
<% } %>

<!-- Form per la ricerca degli ordini per data -->
<form action="OrdineControl" method="GET" style="margin-top: 10px;">
    <input type="hidden" name="action" value="ordiniperdata">
    <label for="fromDate">Da Data: </label>
    <input type="date" id="fromDate" name="fromdate" required>
    <label for="toDate">A Data: </label>
    <input type="date" id="toDate" name="todate" required>
    <input type="submit" value="Cerca">
</form>

<!-- Tabella per mostrare risultati ricerca per data -->
<% if (hasFilteredOrders) { %>
    <div style="display: flex; justify-content: center; margin-right: 50%;">
        <h2 style="color: black; font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Risultati della ricerca per data: </h2>
    </div>
    <table border="1" style="background-color: #90EE90;">
        <tr>
            <th>Order ID</th>
            <th>User ID</th>
            <th>Indirizzo</th>
            <th>Città</th>
            <th>Provincia</th>
            <th>Cap</th>
            <th>Data Ordine</th>
            <th>Prezzo Totale</th>
            <th>Azioni</th>
        </tr>
        <% for (OrderBean order : filteredOrders) { %>
            <tr>
                <td><%= order.getIdordine() %></td>
                <td><%= order.getUserid() %></td>
                <td><%= order.getIndirizzo() %></td>
                <td><%= order.getCitta() %></td>
                <td><%= order.getProvincia() %></td>
                <td><%= order.getCap() %></td>
                <td><%= order.getDataOrdine() %></td>
                <td><%= String.format("%.2f", order.getPrezzoTotale()) %> €</td>
                <td>
                    <a href="OrdineControl?action=orderdetails&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-circle-info" aria-hidden="true"></i></a>
                    <a href="OrdineControl?action=orderdetails&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-file-invoice-dollar" aria-hidden="true"></i></a>
                </td>
            </tr>
        <% } %>
    </table>
<% } else { %>
    <p style="color: red;">Nessun ordine trovato per il periodo selezionato.</p>
<% } %>

<!-- Tabella per mostrare tutti gli ordini -->
<div style="display: flex; justify-content: center; margin-right: 50%;">
    <h2 style="color: rgb(0, 0, 0); font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Tutti gli ordini: </h2>
</div>

<table border="1" style="background-color: #90EE90;">
    <tr>
        <th>Order ID</th>
        <th>User ID</th>
        <th>Indirizzo</th>
        <th>Città</th>
        <th>Provincia</th>
        <th>Cap</th>
        <th>Data Ordine</th>
        <th>Prezzo Totale</th>
        <th>Azioni</th>
    </tr>
    <% for (OrderBean order : orders) { %>
        <tr>
            <td><%= order.getIdordine() %></td>
            <td><%= order.getUserid() %></td>
            <td><%= order.getIndirizzo() %></td>
            <td><%= order.getCitta() %></td>
            <td><%= order.getProvincia() %></td>
            <td><%= order.getCap() %></td>
            <td><%= order.getDataOrdine() %></td>
            <td><%= String.format("%.2f", order.getPrezzoTotale()) %> €</td>
            <td>
                <a href="OrdineControl?action=orderdetails&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-circle-info" aria-hidden="true"></i></a>
                <a href="OrdineControl?action=orderdetails&idordine=<%= order.getIdordine() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-file-invoice-dollar" aria-hidden="true"></i></a>
            </td>
        </tr>
    <% } %>
</table>

<%
        }
    }
%>

<%@ include file="includes/footer.jsp" %>