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

    setTimeout(showSlides, 3000); // Cambia immagine ogni 3 secondi
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