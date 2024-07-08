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
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.draw.VerticalPositionMark;
import java.io.File;
import java.io.FileOutputStream;
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
                    case "generafattura":
                        generaFattura(request,response);
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

    //metodo che genera la fattura di un ordine
    private void generaFattura(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    String orderIdParam = request.getParameter("idordine");

	    if (orderIdParam != null) {
	        try {
	            int orderId = Integer.parseInt(orderIdParam);
	            OrderBean order = model.retrieveOrderById(orderId); 

	            if (order != null) {
	                Document document = new Document();
	                response.setContentType("application/pdf");
                    String fileName = "fattura_" + orderId + ".pdf";
                    response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\""); //serve per scrivere come nome del file scaricato il numero di fattura
	                PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
	                document.open();

	                //set di font usati 
	                Font font = FontFactory.getFont("Arial", 24, Font.BOLD, BaseColor.BLACK);
	                Font font_bold = FontFactory.getFont("Arial", 16, Font.BOLD, BaseColor.BLACK); //creazione di un font bold

	                document.add(new Paragraph("FATTURA", font));

	                //gestione logo
                    String logopath = "/images/logo2.png";
	                Image logo = Image.getInstance(getServletContext().getRealPath(logopath));
	                logo.scaleToFit(100, 100);
	                float yPos = PageSize.A4.getHeight() - logo.getScaledHeight() - (PageSize.A4.getHeight() * 0.05f);
	                logo.setAbsolutePosition(PageSize.A4.getWidth() - logo.getScaledWidth() - (PageSize.A4.getWidth() * 0.05f), yPos);
	                document.add(logo);

	                font = FontFactory.getFont("Arial", 16, Font.NORMAL, BaseColor.BLACK);
	                document.add(new Paragraph("RoadRunnerParts", font));
	                document.add(new Chunk("\n"));

	                document.add(new Phrase("INDIRIZZO FATTURA:", font_bold));
	                document.add(new Paragraph(order.getIndirizzo() + ", " + order.getCitta() + ", " + order.getProvincia() + ", " + order.getCap() +", " + order.getTelefono(), font));
	                document.add(new Chunk("\n"));

	                PdfPTable tableHeader = new PdfPTable(2);
	                tableHeader.setWidthPercentage(100);

	                Phrase phrase = new Phrase();
	                phrase.add(new Chunk("FATTURA #: ", font_bold));
	                phrase.add(new Chunk(String.valueOf(order.getIdordine()), FontFactory.getFont("Arial", 16, Font.NORMAL, BaseColor.BLACK)));
	                PdfPCell cell = new PdfPCell(phrase);
	                cell.setHorizontalAlignment(Element.ALIGN_LEFT);
	                cell.setBorder(Rectangle.NO_BORDER);
	                tableHeader.addCell(cell);

	                phrase = new Phrase();
	                phrase.add(new Chunk("DATA FATTURA: ", font_bold));
	                SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
	                Timestamp originalDate = order.getDataOrdine();
	                Calendar calendar = Calendar.getInstance();
	                calendar.setTime(originalDate);
	                java.util.Date adjustedDate = calendar.getTime();
	                phrase.add(new Chunk(sdf.format(adjustedDate)));
	                cell = new PdfPCell(phrase);
	                cell.setHorizontalAlignment(Element.ALIGN_LEFT);
	                cell.setBorder(Rectangle.NO_BORDER);
	                tableHeader.addCell(cell);

	                //spazio tra intestazione e tabella dei prodotti
	                tableHeader.setSpacingAfter(20);
	                document.add(tableHeader);

	                PdfPTable tableProducts = new PdfPTable(4); // 3 colonne
	                tableProducts.setWidthPercentage(100);
	                tableProducts.setSpacingBefore(20);

	                cell = new PdfPCell(new Phrase("ID", font_bold));
	                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                    cell.setPaddingTop(10f);
                    cell.setPaddingBottom(10f);
	                tableProducts.addCell(cell);

                    cell = new PdfPCell(new Phrase("NOME", font_bold));
	                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                    cell.setPaddingTop(10f);
                    cell.setPaddingBottom(10f);
	                tableProducts.addCell(cell);

	                cell = new PdfPCell(new Phrase("DESCRIZIONE", font_bold));
	                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                    cell.setPaddingTop(10f);
                    cell.setPaddingBottom(10f);
	                tableProducts.addCell(cell);

	                cell = new PdfPCell(new Phrase("PREZZO", font_bold));
	                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                    cell.setPaddingTop(10f);
                    cell.setPaddingBottom(10f);
	                tableProducts.addCell(cell);

	                //righe per i vari prodotti dell'ordine
	                for (ProductBean product : order.getProdotti()) {
	                    cell = new PdfPCell(new Phrase(String.valueOf(product.getId()))); //id
	                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                    cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                        cell.setPaddingTop(10f);
                        cell.setPaddingBottom(10f);
	                    tableProducts.addCell(cell);

                        cell = new PdfPCell(new Phrase(product.getNome())); //nome
	                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                    cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                        cell.setPaddingTop(10f);
                        cell.setPaddingBottom(10f);
	                    tableProducts.addCell(cell);

	                    cell = new PdfPCell(new Phrase(product.getDescrizione())); //descrizione
	                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                    cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                        cell.setPaddingTop(10f);
                        cell.setPaddingBottom(10f);
	                    tableProducts.addCell(cell);

	                    cell = new PdfPCell(new Phrase("€ " + String.format("%.2f", product.getPrezzo()))); //prezzo
	                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
	                    cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
                        cell.setPaddingTop(10f);
                        cell.setPaddingBottom(10f);
	                    tableProducts.addCell(cell);
	                }

	                //spazio tra tabella prodotti e tabella con i costi
	                tableProducts.setSpacingAfter(20);
	                document.add(tableProducts);

                    //tabella dei costi
	                PdfPTable tableTotals = new PdfPTable(3); 
	                tableTotals.setWidthPercentage(50);
                    tableTotals.setSpacingBefore(20);
                    tableTotals.setHorizontalAlignment(Element.ALIGN_RIGHT);
                    document.add(new Paragraph(" "));
	                
	                float totaleprezzo = order.getPrezzoTotale();
	                float iva = totaleprezzo * 22 / 100;
	                float subtotale = totaleprezzo - iva;

	                cell = new PdfPCell(new Phrase("")); 
	                cell.setBorder(Rectangle.NO_BORDER);
	                tableTotals.addCell(cell);

	                cell = new PdfPCell(new Phrase("Subtotale  :")); 
	                cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
                    cell.setPaddingTop(7f);
	                cell.setBorder(Rectangle.NO_BORDER);
	                tableTotals.addCell(cell);

	                cell = new PdfPCell(new Phrase("€ " + String.format("%.2f", subtotale))); //subtotale
	                cell.setBorder(Rectangle.NO_BORDER);
                    cell.setPaddingTop(7f);
	                tableTotals.addCell(cell);

	                cell = new PdfPCell(new Phrase("")); 
	                cell.setBorder(Rectangle.NO_BORDER);
                    cell.setPaddingTop(7f);
                    cell.setPaddingBottom(7f);
	                tableTotals.addCell(cell);

	                cell = new PdfPCell(new Phrase("IVA 22.0%:")); //iva
	                cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
	                cell.setBorder(Rectangle.NO_BORDER);
                    cell.setPaddingBottom(7f);
	                tableTotals.addCell(cell);

	                cell = new PdfPCell(new Phrase("€ " + String.format("%.2f", iva)));
	                cell.setBorder(Rectangle.NO_BORDER);
                    cell.setPaddingBottom(7f);
	                tableTotals.addCell(cell);

	                Font font2 = FontFactory.getFont("Arial", 16, Font.BOLD, BaseColor.BLACK);
	                cell = new PdfPCell(new Phrase("")); 
	                cell.setBorder(Rectangle.NO_BORDER);
                    cell.setPaddingTop(7f);
                    cell.setPaddingBottom(7f);
	                tableTotals.addCell(cell);

	                cell = new PdfPCell(new Phrase(" TOTALE", font2)); //totale ordine
	                cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
	                cell.setBorder(Rectangle.NO_BORDER);
                    cell.setPaddingTop(7f);
                    cell.setPaddingBottom(7f);
	                tableTotals.addCell(cell);

	                cell = new PdfPCell(new Phrase("€ " + String.format("%.2f", totaleprezzo), font2));
	                cell.setBorder(Rectangle.NO_BORDER);
                    cell.setPaddingTop(7f);
                    cell.setPaddingBottom(7f);
	                tableTotals.addCell(cell);

	                // Aggiungi spazio dopo la tabella dei prezzi
	                tableTotals.setSpacingAfter(20);
	                document.add(tableTotals);

	                document.close();
	                writer.close();
	            } else {
	                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Ordine non trovato");
	            }
	        } catch (NumberFormatException | SQLException | DocumentException e) {
	            e.printStackTrace();
	            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore generando la fattura");
	        }
	    } else {
	        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID ordine mancante");
	    }
	}
}