trigger TriggerContact on Contact (before insert, after insert, after update, before update) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        ContactBO.CPFValidationTrigger(Trigger.new);
      }
      if(Trigger.isInsert && Trigger.isAfter){
        ContactBO.CPFValidationTrigger(Trigger.new);
      }
  
}