public static String guid(){
    Blob b = Crypto.GenerateAESKey(128);
    String h = EncodingUtil.ConvertTohex(b);
    String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    return guid;
}

public static string toBase62(Long n) {
    List<String> numbers = new List<String>{
        '0','1','2','3','4','5','6','7','8','9',
        'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
        'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
    };

    List<String> digits = new List<String>();

    if (n == 0) {
        return '0';
    } else {
        while (n > 0) {
            if (digits.isEmpty()) {
                digits.add(numbers.get(Math.mod(n, 62).intValue()));
            } else {
                digits.add(0, numbers.get(Math.mod(n, 62).intValue()));
            }
            n = Math.ceil(n/62).longValue();
        }
        return String.join(digits,'');
    }
}

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

List<Opportunity> opps = new List<Opportunity>();

for(FieloPLT__Member__c m : members) {
    opps.add(
        new Opportunity(
            Name = 'Opp Test ' + toBase62(System.now().getTime()),
            StageName = 'Prospecting',
            Member__c = m.Id,
            CloseDate = System.today(),
            Amount = 100
        )
    );
    opps.add(
        new Opportunity(
            Name = 'Opp Test ' + toBase62(System.now().getTime()),
            StageName = 'Prospecting',
            Member__c = m.Id,
            CloseDate = System.today(),
            Amount = 100
        )
    );
}

opps.add(
    new Opportunity(
        Name = 'Opp Test ' + toBase62(System.now().getTime()),
        StageName = 'Prospecting',
        CloseDate = System.today(),
        Amount = 101
    )
);

opps.get(opps.size()-1).Blocked__c = true;

insert opps;

System.debug('Opps inserted: ' +
    JSON.serialize(new Map<Id,Opportunity>(opps).keySet()).replaceAll('"','\'')
);