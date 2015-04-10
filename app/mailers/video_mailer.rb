class VideoMailer < ApplicationMailer

	def sample_email(file)
		attachments["test.mp4"] = file.read
		mail(to: 'xeroshogun@gmail.com', subject: 'Your video clip')
	end
end
