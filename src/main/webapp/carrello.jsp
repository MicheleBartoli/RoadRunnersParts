<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="it.unisa.model.ProductBean" %>
<%@ page import="it.unisa.model.ProductModelDS" %>
<%@ page import="it.unisa.model.CartBean, it.unisa.model.ProductBean, it.unisa.model.UserBean, it.unisa.model.MetodoPagamentoBean" %>
<%@ include file="includes/header.jsp" %>
<%@ page import="java.sql.SQLException" %>

<%!
    public String capitalizeWords(String str) {
        if (str == null || str.isEmpty()) {
            return str;
        }
        String[] words = str.split(" ");
        StringBuilder capitalizedWords = new StringBuilder();
        for (String word : words) {
            if (word.length() > 0) {
                capitalizedWords.append(Character.toUpperCase(word.charAt(0)))
                                .append(word.substring(1).toLowerCase())
                                .append(" ");
            }
        }
        return capitalizedWords.toString().trim();
    }

    public String toUpperCase(String str) {
        return (str == null) ? null : str.toUpperCase();
    }
    
    public String maskAccountId(String account_id) {
        if (account_id == null || account_id.isEmpty()) {
            return "";
        }
        
        if (account_id.contains("@")) { // Se l'account_id sembra essere un'email
            int atIndex = account_id.indexOf("@");
            if (atIndex > 0) {
                String domain = account_id.substring(atIndex);
                String masked = account_id.substring(0, 4) + "****" + domain;
                return masked;
            }
        } else { // Altrimenti, trattalo come un numero di carta di credito o altro
            return  "****" + account_id.substring(account_id.length() - 4);
        }
        
        return account_id; // Ritorna l'account_id originale se non rientra nei casi sopra
    }
%>

<!-- PAGINE DEL CARRELLO ACCESSIBILE SIA LATO ADMIN SIA LATO UTENTE REGISTRATO DALL'INTERFACCIA DEL SITO -->

<link rel="stylesheet" href="styles/cart.css">


<div class="bodyContainer" id="cart-container">
    <h1 style="margin-top:200px; text-align:center">Riepilogo Carrello</h1>
    <%
    	String userid = (String) session.getAttribute("userid");
        CartBean cart = (CartBean) session.getAttribute("cart");
    	UserBean user = (UserBean) session.getAttribute("user");
        
        if (cart != null && !cart.getProducts().isEmpty()) {
            Map<Integer, ProductBean> productMap = new HashMap<>();
            Map<Integer, Integer> quantityMap = new HashMap<>();
            
            // Aggrega i prodotti in base al loro ID
            for (ProductBean product : cart.getProducts()) {
                int productId = product.getId();
                if (productMap.containsKey(productId)) {
                    quantityMap.put(productId, quantityMap.get(productId) + 1);
                } else {
                    productMap.put(productId, product);
                    quantityMap.put(productId, 1);
                }
            }
    %>
    <div class="containerArticoliCarrello">
    	
    	
    	
    	<div class="tableArticoliCarrello">
    	<% 		
    			double totalPrice = 0.0;
                for (Map.Entry<Integer, ProductBean> entry : productMap.entrySet()) { 
                    ProductBean product = entry.getValue();
                    int quantity = quantityMap.get(product.getId());
                 	// Aggiungi il prezzo del prodotto moltiplicato per la quantità al totale
                    totalPrice += product.getPrezzo() * quantity;

            %>
        <table class="tableCarrello">
            
            
                <tr>
                    <td style="width:110px">
                        <% 
                            String imgSrc = "images/" + product.getNome().toLowerCase() + ".png"; 
                            byte[] immagine = product.getImmagine(); 
                            if (immagine != null && immagine.length > 0) {
                                String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                        %>
                                <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= product.getNome() %>" style="width: 100px; height: 100px;">
                        <% } else { %>
                                <img src="<%= imgSrc %>" alt="<%= product.getNome() %>">
                        <% } %>
                    </td>
                    <td style="text-align:left;"><%= product.getNome() %></td>
                    <td style="text-align:center;"><%= String.format("%.2f", product.getPrezzo()) %>€</td>
                    <td style="text-align:center; min-width: 30px;"><%= quantity %></td>
                    <td>
                        <form action="ProductControl" method="post">
                            <input type="hidden" name="action" value="deleteCart">
                            <input type="hidden" name="idprodotto" value="<%= product.getId() %>">
                            <button type="submit" class="delete-button"><i class="fa fa-trash" aria-hidden="true"></i></button>
                        </form>
                    </td>
                </tr>
            <% } %>
        </table>
        </div>
        
        
        
        <div class="cardPayment">
        	
		<div class="informazioni-utenti">
			<h1 style="font-weight: bolder; font-size:25px;color: red;text-align:center">Dati anagrafici per la fatturazione:</h1>
    		<%
    		MetodoPagamentoBean metodoPagamento = null;
    		ProductModelDS ps = new ProductModelDS();
    		try {
        		if (userid != null) {
            metodoPagamento = ps.doRetrievePayamentMethod(userid);
        		}
    		} catch (SQLException e) {
        	e.printStackTrace();
   			 }
    		%>
    		<p>Username:<br> <%= user != null ? user.getUserid() : "" %></p>
    		<p>Telefono:<br> <%= user != null ? user.getTelefono() : "" %></p>
    		<p>Indirizzo:<br> <%= user != null ? capitalizeWords(user.getIndirizzo()) + ", " + toUpperCase(user.getCitta()) + ", " + toUpperCase(user.getProvincia()) + " - " + user.getCap() : "" %></p>
    		<%
    		String accountcensurato = "";
    		if (metodoPagamento != null){
        		String account_id = metodoPagamento.getAccountId();
        		accountcensurato = maskAccountId(account_id);
    		}
    		%>
    		<p> Metodo di pagamento: <br><%= metodoPagamento != null ? metodoPagamento.getTipoPagamento() + " - " + accountcensurato : "Non disponibile" %> </p>

    		<a href="utente.jsp" class="user-button">Modifica Indirizzo o Metodo di Pagamento</a> 
		</div>
		
		
			<div class="totaleCarrello">
			<% // Formatta il totale come stringa con due decimali
	        String formattedTotalPrice = String.format("€ %.2f", totalPrice);
			%>
			<p style="color:red; font-weight: bolder;">TOTALE DA PAGARE: <br><%out.print(formattedTotalPrice);%>€</p>
			
			
			</div>
		
		
		
		
		
        	
        	<!-- TASTO PAGAH -->
        	<% 
            boolean canPurchase = user != null && user.getIndirizzo() != null && user.getCitta() != null && user.getProvincia() != null && user.getCap() != null && user.getTelefono() != null;
            if (userid != null && canPurchase) { %>
                <form action="OrdineControl" method="post">
                    <input type="hidden" name="action" value="saveorder">
                    <button type="submit" class="buyButton">Finalizza l'acquisto</button>
                </form>
            <% } else { %>
                <p style="text-align: center; margin: 25px; color:red; font-weight: bolder;">Per completare l'acquisto, aggiungi il tuo indirizzo metodo di pagamento nel tuo profilo</p>
            <% } %>
    		<% }else { %>
        		<p style="text-align: center;">Il carrello è vuoto.</p>
    		<% } %>
        </div>
       </div>
</div>

<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>