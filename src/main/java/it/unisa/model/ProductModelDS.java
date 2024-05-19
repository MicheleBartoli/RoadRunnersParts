package it.unisa.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class ProductModelDS implements ProductModel {

	private static DataSource ds;

	static {
		try {
			Context initCtx = new InitialContext();
			Context envCtx = (Context) initCtx.lookup("java:comp/env");

			ds = (DataSource) envCtx.lookup("jdbc/RoadRunnerParts,");

		} catch (NamingException e) {
			System.out.println("Error:" + e.getMessage());
		}
	}

	private static final String TABLE_NAME = "prodotto";
	private static final String TABLE_NAME2 = "utente";

	@Override
	public synchronized void doSave(ProductBean prodotto) throws SQLException {

		Connection connection = null;
		PreparedStatement preparedStatement = null;

		String insertSQL = "INSERT INTO " + ProductModelDS.TABLE_NAME
				+ " (ID, NOME, DESCRIZIONE, PREZZO, QUANTITA, MARCA, MODELLO_AUTO) VALUES (NULL, ?, ?, ?, ?, ?, ?)";

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

			preparedStatement.executeUpdate();

			connection.commit();
		} finally {
			try {
				if (preparedStatement != null)
					preparedStatement.close();
			} finally {
				if (connection != null)
					connection.setAutoCommit(true);
					connection.close();
			}
		}
	}

	@Override
	public synchronized void doSaveUser(UserBean user) throws SQLException{

		Connection connection = null;
		PreparedStatement preparedStatement = null;

		String insertSQL = "INSERT INTO" + ProductModelDS.TABLE_NAME2 + "(userid, tipo, password_hash) VALUES (?, ?, ?)";

		try{
			connection = ds.getConnection();
			connection.setAutoCommit(false);
 
			preparedStatement = connection.prepareStatement(insertSQL);
			preparedStatement.setString(1,user.getUserid());
			preparedStatement.setString(2,user.getTipo());
			preparedStatement.setString(3,user.getPasswordHash());

			preparedStatement.executeUpdate();
			connection.commit();
		}finally{
			try{
				if(preparedStatement != null)
					preparedStatement.close();
			}finally{
				if(connection != null){
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	@Override
	public synchronized void DoSaveOrder(String userid, CartBean cart) throws SQLException{

		Connection connection = null;
		PreparedStatement preparedStatement = null;

		String insertSQL = "INSERT INTO ordine (userid, idprodotto_ordinato, prezzo_ordine, indirizzo, citta, provincia,cap) VALUES (?,?,?,?,?,?,?,?)";
		String updateQuantitySQL = "UPDATE prodotto SET quantita = quantita -1 WHERE id = ?";
		String selectUserSQL = "SELECT indirizzo, citta, provincia, cap FROM utente Where userid = ?";

		try {
			connection = ds.getConnection();
			connection.setAutoCommit(false);

			preparedStatement = connection.prepareStatement(selectUserSQL);
			preparedStatement.setString(1,userid);

			ResultSet rs = preparedStatement.executeQuery();
			String indirizzo = "", citta = "", provincia ="", cap = "";
			if(rs.next()){
				indirizzo = rs.getString("indirizzo");
				citta = rs.getString("citta");
				provincia = rs.getString("provincia");
				cap = rs.getString("cap");
			}

			for (ProductBean product : cart.getProducts()){
				preparedStatement = connection.prepareStatement(insertSQL);

				preparedStatement.setString(1, userid);
				preparedStatement.setInt(2,product.getId());
				preparedStatement.setFloat(3, product.getPrezzo());
				preparedStatement.setString(4,indirizzo);
				preparedStatement.setString(5, citta);
				preparedStatement.setString(6,provincia);
				preparedStatement.setString(7,cap);

				preparedStatement.executeUpdate();

			}

			connection.commit();
		}finally{
			try {
				if (preparedStatement != null){
					preparedStatement.close();
				}
			} finally {
				if (connection != null) {
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	public synchronized void doChange(ProductBean prodotto) throws SQLException{
		Connection connection = null;
		PreparedStatement preparedStatement = null;

		String updateSQL = "UPDATE" + ProductModelDS.TABLE_NAME + "SET NOME = ?, DESCRIZIONE = ?, PREZZO = ?, QUANTITA = ?, MARCA = ?, MODELLO = ? WHERE ID = ?";

		try{
			connection = ds.getConnection();
			connection.setAutoCommit(false);

			preparedStatement = connection.prepareStatement(updateSQL);
			preparedStatement.setString(1, prodotto.getNome());
			preparedStatement.setString(2, prodotto.getDescrizione());
			preparedStatement.setFloat(3,prodotto.getPrezzo());
			preparedStatement.setInt(4, prodotto.getQuantita());
			preparedStatement.setString(5,prodotto.getMarca());
			preparedStatement.setString(6,prodotto.getModelloAuto());
			preparedStatement.setInt(7,prodotto.getId());

			preparedStatement.executeUpdate();

			connection.commit();
		}finally{
			try{
				if(preparedStatement != null){
					preparedStatement.close();
				}
			}finally{
				if(connection != null){
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	public synchronized void doChangeUserLocation(UserBean utente) throws SQLException{
		Connection connection = null;
		PreparedStatement preparedStatement = null;

		String updateSQL = "UPDATE" + ProductModelDS.TABLE_NAME2 + "SET indirizzo = ?, citta = ?, provincia = ?, cap = ? WHERE userid = ?";

		try{
			connection = ds.getConnection();
			connection.setAutoCommit(false);

			preparedStatement = connection.prepareStatement(updateSQL);
			preparedStatement.setString(1, utente.getIndirizzo());
			preparedStatement.setString(2, utente.getCitta());
			preparedStatement.setString(3, utente.getProvincia());
			preparedStatement.setString(4, utente.getCap());
			preparedStatement.setString(5, utente.getUserid());

			preparedStatement.executeUpdate();
			connection.commit();
		}finally{
			try{
				if(preparedStatement != null){
					preparedStatement.close();
				}
			}finally{
				if(connection != null){
					connection.setAutoCommit(true);
					connection.close();
				}
			}
		}
	}

	@Override
	public synchronized ProductBean doRetrieveByKey(int id) throws SQLException {
		Connection connection = null;
		PreparedStatement preparedStatement = null;

		ProductBean bean = new ProductBean();

		String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME + " WHERE ID = ?";

		try {
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setInt(1, id);

			ResultSet rs = preparedStatement.executeQuery();

			while (rs.next()) {
				bean.setId(rs.getInt("ID"));
				bean.setNome(rs.getString("NOME"));
				bean.setDescrizione(rs.getString("DESCRIZIONE"));
				bean.setPrezzo(rs.getInt("PREZZO"));
				bean.setQuantita(rs.getInt("QUANTITA"));
				bean.setMarca(rs.getString("MARCA"));
				bean.setModelloAuto(rs.getString("MODELLO AUTO"));
			}

		} finally {
			try {
				if (preparedStatement != null)
					preparedStatement.close();
			} finally {
				if (connection != null)
					connection.close();
			}
		}
		return bean;
	}


	@Override
	public UserBean doRetrieveByKeyUser(String userid) throws SQLException{
		Connection connection = null;
		PreparedStatement preparedStatement = null;

		String selectSQL = "SELECT * FROM utente HERE userid = ?";

		try{
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setString(1,userid);

			ResultSet rs = preparedStatement.executeQuery();

			if (rs.next()){
				UserBean bean = new UserBean();
				bean.setUserid(rs.getString("userid"));
				bean.setTipo(rs.getString("tipo"));
				bean.setPasswordHash(rs.getString("password_hash"));
				bean.setIndirizzo(rs.getString("indirizzo"));
				bean.setCitta(rs.getString("citta"));
				bean.setProvincia(rs.getString("provincia"));
				bean.setCap(rs.getString("cap"));
				return bean;
			}
		}finally{
			try{
				if(preparedStatement != null){
					preparedStatement.close();
				}
			}finally{
				if(connection != null){
					connection.close();
				}
			}
		}
		return null;
	}

	@Override
	public List <OrderBean> doRetrieveByUserId(String userid) throws SQLException{
		Connection connection = null;
		PreparedStatement preparedStatement = null;

		String selectSQL = "SELECT o.idordine, o.userid, o.prezzo_ordine, o.indirizzo, o.citta, o.provincia, o.cap, p.nome nome_prodotto, p.prezzo AS prezzo_prodotto, p.descrizione AS descrizione_prodotto" + 
 		"FROM ordine o " + 
		"JOIN prodotto p ON o.idprodotto_ordinato = p.idprodotto" + 
 		"WHERE o.userid = ?";

		List <OrderBean> orders = new ArrayList<OrderBean>();

		try{
			connection = ds.getConnection();
			preparedStatement = connection. prepareStatement(selectSQL);
			preparedStatement.setString(1,userid);

			ResultSet rs = preparedStatement.executeQuery();

			while(rs.next()){
				OrderBean bean = new OrderBean();

				bean.setIdordine(rs.getInt("idordine"));
				bean.setUserid(rs.getString("userid"));
				bean.setIDProdottoOrdinato(rs.getInt("idprodotto_ordinato"));
				bean.setPrezzo(rs.getFloat("prezzo"));
				bean.setIndirizzo(rs.getString("indirizzo"));
				bean.setCitta(rs.getString("citta"));
				bean.setProvincia(rs.getString("provincia"));
				bean.setCap(rs.getString("cap"));

				orders.add(bean);
			}		
		}finally{
			try{
				if(preparedStatement != null){
					preparedStatement.close();
				}
			}finally{
				if(connection != null){
					connection.close();
				}
			}
			
		}
		return orders;
	}

	@Override   //controlla se un determianto utente esiste nel db e se la password è corretta 
	public UserBean doCheckUser(String userid, String password) throws SQLException{
		Connection connection = null;
		PreparedStatement preparedStatement= null;

		String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME2 + " WHERE userid = ? AND password_hash = ?";

		try{
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setString(1,userid);
			preparedStatement.setString(2,password);

			ResultSet rs = preparedStatement.executeQuery();

			if(rs.next()){
				UserBean bean = new UserBean();
				bean.setUserid(rs.getString("userid"));
				bean.setTipo(rs.getString("tipo"));
				bean.setPasswordHash(rs.getString("password_hash"));
				bean.setIndirizzo(rs.getString("indirizzo"));
				bean.setCitta(rs.getString("citta"));
				bean.setProvincia(rs.getString("provincia"));
				bean.setCap(rs.getString("cap"));
				bean.setTelefono(rs.getInt("telefono"));
				bean.setEmail(rs.getString("email"));
			}
		}finally{
			try{
				if(preparedStatement != null){
					preparedStatement.close();
				}
			}finally{
				if(connection != null){
					connection.close();
				}
			}
		}
		return null;
	}

	@Override
	public synchronized boolean doDelete(int idprodotto) throws SQLException {
		Connection connection = null;
		PreparedStatement preparedStatement = null;

		int result = 0;

		String deleteSQL = "DELETE FROM " + ProductModelDS.TABLE_NAME + " WHERE ID = ?";

		try {
			connection = ds.getConnection();
			preparedStatement = connection.prepareStatement(deleteSQL);
			preparedStatement.setInt(1, idprodotto);

			result = preparedStatement.executeUpdate();

		} finally {
			try {
				if (preparedStatement != null)
					preparedStatement.close();
			} finally {
				if (connection != null)
					connection.close();
			}
		}
		return (result != 0);
	}

	@Override
	public synchronized Collection<ProductBean> doRetrieveAll(String order) throws SQLException {
		Connection connection = null;
		PreparedStatement preparedStatement = null;

		Collection<ProductBean> products = new LinkedList<ProductBean>();

		String selectSQL = "SELECT * FROM " + ProductModelDS.TABLE_NAME;

		if (order != null && !order.equals(" ")) {
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
				bean.setPrezzo(rs.getInt("prezzo"));
				bean.setQuantita(rs.getInt("quantita"));
				bean.setMarca(rs.getString("marca"));
				bean.setModelloAuto(rs.getString("modello_auto"));
				products.add(bean);
			}

		} finally {
			try {
				if (preparedStatement != null)
					preparedStatement.close();
			} finally {
				if (connection != null)
					connection.close();
			}
		}
		return products;
	}

	//recuperare ricambi per marca e modello 
	public Collection<ProductBean> getProductsByBrandAndModel(String marca, String modello_auto) throws SQLException {
		Connection connection = null;
		PreparedStatement preparedStatement = null;
		Collection<ProductBean> products = new LinkedList<ProductBean>();
	
		try {
			connection = ds.getConnection();
			String selectSQL = "SELECT * FROM prodotto WHERE marca = ? AND modello = ?";
			preparedStatement = connection.prepareStatement(selectSQL);
			preparedStatement.setString(1, marca);
			preparedStatement.setString(2, modello_auto);
	
			ResultSet rs = preparedStatement.executeQuery();
	
			while (rs.next()) {
				ProductBean bean = new ProductBean();
				bean.setId(rs.getInt("id"));
				bean.setNome(rs.getString("nome"));
				bean.setMarca(rs.getString("marca"));
				bean.setModelloAuto(rs.getString("modello"));
				bean.setDescrizione(rs.getString("descrizione"));
				bean.setPrezzo(rs.getFloat("prezzo"));
				bean.setQuantita(rs.getInt("quantita"));
	
				products.add(bean);
			}
		} finally {
			try {
				if (preparedStatement != null)
					preparedStatement.close();
			} finally {
				if (connection != null)
					connection.close();
			}
		}
		return products;
	}

	@Override
	public void doSaveOrder(String userid, CartBean cart) throws SQLException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<OrderBean> doRetrieveByUserid(String userid) throws SQLException {
		// TODO Auto-generated method stub
		return null;
	}
	
}