<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<link rel="shortcut icon" type="icon" href="images/logo2.png">
	<title>Login</title>
</head>

<body>
<div class="bodyContainer">
	<%@ include file = "includes/header.jsp" %>
		<div class="content_page">
			<div class="login-container">
        	<h2>Login</h2>
        	<form>
            	<div class="form-group">
                	<label for="username">Username</label>
                	<input type="text" id="username" name="username" required>
            	</div>
            	<div class="form-group">
                	<label for="password">Password</label>
                	<input type="password" id="password" name="password" required>
            	</div>
            	<div class="form-group">
                	<input type="checkbox" id="remember" name="remember">
                	<label for="remember">Rimani collegato</label>
            	</div>
            	<button type="submit" class="loginButton">Accedi</button>
       		 </form>
        	<div class="register-link">
            	<p>Non hai un account? <a href="#">Registrati qui</a></p>
        	</div>
    		</div>
    	</div>
</div>
	
	
	
	
	<%@ include file="includes/footer.jsp" %>
	
	
</body>
</html>