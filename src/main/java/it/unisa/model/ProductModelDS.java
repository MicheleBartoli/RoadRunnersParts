package it.unisa.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Statement;
import java.sql.Date;

public class ProductModelDS implements ProductModel {

	private static DataSource ds;

	static {
		try {
			Context initCtx = new InitialContext();
			Context envCtx = (Context) initCtx.lookup("java:comp/env");
			ds = (DataSource) envCtx.lookup("jdbc/RoadRunnerParts");
		} catch (NamingException e) {
			System.out.println("Error:" + e.getMessage());
		}
	}

	private static final String TABLE_NAME = "prodotto";
	private static final String TABLE_NAME2 = "user";
	private static final String TABLE_NAME3 = "ordine";

	@Override
	public synchronized void doSave(ProductBean prodotto) throws SQLException { //SALVA PRODTTO NEL DB
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		String insertSQL = "INSERT INTO " + ProductModelDS.TABLE_NAME + " (NOME, DESCRIZIONE, PREZZO, QUANTITA, MARCA, MODELLO_AUTO, IMMAGINE) VALUES (?, ?, ?, ?, ?, ?, ?)";
		try {
			connection = ds.getConnection();
			connection.setAutoCommit(false);
			preparedStatement = connection.prepareStatement(insertSQL);
			preparedStatement.setString(1, prodotto.getNome());
			preparedStatement.setString(2, prodotto.getDescrizione());
			preparedStatement.setFloat(3, prodotto.getPrezzo());
			preparedStatement.setInt(4, prodotto.getQuantita());
			preparedStatement.setString(5, prodotto.getMarca());
			preparedStatement.setString(6, prodotto.getModelloAuto());
			byte[] immagine = prodotto.getImmagine();
			if (immagine != null) {
				preparedStatement.setBytes(7, immagine);
			} else {
				preparedStatement.setNull(7, java.sql.Types.BLOB);
			}
			preparedStatement.executeUpdate();
			connection.commit();
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) {
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	@Override
	public synchronized void doSaveUser(UserBean user) throws SQLException { //SALVA USER NEL DB
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		String insertSQL = "INSERT INTO " + ProductModelDS.TABLE_NAME2 + " (userid, tipo, password_hash, indirizzo, citta, provincia, cap, telefono) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		try {
			connection = ds.getConnection();
			connection.setAutoCommit(false);
			preparedStatement = connection.prepareStatement(insertSQL);
			preparedStatement.setString(1, user.getUserid());
			preparedStatement.setString(2, user.getTipo());
			preparedStatement.setString(3, user.getPasswordHash());
			preparedStatement.setString(4, user.getIndirizzo());
			preparedStatement.setString(5, user.getCitta());
			preparedStatement.setString(6, user.getProvincia());
			preparedStatement.setString(7, user.getCap());
			preparedStatement.setString(8, user.getTelefono());
			preparedStatement.executeUpdate();
			connection.commit();
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) {
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	public synchronized void doSaveOrder(String userid, CartBean cart) throws SQLException {
    Connection connection = null;
    PreparedStatement insertOrderStatement = null;
    PreparedStatement updateProductQuantityStatement = null;
    String insertOrderSQL = "INSERT INTO ordine (userid, idprodotto_ordinato, prezzo_ordine, indirizzo, citta, provincia, cap, telefono, idordine) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    String updateQuantitySQL = "UPDATE prodotto SET quantita = quantita - 1 WHERE idprodotto = ?";
    String selectUserSQL = "SELECT indirizzo, citta, provincia, cap, telefono FROM " + ProductModelDS.TABLE_NAME2 + " WHERE userid = ?";
    
    try {
        connection = ds.getConnection();
        connection.setAutoCommit(false);
    
        int orderId = generateOrderId(); //genera un id random univoco
        
        insertOrderStatement = connection.prepareStatement(insertOrderSQL);
        updateProductQuantityStatement = connection.prepareStatement(updateQuantitySQL);
        
        PreparedStatement selectUserStatement = connection.prepareStatement(selectUserSQL);
        selectUserStatement.setString(1, userid);
        ResultSet rs = selectUserStatement.executeQuery();
        
        String indirizzo = "", citta = "", provincia = "", cap = "";
        String telefono = "";
        
        if (rs.next()) {
            indirizzo = rs.getString("indirizzo");
            citta = rs.getString("citta");
            provincia = rs.getString("provincia");
            cap = rs.getString("cap");
            telefono = rs.getString("telefono");
        }
        
        for (ProductBean product : cart.getProducts()) {
            // Inserisci l'ordine nel db
            insertOrderStatement.setString(1, userid);
            insertOrderStatement.setInt(2, product.getId());
            insertOrderStatement.setFloat(3, product.getPrezzo());
            insertOrderStatement.setString(4, indirizzo);
            insertOrderStatement.setString(5, citta);
            insertOrderStatement.setString(6, provincia);
            insertOrderStatement.setString(7, cap);
            insertOrderStatement.setString(8, telefono);
            insertOrderStatement.setInt(9, orderId); // Utilizza lo stesso ID ordine per tutti i prodotti
            insertOrderStatement.executeUpdate();
            
            // Aggiorna la quantità del prodotto nel magazzino
            updateProductQuantityStatement.setInt(1, product.getId());
            updateProductQuantityStatement.executeUpdate();
        }
        
        connection.commit();
    } catch (SQLException e) {
        if (connection != null) {
            try {
                connection.rollback();
            } catch (SQLException rollbackEx) {
                rollbackEx.printStackTrace();
            }
        }
        e.printStackTrace();
    } finally {
        try {
            if (insertOrderStatement != null) insertOrderStatement.close();
            if (updateProductQuantityStatement != null) updateProductQuantityStatement.close();
            if (connection != null) {
                connection.setAutoCommit(true);
                connection.close();
            }
        } catch (SQLException closeEx) {
            closeEx.printStackTrace();
        }
    }
}

	//metodo per generare un id ordine random da assegnare a tutti i prodotti contenuti nello stesso ordine
	private int generateOrderId() {
    Random random = new Random();
    return random.nextInt(1000000); // Genera un numero casuale tra 0 e 999999
	}

	public synchronized void doChange(ProductBean prodotto) throws SQLException { //MODIFICA PRODOTTO NEL DB
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		String updateSQL = "UPDATE " + ProductModelDS.TABLE_NAME + " SET NOME = ?, DESCRIZIONE = ?, PREZZO = ?, QUANTITA = ?, MARCA = ?, MODELLO_AUTO = ?, IMMAGINE = ? WHERE IDPRODOTTO = ?";
		try {
			connection = ds.getConnection();
			connection.setAutoCommit(false);
			preparedStatement = connection.prepareStatement(updateSQL);
			preparedStatement.setString(1, prodotto.getNome());
			preparedStatement.setString(2, prodotto.getDescrizione());
			preparedStatement.setFloat(3, prodotto.getPrezzo());
			preparedStatement.setInt(4, prodotto.getQuantita());
			preparedStatement.setString(5, prodotto.getMarca());
			preparedStatement.setString(6, prodotto.getModelloAuto());
			byte[] immagine = prodotto.getImmagine();
			if (immagine != null) {
				preparedStatement.setBytes(7, immagine);
			} else {
				preparedStatement.setNull(7, java.sql.Types.BLOB);
			}
			preparedStatement.setInt(8, prodotto.getId());
			preparedStatement.executeUpdate();
			connection.commit();
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) {
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	public synchronized void doChangeUserLocation(UserBean utente) throws SQLException { //CAMBIA INDIRIZZO E TELEFONO UTENTE 
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		String updateSQL = "UPDATE " + ProductModelDS.TABLE_NAME2 + " SET indirizzo = ?, citta = ?, provincia = ?, cap = ?, telefono = ? WHERE userid = ?";
		try {
			connection = ds.getConnection();
			connection.setAutoCommit(false);
			preparedStatement = connection.prepareStatement(updateSQL);
			preparedStatement.setString(1, utente.getIndirizzo());
			preparedStatement.setString(2, utente.getCitta());
			preparedStatement.setString(3, utente.getProvincia());
			preparedStatement.setString(4, utente.getCap());
			preparedStatement.setString(5, utente.getTelefono());
			preparedStatement.setString(6, utente.getUserid());
			preparedStatement.executeUpdate();
			connection.commit();
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) {
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	@Override
	public synchronized ProductBean doRetrieveByKey(int id) throws SQLException { //RECUPERA PRODOTTO DAL DB
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		ProductBean bean = new ProductBean();
		String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME + " WHERE IDPRODOTTO = ?";
		try {
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setInt(1, id);
			ResultSet rs = preparedStatement.executeQuery();
			while (rs.next()) {
				bean.setId(rs.getInt("IDPRODOTTO"));
				bean.setNome(rs.getString("NOME"));
				bean.setDescrizione(rs.getString("DESCRIZIONE"));
				bean.setPrezzo(rs.getInt("PREZZO"));
				bean.setQuantita(rs.getInt("QUANTITA"));
				bean.setMarca(rs.getString("MARCA"));
				bean.setModelloAuto(rs.getString("MODELLO_AUTO"));
				byte[] immagine = rs.getBytes("IMMAGINE");
            	bean.setImmagine(immagine);
			}
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			}
		}
		return bean;
	}

	@Override
	public UserBean doRetrieveByKeyUser(String userid) throws SQLException { //RECUPERA UTENTE DAL DB
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME2 + " WHERE userid = ? ";
		try {
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setString(1, userid);
			ResultSet rs = preparedStatement.executeQuery();
			if (rs.next()) {
				UserBean bean = new UserBean();
				bean.setUserid(rs.getString("userid"));
				bean.setTipo(rs.getString("tipo"));
				bean.setPasswordHash(rs.getString("password_hash"));
				bean.setIndirizzo(rs.getString("indirizzo"));
				bean.setCitta(rs.getString("citta"));
				bean.setProvincia(rs.getString("provincia"));
				bean.setCap(rs.getString("cap"));
				bean.setTelefono(rs.getString("telefono"));
				bean.setMetodoPagamento(rs.getString("metodo_pagamento"));
				return bean;
			}
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			} 
		}
		return null;
	}

	@Override
	public List<OrderBean> doRetrieveByUserId(String userid) throws SQLException { //RECUPERA TUTTI GLI ORDINI DI UN UTENTE
    	PreparedStatement preparedStatement = null;
    	Connection connection = null;
    	String selectSQL = "SELECT o.idordine, o.userid, o.idprodotto_ordinato, o.prezzo_ordine, " +
            "o.indirizzo, o.citta, o.provincia, o.cap, o.telefono, o.data_ordine, " +
            "p.idprodotto, p.nome AS nome_prodotto, p.descrizione AS descrizione_prodotto, " +
            "p.prezzo AS prezzo_prodotto, p.quantita AS quantita_prodotto, " +
            "p.marca, p.modello_auto, p.immagine " +
            "FROM ordine o " +
            "JOIN prodotto p ON o.idprodotto_ordinato = p.idprodotto " +
            "WHERE o.userid = ? " +
            "ORDER BY o.data_ordine DESC";
    
    	List<OrderBean> orders = new ArrayList<>();
    	Map<String, OrderBean> orderMap = new LinkedHashMap<>(); // Map per gestire gli ordini con più prodotti
    
    try {
        connection = ds.getConnection();
        preparedStatement = connection.prepareStatement(selectSQL);
        preparedStatement.setString(1, userid);
        ResultSet rs = preparedStatement.executeQuery();
        
        while (rs.next()) {
            String idOrdine = rs.getString("idordine");
            OrderBean orderBean = orderMap.get(idOrdine);
            
            if (orderBean == null) {
                orderBean = new OrderBean();
                orderBean.setIdordine(rs.getString("idordine")); 
                orderBean.setUserid(rs.getString("userid"));
                orderBean.setPrezzoTotale(0);
                orderBean.setIndirizzo(rs.getString("indirizzo"));
                orderBean.setCitta(rs.getString("citta"));
                orderBean.setProvincia(rs.getString("provincia"));
                orderBean.setCap(rs.getString("cap"));
                orderBean.setTelefono(rs.getInt("telefono"));
                orderBean.setDataOrdine(rs.getTimestamp("data_ordine"));
                orderBean.setProdotti(new ArrayList<>());
                orderMap.put(idOrdine, orderBean);
            }
            
            // productbean associato all'ordine
            ProductBean productBean = new ProductBean();
            productBean.setId(rs.getInt("idprodotto"));
            productBean.setNome(rs.getString("nome_prodotto"));
            productBean.setPrezzo(rs.getFloat("prezzo_prodotto"));
            productBean.setDescrizione(rs.getString("descrizione_prodotto"));
            orderBean.getProdotti().add(productBean);
			orderBean.setPrezzoTotale(orderBean.getPrezzoTotale() + productBean.getPrezzo()); // Aggiorna il prezzo totale
        }
        
        // Aggiungi tutti gli ordini dalla mappa all'elenco da restituire
        orders.addAll(orderMap.values());
        
    } finally {
        try {
            if (preparedStatement != null) preparedStatement.close();
        } finally {
            if (connection != null) connection.close();
        }
    }
    
    return orders;
}


	public List<UserBean> doRetrieveAllUsers() throws SQLException { //RECUPERA TUTTI GLI UTENTI PRESENTI NEL DB 
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        List<UserBean> users = new ArrayList<>();
        
        String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME2;
        
        try {
            connection = ds.getConnection();
            preparedStatement = connection.prepareStatement(selectSQL);
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                UserBean bean = new UserBean();
                bean.setUserid(rs.getString("userid"));
                bean.setTipo(rs.getString("tipo"));
                bean.setPasswordHash(rs.getString("password_hash"));
                bean.setIndirizzo(rs.getString("indirizzo"));
                bean.setCitta(rs.getString("citta"));
                bean.setProvincia(rs.getString("provincia"));
                bean.setCap(rs.getString("cap"));
                bean.setTelefono(rs.getString("telefono"));
                bean.setMetodoPagamento(rs.getString("metodo_pagamento"));
                users.add(bean);
            }
        } finally {
            try {
                if (preparedStatement != null) preparedStatement.close();
            } finally {
                if (connection != null) connection.close();
            }
        }
        return users;
    }

	@Override 
	public UserBean doCheckUser(String userid, String password) throws SQLException { //CONTROLLA SE UN UTENTE E' PRESENTE NEL DB
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME2 + " WHERE userid = ? AND password_hash = ?";
		try {
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setString(1, userid);
			preparedStatement.setString(2, password);
			ResultSet rs = preparedStatement.executeQuery();
			if (rs.next()) {
				UserBean bean = new UserBean();
				bean.setUserid(rs.getString("userid"));
				bean.setTipo(rs.getString("tipo"));
				bean.setPasswordHash(rs.getString("password_hash"));
				bean.setIndirizzo(rs.getString("indirizzo"));
				bean.setCitta(rs.getString("citta"));
				bean.setProvincia(rs.getString("provincia"));
				bean.setCap(rs.getString("cap"));
				bean.setTelefono(rs.getString("telefono"));
				bean.setMetodoPagamento(rs.getString("metodo_pagamento"));
				return bean;
			}
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			}
		}
		return null;
	}

	@Override
	public synchronized boolean doDelete(int idprodotto) throws SQLException { //ELIMINA PRODOTTO DAL DB
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		int result = 0;
		String deleteSQL = "DELETE FROM " + ProductModelDS.TABLE_NAME + " WHERE IDPRODOTTO = ?";
		try {
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(deleteSQL);
			preparedStatement.setInt(1, idprodotto);
			result = preparedStatement.executeUpdate();
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			}
		}
		return (result != 0);
	}

	@Override
	public synchronized List<ProductBean> doRetrieveAll(String order) throws SQLException { //RECUPERA TUTTI I PRODOTTI DAL DB 
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		List<ProductBean> products = new ArrayList<ProductBean>();

		String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME + " WHERE quantita > 0";
		
		if (order != null && !order.equals("")) {
			selectSQL += " ORDER BY " + order;
		}
		try {
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(selectSQL);
			ResultSet rs = preparedStatement.executeQuery();
			while (rs.next()) {
				ProductBean bean = new ProductBean();
				bean.setId(rs.getInt("idprodotto"));
				bean.setNome(rs.getString("nome"));
				bean.setDescrizione(rs.getString("descrizione"));
				bean.setPrezzo(rs.getFloat("prezzo"));
				bean.setQuantita(rs.getInt("quantita"));
				bean.setMarca(rs.getString("marca"));
				bean.setModelloAuto(rs.getString("modello_auto"));
				byte[] immagine = rs.getBytes("immagine");
          		bean.setImmagine(immagine);
				products.add(bean);
			}
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			}
		}
		return products;
	}

	public Collection<ProductBean> getProductsByBrandAndModel(String marca, String modello_auto) throws SQLException { //RECUPERA PRODOTTI PER MARCA E MODELLO AUTO
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		Collection<ProductBean> products = new LinkedList<ProductBean>();
		try {
			connection = ds.getConnection();
			String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME + " WHERE marca = ? AND modello_auto = ?";
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setString(1, marca);
			preparedStatement.setString(2, modello_auto);
			ResultSet rs = preparedStatement.executeQuery();
			while (rs.next()) {
				ProductBean bean = new ProductBean();
				bean.setId(rs.getInt("id"));
				bean.setNome(rs.getString("nome"));
				bean.setMarca(rs.getString("marca"));
				bean.setModelloAuto(rs.getString("modello_auto"));
				bean.setDescrizione(rs.getString("descrizione"));
				bean.setPrezzo(rs.getFloat("prezzo"));
				bean.setQuantita(rs.getInt("quantita"));
				byte[] immagine = rs.getBytes("immagine");
           		bean.setImmagine(immagine);
				products.add(bean);
			}
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			}
		}
		return products;
	}

	public void doChangePaymentMethods(MetodoPagamentoBean metodoPagamento) throws SQLException { //MODIFICA IL METODO DI PAGAMENTO 
	    Connection connection = null;
	    PreparedStatement preparedStatement = null;
	    try {
	        connection = ds.getConnection();
	       
	        // Verifica se il metodo di pagamento già esiste nel database
	        boolean metodoEsistente = checkMetodoPagamentoEsistente(metodoPagamento.getUserIdPagamento());
	        
	        if (metodoEsistente) {
	            // Se esiste esegui un'istruzione UPDATE
	            String updateSQL = "UPDATE metodi_pagamento SET tipo_pagamento = ?, account_id = ?, " +
	                               "data_scadenza = ?, cvv = ? WHERE user_id = ?";
	            
	            preparedStatement = connection.prepareStatement(updateSQL);
	            preparedStatement.setString(1, metodoPagamento.getTipoPagamento());
	            preparedStatement.setString(2, metodoPagamento.getAccountId());
	            java.util.Date utilDate = metodoPagamento.getDataScadenza(); 
	            if (utilDate != null) {
	                java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
	                preparedStatement.setDate(3, sqlDate);
	            } else {
	            	preparedStatement.setDate(3, null); 
	            }
	            preparedStatement.setString(4, metodoPagamento.getCvv());
	            preparedStatement.setString(5, metodoPagamento.getUserIdPagamento());
	        } else {
	            // Se non esiste, esegui un'istruzione INSERT
	            String insertSQL = "INSERT INTO metodi_pagamento (user_id, tipo_pagamento, account_id, " +
	                               "data_scadenza, cvv) VALUES (?, ?, ?, ?, ?)";
	            
	            preparedStatement = connection.prepareStatement(insertSQL);
	            preparedStatement.setString(1, metodoPagamento.getUserIdPagamento());
	            preparedStatement.setString(2, metodoPagamento.getTipoPagamento());
	            preparedStatement.setString(3, metodoPagamento.getAccountId());
	            
	            java.util.Date utilDate = metodoPagamento.getDataScadenza();
	            if (utilDate != null) {
	                java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
	                preparedStatement.setDate(4, sqlDate);
	            } else {
	            	preparedStatement.setDate(4, null);
	            }

	            preparedStatement.setString(5, metodoPagamento.getCvv());
	        }
	        preparedStatement.executeUpdate();
	    } finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			}
		}
	}


// Metodo per verificare se il metodo di pagamento esiste già nel database per un dato utente
private boolean checkMetodoPagamentoEsistente(String userId) throws SQLException {
    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet rs = null;
    boolean metodoEsistente = false;

    try {
        connection = ds.getConnection(); 
        // Query per verificare se esiste già un metodo di pagamento per l'utente
        String query = "SELECT COUNT(*) FROM metodi_pagamento WHERE user_id = ?";
        preparedStatement = connection.prepareStatement(query);
        preparedStatement.setString(1, userId);

        rs = preparedStatement.executeQuery();
        if (rs.next()) {
            int count = rs.getInt(1);
            if (count > 0) {
                metodoEsistente = true;
            }
        }
    } finally{
		try {
			if (preparedStatement != null) preparedStatement.close();
		} finally {
			if (connection != null) connection.close();
		}
	}
    return metodoEsistente;
}

	public List<ProductBean> retrieveProductsByOrderId(int orderId) throws SQLException { //RECUPERA TUTTI I PRODOTTI PRESENTI PER UN DATO ORDINE
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		List<ProductBean> products = new ArrayList<ProductBean>();
		try {
			connection = ds.getConnection();
			String selectSQL = "SELECT p.idprodotto, p.nome, p.descrizione, p.prezzo, p.quantita, p.marca, p.modello_auto, p.immagine " +
			"FROM prodotto p " +
			"JOIN ordine o ON o.idprodotto_ordinato = p.idprodotto " +
			"WHERE o.idordine = ?";
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setInt(1, orderId);
			ResultSet rs = preparedStatement.executeQuery();
			while (rs.next()) {
				ProductBean bean = new ProductBean();
				bean.setId(rs.getInt("idprodotto"));
				bean.setNome(rs.getString("nome"));
				bean.setMarca(rs.getString("marca"));
				bean.setModelloAuto(rs.getString("modello_auto"));
				bean.setDescrizione(rs.getString("descrizione"));
				bean.setPrezzo(rs.getFloat("prezzo"));
				bean.setQuantita(rs.getInt("quantita"));
				//gestione dell'immagine
				byte[] immagine = rs.getBytes("immagine");
           		bean.setImmagine(immagine);
				products.add(bean);
			}
		} finally {
			try {
				if (preparedStatement != null) preparedStatement.close();
			} finally {
				if (connection != null) connection.close();
			}
		}
		return products;
	}

	public List<OrderBean> DoRetrieveAllOrders() throws SQLException { //RECUPERA TUTTI GLI ORDINI DAL DB 
    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet rs = null;
    List<OrderBean> orders = new ArrayList<>();
    Map<String, OrderBean> orderMap = new LinkedHashMap<>(); // Map per gestire gli ordini con più prodotti
    try {
        connection = ds.getConnection();
        String selectSQL = "SELECT o.idordine, o.userid, o.prezzo_ordine, o.indirizzo, o.citta, " +
                "o.provincia, o.cap, o.telefono, o.data_ordine, p.idprodotto, p.nome, p.descrizione, " +
                "p.prezzo, p.quantita, p.marca, p.modello_auto, p.immagine " +
                "FROM " + ProductModelDS.TABLE_NAME3 + " o " +
                "JOIN " + ProductModelDS.TABLE_NAME + " p ON o.idprodotto_ordinato = p.idprodotto " +
                "ORDER BY o.data_ordine DESC";
        preparedStatement = connection.prepareStatement(selectSQL);
        rs = preparedStatement.executeQuery();

        while (rs.next()) {
            String idOrdine = rs.getString("idordine");
            OrderBean orderBean = orderMap.get(idOrdine);

            if (orderBean == null) {
                orderBean = new OrderBean();
                orderBean.setIdordine(rs.getString("idordine"));
                orderBean.setUserid(rs.getString("userid"));
                orderBean.setPrezzoTotale(0);
                orderBean.setIndirizzo(rs.getString("indirizzo"));
                orderBean.setCitta(rs.getString("citta"));
                orderBean.setProvincia(rs.getString("provincia"));
                orderBean.setCap(rs.getString("cap"));
                orderBean.setTelefono(rs.getInt("telefono"));
                orderBean.setDataOrdine(rs.getTimestamp("data_ordine"));
                orderBean.setProdotti(new ArrayList<>()); 
                orderMap.put(idOrdine, orderBean);
            }

            ProductBean productBean = new ProductBean();
            productBean.setId(rs.getInt("idprodotto"));
            productBean.setNome(rs.getString("nome"));
            productBean.setDescrizione(rs.getString("descrizione"));
            productBean.setPrezzo(rs.getFloat("prezzo"));
            productBean.setQuantita(rs.getInt("quantita"));
            productBean.setMarca(rs.getString("marca"));
            productBean.setModelloAuto(rs.getString("modello_auto"));
            productBean.setImmagine(rs.getBytes("immagine"));
            orderBean.getProdotti().add(productBean);
			orderBean.setPrezzoTotale(orderBean.getPrezzoTotale() + productBean.getPrezzo()); // Aggiorna il prezzo totale
			
        }
        orders.addAll(orderMap.values());

    } finally {
        try {
            if (rs != null) rs.close();
            if (preparedStatement != null) preparedStatement.close();
        } finally {
            if (connection != null) connection.close();
        }
    }
    return orders;
	}

	public List<OrderBean> DoRetrieveOrdersByDate(Timestamp startDate, Timestamp endDate) throws SQLException { //RECUPERA TUTTI GLI ORDIIN DA UNA DATA A UNA DATA
	    Connection connection = null;
	    PreparedStatement preparedStatement = null;
	    ResultSet rs = null;
	    List<OrderBean> orders = new ArrayList<>();
	    Map<String, OrderBean> orderMap = new LinkedHashMap<>();

	    try {
	        connection = ds.getConnection();
	        String selectSQL = "SELECT o.idordine, o.userid, o.prezzo_ordine, o.indirizzo, o.citta, " +
	                "o.provincia, o.cap, o.telefono, o.data_ordine, p.idprodotto, p.nome, p.descrizione, " +
	                "p.prezzo, p.quantita, p.marca, p.modello_auto, p.immagine " +
	                "FROM " + ProductModelDS.TABLE_NAME3 + " o " +
	                "JOIN " + ProductModelDS.TABLE_NAME + " p ON o.idprodotto_ordinato = p.idprodotto " +
	                "WHERE o.data_ordine BETWEEN ? AND ? " +
	                "ORDER BY o.data_ordine DESC";
	        preparedStatement = connection.prepareStatement(selectSQL);
	        preparedStatement.setTimestamp(1, startDate);
	        preparedStatement.setTimestamp(2, endDate);
	        rs = preparedStatement.executeQuery();

	        while (rs.next()) {
	            String idOrdine = rs.getString("idordine");
	            OrderBean orderBean = orderMap.get(idOrdine);

	            if (orderBean == null) {
	                orderBean = new OrderBean();
	                orderBean.setIdordine(rs.getString("idordine"));
	                orderBean.setUserid(rs.getString("userid"));
	                orderBean.setPrezzoTotale(0);
	                orderBean.setIndirizzo(rs.getString("indirizzo"));
	                orderBean.setCitta(rs.getString("citta"));
	                orderBean.setProvincia(rs.getString("provincia"));
	                orderBean.setCap(rs.getString("cap"));
	                orderBean.setTelefono(rs.getInt("telefono"));
	                orderBean.setDataOrdine(rs.getTimestamp("data_ordine"));
	                orderBean.setProdotti(new ArrayList<>());
	                orderMap.put(idOrdine, orderBean);
	            }

	            ProductBean productBean = new ProductBean();
	            productBean.setId(rs.getInt("idprodotto"));
	            productBean.setNome(rs.getString("nome"));
	            productBean.setDescrizione(rs.getString("descrizione"));
	            productBean.setPrezzo(rs.getFloat("prezzo"));
	            productBean.setQuantita(rs.getInt("quantita"));
	            productBean.setMarca(rs.getString("marca"));
	            productBean.setModelloAuto(rs.getString("modello_auto"));
	            productBean.setImmagine(rs.getBytes("immagine"));

	            orderBean.getProdotti().add(productBean);
				orderBean.setPrezzoTotale(orderBean.getPrezzoTotale() + productBean.getPrezzo()); // Aggiorna il prezzo totale
	        }
	        orders.addAll(orderMap.values());

	    } finally {
	        try {
	            if (rs != null) rs.close();
	            if (preparedStatement != null) preparedStatement.close();
	        } finally {
	            if (connection != null) connection.close();
	        }
	    }
	    return orders;
	}

	public List<ProductBean> getSuggestions(String query) throws SQLException { //RECUPERA SUGGERIMENTI PER LA RICERCA CON AJAX
    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet rs = null;

    List<ProductBean> suggestions = new ArrayList<>();
    String sql = "SELECT idprodotto, nome FROM prodotto WHERE nome LIKE ? LIMIT 10";

    try {
        connection = ds.getConnection();
        preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setString(1, query + "%");

        rs = preparedStatement.executeQuery();
        while (rs.next()) {
            ProductBean product = new ProductBean();
            product.setId(rs.getInt("idprodotto"));
            product.setNome(rs.getString("nome"));
            suggestions.add(product);
        }
    } finally {
        try {
            if (rs != null) rs.close();
            if (preparedStatement != null) preparedStatement.close();
        } finally {
            if (connection != null) connection.close();
        }
    }
    
    return suggestions;
}

	public OrderBean retrieveOrderById(int orderId) throws SQLException {
	    Connection connection = null;
	    PreparedStatement preparedStatement = null;
	    ResultSet rs = null;
	    OrderBean orderBean = null;

	    try {
	        connection = ds.getConnection();
	        String selectSQL = "SELECT o.idordine, o.userid, o.prezzo_ordine, o.indirizzo, o.citta, " +
	                "o.provincia, o.cap, o.telefono, o.data_ordine, " +
	                "p.idprodotto, p.nome, p.descrizione, p.prezzo, p.quantita, p.marca, p.modello_auto, p.immagine " +
	                "FROM ordine o " +
	                "JOIN prodotto p ON o.idprodotto_ordinato = p.idprodotto " +
	                "WHERE o.idordine = ?";
	        preparedStatement = connection.prepareStatement(selectSQL);
	        preparedStatement.setInt(1, orderId);
	        rs = preparedStatement.executeQuery();

	        Map<String, OrderBean> orderMap = new LinkedHashMap<>();

	        while (rs.next()) {
	            String idOrdine = rs.getString("idordine");
	            OrderBean order = orderMap.get(idOrdine);

	            if (order == null) {
	                order = new OrderBean();
	                order.setIdordine(rs.getString("idordine"));
	                order.setUserid(rs.getString("userid"));
	                order.setPrezzoTotale(0); // Inizializza il prezzo totale a zero
	                order.setIndirizzo(rs.getString("indirizzo"));
	                order.setCitta(rs.getString("citta"));
	                order.setProvincia(rs.getString("provincia"));
	                order.setCap(rs.getString("cap"));
	                order.setTelefono(rs.getInt("telefono"));
	                order.setDataOrdine(rs.getTimestamp("data_ordine"));
	                order.setProdotti(new ArrayList<>());
	                orderMap.put(idOrdine, order);
	            }

	            ProductBean product = new ProductBean();
	            product.setId(rs.getInt("idprodotto"));
	            product.setNome(rs.getString("nome"));
	            product.setDescrizione(rs.getString("descrizione"));
	            product.setPrezzo(rs.getFloat("prezzo"));
	            product.setQuantita(rs.getInt("quantita"));
	            product.setMarca(rs.getString("marca"));
	            product.setModelloAuto(rs.getString("modello_auto"));
	            product.setImmagine(rs.getBytes("immagine"));

	            order.getProdotti().add(product);
	            order.setPrezzoTotale(order.getPrezzoTotale() + product.getPrezzo()); // Aggiorna il prezzo totale dell'ordine
	        }

	        // Se l'ordine è stato trovato, restituisci il primo elemento della mappa (dovrebbe essercene solo uno)
	        if (!orderMap.isEmpty()) {
	            orderBean = orderMap.values().iterator().next();
	        }

	    } finally {
	        try {
	            if (rs != null) rs.close();
	            if (preparedStatement != null) preparedStatement.close();
	        } finally {
	            if (connection != null) connection.close();
	        }
	    }

	    return orderBean;
	}
}

