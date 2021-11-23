/* 
* @Author : Monali 
* @Date : 19/05/2021 
* @Desc :Test Class for CongaTemplateException 
*/
@isTest 
public class CongaTemplateExceptionTest {
    @isTest  static void getPlansTest() {   
		String e = 'Exception occured while executing code';
		String cnmn = 'Class :: Method'; 
        String tType = 'Q';
		CongaTemplateException c = new CongaTemplateException(e,cnmn,tType); 
    }
}