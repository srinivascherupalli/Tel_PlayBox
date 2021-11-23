/*
* @Author : Ravindran Shanmugam
* @Date : 20 Oct 2019
* @Desc : DTO class for Batch Tramas request
* @Jira : EDGE-92541
*/

public class TramasBatchRequestDTO{

    public list<operationList> operations= new list<operationList >();
    //public String Correlation_ID;
    //public String Service_Provider_ID;    
    
    public class operationList {
        public String type{get;set;}
        public opnProperties properties{get;set;}
    }

    public class opnProperties {
        public list<transitionList> transitions= new list<transitionList>();
       // public String family {get;set;}
       // public list<identifiers> identifierList = new list<identifiers>();
    }

    public class transitionList{
       public trnpropr properties{get;set;}
        //public properties trnProperties{get;set;}
        public String type{get;set;}
        public target target{get;set;}
    }
    
    public class trnpropr {
            public String family {get;set;}
        public list<identifierList > identifiers= new list<identifierList >();
    }

    public class target{
        public String type{get;set;}
    }

    public class identifierList {
        public String identifier{get;set;}
        public list<attributesList> attributes= new list<attributesList>();
    }
    
    public class attributesList{
        public String key{get;set;}
        public String value{get;set;}
    }   
}