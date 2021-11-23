/*************************************************************************************************************************
 @Name: APTPS_CommonUtilities
 @Author: Shishir Bose
 @Created Date: 05/11/2016
 @Descripton: This class conatins common utilities for the application
*************************************************************************************************************************/
public class APTPS_CommonUtilities {
    
    /*************************************************************************************************************************
     @Name: GetStringFromDate
     @Author: Shishir Bose
     @Created Date: 05/10/2016
     @Descripton: This method returns string format for a date input 
    *************************************************************************************************************************/
    public static string GetStringFromDate(date inputdate, string formatString)
    {
        datetime tempDateTime;
        string outputDateString;
        
        if(inputdate != null)
        {
            tempDateTime = datetime.newInstance(inputdate.Year(),inputdate.month(),inputdate.day());
            outputDateString = tempDateTime.format(formatString);
        }
        else
        {
            outputDateString = '';
        }
        
        return outputDateString;
    }

    /*************************************************************************************************************************
     @Name: GetStringFromDate
     @Author: Shishir Bose
     @Created Date: 05/10/2016
     @Descripton: This method returns string format for a datetime input
    *************************************************************************************************************************/
   public static string GetStringFromDateTime(datetime inputdate, string formatString)
    {
        string outputDateString;
        
        if(inputdate != null)
        {
           outputDateString = inputdate.format(formatString);
        }
        else
        {
            outputDateString = '';
        }
        
        return outputDateString;
    }
    
    /*************************************************************************************************************************
     @Name: setStringToDateFormat
     @Author: Shishir Bose
     @Created Date: 04/28/2016
     @Descripton: This method converts string to date
    *************************************************************************************************************************/    
    public static Date setStringToDateFormat(String myDate) 
    {
       String[] myDateOnly = myDate.split(' ');
       String[] strDate = myDateOnly[0].split('/');
       Integer myIntDate = integer.valueOf(strDate[0]);
       Integer myIntMonth = integer.valueOf(strDate[1]);
       Integer myIntYear = integer.valueOf(strDate[2]);
       Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
       return d;
    }
    
     /*************************************************************************************************************************
 @Name: getAgreementData
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This method is used for getting all the field of agreement object
*************************************************************************************************************************/
    public static Apttus__APTS_Agreement__c getAgreementData(Id agreementId)
    {
        // Initialize setup variables
        String objectName = 'Apttus__APTS_Agreement__c';  
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
        }
        
       
        
        query = query.subString(0,query.Length()-2);
        // Add FROM statement
        query += ',RecordType.Name FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        
        string condition = 
        query += ' WHERE Id = \'';
        
        query += agreementId;
        
        query += '\'';
        
         
          Apttus__APTS_Agreement__c agreement = database.query(query);
                return agreement;
        
    } 
     /*************************************************************************************************************************
     @Name: checkPickListValue
     @Author: Shishir Bose
     @Created Date: 06/01/2016
     @Descripton: This method checks whether a string exist in picklist or not
    *************************************************************************************************************************/
   /* public static boolean checkPickListValue(string objectName, string pickListName, string valuetoBeCompared)
    {
        boolean doesValueExist = false;
        //Get the object 
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap(); 
        
        Set<String> fieldSet = fields.keySet();
DescribeFieldResult selectedField;

//Iterate through all the fields of object and break look when the correct object is received
        for(String s:fieldSet)
        {
            SObjectField fieldToken = fields.get(s);
            selectedField = fieldToken.getDescribe();
            if(selectedField.getName() == pickListName)
            {
                break;
            }            
        }

       //Get the picklist data for the field
        List<Schema.PicklistEntry> ple = selectedField.getPicklistValues();
        
        //Iterate through picklist values and return true if value exists
        for(Schema.PicklistEntry pl : ple)
        {
            if(valuetoBeCompared == pl.Value)
            {
                doesValueExist = true;
                break;
            }               
                
        }        
        return doesValueExist;
    }*/

}