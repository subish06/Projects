@isTest
public class TestDataFactory {
  public static Hierarchy_Config__c createHierarchyConfig(Id userId, String role) {
        return new Hierarchy_Config__c(
            User__c = userId,
            Role__c = role
        );
    }

    public static User createUser(String name) {
        return new User(
            FirstName = name,
            LastName = 'Lastname',
            Email = name + '@Gibson23.com',
            Username = name + '@google.com',
            Alias = name,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'en_US'
        );
    }
 
    public static Hierarchy_Config__c createHierarchyConf(Id userId, String role, Id managerId) {
        Hierarchy_Config__c hierarchyConfig = new Hierarchy_Config__c();
        hierarchyConfig.User__c = userId;
        hierarchyConfig.Role__c = role;
        hierarchyConfig.Manager__c = managerId;
        // Set other required fields for the Hierarchy_Config__c object
        return hierarchyConfig;
    }
    public static User createBDMUser(String name) {
        return new User(
            FirstName = name,
            LastName = 'Lastname',
            Email = name + '@Gibson23.com',
            Username = name + '@google.com',
            Alias = name,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'en_US'
        );
    }

    public static Business_Unit__c createBusinessUnit(String name, Boolean availableForTarget, string uniquename) {
        return new Business_Unit__c(
            Name = name,
            Available_for_Target__c = availableForTarget,
            Unique_Name__c = uniquename
        );
    }

    public static Target_Config__c createTargetConfig(Id bddId, Id bdmId, Id businessUnitId, Decimal target, String financialYear,string Month,string level,Id Year,Id Account) {
        return new Target_Config__c(
            BDD__c = bddId,
            BDM__c = bdmId,
            Business_Unit__c = businessUnitId,
            Account__c = Account,
            Target__c = target,
            Financial_Year__c = financialYear,
            Month__c = Month,
            Level__c = level,
            Year_Stats__c =Year
        );
    }

    public static SPM_Stats__c createSPMStats(Id bddId, Id bdmId, Id businessUnitId, Decimal actualAmount, String financialYear,Id targetConfig,string Month,Id year,Id Account) {
        return new SPM_Stats__c(
            BDD__c = bddId,
            BDM__c = bdmId,
            Business_Unit__c = businessUnitId,
            Actual_Amount__c = actualAmount,
            Financial_Year__c = financialYear,
            Target_Config__c = targetConfig,
            Month__c = Month,
            Year_Stats__c = year,
            Account__c = Account
            
        );
    }
    

   public static Account createAccount(String name, Id ownerId,string BU) {
       system.debug('ownerId'+ownerId);
        return new Account(Name = name, OwnerId = ownerId,Authorized_Business_Units__c = BU);
       
    }
    
     public static Pricebook2 createPricebook(String name) {
        return new Pricebook2(Name = name);
    }

    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Decimal unitPrice) {
        return new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            UseStandardPrice = false,
            IsActive = true
        );
    }
     public static Product2 createProduct(String productName, String businessUnit) {
        return new Product2(
            Name = productName,
            Business_Unit__c = businessUnit
           
        );
    }

     public static Contract createContract(Id accountId) {
        Contract testContract = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12
        );
        return testContract;
    } 
    
    public static Order createOrder(Id accountId,Id pricebookId,Id Contract) {
        return new Order(
            AccountId = accountId,
            ContractId = Contract,
            OrderedDate =   Datetime.now(),
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pricebookId,
            XC_Order_Status__c = 'invoiced'
        );
    }
    

    public static OrderItem createOrderItem(Id orderId, Id productId,Id pricebookEntryId,decimal unitprice, decimal quantity) {
        return new OrderItem(
            OrderId = orderId,
            Product2Id = productId,
            PricebookEntryId = pricebookEntryId,
            UnitPrice = unitprice, 
            Quantity = quantity
            
        );
    }
  
   public static Target_Distribution__c createTargetDistribution(Id bddId, Id bdmId, String financialYear, Decimal allocatedPercentage, String currencyIsoCode) {
        return new Target_Distribution__c(
            BDD__c = bddId,
            BDM__c = bdmId,
            Financial_Year__c = financialYear,
            Allocated_Percentage__c = allocatedPercentage,
            CurrencyIsoCode = currencyIsoCode
        );
    }
   
   public static Target_Distribution__c createBDDTargetDistribution(Id bddId, String financialYear, Decimal overallTarget, String currencyIsoCode) {
        return new Target_Distribution__c(
            BDD__c = bddId,
            Overall_Target__c = overallTarget,
            Financial_Year__c = financialYear,
            CurrencyIsoCode = currencyIsoCode
        );
    }
    
    
  public static Order_Commitment__c createOrderCommitment(Id accountId, Id businessUnitName, String financialYear, String month, Decimal Quantity,Decimal unitPrice,Id Product) {
        Order_Commitment__c orderCommit = new Order_Commitment__c(
            Account__c = accountId,
            Business_Unit__c = businessUnitName,
            Financial_Year__c = financialYear,
            Month__c = month,
            Quantity__c = Quantity,
            Unit_Price__c =unitPrice,
            Product__c = product
        );
        return orderCommit;
    }

  public static Year_Stats__c createYearStats( String financialYear) {
        return new Year_Stats__c(
            Financial_Year__c = financialYear    
        );
    }
    
    
    
    
     public static List<Target_Config__c> createTargetConfigs(Id bddId, Id bdmId, String financialYear, List<Map<String, Object>> targetData,Id Year) {
        List<Target_Config__c> targetConfigs = new List<Target_Config__c>();

        for (Map<String, Object> target : targetData) {
            // Adjust this part according to the structure of your targetData list.
            // Assuming the targetData list contains maps with keys: 'busUnit', 'Jan', 'Feb', ..., 'Dec'
            String busUnit = (String) target.get('busUnit');
            Boolean isTotal = busUnit == 'Total';
            if (String.isBlank(busUnit) || isTotal) {
                continue;
            }

            // Create Business_Unit__c record if it doesn't exist
            Business_Unit__c bu = createBusinessUnit(busUnit, true,'');
            insert bu;

            // Create Target_Config__c record
            Target_Config__c targetConfig = new Target_Config__c(
                BDD__c = bddId,
                BDM__c = bdmId,
                Business_Unit__c = bu.Id,
                Financial_Year__c = financialYear,
                level__c = 'BDM',
                Year_Stats__c =Year,
                Target__c = isTotal ? null : (Decimal) target.get('Jan')  
            );
            targetConfigs.add(targetConfig);
        }

        return targetConfigs;
    }
   
    
}