@isTest
public class ConversionUtilsTest {
    
    static testMethod void testStringToBoolean() {
    	System.assertEquals(true, ConversionUtils.stringtoBoolean('Y'));
        System.assertEquals(true, ConversionUtils.stringtoBoolean('true'));
        System.assertEquals(false, ConversionUtils.stringtoBoolean('N'));
        System.assertEquals(false, ConversionUtils.stringtoBoolean('false'));
    }
    
    static testMethod void testBooleanToString() {
    	System.assertEquals('Y', ConversionUtils.booleanToString(true));
        System.assertEquals('N', ConversionUtils.booleanToString(false));
    }
    
    static testMethod void testToUSDateFormat() {
    	System.assertEquals('04-11-2016', ConversionUtils.toUSDateFormat('2016-04-11')); 
        System.assertEquals('', ConversionUtils.toUSDateFormat(''));
    }
}