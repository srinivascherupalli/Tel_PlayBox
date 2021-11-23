/*-------------------------
    Author: Ila Anmol Verma
    US: EDGE-66239
    Description: Generate appointment pre requisite for BOM Queueable
    ---------------------------------*/

    public  class AppointmentServiceCalloutQ implements Queueable,Database.AllowsCallouts{
                
        public static String handler = 'GenerateAppointmentHandler';
                List<csord__Subscription__c> subscrpList = null;
                public Integer counter =0;
                public String orderID=null;
                
                public AppointmentServiceCalloutQ(List<csord__Subscription__c> subsList, String ordID){
                this.subscrpList = subsList;
                this.counter = 0;
                this.orderID= ordID;
            }

            
             public void execute(QueueableContext context) {
                //String token= 'lFYpKM2LkokcsbzQFKfsMTiPeFcA'; 
                 String token = AuthenticationManager.getOauthToken(handler);
                    AppointmentServiceCallout.generateAppointment(subscrpList,token,orderID);
                    
                }

                    }