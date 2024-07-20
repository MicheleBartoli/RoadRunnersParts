<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="it.unisa.model.ProductBean" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>


<!-- PAGINA CHE VIENE APERTA QUANDO SI VUOLE CAMBIARE QUALCHE ATTRIBUTO DI UN RICAMBIO LATO AMMINISTRATORE (da catalogo.jsp) (non è la pagina del prodotto che visualizzano i clienti) -->
<%
    
    ProductBean prodotto = (ProductBean) request.getAttribute("prodotto");
%>

<body>
<div class="bodyContainer">
    
    
   	<div style="height:100px; margin-top: 20px;">
   	
   	</div>
    <form action="ProductControl?action=change" method="post" enctype="multipart/form-data">
    <%
        if (prodotto != null) {
    %>
    <div class="cardModificaProdotto">
    <div style="display: flex; flex-direction: column; justify-content: flex-start; align-items: center;">
    <p style="color:black;font-weight: bolder; margin-top: 30px; font-size:18px;">Stai modificando il prdotto codice:<br><%=prodotto.getId()%></p><br> 
    	<div class="image-container">
                        <%
                            byte[] immagine = prodotto.getImmagine();
                            if (immagine != null && immagine.length > 0) {
                                String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                        %>
                        <!-- visualizzazione immagine con modifica quando si clicca sopra-->
                            <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= prodotto.getNome() %>" style="width: 200px; height: 200px; cursor: pointer;" onclick="handleImageClick()"">
                            <div class="overlay" onclick=""handeImageClick()">Modifica foto</div>
                        <% 
                            } else {    
                        %>
                        <!-- gestione nel caso l'immagine non gosse presente-->
                         <div class = overlay onclick = "handleImageClick()">Aggiungi foto</div>
                        <%
                            }   
                        %>
                        <input type="file" name="immagine" id="fileinput" style="position: absolute; top: 0; left: 0; width: 200px; height: 200px; opacity: 0; cursor: pointer;" accept="image/*"><br> 
    	</div>
    	<div>
    <div style="display:none;">
    	<label for="idprodotto">Nome:</label><br> 
    	<input type="text" name="idprodotto" value="<%=prodotto.getId()%>" readonly><br>
    </div>
    
    <label for="nome">Nome:</label><br> 
    <input name="nome" type="text" maxlength="50" required placeholder="Inserisci nome" value="<%=prodotto.getNome()%>"><br> 
    
    <label for="marca">Marca:</label><br> 
    <input name="marca" type="text" maxlength="50" required placeholder="Inserisci marca" value="<%=prodotto.getMarca()%>"><br> 
    
    <label for="modello">Modello:</label><br> 
    <input name="modello_auto" type="text" maxlength="50" required placeholder="Inserisci modello" value="<%=prodotto.getModelloAuto()%>"><br> 

    <label for="descrizione">Descrizione:</label><br>
    <textarea name="descrizione" maxlength="100" rows="3" required><%=prodotto.getDescrizione()%></textarea><br> 
    
    <label for="prezzo">Prezzo:</label><br>
    <input name="prezzo" type="text" pattern="^\d+(\.\d{1,2})?$" title="Inserisci un numero valido. Massimo due cifre decimali." required value="<%=prodotto.getPrezzo()%>"><br> 

    <label for="quantita">Quantita:</label><br> 
    <input name="quantita" type="number" min="0" value="<%=prodotto.getQuantita()%>" required><br> 
    	</div>


    
   		<div style="display: flex; align-items: flex-end; gap:5px">
    		<input type="submit" value="Modifica" id="bottoneModificaProd"><br>
    		<h3 style="color: white;"><a href="catalogo.jsp" style="text-decoration: none; color: #2074b0;"><i class="fa fa-arrow-circle-left" aria-hidden="true"></i></a></h3>
    	</div>
    </div>
    </div>

        <p style="text-align: center; color: white; font-weight: bold;"><i class="fa fa-check-circle" aria-hidden="true" style="margin-right: 0.3125rem;"></i>Modifica avvenuta con successo<i class="fa fa-check-circle" aria-hidden="true" style="margin-left: 0.3125rem;"></i></p>
    <%
        }
    %>

    </form>
    </div>
   
    <script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>
</body>