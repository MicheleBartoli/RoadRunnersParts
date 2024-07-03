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

import it.unisa.model.ProductModelDS;
import it.unisa.model.UserBean;
import it.unisa.model.MetodoPagamentoBean;
import java.sql.Date;

@MultipartConfig
public class PagamentoControl extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ProductModelDS usa il DataSource
	static boolean isDataSource = true;

    private ProductModelDS model;

    public PagamentoControl() {
        super();
        model = new ProductModelDS();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (action != null) {
                switch (action.toLowerCase()) {
                    case "addmetodopagamento":
                        salvaMetodoPagamento(request,response);
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

    //metodo che salva il metodi di pagamento nel db 
    public void salvaMetodoPagamento(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        String userid = request.getParameter("userid");
        String tipoPagamento = request.getParameter("tipo_pagamento");
        String accountId = request.getParameter("account_id");
        String dataScadenza = request.getParameter("data_scadenza");
        String cvv = request.getParameter("cvv");
    
        try {
            UserBean user = model.doRetrieveByKeyUser(userid);
            if (user != null) {
                MetodoPagamentoBean metodoPagamento = new MetodoPagamentoBean();
                metodoPagamento.setUserIdPagamento(user.getUserid());
                metodoPagamento.setTipoPagamento(tipoPagamento);
                metodoPagamento.setAccountId(accountId);
    
                if (tipoPagamento.equals("Carta di Credito")) {
                    metodoPagamento.setDataScadenza(Date.valueOf(dataScadenza));
                    metodoPagamento.setCvv(cvv);
                }
    
                model.doChangePaymentMethods(metodoPagamento);
            } 
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore durante il salvataggio del metodo di pagamento.");
        }
    
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/utente.jsp");
        dispatcher.forward(request, response);
    }
}    