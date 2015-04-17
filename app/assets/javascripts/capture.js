// $(document).ready(function(){
// 	$('#submit').mouseenter(function(){
// 		capture();
// 	});
// });


// //hovering over the submit button updates the preview to be sent to server.
// //preview is then captured and sent when user clicks submit.
// function capture(){
// 	html2canvas($('.preview-standard'), {
// 		onrendered: function (canvas) {
// 			$('#img_val').val(canvas.toDataURL("image/jpeg");
// 			var myImage = canvas.toDataURL("image/png")
// 			window.open(myImage);
// 		   // document.getElementById("form").submit();
// 		}
// 	});
// }

	




// html2canvas($('.preview-standard'), {
// 	onrendered: function (canvas) {
// 		var canvasImg = canvas.toDataURL("image.jpg";)
// 		$.ajax({
// 			type: "POST",
// 			url: "/inthere",
// 			data: {
// 				imgBase64: canvasImg
// 			}
// 		})
// 	}
// })