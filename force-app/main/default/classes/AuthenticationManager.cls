/*
  **********************************************************************************************
  * @author       : Resmi Ramakrishnan
  * @date         : 12/12/2016
  * @description  : This class is using to get stored/new OathToken from Platform Cache
  **********************************************************************************************
*/

public class AuthenticationManager
{

  /*
     * @description       This is method is using to get new/stored Oauth Token from AuthenticationService.                       
     * @param             handlerName 
     * @return            String 
     * @throws            NA
  */ 
  public static String getOauthToken( String handlerName ) 
  {
     String retVal;     
     String token = AuthenticationService.retrieveToken( handlerName );     
     if( String.isEmpty(token ))
     {
        token = AuthenticationService.getNewOauthToken( handlerName );
     }   
              
     if( !String.isEmpty(token ))
     {        
        retVal = token ;
     }       
     return retVal;
  }
  
}