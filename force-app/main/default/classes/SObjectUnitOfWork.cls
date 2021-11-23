public with sharing virtual class SObjectUnitOfWork 
{
	private List<Schema.SObjectType> m_sObjectTypes = new List<Schema.SObjectType>();

	private Map<String, List<SObject>> m_newListByType = new Map<String, List<SObject>>();

	private Map<String, Map<Id, SObject>> m_dirtyMapByType = new Map<String, Map<Id, SObject>>();

	private Map<String, Map<Id, SObject>> m_deletedMapByType = new Map<String, Map<Id, SObject>>();

	private Map<String, Relationships> m_relationships = new Map<String, Relationships>();

	private List<IDoWork> m_workList = new List<IDoWork>();

	private SendEmailWork m_emailWork = new SendEmailWork();

	private IDML m_dml;

	/**
	 * Interface describes work to be performed during the commitWork method
	 **/
	public interface IDoWork
	{
		void doWork();
	}

	public interface IDML
	{
		void dmlInsert(List<SObject> objList);
		void dmlUpdate(List<SObject> objList);
		void dmlDelete(List<SObject> objList);
	}

	public class SimpleDML implements IDML
	{
		public void dmlInsert(List<SObject> objList){
			insert objList;
		}
		public void dmlUpdate(List<SObject> objList){
			update objList;
		}
		public void dmlDelete(List<SObject> objList){
			delete objList;
		}
	}
	/**
	 * Constructs a new UnitOfWork to support work against the given object list
	 *
	 * @param sObjectList A list of objects given in dependency order (least dependent first)
	 */
	public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes)
	{
		this(sObjectTypes,new SimpleDML());
	}


	public SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes, IDML dml)
	{
		m_sObjectTypes = sObjectTypes.clone();

		for(Schema.SObjectType sObjectType : m_sObjectTypes)
		{
			m_newListByType.put(sObjectType.getDescribe().getName(), new List<SObject>());
			m_dirtyMapByType.put(sObjectType.getDescribe().getName(), new Map<Id, SObject>());
			m_deletedMapByType.put(sObjectType.getDescribe().getName(), new Map<Id, SObject>());
			m_relationships.put(sObjectType.getDescribe().getName(), new Relationships());
		}

		m_workList.add(m_emailWork);

		m_dml = dml;
	}

	/**
	 * Register a generic peace of work to be invoked during the commitWork phase
	 **/
	public void registerWork(IDoWork work)
	{
		m_workList.add(work);
	}

	/**
	 * Registers the given email to be sent during the commitWork
	 **/
	public void registerEmail(Messaging.Email email)
	{
		m_emailWork.registerEmail(email);
	}

	/**
	 * Register a newly created SObject instance to be inserted when commitWork is called
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 **/
	public void registerNew(SObject record)
	{
		registerNew(record, null, null);
	}

	/**
	 * Register a list of newly created SObject instances to be inserted when commitWork is called
	 *
	 * @param records A list of newly created SObject instances to be inserted during commitWork
	 **/
	public void registerNew(List<SObject> records)
	{
		for(SObject record : records)
		{
			registerNew(record, null, null);
		}
	}

	/**
	 * Register a newly created SObject instance to be inserted when commitWork is called,
	 *   you may also provide a reference to the parent record instance (should also be registered as new separatly)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separatly)
	 **/
	public void registerNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if(record.Id != null)
			throw new UnitOfWorkException('Only new records can be registered as new');
		String sObjectType = record.getSObjectType().getDescribe().getName();
		if(!m_newListByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		m_newListByType.get(sObjectType).add(record);
		if(relatedToParentRecord!=null && relatedToParentField!=null)
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
	}

	/**
	 * Register a relationship between two records that have yet to be inserted to the database. This information will be
	 *  used during the commitWork phase to make the references only when related records have been inserted to the database.
	 *
	 * @param record An existing or newly created record
	 * @param relatedToField A SObjectField referene to the lookup field that relates the two records together
	 * @param relatedTo A SOBject instance (yet to be commited to the database)
	 */
	public void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo)
	{
		String sObjectType = record.getSObjectType().getDescribe().getName();
		if(!m_newListByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		m_relationships.get(sObjectType).add(record, relatedToField, relatedTo);
	}

	/**
	 * Register an existing record to be updated during the commitWork method
	 *
	 * @param record An existing record
	 **/
	public void registerDirty(SObject record)
	{
		if(record.Id == null)
			throw new UnitOfWorkException('New records cannot be registered as dirty');
		String sObjectType = record.getSObjectType().getDescribe().getName();
		if(!m_dirtyMapByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		m_dirtyMapByType.get(sObjectType).put(record.Id, record);
	}

	/**
	 * Register a list of existing records to be updated during the commitWork method
	 *
	 * @param records A list of existing records
	 **/
/*	public void registerDirty(List<SObject> records)
	{
		for(SObject record : records)
		{
			this.registerDirty(record);
		}
	}
*/
	/**
	 * Register an existing record to be deleted during the commitWork method
	 *
	 * @param record An existing record
	 **/
/*	public void registerDeleted(SObject record)
	{
		if(record.Id == null)
			throw new UnitOfWorkException('New records cannot be registered for deletion');
		String sObjectType = record.getSObjectType().getDescribe().getName();
		if(!m_deletedMapByType.containsKey(sObjectType))
			throw new UnitOfWorkException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		m_deletedMapByType.get(sObjectType).put(record.Id, record);
	}
*/
	/**
	 * Register a list of existing records to be deleted during the commitWork method
	 *
	 * @param records A list of existing records
	 **/
/*	public void registerDeleted(List<SObject> records)
	{
		for(SObject record : records)
		{
			this.registerDeleted(record);
		}
	}
*/
	/**
	 * Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 **/
	public void commitWork()
	{
		// Wrap the work in its own transaction
		Savepoint sp = Database.setSavePoint();
		try
		{
			// Insert by type
			for(Schema.SObjectType sObjectType : m_sObjectTypes)
			{
				Relationships relationships = m_relationships.get(sObjectType.getDescribe().getName());
				relationships.resolve();
				m_dml.dmlInsert(m_newListByType.get(sObjectType.getDescribe().getName()));
				if (relationships.hasReflective()) {
					m_dml.dmlUpdate(relationships.getResolvedReflectiveRecords());
				}
			}
			// Update by type
			for(Schema.SObjectType sObjectType : m_sObjectTypes)
				m_dml.dmlUpdate(m_dirtyMapByType.get(sObjectType.getDescribe().getName()).values());
			// Delete by type (in reverse dependency order)
			Integer objectIdx = m_sObjectTypes.size() - 1;
			while(objectIdx>=0)
				m_dml.dmlDelete(m_deletedMapByType.get(m_sObjectTypes[objectIdx--].getDescribe().getName()).values());
			// Generic work
			for(IDoWork work : m_workList)
				work.doWork();
		}
		catch (Exception e)
		{
            System.debug('Error:'+e.getMessage());
			// Rollback
			Database.rollback(sp);
			// Throw exception on to caller
			throw e;
		}
	}

	private class Relationships
	{
		private List<Relationship> m_relationships = new List<Relationship>();
		private List<Relationship> m_reflectiveRelationships = new List<Relationship>();

		public void resolve()
		{
			// Resolve relationships
			for(Relationship relationship : m_relationships)
				relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
		}

		public void resolveReflective()
		{
			// Resolve reflective relationships
			for(Relationship relationship : m_reflectiveRelationships)
				relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
		}

		public Boolean hasReflective()
		{
			return !m_reflectiveRelationships.isEmpty();
		}

		public List<SObject> getResolvedReflectiveRecords()
		{
			resolveReflective();
			List<SObject> records = new List<SObject>();
			for(Relationship relationship : m_reflectiveRelationships)
				records.add(relationship.Record);
			return records;
		}

		public void add(SObject record, Schema.sObjectField relatedToField, SObject relatedTo)
		{
			// Relationship to resolve
			Relationship relationship = new Relationship();
			relationship.Record = record;
			relationship.RelatedToField = relatedToField;
			relationship.RelatedTo = relatedTo;
			if (record.getSObjectType() == relatedTo.getSObjectType() && relatedTo.Id == null)
				m_reflectiveRelationships.add(relationship);
			else
				m_relationships.add(relationship);
		}
	}

	private class Relationship
	{
		public SObject Record;
		public Schema.sObjectField RelatedToField;
		public SObject RelatedTo;
	}

	/**
	 * UnitOfWork Exception
	 **/
	public class UnitOfWorkException extends Exception {}

	/**
	 * Internal implementation of Messaging.sendEmail, see outer class registerEmail method
	 **/
	private class SendEmailWork implements IDoWork
	{
		private List<Messaging.Email> emails;

		public SendEmailWork()
		{
			this.emails = new List<Messaging.Email>();
		}

		public void registerEmail(Messaging.Email email)
		{
			this.emails.add(email);
		}

		public void doWork()
		{
			if(!emails.isEmpty()) 
			if(!Test.isRunningTest()){
			Messaging.sendEmail(emails);
			}
		}
	}
}