//Story : EDGE -35565 AC8
//Author : Kalashree Borgaonkar
public without sharing class CaseCommentTriggerHandler { 
    public static void updateChildComments(List<CaseComment> caseComments){
        List<CaseComment> insertCaseComments = new List<CaseComment>();
        CaseComment insertComment; 
        Set<id> ccIdsParent = new Set<id>();
        Set<id> ccIds = new Set<id>();
        for(CaseComment comment : caseComments){
           ccIds.add(comment.id);
           ccIdsParent.add(comment.parentid);
        }
        System.debug('ccIdsParent: '+ccIdsParent);
        List<CaseComment> ccList = [SELECT id,parentid,commentbody FROM casecomment WHERE id in :ccIds ];
        System.debug('List ccList:'+ccList);
        List<case> csalist = [Select id,parentid from case where parentid in :ccIdsParent AND recordtype.name = 'Feedback' AND status !='Closed'];
        System.debug('List case:'+csaList);
        for(CaseComment cc : ccList){
            for(Case c: csalist){
                System.debug('Case: '+c);
                if(cc.parentid==c.parentid){
                    System.debug('In insert');
                    insertComment = new CaseComment();
                    insertComment.CommentBody =cc.commentbody;
                    insertComment.ParentId = c.id;
                    insertCaseComments.add(insertComment);
                }
            }
        }
        if(!insertCaseComments.isempty())
        	insert insertCaseComments;
    }
}