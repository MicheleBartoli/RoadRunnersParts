<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="it.unisa.model.ProductBean" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>

<!-- PAGINA DI GESTIONE DEL CATALOGO LATO AMMINISTRATORE -->

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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
            List<ProductBean> prodotti = (List<ProductBean>) request.getAttribute("prodotti");
            if (prodotti == null || prodotti.isEmpty()) {
                RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ProductControl?action=amministratore");
                dispatcher.forward(request, response);
                return;
            }
%>

<!-- menù selezione per ordinare i prodotti per id, nome o prezzo-->
<form action="ProductControl" method="get" id="sortForm">
    <input type="hidden" name="action" value="amministratore">
    <label for="sortOption">Ordina per:</label><br>
    <select name="sortOption" onchange="document.getElementById('sortForm').submit();">
        <option value="idprodotto" <% if ("idprodotto".equals(request.getParameter("sortOption"))) out.print("selected"); %>>ID</option> <!-- serve per fare in modo che rimane visualizzato il parametro che abbiamo scelto all interno del menu a tendina -->
        <option value="nome" <% if ("nome".equals(request.getParameter("sortOption"))) out.print("selected"); %>>Nome</option>
        <option value="prezzo" <% if ("prezzo".equals(request.getParameter("sortOption"))) out.print("selected"); %>>Prezzo</option>
    </select><br>
</form>


<div style="display: flex; justify-content: center; margin-right: 50%;">
    <h2 style="color: white; font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Prodotti</h2>
</div>
<table border="1" style="background-color: #90EE90;">
    <tr>
        <th>Immagine</th>
        <th>ID</th>
        <th>Nome</th>
        <th>Descrizione</th>
        <th>Prezzo</th>
        <th>Quantità</th>
        <th>Marca</th>
        <th>Modello</th>
        <th>Azione</th>
    </tr>
    <%
        for (ProductBean bean : prodotti) {
    %>
    <tr>
        <td>
            <%
                byte[] immagine = bean.getImmagine();
                if (immagine != null && immagine.length > 0) {
                    String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
            %>
                <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= bean.getNome() %>" style="width: 100px; height: 100px;">
            <% 
                } 
            %>
        </td>
        <td><%= bean.getId() %></td>
        <td><%= bean.getNome() %></td>
        <td><%= bean.getDescrizione() %></td>
        <td><%= bean.getPrezzo() %></td>
        <td><%= bean.getQuantita() %></td>
        <td><%= bean.getMarca() %></td>
        <td><%= bean.getModelloAuto() %></td>

        <!-- colonna con i tasti per la gestione delle azioni da fare per ogni prodotto -->
        <td>
            <a href="ProductControl?action=readdetails&idprodotto=<%= bean.getId() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-pen" aria-hidden="true"></i></a>
            <a href="ProductControl?action=addProduct&idprodotto=<%= bean.getId() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-cart-plus" aria-hidden="true"></i></a>
            <a href="ProductControl?action=delete&idprodotto=<%= bean.getId() %>"style="margin-left: 0.625rem;"><i class="fa-solid fa-trash" aria-hidden="true"></i></a>
        </td>
    </tr>
    <%
        }
    %>
</table>

<!-- Form di inserimento prodotti lato amministratore -->

<div style="display: flex; justify-content: center; margin-right: 88%;">
    <h2 style="color: rgb(0, 0, 0);">Inserisci</h2>
</div>
<form action="ProductControl?action=insert" method="post" class="form-container3" enctype="multipart/form-data">
    
    <label for="nome">Nome:</label><br> 
    <input name="nome" type="text" maxlength="20" required placeholder="Inserisci nome"><br>
    
    <label for="marca">Marca:</label><br> 
    <input name="marca" type="text" maxlength="20" required placeholder="Inserisci marca"><br>
    
    <label for="modello">Modello:</label><br> 
    <input name="modello_auto" type="text" maxlength="20" required placeholder="Inserisci modello"><br>

    <label for="descrizione">Descrizione:</label><br>
    <textarea name="descrizione" maxlength="100" rows="3" required placeholder="Inserisci descrizione"></textarea><br>
    
    <label for="prezzo">Prezzo:</label><br>
    <input name="prezzo" type="text" pattern="^\d+(\.\d{1,2})?$" title="Inserisci un numero valido. Massimo due cifre decimali." required><br>

    <label for="quantita">Quantita:</label><br> 
    <input name="quantita" type="number" min="1" value="1" required><br> 
    
    <label for="immagine">Immagine:</label><br>
    <input name="immagine" type="file" accept="image/jpeg, image/png" required><br>
    
    <input type="submit" value="Add"><input type="reset" value="Reset">
</form>
<form action="UserControl?action=logoututente" method="post" style="margin-bottom: 8.125rem; margin-top: 1.25rem;">
    <input type="hidden" name="action" value="logout">
    <input type="submit" value="Logout">
</form>
<%
        }
    }
%>
<%@ include file="includes/footer.jsp" %>