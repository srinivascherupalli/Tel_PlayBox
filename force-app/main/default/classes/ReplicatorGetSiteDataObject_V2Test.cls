/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 14 April 2019
 * Description : Test Class to cover : ReplicatorGetSiteDataObject_V2
 * Revision :
 * 
 * *****************************************************************************/
@IsTest
public class ReplicatorGetSiteDataObject_V2Test {
   
        /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 06 April 2019
 * Description : Method to Test ReplicatorGetSiteDataObject_V2 parse value's
 * Parameter : 
 * 
 * *****************************************************************************/
    static testMethod void parseTest() {
            String json = '{'+
        '    \"cidn\": \"212\",'+
        '    \"correlationId\": \"123456\",'+
        '    \"addressList\": [{'+
        '        \"addressType\": \"111\",'+
        '        \"addressValue\": \"111\",'+
        '        \"replicatorUpdateDateTime\": \"22/05/1992\",'+
     
        '        \"addressCharacteristics\": [{'+
        '            \"name\": \"1245\",'+
        '            \"value\": \"1245\"'+
        '        }]'+
        '    }]'+
        '}';     
        ReplicatorGetSiteDataObject_V2 obj = ReplicatorGetSiteDataObject_V2.parse(json);
        System.debug('Obj: ' + obj.toString());
       
        ReplicatorGetSiteDataObject_V2 obj2 = new ReplicatorGetSiteDataObject_V2();
        obj2.cidn = '212';
        obj2.correlationId = '553'; 
        obj2.Error_Code = '402';
        obj2.Error_Description = 'Test';
        
        obj2.addressList= new List<ReplicatorGetSiteDataObject_V2.addressListDTO>();
        ReplicatorGetSiteDataObject_V2.addressListDTO AddListRec = new ReplicatorGetSiteDataObject_V2.addressListDTO ();
        AddListRec.addressType = 'test address';
        AddListRec.addressValue = 'test address'; 
        AddListRec.replicatorUpdateDateTime = 'test time'; 
        
        AddListRec.addressCharacteristics = new List<ReplicatorGetSiteDataObject_V2.addressCharacteristicsDTO>();
        ReplicatorGetSiteDataObject_V2.addressCharacteristicsDTO addressCharacteristicsRec = new ReplicatorGetSiteDataObject_V2.addressCharacteristicsDTO();
        addressCharacteristicsRec.name= 'Test value';
        addressCharacteristicsRec.value= 'Test value';
        System.debug('Obj2: ' + obj2.toString());
    }
}