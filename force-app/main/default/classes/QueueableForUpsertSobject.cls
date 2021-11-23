public without sharing class QueueableForUpsertSobject implements Queueable {
      List<Sobject> lstRecords;       
      
      public QueueableForUpsertSobject(List<Sobject> lstRecords) {
          this.lstRecords = lstRecords;                      
      }
      
      public void execute(QueueableContext context) {
	  Logger2 logger = Logger2.getLogger('QueueableForUpsertSobject');
         try{
			  Schema.SObjectType sObjectType = lstRecords.getSObjectType();
			  if (sObjectType != null)
			  {
				  String listType = 'List<' + sObjectType + '>';
				  List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
				  castRecords.addAll(lstRecords);
				  upsert castRecords;
			  }
			}
		  catch(Exception ex){
		  logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
		  logger.exitLogger();
		  
		  }
      }
  }