/*
@Author 
@name MetadataService
@CreateDate 07/11/2016
@Description - this class wsdl generated apex class to call salesforce metadata api

*/ 

public class MetadataService {
    public virtual class Metadata {
        public String fullName;
    }
    public interface IReadResult {
        MetadataService.Metadata[] getRecords();
    }
    public class ProfileExternalDataSourceAccess {
        public Boolean enabled;
        public String externalDataSource;
        private String[] enabled_type_info = new String[]{'enabled','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] externalDataSource_type_info = new String[]{'externalDataSource','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'enabled','externalDataSource'};
                        }
    public class Profile extends Metadata {
        public String type = 'Profile';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            public MetadataService.ProfileApplicationVisibility[] applicationVisibilities;
        public MetadataService.ProfileApexClassAccess[] classAccesses;
        public Boolean custom;
        public MetadataService.ProfileCustomPermissions[] customPermissions;
        public String description;
        public MetadataService.ProfileExternalDataSourceAccess[] externalDataSourceAccesses;
        public MetadataService.ProfileFieldLevelSecurity[] fieldPermissions;
        public MetadataService.ProfileLayoutAssignment[] layoutAssignments;
        public MetadataService.ProfileLoginHours loginHours;
        public MetadataService.ProfileLoginIpRange[] loginIpRanges;
        public MetadataService.ProfileObjectPermissions[] objectPermissions;
        public MetadataService.ProfileApexPageAccess[] pageAccesses;
        public MetadataService.ProfileRecordTypeVisibility[] recordTypeVisibilities;
        public MetadataService.ProfileTabVisibility[] tabVisibilities;
        public String userLicense;
        public MetadataService.ProfileUserPermission[] userPermissions;
        private String[] applicationVisibilities_type_info = new String[]{'applicationVisibilities','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] classAccesses_type_info = new String[]{'classAccesses','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                private String[] custom_type_info = new String[]{'custom','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] customPermissions_type_info = new String[]{'customPermissions','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                        private String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] externalDataSourceAccesses_type_info = new String[]{'externalDataSourceAccesses','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                private String[] fieldPermissions_type_info = new String[]{'fieldPermissions','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                    private String[] layoutAssignments_type_info = new String[]{'layoutAssignments','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                        private String[] loginHours_type_info = new String[]{'loginHours','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                            private String[] loginIpRanges_type_info = new String[]{'loginIpRanges','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                private String[] objectPermissions_type_info = new String[]{'objectPermissions','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                    private String[] pageAccesses_type_info = new String[]{'pageAccesses','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                        private String[] recordTypeVisibilities_type_info = new String[]{'recordTypeVisibilities','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                            private String[] tabVisibilities_type_info = new String[]{'tabVisibilities','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                                private String[] userLicense_type_info = new String[]{'userLicense','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                    private String[] userPermissions_type_info = new String[]{'userPermissions','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                                        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                                                            private String[] type_att_info = new String[]{'xsi:type'};
                                                                                private String[] field_order_type_info = new String[]{'fullName', 'applicationVisibilities','classAccesses','custom','customPermissions','description','externalDataSourceAccesses','fieldPermissions','layoutAssignments','loginHours','loginIpRanges','objectPermissions','pageAccesses','recordTypeVisibilities','tabVisibilities','userLicense','userPermissions'};
                                                                                    }
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
       	private String[] level_type_info = new String[]{'level','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    
    public class ProfileLoginIpRange {
        public String description;
        public String endAddress;
        public String startAddress;
        private String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] endAddress_type_info = new String[]{'endAddress','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] startAddress_type_info = new String[]{'startAddress','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'description','endAddress','startAddress'};
	}
	
    public class readLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'result'};
                    }
    public class ReadLayoutResult implements IReadResult {
        public MetadataService.Layout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'records'};
                    }
    public class ProfileTabVisibility {
        public String tab;
        public String visibility;
        private String[] tab_type_info = new String[]{'tab','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] visibility_type_info = new String[]{'visibility','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'tab','visibility'};
                        }
    public class ProfileApexPageAccess {
        public String apexPage;
        public Boolean enabled;
        private String[] apexPage_type_info = new String[]{'apexPage','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] enabled_type_info = new String[]{'enabled','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'apexPage','enabled'};
                        }
    public class ProfileRecordTypeVisibility {
        public Boolean default_x;
        public Boolean personAccountDefault;
        public String recordType;
        public Boolean visible;
        private String[] default_x_type_info = new String[]{'default','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] personAccountDefault_type_info = new String[]{'personAccountDefault','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] recordType_type_info = new String[]{'recordType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                    private String[] visible_type_info = new String[]{'visible','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                            private String[] field_order_type_info = new String[]{'default_x','personAccountDefault','recordType','visible'};
                                }
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'sessionId'};
                    }
    
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'debugLog'};
                    }
    public class DebuggingHeader_element {
        public MetadataService.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] debugLevel_type_info = new String[]{'debugLevel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'categories','debugLevel'};
                        }
    
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'client'};
                    }
    public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'allOrNone'};
                    }
    public class readMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] fullNames_type_info = new String[]{'fullNames','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'type_x','fullNames'};
                        }
    public interface IReadResponseElement {
        IReadResult getResult();
    }
    public class ReadProfileResult implements IReadResult {
        public MetadataService.Profile[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'records'};
                    }
    public class readProfileResponse_element implements IReadResponseElement {
        public MetadataService.ReadProfileResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'result'};
                    }
    public class ProfileObjectPermissions {
        public Boolean allowCreate;
        public Boolean allowDelete;
        public Boolean allowEdit;
        public Boolean allowRead;
        public Boolean modifyAllRecords;
        public String object_x;
        public Boolean viewAllRecords;
        private String[] allowCreate_type_info = new String[]{'allowCreate','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] allowDelete_type_info = new String[]{'allowDelete','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] allowEdit_type_info = new String[]{'allowEdit','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] allowRead_type_info = new String[]{'allowRead','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] modifyAllRecords_type_info = new String[]{'modifyAllRecords','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] object_x_type_info = new String[]{'object','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                                private String[] viewAllRecords_type_info = new String[]{'viewAllRecords','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                        private String[] field_order_type_info = new String[]{'allowCreate','allowDelete','allowEdit','allowRead','modifyAllRecords','object_x','viewAllRecords'};
                                            }
    public class ProfileApexClassAccess {
        public String apexClass;
        public Boolean enabled;
        private String[] apexClass_type_info = new String[]{'apexClass','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] enabled_type_info = new String[]{'enabled','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'apexClass','enabled'};
                        }
    public class ProfileFieldLevelSecurity {
        public Boolean editable;
        public String field;
        public Boolean readable;
        private String[] editable_type_info = new String[]{'editable','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] field_type_info = new String[]{'field','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] readable_type_info = new String[]{'readable','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                        private String[] field_order_type_info = new String[]{'editable','field','readable'};
                            }
    public class ProfileUserPermission {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] name_type_info = new String[]{'name','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'enabled','name'};
                        }
    public class ProfileApplicationVisibility {
        public String application;
        public Boolean default_x;
        public Boolean visible;
        private String[] application_type_info = new String[]{'application','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] default_x_type_info = new String[]{'default','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] visible_type_info = new String[]{'visible','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                        private String[] field_order_type_info = new String[]{'application','default_x','visible'};
                            }
    public class ProfileLoginHours {
        public String fridayEnd;
        public String fridayStart;
        public String mondayEnd;
        public String mondayStart;
        public String saturdayEnd;
        public String saturdayStart;
        public String sundayEnd;
        public String sundayStart;
        public String thursdayEnd;
        public String thursdayStart;
        public String tuesdayEnd;
        public String tuesdayStart;
        public String wednesdayEnd;
        public String wednesdayStart;
        private String[] fridayEnd_type_info = new String[]{'fridayEnd','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] fridayStart_type_info = new String[]{'fridayStart','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] mondayEnd_type_info = new String[]{'mondayEnd','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] mondayStart_type_info = new String[]{'mondayStart','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] saturdayEnd_type_info = new String[]{'saturdayEnd','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] saturdayStart_type_info = new String[]{'saturdayStart','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                private String[] sundayEnd_type_info = new String[]{'sundayEnd','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                    private String[] sundayStart_type_info = new String[]{'sundayStart','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                        private String[] thursdayEnd_type_info = new String[]{'thursdayEnd','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                            private String[] thursdayStart_type_info = new String[]{'thursdayStart','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                private String[] tuesdayEnd_type_info = new String[]{'tuesdayEnd','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                    private String[] tuesdayStart_type_info = new String[]{'tuesdayStart','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                        private String[] wednesdayEnd_type_info = new String[]{'wednesdayEnd','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                            private String[] wednesdayStart_type_info = new String[]{'wednesdayStart','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                                                    private String[] field_order_type_info = new String[]{'fridayEnd','fridayStart','mondayEnd','mondayStart','saturdayEnd','saturdayStart','sundayEnd','sundayStart','thursdayEnd','thursdayStart','tuesdayEnd','tuesdayStart','wednesdayEnd','wednesdayStart'};
                                                                        }
    public class ProfileLayoutAssignment {
        public String layout;
        public String recordType;
        private String[] layout_type_info = new String[]{'layout','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] recordType_type_info = new String[]{'recordType','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'layout','recordType'};
                        }
    public class ProfileCustomPermissions {
        public Boolean enabled;
        public String name;
        private String[] enabled_type_info = new String[]{'enabled','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] name_type_info = new String[]{'name','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'enabled','name'};
                        }
    
    public class LayoutSection {
        public Boolean customLabel;
        public Boolean detailHeading;
        public Boolean editHeading;
        public String label;
        public MetadataService.LayoutColumn[] layoutColumns;
        public String style;
        private String[] customLabel_type_info = new String[]{'customLabel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] detailHeading_type_info = new String[]{'detailHeading','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] editHeading_type_info = new String[]{'editHeading','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] layoutColumns_type_info = new String[]{'layoutColumns','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                            private String[] style_type_info = new String[]{'style','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                    private String[] field_order_type_info = new String[]{'customLabel','detailHeading','editHeading','label','layoutColumns','style'};
                                        }
    public class LayoutColumn {
        public MetadataService.LayoutItem[] layoutItems;
        public String reserved;
        private String[] layoutItems_type_info = new String[]{'layoutItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] reserved_type_info = new String[]{'reserved','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'layoutItems','reserved'};
                        }
    public class LayoutItem {
        public String behavior;
        public String canvas;
        public String component;
        public String customLink;
        public Boolean emptySpace;
        public String field;
        public Integer height;
        public String page_x;
        public String scontrol;
        public Boolean showLabel;
        public Boolean showScrollbars;
        public String width;
        private String[] behavior_type_info = new String[]{'behavior','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] canvas_type_info = new String[]{'canvas','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] component_type_info = new String[]{'component','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] customLink_type_info = new String[]{'customLink','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] emptySpace_type_info = new String[]{'emptySpace','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] field_type_info = new String[]{'field','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                    private String[] page_x_type_info = new String[]{'page','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                        private String[] scontrol_type_info = new String[]{'scontrol','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                            private String[] showLabel_type_info = new String[]{'showLabel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                private String[] showScrollbars_type_info = new String[]{'showScrollbars','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                    private String[] width_type_info = new String[]{'width','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                                            private String[] field_order_type_info = new String[]{'analyticsCloudComponent','behavior','canvas','component','customLink','emptySpace','field','height','page_x','reportChartComponent','scontrol','showLabel','showScrollbars','width'};
                                                                }
    public class MiniLayout {
        public String[] fields;
        public MetadataService.RelatedListItem[] relatedLists;
        private String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] relatedLists_type_info = new String[]{'relatedLists','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'fields','relatedLists'};
                        }
    public class RelatedListItem {
        public String[] customButtons;
        public String[] excludeButtons;
        public String[] fields;
        public String relatedList;
        public String sortField;
        public String sortOrder;
        private String[] customButtons_type_info = new String[]{'customButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] excludeButtons_type_info = new String[]{'excludeButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                private String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                    private String[] relatedList_type_info = new String[]{'relatedList','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                        private String[] sortField_type_info = new String[]{'sortField','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] sortOrder_type_info = new String[]{'sortOrder','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                    private String[] field_order_type_info = new String[]{'customButtons','excludeButtons','fields','relatedList','sortField','sortOrder'};
                                        }
    public class CustomConsoleComponents {
        public MetadataService.PrimaryTabComponents primaryTabComponents;
        public MetadataService.SubtabComponents subtabComponents;
        private String[] primaryTabComponents_type_info = new String[]{'primaryTabComponents','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] subtabComponents_type_info = new String[]{'subtabComponents','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'primaryTabComponents','subtabComponents'};
                        }
    public class PrimaryTabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'containers'};
                    }
    public class Container {
        public Integer height;
        public Boolean isContainerAutoSizeEnabled;
        public String region;
        public MetadataService.SidebarComponent[] sidebarComponents;
        public String style;
        public String unit;
        public Integer width;
        private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] isContainerAutoSizeEnabled_type_info = new String[]{'isContainerAutoSizeEnabled','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] region_type_info = new String[]{'region','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                    private String[] sidebarComponents_type_info = new String[]{'sidebarComponents','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                        private String[] style_type_info = new String[]{'style','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                            private String[] unit_type_info = new String[]{'unit','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                                private String[] width_type_info = new String[]{'width','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                        private String[] field_order_type_info = new String[]{'height','isContainerAutoSizeEnabled','region','sidebarComponents','style','unit','width'};
                                            }
    public class SidebarComponent {
        public String componentType;
        public Integer height;
        public String label;
        public String lookup;
        public String page_x;
        public MetadataService.RelatedList[] relatedLists;
        public String unit;
        public Integer width;
        private String[] componentType_type_info = new String[]{'componentType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] lookup_type_info = new String[]{'lookup','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] page_x_type_info = new String[]{'page','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] relatedLists_type_info = new String[]{'relatedLists','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                private String[] unit_type_info = new String[]{'unit','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                    private String[] width_type_info = new String[]{'width','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                            private String[] field_order_type_info = new String[]{'componentType','height','label','lookup','page_x','relatedLists','unit','width'};
                                                }
    public class RelatedList {
        public Boolean hideOnDetail;
        public String name;
        private String[] hideOnDetail_type_info = new String[]{'hideOnDetail','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] name_type_info = new String[]{'name','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                    private String[] field_order_type_info = new String[]{'hideOnDetail','name'};
                        }
    public class SubtabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'containers'};
                    }
    public class PlatformActionList {
        public String actionListContext;
        public MetadataService.PlatformActionListItem[] platformActionListItems;
        public String relatedSourceEntity;
        private String[] actionListContext_type_info = new String[]{'actionListContext','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] platformActionListItems_type_info = new String[]{'platformActionListItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                private String[] relatedSourceEntity_type_info = new String[]{'relatedSourceEntity','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                        private String[] field_order_type_info = new String[]{'actionListContext','platformActionListItems','relatedSourceEntity'};
                            }
    public class PlatformActionListItem {
        public String actionName;
        public String actionType;
        public Integer sortOrder;
        public String subtype;
        private String[] actionName_type_info = new String[]{'actionName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] actionType_type_info = new String[]{'actionType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] sortOrder_type_info = new String[]{'sortOrder','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                    private String[] subtype_type_info = new String[]{'subtype','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                            private String[] field_order_type_info = new String[]{'actionName','actionType','sortOrder','subtype'};
                                }
    public class QuickActionList {
        public MetadataService.QuickActionListItem[] quickActionListItems;
        private String[] quickActionListItems_type_info = new String[]{'quickActionListItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'quickActionListItems'};
                    }
    public class QuickActionListItem {
        public String quickActionName;
        private String[] quickActionName_type_info = new String[]{'quickActionName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'quickActionName'};
                    }
    public class RelatedContent {
        public MetadataService.RelatedContentItem[] relatedContentItems;
        private String[] relatedContentItems_type_info = new String[]{'relatedContentItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'relatedContentItems'};
                    }
    public class RelatedContentItem {
        public MetadataService.LayoutItem layoutItem;
        private String[] layoutItem_type_info = new String[]{'layoutItem','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                private String[] field_order_type_info = new String[]{'layoutItem'};
                    }
    public class SummaryLayout {
        public String masterLabel;
        public Integer sizeX;
        public Integer sizeY;
        public Integer sizeZ;
        public MetadataService.SummaryLayoutItem[] summaryLayoutItems;
        public String summaryLayoutStyle;
        private String[] masterLabel_type_info = new String[]{'masterLabel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] sizeX_type_info = new String[]{'sizeX','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] sizeY_type_info = new String[]{'sizeY','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] sizeZ_type_info = new String[]{'sizeZ','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] summaryLayoutItems_type_info = new String[]{'summaryLayoutItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                            private String[] summaryLayoutStyle_type_info = new String[]{'summaryLayoutStyle','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                    private String[] field_order_type_info = new String[]{'masterLabel','sizeX','sizeY','sizeZ','summaryLayoutItems','summaryLayoutStyle'};
                                        }
    public class FeedLayout {
        public Boolean autocollapsePublisher;
        public Boolean compactFeed;
        public String feedFilterPosition;
        public MetadataService.FeedLayoutFilter[] feedFilters;
        public Boolean fullWidthFeed;
        public Boolean hideSidebar;
        public Boolean highlightExternalFeedItems;
        public MetadataService.FeedLayoutComponent[] leftComponents;
        public MetadataService.FeedLayoutComponent[] rightComponents;
        public Boolean useInlineFiltersInConsole;
        private String[] autocollapsePublisher_type_info = new String[]{'autocollapsePublisher','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] compactFeed_type_info = new String[]{'compactFeed','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] feedFilterPosition_type_info = new String[]{'feedFilterPosition','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] feedFilters_type_info = new String[]{'feedFilters','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                        private String[] fullWidthFeed_type_info = new String[]{'fullWidthFeed','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] hideSidebar_type_info = new String[]{'hideSidebar','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                private String[] highlightExternalFeedItems_type_info = new String[]{'highlightExternalFeedItems','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                    private String[] leftComponents_type_info = new String[]{'leftComponents','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                        private String[] rightComponents_type_info = new String[]{'rightComponents','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                            private String[] useInlineFiltersInConsole_type_info = new String[]{'useInlineFiltersInConsole','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                                    private String[] field_order_type_info = new String[]{'autocollapsePublisher','compactFeed','feedFilterPosition','feedFilters','fullWidthFeed','hideSidebar','highlightExternalFeedItems','leftComponents','rightComponents','useInlineFiltersInConsole'};
                                                        }
    
    public class FeedLayoutFilter {
        public String feedFilterName;
        public String feedFilterType;
        public String feedItemType;
        private String[] feedFilterName_type_info = new String[]{'feedFilterName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] feedFilterType_type_info = new String[]{'feedFilterType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                private String[] feedItemType_type_info = new String[]{'feedItemType','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                        private String[] field_order_type_info = new String[]{'feedFilterName','feedFilterType','feedItemType'};
                            }
    public class FeedLayoutComponent {
        public String componentType;
        public Integer height;
        public String page_x;
        private String[] componentType_type_info = new String[]{'componentType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
            private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] page_x_type_info = new String[]{'page','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                        private String[] field_order_type_info = new String[]{'componentType','height','page_x'};
                            }
    public class SummaryLayoutItem {
        public String customLink;
        public String field;
        public Integer posX;
        public Integer posY;
        public Integer posZ;
        private String[] customLink_type_info = new String[]{'customLink','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            private String[] field_type_info = new String[]{'field','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] posX_type_info = new String[]{'posX','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
                    private String[] posY_type_info = new String[]{'posY','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                        private String[] posZ_type_info = new String[]{'posZ','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                private String[] field_order_type_info = new String[]{'customLink','field','posX','posY','posZ'};
                                    }
    public class Layout extends Metadata {
        public String type = 'Layout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
            public String[] customButtons;
        public MetadataService.CustomConsoleComponents customConsoleComponents;
        public Boolean emailDefault;
        public String[] excludeButtons;
        public MetadataService.FeedLayout feedLayout;
        public String[] headers;
        public MetadataService.LayoutSection[] layoutSections;
        public MetadataService.MiniLayout miniLayout;
        public String[] multilineLayoutFields;
        public MetadataService.PlatformActionList platformActionList;
        public MetadataService.QuickActionList quickActionList;
        public MetadataService.RelatedContent relatedContent;
        public MetadataService.RelatedListItem[] relatedLists;
        public String[] relatedObjects;
        public Boolean runAssignmentRulesDefault;
        public Boolean showEmailCheckbox;
        public Boolean showHighlightsPanel;
        public Boolean showInteractionLogPanel;
        public Boolean showKnowledgeComponent;
        public Boolean showRunAssignmentRulesCheckbox;
        public Boolean showSolutionSection;
        public Boolean showSubmitAndAttachButton;
        public MetadataService.SummaryLayout summaryLayout;
        private String[] customButtons_type_info = new String[]{'customButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
            private String[] customConsoleComponents_type_info = new String[]{'customConsoleComponents','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                private String[] emailDefault_type_info = new String[]{'emailDefault','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                    private String[] excludeButtons_type_info = new String[]{'excludeButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                        private String[] feedLayout_type_info = new String[]{'feedLayout','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                            private String[] headers_type_info = new String[]{'headers','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                private String[] layoutSections_type_info = new String[]{'layoutSections','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                    private String[] miniLayout_type_info = new String[]{'miniLayout','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                        private String[] multilineLayoutFields_type_info = new String[]{'multilineLayoutFields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                            private String[] platformActionList_type_info = new String[]{'platformActionList','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                private String[] quickActionList_type_info = new String[]{'quickActionList','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                    private String[] relatedContent_type_info = new String[]{'relatedContent','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                        private String[] relatedLists_type_info = new String[]{'relatedLists','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                            private String[] relatedObjects_type_info = new String[]{'relatedObjects','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
                                                                private String[] runAssignmentRulesDefault_type_info = new String[]{'runAssignmentRulesDefault','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                    private String[] showEmailCheckbox_type_info = new String[]{'showEmailCheckbox','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                        private String[] showHighlightsPanel_type_info = new String[]{'showHighlightsPanel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                            private String[] showInteractionLogPanel_type_info = new String[]{'showInteractionLogPanel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                                private String[] showKnowledgeComponent_type_info = new String[]{'showKnowledgeComponent','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                                    private String[] showRunAssignmentRulesCheckbox_type_info = new String[]{'showRunAssignmentRulesCheckbox','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                                        private String[] showSolutionSection_type_info = new String[]{'showSolutionSection','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                                            private String[] showSubmitAndAttachButton_type_info = new String[]{'showSubmitAndAttachButton','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                                                private String[] summaryLayout_type_info = new String[]{'summaryLayout','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
                                                                                                    private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
                                                                                                        private String[] type_att_info = new String[]{'xsi:type'};
                                                                                                            private String[] field_order_type_info = new String[]{'fullName', 'customButtons','customConsoleComponents','emailDefault','excludeButtons','feedLayout','headers','layoutSections','miniLayout','multilineLayoutFields','platformActionList','quickActionList','relatedContent','relatedLists','relatedObjects','runAssignmentRulesDefault','showEmailCheckbox','showHighlightsPanel','showInteractionLogPanel','showKnowledgeComponent','showRunAssignmentRulesCheckbox','showSolutionSection','showSubmitAndAttachButton','summaryLayout'};
                                                                                                                }
    
    public class MetadataPort {
        public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/36.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public MetadataService.SessionHeader_element SessionHeader;
        public MetadataService.DebuggingInfo_element DebuggingInfo;
        public MetadataService.DebuggingHeader_element DebuggingHeader;
        public MetadataService.CallOptions_element CallOptions;
        public MetadataService.AllOrNoneHeader_element AllOrNoneHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata', 'MetadataService'};
            public MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {
                MetadataService.readMetadata_element request_x = new MetadataService.readMetadata_element();
                request_x.type_x = type_x;
                request_x.fullNames = fullNames;
                MetadataService.IReadResponseElement response_x;
                Map<String, MetadataService.IReadResponseElement> response_map_x = new Map<String, MetadataService.IReadResponseElement>();
                response_map_x.put('response_x', response_x);
                WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                        '',
                        'http://soap.sforce.com/2006/04/metadata',
                        'readMetadata',
                        'http://soap.sforce.com/2006/04/metadata',
                        'readMetadataResponse',
                        'MetadataService.read' + type_x + 'Response_element'}
                );
                response_x = response_map_x.get('response_x');
                return response_x.getResult();
            }
    }
}