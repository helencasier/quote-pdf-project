@isTest
public with sharing class QuoteControllerTest {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        // Create Contact
        Contact contact = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            AccountId = acct.Id
        );
        insert contact;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            AccountId = acct.Id
        );
        insert opp;

        // Set Primary Contact on Opportunity
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = contact.Id,
            Role = 'Decision Maker',
            IsPrimary = true
        );
        insert oppContactRole;

        // Fetch Standard Price Book
        Id standardPricebookId = Test.getStandardPricebookId();

        // Create Product
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        // Insert Standard Price (must exist before custom prices)
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPrice;

        // Fetch Custom Pricebook (if needed)
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Price Book',
            IsActive = true
        );
        insert customPricebook;

        // Insert custom PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = customPricebook.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

                
        // Get a User Id for lookup fields if needed
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Status = 'Draft',
            ExpirationDate = System.today().addDays(15),
            BillingName = 'Test Billing Name',
            Send_key_to__c = contact.Id,      // Use Contact Id
            send_invoice_to__c = contact.Id,  // Use Contact Id
            Pricebook2Id = customPricebook.Id
        );
        insert quote;



        // Create QuoteLineItem
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 100
        );
        insert qli;

        // Create Legal Document
        Legal_document__c legalDoc = new Legal_document__c(
            Name = 'Standard T&C',
            Component__c = 'Direct',
            Type__c = 'T&C',
            Status__c = 'Active',
            Content__c = 'These are the legal terms.',
            Version__c = 'v1.0'
        );
        insert legalDoc;
    }

    @isTest
    static void testQuoteControllerWithPrimaryContact() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testQuote);
        QuoteController controller = new QuoteController(stdCtrl);

        // Assert Primary Contact
        System.assertEquals('Jane Doe', controller.primaryContactName, 'Primary Contact Name mismatch');
        System.assertEquals('jane.doe@example.com', controller.primaryContactEmail, 'Primary Contact Email mismatch');

        // Assert other properties
        System.assertEquals(false, controller.hasDiscounts, 'Discount flag should be false');
        System.assertNotEquals(null, controller.getLegalTerms(), 'Legal Terms should not be null');
        System.assert(controller.wrappedLineItems.size() > 0, 'Quote should have line items');
        Test.stopTest();
    }

    @isTest
    static void testQuoteControllerWithoutPrimaryContact() {
        // Remove OpportunityContactRole to test fallback
        delete [SELECT Id FROM OpportunityContactRole LIMIT 1];

        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testQuote);
        QuoteController controller = new QuoteController(stdCtrl);

        // Assert fallback for Primary Contact
       System.assertEquals('N/A', controller.primaryContactName, 'Primary Contact Name fallback mismatch');
        System.assertEquals('N/A', controller.primaryContactEmail, 'Primary Contact Email fallback mismatch');


        Test.stopTest();
    }
}
