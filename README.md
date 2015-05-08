Custom Clinic Deployment Considerations

Welcome to Context Media's Custom Clinic Portal.  You are about to take a wonderful journey down the path of being able
to quickly create videos for a clinic at a moments notice.  If you are the brave soul in charge of deploying this application
there are a few considerations you should keep in mind.  

MAJOR DEPENDECIES (app will not work if these aren't installed on the server)
	-FFmpeg
	-ImageMagick
	-Redis
	-MySQL

	The app also depends on many gems that are in the gemfile and should be bundled before each build.

Security Considerations
	This app will make API calls to Salesforce to verify clinic existance.   Videos that are created are then stored in 
	an amazon S3 bucket.  Lastly, the app makes another SF API call to create a case (this case is tied into the account for the clinic) and put the file location url in the case for easy downloading.   

	Video contents simply consist of public information about the doctors, office hours, and messages that the offices want their patinets to know (although this could be expanded).

	Questions? Contact Shomari Ewing.
