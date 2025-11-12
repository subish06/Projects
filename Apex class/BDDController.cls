public class BDDController {
    
    @AuraEnabled
    public static Map<String, Object> getBDDStats(String selYear) {
        String prevYear = 'FY-'+String.valueOf(Integer.valueOf(selYear.substring(3)) - 1);
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();  
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        AggregateResult agrResult = [SELECT SUM(Target__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND BDD__c =: UserInfo.getUserId()
                                    ];
        
        //String currencyIsoCode = (String)agrResult.get('CurrencyISOCode');
        Decimal curYearTarget = (Decimal) agrResult.get('totalAmount') * currTypeMap.get(UserInfo.getDefaultCurrency());
        curYearTarget = curYearTarget.setScale(2, System.RoundingMode.HALF_UP);
        curYearTarget = curYearTarget != null ? curYearTarget : 0;
        
        agrResult = [SELECT SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND BDD__c =: UserInfo.getUserId()];
        Decimal curYearActual = (Decimal) agrResult.get('totalAmount') *currTypeMap.get(UserInfo.getDefaultCurrency());
        curYearActual = curYearActual.setScale(2, System.RoundingMode.HALF_UP);
        curYearActual = curYearActual != null ? curYearActual : 0;
        
        agrResult = [SELECT SUM(Variance_Amount__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: selYear AND BDD__c =: UserInfo.getUserId()
                    ];
        
        //String currencyIsoCodeVar = (String)agrResult.get('CurrencyISOCode');
        Decimal curYearVariance = (Decimal) agrResult.get('totalAmount') * currTypeMap.get(UserInfo.getDefaultCurrency());
        curYearVariance = curYearVariance.setScale(2, System.RoundingMode.HALF_UP);
        curYearVariance = curYearVariance != null ? curYearVariance : 0;
        
        agrResult = [SELECT SUM(Overall_Actuals__c) totalAmount FROM Target_Config__c WHERE Financial_Year__c =: prevYear AND BDD__c =: UserInfo.getUserId()];
        Decimal prevYearActual = (Decimal) agrResult.get('totalAmount');
        prevYearActual = prevYearActual != null ? prevYearActual : 0;
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('prevYear', prevYear);
        result.put('curYearTarget', curYearTarget);
        result.put('curYearActual', curYearActual);
        result.put('prevYearActual', prevYearActual);
        result.put('curYearVariance', curYearVariance);
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getBDMTargetDist(Id currentUser, String financialYear, String prevFinancialYear) {
        Decimal DBBTarget = 0;
        String currencyVal = 'USD';
        String prevFYCurrencyVal= 'USD';
        string currencySymbol =  UserInfo.getDefaultCurrency();       
        
        Map<Id, BDMTargetDist> BDMTargetDistMap = new Map<Id, BDMTargetDist>();
        for(
            Hierarchy_Config__c hConfig : 
            [SELECT Id,User__c,user__r.name,user__r.FullPhotoUrl FROM Hierarchy_Config__c 
             WHERE Role__c = 'BDM' AND Manager__c =: currentUser]
        ) {
            BDMTargetDistMap.put(
                hConfig.User__c, 
                new BDMTargetDist(hConfig.User__c, hConfig.user__r.name, hConfig.user__r.FullPhotoUrl, 0)
            );
        }
        
        for(
            Target_Distribution__c targetDist : 
            [SELECT Id, Allocated_Percentage__c, BDM__c, CurrencyIsoCode FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND 
             BDD__c =: currentUser AND BDM__c IN : BDMTargetDistMap.keySet()]
        ) {
            currencyVal = 'USD';
            currencySymbol = UserInfo.getDefaultCurrency();
            BDMTargetDistMap.get(targetDist.BDM__c).disPercent = targetDist.Allocated_Percentage__c;
        }
        
        List<Target_Distribution__c> targetDistList = 
            [SELECT Id,Overall_Target__c FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND 
             BDD__c =: currentUser AND Overall_Target__c > 0];
        
        if(!targetDistList.isEmpty()) {
            DBBTarget = targetDistList[0].Overall_Target__c;
        }
        
        List<Target_Config__c> actualList = [SELECT CurrencyIsoCode FROM Target_Config__c WHERE BDD__c =: currentUser AND Financial_Year__c =: prevFinancialYear LIMIT 1];
        if(!actualList.isEmpty()) {
            prevFYCurrencyVal = actualList[0].CurrencyIsoCode;
        }
        
        return '{"currencyVal" : "'+currencyVal+'","prevFYCurrencyVal" : "'+prevFYCurrencyVal+'","BDDTarget" : "'+DBBTarget+'", "BDMList" : '+JSON.serialize(BDMTargetDistMap.values())+',"currencySymbol" : "'+currencySymbol+'"}';
    }
    
    @AuraEnabled
    public static Boolean saveBDMTargetConfigs(Id currentUser, Decimal BDDTarget, String financialYear, String BDMDistData, String currencyVal, Boolean isAcknowledge, List<String> bdmList) { //
        List<Target_Distribution__c> targetDistList = new List<Target_Distribution__c>();
        Map<Id, Target_Distribution__c> BDMTargetDistMap = new Map<Id, Target_Distribution__c>();
        List<Target_Acknowledgement__c> tAcknowledgeList = new List<Target_Acknowledgement__c>();
        Map<Id, Target_Acknowledgement__c> existingRecordsMap = new Map<Id, Target_Acknowledgement__c>();
        List<Target_Acknowledgement_History__c> ackHistoryList = new List<Target_Acknowledgement_History__c>();
        
        for (Target_Acknowledgement__c tAcknowledge : [SELECT Id, BDD__c, BDM__c, Status__c, Financial_Year__c FROM Target_Acknowledgement__c WHERE BDD__c = :currentUser AND BDM__c IN :bdmList AND Financial_Year__c = :financialYear]) {
            existingRecordsMap.put(tAcknowledge.BDM__c, tAcknowledge);
        }
        
        
        if(isAcknowledge){
            for(Id bdmId : bdmList){
                if (existingRecordsMap.containsKey(bdmId)) {
                    Target_Acknowledgement__c existingRecord = existingRecordsMap.get(bdmId);
                    existingRecord.Status__c = 'Target sent';
                    existingRecord.Comments__c = '';
                    tAcknowledgeList.add(existingRecord);
                } else {
                    Target_Acknowledgement__c newRecord = new Target_Acknowledgement__c();
                    newRecord.BDD__c = currentUser;
                    newRecord.BDM__c = bdmId;
                    newRecord.Status__c = 'Target sent';
                    newRecord.Financial_Year__c = financialYear;
                    newRecord.Comments__c = '';
                    tAcknowledgeList.add(newRecord);
                }
            }
        }
        
        
        for(BDMTargetDist BDMTargetDist : (List<BDMTargetDist>) JSON.deserialize(BDMDistData, List<BDMTargetDist>.class)) {
            BDMTargetDistMap.put(
                BDMTargetDist.userId, 
                new Target_Distribution__c(
                    Financial_Year__c = financialYear, BDD__c = currentUser, BDM__c = BDMTargetDist.userId, 
                    Allocated_Percentage__c = BDMTargetDist.disPercent, CurrencyIsoCode = currencyVal
                )
            );
        }
        
        for(
            Target_Distribution__c targetDist : 
            [SELECT Id, Allocated_Percentage__c, BDM__c FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND 
             BDD__c =: currentUser AND BDM__c IN : BDMTargetDistMap.keySet()]
        ) {
            if(BDMTargetDistMap.containsKey(targetDist.BDM__c)) {
                BDMTargetDistMap.get(targetDist.BDM__c).Id = targetDist.Id;
            }
        }
        
        List<Target_Distribution__c> BDDTargetDistList = [SELECT Id, Overall_Target__c FROM Target_Distribution__c WHERE Financial_Year__c =: financialYear AND BDD__c =: currentUser AND Overall_Target__c != null];
        
        
        if(!tAcknowledgeList.isEmpty()){
            Upsert tAcknowledgeList;
            
            for(Target_Acknowledgement__c tAcknowledge : tAcknowledgeList){
                Target_Acknowledgement_History__c newHistory = new Target_Acknowledgement_History__c();
                newHistory.Target_Acknowledgement__c = tAcknowledge.Id;
                newHistory.Status__c = tAcknowledge.Status__c;
                newHistory.Comments__c = tAcknowledge.Comments__c;
                ackHistoryList.add(newHistory);
            }
        }
        
        if(!ackHistoryList.isEmpty()){
            Insert ackHistoryList;
        }
        
        if(!BDDTargetDistList.isEmpty()) {
            BDDTargetDistList[0].Overall_Target__c = BDDTarget;
            BDDTargetDistList[0].CurrencyIsoCode = currencyVal;
            targetDistList.add(BDDTargetDistList[0]);
        }
        else {
            targetDistList.add(new Target_Distribution__c(Financial_Year__c =financialYear , BDD__c=currentUser, Overall_Target__c=BDDTarget,CurrencyIsoCode = currencyVal));
        }
        
        
        if(!BDMTargetDistMap.keyset().isEmpty()) {
            targetDistList.addAll(BDMTargetDistMap.values());
        }
        
        if(!targetDistList.isEmpty()) {
            upsert targetDistList;
            updateBDMTargets(currentUser, financialYear, BDDTarget, BDMTargetDistMap, currencyVal);
            return true;
        }
        
        return false;
    }
    
    private static void updateBDMTargets(Id currentUser, String financialYear, Decimal BDDTarget, Map<Id, Target_Distribution__c> BDMTargetDistMap, String currencyVal) {
        Map<Id, Decimal> BDMActualsMap = new Map<Id, Decimal>();
        Map<String, Decimal> currTypeMap = new Map<String, Decimal>();
        Map<Id, Decimal> missingBDMActualsMap = new Map<Id, Decimal>();
        Map<String, Target_Config__c> targetMap = new Map<String, Target_Config__c>();
        Map<String, Order_Commitment__c> orderCommitMap = new Map<String, Order_Commitment__c>();
        Map<String, Pending_Targets__c> pendingJobMap = new Map<String, Pending_Targets__c>();
        
        String prevYear = 'FY-'+String.valueOf(Integer.valueOf(financialYear.substring(3)) - 1);
        
        for(CurrencyType currType : [SELECT Id,IsoCode, ConversionRate FROM CurrencyType]) {
            currTypeMap.put(currType.IsoCode, currType.ConversionRate);
        }
        
        for(
            AggregateResult aggr : 
            [SELECT BDM__c, currencyIsoCode, SUM(Actual_Amount__c) totalAmount FROM SPM_Stats__c WHERE Financial_Year__c =: prevYear AND 
             BDD__c =: currentUser AND BDM__c IN : BDMTargetDistMap.keySet() And Actual_Amount__c > 0 GROUP BY BDM__c, currencyIsoCode]
        ) {
            Id BDMId = (Id) aggr.get('BDM__c');
            
            Decimal actualsAchieved = (Decimal) aggr.get('totalAmount');
            
            if((String) aggr.get('currencyIsoCode') != currencyVal) {
                actualsAchieved = actualsAchieved * currTypeMap.get(currencyVal);
            }
            
            Decimal targetCal = BDDTarget * (BDMTargetDistMap.get(BDMId).Allocated_Percentage__c / 100);
            Decimal computeIncrease = ((targetCal - actualsAchieved) / actualsAchieved);
            BDMActualsMap.put(BDMId, computeIncrease);
        }
        
        for(
            SPM_Stats__c actual : 
            [SELECT Id, currencyIsoCode, Financial_Year__c, Month__c, Account__c, Business_Unit__c, BDD__c, BDM__c, Actual_Amount__c 
             FROM SPM_Stats__c WHERE Financial_Year__c =: prevYear AND BDD__c =: currentUser AND BDM__c IN : BDMActualsMap.keySet()]
        ) {
            Decimal finalTarget = (BDMActualsMap.get(actual.BDM__c) * actual.Actual_Amount__c) + actual.Actual_Amount__c;
            
            if(currencyVal != actual.currencyIsoCode && currTypeMap.containsKey(currencyVal)) {
                finalTarget = (BDMActualsMap.get(actual.BDM__c) * actual.Actual_Amount__c * currTypeMap.get(currencyVal)) + (actual.Actual_Amount__c * currTypeMap.get(currencyVal));
            }
            
            String key = financialYear + '-' + String.valueOf(actual.BDD__c).substring(0, 15) + '-' 
                + String.valueOf(actual.BDM__c).substring(0, 15) + '-' + String.valueOf(actual.Account__c).substring(0, 15) + '-' 
                + String.valueOf(actual.Business_Unit__c).substring(0, 15) + '-' 
                + actual.Month__c;
            
            if(targetMap.containsKey(key)) {
                finalTarget += targetMap.get(key).Target__c;
            }
            
            targetMap.put(key, new Target_Config__c(
                Financial_Year__c = financialYear, Month__c = actual.Month__c, Account__c = actual.Account__c,
                Business_Unit__c = actual.Business_Unit__c, BDD__c = actual.BDD__c, BDM__c = actual.BDM__c,
                Target__c = finalTarget, Level__c='BDM', CurrencyIsoCode = currencyVal
            ));
        }
        
        for(SPM_Stats__c actual : [SELECT Id, Financial_Year__c, Month__c, Account__c, Business_Unit__c, BDD__c, BDM__c, Order_Product__c,Product__c,Order_Product__r.quantity,Order_Product__r.UnitPrice FROM SPM_Stats__c WHERE Financial_Year__c =: prevYear  AND BDM__c IN : BDMActualsMap.keySet() And Order_Product__c!=null] ) {
            Decimal finalTarget = (BDMActualsMap.get(actual.BDM__c) * actual.Order_Product__r.quantity) + actual.Order_Product__r.quantity;
            
            String key = financialYear + '-' + String.valueOf(actual.BDM__c).substring(0, 15) + '-' + String.valueOf(actual.Account__c).substring(0, 15) + '-' 
                + String.valueOf(actual.Business_Unit__c).substring(0, 15) + '-' + String.valueOf(actual.Product__c).substring(0, 15)+ '-' + actual.Month__c;
            
            if(orderCommitMap.containsKey(key)) {
                finalTarget += OrderCommitMap.get(key).Quantity__c;
                
            }
            
            orderCommitMap.put(key, new Order_Commitment__c(
                Financial_Year__c = financialYear, Month__c = actual.Month__c, Account__c = actual.Account__c,Product__c = actual.Product__c, Unit_Price__c = actual.Order_Product__r.UnitPrice ,
                Business_Unit__c = actual.Business_Unit__c, BDD__c = actual.BDD__c, BDM__c = actual.BDM__c, Quantity__c =Math.round(finalTarget) , CurrencyIsoCode = currencyVal
            ));
        }
        
        if(!OrderCommitMap.keySet().isEmpty()) {
            for(Order_Commitment__c orderComit : [SELECT Id, Key__c,Unit_Price__c FROM Order_Commitment__c WHERE Key__c IN : OrderCommitMap.keySet()]) {
                if(OrderCommitMap.containsKey(orderComit.Key__c)) {
                    OrderCommitMap.get(orderComit.Key__c).Id = orderComit.Id;
                }
            }
            Upsert OrderCommitMap.values();
        }
        
        if(!targetMap.keySet().isEmpty()) {
            // Fetch the existing targets
            for(Target_Config__c tConfig : [SELECT Id, Target_Key__c FROM Target_Config__c WHERE Target_Key__c IN : targetMap.keySet()]) {
                if(targetMap.containsKey(tConfig.Target_Key__c)) {
                    targetMap.get(tConfig.Target_Key__c).Id = tConfig.Id;
                }
            }
            Upsert targetMap.values();
        }
    }
    
    public class BDMTargetDist {
        @AuraEnabled
        public Id userId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String url {get; set;}
        @AuraEnabled
        public Decimal disPercent {get; set;}
        
        public BDMTargetDist(Id userId, String name, String url, Decimal disPercent) {
            this.userId = userId;
            this.name = name;
            this.url = url;
            this.disPercent = disPercent;
        }
    }
}