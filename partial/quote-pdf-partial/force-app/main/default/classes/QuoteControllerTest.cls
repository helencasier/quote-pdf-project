@isTest
public with sharing class QuoteControllerTest {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        // Create Contact
        Contact contact = new Contact(
            FirstName = 'Jane', LastName = 'Doe', Email = 'jane.doe@example.com', AccountId = acct.Id
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

        // Create Quote
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Status = 'Draft',
            ExpirationDate = System.today().addDays(15),
            BillingName = 'Test Billing Name'
        );
        insert quote;

        // Create Product & PricebookEntry
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = pricebook.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

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

        System.assertEquals('Jane Doe', controller.primaryContactName, 'Primary Contact Name mismatch');
        System.assertEquals('jane.doe@example.com', controller.primaryContactEmail, 'Primary Contact Email mismatch');
        System.assert(controller.hasDiscounts == false, 'Discount flag should be false');
        System.assertNotEquals(null, controller.getLegalTerms(), 'Legal Terms should not be null');
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

        System.assertEquals('Not specified', controller.primaryContactName, 'Primary Contact Name fallback mismatch');
        System.assertEquals('Not specified', controller.primaryContactEmail, 'Primary Contact Email fallback mismatch');
        Test.stopTest();
    }
}
