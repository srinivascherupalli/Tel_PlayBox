public class ConversionUtils {
	public static Boolean stringtoBoolean(String i) {
        Boolean o;
        if(i == 'true' || i == 'Y'){
            o = true;
        }
        else if(i == 'false' || i == 'N'){
            o = false;
        }
        return o;
    }
    
    public static String booleanToString(Boolean i) {
        String o;
        if(i == true){
            o = 'Y';
        }
        else if(i == false){
            o = 'N';
        }
        return o;
    }
    
    public static String toUSDateFormat(String d){
        if(d != null && d != ''){
        	return d.split('-')[1] +'-'+ d.split('-')[2] +'-'+ d.split('-')[0];    
        }
        return d;    
    }
}