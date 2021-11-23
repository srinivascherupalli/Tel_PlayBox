/**
 * Class for billing account validate request.
 */
public class BillingAccountValidateRequestDTO {

	/**
	 * Class for account.
	 */
	public class Account {
		public String ID;
	}

	/**
	 * Class for owner.
	 */
	public class Owner {
		public Account Party;
	}

	public Product Product;

	/**
	 * Class for product.
	 */
	public class Product {
		public Account Account;
		public Owner Owner;
	}


	/**
	 * Parses the provided Json text
	 *
	 * @param      json  The json
	 *
	 * @return     BillingAccountValidateRequestDTO object
	 */
	public static BillingAccountValidateRequestDTO parse(String json) {
		return (BillingAccountValidateRequestDTO) System.JSON.deserialize(json, BillingAccountValidateRequestDTO.class);
	}
}