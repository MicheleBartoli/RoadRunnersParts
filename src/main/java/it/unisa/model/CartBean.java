package it.unisa.model;

import it.unisa.control.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

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
			total += ((ProductBean) products).getPrezzo();
		}
		return total;
	}

	@Override
	public String toString(){
		return "Cart [products=" + products + "]";
	}
	
}
