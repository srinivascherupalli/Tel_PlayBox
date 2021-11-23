/**
 * @description       : 
 * @author            : Abinash Barik
 * @group             : 
 * @last modified on  : 10-20-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-23-2020   Abinash Barik   Initial Version
**/
public class inlineEditDataTableController {
    /*
    * Method will expect table name and returns respected configuration and all column details
    * which are shown on the data table
    */
    @AuraEnabled
    public static dataTableWrapper initiateDataTable(String tname){
        String tableName = tname;
        dataTableWrapper objdataTable = new dataTableWrapper();
        if(tableName != null){
            try{
                System.debug('tableName>>'+tableName);
                //Get table level config details
                String tableconfigSOQL = prepareSOQL('DataTableConfiguration__mdt', tableName, 'DeveloperName=:tableName', '');
                System.debug('tableconfigSOQL>>'+tableconfigSOQL);
                objdataTable.dataTableConfig =  Database.query(String.escapeSingleQuotes(tableconfigSOQL));
                

                if(objdataTable.dataTableConfig == null){
                    objdataTable.error = 'Please provide a valid data table name.';
                    return objdataTable;
                }
                // Get fields level config details
                String fieldconfigSOQL = prepareSOQL('Data_Table_Field_Conf__mdt', tableName, 'Data_table_Configuration__r.DeveloperName=:tableName', 'Display_Order__c');
                System.debug('fieldconfigSOQL>>'+fieldconfigSOQL);
                objdataTable.fielddetails =  Database.query(String.escapeSingleQuotes(fieldconfigSOQL));
                system.debug('objdataTable.fielddetails>>>>>'+objdataTable.fielddetails);
                if(objdataTable.fielddetails.isEmpty()){
                    objdataTable.error = 'Please create the valid fields for the data table.';
                    return objdataTable;
                }

                List<columndetailwrapper> lstcolumn = new List<columndetailwrapper>();
                if(!objdataTable.fielddetails.isEmpty()){
                    system.debug('objdataTable--->'+objdataTable);
                    columndetailwrapper column = new columndetailwrapper();
                    for(Data_Table_Field_Conf__mdt flds : objdataTable.fielddetails){
                        column = (columndetailwrapper) JSON.deserialize(JSON.serialize(flds).replace('__c',''), columndetailwrapper.class);
                        
                        if(objdataTable.dataTableConfig.Datasource_Type__c != 'Other'){                            
                            column.fieldName= flds.fieldName__c;
                        }
                        //column = (columndetailwrapper) JSON.deserialize(JSON.serialize(flds).replace('__c',''), columndetailwrapper.class);
                        // If field type is picklist then it will get picklist values from respected field
                        if(flds.type__c == 'picklist'){
                            if(flds.Reference_Object__c != null && flds.Reference_Field__c != null){
                                column.selectOptions = ConstantMetadataUtility.findPicklistOptions(flds.Reference_Object__c,flds.Reference_Field__c);
                            }else{
                                objdataTable.error = 'Reference object and Reference field can not be blank for picklist type field.';
                                return objdataTable;
                            }
                        } 
                        System.debug('column>>>'+column);
                        lstcolumn.add(column);
                    }
                }
                objdataTable.columndetail = lstcolumn;
                objdataTable.selectOptionsPagination = ConstantMetadataUtility.findPicklistOptions('DataTableConfiguration__mdt','Page_Size_Option__c');
                objdataTable.selectOptionValue = Integer.valueOf(objdataTable.dataTableConfig.Page_Size__c);
            }
            Catch (Exception e){
                objdataTable.error = e.getMessage();
            }
            
        }else{
            objdataTable.error = ' Data table name can not be blank.';
        }

        System.debug('objdataTable>>>'+objdataTable);
        return objdataTable;
    }

    Public Static String prepareSOQL(String objectName, String tableName, String tableClause, String orderby){
        String query = '';
        List <String> fieldList = ConstantMetadataUtility.getAllFields(objectName);
        query = ConstantMetadataUtility.getSOQL(objectName, fieldList, tableClause, orderby); 
        return query;
    }


    Public class columndetailwrapper{
        @AuraEnabled
        public String label; // holds Column Header
        @auraEnabled
        public String fieldName;// holds Column API
        @auraEnabled
        public String type; // holds Column type ex: text,picklist etc
        @auraEnabled
        public boolean editable; // holds Column is editable or not, if false not editable if true editable
        @auraEnabled
        public boolean sortable; // holds Column is editable or not, if false not editable if true editable
        @auraEnabled
        public String Reference_Field; 
        @auraEnabled
        public string Reference_Object; 
        @auraEnabled
        public boolean Hide_Column; 
        @auraEnabled
        public List<ConstantMetadataUtility.picklistWrapper> selectOptions;
        public columndetailwrapper(){
            this.label = '';
            this.fieldName = '';
            this.type = '';
            this.editable = false;
            this.selectOptions = new List<ConstantMetadataUtility.picklistWrapper>();
            this.Reference_Field = '';
            this.Reference_Object = '';
            this.sortable = false;
            this.Hide_Column = false;
        }
    }
    Public class dataTabledetails{
        @AuraEnabled
        public boolean isEditModeOn;
        @auraEnabled
        public boolean buttonsDisabled;
        @auraEnabled
        public String buttonClicked;
        @auraEnabled
        public String error;
        public dataTabledetails(){
            this.isEditModeOn = false;
            this.buttonsDisabled = false;
            this.buttonClicked = '';
            this.error = '';
        }
    }
    Public class dataTableWrapper{
        @AuraEnabled
        public DataTableConfiguration__mdt dataTableConfig; // holds data table config details
        @auraEnabled
        public List<Data_Table_Field_Conf__mdt> fielddetails; // holds all column detils respected to data table
        @AuraEnabled
        public List<columndetailwrapper> columndetail; // holds all column detils respected to data table as a JSON format
        @AuraEnabled
        public dataTabledetails tabledetils = new dataTabledetails();
        @AuraEnabled
        public List<ConstantMetadataUtility.picklistWrapper> selectOptionsPagination;
        @AuraEnabled
        public String error = '';
        @AuraEnabled
        public Integer selectOptionValue;
        public dataTableWrapper(){
            this.selectOptionsPagination = new List<ConstantMetadataUtility.picklistWrapper>();
        }
    }
    
/************************************************************************************
 * Developer: Abhishek Mallick
 * User Story: EDGE-207158
 * Team: Osaka
 * Description: This is a re-usable method to perform operations on uploaded file based 
				on metadata record Name.     
**************************************************************************************/    
    @AuraEnabled
    public static String uploadFile(String base64Data, String metaDataRecName){
        String result = '';
        //Start of EDGE-207158 to bulk update Nickname on Subscription.
        if(metaDataRecName == 'SubscriptionNicknameOrder'){
            result = inlineEditDataTableControllerHelper.updateNickName(base64Data);
        }
        //End of EDGE-207158 to bulk update Nickname on Subscription.
        return result;
    }
}