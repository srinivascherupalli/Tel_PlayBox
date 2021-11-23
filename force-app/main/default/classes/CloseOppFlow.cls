/*******************************************************************************
@Last Modified      : 07/01/2021 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : P2OB-14468 Team SFO Close Opp Flow simplificaion
*******************************************************************************/
public without sharing class CloseOppFlow {
    
    @InvocableMethod(label = 'Invoke Apex')
    public static list<flowOutputs> invokeThisFromFlow(list<flowInputs> flwip){
        
        list<flowOutputs> lflwoutput = new list<flowOutputs>();
        try{
            for(flowInputs str : flwip){

                    if(str.closureReason == 'Won' && str.TCV >= 250000 ){
                        lflwoutput.add(invokeLocalMethodWonOver250(str));
                    }
                    else if(str.closureReason == 'Won'  ){
                        lflwoutput.add(invokeLocalMethodWonBelow250(str)); 
                    }
                    else if(str.closureReason == 'Lost' && str.TCVForClosedLost >= 250000 ){
                        lflwoutput.add(invokeLocalMethodLostOver250(str)); 
                    }
                    else if(str.closureReason == 'Lost'  ){
                        lflwoutput.add(invokeLocalMethod(str)); 
                    }
            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlow :::: invokeThisFromFlow Method'+ Ex.getMessage());
        }
        
        return lflwoutput;
    }
    
    /************************* Maintaining Separte Methods To 4 different Scenarios so that maintaince will be 
Easy in case of any changes to particular field and particular scenario    ***********************/
    
    /************************ Method For Lost Under 250K  *****************************/
    
    public static flowOutputs invokeLocalMethod(flowInputs req){
        
        flowOutputs flops = new flowOutputs();
        try{
            string LostReason1 = req.UserInputLostReason;
            string usrcomments = req.UserInputLostComments;
            flops.isError = False;
            integer errorCounter = 0;
            
            
            if(LostReason1 == '--None--'){
                flops.oppReasonLostErrormsg_ApexOutput = Label.ReasonLostErrorMsg;
                errorCounter++;
            }
            if((LostReason1 == 'Withdrawn - Customer Request' || LostReason1 == 'Withdrawn - Incorrect Entry') && req.OppStageName == 'Propose'){
                flops.oppReasonLostWithdrawn = Label.CloseoppLostReasonWithdrawnErrorMsg;
                errorCounter++;
            }
            
            if(errorCounter > 0){
                flops.isError = True;
                flops.reasonLost  = LostReason1;
                flops.Compitator=req.UserInputCompetitor;
                flops.LostComments = usrcomments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;

            }
            else{
                flops.reasonLost  = LostReason1;
                flops.Compitator=req.UserInputCompetitor;
                flops.LostComments = usrcomments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;
            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlow :::: invokeLocalMethod Method'+ Ex.getMessage());
        }
        return flops;
    }
    
    /********************* Method For WonBelow250  *****************************/
    public static flowOutputs invokeLocalMethodWonBelow250(flowInputs req){
        
        flowOutputs flops = new flowOutputs();
        try{
            string LostReason1 = req.UserInputWonLostReason;
            string usrcomments = req.UserInputComments;
            flops.isError = False;
            integer errorCounter = 0;

            if(LostReason1 == '--None--'){
                flops.oppReasonWonErrormsg_ApexOutput = Label.ReasonWonErrorMsg;
                errorCounter++;
            }
            if(req.UserRevenueImpactDate == null ){
                flops.oppRevenueImpactDateErrormsg_ApexOutput = 'Please enter revenue impact date';
                errorCounter++;
            }
            if(errorCounter > 0){
                flops.isError = True;
                flops.resonWonLost = LostReason1;
                flops.Compitator=req.UserInputCompetitor;
                flops.Comments = usrcomments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;
            }
            else{
                flops.resonWonLost = LostReason1;
                flops.Compitator=req.UserInputCompetitor;
                flops.Comments = usrcomments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;
            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlow :::: invokeLocalMethodWonBelow250 Method'+ Ex.getMessage());
        }
        return flops;
    }
    
    /********************* Method For WonOver250 *******************************/
    public static flowOutputs invokeLocalMethodWonOver250(flowInputs req){
        
        flowOutputs flops = new flowOutputs();
        try{
            string wonReasonOver250 = req.UserInputWonLostReason;
            flops.isError = False;
            integer errorCounter = 0;
            

            if(wonReasonOver250 == '--None--'){
                flops.oppReasonWonErrormsg_ApexOutput = Label.ReasonWonErrorMsg;
                errorCounter++;
            }
            if(req.UserInputComments == ''){
                flops.oppReasonWonCommentsErrormsg_ApexOutput = Label.CloseoppReasonWonCommentsErrorMsg;
                errorCounter++;
            }
            if(req.UserRevenueImpactDate == null ){
                flops.oppRevenueImpactDateErrormsg_ApexOutput = 'Please enter revenue impact date';
                errorCounter++;
            }
            if(errorCounter > 0){
                flops.isError = True;
                flops.resonWonLost = wonReasonOver250;
                flops.Compitator=req.UserInputCompetitor;
                flops.Comments = req.UserInputComments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;

            }
            else{
                flops.resonWonLost = wonReasonOver250;
                flops.Compitator=req.UserInputCompetitor;
                flops.Comments = req.UserInputComments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;

            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlow :::: invokeLocalMethodWonOver250 Method'+ Ex.getMessage());
        }
        return flops;
    }
    
    /********************************* Method For Lost Over 250K  ***********************************************/
    
    
    public static flowOutputs invokeLocalMethodLostOver250(flowInputs req){
        
        flowOutputs flops = new flowOutputs();
        
        try{
            string wonReasonOver250 = req.UserInputLostReason;
            string usrcomments = req.UserInputLostComments;
            flops.isError = False;
            integer errorCounter = 0;
            

            if(wonReasonOver250 == '--None--'){
                flops.oppReasonLostErrormsg_ApexOutput = Label.ReasonLostErrorMsg;
                errorCounter++;
            }
            if(usrcomments == '' || usrcomments == null){
                flops.oppReasonLostCommentsErrmsg_ApexOutput = Label.CloseOppReasonLostComments;
                errorCounter++;
            }
            
            if(errorCounter > 0){
                flops.isError = True;
                flops.reasonLost  = wonReasonOver250;
                flops.Compitator=req.UserInputCompetitor;
                flops.LostComments = req.UserInputLostComments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;

            }
            else{
                flops.reasonLost  = wonReasonOver250;
                flops.Compitator=req.UserInputCompetitor;
                flops.LostComments = req.UserInputComments;
                flops.UserRevenueImpactDate_ApexOutput = req.UserRevenueImpactDate;

            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlow :::: invokeLocalMethodLostOver250 Method'+ Ex.getMessage());
        }
        return flops;
    }
    
    /************* At any given time, Please dont change any variable name because these are refered in Close Opportunity Flow **********/
    public class flowInputs{
        /************************ Screen Check **********************************/
        @InvocableVariable(label='Input for Close Won TCV')
        public integer TCV;
        @InvocableVariable(label='Input for Close Lost TCV')
        public integer TCVForClosedLost;
        @InvocableVariable(label='Input for Closure Reason')
        public string closureReason;
        @InvocableVariable(label='Input for Opportunity Stage Value')
        public string OppStageName;

        /************************ Input Varibales For Lost/WON *********************/
        @InvocableVariable(label='Input for Reason Won')
        public string UserInputWonLostReason;
        @InvocableVariable(label='Input for Reason Lost')
        public string UserInputLostReason;
        @InvocableVariable(label='Input for Competitor on Won & Lost')
        public string UserInputCompetitor;
        @InvocableVariable(label='Input for Reason Won Comments')
        public string UserInputComments;
        @InvocableVariable(label='Input for Reason Lost Comments')
        public string UserInputLostComments;
        @InvocableVariable(label='Input for Revenue Impacte Date')
        public date UserRevenueImpactDate;
        
    }
    public class flowOutputs{
        
        @InvocableVariable
        public boolean isError;
        
        /************************ Output Variables For Lost/WON ************/
        @InvocableVariable(label='Output for Reason Won Value')
        public string resonWonLost;
        @InvocableVariable(label='Output for Reason Lost Value')
        public string reasonLost;
        @InvocableVariable(label='Output for Competitor Value')
        public string Compitator;
        @InvocableVariable(label='Output for Reason Won Comments Value')
        public string Comments;
        @InvocableVariable(label='Output for Reason Lost Comments Value')
        public string LostComments;
        @InvocableVariable
        public string oppReasonLostWithdrawn;
        @InvocableVariable(label='Output for Revenue Impacte Date')
        public date UserRevenueImpactDate_ApexOutput;
        /************************ Output Variables For Lost/WON  Error messages************/
        @InvocableVariable
        public string oppReasonWonErrormsg_ApexOutput;
        @InvocableVariable
        public string oppReasonWonCommentsErrormsg_ApexOutput;
        @InvocableVariable
        public string oppReasonLostErrormsg_ApexOutput;
        @InvocableVariable
        public string oppReasonLostCommentsErrmsg_ApexOutput;
        @InvocableVariable
        public string oppRevenueImpactDateErrormsg_ApexOutput;
    }
}