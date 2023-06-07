public with sharing class ContactBO {
    public static void CPFValidationTrigger(List<Contact> newList) {
        Map<String, Id> cpfContactValidToRecorId = new Map<String, Id>();
        Map<String, Id> cpfContactInvalidToRecordId = new Map<String, Id>();

        for (Contact record : newList) {
            String cpf = record.CPF__c;
            if (cpf == null || !validateCPF(cpf)) {
                cpfContactInvalidToRecordId.put(cpf, record.Id);
            } else {
                cpfContactValidToRecorId.put(cpf, record.Id);
            }
        }
        
        List<Contact> cpfContactListValid = [SELECT Id, Name, CPF__c FROM Contact WHERE CPF__c IN :cpfContactValidToRecorId.keySet()];
        System.debug('cpfContactListValid : '+cpfContactListValid);

        List<Contact> toUpdateValid = new List<Contact>(); 
        for (Contact cpfContact : cpfContactListValid) {
            cpfContact.CPFValidation__c = true;
            System.debug('cpfContact.CPFValidation__c : '+cpfContact.CPFValidation__c);
            toUpdateValid.add(cpfContact);
        }
        
        List<Contact> cpfContactListInvalid = [SELECT Id, Name, CPF__c FROM Contact WHERE CPF__c IN :cpfContactInvalidToRecordId.keySet()];
        List<Contact> toUpdateInvalid = new List<Contact>();
        
        for (Contact cpfContact : cpfContactListInvalid) {
            cpfContact.CPFValidation__c = false;
            toUpdateInvalid.add(cpfContact);
        }
        System.debug('toUpdateValid : '+toUpdateValid);

        update toUpdateValid;
        update toUpdateInvalid;
    }
    
    public static boolean validateCPF(String CPF) {

            if (CPF.equals('00000000000') || CPF.equals('11111111111') ||
                CPF.equals('22222222222') || CPF.equals('33333333333') ||
                CPF.equals('44444444444') || CPF.equals('55555555555') ||
                CPF.equals('66666666666') || CPF.equals('77777777777') ||
                CPF.equals('88888888888') || CPF.equals('99999999999') ||
               (CPF.length() != 11))

               return(false);
        
            Integer dig10, dig11, sm, i, r, num, peso;
         
               
              sm = 0;
              peso = 10;
              List<String> cpfString = cpf.split('');
              for (i=0; i<9; i++) {
                num = Integer.valueOf(cpfString[i]); 
                sm = sm + (num * peso);
                peso = peso - 1;
              }
        
              r = 11 - (math.mod(sm,11));
              if ((r == 10) || (r == 11))
                 dig10 = 0;
              else dig10 = r;
        
        // Calculo do 2o. Digito Verificador
              sm = 0;
              peso = 11;
              for(i=0; i<10; i++) {
                num = Integer.valueOf(cpfString[i]);
                sm = sm + (num * peso);
                peso = peso - 1;
              }
        
              r = 11 - (math.mod(sm,11));
              if ((r == 10) || (r == 11))
                 dig11 = 0;
              else dig11 = r;
        
        // Verifica se os digitos calculados conferem com os digitos informados.
              if (dig10 == Integer.valueOf(cpfString[9]) && dig11 == Integer.ValueOf(cpfString[10]))
                 return true;
              else return false;
          }
        
    public static String imprimeCPF(String CPF) {
        return(CPF.substring(0, 3) + '.' + CPF.substring(3, 6) + '.' +
            CPF.substring(6, 9) + '-' + CPF.substring(9, 11));
        } 
}
