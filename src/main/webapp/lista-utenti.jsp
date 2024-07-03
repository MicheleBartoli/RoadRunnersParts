<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="it.unisa.model.UserBean" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- PAGINA, LATO AMMINISTRATORE, CHE MOSTRA TUTTI GLI UTENTI CHE SONO NEL DB -->

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
        } else if (tipo.equals("Admin")) {
            List<UserBean> users = (List<UserBean>) request.getAttribute("users");
            if (users == null || users.isEmpty()) {
                RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/UserControl?action=users");
                dispatcher.forward(request, response);
                return;
            }

            UserBean searchedUser = (UserBean) request.getAttribute("searchedUser");
            boolean hasSearchedUser = searchedUser != null;  //boolean per capire se è stato trovato 
%>

<!-- Form per la ricerca -->
<form action="UserControl" method="GET" style="margin-top: 10px;">
    <input type="hidden" name="action" value="searchUser">
    <label for="userId">Cerca per UserID:</label>
    <input type="text" id="userId" name="userId">
    <input type="submit" value="Cerca">
</form>

<div style="display: flex; justify-content: center; margin-right: 50%;">
    <h2 style="color: black; font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Risultato della Ricerca</h2>
</div>

<% if (hasSearchedUser) { %>
    <table border="1" style="background-color: #90EE90; margin-bottom: 20px;">
        <tr>
            <th>User ID</th>
            <th>Tipo</th>
            <th>Indirizzo</th>
            <th>Città</th>
            <th>Provincia</th>
            <th>Cap</th>
            <th>Telefono</th>
            <th>Metodo Pagamento</th>
        </tr>
        <tr>
            <td><%= searchedUser.getUserid() %></td>
            <td><%= searchedUser.getTipo() %></td>
            <td><%= searchedUser.getIndirizzo() %></td>
            <td><%= searchedUser.getCitta() %></td>
            <td><%= searchedUser.getProvincia() %></td>
            <td><%= searchedUser.getCap() %></td>
            <td><%= searchedUser.getTelefono() %></td>
            <td><%= searchedUser.getMetodoPagamento() %></td>
        </tr>
    </table>
    <% } else { %>
        <p style="color: red;">Utente non trovato o inserisci un utente per ricercarlo.</p>
    <% } %>

<div style="display: flex; justify-content: center; margin-right: 50%;">
    <h2 style="color: rgb(0, 0, 0); font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Utenti</h2>
</div>

<table border="1" style="background-color: #90EE90;">
    <tr>
        <th>User ID</th>
        <th>Tipo</th>
        <th>Indirizzo</th>
        <th>Città</th>
        <th>Provincia</th>
        <th>Cap</th>
        <th>Telefono</th>
        <th>Metodo Pagamento</th>
    </tr>
    <% for (UserBean user : users) { %>
        <tr>
            <td><%= user.getUserid() %></td>
            <td><%= user.getTipo() %></td>
            <td><%= user.getIndirizzo() %></td>
            <td><%= user.getCitta() %></td>
            <td><%= user.getProvincia() %></td>
            <td><%= user.getCap() %></td>
            <td><%= user.getTelefono() %></td>
            <td><%= user.getMetodoPagamento() %></td>
        </tr>
    <% } %>
    <% } %>
    <% } %>
</table>

<%@ include file="includes/footer.jsp" %>
