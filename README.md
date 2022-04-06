# Fielo Double Points Issue

## Pre Conditions:
- Install FieloPLT 2.114.28 (or any version before 2.114.48)
- Activate FieloPLT Library
- Activate Local Library

### Metadata
- Two custom fields in Opportunity:
    - Blocked (checkbox, default: false)
    - Member (Lookup(FieloPLT__Member__c))

- Classes
    - [Opportunity.cls](https://github.com/tibeal/doublePoints/blob/master/force-app/main/default/classes/Opportunities.cls)
```apex
public class Opportunities {

    public static void onBeforeUpdate(List<Opportunity> records, Map<Id, Opportunity> existingRecords) {
        List<FieloPLT__Event__c> oppEvents = new List<FieloPLT__Event__c>();
        for (Opportunity opp : records) {
            Opportunity oldRecord = existingRecords.get(opp.Id);
            if (opp.StageName == 'Closed Won') {
                oppEvents.add(
                    new FieloPLT__Event__c(
                        FieloPLT__Type__c = 'Opportunity',
                        FieloPLT__Member__c = opp.Member__c
                    )
                );
            }
        }
        insert oppEvents;
    }

    public static void onAfterUpdate(List<Opportunity> records, Map<Id, Opportunity> existingRecords) {
        for (Opportunity opp : records) {
            Opportunity oldRecord = existingRecords.get(opp.Id);
            if (opp.Blocked__c == true && oldRecord.Blocked__c == true) {
                opp.addError('Blocked Opportunities are not allowed to be updated.');
            }
        }
    }
}
```
- Triggers
    - [Opportunity.trigger](https://github.com/tibeal/doublePoints/blob/master/force-app/main/default/triggers/Opportunities.trigger)
```apex
trigger Opportunities on Opportunity (before update, after update){
	if(Trigger.isBefore && Trigger.isUpdate) {
		Opportunities.onBeforeUpdate(Trigger.new, Trigger.oldMap);
	} else if(Trigger.isAfter && Trigger.isUpdate){
		Opportunities.onAfterUpdate(Trigger.new, Trigger.oldMap);
	}
}
```

### Business Rules
- Whenever an opportunity is updated to Stage = Closed Won a Fielo Event with Type = Opportunity is created and incentivized
- There is a validation in the after trigger of opportunity:
    - Opportunities with the field Blocked = true when updated throw an error "Blocked Opportunities are not allowed to be modified."

### Program Configuration
- 1 promotion
- 1 Rule on Generate event and win
    - 1 point per event

| ![Promotion](https://github.com/tibeal/doublePoints/blob/master/assets/doublePoints_Promotion.png) |
| ------ |

## Steps to reproduce

Create the Opportunities:
Run the following code in the anonymous window
Gear Icon on top right corner > Developer Console

| ![Developer Console](https://github.com/tibeal/doublePoints/blob/master/assets/doublePoints_devConsole.png) |
| ------ |

On the developer console > Debug > Open Execute Anonymous Window

| ![Execute Anonymous Window](https://github.com/tibeal/doublePoints/blob/master/assets/doublePoints_executeApex.png) |
| ------ |

Execute the code [createOpps.apex](https://github.com/tibeal/doublePoints/blob/master/scripts/apex/createOpps.apex)

```apex
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
```

This code creates:
- 2 members
- 2 opportunities the members
- 1 opportunity without member and with Blocked__c = true

After executing the code, open the log and filter by debugs
Get the 4 ids that will appear in the log

| ![Debug Log](https://github.com/tibeal/doublePoints/blob/master/assets/doublePoints_debugLog.png) |
| ------ |

Then, run the query (replacing by your ids):

```SQL
SELECT Id, Member__r.Name, Member__r.FieloPLT__Points__c, Blocked__c, Amount, StageName FROM Opportunity WHERE
Id IN (
'0068c00000pvOGOAA2','0068c00000pvOGPAA2','0068c00000pvOGQAA2','0068c00000pvOGRAA2','0068c00000pvOGSAA2'
)
```

Results:
| ![Query Results 1](https://github.com/tibeal/doublePoints/blob/master/assets/doublePoints_queryResult1.png) |
| ------ |

After checking the opportunities go back to the Execute Anonymous Window

And run the code [processOpps.apex](https://github.com/tibeal/doublePoints/blob/master/scripts/apex/processOpps.apex)

Replacing the oppIds variable with your opportunity ids.

```apex

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
```

This code will update (in a partial dml) all opportunities from StageName = Prospecting to StageName = Closed Won, but the opportunity with Blocked__c = true will throw an error and should rollback everything that was generated by the first attempt of the partial dml.

## The expected result:
Both members receive 2 points

## Current result
Both members receive 4 points

Error:
| ![Query Results 2](https://github.com/tibeal/doublePoints/blob/master/assets/doublePoints_queryResult2.png) |
| ------ |