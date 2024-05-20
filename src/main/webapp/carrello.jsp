<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.model.CartBean" %>
<%@ page import="it.unisa.model.ProductBean" %>
<!DOCTYPE html>
<html>
<head>
    <title>Carrello</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
    </style>
</head>
<body>
    <%
        CartBean cart = (CartBean) session.getAttribute("cart");
        if (cart == null) {
            cart = new CartBean();
            session.setAttribute("cart", cart);
        }
        List<ProductBean> products = cart.getProducts();
    %>
    <h1>Il tuo Carrello</h1>
    <table>
        <tr>
            <th>Nome</th>
            <th>Descrizione</th>
            <th>Marca</th>
            <th>Modello</th>
            <th>Prezzo</th>
            <th>Quantità</th>
            <th>Totale</th>
            <th>Azione</th>
        </tr>
        <% float totaleCarrello = 0; 
           for (ProductBean product : products) { 
               float totaleProdotto = product.getPrezzo() * product.getQuantita();
               totaleCarrello += totaleProdotto;
        %>
        <tr>
            <td><%= product.getNome() %></td>
            <td><%= product.getDescrizione() %></td>
            <td><%= product.getMarca() %></td>
            <td><%= product.getModelloAuto() %></td>
            <td><%= product.getPrezzo() %> €</td>
            <td>
                <form action="CarrelloControl" method="get" style="display:inline;">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= product.getId() %>">
                    <input type="number" name="quantita" value="<%= product.getQuantita() %>" min="1">
                    <input type="submit" value="Aggiorna">
                </form>
            </td>
            <td><%= totaleProdotto %> €</td>
            <td>
                <form action="CarrelloControl" method="get" style="display:inline;">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="id" value="<%= product.getId() %>">
                    <input type="submit" value="Rimuovi">
                </form>
            </td>
        </tr>
        <% } %>
    </table>
    <h2>Totale: <%= totaleCarrello %> €</h2>
</body>
</html>
