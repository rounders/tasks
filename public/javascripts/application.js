// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$('input[type=checkbox]').live('click', function () {
	task_id = this.value;

	
	$.ajax({
		type: "POST",
		url: '/toggle_task_completed/'+task_id,
		data: { _method:'PUT'},
		dataType: 'script',
		success: function(){
			// alert("olo");
		},
		error: function(xhr, textStatus, errorThrown) {
			$('#flash').html("<p class='alert'>The server reported an error: " +xhr.responseText+ "</p>");
		}
	});

});

$(function () {  
  $('#close_new_task_link').live('click',function () {  
	$('#new_task_form').empty();
	$('#close_new_task_link').hide();
	$('#new_task_link').show();
	return false;  
	
   })  
});

function remove_fields(link) {  
	$(link).prev("input[type=hidden]").val("1");  
	$(link).closest(".fields").hide(); 
}

