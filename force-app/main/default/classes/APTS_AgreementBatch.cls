/*************************************************************************************************************************
@Name: APTS_AgreementBatch
@Author: Apttus team
@Created Date: 05/21/2020
@Descripton: Rolling status functionality.
*************************************************************************************************************************/
global Without sharing class APTS_AgreementBatch implements Database.Batchable <Sobject> 
{
    List <Apttus__APTS_Agreement__c> agreelist = new list<Apttus__APTS_Agreement__c>();
    public Decimal renewmonth;
     Date tempDate = Date.valueOf(System.today());
       Date tempDateoflastday = Date.valueOf(System.today()-1);
       global Database.QueryLocator start(Database.BatchableContext BC){
    
    
    List<String> status= new List<String>{'Rolling','Activated'}; 
    string query='select Id,Name,Apttus__Status__c,Apttus__Auto_Renewal__c,Apttus__Auto_Renew_Term_Months__c,Apttus__Contract_End_Date__c,APTPS_Effective_End_Date_For_Min_Spend__c,Apttus__Term_Months__c,Apttus__Activated_Date__c,APTPS_Effective_End_Date__c from Apttus__APTS_Agreement__c where Apttus__Status__c IN: status ';
    
    System.debug('Checking the list of agreemnet ....' + query );
    
    return Database.getQueryLocator(query);
}

    global void execute(Database.BatchableContext BC,List<Apttus__APTS_Agreement__c> scope)
{        
        
        Integer dayofdate = tempDate.day();
        
        
        for(Apttus__APTS_Agreement__c Agreerec :scope){ 
        
        if(Agreerec.Apttus__Auto_Renewal__c== true ){
        renewmonth = Agreerec.Apttus__Auto_Renew_Term_Months__c;
        Integer renewalterm = renewmonth.intValue();
        
            if(Agreerec.APTPS_Effective_End_Date__c == tempDateoflastday  && Agreerec.Apttus__Status__c =='Activated')
            {
           //Agreerec.APTPS_Effective_End_Date__c=Agreerec.Apttus__Contract_End_Date__c.addMonths(1);
            Agreerec.APTPS_Effective_End_Date_For_Min_Spend__c = Agreerec.APTPS_Effective_End_Date__c.addMonths(3);
            Agreerec.APTPS_Effective_End_Date__c=Agreerec.APTPS_Effective_End_Date__c.addMonths(renewalterm);
                
            Agreerec.Apttus__Status__c = 'Rolling';
            agreelist.add(Agreerec);
            System.debug('To checking the Agreement list....' + agreelist );
                
            //if(Agreerec.Apttus__Term_Months__c <= 24 && Agreerec.Apttus__Activated_Date__c <= Agreerec.Apttus__Contract_End_Date__c)
            }
            else if(Agreerec.APTPS_Effective_End_Date__c< tempDateoflastday && Agreerec.Apttus__Status__c =='Activated' /* && Agreerec.Apttus__Activated_Date__c >= Agreerec.APTPS_Effective_End_Date__c */)
            {                
            Date tdate = Date.valueOf(Agreerec.APTPS_Effective_End_Date__c);
            Integer originalendday = tdate.day();
            // Agreerec.APTPS_Effective_End_Date__c = tempDate.addMonths(renewalterm);
               
               if(originalendday  <= dayofdate )
                {    
                
                    System.debug('----->inside if loop111111' );
                    
                   // Agreerec.APTPS_Effective_End_Date__c = Agreerec.APTPS_Effective_End_Date__c.addMonths(renewalterm);
                    Agreerec.APTPS_Effective_End_Date__c = tempDate.addMonths(renewalterm);
                    
                    Date eed = Date.valueOf(Agreerec.APTPS_Effective_End_Date__c);
                    Integer mo = eed.month();
                    Integer yr = eed.year();
                    
                    // Agreerec.APTPS_Effective_End_Date__c = Date.newInstance(yr,cc mo, originalendday);
                    String strdteed = string.valueof(originalendday)+ '/'+ string.valueof(mo);
                    
                    Date dteed = Date.newInstance(yr, mo, originalendday);
                    if(strdteed.contains('31/4') || strdteed.contains('31/6') || strdteed.contains('31/9') || strdteed.contains('31/11') || strdteed.contains('29/2') || strdteed.contains('30/2') || strdteed.contains('31/2')     )
                    {
                        Agreerec.APTPS_Effective_End_Date__c = dteed.toStartOfMonth().addDays(-1);
                    }else
                    {
                         Agreerec.APTPS_Effective_End_Date__c = dteed;
                    }

                    
                    
                }
                if(originalendday  > dayofdate )
                {
                System.debug('----->inside if loop22222' );
                  //    Agreerec.APTPS_Effective_End_Date__c = tempDate.addMonths(renewalterm); 
                      Date eedod = tempDate.addMonths(renewalterm); 
                      If(renewalterm ==1){
                      Agreerec.APTPS_Effective_End_Date__c = eedod.addMonths(-1);
                      }else{
                      Agreerec.APTPS_Effective_End_Date__c = eedod;
                      }
                      Date eed = Date.valueOf(Agreerec.APTPS_Effective_End_Date__c);
                      Integer mo = eed.month();
                      Integer yr = eed.year();  
                    //Agreerec.APTPS_Effective_End_Date__c = Date.newInstance(yr, mo, originalendday);
                    String strdteed = string.valueof(originalendday)+ '/'+ string.valueof(mo);
                    
                    Date dteed = Date.newInstance(yr, mo, originalendday);
                 //   Datetime dtt = dteed;
                 //   String strdteed = dtt.formatGMT('dd/MM/yyyy');
                    if(strdteed.contains('31/4') || strdteed.contains('31/6') || strdteed.contains('31/9') || strdteed.contains('31/11') || strdteed.contains('29/2') || strdteed.contains('30/2') || strdteed.contains('31/2')     )
                    {
                        Agreerec.APTPS_Effective_End_Date__c = dteed.toStartOfMonth().addDays(-1);
                    }else
                    {
                         Agreerec.APTPS_Effective_End_Date__c = dteed;
                    }
                }
                
            Agreerec.Apttus__Status__c = 'Rolling';
            agreelist.add(Agreerec);
            System.debug('To check the Agreement list....' + agreelist );
            }
            
            else if(Agreerec.Apttus__Status__c =='Rolling' && tempDateoflastday == Agreerec.APTPS_Effective_End_Date__c) // && sysdate = effective end date
            {                                                   
                //Agreerec.APTPS_Effective_End_Date_For_Min_Spend__c = Agreerec.APTPS_Effective_End_Date__c.addMonths(3);
                //Agreerec.APTPS_Effective_End_Date__c=Agreerec.APTPS_Effective_End_Date__c.addMonths(1);
               /* if( Agreerec.APTPS_Effective_End_Date__c !=null )
                {
                 Agreerec.APTPS_Effective_End_Date_For_Min_Spend__c = Agreerec.APTPS_Effective_End_Date__c.addMonths(3);
                 Agreerec.APTPS_Effective_End_Date__c=Agreerec.APTPS_Effective_End_Date__c.addMonths(renewalterm);
                } else */
                {
                 Agreerec.APTPS_Effective_End_Date__c =  Agreerec.APTPS_Effective_End_Date__c.addMonths(renewalterm);
                 Agreerec.APTPS_Effective_End_Date_For_Min_Spend__c = Agreerec.APTPS_Effective_End_Date__c.addMonths(3);
                }
                   
                
                //Agreerec.Apttus__Status__c = 'Rolling';
            agreelist.add(Agreerec);
            System.debug('To check the Agreement list....' + agreelist );
 
            }
        }
        
        
        else if(Agreerec.APTPS_Effective_End_Date__c <= tempDateoflastday && (Agreerec.Apttus__Status__c =='Activated' || Agreerec.Apttus__Status__c =='Rolling' ))
        {
        Agreerec.Apttus__Status_Category__c= 'Expired';
        Agreerec.Apttus__Status__c= 'Expired';
        agreelist.add(Agreerec);
        }
        
    }
    System.debug('---->End for loop' );
    update agreelist ;
}   
    
    
global void finish(Database.BatchableContext BC)
    {
        
    }
}