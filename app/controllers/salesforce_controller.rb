class SalesforceController < ApplicationController

	def sf
		client = Restforce.new :host => 'test.salesforce.com',
			:username => 'shomari.e@contextmediainc.com.staging', 
			:password => 'wingzero05',
			:grant_type => 'password',
			:security_token => 'luzvxCLqrFywA4tcq4GwD8w4',
			:client_id => '3MVG9sLbBxQYwWqsMePpk_o4w.BOkzVhkOH3KFVjKtXwK9QAKCbDkiNjnVdYCyXeCl8dSTxvKzBmp2oNFzCnj',
			:client_secret => '2025903504565848878'

			nope = client.query('select Id from ')

			
	end
end