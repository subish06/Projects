@isTest
public class SPMTest {
   @isTest
    static void testGetUserInfo() {
       
        User testUser = TestDataFactory.createUser('TestUse1');
        insert testUser;

       
        Hierarchy_Config__c testHierarchyConfig = TestDataFactory.createHierarchyConfig(testUser.Id, 'BDM');
        insert testHierarchyConfig;

        Test.startTest();
        List<Hierarchy_Config__c> result = SPMController.getUserInfo(testUser.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetBDMStats() {
        
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        insert new List<User>{ testBDMUser, testManagerUser };

       
       Hierarchy_Config__c createHierarchyCon = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c createHierarchyConf = TestDataFactory.createHierarchyConfig(testBDMUser.Id, 'BDD');
        insert createHierarchyConf;
        insert createHierarchyCon;


        Business_Unit__c testBusinessUnit = TestDataFactory.createBusinessUnit('USA', true, 'USA');
        insert testBusinessUnit;
        
        Year_Stats__c testYearStats = TestDataFactory.createYearStats('FY-23');
        insert testYearStats;
       
         Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        insert ownedAccount;
        
        Target_Config__c testTargetConfig = TestDataFactory.createTargetConfig(testManagerUser.Id, testBDMUser.Id, testBusinessUnit.Id, 10000.00, 'FY-23','','',testYearStats.Id,ownedAccount.Id);
        insert testTargetConfig;

        SPM_Stats__c testSPMStats = TestDataFactory.createSPMStats(testManagerUser.Id, testBDMUser.Id, testBusinessUnit.Id, 8500.00, 'FY-23', testTargetConfig.Id,'Jul',testYearStats.Id,ownedAccount.Id);
        insert testSPMStats;
        
       
        
        Test.startTest();
        List<SPMController.BDMActuals> result = SPMController.getBDMStats(testManagerUser.Id, 'FY-23');
        Test.stopTest();
        
       
          
    }
    
      @isTest
    static void testGetTargetBDM() {
        
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        insert new List<User>{ testBDMUser, testManagerUser };

       Hierarchy_Config__c createHierarchyCon = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c createHierarchyConf = TestDataFactory.createHierarchyConfig(testBDMUser.Id, 'BDD');
        insert createHierarchyConf;
        insert createHierarchyCon;
        
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        insert bu1;

        Business_Unit__c bu2 = TestDataFactory.createBusinessUnit('Epiphone', true,'Epiphone');
        insert bu2;
        
        Year_Stats__c testYearStats = TestDataFactory.createYearStats('FY-23');
        insert testYearStats;
        
         Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        insert ownedAccount;

        // Create test data for Target_Config__c
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id,testBDMUser.Id,  bu1.Id,5000, 'FY-23', 'Apr','BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig1;

        Target_Config__c targetConfig2 = TestDataFactory.createTargetConfig(
            testManagerUser.Id,testBDMUser.Id,  bu2.Id,6000, 'FY-23', 'May','BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig2;
        
        Target_Config__c targetConfig3 = TestDataFactory.createTargetConfig(
            testManagerUser.Id,testBDMUser.Id,  bu1.Id,4500, 'FY-23', 'Apr','BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig3;

        
        Test.startTest();
        Map<String, Map<String, Decimal>> result = SPMController.getTargetBDM('FY-23',testManagerUser.Id, testBDMUser.Id);
        Test.stopTest();

    }
    
   @isTest
    static void testGetActualsBDM() {
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        insert new List<User>{ testBDMUser, testManagerUser };
        
        // Create test data for Business_Unit__c
        Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        insert bu1;

        Business_Unit__c bu2 = TestDataFactory.createBusinessUnit('Epiphone', true,'Epiphone');
        insert bu2;
        
         Year_Stats__c testYearStats = TestDataFactory.createYearStats('FY-23');
        insert testYearStats;
        
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        insert ownedAccount;
        // Create test data for Target_Config__c
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-23', 'Apr', 'BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig1;
        
        Target_Config__c targetConfig2 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu2.Id, 6000, 'FY-23', 'May', 'BDM',testYearStats.Id,ownedAccount.ID
        );
        insert targetConfig2;
        
        // Create test data for SPM_Stats__c (Actuals)
        SPM_Stats__c actual1 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 4500, 'FY-23', targetConfig1.Id, 'Apr',testYearStats.Id,ownedAccount.Id
        );
        insert actual1;
        
        SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu2.Id, 5500, 'FY-23', targetConfig2.Id, 'May',testYearStats.Id,ownedAccount.Id
        );
        insert actual2;
        
        Test.startTest();
        Map<String, Map<String, Decimal>> getActualsBDMresult = SPMController.getActualsBDM('FY-23', testManagerUser.Id, testBDMUser.Id);
        Map<String, Map<String, Decimal>> getVarianceBDMresult = SPMController.getVarianceBDM('FY-23', testManagerUser.Id, testBDMUser.Id);
        Map<String, Object> getBDDStatsresult = BDDController.getBDDStats('FY-23');
        //string getBDMTargetDist = BDDController.getBDMTargetDist(testBDMUser.Id,'FY-23','FY-22');
        Test.stopTest();
    }

    @isTest
    static void testGetBDMTargetDist() {
        User testBDMUser = TestDataFactory.createUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        insert new List<User>{ testBDMUser, testManagerUser };

        Hierarchy_Config__c hierarchyConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        insert hierarchyConfig;
        
         Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        insert bu1;
        
          Year_Stats__c testYearStats = TestDataFactory.createYearStats('FY-23');
        insert testYearStats;
        
         Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        insert ownedAccount;

        // Create test data for Target_Config__c
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-22', 'Apr', 'BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig1;
        
         SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 66500, 'FY-22', targetConfig1.Id, 'Apr',testYearStats.Id,ownedAccount.Id
        );
        insert actual2;

        Target_Distribution__c targetDist = TestDataFactory.createTargetDistribution(
            testManagerUser.Id, testBDMUser.Id, 'FY-23', 50, 'USD'
        );
        insert targetDist;
        

        Target_Distribution__c overallTargetDist = TestDataFactory.createBDDTargetDistribution(
            testManagerUser.Id, 'FY-23', 100000, 'USD'
        );
        insert overallTargetDist;
        
      

        
        Test.startTest();
        String result = BDDController.getBDMTargetDist(testManagerUser.Id, 'FY-23', 'FY-22');
        Test.stopTest();

        // Perform assertions on the result if needed
    }

     @isTest
    static void testSaveBDMTargetConfigs() {
         User testBDMUser = TestDataFactory.createUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        insert new List<User>{ testBDMUser, testManagerUser };

        Hierarchy_Config__c hierarchyConfig = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        insert hierarchyConfig;
        
         Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        insert bu1; 
        
         Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        insert ownedAccount;
        
         Year_Stats__c testYearStats = TestDataFactory.createYearStats('FY-22');
        insert testYearStats;

        // Create test data for Target_Config__c
        Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-22', 'Apr', 'BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig1;
        
         SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 66500, 'FY-22', targetConfig1.Id, 'Apr',testYearStats.Id,ownedAccount.Id
        );
        insert actual2;

        Target_Distribution__c targetDist = TestDataFactory.createTargetDistribution(
            testManagerUser.Id, testBDMUser.Id, 'FY-23', 50, 'USD'
        );
        insert targetDist;

        String BDMDistData = '[{"userId":"' + testBDMUser.Id + '","disPercent":60}]';
        
        Target_Config__c targetConfig = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-23', 'Apr', 'BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig;

        Test.startTest();
        BDDController.saveBDMTargetConfigs(testManagerUser.Id, 100000, 'FY-23', BDMDistData, 'USD');
   
        Test.stopTest();


    }
    
     @isTest
    static void testSaveBDMTargets() {
       
        User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        insert new List<User>{ testBDMUser, testManagerUser };

       
       Hierarchy_Config__c createHierarchyCon = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c createHierarchyConf = TestDataFactory.createHierarchyConfig(testBDMUser.Id, 'BDD');
        insert createHierarchyConf;
        insert createHierarchyCon;
     
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testBDMUser.Id,'USA');
        insert ownedAccount;
        
         Business_Unit__c bu1 = TestDataFactory.createBusinessUnit('USA', true,'USA');
        insert bu1;
       
        List<Map<String, Object>> targetData = new List<Map<String, Object>>();
       
        targetData.add(new Map<String, Object>{
            'busUnit' => 'USA',
            'accountId' => ownedAccount.Id,
            'Jan' => 1000,  
            'Feb' => 1500
        });
        targetData[0].put('Jan', 1200);
        
        
       
        
        Year_Stats__c testYearStats = TestDataFactory.createYearStats('FY-23');
        insert testYearStats;
        
        Product2 testProduct = TestDataFactory.createProduct('Test Product', bu1.Name);
        insert testProduct;
            
           // Define the standard price for the product
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct.Id,
                UnitPrice = 100.0
            );
            insert standardPricebookEntry;

           Pricebook2 testPricebook = TestDataFactory.createPricebook('Test Pricebook');
            insert testPricebook;

            // Create a custom pricebook entry associated with the custom pricebook
            PricebookEntry testPricebookEntry = TestDataFactory.createPricebookEntry(testPricebook.Id, testProduct.Id, 110.0);
            insert testPricebookEntry;
        
         Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
            testManagerUser.Id, testBDMUser.Id, bu1.Id, 5000, 'FY-22', 'Apr', 'BDM',testYearStats.Id,ownedAccount.Id
        );
        insert targetConfig1;
        
         SPM_Stats__c actual2 = TestDataFactory.createSPMStats(
         testManagerUser.Id, testBDMUser.Id, bu1.Id, 500, 'FY-22', targetConfig1.Id, 'Apr',testYearStats.Id,ownedAccount.Id
        );
        insert actual2;
        
          Business_Unit__c bu = [SELECT Id FROM Business_Unit__c WHERE Unique_Name__c = 'USA' LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT ID From Product2 LIMIT 1];

        // Create Order Commitment test data
        Order_Commitment__c orderCommit = TestDataFactory.createOrderCommitment(
            ownedAccount.Id,bu1.Id , 'FY-22', 'Apr',20,20,testProduct.Id
        );
        insert orderCommit;
        
        List<Target_Config__c> targetConfigs = TestDataFactory.createTargetConfigs(testManagerUser.Id, testBDMUser.Id, 'FY-23', targetData,testYearStats.Id);
        insert targetConfigs;

        List<Order_Commitment__c> ordCommitList = new List<Order_Commitment__c>{orderCommit};
        Test.startTest();
        SPMController.saveBDMTargets(testManagerUser.Id, testBDMUser.Id, 'FY-23', targetData);
        
         List<Account> resultAccounts = BDMController.getBDMAccounts(ownedAccount.Id);
         Map<String, Object> getBDMstatsresult = BDMController.getBDMstats('FY-22');
         Map<String, Map<String, Decimal>> getTargetBDMresult = BDMController.getTargetBDM('FY-22',ownedAccount.id,testBDMUser.Id);
         Map<String, Map<String, Decimal>> getActualsBDMresult = BDMController.getActualsBDM('FY-22',ownedAccount.id,testBDMUser.Id);
        Map<String, Map<String, Decimal>> getVarianceBDMresult = BDMController.getVarianceBDM('FY-22',ownedAccount.id,testBDMUser.Id);
        List<String> getBusinessUnitsresult = BDMController.getBusinessUnits(ownedAccount.Id);
        BDMController.getBusUnitTarActVar('FY-22', ownedAccount.Id, bu1.Name);
       BDMController.getMonthTarActVar('FY-22', ownedAccount.Id, bu1.Name, 'Apr');
        String upsertOrdCommitresult = BDMController.upsertOrdCommit(ordCommitList, '', '');
      BDMController.prepareBUProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','','');
       BDMController.getBDMAccountStats(testBDMUser.Id,'FY-22','');
        BDMController.getBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','','');
         BDMController.getBusUnitProducts( bu1.Id, bu1.Name,ownedAccount.Id,'FY-22','Apr','ABCD','TEST');
       boolean MonthTarActVarresult = BDMController.MonthTarActVar('FY-22', ownedAccount.Id, bu1.Name, 'Apr');
        Test.stopTest();
        List<Target_Config__c> updatedTargets = [SELECT Id, Target__c FROM Target_Config__c WHERE BDD__c = :testBDMUser.Id AND Financial_Year__c = 'FY-23'];
    }

 /*@isTest
    static void testGetBDMAccounts() {
        // Create a user for testing
        User testUser = TestDataFactory.createUser('TestU1');
        insert testUser;

        // Create accounts with different owners for testing
        Account ownedAccount = TestdataFactory.createAccount('Owned Account', testUser.Id,'');
        Account otherAccount = TestdataFactory.createAccount('Other Account', UserInfo.getUserId(),'');

        Test.startTest();
        // Call the getBDMAccounts method with the test user's Id
       
        Test.stopTest();

        
    }*/
   
    
     @isTest
    static void testCreateActuals() {
        try{
          User testBDMUser = TestDataFactory.createBDMUser('TestBDM');
        User testManagerUser = TestDataFactory.createUser('TestBDD');
        insert new List<User>{ testBDMUser, testManagerUser };

       Hierarchy_Config__c createHierarchyCon = TestDataFactory.createHierarchyConf(testBDMUser.Id, 'BDM', testManagerUser.Id);
        Hierarchy_Config__c createHierarchyConf = TestDataFactory.createHierarchyConfig(testBDMUser.Id, 'BDD');
        insert createHierarchyConf;
        insert createHierarchyCon;

        Business_Unit__c testBusinessUnit = TestDataFactory.createBusinessUnit('USA', true, 'USA');
        insert testBusinessUnit;
            
             Product2 testProduct = TestDataFactory.createProduct('Test Product', testBusinessUnit.Name);
        insert testProduct;
            
           // Define the standard price for the product
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct.Id,
                UnitPrice = 100.0
            );
            insert standardPricebookEntry;

            Pricebook2 testPricebook = TestDataFactory.createPricebook('Test Pricebook');
            insert testPricebook;

            // Create a custom pricebook entry associated with the custom pricebook
            PricebookEntry testPricebookEntry = TestDataFactory.createPricebookEntry(testPricebook.Id, testProduct.Id, 110.0);
            insert testPricebookEntry;

        Account testAccount = TestDataFactory.createAccount('TestAccount1', testBDMUser.Id,'');
        insert testAccount;
            
        Year_Stats__c testYearStats = TestDataFactory.createYearStats('FY-23');
        insert testYearStats;   
            
         Target_Config__c targetConfig1 = TestDataFactory.createTargetConfig(
         testManagerUser.Id, testBDMUser.Id, testBusinessUnit.Id, 5000, 'FY-23', 'Aug', 'BDM',testYearStats.Id,testAccount.Id
        );
        insert targetConfig1;

       Contract testContract = TestDataFactory.createContract(testAccount.Id);
            insert testContract;
       
        Order testOrder = TestDataFactory.createOrder(testAccount.Id,testPricebook.Id,testContract.Id);
        insert testOrder;

        OrderItem testOrderItem = TestDataFactory.createOrderItem(testOrder.Id, testProduct.Id,testPricebookEntry.Id,100,2);
            insert testOrderItem;
        Map<Id, OrderItem> newOrderMap = new Map<Id, OrderItem>{ testOrderItem.Id => testOrderItem };
        Map<Id, OrderItem> oldOrderItemMap = new Map<Id, OrderItem>{ testOrderItem.Id => testOrderItem };
        testOrderItem.unitprice = 120;
        testOrderItem.Quantity =2;    
            update testOrderItem;

        Test.startTest();
        OrderItemController.createActuals(newOrderMap);
        OrderItemController.updateActualsOnOrderItemUpdate(newOrderMap, oldOrderItemMap);
        
        Test.stopTest();

        List<SPM_Stats__c> actualsList = [SELECT Id FROM SPM_Stats__c];
        }
         catch(Exception e) {
        System.debug('Error occurred: ' + e.getMessage());
        // Re-throw the exception to see the full stack trace in debug logs
        throw e;
    }
        
    }
    
      
   

}