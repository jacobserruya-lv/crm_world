public with sharing class JSON2OrderNotes {

    public List<OrderNote> orderNotes;

    public class OrderNote {
        public String orderNumber;
        public String shippingNumber;
        public String orderType;
        public String description;
        public String reasonCode;
        
        public boolean isClientelingException(){
            return OrderNoteService.CLIENTELING_EXCEPTION.equals(this.orderType);
        }
        
        public boolean isPriceAdjustment(){
            return OrderNoteService.PRICE_ADJUSTMENT.equals(this.orderType);
        }
        
        public boolean isAttachedNote(){
            return OrderNoteService.ATTACHED_NOTE.equals(this.orderType);
        }

        public boolean isBankTransfer(){
            return OrderNoteService.BANK_TRANSFER.equals(this.orderType);
        }
        
        public boolean isStockOnHold(){
            return OrderNoteService.STOCK_ON_HOLD.equals(this.orderType);
        }

        public boolean isFreeShipping(){
            return OrderNoteService.FREE_SHIPPING.equals(this.orderType);
        }

        public boolean isPaymentLink(){
            return OrderNoteService.PAYMENT_LINK.equals(this.orderType);
        }
        
        public boolean isExtendedPaymentLink(){
            return OrderNoteService.EXTENDED_PAYMENT_LINK.equals(this.orderType);
        }
        
        public boolean isPersoProductAccepted(){
            return OrderNoteService.PERSO_PRODUCT_ACC.equals(this.orderType);
        }
        
        public boolean isPersoProductRefused(){
            return OrderNoteService.PERSO_PRODUCT_REF.equals(this.orderType);
        }

        public boolean isPayAfterAgreement(){
            return OrderNoteService.PAY_AFTER_AGREEMENT.equals(this.orderType);
        }
    }
        
    public static JSON2OrderNotes parse(String json) {
        return (JSON2OrderNotes) System.JSON.deserialize(json, JSON2OrderNotes.class);
    }
}