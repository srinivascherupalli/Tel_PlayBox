/*
    AUTHOR : Vineeth Batreddy
    DESCRIPTION : This class is used to validate the legitimacy of an ACN(Australian Company Number)
*/

public class ACNValidator {
    
    public static Boolean runValidation(String acn) {
        
        if(acn != null && acn != '' && acn.length() == 9){
            Integer total = 0;
            List<Integer> acnDigits = new List<Integer>();
            
            Integer weighting = 8;
            for(Integer i=0; i<acn.length()-1; i++){
                Integer digit = System.Integer.valueOf(acn.substring(i, i+1));
                acnDigits.add(digit);
                total = total + acnDigits[i]*weighting;
                weighting--;
            }
            
            Integer modulus = System.Math.mod(total,10); 
            
            Integer complement = 10-modulus;
            if(complement==10){complement=0;}
            
            if(complement == Integer.valueOf(acn.substring(acn.length()-1))){
                return true;
            }else{
                return false;
            }
        }
        else {
            return false;
        }
    }
	
}