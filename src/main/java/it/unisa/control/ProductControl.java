package it.unisa.control;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import it.unisa.model.CartBean;
import it.unisa.model.ProductBean;
import it.unisa.model.ProductModelDS;
import com.google.gson.Gson;


@MultipartConfig
public class ProductControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ProductModelDS usa il DataSource
	static boolean isDataSource = true;

    private ProductModelDS model;

    public ProductControl() {
        super();
        model = new ProductModelDS();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (action != null) {
                switch (action.toLowerCase()) {
                    case "addproduct":
                        addProduct(request, response);
                        break;
                    case "readdetails":
                        readProductDetails(request, response);
                        break;
                    case "delete":
                        deleteProduct(request, response);
                        break;
                    case "deletecart":
                        deleteProductFromCart(request, response);
                        break;
                    case "insert":
                        insertProduct(request, response);
                        break;
                    case "change":
                        changeProduct(request, response);
                        break;
                    case "amministratore":
                        amministratore(request, response);
                        break;
                    case "searchsuggestions": 
                        searchSuggestions(request, response);
                        break;
                    case "products-customer":
                        productsCustomer(request, response);
                        break;
                    case "cercamarcamodello":
                        cercaMarcaModello(request, response);
                        break;
                    case "prodottirandom":
                        randomProduct(request, response);
                        break;
                    default:
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                }
            }
        } catch (SQLException e) {
            throw new ServletException("SQL Error", e);
        } 
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    //aggiungi prodotto al carrello 
    private void addProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        HttpSession session = request.getSession();
        int id = Integer.parseInt(request.getParameter("idprodotto"));
        CartBean cart = (CartBean) session.getAttribute("cart");
        if (cart == null) {
            cart = new CartBean();
            session.setAttribute("cart", cart);
        }
        ProductBean product = model.doRetrieveByKey(id);
        cart.addProduct(product);
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/carrello.jsp");
        dispatcher.forward(request, response);
    }

    //leggere i dettagli di un prodotto dal db 
    private void readProductDetails(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        int id = Integer.parseInt(request.getParameter("idprodotto"));
        request.setAttribute("prodotto", model.doRetrieveByKey(id));
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/dettaglio-prodotto.jsp");
        dispatcher.forward(request, response);
    }

    //elemina profotto dal db
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        int id = Integer.parseInt(request.getParameter("idprodotto"));
        model.doDelete(id);
        request.setAttribute("prodotti", model.doRetrieveAll("idprodotto"));
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp");
        dispatcher.forward(request, response);
    }

    //elimina il prodotto dal carrello 
    private void deleteProductFromCart(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        int productId = Integer.parseInt(request.getParameter("idprodotto"));
        if (productId != 0) {
            CartBean cart = (CartBean) request.getSession().getAttribute("cart");
            if (cart != null) {
                List<ProductBean> products = cart.getProducts();
                for (Iterator<ProductBean> iterator = products.iterator(); iterator.hasNext();) {
                    ProductBean prodotto = iterator.next();
                    if (productId == prodotto.getId()) {
                        iterator.remove();
                        break;
                    }
                }
            }
            request.getSession().setAttribute("cart", cart);
        }
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/carrello.jsp");
        dispatcher.forward(request, response);
    }

   
    //inserisce un nuovo prodotto nel db
    private void insertProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String nome = new BufferedReader(new InputStreamReader(request.getPart("nome").getInputStream(), StandardCharsets.UTF_8)).readLine();
        String descrizione = new BufferedReader(new InputStreamReader(request.getPart("descrizione").getInputStream(), StandardCharsets.UTF_8)).readLine();
        float prezzo = Float.parseFloat(new BufferedReader(new InputStreamReader(request.getPart("prezzo").getInputStream(), StandardCharsets.UTF_8)).readLine());
        int quantita = Integer.parseInt(new BufferedReader(new InputStreamReader(request.getPart("quantita").getInputStream(), StandardCharsets.UTF_8)).readLine());
        String marca = new BufferedReader(new InputStreamReader(request.getPart("marca").getInputStream(), StandardCharsets.UTF_8)).readLine();
        String modello_auto = new BufferedReader(new InputStreamReader(request.getPart("modello_auto").getInputStream(), StandardCharsets.UTF_8)).readLine();

        Part filePart = request.getPart("immagine");
        InputStream inputStream = filePart.getInputStream();
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[10240];
        int bytesRead;
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            output.write(buffer, 0, bytesRead);
        }
        byte[] image = output.toByteArray();

        ProductBean bean = new ProductBean();
        bean.setNome(nome);
        bean.setDescrizione(descrizione);
        bean.setPrezzo(prezzo);
        bean.setQuantita(quantita);
        bean.setMarca(marca);
        bean.setModelloAuto(modello_auto);
        bean.setImmagine(image);

        model.doSave(bean);
        request.setAttribute("prodotti", model.doRetrieveAll("idprodotto"));
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp");
        dispatcher.forward(request, response);
    }

    //modifica prodotto nel db
    private void changeProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String nome = new BufferedReader(new InputStreamReader(request.getPart("nome").getInputStream(), StandardCharsets.UTF_8)).readLine();
        String descrizione = new BufferedReader(new InputStreamReader(request.getPart("descrizione").getInputStream(), StandardCharsets.UTF_8)).readLine();
        float prezzo = Float.parseFloat(new BufferedReader(new InputStreamReader(request.getPart("prezzo").getInputStream(), StandardCharsets.UTF_8)).readLine());
        int quantita = Integer.parseInt(new BufferedReader(new InputStreamReader(request.getPart("quantita").getInputStream(), StandardCharsets.UTF_8)).readLine());
        String marca = new BufferedReader(new InputStreamReader(request.getPart("marca").getInputStream(), StandardCharsets.UTF_8)).readLine();
        String modello_auto = new BufferedReader(new InputStreamReader(request.getPart("modello_auto").getInputStream(), StandardCharsets.UTF_8)).readLine();
        int id = Integer.parseInt(new BufferedReader(new InputStreamReader(request.getPart("idprodotto").getInputStream(), StandardCharsets.UTF_8)).readLine());

        Part filePart = request.getPart("immagine");

        ProductBean bean = new ProductBean();
        bean.setNome(nome);
        bean.setDescrizione(descrizione);
        bean.setPrezzo(prezzo);
        bean.setQuantita(quantita);
        bean.setId(id);
        bean.setMarca(marca);
        bean.setModelloAuto(modello_auto);

        if (filePart != null && filePart.getSize() > 0) {
            InputStream inputStream = filePart.getInputStream();
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] buffer = new byte[10240];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
            byte[] image = output.toByteArray();
            inputStream.close();
            bean.setImmagine(image);
        } else {
            ProductBean oldBean = model.doRetrieveByKey(id);
            bean.setImmagine(oldBean.getImmagine());
        }

        model.doChange(bean);
        request.setAttribute("prodotto", model.doRetrieveByKey(id));
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/dettaglio-prodotto.jsp");
        dispatcher.forward(request, response);
    }

    //preleva tutti i prodotti per mostrarli lato amministratore
    private void amministratore(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String sortOption = request.getParameter("sortOption");
        if (sortOption == null || sortOption.isEmpty()) {
            sortOption = "idprodotto";
        }
        request.removeAttribute("prodotti");
        request.setAttribute("prodotti", model.doRetrieveAll(sortOption));
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp");
        dispatcher.forward(request, response);
    }

    //preleva tutti i prodotti per mostrarli lato customer
    private void productsCustomer(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String sortOption = request.getParameter("sortOption");
        if (sortOption == null || sortOption.isEmpty()) {
            sortOption = "idprodotto";
        }
        request.removeAttribute("prodotti");
        request.setAttribute("prodotti", model.doRetrieveAll(sortOption));
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo-customer.jsp");
        dispatcher.forward(request, response);
    }

    // Metodo per ottenere i suggerimenti di ricerca
    private void searchSuggestions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String query = request.getParameter("query");
        List<ProductBean> suggestions = model.getSuggestions(query); // Chiamata al model per ottenere i suggerimenti
    
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(suggestions));
    }

    private void cercaMarcaModello(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String marca = request.getParameter("marca");
        String modello = request.getParameter("modello");
        List<ProductBean> products = model.doRetrieveByMarcaModello(marca, modello);
        request.removeAttribute("prodotti");
        request.setAttribute("prodotti", products);
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo-customer.jsp");
        dispatcher.forward(request, response);
    }

    private void randomProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        List<ProductBean> randomProducts = model.doRetrieveRandom(3); // Recupera 3 prodotti casuali
        request.removeAttribute("randomProducts");
        request.setAttribute("randomProducts", randomProducts); 
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/home.jsp");            
        dispatcher.forward(request, response);
    }
}
