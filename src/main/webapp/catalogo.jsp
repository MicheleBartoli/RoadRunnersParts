<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ include file="header.jsp" %>
<%@ page import="it.unisa.model.ProductBean" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String userid = (String) session.getAttribute("userid");
    if (userid == null) {
		response.sendRedirect("utente.jsp");
	}
	else{
		String tipo = (String) session.getAttribute("tipo");
		if(tipo != null && tipo.equals("Customer")){
			response.sendRedirect("utente.jsp");
		}
		else if(tipo != null && tipo.equals("Admin")){
%>

<%
	ProductBean prodotto = (ProductBean) request.getAttribute("prodotto");
	List<?> prodotti = (List<?>) request.getAttribute("prodotti");
	if(prodotti == null){
		RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ProductControl?action=amministratore");
    	dispatcher.forward(request, response);
		return;
	}
%>

	<div style="display: flex; justify-content: center; margin-right: 50%;">
	<h2 style="color: white; font-weight: bold; margin-bottom: 0.3125rem; margin-top: 0.3125rem;">Prodotti</h2>
	</div>
	<a href="ProductControl?action=amministratore" style="color: white; font-weight: bolder; text-decoration: none;">Lista(clicca per aggiornare)</a>
	<table border="1" style="background-color: #90EE90;">
		<tr>
			<th>ID</th>
			<th>Tipo</th>
			<th>Nome</th>
			<th>Descrizione</th>
            <th>Prezzo</th>
            <th>Quantita</th>
            <th>Marca</th>
            <th>Modello</th>
		</tr>
		<%
			if (prodotti != null && prodotti.size() != 0) {
				Iterator<?> it = prodotti.iterator();
				while (it.hasNext()) {
					ProductBean bean = (ProductBean) it.next();
		%>
		<tr>
			<td><%=bean.getId()%></td>
			<td><%=bean.getNome()%></td>
			<td><%=bean.getDescrizione()%></td>
            <td><%=bean.getPrezzo()%></td>
            <td><%=bean.getQuantita()%></td>
			<td><a href="ProductControl?action=delete&id=<%=bean.getId()%>"><i class="fa fa-times-circle" aria-hidden="true"></i></a>
				<a href="ProductControl?action=readdetails&id=<%=bean.getId()%>" style="margin-left: 0.625rem;"><i class="fa fa-info-circle" aria-hidden="true"></i></a></td>
		</tr>
		<%
				}
			} else {
		%>
		<tr>
			<td colspan="6">No products available</td>
		</tr>
		<%
			}
		%>
	</table>
	<div style="display: flex; justify-content: center; margin-right: 88%;">
	<h2 style="color: white;">Inserisci</h2>
	</div>
	<form action="ProductControl?action=insert" method="post" class="form-container3">
		<input type="hidden" name="action" value="insert"> 
		
		<label for="nome">Nome:</label><br> 
		<input name="nome" type="text" maxlength="20" required placeholder="Inserisci nome"><br>
		
		<label for="marca">Marca:</label><br> 
		<input name="marca" type="text" maxlength="20" required placeholder="Inserisci marca"><br>
		
		<label for="modello">Modelo:</label><br> 
		<input name="modello" type="text" maxlength="20" required placeholder="Inserisci modello"><br>

  
		<label for="descrizione">Descrizione:</label><br>
		<textarea name="descrizione" maxlength="100" rows="3" required placeholder="Inserisci descrizione"></textarea><br>
		
		<label for="prezzo">Prezzo:</label><br> 
        <input name="prezzo" type="text" pattern="^\d+(\.\d{1,2})?$" title="Inserisci un numero valido. Massimo due cifre decimali." required><br>

		<label for="quantita">Quantita:</label><br> 
		<input name="quantita" type="number" min="1" value="1" required><br>
		

		<input type="submit" value="Add"><input type="reset" value="Reset">

	</form>
	<form action="ProductControl?action=logoututente" method="post"  style="margin-bottom: 8.125rem; margin-top: 1.25rem;">
        <input type="hidden" name="action" value="logout">
        <input type="submit" value="Logout">
    </form>
	<%
		}
	}
	%>
<%@ include file="footer.jsp" %>