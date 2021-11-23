/*
	Author: Dunna, Uday Kumar
	Date: 14/09/2021
*/
public class ManageOrderNotificationUtil {

	public class NotificationAttributesDataObject{
	  public List<NotificationAttributes> attributes;
	}
	  
	  public class NotificationAttributes{
	  public String name {get; set;}
	  public String value {get; set;}
	}
  
	  public static NotificationAttributesDataObject parseAttributes(String json) {
		  system.debug('json >'+json);
	  return (NotificationAttributesDataObject) System.JSON.deserialize(json, NotificationAttributesDataObject.class);
	}
  
	public static Product parse(String json) {
	  Productupdate prd =  (Productupdate) System.JSON.deserialize(json, Productupdate.class);
	  return prd.product;
	}
  
	public class ChildProduct {
	  public String productId {get; set;}
	  public String status {get; set;}
	  public List<NotificationAttributes> attributes {get; set;}
	}
  
	public class Productupdate{
	  public Product product;
	}
	public class Product {
	  public String productId {get; set;}
	  public String status {get; set;}
	  public List<NotificationAttributes> attributes {get; set;}
	  public List<ChildProduct> childProduct {get; set;}
	}
  
	public class SubsDetails {
	  public String responseCode {get; set;}
	  public String responsesDescription {get; set;}
	  public String subscriptionId {get; set;}
	}
  
	public class SubsDetailsDataObject{
	  public List<SubsDetails> listOfSubsDetails;
	}
  
	public static List<SubsDetails> parseSubsDetails(String json) {
	  System.debug('parseSubsDetails..'+json);
	  return (List<SubsDetails>) System.JSON.deserialize(json, List<SubsDetails>.class);
	}
  
	public class Parameters {
	  public String orderIdc {get; set;}
	  public String notifyAttributes {get; set;}
	  public String orderItemDetails {get; set;}
	  public String eventType {get; set;}
	  public String subscriptionDetails {get; set;}
	}
  
  }