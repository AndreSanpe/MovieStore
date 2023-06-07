public class InventoryItemDAO {
    public static List<Inventory_Item__c> getInventoryItemById(List<Id> listId){
       return [SELECT id, Status__c FROM Inventory_Item__c WHERE id IN:listId];
    } 
} 