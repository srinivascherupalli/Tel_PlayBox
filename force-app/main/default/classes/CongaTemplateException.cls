/* 
* @Author : Monali 
* @Date : 19/05/2021 
* @Desc : Quote and Contract Exception Handling 
*/
public class CongaTemplateException extends Exception {
 	String errorMessage;
    String codeReference;
    String templateType; // Quote or Contract
  public  CongaTemplateException(String errorMessage, String codeReference ,String templateType) {
	    this.errorMessage = errorMessage;
        this.codeReference = codeReference;
      	this.templateType = templateType;
   }
}