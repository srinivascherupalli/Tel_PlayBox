/*************************************************************************************************
Name : OneFundInvoiceRequestDTO
Description : Request DTO for Invoice by Number/PDF Callout
Author: Vamshi
Story: EDGE-124053
***************************************************************************************************/
@IsTest
public class OneFundInvoiceResponseDTOTest {
	
	static testMethod void testParse() {
		String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
		OneFundInvoiceResponseDTO obj = OneFundInvoiceResponseDTO.parse(json);
		System.assert(obj != null);
	}
    
    
   
    
}