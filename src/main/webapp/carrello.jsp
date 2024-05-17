<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="it.unisa.model.CartBean, it.unisa.model.ProductBean, it.unisa.model.UserBean" %>
<%@ include file="header.jsp" %>

<div id="cart-container">
    <h1 id="cart-title">CARRELLO</h1>
    <%
        CartBean cart = (CartBean) session.getAttribute("cart");
        if (cart != null && !cart.getProducts().isEmpty()) {
            out.println("<table>");
            out.println("<tr><th class='img-column'>Immagine</th><th>Tipo</th><th>Asse</th><th>Carrello</th><th>Cuscinetti</th><th>Ruote</th><th>Prezzo</th><th>RIMUOVI</th></tr>");
            for (ProductBean product : cart.getProducts()) {
                out.println("<tr>");
                out.println("<td class='img-column'><img src='" + imgSrc + "' alt='" + tipo + "' width='100%'></td>");
                out.println("<td>" + product.getTipo() + "</td>");
                out.println("<td>" + String.format("%.2f", product.getTotalPrice()) + "\u20AC</td>");
                out.println("<td><form action='ProductControl' method='post'>"
                    + "<input type='hidden' name='action' value='deleteCart'>"
                    + "<input type='hidden' name='skateboardId' value='" + product.getId() + "'>"
                    + "<button type='submit' class='delete-button'><i class='fa fa-trash' aria-hidden='true'></i></button>"
                    + "</form></td>");
                out.println("</tr>");
            }
            out.println("</table>");
            String userid = (String) session.getAttribute("userid"); %>
            <% if (userid != null) {
                boolean canPurchase = true;
                String outOfStockComponent = null;
                Map<String, Integer> componentQuantities = new HashMap<>();
                for (ProductBean product : cart.getProducts()) {
                    for (ProductBean product : product.getProducts()) {
                        // Aggiorna la quantità del componente
                        ProductModelDS productModelDS = new ProductModelDS();
                        product = productModelDS.doRetrieveByKey(product.getId());
                        componentQuantities.put(component.getNome(), componentQuantities.getOrDefault(component.getNome(), 0) + 1);
                        if (component.getQuantita() < componentQuantities.get(component.getNome())) {
                            canPurchase = false;
                            outOfStockComponent = component.getNome();
                            break;
                        }
                    }
                    if (!canPurchase) {
                        break;
                    }
                }
            
                // Verifica che l'utente abbia un indirizzo, città, provincia e CAP nel database
                ProductModelDS productModelDS = new ProductModelDS();
                UserBean user = productModelDS.doRetrieveByKeyUser(userid);
                if (user.getIndirizzo() == null || user.getCitta() == null || user.getProvincia() == null || user.getCAP() == null) {
                    canPurchase = false;
                }
            
                if (canPurchase) { %>
                    <form action="ProductControl" method="post">
                        <input type='hidden' name='action' value='saveOrder'>
                        <button type='submit' class='full-width-button'>Finalizza l'acquisto</button>
                    </form>
                <% } else if (outOfStockComponent != null) { %>
                    <p style='text-align: center;'>Abbiamo esaurito il componente <%= outOfStockComponent %> nel tuo ordine, rimuovilo o attendi che viene rifornito per completare l'acquisto</p>
                <% } else { %>
                    <p style='text-align: center;'>Per completare l'acquisto, aggiungi il tuo indirizzo, città, provincia e CAP nel tuo profilo</p>
                <% }
            } else { %>
                <p style='text-align: center;'>Accedi per finalizzare l'acquisto</p>
            <% } %>
            <% } else {
            out.println("<p style='text-align: center;'>Il carrello è vuoto.</p>");
        }
    %>
</div>
<%@ include file="footer.jsp" %>