public with sharing class MovieWishListController {

    @AuraEnabled
    public static String createWishMovie(String name, String ContactId) {
        MovieWishList__c movieWish = new MovieWishList__c();
        movieWish.MovieName__c = name;
        movieWish.Contact__c = ContactId;
        try {
            
            insert movieWish;
            return 'success';
        } catch (Exception e) {
            return 'error';
            
        }

    }
}
