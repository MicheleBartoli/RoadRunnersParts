/**
 * 
 */
let slideIndex = 0;
let slides = document.getElementsByClassName("mySlides");

function showSlides() {
    let i;
    for (i = 0; i < slides.length; i++) {
        slides[i].classList.remove("show", "next", "prev");
    }
    slideIndex++;
    if (slideIndex > slides.length) {slideIndex = 1}
    
    let currentSlide = slides[slideIndex - 1];
    currentSlide.classList.add("show");

    if (slideIndex > 1) {
        let prevSlide = slides[slideIndex - 2];
        prevSlide.classList.add("prev");
    } else {
        let lastSlide = slides[slides.length - 1];
        lastSlide.classList.add("prev");
    }

    if (slideIndex < slides.length) {
        let nextSlide = slides[slideIndex];
        nextSlide.classList.add("next");
    } else {
        let firstSlide = slides[0];
        firstSlide.classList.add("next");
    }

    setTimeout(showSlides, 6000); // Cambia immagine ogni 3 secondi
}

showSlides();

function myFunction() {
  var x = document.getElementById("myTopnav");
  if (x.className === "topnav") {
    x.className += " responsive";
  } else {
    x.className = "topnav";
  }
}



document.addEventListener('DOMContentLoaded', function () {
    // Aggiungi un event listener per il campo di ricerca
    document.getElementById('search').addEventListener('input', function () {
        let query = this.value;
        
        if (query.length >= 3) { // Inizia la ricerca solo se ci sono almeno 3 caratteri
            // Esegui una richiesta Ajax
            let xhr = new XMLHttpRequest();
            xhr.open('GET', `search.jsp?query=${encodeURIComponent(query)}`, true);
            xhr.onload = function () {
                if (xhr.status === 200) {
                    // Aggiorna la pagina con i risultati della ricerca
                    document.getElementById('search-results').innerHTML = xhr.responseText;
                }
            };
            xhr.send();
        } else {
            // Cancella i risultati della ricerca se la query è troppo corta
            document.getElementById('search-results').innerHTML = '';
        }
    });
});


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
	                    var suggestionLink = $("<a id='suggestion'></a>");
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

		
		
		document.getElementById("payment-form").addEventListener("submit", function(event) {
		           if (!validateForm()) {
		               event.preventDefault(); //se la validazione fallisce il form non viene submit
		           }
		       });
		       
		       function validateForm() { //validazione della correttezza dei dati 
		           var tipoPagamento = document.getElementById("tipo_pagamento").value;
		           var valid = true;
		       
		           if (tipoPagamento === "Carta di Credito") {
		               var ccNumber = document.getElementById("cc_account_id").value;
		               var dataScadenza = document.getElementById("data_scadenza").value;
		               var cvv = document.getElementById("cvv").value;
		               
		               // Validazione del numero della carta di credito
		               if (!/^\d{16}$/.test(ccNumber)) {
		                   alert("Inserisci un nuemero di carta di credito valido (16 cifre).");
		                   valid = false;
		               }
		       
		               // Validazione della data di scadenza
		               var today = new Date();
		               var expirationDate = new Date(dataScadenza);
		               if (expirationDate <= today) {
		                   alert("Inserisci una data di scadenza valida.");
		                   valid = false;
		               }
		       
		               // Validazione del CVV
		               if (!/^\d{3}$/.test(cvv)) {
		                   alert("Inserisci un CVV valido (3 cifre).");
		                   valid = false;
		               }
		           }
		       
		           return valid;
		       }
		       
		       function togglePaymentFields() {
		           var tipoPagamento = document.getElementById("tipo_pagamento").value;
		           var paypalFields = document.getElementById("paypal_fields");
		           var creditCardFields = document.getElementById("credit_card_fields");
		       
		           if (tipoPagamento === "PayPal") {
		               paypalFields.style.display = "block";
		               creditCardFields.style.display = "none";
		               
		               document.getElementById("paypal_account_id").disabled = false;
		               document.getElementById("cc_account_id").disabled = true;
		               document.getElementById("data_scadenza").disabled = true;
		               document.getElementById("cvv").disabled = true;
		           } else if (tipoPagamento === "Carta di Credito") {
		               paypalFields.style.display = "none";
		               creditCardFields.style.display = "block";
		               
		               document.getElementById("paypal_account_id").disabled = true;
		               document.getElementById("cc_account_id").disabled = false;
		               document.getElementById("data_scadenza").disabled = false;
		               document.getElementById("cvv").disabled = false;
		           } else {
		               paypalFields.style.display = "none";
		               creditCardFields.style.display = "none";
		               
		               document.getElementById("paypal_account_id").disabled = true;
		               document.getElementById("cc_account_id").disabled = true;
		               document.getElementById("data_scadenza").disabled = true;
		               document.getElementById("cvv").disabled = true;
		           }
		       }
		       
		       togglePaymentFields(); //chiamata utile a inizializzare il form all'apertura della pagina
	
			   
			   
			   
function reAdressForm() {
		document.getElementById('form-container').style.display = 'block';
		document.getElementById('reAdressButton').style.display = 'none';
}
function updateAdressForm() {
		document.getElementById('form-container').style.display = 'none';
		document.getElementById('reAdressButton').style.display = 'block';
}


///sortForm
function showInsertProduct(){
		document.getElementById('cardProdotto').style.display = 'block';
		document.getElementById('hideButton').style.display = 'block';
		document.getElementById('insertButton').style.display = 'none';
		document.getElementById('containerTabella').style.display = 'none';
		document.getElementById('sortForm').style.display = 'none';
}
function hideInsertProduct(){
		document.getElementById('cardProdotto').style.display = 'none';
		document.getElementById('hideButton').style.display = 'none';
		document.getElementById('insertButton').style.display = 'block';
		document.getElementById('containerTabella').style.display = 'block';
		document.getElementById('sortForm').style.display = 'block';
}
 /// Script per gestire il click sull'immagine per modificarla (quando si intende modificare il prodotto)
function handleImageClick() {
        document.getElementById('fileinput').click();
    }
