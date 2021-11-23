/*
* @Author : Rahul/Ritika
* @Date : 3 April 2019
* @Desc : DTO class for TM1 Eligibility Request for Transition
* @Jira : EDGE-66569 
*/

public class TM1EligibilityCheckRequestDTO{

public String Correlation_ID;
public String Product_Technology_Family_Name;
public String Service_Provider_ID;
public String Match_Type;
public String Effective_Date;
public String Start_Date;
public String End_Date;
public List<Query_Key_WhiteList> Query_Key_White_List=new List<Query_Key_WhiteList>();
public List<Query_Key_BlackList> Query_Key_Black_List= new List<Query_Key_BlackList> ();    
public String Client_ID; 
public String CallBack_URL;

//Inner class for framing number/range to be checked for eligibilty
public class Query_Key_WhiteList{
    public String ID_Catergory;
    public String ID_Type;
    public String ID;
    public String Range_Start;
    public String Range_End;
}

public class Query_Key_BlackList{
    public String ID_Catergory;
    public String ID_Type;
    public String ID;
    public String Range_Start;
    public String Range_End;
}




}