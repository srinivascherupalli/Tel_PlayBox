({
    doInit : function(component, event, helper) {
		var record = component.get("v.record");
        var field = component.get("v.field");
        console.log('record********'+record);
        console.log('fields name********'+field.name);
        console.log('fields type********'+field.type);
        component.set("v.cellValue", record[field.name]);
        if(field.name != 'Name' && (field.type == 'STRING' || field.type == 'PICKLIST')){
            component.set("v.isTextField", true);
        }else if(field.name == 'Name'){
            component.set("v.isNameField", true);
            component.set("v.idValue", record['Id']);
            console.log('***record[Id]***'+component.get("v.idValue"));
        }else if(field.type == 'DATETIME'){
        	component.set("v.isDateTimeField", true);
        }else if(field.type == 'CURRENCY'){
        	component.set("v.isCurrencyField", true);
        }else if(field.type == 'BOOLEAN'){
            component.set("v.isCheckboxField", true);
        }else if(field.type == 'REFERENCE'){
        	component.set("v.isReferenceField", true);
            var relationShipName = '';
            if(field.name.indexOf('__c') == -1) {
                relationShipName = field.name.substring(0, field.name.indexOf('Id'));
            }else {
                relationShipName = field.name.substring(0, field.name.indexOf('__c')) + '__r';
            }
            component.set("v.cellLabel", record[relationShipName].Name);
        }
	}
})