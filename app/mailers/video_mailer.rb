class VideoMailer < ApplicationMailer

	def sample_email(file, user)
		attachments["video.mp4"] = file.read
		mail(to: user, subject: 'Your customized clinic video')
	end
end
