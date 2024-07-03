package it.unisa.control;

import java.io.IOException;
import java.sql.SQLException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;
import java.math.BigInteger;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import it.unisa.model.UserBean;
import it.unisa.model.ProductModelDS;

public class UserControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ProductModelDS model;
    
	// ProductModelDS usa il DataSource
	static boolean isDataSource = true;

    public UserControl() {
        super();
        model = new ProductModelDS();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (action != null) {
                switch (action.toLowerCase()) {
                    case "registrautente":
                        registraUtente(request, response);
                        break;
                    case "loginutente":
                        loginUtente(request, response);
                        break;
                    case "logoututente":
                        logoutUtente(request, response);
                        break;
                    case "changeuserlocation":
                        changeUserLocation(request, response);
                        break;
                    case "users":
                        listUsers(request, response);
                        break;
                    case "searchuser":
                        searchUser(request, response);
                        break;
                    default:
                        listUsers(request, response);
                        break;
                }
            } else {
                listUsers(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    //metodo che registra l'utente
    private void registraUtente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String userid = request.getParameter("userid");
    String password = request.getParameter("password");
    String indirizzo = request.getParameter("indirizzo");
    String citta = request.getParameter("citta");
    String provincia = request.getParameter("provincia");
    String cap = request.getParameter("cap");
    String telefono = request.getParameter("telefono");

    try {
        UserBean existingUser = model.doRetrieveByKeyUser(userid);
        if (existingUser != null) {
            request.setAttribute("registrato", "true");
        } else {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
            String hashedPassword = String.format("%064x", new BigInteger(1, hash));
            UserBean user = new UserBean(userid, hashedPassword, "Customer", indirizzo, citta, provincia, cap, telefono);
            model.doSaveUser(user);

            // Imposta gli attributi nella sessione dopo la registrazione
            HttpSession session = request.getSession();
            session.setAttribute("userid", userid);
            session.setAttribute("tipo", user.getTipo());
            session.setAttribute("user", user);

            request.setAttribute("registrato", "false");
            request.setAttribute("registrazione", "successo");

            // Reindirizza alla pagina utente.jsp dopo la registrazione
            response.sendRedirect("utente.jsp");
            return; 
        }
    } catch (NoSuchAlgorithmException | SQLException e) {
        e.printStackTrace(); 
        request.setAttribute("errorMessage", "Errore durante la registrazione dell'utente.");
    }

    // Se non si è reindirizzati, forward alla pagina di login per mostrare eventuali messaggi di errore o conferma
    RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/login.jsp");
    dispatcher.forward(request, response);
}

    //metodo che permette il login dell'utente
    private void loginUtente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userid = request.getParameter("userid");
        String password = request.getParameter("password");

        try {
            UserBean existingUser = model.doRetrieveByKeyUser(userid);

            if (existingUser == null) {
                request.setAttribute("utenteinesistente", "true");
            } else {
                MessageDigest md = MessageDigest.getInstance("SHA-256");
                byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
                String hashedPassword = String.format("%064x", new BigInteger(1, hash));
                UserBean user = model.doCheckUser(userid, hashedPassword);

                if (user == null) {
                    request.setAttribute("passworderrata", "true");
                } else {
                    request.getSession().setAttribute("userid", userid);
                    request.getSession().setAttribute("tipo", user.getTipo());
                    request.getSession().setAttribute("user", user);
                    response.sendRedirect("utente.jsp");
                    return; // Importante: uscire dal metodo dopo il reindirizzamento
                }
            }
        } catch (NoSuchAlgorithmException | SQLException e) {
            e.printStackTrace(); // o gestione specifica dell'errore
            request.setAttribute("errorMessage", "Errore durante il login dell'utente.");
        }

        // Se si arriva qui, significa che c'è stato un errore o che l'utente non è stato trovato
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/login.jsp");
        dispatcher.forward(request, response);
    }

    //metodo che permette il logout dell'utente
    private void logoutUtente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getSession().invalidate();
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/login.jsp");
        dispatcher.forward(request, response);
    }

    //metodo per cambiare la posizione dell'utente
    private void changeUserLocation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String userid = request.getParameter("userid");
        String indirizzo = request.getParameter("indirizzo");
        String citta = request.getParameter("citta");
        String provincia = request.getParameter("provincia");
        String cap = request.getParameter("cap");
        String telefono = request.getParameter("telefono");

        UserBean user = new UserBean();
        user.setUserid(userid);
        user.setIndirizzo(indirizzo);
        user.setCitta(citta);
        user.setProvincia(provincia);
        user.setCap(cap);
        user.setTelefono(telefono);
        model.doChangeUserLocation(user);

        user = model.doRetrieveByKeyUser(userid);
        request.getSession().setAttribute("user", user);

        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/utente.jsp");
        dispatcher.forward(request, response);
    }

    //metodo che restituisce la lista degli utenti
    private void listUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        List<UserBean> users = model.doRetrieveAllUsers();
        request.setAttribute("users", users);
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/lista-utenti.jsp");
        dispatcher.forward(request, response);
    }

    //metodo che cerca un utente per id
    private void searchUser(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String userId = request.getParameter("userId");
        UserBean searchedUser = model.doRetrieveByKeyUser(userId);
        request.setAttribute("searchedUser", searchedUser);
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/lista-utenti.jsp");
        dispatcher.forward(request, response);
    }
}