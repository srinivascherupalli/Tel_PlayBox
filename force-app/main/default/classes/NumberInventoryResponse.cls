/***********************************************************************************************************
Class Name : NumberInventoryRequest
Description : wrapper class to handle rest api request
Created By : Team Apple, Puneeth Kamath
Created On : 27 April 2021
User Story : EDGE-214743
************************************************************************************************************/

global class NumberInventoryResponse
{
    public String code {set;get;}
    public String status {set;get;}
    public String message {set;get;}
    public List<errors> errors{set;get;}
    
    
    public class errors {
        public String failure {set;get;}
        public String value {set;get;}
        public String message {set;get;}

    }
}