/*
    AUTHOR : Vineeth Batreddy
    DESCRIPTION : This class is used to validate the legitimacy of an ABN(Australian Business Number)
*/

public class ABNValidator {

    public static Boolean runValidation(String abn) {
        
        if(abn != null && abn != '' && abn.length() == 11){
            Integer total = 0;
            List<Integer> abnDigits = new List<Integer>();
            List<Integer> weighting = new List<Integer>();

            weighting.add(10);
            weighting.add(1);
            weighting.add(3);
            weighting.add(5);
            weighting.add(7);
            weighting.add(9);
            weighting.add(11);
            weighting.add(13);
            weighting.add(15);
            weighting.add(17);
            weighting.add(19);

            for(Integer i=0; i<abn.length(); i++){
                Integer digit = System.Integer.valueOf(abn.substring(i, i+1));
                if(i==0){digit = digit-1;}
                abnDigits.add(digit);
                total = total + abnDigits[i]*weighting[i];
            }
            
            Integer modulus = System.Math.mod(total,89);  
            if(modulus==0){
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