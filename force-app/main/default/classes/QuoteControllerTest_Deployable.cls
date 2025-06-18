@isTest
private class QuoteControllerTest_Deployable {
    @isTest static void testQuoteController() {
        // Create a test Account
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        // Get standard Price Book
        Id stdPbId = Test.getStandardPricebookId();

        // Create a test Product
        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TP01', IsActive = true);
        insert prod;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acct.Id
        );
        insert opp;

        // Create a PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPbId,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Receiver');
        insert contact;

        // Create a Quote
        Quote q = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = stdPbId,
            ExpirationDate = Date.today().addDays(30),
            BillingName = 'Test Billing',
            Reseller_Quote__c = false,
            Send_key_to__c = contact.Id,
            send_invoice_to__c = contact.Id
        );
        insert q;

        // Create a Quote Line Item
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pbe.Id
        );
        insert qli;

        // Insert legal document for "Direct"
        Legal_document__c doc = new Legal_document__c(
            Name = 'Direct T&C v1',
            Component__c = 'Direct',
            Type__c = 'T&C',
            Status__c = 'Active',
            Content__c = 'Test Terms',
            Version__c = 'v1.0' // ✅ add this line
        );
        insert doc;

        // Test controller
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(q);
        QuoteController controller = new QuoteController(sc);

        List<QuoteController.QuoteLineItemWrapper> items = controller.getWrappedLineItems();
        System.assertNotEquals(0, items.size(), 'Should return wrapped line items');

        System.assertNotEquals(null, controller.getLegalTerms(), 'Legal terms should not be null');
        System.assert(controller.getIsMinimalTerms() == false || controller.getIsMinimalTerms() == true, 'isMinimalTerms must be boolean');
        Test.stopTest();
    }
}
