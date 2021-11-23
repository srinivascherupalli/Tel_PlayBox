/*
* @Author : Rahul Asarma
* @Date : 06 Oct 2019
* @Desc : DTO class for Batch Tramas Execution Request
* @Jira :  EDGE-92541 
*/

public class TramasExecutionRequestDTO{

public string transitionId{get;set;}
public list<resourceidlist> resourceIds = new list<resourceidlist>();
public string action{get;set;}
public string mode{get;set;}
public mtd metadata{get;set;}

public class resourceidlist{
}

public class mtd {
 public string salesforceId{get;set;}
}

}