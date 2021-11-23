@isTest
public class AttributeTest {
    public String name;
    public String value;
    public Boolean isLineItem;
    public Decimal price;
    
    public AttributeTest(String n, String v, Boolean isLI, Decimal p) {
        name =  n;
        value = v;
        isLineItem = isLI;
        price = p; 
    }

}