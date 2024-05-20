<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<style>
/* Stili di base per la navbar e l'icona hamburger */
.navbar {
    display: flex;
    align-items: center;
    padding: 10px 20px;
    background-color: #333;
    color: white;
}

.hamburger {
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    width: 30px;
    height: 25px;
    cursor: pointer;
}

.line {
    width: 100%;
    height: 3px;
    background-color: white;
    transition: all 0.3s ease;
}

/* Stili per il menu */
.menu {
    display: none;
    flex-direction: column;
    position: absolute;
    top: 50px;
    right: 20px;
    background-color: #333;
    width: 200px;
    border-radius: 8px;
}

.menu a {
    color: white;
    padding: 10px;
    text-decoration: none;
    border-bottom: 1px solid #444;
}

.menu a:last-child {
    border-bottom: none;
}

/* Cambia dimensioni e rotazione delle linee quando l'hamburger è attivo */
.hamburger.active .line:nth-child(1) {
    transform: rotate(45deg) translate(5px, 5px);
    width: 35px;
}

.hamburger.active .line:nth-child(2) {
    opacity: 0;
}

.hamburger.active .line:nth-child(3) {
    transform: rotate(-45deg) translate(5px, -5px);
    width: 35px;
}

/* Mostra il menu quando l'hamburger è attivo */
.menu.active {
    display: flex;
</style>
</head>
<body>

<nav class="navbar">
    <div class="hamburger" id="hamburger">
        <div class="line"></div>
        <div class="line"></div>
        <div class="line"></div>
    </div>
    <div class="menu" id="menu">
        <!-- Aggiungi qui i link del tuo menu -->
    </div>
</nav>
<script>
document.addEventListener("DOMContentLoaded", function() {
    const hamburger = document.getElementById("hamburger");
    const menu = document.getElementById("menu");

    hamburger.addEventListener("click", function() {
        hamburger.classList.toggle("active");
        menu.classList.toggle("active");
    });
});
</script>

</body>
</html>
