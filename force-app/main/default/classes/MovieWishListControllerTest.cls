@isTest
public with sharing class MovieWishListControllerTest {
    @isTest static void createWishSuccess() {
        Contact contactTest = new Contact(LastName = 'Test Contact');
        insert contactTest;

        Test.startTest();

        String Result = MovieWishListController.createWishMovie('Wish Movie Name', contactTest.Id);

        Test.stopTest();
        MovieWishList__c movieWish = [SELECT Id FROM MovieWishList__c];

        System.Assert(movieWish != null);
        System.assertEquals('success', Result);
    }
    @isTest static void createWishError() {
 
        Test.startTest();

        String Result = MovieWishListController.createWishMovie('Wish Movie Name', null);

        Test.stopTest();

        System.assertEquals('error', Result);
    }
}