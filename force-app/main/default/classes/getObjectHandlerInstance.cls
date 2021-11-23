/*
Class Name 	 : getObjectHandlerInstance
Description  : This class will initialize handlerclass dynamically.                
Created By   : ABINASH BARIK
Created On   : 

Change History:
----------------------------------------------------------------------------------------------------------------------
Sr#      Description                     Updated By                         Updated On            EMP ID
----------------------------------------------------------------------------------------------------------------------

*/
public class getObjectHandlerInstance {
    private static ITrigger instance = null;

    public static ITrigger getCurrentObjectHandlerClass(String objectName){
        if(instance == null){
            String customClass=objectName+'_TriggerHandler';
            Type t = Type.forName(customClass);
            instance = (ITrigger)t.newInstance();
        }        
        return instance;
    }
}