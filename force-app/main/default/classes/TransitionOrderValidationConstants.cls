public class TransitionOrderValidationConstants {
	public static final String ERROR = 'Error';
    public static final String TBB = 'Business Bundle - TBB';
    public static final String TBV = 'Business Bundle - TBV';
    public static final String DOT = 'Business Bundle - DOT';
    public static final String legacyTBB = 'Broadband';
    public static final String legacyTBV = 'Voice';
    public static final String legacyDOT = 'DOT';
    public static final String SubStatus = 'Subscription created';
    public static final String SrvStatus = 'Service created';
    public static final Map<String, String> legacyvalueMaps = new Map<String, String>{'Business Essentials' => 'Business Bundle',
                                                'Broadband' => 'Business Broadband','Device' => 'Device',
                                                'Switch' => 'Device','IP Subnet' => 'IP Subnet',
                                                'Mobile Service' => 'Mobile Service','Voice' => 'T-Biz Voice',
                                                'Add Ons' => 'Add Ons','VAS-AOH' => 'Add Ons', 'VAS-Accessory' => 'Add Ons'
                                              };

    public static final String qField = 'cspmb__Add_On_Price_Item__r.Name';

    public static String getRecordType (String key){
        Map<String, String> RecordTypeMaps = new Map<String, String>{'vas-accessory' => 'Add Ons',
                                                'vas-aoh' => 'Add Ons',
                                                'mobile phone' => 'Device',
                                                'switch' => 'Device',
                                                'iad' => 'Device',
                                                'router' => 'Device',
                                                'tmb device' => 'Device',
                                                'accessory' => 'Device',
                                                'bbbu dongle' => 'Device',
                                                'ip phone' => 'Device',
                                                'byo_analogue device' => 'Device',
                                                'byo analogue device' => 'Device',
                                                'tmb' => 'Business Internet',
                                                'mbbu' => 'Mobile Service',
                                                'voice' => 'IP Voice',
                                                'broadband' => 'Business Internet',
                                                'business bundle' => 'Business Bundle'
                                              }; 
        System.debug('key := '+key);
        if(key != null && key != ''){
            if(RecordTypeMaps.get(key.toLowerCase('tr')) != null)
            	return RecordTypeMaps.get(key.toLowerCase('tr'));
            else return RecordTypeMaps.get('business bundle');
        } else return RecordTypeMaps.get('business bundle');
    }

    public static Id getRecordTypeId (String key){
            return Schema.SObjectType.csord__Service__c.getRecordTypeInfosByName().get(getRecordType(key)).getRecordTypeId();
    }

    public static String getUserType (String key){
        Map<String, String> usertypeMap = new Map<String, String>{'dbl'=>'Core','core'=>'Core','fax'=>'Fax','huntgroup'=>'Hunt Group',
                'autoattendant'=>'Virtual Receptionist','eftpos'=>'EFTPOS', 'b2b'=>'B2B Alarm', 'office'=>'Office'
                };
        if(key != null && key != ''){
            if(usertypeMap.get(key.toLowerCase('tr')) != null)
                return usertypeMap.get(key.toLowerCase('tr'));
            else 
                return key;
        } else return null;
    }

    public static String getPlan(String transition){
        String plan=null;
        if(transition.contains('DOT')){
                plan = 'DOT';
            } else if(transition.contains('TBV')){
                plan = 'TBiz Voice';
            } else if(transition.contains('TBB')){
                plan = 'Business Broadband';
            }
        return plan;
    }

    public class PricingDetails{
        public Date billStartDt;
        public String addOn;
        public String priceList;
        public Decimal amount;
        public String term;
        public String name;
        public String comType;
        public String payType;
    }

    public static String getPriceList(String priceList){
        String priceListId=null;
        List<cspmb__Price_Item__c> query = [SELECT Id, Name, cspmb__Is_Active__c from cspmb__Price_Item__c where Name = :priceList and cspmb__Is_Active__c = true];
        if(!query.isEmpty()){
            priceListId = query[0].Id;
        }
        return priceListId;
    }


}