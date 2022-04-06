List<FieloPLT__Program__c> programs = [SELECT Id FROM FieloPLT__Program__c WHERE Name = 'Default'];
if (programs.isEmpty()) {
    programs.add(new FieloPLT__Program__c(
        Name = 'Default',
        FieloPLT__OnlineTransactionProcessing__c = true//,
    ));
    insert programs;
}

List<Account> fieloAcc = [SELECT Id FROM Account WHERE Name = 'Fielo Members'];

if (fieloAcc.isEmpty()) {
    fieloAcc.add(new Account(Name='Fielo Members'));
    insert fieloAcc;
}

Integer memberCount = Database.countQuery('SELECT COUNT() FROM FieloPLT__Member__c WHERE FieloPLT__Program__c = \'' + programs[0].Id + '\'');

List<FieloPLT__Member__c> members = new List<FieloPLT__Member__c>();

String memberName;
for(Integer i = 1; i <= 2; i++) {
    memberName = 'Member ' + (memberCount+i);
    members.add(
        new FieloPLT__Member__c(
            Name = memberName,
            FieloPLT__Email__c = (memberName).trim().replace(' ','.') + '@email.com',
            FieloPLT__Program__c = programs.get(0).Id,
            FieloPLT__Account__c = fieloAcc.get(0).Id
        )
    );
}

insert members;