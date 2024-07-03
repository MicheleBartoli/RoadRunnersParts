package it.unisa.control;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.TimeZone;
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
import it.unisa.model.ProductModelDS;
import it.unisa.model.UserBean;
import it.unisa.model.CartBean;
import it.unisa.model.MetodoPagamentoBean;
import it.unisa.model.OrderBean;
import it.unisa.model.ProductBean;

import java.sql.Date;

@MultipartConfig
public class OrdineControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ProductModelDS usa il DataSource
	static boolean isDataSource = true;

    private ProductModelDS model;

    public OrdineControl() {
        super();
        model = new ProductModelDS();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (action != null) {
                switch (action.toLowerCase()) {
                    case "saveorder":
                        salvaOrdine(request,response);
                        break;
                    case "orderdetails":
                    	dettaglioOrdine(request,response);
                        break;
                    case "listaordini":
                        listaOrdini(request,response);
                        break;
                    case "ordiniadmin":
                        listaOrdiniAdmin(request,response);
                        break;
                    case "ordiniutente":
                        ricercaOrdiniUtente(request, response);
                        break;
                    case "ordiniperdata":
                        ricercaOrdineData(request,response);
                        break;
                    default:
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                }
            }
        } catch (SQLException e) {
            throw new ServletException("SQL Error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    //metodo che salva un ordine nel db 
    public void salvaOrdine(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
    String userid = (String) request.getSession().getAttribute("userid");
    CartBean cart = (CartBean) request.getSession().getAttribute("cart");

    if (userid != null && cart != null) {
        try {
            model.doSaveOrder(userid, cart);
            request.getSession().removeAttribute("cart"); // pulisce il carrello
            response.sendRedirect(request.getContextPath() + "/carrello.jsp"); // mostra il carrello vuoto
            return;
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/carrello.jsp");
    dispatcher.forward(request, response);
}

    //metodo che mostra i dettagli di un ordine
    public void dettaglioOrdine(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String orderIdParam = request.getParameter("idordine");
        
        if (orderIdParam != null) {
            int orderId = Integer.parseInt(orderIdParam);
            List <ProductBean> products = model.retrieveProductsByOrderId(orderId);
            
            if (products != null) {
                request.setAttribute("order", products);
                RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/dettaglio-ordine.jsp");
                dispatcher.forward(request, response);
            } else {
                response.sendRedirect("/ordini-customer.jsp");
            }
        } else {
            response.sendRedirect("/ordini-customer.jsp");
        }
}

    //metodo che mostra la lista degli ordini di un utente
    public void listaOrdini(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
    String userid = (String) request.getSession().getAttribute("userid");
    
    if (userid != null) {
        List<OrderBean> orders = model.doRetrieveByUserId(userid);
        request.setAttribute("orders", orders);
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ordini-customer.jsp");
        dispatcher.forward(request, response);
    } else {
        response.sendRedirect("login.jsp");
    }
    } 
    
    //metodo che lista tutti gli ordini
    public void listaOrdiniAdmin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException{
        List <OrderBean> orders = model.DoRetrieveAllOrders();
        request.setAttribute("orders", orders);
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ordini-admin.jsp");
        dispatcher.forward(request, response);
    }

    //metodo che ricerca gli ordini di un utente
    public void ricercaOrdiniUtente(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException{
        String userid = request.getParameter("userId");

        if(userid != null){
            List <OrderBean> ordersurser = model.doRetrieveByUserId(userid);
            request.setAttribute("searchedOrders",ordersurser);
            RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ordini-admin.jsp");
            dispatcher.forward(request, response);
        }else{
            response.sendRedirect("login.jsp");
        }
    }

    //metodo che ricerca gli ordini per data
   public void ricercaOrdineData(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException, SQLException {
        String startDateParam = request.getParameter("fromdate");
        String endDateParam = request.getParameter("todate");

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        Timestamp startDate = null;
        Timestamp endDate = null;

        try {
        	TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
            if (startDateParam != null && !startDateParam.isEmpty()) {
                java.util.Date parsedStartDate = dateFormat.parse(startDateParam);
                startDate = new Timestamp(parsedStartDate.getTime());
            }
            if (endDateParam != null && !endDateParam.isEmpty()) {
            // Imposta l'endDate al giorno successivo
            java.util.Date parsedEndDate = dateFormat.parse(endDateParam);
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(parsedEndDate);
            calendar.add(Calendar.DAY_OF_MONTH, 1); // Aggiungi un giorno
            parsedEndDate = calendar.getTime();
            endDate = new Timestamp(parsedEndDate.getTime());
        }
        } catch (ParseException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format");
            return;
        }

        if (startDate != null && endDate != null) {
            try {
                List<OrderBean> ordersdate = model.DoRetrieveOrdersByDate(startDate, endDate);
                request.setAttribute("filteredOrders", ordersdate);
            } catch (SQLException e) {
                e.printStackTrace();
                throw new ServletException("Database access error", e);
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Start date or end date is missing");
            return;
        }

        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ordini-admin.jsp");
        dispatcher.forward(request, response);
    }
}