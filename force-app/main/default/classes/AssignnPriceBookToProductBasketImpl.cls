public with sharing class AssignnPriceBookToProductBasketImpl implements AssignPriceBookToProductBasket 
{
	private static string StandardPriceBookId=null;
	
	public map<string,string> AssignPriceBook(set<string> setProductBasketId)
	{
		if (StandardPriceBookId==null)
		{
			if (Test.isRunningTest())
			{
				StandardPriceBookId = Test.getStandardPricebookId();
			}
			else
			{
				list<Pricebook2> lstPriceBook = [select Id, IsActive, IsStandard from Pricebook2 where IsStandard=true];
			
				StandardPriceBookId = lstPriceBook[0].Id;
			}
		}
		
		map<string,string> mapProductBasketIdPriceBookId = new map<string,string>();
		
		for (string tmpProductBasketId : setProductBasketId)
		{
			mapProductBasketIdPriceBookId.put(tmpProductBasketId,StandardPriceBookId);
		}
		
		return mapProductBasketIdPriceBookId;
	}
}