({
	getInvoiceLineItems : function(component, event, helper) {
        helper.fetchInvoiceLineItems(component, event, helper);
	},
	/*getDiscountDetails : function(component, event, helper) {
        helper.makeCallout(component, event, helper);
	},*/
    InvoiceLineItemSectionDetails : function(component, event, helper) {
       helper.InvoiceLineItemSection(component,event,'section');
    },
})