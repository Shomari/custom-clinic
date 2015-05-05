class SalesforceWorker
	include Sidekiq::Worker

	### Pass in client id that will be set when we do admin page
	### Also pass in link to where video is saved in asset
  ### Subject is the date and time created

	def perform
		client = Restforce.new :host => 'test.salesforce.com',
			:username       => ENV["sf_username"],
		  :password       => ENV["sf_password"],
		  :security_token => ENV["sf_security_token"],
		  :client_id      => ENV["sf_client_id"],
		  :client_secret  => ENV["sf_client_secret"]

		  #need to pass in account
		  account = client.find('Account', '30431', 'CMHID__c')
		  account_id = account.Id
		  client.create!('Case', Subject: "#{Time.now}", Priority: 'Low', AccountId: account_id, Description: "www.link" )

	end
end