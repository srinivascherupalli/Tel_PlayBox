/***********************************************************************************************************
Class Name : NumberInventoryRequest
Description : wrapper class to handle rest api request
Created By : Team Apple, Puneeth Kamath
Created On : 27 April 2021
User Story : EDGE-214743
************************************************************************************************************/
global class NumberInventoryRequest
{
    public String networkServiceId {set;get;}
    public String actionType {set;get;}
    public String reason {set; get;}
    public List<numbers> numbers{set;get;}
    
    public class numbers {
        public list<String> singleNumbers {set;get;}
        public list<ranges> ranges {set;get;}
    }
    public class ranges {
        public String startNumber{set;get;}
        public String endNumber{set;get;}
    }
}