$(document).ready(function(){
	$(".doctor-tab").first().addClass("active");
	$(".first").first().addClass("active");	
});

//this is hacky
function changeTrack(){
	var selected = $("#collection_audio option:selected").text();
	if(selected == "track_1"){
 	 $("audio").attr("src", "/assets/bensound-acousticbreeze.mp3");
	} else {
 	 $("audio").attr("src", "/asset/different_track");		
	}

};

