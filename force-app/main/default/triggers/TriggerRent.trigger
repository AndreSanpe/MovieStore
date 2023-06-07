trigger TriggerRent on Rent__c (after insert, after update, before insert, after delete) {
    RentBO re = new RentBO();

    if(Trigger.isInsert && Trigger.isAfter){
        re.updateStatusInventoryItem(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
      re.setContactStatusDefaulting(Trigger.new);
      re.setReservedItmCountingDown(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isBefore && Trigger.isInsert) {
     	re.cantAddDuplicatedItem(Trigger.new);
        re.blockStatusDefalting(Trigger.new);
    } 
    if(Trigger.isDelete){
        re.updateContactAndItemStatus(Trigger.old); 
    }
}