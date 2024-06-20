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
<style>
    /* Stili per schermi con larghezza minore di 600px */
    @media (max-width: 990px) {
        .desktop-header {
            display: none !important;
        }
        
        .table-container table {
            width: 100%;  /* Aumenta la larghezza al 100% */
            min-width: 25rem;
        }

        .table-container table,
        .table-container thead,
        .table-container tbody,
        .table-container th,
        .table-container td,
        .table-container tr {
            display: block;
        }

        .table-container tr {
            border: 1px solid #ccc;
        }

        .table-container td {
            border: none;
            border-bottom: 1px solid #eee;
            position: relative;
            padding-left: 50%;
            text-align: right;
        }

        .table-container td:before {
            position: absolute;
            top: 6px;
            left: 6px;
            width: 45%;
            padding-right: 10px;
            white-space: nowrap;
            content: attr(data-column);
            text-align: left;
            font-weight: bold;
        }

        
    }

    /* Stili per schermi con larghezza maggiore o uguale a 991px */
    @media (min-width: 991px) {
        .desktop-header {
            display: table-row !important;
        }
        
        /* Aggiungi qui altri stili specifici per schermi più larghi se necessario */
    }

    /* Stili per l'effetto hover sull'immagine */
    .image-container {
            position: relative;
            display: inline-block;
        }

    .image-container:hover .overlay {
            opacity: 1;
    }

    .overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100px;
        height: 100px;
        background-color: rgba(0, 0, 0, 0.5);
        opacity: 0;
        transition: opacity 0.3s ease;
        display: flex;
        justify-content: center;
        align-items: center;
        color: white;
        font-size: 14px;
        cursor: pointer;
    }

    .image-container.hovered .overlay {
        opacity: 1;
    }
</style>

<!-- Script per gestire il click sull'immagine per modificarla -->
<script>
    function handleImageClick() {
        document.getElementById('fileinput').click();
    }
</script>


    <h3 style="color: white;"><a href="catalogo.jsp" style="text-decoration: none; color: white;"><i class="fa fa-arrow-circle-left" aria-hidden="true"></i></a></h3>
    <div style="display: flex; justify-content: center; align-items: center; flex-direction: column;">
    <h2 style="color: white;">Dettagli</h2>
    <form action="ProductControl?action=change" method="post" enctype="multipart/form-data">
    <%
        if (prodotto != null) {
    %>
    <div class="table-container">
        <table border="1" style="background-color: rgb(41, 139, 230); width: 100%;">
            <tr class="desktop-header">
                <th>Immagine Prodotto</th>
                <th>ID</th>
                <th>Nome</th>
                <th>Descrizione</th>
                <th>Prezzo</th>
                <th>Quantità</th>
                <th>Marca</th>
                <th>Modello</th>
            </tr>
            <tr>
                <td data-column="Immagine">
                    <div class="image-container">
                        <%
                            byte[] immagine = prodotto.getImmagine();
                            if (immagine != null && immagine.length > 0) {
                                String base64image = java.util.Base64.getEncoder().encodeToString(immagine);
                        %>
                        <!-- visualizzazione immagine con modifica quando si clicca sopra-->
                            <img src="data:image/jpeg;base64,<%= base64image %>" alt="<%= prodotto.getNome() %>" style="width: 100px; height: 100px; cursor: pointer;" onclick="handleImageClick()"">
                            <div class="overlay" onclick=""handeImageClick()">Modifica foto</div>
                        <% 
                            } else {    
                        %>
                        <!-- gestione nel caso l'immagine non gosse presente-->
                         <div class = overlay onclick = "handleImageClick()">Aggiungi foto</div>
                        <%
                            }   
                        %>
                        <input type="file" name="immagine" id="fileinput" style="position: absolute; top: 0; left: 0; width: 100px; height: 100px; opacity: 0; cursor: pointer;" accept="image/*">
                    </div>

                </td>
                <td data-column="Idprodotto"><input type="text" name="idprodotto" value="<%=prodotto.getId()%>" readonly></td>
                <td data-column="Nome"><input name="nome" type="text" maxlength="50" required placeholder="Inserisci nome" value="<%=prodotto.getNome()%>"></td>
                <td data-column="Descrizione"><textarea name="descrizione" maxlength="100" rows="3" required><%=prodotto.getDescrizione()%></textarea></td>
                <td data-column="Prezzo"><input name="prezzo" type="text" pattern="^\d+(\.\d{1,2})?$" title="Inserisci un numero valido. Massimo due cifre decimali." required value="<%=prodotto.getPrezzo()%>"></td>
                <td data-column="Quantita"><input name="quantita" type="number" min="1" value="<%=prodotto.getQuantita()%>" required></td>
                <td data-column="Marca"><input name="marca" type="text" maxlength="20" required placeholder="Inserisci marca" value="<%=prodotto.getMarca()%>"></td>
                <td data-column="Modello"><input name="modello_auto" type="text" maxlength="20" required placeholder="Inserisci modello" value="<%=prodotto.getModelloAuto()%>"></td>
                
            </tr>
        </table>
    </div>
    <input type="submit" value="Modifica" style="width: 100%; height: 3.125rem;
    text-shadow: -1px 0 black, 0 1px black, 1px 0 black, 0 -1px black;
    font-size: 2rem;
    margin-top: 0.125rem;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    background-color: #0436b3;"><br>
    <%
        if("true".equals(request.getAttribute("verificatarocca"))){
    %>
        <p style="text-align: center; color: white; font-weight: bold;"><i class="fa fa-check-circle" aria-hidden="true" style="margin-right: 0.3125rem;"></i>Modifica avvenuta con successo<i class="fa fa-check-circle" aria-hidden="true" style="margin-left: 0.3125rem;"></i></p>
    <%
    }
    %>
    <%
        }
    %>
    </form>
    </div>

    <a href="catalogo.jsp" style="text-decoration: none; color: black;">
        <button type="button">Torna al Catalogo</button>
    </a>
    
<%@ include file="includes/footer.jsp" %>