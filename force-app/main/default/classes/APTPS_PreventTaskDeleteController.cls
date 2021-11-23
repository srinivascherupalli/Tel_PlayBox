public with sharing class APTPS_PreventTaskDeleteController {
public id taskId = apexpages.currentpage().getparameters().get('id');
public Id parentId;
public Task taskRecord {get; set;}
    public APTPS_PreventTaskDeleteController(ApexPages.StandardController controller) {
    }
    public Pagereference onDeletion(){
        Profile profileRecord = [Select Name from Profile where Id =: userinfo.getProfileid()];
        List<Task> taskList = new List<Task>();
        if(taskId != null){
            taskList = [Select Id, What.Type, WhatId, Status from Task where id=:taskId All Rows]; 
            if(taskList.size() > 0){
                taskRecord = taskList[0];
                parentId = taskRecord.WhatId ;
                if(profileRecord.Name != 'System Administrator' && taskRecord.Status == 'Completed' && taskRecord.What.Type == 'Apttus__APTS_Agreement__c'){                
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.fatal,'You do not have permission to delete this record. Please contact your system Administrator.');
                    ApexPages.addMessage(myMsg);  
                    return null;  
                }
                else{
                    delete taskRecord;
                    PageReference homePage= new PageReference('/'+parentId); 
                    homePage.setRedirect(true);
                    return homePage;
                }
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }

}