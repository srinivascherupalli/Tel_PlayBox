/*
  **********************************************************************************************
  * @author       : Resmi Ramakrishnan
  * @date         : 12/12/2016
  * @description  : This class is using to get OathToken and store this to Platform Cache
  **********************************************************************************************
*/

public class AuthenticationService
{ 
  
  /*
      * @description       This is method is using to get new Oauth Token from Authentication Provider.                       
      * @param             handlerName 
      * @return            String 
      * @throws            NA
  */
  public static String getNewOauthToken(String handlerName) 
  { 
     String retVal;
     
     String envExpiryTime = EnvironmentVariable.get('PlatformCache_Expiry_Time');
     Integer expiryTime =  ( envExpiryTime != null && envExpiryTime != '') ? integer.valueof(envExpiryTime ) : Cache.Org.MAX_TTL_SECS;
               
     String token = OauthLogin.getToken(handlerName);
     
     if( !String.isEmpty(token ) && ! OauthLogin.isMock(handlerName)) 
     {       
         storeToken( handlerName, token, expiryTime );
     }     
     return token; 
  }
  
  
  /*
      * @description       This is method is using to store Oauth Token to Platform Cache.                      
      * @param             token_i, expiryTime_i
      * @return            void 
      * @throws            NA
  */
  public static void storeToken( String handlerName, String token_i, Integer expiryTime_i )
  {           
    Cache.Org.put( handlerName, token_i, expiryTime_i );           
  }
  
  
  /*
      * @description       This is method is using to get stored Oauth Token from Platform Cache.                      
      * @param             NA
      * @return            String
      * @throws            NA
  */
  public static string retrieveToken( String handlerName )
  {
     String retVal;         
     if ( Cache.Org.contains( handlerName )) 
     {
       String storedToken = (String)Cache.Org.get( handlerName );       
       if( !String.isEmpty(storedToken ))
       {
          retVal = storedToken ;
       }       
     }    
     return retVal; 
  }
}