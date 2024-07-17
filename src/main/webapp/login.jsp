<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="it.unisa.model.OrderBean" %>
<%@ page import="it.unisa.model.UserBean" %>
<%@ include file="includes/header.jsp" %>


<!-- PAGINA DI LOGIN E REGISTRAZIONI con form e controllo tramite JavaScript -->

<% 
    String userid = (String) session.getAttribute("userid");
    if (userid == null) {
%> 
<div class="bodyContainerLogin">
<div class="login-container" id="login-container">
    <h2>Login</h2>
    <form action="UserControl?action=loginutente" method="post">
        <input type="hidden" name="action" value="login">
        <label for="loginUserid">E-mail:</label><br>
        <input type="text" id="loginUserid" name="userid" required><br>
        <label for="loginPassword">Password:</label><br>
        <input type="password" id="loginPassword" name="password" required>
        <button type="button" onmousedown="showPassword('loginPassword')" onmouseup="hidePassword('loginPassword')"><i class="fa fa-eye" aria-hidden="true"></i></button><br>
        <div style="margin-top:20px">
        	<input type="submit" class="button" value="Login">
        </div>
    </form>
    <h3>Non hai un account?</h3>
    <button onclick="showRegisterForm()" class="button" >Registrati</button>
</div>

<div class="login-container" id="registerForm" style="display: none;">
    <h2>Registrazione</h2>
    <form action="UserControl?action=registrautente" method="post" onsubmit="return validateForm()">
        <input type="hidden" name="action" value="register">
        <label for="registerUserid">E-mail:</label><br>
        <input type="text" id="registerUserid" name="userid" pattern="[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$" required><br>
        <label for="registerPassword">Password:</label><br>
        <input type="password" id="registerPassword" name="password" required>
        <button type="button" onmousedown="showPassword('registerPassword')" onmouseup="hidePassword('registerPassword')"><i class="fa fa-eye" aria-hidden="true"></i></button><br>
        <label for="confirmPassword">Conferma Password:</label><br>
        <input type="password" id="confirmPassword" name="confirmPassword" required>
        <button type="button" onmousedown="showPassword('confirmPassword')" onmouseup="hidePassword('confirmPassword')"><i class="fa fa-eye" aria-hidden="true"></i></button><br>
        
            <div>
                <div style="flex: 1;"><strong>Indirizzo</strong></div>
                <div style="flex: 1;"><input type="text" name="indirizzo" required></div>
            </div>
            <div>
                <div style="flex: 1;"><strong>Città</strong></div>
                <div style="flex: 1;"><input type="text" name="citta" required></div>
            </div>
            <div>
                <div style="flex: 1;"><strong>Provincia</strong></div>
                <div style="flex: 1;"><input type="text" name="provincia" required></div>
            </div>
            <div>
                <div style="flex: 1;"><strong>CAP</strong></div>
                <div style="flex: 1;"><input type="text" name="cap" maxlength="10" required"></div>
            </div>
            <div>
                <div style="flex: 1;"><strong>Telefono</strong></div>
                <div style="flex: 1;"><input type="text" name="telefono" maxlength="10" required></div>
            </div>
        <div style="margin-top:20px">
        <input type="submit" value="Registra" class="button">
        </div>
    </form>
    <h3>Hai già un account?</h3>
    <button onclick="showLoginForm()" class="button">Accedi</button>
</div>

</div>
<script src="script.js"></script>
<%@ include file="includes/footer.jsp" %>



<%}
else {
    // Se l'utente è già loggato, reindirizza alla pagina utente
    response.sendRedirect("utente.jsp");
}
%>

<%
String utenteInesistente = (String) request.getAttribute("utenteinesistente");
if (utenteInesistente != null && utenteInesistente.equals("true")) {
%>
<script>window.onload = function() {alert("ERRORE: utente inesistente");}</script>
<%
}
%>

<%
String passworderrata = (String) request.getAttribute("passworderrata");
if (passworderrata != null && passworderrata.equals("true")) {
%>
<script>window.onload = function() {alert("ERRORE: password errata");}</script>
<%
}
%>

<%
String registrato = (String) request.getAttribute("registrato");
if (registrato != null && registrato.equals("true")) {
%>
<script>
    window.onload = function() {
        showRegisterForm();
        setTimeout(function() {
            alert("ERRORE: utente già registrato");
        }, 100);
    }
</script>
<%}
%>

