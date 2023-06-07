@isTest
public with sharing class ContactBOTest {
    @isTest
    public static void validateCPFTest() {
        String[] cpfArray = new String[]{
            '10049583662',
            '09325368676',
            '14302674610',
            '42714179800',
            '35737691870',
            '18219822821',
            '31081862807',
            '27272945818',
            '08870904865'
        };
     
        // Map<String,Boolean> mapCPFToResult = new Map<String,Boolean>();
        for(String cpf: cpfArray){
            // mapCPFToResult.put(cpf,ContactBO.validateCPF(cpf));
            System.assert(ContactBO.validateCPF(cpf));
        }


    }
}