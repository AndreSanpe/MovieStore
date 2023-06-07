@isTest
public class RentBOTest {
 
@isTest static void cantCreatRentWithoutContact(){
    Inventory__c inventory = new Inventory__c(RecordTypeId = '0128b000001MpG2AAK', Name = 'Test Movie');
    Inventory_Item__c inventoryItem = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');

    Rent__c rent = new Rent__c();
        rent.Inventory_Item__c = inventoryItem.Id;
        System.debug('inventoryItem.Id : '+inventoryItem.Id);

        rent.LocationDate__c = Date.today();
        rent.CloseDate__c = Date.today().addMonths(1);

    Test.startTest();
    Database.SaveResult result = Database.insert(rent, false);
    Test.stopTest();

    System.assert(result.getErrors().size() > 0);
    System.assert(result.isSuccess() == false, 'You should insert Contact__c');
}
@isTest static void cantCreatRent(){
    Rent__c rent = new Rent__c();
    Test.startTest();
    Database.SaveResult result = Database.insert(rent, false);
    Test.stopTest();

    System.assert(result.getErrors().size() > 0);
    System.assert(result.isSuccess() == false, 'You should insert Inventory_Item__c and Contact__c');
}
@isTest static void createOneRentSuccess() {
    Inventory__c inventory = new Inventory__c(RecordTypeId = '0128b000001MpG2AAK', Name = 'Test Movie');
    insert inventory;
    Inventory_Item__c inventoryItem = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem;
    Contact contactTest = new Contact(LastName = 'Test Movie');
    insert contactTest;


    Rent__c rent = new Rent__c();
        rent.Contact__c = contactTest.Id;
        System.debug('contactTest.Id : '+contactTest.Id);

        rent.Inventory_Item__c = inventoryItem.Id;
        System.debug('inventoryItem.Id : '+inventoryItem.Id);

        rent.LocationDate__c = Date.today();
        rent.CloseDate__c = Date.today().addMonths(1);

    Test.startTest();
    Database.SaveResult result = Database.insert(rent, false);
    Test.stopTest();

    Inventory_Item__c chckingStatus = [SELECT Status__c FROM Inventory_Item__c WHERE id = :inventoryItem.Id LIMIT 1];
    System.AssertEquals('Rented', chckingStatus.Status__c);

    System.Assert(result.isSuccess());

}
@isTest static void alreadyRented() {
    Inventory__c inventory = new Inventory__c(RecordTypeId = '0128b000001MpG2AAK', Name = 'Test Movie');
    insert inventory;
    Inventory_Item__c inventoryItem = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem;
    Contact contactTest = new Contact(LastName = 'Test Movie');
    insert contactTest;


    Rent__c rent = new Rent__c();
        rent.Contact__c = contactTest.Id;
        System.debug('contactTest.Id : '+contactTest.Id);

        rent.Inventory_Item__c = inventoryItem.Id;
        System.debug('inventoryItem.Id : '+inventoryItem.Id);

        rent.LocationDate__c = Date.today();
        rent.CloseDate__c = Date.today().addMonths(1);
        
    Rent__c rent2 = new Rent__c();
        rent2.Contact__c = contactTest.Id;
        System.debug('contactTest.Id : '+contactTest.Id);

        rent2.Inventory_Item__c = inventoryItem.Id;
        System.debug('inventoryItem.Id : '+inventoryItem.Id);

        rent2.LocationDate__c = Date.today();
        rent2.CloseDate__c = Date.today().addMonths(1);
    
    Test.startTest();
    Database.SaveResult result = Database.insert(rent, false);
    Database.SaveResult result2 = Database.insert(rent2, false);
    Test.stopTest();

    Inventory_Item__c chckingStatus = [SELECT Status__c FROM Inventory_Item__c WHERE id = :inventoryItem.Id LIMIT 1];
    System.AssertEquals('Rented', chckingStatus.Status__c);

    System.Assert(result.isSuccess());
    System.Assert(!result2.isSuccess());

}
    @isTest
static void updateContactAndItemStatusTest() {
    Inventory__c inventory = new Inventory__c(RecordTypeId = '0128b000001MpG2AAK', Name = 'Test Movie');
    insert inventory;
    Inventory_Item__c inventoryItem = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem;
    Inventory_Item__c inventoryItem2 = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem2;
    Contact contactTest = new Contact(LastName = 'Test Movie');
    insert contactTest;
    RentBO re = new RentBO();

    Rent__c rent = new Rent__c();
    rent.Contact__c = contactTest.Id;
    rent.Inventory_Item__c = inventoryItem.Id;
    rent.LocationDate__c = Date.today();
    rent.CloseDate__c = Date.today().addMonths(1);

    insert rent;
    delete rent;

    Rent__c rent2 = new Rent__c();
    rent2.Contact__c = contactTest.Id;
    rent2.Inventory_Item__c = inventoryItem2.Id;
    rent2.LocationDate__c = Date.today();
    rent2.CloseDate__c = Date.today().addMonths(1);
    insert rent2;


    Rent__c rent3 = new Rent__c();
    rent3.Contact__c = contactTest.Id;
    rent3.Inventory_Item__c = inventoryItem.Id;
    rent3.LocationDate__c = Date.today();
    rent3.CloseDate__c = Date.today().addMonths(1);
    insert rent3;

    List<Rent__c> rentList = new List<Rent__c>();
    rentList.Add(rent);
    rentList.Add(rent2);
    rentList.Add(rent3);


    ReservedItem__c reserved1 = new ReservedItem__c();
    reserved1.Reservation__c = inventory.Id;
    reserved1.ContactName__c = contactTest.Id;
    reserved1.ReservationStatus__c = 'Waiting';

    ReservedItem__c reserved2 = new ReservedItem__c();
    reserved2.Reservation__c = inventory.Id;
    reserved2.ContactName__c = contactTest.Id;
    reserved2.ReservationStatus__c = 'Waiting';
    
    ReservedItem__c reserved3 = new ReservedItem__c();
    reserved3.Reservation__c = inventory.Id;
    reserved3.ContactName__c = contactTest.Id;
    reserved3.ReservationStatus__c = 'Waiting';
    
    insert reserved1;
    insert reserved2;
    insert reserved3;

    delete rentList;
    // Perform assertions on the expected changes caused by the trigger
    Contact checkingStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactTest.Id LIMIT 1];
    System.AssertEquals('Normal', checkingStatus.ContactStatus__c);
}
@isTest
static void setReservedItmCountingDownTest() {
    Inventory__c inventory = new Inventory__c(RecordTypeId = '0128b000001MpG2AAK', Name = 'Test Movie');
    insert inventory;
    Inventory_Item__c inventoryItem = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem;
    Inventory_Item__c inventoryItem2 = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem2;
    Inventory_Item__c inventoryItem3 = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem3;
    Contact contactTest = new Contact(LastName = 'Test Movie');
    insert contactTest;
   
    Rent__c rent = new Rent__c();
    rent.Contact__c = contactTest.Id;
    rent.Inventory_Item__c = inventoryItem.Id;
    rent.LocationFinished__c = false;
    rent.LocationDate__c = Date.today();
    rent.CloseDate__c = Date.today().addMonths(1);
    insert rent;

    Rent__c rent2 = new Rent__c();
    rent2.Contact__c = contactTest.Id;
    rent2.Inventory_Item__c = inventoryItem2.Id;
    rent.LocationFinished__c = false;
    rent2.LocationDate__c = Date.today();
    rent2.CloseDate__c = Date.today().addMonths(1);
    insert rent2;


    Rent__c rent3 = new Rent__c();
    rent3.Contact__c = contactTest.Id;
    rent3.Inventory_Item__c = inventoryItem3.Id;
    rent.LocationFinished__c = false;
    rent3.LocationDate__c = Date.today();
    rent3.CloseDate__c = Date.today().addMonths(1);
    insert rent3;

    ReservedItem__c reserved1 = new ReservedItem__c();
    reserved1.Reservation__c = inventory.Id;
    reserved1.ContactName__c = contactTest.Id;
    reserved1.ReservationStatus__c = 'Waiting';

    ReservedItem__c reserved2 = new ReservedItem__c();
    reserved2.Reservation__c = inventory.Id;
    reserved2.ContactName__c = contactTest.Id;
    reserved2.ReservationStatus__c = 'Waiting';
    
    ReservedItem__c reserved3 = new ReservedItem__c();
    reserved3.Reservation__c = inventory.Id;
    reserved3.ContactName__c = contactTest.Id;
    reserved3.ReservationStatus__c = 'Waiting';
    
    insert reserved1;
    insert reserved2;
    insert reserved3;

    Map<Id, Rent__c> mapRent = new Map<Id, Rent__c>([SELECT Id, LocationFinished__c FROM Rent__c]);

    rent3.LocationFinished__c = true;
    rent2.LocationFinished__c = true;
    update rent3;
    update rent2;

    List<Rent__c> newList = new List<Rent__c>();
    newList.add(rent);
    newList.add(rent2);
    newList.add(rent3);

    RentBO re = new RentBO();

    Test.startTest();
    re.setReservedItmCountingDown(newList, mapRent);
    Test.stopTest();

    ReservedItem__c checkingStatus = [SELECT ReservationStatus__c FROM ReservedItem__c WHERE Id = :reserved1.Id LIMIT 1];
    System.AssertEquals('Time Counting Down', checkingStatus.ReservationStatus__c);
}
@isTest
static void blockStatusDefaltingTest() {
    Inventory__c inventory = new Inventory__c(RecordTypeId = '0128b000001MpG2AAK', Name = 'Test Movie');
    insert inventory;
    Inventory_Item__c inventoryItem = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem;
    Inventory_Item__c inventoryItem2 = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem2;
    Inventory_Item__c inventoryItem3 = new Inventory_Item__c(Inventory__c = inventory.Id, Status__c = 'Available');
    insert inventoryItem3;
    Contact contactTest = new Contact(LastName = 'Test Movie');
    contactTest.ContactStatus__c = 'Defaulting';
    insert contactTest;
   
    Rent__c rent = new Rent__c();
    rent.Contact__c = contactTest.Id;
    rent.Inventory_Item__c = inventoryItem.Id;

    
    Rent__c rent2 = new Rent__c();
    rent2.Contact__c = contactTest.Id;
    rent2.Inventory_Item__c = inventoryItem.Id;
    rent2.LocationFinished__c = false;
    rent2.LocationDate__c = Date.today().addMonths(1);
    rent2.CloseDate__c = Date.today();

    List<Rent__c> newList = new List<Rent__c>();
    newList.add(rent);

    List<Rent__c> newList2 = new List<Rent__c>();
    newList.add(rent2);

    RentBO re = new RentBO();

    Test.startTest();
    re.blockStatusDefalting(newList);
    re.blockStatusDefalting(newList2);
    Test.stopTest();

    // Perform assertions on the expected changes caused by the trigger
    Contact checkingStatus = [SELECT ContactStatus__c FROM Contact WHERE Id = :contactTest.Id LIMIT 1];
    System.AssertEquals('Defaulting', checkingStatus.ContactStatus__c);
}

}