package it.unisa.model;
import java.sql.SQLException;
import java.util.Collection;
import java.util.List;

public interface ProductModel {
	public void doSave(ProductBean prodotto) throws SQLException;

	public void doSaveUser(UserBean user) throws SQLException;

	public void doSaveOrder(String userid, CartBean cart) throws SQLException;

	public boolean doDelete(int code) throws SQLException;

	public ProductBean doRetrieveByKey(int code) throws SQLException;

	public UserBean doRetrieveByKeyUser(String userid) throws SQLException;

	public List<OrderBean> doRetrieveByUserid(String userid) throws SQLException;
	
	public UserBean doCheckUser(String userid, String password) throws SQLException;
	
	public Collection<ProductBean> doRetrieveAll(String order) throws SQLException;
	
	public List <OrderBean> doRetrieveByUserId(String userid) throws SQLException;
	
}
