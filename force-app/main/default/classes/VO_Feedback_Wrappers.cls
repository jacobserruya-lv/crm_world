/**
 * Wrapper for the answers logic in order to support the different change like 
 * multy question, solo question, number answer or string answer.
 * @createdBy   Menashe Yamin ,  28/08/2015      
 */
    
public class VO_Feedback_Wrappers {

	public class AnswerList_Wrapper 
	{
		public List<VO_Feedback_Wrappers.Answer_Wrapper> answerList {get; set;}
		public Integer count {get; set;}
		public Boolean isAnsIsNum {get; set;}
        public Boolean hasNoAns {get; set;} // 29/12/2016: added by MTOU: indicates if a group of questions has at least one answer

		public AnswerList_Wrapper()
		{
			this.answerList = new List<VO_Feedback_Wrappers.Answer_Wrapper>();
			this.count = 0;
			this.isAnsIsNum = false;
            this.hasNoAns = true;
		}
	}

	public class Answer_Wrapper 	implements Comparable
	{
		public Integer orderInAnswer {get; set;}
		public String  answer {get; set;}
		public Integer num {get; set;}
		public String  section {get; set;}
		public String  shortName {get; set;}
		public String  title {get; set;}

		public Answer_Wrapper()
		{

		}

	    public Integer compareTo(Object compareTo) 
	    {
	        Answer_Wrapper compareToOppy = (Answer_Wrapper)compareTo;
	        
	        // The return value of 0 indicates that both elements are equal.
	        Integer returnValue = 0;
	        if (this.num > compareToOppy.num) {
	            // Set return value to a positive value.
	            returnValue = 1;
	        } else if (this.num < compareToOppy.num) {
	            // Set return value to a negative value.
	            returnValue = -1;
	        }
	        
	        return returnValue;       
	    }
	}

}