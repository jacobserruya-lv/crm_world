// JSON input from WS_Orders class with POST method
public class WS_OrdersJson {

	//public Order order {get;set;} 

    //public class Order {
    public String orderNumber {get;set;} 
    public String orderDate {get;set;} 
    public String storeCode {get;set;} 
    public String source {get;set;} 
	public Client client {get;set;} 
	public String WWEmployeeId {get;set;}
	public String Comissioned_CA {get;set;}
    public List<Lines> lines {get;set;} 
    public List<Shippings> shippings {get;set;} 
	public Address address {get;set;} 

	//}

	public class Shippings {
		public String shippingNumber {get;set;} 
		public String type {get;set;} // in json: type
		public String status {get;set;} 
		public String statusDate {get;set;} 
		public String sourceLocation {get;set;} 
		public String pickupLocation {get;set;}
		public String statusIconics {get;set;}
	}
	
	public class Client {
		public String firstName {get;set;} 
		public String lastName {get;set;} 
		public String phone {get;set;} 
		public String email {get;set;} 
		public String customer_no {get;set;}
	}

	public class Address{
		public String address1 {get;set;}
		public String address2 {get;set;}
		public String address3 {get;set;}
		public String address4 {get;set;}
        public String city {get;set;}
		public String province {get;set;}
		public String postal_code {get;set;}
		public String country {get;set;}
		public String gps_lat {get;set;}
		public String gps_lon {get;set;}
	}
	
	public class Lines {
        public String shippingNumber {get;set;} 
		public String sku {get;set;} 
		public Integer quantity {get;set;} 
		public String initial_eta_min {get;set;}
		public String initial_eta_max {get;set;}
	}
}