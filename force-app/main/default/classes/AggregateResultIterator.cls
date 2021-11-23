global Without sharing class AggregateResultIterator implements Iterator<AggregateResult>, Iterable<AggregateResult>
{
	
   @testVisible private List<AggregateResult> results {get;set;}
   // tracks which result item is returned
   Integer index {get; set;} 
         
   global AggregateResultIterator() {
      index = 0;
	  // Fire query here to load the results
      String query = 'Select Layout__c From Profile_Layout__c group by Layout__c';
      results = Database.query(query);            
   } 
   
   global boolean hasNext(){ 
      return results != null && !results.isEmpty() && index < results.size(); 
   }    
   
   global AggregateResult next(){        
      return results.get(index++);            
   }
    
   global Iterator<AggregateResult> Iterator(){
      return this;
   }
}