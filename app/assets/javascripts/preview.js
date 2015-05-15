function previewFile(index) {
  var preview = document.querySelector('#image_'+ index);
  var file    = document.querySelector('#site_doctors_attributes_'+index+'_image').files[0];
  var reader  = new FileReader();

  reader.onloadend = function () {
    $('#image_'+index).show();
    preview.src = reader.result;

  }

  if (file) {
    reader.readAsDataURL(file);
  } else {
    preview.src = "";
  }
}