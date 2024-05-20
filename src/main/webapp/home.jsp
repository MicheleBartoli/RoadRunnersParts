<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<link rel="shortcut icon" type="icon" href="images/logo2.png">
	<title>Road Runner Parts</title>
</head>
<body>
<div class="bodyContainer">
	<%@ include file = "includes/header.jsp" %>
		
		<div class="slideshow-container">
        	<div class="mySlides">
            	<img src="images/slideshow/image1.jpg" style="width:100%">
        	</div>
        	<div class="mySlides">
            	<img src="images/slideshow/image2.jpg" style="width:100%">
        	</div>
        	<div class="mySlides">
            	<img src="images/slideshow/image3.jpg" style="width:100%">
        	</div>
    </div>
	<%@ include file="includes/footer.jsp" %>
</div>	
	 <script src="script.js"></script>
</body>
</html>