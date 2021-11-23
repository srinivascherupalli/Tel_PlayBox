public class QuestionAndAnswerWrapper {
	@auraenabled
    public string Question {get;set;}
    @auraenabled
    public object Answer {get;set;}
    
    public QuestionAndAnswerWrapper(string Que,object Ans){
        this.Question=Que;
        this.Answer=Ans;
    }
    
    public QuestionAndAnswerWrapper(string Que){
        this.Question=Que;
    }
}