package it.unisa.control;

import java.util.Iterator;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;
import java.math.BigInteger;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;

import java.lang.String;

import it.unisa.model.CartBean;
import it.unisa.model.OrderBean;
import it.unisa.model.ProductBean;
import it.unisa.model.ProductModelDS;
import it.unisa.model.UserBean;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class ProductControl
 */
@MultipartConfig
public class ProductControl extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// ProductModelDS usa il DataSource
	static boolean isDataSource = true;

	static ProductModelDS model;

	static {
		model = new ProductModelDS();
	}

	public ProductControl() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String action = request.getParameter("action");

		try {
			if (action != null) {
				if (action.equalsIgnoreCase("registrautente")) { //registrazione utente
					String userid = request.getParameter("userid");
					String password = request.getParameter("password");
					String indirizzo = request.getParameter("indirizzo");
					String citta = request.getParameter("citta");
					String provincia = request.getParameter("provincia");
					String cap = request.getParameter("cap");
					String telefono = request.getParameter("telefono");
					UserBean existingUser = model.doRetrieveByKeyUser(userid);
					if(existingUser != null){
						//utente già registrato
						request.removeAttribute("registrato");
						request.setAttribute("registrato", "true");
					}
					else{
						//utente non registrato
						try {
							MessageDigest md = MessageDigest.getInstance("SHA-256"); //hashing della password
							byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
							BigInteger number = new BigInteger(1, hash);
							String hashedPassword = String.format("%064x", number);
							UserBean user = model.doCheckUser(userid, hashedPassword);
							if(user == null){
								user = new UserBean();
								user.setUserid(userid);
								user.setPasswordHash(hashedPassword);
								user.setTipo("Customer");
								user.setIndirizzo(indirizzo);
								user.setCitta(citta);
								user.setProvincia(provincia);
								user.setCap(cap);
								user.setTelefono(telefono);
								model.doSaveUser(user);
								request.removeAttribute("registrato");
								request.setAttribute("registrato", "false");
								request.removeAttribute("registrazione");
								request.setAttribute("registrazione", "successo");
							}
						} catch (NoSuchAlgorithmException | SQLException e) {
							e.printStackTrace();
						}
					}
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/home.jsp");
					dispatcher.forward(request, response);
				}else if (action.equalsIgnoreCase("addProduct")) { //aggiunta prodotto al carrello
					// Ottieni la sessione corrente. Se non esiste, ne crea una nuova.
					HttpSession session = request.getSession();
					int id = Integer.parseInt(request.getParameter("idprodotto")); //cosa aggiunta dopo 
					//ottieni il carrello della sessione. se non esiste ne crea uno nuovo
					CartBean cart = (CartBean) session.getAttribute("cart");
					if(cart == null){
						cart = new CartBean();
						session.setAttribute("cart",cart);
					}
					ProductBean product = model.doRetrieveByKey(id);

					cart.addProduct(product);

					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/carrello.jsp");
					dispatcher.forward(request, response);
				} else if (action.equalsIgnoreCase("loginutente")) { //login utente
					String userid = request.getParameter("userid");
					String password = request.getParameter("password");
					UserBean existingUser = model.doRetrieveByKeyUser(userid);
					if(existingUser == null){
						//utente non esistente
						request.removeAttribute("utenteinesistente");
						request.setAttribute("utenteinesistente", "true");
					}
					else{
						//utente esistente
						try {
							MessageDigest md = MessageDigest.getInstance("SHA-256"); //hashing della password
							byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
							BigInteger number = new BigInteger(1, hash);
							String hashedPassword = String.format("%064x", number);
							UserBean user = model.doCheckUser(userid, hashedPassword);
							if(user == null){
								//password errata
								request.removeAttribute("passworderrata");
								request.setAttribute("passworderrata", "true");
							}
							else{
								//password corretta
								request.getSession().removeAttribute("userid");
								request.getSession().removeAttribute("tipo");
								request.getSession().removeAttribute("user");
								request.getSession().setAttribute("userid", userid);
								request.getSession().setAttribute("tipo", user.getTipo());
								request.getSession().setAttribute("user", user);
							}
						} catch (NoSuchAlgorithmException | SQLException e) {
							e.printStackTrace();
						}
					}
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/home.jsp");
					dispatcher.forward(request, response);
				} else if (action.equalsIgnoreCase("logoututente")) { //logout utente
					request.getSession().invalidate();
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/login.jsp");
					dispatcher.forward(request, response);
				}
				if (action.equalsIgnoreCase("read")) { //visualizzazione catalogo prodotti
					int id = Integer.parseInt(request.getParameter("idprodotto"));
					request.removeAttribute("prodotto");
					request.setAttribute("prodotto", model.doRetrieveByKey(id));
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp"); //pagina di amministazione catalogo prodotti
					dispatcher.forward(request, response);
				} else if (action.equalsIgnoreCase("readdetails")) { //visualizzazione dettagli prodotto da catalogo
					int id = Integer.parseInt(request.getParameter("idprodotto"));
					request.removeAttribute("prodotto");
					request.setAttribute("prodotto", model.doRetrieveByKey(id));
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/dettaglio-prodotto.jsp"); //pagina di dettaglio di un prodotto da catalogo
					dispatcher.forward(request, response);
				} else if (action.equalsIgnoreCase("delete")) { //eliminazione prodotto da catalogo
					int id = Integer.parseInt(request.getParameter("idprodotto"));
					model.doDelete(id);

					request.removeAttribute("prodotti");
					request.setAttribute("prodotti",model.doRetrieveAll("idprodotto"));

					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp"); //pagina di amministrazione catalogo
					dispatcher.forward(request, response);
				}else if (action.equalsIgnoreCase("deleteCart")) { //eliminazione prodotto dal carrello
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
			   } else if (action.equalsIgnoreCase("saveOrder")) { //salvataggio ordine nel db
					String userid = (String) request.getSession().getAttribute("userid");
					CartBean cart = (CartBean) request.getSession().getAttribute("cart");

					if (userid != null && cart != null) {
					try {
						model.doSaveOrder(userid, cart);
						request.getSession().removeAttribute("cart"); // pulisce il carrello
					} catch (SQLException e) {
						// Handle exception
						e.printStackTrace();
					}
					}
				RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/carrello.jsp"); 
				dispatcher.forward(request, response);
				} else if (action.equalsIgnoreCase("insert")) { //inserimento prodotto nel catalogo
					String nome = new BufferedReader(new InputStreamReader(request.getPart("nome").getInputStream(), StandardCharsets.UTF_8)).readLine();
    				String descrizione = new BufferedReader(new InputStreamReader(request.getPart("descrizione").getInputStream(), StandardCharsets.UTF_8)).readLine();
    				float prezzo = Float.parseFloat(new BufferedReader(new InputStreamReader(request.getPart("prezzo").getInputStream(), StandardCharsets.UTF_8)).readLine());
   					int quantita = Integer.parseInt(new BufferedReader(new InputStreamReader(request.getPart("quantita").getInputStream(), StandardCharsets.UTF_8)).readLine());
    				String marca = new BufferedReader(new InputStreamReader(request.getPart("marca").getInputStream(), StandardCharsets.UTF_8)).readLine();
    				String modello_auto = new BufferedReader(new InputStreamReader(request.getPart("modello_auto").getInputStream(), StandardCharsets.UTF_8)).readLine();

					//GESTIONE DELL UPLOAD DELL IMMAGINE
					Part filePart = request.getPart("immagine"); //capire come sostituirlo
					InputStream inputStream = filePart.getInputStream(); //ottiene lo stream di input dell'immagine
					//convertendo l'inputStream in byte[] (BLOB)
					ByteArrayOutputStream output = new ByteArrayOutputStream();
					byte[] buffer = new byte[10240];
					int bytesRead = -1;
					while ((bytesRead = inputStream.read(buffer)) != -1) {
						output.write(buffer, 0, bytesRead);
					}
					byte[] image = output.toByteArray();

					//crea un oggetto e imposta i dati
					ProductBean bean = new ProductBean();
					bean.setNome(nome);
					bean.setDescrizione(descrizione);
					bean.setPrezzo(prezzo);
					bean.setQuantita(quantita);
					bean.setMarca(marca);
					bean.setModelloAuto(modello_auto);
					bean.setImmagine(image);

					model.doSave(bean); //salva il prodotto nel db richiamando doSave()

					request.removeAttribute("prodotti");
					request.setAttribute("prodotti",model.doRetrieveAll("idprodotto"));

					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp");
					dispatcher.forward(request, response);
				} else if (action.equalsIgnoreCase("change")) {
					try {
						String nome = new BufferedReader(new InputStreamReader(request.getPart("nome").getInputStream(), StandardCharsets.UTF_8)).readLine();
						String descrizione = new BufferedReader(new InputStreamReader(request.getPart("descrizione").getInputStream(), StandardCharsets.UTF_8)).readLine();
						float prezzo = Float.parseFloat(new BufferedReader(new InputStreamReader(request.getPart("prezzo").getInputStream(), StandardCharsets.UTF_8)).readLine());
						int quantita = Integer.parseInt(new BufferedReader(new InputStreamReader(request.getPart("quantita").getInputStream(), StandardCharsets.UTF_8)).readLine());
						String marca = new BufferedReader(new InputStreamReader(request.getPart("marca").getInputStream(), StandardCharsets.UTF_8)).readLine();
						String modello_auto = new BufferedReader(new InputStreamReader(request.getPart("modello_auto").getInputStream(), StandardCharsets.UTF_8)).readLine();
						int id = Integer.parseInt(new BufferedReader(new InputStreamReader(request.getPart("idprodotto").getInputStream(), StandardCharsets.UTF_8)).readLine());
				
						// Gestione dell'upload dell'immagine
						Part filePart = request.getPart("immagine");
				
						ProductBean bean = new ProductBean();
						bean.setNome(nome);
						bean.setDescrizione(descrizione);
						bean.setPrezzo(prezzo);
						bean.setQuantita(quantita);
						bean.setId(id);
						bean.setMarca(marca);
						bean.setModelloAuto(modello_auto);
				
						if(filePart != null && filePart.getSize() > 0) {
							// Se un nuovo file è stato caricato, aggiorna l'immagine
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
						}else{
							ProductBean oldBean = model.doRetrieveByKey(id);
							bean.setImmagine(oldBean.getImmagine());
						}
				
						model.doChange(bean);

						 // Aggiorna il bean con l'immagine aggiornata (potrebbe non essere necessario se l'immagine non cambia)
						 //bean.setImmagine(model.doRetrieveByKey(id).getImmagine());
				
						request.removeAttribute("prodotto");
						request.setAttribute("prodotto", model.doRetrieveByKey(id));
				
						RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/dettaglio-prodotto.jsp");
						dispatcher.forward(request, response);
					} catch (Exception e) {
						e.printStackTrace();
						// Gestisci l'errore, ad esempio reindirizzando a una pagina di errore
						response.sendRedirect("errorPage.jsp");
					}
				}else if(action.equalsIgnoreCase("changeUserLocation")){ //modifica indirizzo utente
					String userid = request.getParameter("userid");
					String indirizzo = request.getParameter("indirizzo");
					String citta = request.getParameter("citta");
					String provincia = request.getParameter("provincia");
					String cap = request.getParameter("cap");
					String telefono = request.getParameter("telefono");
				
					UserBean bean = new UserBean();
					bean.setUserid(userid);
					bean.setIndirizzo(indirizzo);
					bean.setCitta(citta);
					bean.setProvincia(provincia);
					bean.setCap(cap);
					bean.setTelefono(telefono);
					model.doChangeUserLocation(bean);
					bean = model.doRetrieveByKeyUser(userid);

					request.removeAttribute("user");
					request.getSession().setAttribute("user", bean);
				
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/utente.jsp");
					dispatcher.forward(request, response);
				} else if (action.equalsIgnoreCase("amministratore")) { //pagina amministratore
					String sortOption = request.getParameter("sortOption");
					if(sortOption == null || sortOption.isEmpty()){
						sortOption = "idprodotto";
					}
					request.removeAttribute("prodotti");
					request.setAttribute("prodotti",model.doRetrieveAll(sortOption));
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp");
					dispatcher.forward(request, response);
				}else if (action.equalsIgnoreCase("ordini")) { //pagina ordini utente
					String userid = (String) request.getSession().getAttribute("userid");
				
					if (userid != null) {
						try {
							List<OrderBean> orders = model.doRetrieveByUserid(userid);
							request.setAttribute("ordini", orders);
						} catch (SQLException e) {
							// Handle exception
							e.printStackTrace();
							request.setAttribute("errorMessage", "An error occurred while retrieving orders.");
							RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/error.jsp"); //error.jsp serve per dire che quell utente non ha ordini effettuati (DA FARE)
							dispatcher.forward(request, response);
							return; // Important to stop further execution in case of error
						}
					}
				
					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/utente.jsp");
					dispatcher.forward(request, response);
				}else if(action.equalsIgnoreCase("addMetodoPagamento")){ //aggiunta o modifica del metodo di pagamento
					String userid = request.getParameter("userid");
					String metodo_pagamento = request.getParameter("payment-method");
					if ("credit-card".equals(metodo_pagamento)){
						metodo_pagamento = "Carta di credito";
					}
					if ("paypal".equals(metodo_pagamento)){
						metodo_pagamento = "PayPal";
					}

					UserBean bean = new UserBean();
					bean.setUserid(userid);
					bean.setMetodoPagamento(metodo_pagamento);
					model.doChangeUserPaymentMethod(bean);

					bean = model.doRetrieveByKeyUser(userid);

					request.removeAttribute("user");
					request.getSession().setAttribute("user", bean);

					RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/utente.jsp");
					dispatcher.forward(request, response);
				}

			}
			request.removeAttribute("prodotti");
			request.setAttribute("prodotti",model.doRetrieveAll("idprodotto"));
		} catch (SQLException e) {
			System.out.println("Error:" + e.getMessage());}
		}
	

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

}