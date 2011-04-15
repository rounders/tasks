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
	$('#new_task_form').hide();
	
	$('#new_task_link').live('click', function(event) {
		event.preventDefault();
		$('#new_task_form').show();

		$("#close_new_task_link").show();
		$("#task_description")[0].focus();

		$('#add-task').hide();
		toggle_delete_project_link();
	});
	
	$('#close_new_task_link').live('click',function () {  
		$('#new_task_form').hide();
		$('#close_new_task_link').hide();
		$('#add-task').show();
		toggle_delete_project_link();
		return false;  
	})  
	
	toggle_delete_project_link();
});

function toggle_delete_project_link() {
	if ( $('#active_tasks ul li').length > 0 ) {
		$('#delete-project').hide();
	} else {
		$('#delete-project').show();
	}
}

function remove_fields(link) {  
	$(link).prev("input[type=hidden]").val("1");  
	$(link).closest(".fields").hide(); 
}

