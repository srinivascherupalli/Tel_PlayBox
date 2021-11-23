global class AddressCheck {
    
    webservice static String GetAddresses (String searchcard,String accid, String basketid) {
        System.debug('<><> searchcard == ' + searchcard);
        String result='';
        if((accid == null || accid == '') ) {
            result = null;
        }
        else{

            Set<cscrm__Site__c> setList1 = new Set<cscrm__Site__c>();
            Set<cscrm__Site__c> setList2 = new Set<cscrm__Site__c>();
            String searchcardcondition = (searchcard == '') ? '' : 'AND (Name like \'%' + searchcard +'%\' OR cscrm__Installation_Address_Details__c like \'%' + searchcard + '%\') ';
            String json= '';
            List<String> adborIDList = new List<String>();
            String connectedWorkLabel = System.Label.Label_CWP;
            List<csbb__Product_Configuration_Request__c> pcrList = [SELECT id, Name, csbb__Optionals__c FROM csbb__Product_Configuration_Request__c Where csbb__Product_Basket__c =:basketId AND Product_Configuration_Name__c =: connectedWorkLabel];
            
            for(csbb__Product_Configuration_Request__c pcr: pcrList){
                System.debug('<<>>Inside for');
                if(pcr.csbb__Optionals__c != null){
                    if(json == ''){
                        json = pcr.csbb__Optionals__c ; 
                    }
                    else{
                        json = json + ',' +pcr.csbb__Optionals__c ;
                    }
                }
            }
            
            json = '['+json+']';
            List<Optionals> optionalLs = (List<Optionals>)System.JSON.deserialize(json, List<Optionals>.class);
            
            for(Optionals op: optionalLs){
                if(op.hiddenParam1 != null){
                    adborIDList.add(op.hiddenParam1);
                }
            }

            System.debug('adborIDList<><>'+adborIDList);
        
           
            if(searchcardcondition != ''){
                String query = 'Select Id, display_name__c, Name, cscrm__Installation_Address_Details__c,cscrm__Account__c,cscrm__Installation_Address__c, cscrm__Installation_Address__r.cscrm__State_Province__c,AdborID__c from cscrm__Site__c where cscrm__Account__c = \'' + accid +'\' '+ searchcardcondition + 'AND cscrm__Installation_Address__r.Address_ID__c NOT IN';
                query+=':adborIDList';
                List<cscrm__Site__c> sites = Database.query(query);
                Map<Id, cscrm__Site__c> siteMap= new Map<Id, cscrm__Site__c>();
                for(cscrm__Site__c site:sites){
                    siteMap.put(site.id,site);

                }

                System.debug('<><> sites == ' + sites);
                List<cscrm__Site__c>  siteWithSubList = new List<cscrm__Site__c>();
                for(csord__Subscription__c sub:[SELECT id, Site__c FROM csord__Subscription__c WHERE Name=: connectedWorkLabel AND Site__c IN:sites]){
                    if(sub.Site__c != null){
                        siteWithSubList.add(siteMap.get(sub.Site__c));
                    }
                }

                setList1 = new Set<cscrm__Site__c>(sites);
                setList2 = new Set<cscrm__Site__c>(siteWithSubList);
                for(cscrm__Site__c siteEle : setList2)
                {
                    if(setList1.contains(siteEle)){
                       setList1.remove(siteEle);
                    }
                }

                result = System.JSON.serialize(setList1);
            }
            
            if(setList1.isEmpty()){
                String queryallsites = 'Select Id, display_name__c, Name, cscrm__Installation_Address_Details__c,cscrm__Account__c,cscrm__Installation_Address__c, cscrm__Installation_Address__r.cscrm__State_Province__c,AdborID__c from cscrm__Site__c where cscrm__Account__c = \'' + accid +'\'' +'AND cscrm__Installation_Address__r.Address_ID__c NOT IN';
                queryallsites+=':adborIDList';
                system.debug('queryallsites<><>'+queryallsites);
                List<cscrm__Site__c> allsites = Database.query(queryallsites);
                
                Map<Id, cscrm__Site__c> siteMap2= new Map<Id, cscrm__Site__c>();
                for(cscrm__Site__c site:allsites){
                    siteMap2.put(site.id,site);

                }
                
                List<cscrm__Site__c>  siteWithSubList2 = new List<cscrm__Site__c>();
                for(csord__Subscription__c sub:[SELECT id, Site__c FROM csord__Subscription__c WHERE Name=: connectedWorkLabel AND Site__c IN:allsites]){
                    if(sub.Site__c != null){
                        siteWithSubList2.add(siteMap2.get(sub.Site__c));
                    }
                }

                setList1 = new Set<cscrm__Site__c>(allsites);
                setList2 = new Set<cscrm__Site__c>(siteWithSubList2);
                for(cscrm__Site__c siteEle : setList2)
                {
                    if(setList1.contains(siteEle)){
                       setList1.remove(siteEle);
                    }
                }

                result = System.JSON.serialize(setList1);

            }
            
            
        }
        return result;
    }
    
    public class Optionals{
        public String selectedAddressDisplay;
        public String hiddenParam1;


    }
}