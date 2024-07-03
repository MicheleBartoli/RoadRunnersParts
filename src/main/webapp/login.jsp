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

<div id="login-container">
    <h2>Login</h2>
    <form action="UserControl?action=loginutente" method="post">
        <input type="hidden" name="action" value="login">
        <label for="loginUserid">E-mail:</label><br>
        <input type="text" id="loginUserid" name="userid" required><br>
        <label for="loginPassword">Password:</label><br>
        <input type="password" id="loginPassword" name="password" required>
        <button type="button" onmousedown="showPassword('loginPassword')" onmouseup="hidePassword('loginPassword')"><i class="fa fa-eye" aria-hidden="true"></i></button><br>
        <input type="submit" value="Login">
    </form>
    <h3>Non hai un account?</h3>
    <button onclick="showRegisterForm()">Registrati</button>
</div>

<div id="registerForm" style="display: none;">
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
        <div class="responsive-table" style="background-color: #f2f2f2; color: black; padding: 10px; display: flex; flex-direction: column;">
            <div style="display: flex; flex-direction: row; align-items: center;">
                <div style="flex: 1;"><strong>Indirizzo</strong></div>
                <div style="flex: 1;"><input type="text" name="indirizzo" required style="min-width: 8rem; width: 100%; box-sizing: border-box;"></div>
            </div>
            <div style="display: flex; flex-direction: row; align-items: center;">
                <div style="flex: 1;"><strong>Città</strong></div>
                <div style="flex: 1;"><input type="text" name="citta" required style="min-width: 8rem; width: 100%; box-sizing: border-box;"></div>
            </div>
            <div style="display: flex; flex-direction: row; align-items: center;">
                <div style="flex: 1;"><strong>Provincia</strong></div>
                <div style="flex: 1;"><input type="text" name="provincia" required style="min-width: 8rem; width: 100%; box-sizing: border-box;"></div>
            </div>
            <div style="display: flex; flex-direction: row; align-items: center;">
                <div style="flex: 1;"><strong>CAP</strong></div>
                <div style="flex: 1;"><input type="text" name="cap" maxlength="10" required style="min-width: 4rem; width: 100%; box-sizing: border-box;"></div>
            </div>
            <div style="display: flex; flex-direction: row; align-items: center;">
                <div style="flex: 1;"><strong>Telefono</strong></div>
                <div style="flex: 1;"><input type="text" name="telefono" maxlength="10" required style="min-width: 4rem; width: 100%; box-sizing: border-box;"></div>
            </div>
        </div>
        <input type="submit" value="Registra">
    </form>
    <h3>Hai già un account?</h3>
    <button onclick="showLoginForm()">Accedi</button>
</div>

<script>
    function validateForm() {
        var email = document.getElementById('registerUserid').value;
        var password = document.getElementById('registerPassword').value;
        var confirmPassword = document.getElementById('confirmPassword').value;

        var emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if (!emailPattern.test(email)) {
            alert('Per favore inserisci un indirizzo email valido.');
            return false;
        }

        if (password != confirmPassword) {
            alert('Le password non coincidono.');
            return false;
        }

        return true;
    }

    function showPassword(inputId) {
        document.getElementById(inputId).type = 'text';
    }

    function hidePassword(inputId) {
        document.getElementById(inputId).type = 'password';
    }

    function showRegisterForm() {
        document.getElementById('login-container').style.display = 'none';
        document.getElementById('registerForm').style.display = 'block';
    }

    function showLoginForm() {
        document.getElementById('registerForm').style.display = 'none';
        document.getElementById('login-container').style.display = 'block';
    }
</script>

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

<%@ include file="includes/footer.jsp" %>