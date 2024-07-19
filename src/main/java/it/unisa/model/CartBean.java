package it.unisa.model;

import it.unisa.control.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.mysql.cj.x.protobuf.MysqlxDatatypes.Scalar.String;

public class CartBean {

	private List <ProductBean> products;
	
	public CartBean() {
		products = new ArrayList<ProductBean>();
	}

	public List <ProductBean> getProducts(){
		return products;
	}

	public void setProducts(List<ProductBean> products){
		this.products = products;
	}
	
	public void addProduct(ProductBean product) {
		this.products.add(product);
	}

	public void removeProduct(ProductBean product){
		this.products.remove(product);
	}

	public float getPrezzoTotale(){
		float total = 0;
		for (ProductBean product : products){
			total += ((ProductBean) product).getPrezzo();
		}
		return total;
	}

	 public ProductBean getProductById(int productId) {
        for (ProductBean product : products) {
            if (product.getId() == productId) {
                return product;
            }
        }
        return null; // Restituisce null se il prodotto non viene trovato
    }

}
