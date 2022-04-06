
Set<Id> oppIds = new Set<Id>{
    // CHANGE ME
    '0068c00000pvOGOAA2','0068c00000pvOGPAA2','0068c00000pvOGQAA2','0068c00000pvOGRAA2','0068c00000pvOGSAA2'
};

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

List<Opportunity> opps = new List<Opportunity>();
for(Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN :oppIds]){
    opps.add(
        new Opportunity(
            Name = 'Opp Test ' + toBase62(System.now().getTime()),
            Id = opp.Id,
            StageName = 'Closed Won'
        )
    );
}

Savepoint sp = Database.setSavePoint();

List<Database.SaveResult> results = Database.update(opps, false);