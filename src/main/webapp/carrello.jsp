<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="it.unisa.model.CartBean, it.unisa.model.ProductBean, it.unisa.model.UserBean" %>
<%@ include file="includes/header.jsp" %>

<!-- PAGINE DEL CARRELLO ACCESSIBILE SIA LATO ADMIN SIA LATO UTENTE REGISTRATO DALL'INTERFACCIA DEL SITO -->

<link rel="stylesheet" href="styles/cart.css">
<style>
    table {
        border-collapse: collapse;
        width: 100%;
    }
    td, th {
        border: 1px solid #ddd;
        padding: 8px;
    }
    td {
        text-align: center;
    }
    .img-column img {
        width: 100px;
        height: auto;
    }
    .full-width-button {
        width: 100%;
        padding: 10px;
        background-color: #4CAF50;
        color: white;
        border: none;
        cursor: pointer;
    }
    .delete-button {
        background-color: red;
        color: white;
        border: none;
        cursor: pointer;
    }
    .fa-trash {
        font-size: 1.5rem;
    }
    @media (max-width: 600px) {
        .fa-trash {
            font-size: 1rem;
        }
    }
</style>

<div id="cart-container">
    <h1 id="cart-title">Carrello</h1>
    <%
        CartBean cart = (CartBean) session.getAttribute("cart");
        if (cart != null && !cart.getProducts().isEmpty()) {
            out.println("<table>");
            out.println("<tr><th>Immagine</th><th>Nome</th><th>Prezzo</th><th>Rimuovi</th></tr>");
            for (ProductBean product : cart.getProducts()) {
                out.println("<tr>");
                    String imgSrc = "images/" + product.getNome().toLowerCase() + ".png"; 
                    out.println("<td class='img-column'>");
                    byte[] immagine = product.getImmagine(); 
                    if (immagine != null && immagine.length > 0) {
                        String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                        out.println("<img src='data:image/jpeg;base64," + base64image + "' alt='" + product.getNome() + "' style='width: 100px; height: 100px;'>");
                    } else {
                        out.println("<img src='" + imgSrc + "' alt='" + product.getNome() + "'>");
                    }
                    out.println("</td>");
                    out.println("<td>" + product.getNome() + "</td>");
                    out.println("<td>" + String.format("%.2f", product.getPrezzo()) + "€</td>");
                    out.println("<td><form action='ProductControl' method='post'>"
                        + "<input type='hidden' name='action' value='deleteCart'>"
                        + "<input type='hidden' name='idprodotto' value='" + product.getId() + "'>"
                        + "<button type='submit' class='delete-button'><i class='fa fa-trash' aria-hidden='true'></i></button>"
                        + "</form></td>");
                    out.println("</tr>");
            }
            out.println("</table>");
            String userid = (String) session.getAttribute("userid");
    %>
            <% if (userid != null) {
                UserBean user = (UserBean) session.getAttribute("user");
                boolean canPurchase = user != null && user.getIndirizzo() != null && user.getCitta() != null && user.getProvincia() != null && user.getCap() != null && user.getTelefono() != null;

                if (canPurchase) { %>
                    <form action="OrdineControl" method="post">
                        <input type='hidden' name='action' value='saveorder'>
                        <button type='submit' class='full-width-button'>Finalizza l'acquisto</button>
                    </form>
                <% } else { %>
                    <p style='text-align: center;'>Per completare l'acquisto, aggiungi il tuo indirizzo, città, provincia e CAP e Telefono nel tuo profilo</p>
                <% }
            } else { %>
                <p style='text-align: center;'>Accedi per finalizzare l'acquisto</p>
            <% } %>
        <% } else {
            out.println("<p style='text-align: center;'>Il carrello è vuoto.</p>");
        }
    %>
</div>
<%@ include file="includes/footer.jsp" %>
