<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>RoadRunnerParts</title>
    <style>
        /* Stili CSS per il pulsante */
        .add-to-cart-btn {
            background-color: #4CAF50; /* Colore di sfondo verde */
            color: white;
            padding: 12px 20px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin-top: 10px;
            border-radius: 4px;
            cursor: pointer;
            border: none;
        }
        .add-to-cart-btn:hover {
            background-color: #45a049; /* Cambia il colore al passaggio del mouse */
        }
        /* Stili per la barra di ricerca */
        .search-container {
            position: relative;
            margin: 20px;
        }

        .search-input {
            width: 100%;
            padding: 12px;
            box-sizing: border-box;
        }

        .suggestions {
            display: block;
            padding: 10px;
            cursor: pointer;
            border-bottom: 1px solid #ddd;
            position: absolute;
            background-color: white;
            border: 1px solid #ddd;
            max-height: 200px;
            overflow-y: auto;
            width: 100%;
            box-sizing: border-box;
            display: none; /* Nascosto di default */
        }

        .suggestion {
            padding: 10px;
            cursor: pointer;
        }

        .suggestion:hover {
            background-color: #f0f0f0;
        }
    </style>
</head>
<body>
    <div class="bodyContainer">
        <%@ include file="includes/header.jsp" %>

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

            <!-- Barra di ricerca -->
            <div class="search-container">
                <input type="text" id="search" class="search-input" placeholder="Cerca...">
                <div id="suggestions" class="suggestions"></div>
            </div>
        </div>

        <%@ include file="includes/footer.jsp" %>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="script.js"></script>
    <script>
        // Gestione delle richieste di ricerca
        $(document).ready(function() {
            $("#search").on("input", function() {
                var query = $(this).val();
                if (query.length >= 2) {
                    $.ajax({
                        type: "GET",
                        url: "ProductControl?action=searchsuggestions&query=" + encodeURIComponent(query),
                        dataType: "json",
                        success: function(data) {
                            showSuggestions(data);
                        },
                        error: function(jqXHR, textStatus, errorThrown) {
                            console.error("Error retrieving suggestions:", textStatus, errorThrown);
                        }
                    });
                } else {
                    $("#suggestions").html("");
                    $("#suggestions").hide(); // Nasconde il contenitore dei suggerimenti quando la query è troppo corta
                }
            });

            function showSuggestions(suggestions) {
                var suggestionsContainer = $("#suggestions");
                suggestionsContainer.html(""); // Pulisce il contenuto precedente
                suggestionsContainer.show(); // Mostra il contenitore dei suggerimenti

                suggestions.forEach(function(suggestion) {
                    var suggestionLink = $("<a class='suggestion'></a>");
                    suggestionLink.text(suggestion.nome); // Mostra il nome del prodotto come testo del link
                    suggestionLink.attr("href", "pagina-prodotto.jsp?id=" + suggestion.idprodotto); // Aggiunge l'ID del prodotto come parametro

                    suggestionLink.on("click", function() {
                        $("#search").val(suggestion.nome); // Imposta il valore della barra di ricerca con il nome del prodotto
                        suggestionsContainer.html(""); // Pulisce i suggerimenti
                        suggestionsContainer.hide(); // Nasconde il contenitore dei suggerimenti dopo il clic
        });
        suggestionsContainer.append(suggestionLink); // Aggiunge il link al container dei suggerimenti
    });
    }
    });
    </script>

    
</body>
</html>