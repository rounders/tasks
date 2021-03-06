// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$('ul.tasks input[type=checkbox]').live('click', function () {
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
	$('#new_task').bind('ajax:error', function(xhr, status, error){
		$("#task_description")[0].focus();
		// errors = JSON.parse(status.responseText);
	});
	
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
	});
	
	$( ".sortable" ).sortable({
		handle: '.handle',  
		cursor: 'crosshair',
		axis: 'y',
		update: function(event, ui){
			project_id = $('ul#active-tasks-list').attr('data-project-id');
			element_index = ui.item.index();
			element_id = ui.item.attr('id');
			task_id = element_id.split("_",2)[1];
			$.ajax({
				type: 'post',
				data: {_method:'PUT', task:{'position_position':element_index}},
				url: '/projects/' + project_id + '/tasks/'+task_id+'.js'
			});
		}
	});
	$( ".sortable" ).disableSelection();

	
	toggle_delete_project_link();
	if ($('#new_task_form').attr('data-show-form') == "1") {
		$('#new_task_link').click();
	} 
	
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

