public class RentBO {
    
    public void updateStatusInventoryItem(List<Rent__c> newList){

    	List<Id> listIdInventoryItems = RentBO.getListIdInventoryItem(newList);
        
        List<Inventory_Item__c> listItemReletad = InventoryItemDAO.getInventoryItemById(listIdInventoryItems);
        
        List<Inventory_Item__c> listInventoryItemToUpdate = RentBO.getListInventoryItemToUpdate(listItemReletad);														
        
        update listInventoryItemToUpdate; 
        
    }
    
    public void setContactStatusDefaulting(List<Rent__c> newList){
		//System.debug('===> newList : '+newList);
        
        List<Id> contactIdList = RentBO.getListIdContact(newList);
         
        List<Rent__c> listOfRelatedInventoryItems = [SELECT id, LocationStatus__c, Contact__c FROM Rent__c WHERE Contact__c IN :contactIdList AND 	LocationStatus__c != 'Finished'];
                 
        Map<Id, List<String>> mapContactIdToStatus =  new Map<Id, List<String>>();
            
         for(Rent__c re:listOfRelatedInventoryItems){
             List<String> auxiliar = mapContactIdToStatus.get(re.Contact__c);
             if(auxiliar != null){
                auxiliar.add(re.LocationStatus__c);
                 mapContactIdToStatus.put(re.Contact__c, auxiliar);
             }else{
                 mapContactIdToStatus.put(re.Contact__c, new List<String>{re.LocationStatus__c});
             }
         }
        If(mapContactIdToStatus.isEmpty()){
            return;
        }   
         List<Id> contactToUpdateLate = new List<Id>();
         List<Id> contactToUpdateNormal = new List<Id>();

         for(Id contactId:contactIdList){
             if(mapContactIdToStatus.get(contactId).contains('Late')){
                 contactToUpdateLate.add(contactId);
             } else {
                 contactToUpdateNormal.add(contactId);
             }
         }
         
  		List<Contact> contactListUpdate = [SELECT id, ContactStatus__c FROM Contact WHERE id IN :contactToUpdateLate];
  		List<Contact> contactListNormal = [SELECT id, ContactStatus__c FROM Contact WHERE id IN :contactToUpdateNormal];
	
       // System.debug('contactListUpdate'+contactListUpdate);

         for(Contact item:contactListUpdate){
             item.ContactStatus__c = 'Defaulting';
         }    
         for(Contact item:contactListNormal){
             item.ContactStatus__c = 'Normal';
         } 
         
         update contactListUpdate;
         update contactListNormal;
    }
    
    public void cantAddDuplicatedItem(List<Rent__c> newList){
        List<Id> listIdInventoryItems = RentBO.getListIdInventoryItem(newList);
        System.debug('newList = ' + newList);

       System.debug('listIdInventoryItems = ' + listIdInventoryItems);

        List<Inventory_Item__c> listItemReletadRented = [SELECT id, Status__c FROM Inventory_Item__c WHERE id IN :listIdInventoryItems AND Status__c = 'Rented'];
        System.debug('listItemReletadRented Querry = ' + listItemReletadRented);
        
        List<Id> lisIdItemRented = new List<Id>(); 
        
        for(Inventory_Item__c item:listItemReletadRented){
            lisIdItemRented.add(item.Id);
        }
        
       
        for(Rent__c re:newList){
            if(lisIdItemRented.contains(re.Inventory_Item__c)){
               System.debug('Entrou no if' + lisIdItemRented);
               re.addError('This Item is already Rented, please choose other');
       
            }
        }
        
    } 
    
    public void blockStatusDefalting(List<Rent__c> newList){
        List<Id> contactIdList = RentBO.getListIdContact(newList);
        
        List<Contact> listOfContact = [SELECT id, ContactStatus__c FROM Contact WHERE id IN :contactIdList];
        
      //  System.debug('listOfContact : '+listOfContact);
      
        Map<Id, List<String>> mapContactIdToStatus =  new Map<Id, List<String>>();
		
        for(Contact co:listOfContact){
             List<String> helperList = mapContactIdToStatus.get(co.Id);
             if(helperList != null){
                helperList.add(co.ContactStatus__c);
                 mapContactIdToStatus.put(co.Id, helperList);
             }else{
                 mapContactIdToStatus.put(co.Id, new List<String>{co.ContactStatus__c});
             }
         }
        
        List<Id> listOfDefaultingContactId = new List<Id>();
        List<Id> listOfNormalContatId = new List<Id>();
        
        for(Rent__c re:newList){
            if(mapContactIdToStatus.get(re.Contact__c).contains('Defaulting')){
                re.addError('This contact can not Rent any movie because their status is Defaulting');
                
              // I did this just to see if after throw the error the debug was going to run  System.debug('Rent__c : ' + re);
                    }
        }
         
    }

    public void setReservedItmCountingDown(List<Rent__c> newList, Map<Id, Rent__c> mapOld){
        List<Id> listIdInventoryItems = RentBO.getListIdInventoryItem(newList);

        Map<Id, Rent__c> mapInventoryItemToRent = new Map<Id, Rent__c>();

        for(Rent__c re:newList){
            if(mapOld.get(re.Id).LocationFinished__c == false && re.LocationFinished__c == true){
                mapInventoryItemToRent.put(re.Inventory_Item__c, re);
            }
        }
        if(mapInventoryItemToRent.isEmpty()){
            return;
        }
        
        List<Inventory_Item__c> lstInventoryItem = [SELECT Id, Inventory__r.Name, Inventory__c, Status__c 
                                                    FROM Inventory_Item__c 
                                                    WHERE id IN:mapInventoryItemToRent.keySet()];

        List<Id> lstInventoryId = new List<Id>();

        Map<Id, Inventory_Item__c> mapInventoryIdToInventoryItem = new Map<Id, Inventory_Item__c>();

        Map<Id, Integer> mapNumberOfInventoryItem = new Map<Id, Integer> ();

        for(Inventory_Item__c InventoryItem:lstInventoryItem){
            mapInventoryIdToInventoryItem.put(InventoryItem.Inventory__c, InventoryItem);

            lstInventoryId.add(InventoryItem.Inventory__c);
            Integer countInventory = mapNumberOfInventoryItem.get(InventoryItem.Inventory__c);
            if(countInventory == null){
                mapNumberOfInventoryItem.put(InventoryItem.Inventory__c, 1);
            }else {
                mapNumberOfInventoryItem.put(InventoryItem.Inventory__c, (countInventory+= 1));
            }
        }

        List<ReservedItem__c> lstReservedItem = [SELECT Reservation__c     
                                                FROM ReservedItem__c 
                                                WHERE Reservation__c IN : lstInventoryId AND 
                                                    ReservationStatus__c = 'Waiting'
                                                ORDER BY Name];
        
        Map<Id, List<ReservedItem__c>> mapInventoryIdToListOfReservedItem = new Map<Id, List<ReservedItem__c>> ();
        
        for(ReservedItem__c re:lstReservedItem){
            List<ReservedItem__c> auxLstReservedItem = mapInventoryIdToListOfReservedItem.get(re.Reservation__c);
            if(auxLstReservedItem != null){
                auxLstReservedItem.add(re);
                mapInventoryIdToListOfReservedItem.put(re.Reservation__c,auxLstReservedItem);
            }else{
                mapInventoryIdToListOfReservedItem.put(re.Reservation__c, new List<ReservedItem__c>{re});                
            }
            
        }
        // Inventory => count Inventory Item
        // Inventory => list Reserved Item
        List<ReservedItem__c> lstReservedItemToUpdate = new List<ReservedItem__c>();
        List<Inventory_Item__c> lstInventoryItemToUpload = new List<Inventory_Item__c>();

        for(Id InventoryId:mapNumberOfInventoryItem.keySet()){
            Integer countInventory = mapNumberOfInventoryItem.get(InventoryId);
            List<ReservedItem__c> listInventoryItem = mapInventoryIdToListOfReservedItem.get(InventoryId);

            if(countInventory <= 0){
                break;
            }else{
                Integer countReservedItems = 0;
                List<ReservedItem__c> auxLstReservedItem = mapInventoryIdToListOfReservedItem.get(InventoryId);
                
                for(ReservedItem__c reservedItem:auxLstReservedItem){
                    countReservedItems +=1;
                    if(countReservedItems <= countInventory){
                        reservedItem.ReservationStatus__c = 'Time Counting Down';
                        lstReservedItemToUpdate.add(reservedItem);
                        
                        Inventory_Item__c inventoryItemToUpdate = mapInventoryIdToInventoryItem.get(InventoryId);
                        // System.debug('inventoryItemToUpdate : ' +inventoryItemToUpdate);
                        inventoryItemToUpdate.Status__c = 'Reserved';
                        lstInventoryItemToUpload.add(inventoryItemToUpdate);

                    }else{
                        break;
                    }

                }

            }
        }

        update lstReservedItemToUpdate;
        update lstInventoryItemToUpload;
    }
    
    public void updateContactAndItemStatus(List<Rent__c> oldList){
        Map<Id, Rent__c> mapInventoryItemIdToRent = new Map<Id, Rent__c>();
        Map<Id, Id> mapInventoryItemIdToContactId = new Map<Id, Id>();
        Map<Id, Id> mapContactIdToInventoryItemId = new Map<Id, Id>();

        
        for(Rent__c re:oldList){
            mapInventoryItemIdToRent.put(re.Inventory_Item__c, re);
            mapInventoryItemIdToContactId.put(re.Inventory_Item__c, re.Contact__c);
            mapInventoryItemIdToContactId.put(re.Contact__c,re.Inventory_Item__c);
        }     


        List<Rent__c> lstRentedToContact = [SELECT Id, LocationStatus__c, Contact__c 
                                                            FROM Rent__c 
                                                            WHERE Contact__c IN :mapContactIdToInventoryItemId.keySet()
                                                            AND LocationStatus__c = 'Late'];

        Map<Id, Integer> mapNumberOfRentedOfContact = new Map<Id, Integer> ();

        for(Rent__c Rent:lstRentedToContact){
            Integer countLateRent = mapNumberOfRentedOfContact.get(Rent.Contact__c);
            if(countLateRent == null){
                mapNumberOfRentedOfContact.put(Rent.Contact__c, 1);
            }else {
                mapNumberOfRentedOfContact.put(Rent.Contact__c, (countLateRent+= 1));
            }
        }
        List<Id> lstContactIdToUpdate = new List<Id>();
        for(Rent__c re:oldList){
            if(mapNumberOfRentedOfContact.get(re.Contact__c) == 1){
                lstContactIdToUpdate.add(re.Contact__c);
            }else{
                break;
            }
        }
        List<Contact> lstContact = [SELECT Id, ContactStatus__c 
                                            FROM Contact 
                                            WHERE Id IN :lstContactIdToUpdate];
        List<Contact> lstContactToUpdate = new List<Contact> ();

        for(Contact con:lstContact){
            con.ContactStatus__c = 'Normal';
            lstContactToUpdate.add(con);
        }

        update lstContactToUpdate;

    } 


    private static List<Id> getListIdInventoryItem(List<Rent__c> newList){
		
      List<Id> listIdInventoryItems = new List<Id>();
        
        for(Rent__c rentItem: newList){
       		listIdInventoryItems.add(rentItem.Inventory_Item__c);
       //     System.debug('Intentory Item = '+rentItem.Inventory_Item__c);
        }
         return listIdInventoryItems;
	}
    
    private static List<Id> getListIdContact(List<Rent__c> newList){
		
      List<Id> listIdContact = new List<Id>();
        
        for(Rent__c rentItem: newList){
       		listIdContact.add(rentItem.Contact__c);
       //     System.debug('Intentory Item = '+rentItem.Inventory_Item__c);
        }
         return listIdContact;
	}
    
    private static List<Inventory_Item__c> getListInventoryItemToUpdate(List<Inventory_Item__c> listItemReletad){

 		List<Inventory_Item__c> listInventoryItemToUpdate = new List<Inventory_Item__c>();
        
        for(Inventory_Item__c item:listItemReletad){
            item.Status__c = 'Rented';
        //    System.debug('=============>Item'+item);
            listInventoryItemToUpdate.add(item);
        }	
         return listInventoryItemToUpdate;
	}
}

