public class EDISEnqueueDirectoryListing {
    public static Integer counter=0;
    
    public void EDISEnqueueListing(List<EDISSingleRequestDTO> dtoList){
        List<EDISSingleRequestDTO> ListOfDTO = new List<EDISSingleRequestDTO>();
        List<EDISSingleRequestDTO> AnotherListOfDTO = new List<EDISSingleRequestDTO>();
        
        system.debug('I am inside enqueue::'+dtoList+'size::'+dtoList.size());
        EDISDirectoryService EDISJob = null;
        Integer num = dtoList.size()/50;
        system.debug('number::'+num);
        
        if(math.mod(dtoList.size(),50) != 0 ){
            
            num=num+1;
            system.debug('inside if::'+num);
        }
       
        for(Integer i=0; i<num; i++){
            ListOfDTO = new List<EDISSingleRequestDTO>();
            for(Integer j=0; j<50; j++){
                system.debug('counter value::'+counter);
                if(dtoList.size()==1){
                    ListOfDTO.add(dtoList[0]);}
                else{
                        ListOfDTO.add(dtoList[counter]);}
                system.debug('allList::'+ListOfDTO +'sizeHere::'+ListOfDTO.size());
                
                EDISJob = new EDISDirectoryService(ListOfDTO);
                if(counter == dtoList.size()-1){
                    counter++;
                    break;
                }
                counter++;
                //ListOfDTO.clear();                
            }
            system.debug('debug before job enque ' + Limits.getQueueableJobs() + ' limits ' + Limits.getLimitQueueableJobs());
            //while(Limits.getQueueableJobs()>=Limits.getLimitQueueableJobs()){
            //    continue;
            //}
            //ID jobID = EDISDirectoryService.enqueueJob(EDISJob);
            if(Limits.getQueueableJobs() == 1){
                String hour ;
                  String min ; 
                  String ss ;
                  String nextFireTime;
              if(!Test.isRunningTest()){
                  hour = String.valueOf(Datetime.now().hour());
                  min = String.valueOf(Datetime.now().minute()); 
                  ss = String.valueOf(Datetime.now().second() + 5);
                  //parse to cron expression
                  nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
              }else{
                   hour = String.valueOf(Datetime.now().hour());
                  min = String.valueOf(Datetime.now().minute()); 
                  ss = String.valueOf(Datetime.now().second()>54 ? Datetime.now().second() : Datetime.now().second() + 5);
                  //parse to cron expression
                  nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
              }
           
              System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new CreateDirectorySchedulable(EDISJob));
          }else{
                System.enqueueJob(EDISJob);
            }
            system.debug('Limit::'+Limits.getLimitQueueableJobs());
            //system.debug('JOBID of EDIS Queue ' + EDISDirectoryService.enqueueJob(EDISJob));
        }
    }
}