<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="it.unisa.model.ProductBean" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>

<!-- PAGINA DI GESTIONE DEL CATALOGO LATO AMMINISTRATORE -->

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="containerProdotti" id="containerProdotti">
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

<div style="margin-top:100px;">
    <h2>Prodotti</h2>
</div>
<div style="margin-top:100px;">
    <button onclick="showInsertProduct()" class="button"  id="insertButton">Inserisci prodotto</button>
</div>
<div class="cardAggiungiProdotto" id="cardProdotto">

<!-- Form di inserimento prodotti lato amministratore -->



<form action="ProductControl?action=insert" method="post"  enctype="multipart/form-data">
    
    <label for="nome">Nome:</label><br> 
    <input name="nome" type="text" maxlength="50" required placeholder="Inserisci nome"><br>
    
    <label for="marca">Marca:</label><br> 
    <input name="marca" type="text" maxlength="50" required placeholder="Inserisci marca"><br>
    
    <label for="modello">Modello:</label><br> 
    <input name="modello_auto" type="text" maxlength="50" required placeholder="Inserisci modello"><br>

    <label for="descrizione">Descrizione:</label><br>
    <textarea name="descrizione" maxlength="200" rows="3" required placeholder="Inserisci descrizione"></textarea><br>
    
    <label for="prezzo">Prezzo:</label><br>
    <input name="prezzo" type="text" pattern="^\d+(\.\d{1,2})?$" title="Inserisci un numero valido. Massimo due cifre decimali." required><br>

    <label for="quantita">Quantita:</label><br> 
    <input name="quantita" type="number" min="1" value="1" required style="text-align:center;"><br> 
    
    <label for="immagine">Immagine:</label><br>
    <input name="immagine" type="file" accept="image/jpeg, image/png" required style="margin:auto;"><br> 
    
    <input type="submit" value="Add" id="bottoneCatalogo">
    <input type="reset" value="Reset" id="bottoneCatalogo">
</form>
<div style="margin-bottom:20px">
    <button onclick="hideInsertProduct()" class="button" id="hideButton">Nascondi inserimento</button>
</div>

</div>



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


<div class="table-container" id="containerTabella">
<table border="1" class="tabellaProdotto">
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
        <td><%= String.format("%.2f", bean.getPrezzo())%>€</td>
       
        <td><%= bean.getQuantita() %></td>
        <td><%= bean.getMarca() %></td>
        <td><%= bean.getModelloAuto() %></td>

        <!-- colonna con i tasti per la gestione delle azioni da fare per ogni prodotto -->
        <td>
            <a href="ProductControl?action=readdetails&idprodotto=<%= bean.getId() %>" style="margin-left: 0.625rem;"><i class="fa-solid fa-pen" aria-hidden="true"></i></a>
            <a href="ProductControl?action=delete&idprodotto=<%= bean.getId() %>"style="margin-left: 0.625rem;"><i class="fa-solid fa-trash" aria-hidden="true"></i></a>
        </td>
    </tr>
    <%
        }
    %>
</table>

</div>
<%
        }
    }
%>

</div>
<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>