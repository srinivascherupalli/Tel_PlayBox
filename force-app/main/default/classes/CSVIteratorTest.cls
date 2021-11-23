@IsTest
public class CSVIteratorTest {

    private static String introValue = Constants_PLR.NEWLINE_CHAR;        
    private static String fileData = '\"EVENT_TYPE\",\"TIMESTAMP\"'+ '\n' +
                                     '\"LightningInteraction\",\"20170712005914.852\"'+ '\n' +
                                     '\"LightningInteraction\",\"20170712005915.102\"';

    @isTest
    static void headerTest() {
        CSVIterator csvItr = new CSVIterator(fileData, introValue);
        System.assert(String.isNotBlank(csvItr.m_CSVDataHeader), 'Error: Missing header row');
        
        String headerRow = csvItr.m_CSVDataHeader.replace('"','');
        System.debug('HeaderRow: ' + headerRow);
        System.assert(headerRow.containsIgnoreCase('EVENT_TYPE'), 'Error: Missing Header');

        List<String> headers = headerRow.split(',');        
        System.assertEquals(headers.size(), 2, 'Error: Unexpected Header column count');    
    }

    @isTest
    static void hasNextTest() {
        CSVIterator csvItr = new CSVIterator(fileData, introValue);
        System.assert(csvItr.hasNext(), 'Error: Iterator cannot find next record');            
    }
    
    @isTest
    static void nextTest() {
        CSVIterator csvItr = new CSVIterator(fileData, introValue);
        System.assert(csvItr.next() != null, 'Error: Not able to retrieve first event record');
    }    
    
    @isTest
    static void iteratorTest() {        
        CSVIterator csvItr = new CSVIterator(fileData, introValue);
        Iterator<String> iterator = csvItr.Iterator();
        
        System.assert(iterator.hasNext(), 'Error: Iterator cannot find next record');                
    }       
}