@isTest
global class IDENTITY_jusoAddressSearch_CTRL_TEST {

    @isTest
    static void test_first_jusoSearch(){
        Test.startTest();
        IDENTITY_jusoAddressSearch_CTRL ctrl = new IDENTITY_jusoAddressSearch_CTRL();
        ctrl.addressInputSearch='주소';
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody('({"results":{"common":{"errorMessage":"정상","countPerPage":"20","totalCount":"95","errorCode":"0","currentPage":"1"},"juso":[{"detBdNmList":"","engAddr":"32 Suin-ro 2573beon-gil, Siheung-si, Gyeonggi-do","rn":"수인로2573번길","emdNm":"금이동","zipNo":"14981","roadAddrPart2":" (금이동)","emdNo":"01","sggNm":"시흥시","jibunAddr":"경기도 시흥시 금이동 43-4 (주)한국주소연구소","siNm":"경기도","roadAddrPart1":"경기도 시흥시 수인로2573번길 32","bdNm":"(주)한국주소연구소","admCd":"4139011000","udrtYn":"0","lnbrMnnm":"43","roadAddr":"경기도 시흥시 수인로2573번길 32"}]}})'));
        
        Boolean hasPrevious = ctrl.gethasPrevious();
        Boolean hasNext  = ctrl.gethasNext();
        ctrl.first();
        Test.stopTest();
        Assert.isNotNull(ctrl.searchResults, 'search result should include the response of the search');

    }
    @isTest
    static void test_next_badresponse_jusoSearch(){
        Test.startTest();
        IDENTITY_jusoAddressSearch_CTRL ctrl = new IDENTITY_jusoAddressSearch_CTRL();
        ctrl.addressInputSearch='주소';
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setStatusCode(400));
       
        ctrl.next();
        Test.stopTest();
        Assert.isNull(ctrl.searchResults, 'bad response so searchResult is null');
    }
    @isTest
    static void test_previous_badInput_jusoSearch(){
        Test.startTest();
        IDENTITY_jusoAddressSearch_CTRL ctrl = new IDENTITY_jusoAddressSearch_CTRL();
        ctrl.addressInputSearch='주소SELECT주소';
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody('({"results":{"common":{"errorMessage":"정상","countPerPage":"20","totalCount":"95","errorCode":"0","currentPage":"1"},"juso":[{"detBdNmList":"","engAddr":"32 Suin-ro 2573beon-gil, Siheung-si, Gyeonggi-do","rn":"수인로2573번길","emdNm":"금이동","zipNo":"14981","roadAddrPart2":" (금이동)","emdNo":"01","sggNm":"시흥시","jibunAddr":"경기도 시흥시 금이동 43-4 (주)한국주소연구소","siNm":"경기도","roadAddrPart1":"경기도 시흥시 수인로2573번길 32","bdNm":"(주)한국주소연구소","admCd":"4139011000","udrtYn":"0","lnbrMnnm":"43","roadAddr":"경기도 시흥시 수인로2573번길 32"}]}})'));
        
      
        ctrl.previous();
        Test.stopTest();
        Assert.isNull(ctrl.searchResults, 'search result should be null since the totalCount');
    }
    @isTest
    static void test_reset_jusoSearch(){
        Test.startTest();
        IDENTITY_jusoAddressSearch_CTRL ctrl = new IDENTITY_jusoAddressSearch_CTRL();
        ctrl.addressInputSearch='주소';
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody('({"results":{"common":{"errorMessage":"정상","countPerPage":"20","totalCount":"95","errorCode":"0","currentPage":"1"},"juso":[{"detBdNmList":"","engAddr":"32 Suin-ro 2573beon-gil, Siheung-si, Gyeonggi-do","rn":"수인로2573번길","emdNm":"금이동","zipNo":"14981","roadAddrPart2":" (금이동)","emdNo":"01","sggNm":"시흥시","jibunAddr":"경기도 시흥시 금이동 43-4 (주)한국주소연구소","siNm":"경기도","roadAddrPart1":"경기도 시흥시 수인로2573번길 32","bdNm":"(주)한국주소연구소","admCd":"4139011000","udrtYn":"0","lnbrMnnm":"43","roadAddr":"경기도 시흥시 수인로2573번길 32"}]}})'));
        
        ctrl.setIsSelectedAccess();
        ctrl.resetPopup();
        Test.stopTest();
        Assert.isNull(ctrl.searchResults, 'search result should be null');
    }
}