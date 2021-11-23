/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
* @Story : EDGE-34, @Author : Anu Yadav, @Date : 29/11/2017 
*/

public class TCMCustomerContactHelper {
   
  	/**
	 * Description : Utility for formating the number.
	 */    
    public static String formatNumber(String numberformat){
        String formatNumber = numberformat;
        if(formatNumber != null && String.isNotBlank(formatNumber)){
            formatNumber = (formatNumber.contains('+61')) ? formatNumber.replace('+61','') : formatNumber;
			formatNumber = (formatNumber.startsWith('0')) ? formatNumber.replaceFirst('0','') : formatNumber;
            formatNumber = (formatNumber.length()==9) ? '0'+formatNumber : formatNumber;
            return formatNumber;
        }
        return null;
    }
    
    public static String validateField(Boolean value){
        return (value != null && value) ? 'Y' : 'N';
	}
    public String validateStringField(String value, String defaultValue){
        return (value != null && String.isNotBlank(value)) ? value : defaultValue;
    }
    
    public static Date validateDateField(String value){
        return (value != null && String.isNotBlank(value)) ? Date.valueOf(value) : null;
    } 
    public static Date setLastVerifiedDateField(String value){
      Date mydate = Date.today();
      Date newdate = mydate.addDays(-366);
     return newdate;
    } 
    public static boolean validateField(String value){
        return (value != null && value.trim().equalsIgnoreCase('Y')) ? true : false;
    }
    public static boolean isNotNullAndBlank(String value){
        return (value != null && String.isNotBlank(value)) ? true : false;
    }
    public static boolean validateOptInFields(String value){
        return(isNotNullAndBlank(value) && value == 'Y')? false : true;
    }
    public static String validateOptOutFields(Boolean value){
        return(value)? 'N' : 'Y';
    }
    
}