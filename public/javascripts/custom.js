window.onload = function(){
  $('.ui.dropdown').dropdown()

  $('.submit').click(function() {
    $(this).parent().submit();
  });
}

function firmInputToggle() {
    toggleElement($('#newProject input'))
    toggleElement($('#newProject'))
    toggleElement($('#newProject label'))
    toggleElement($('#projectSelect input'))
    toggleElement($('#projectSelect'))
    toggleElement($('#projectSelect label'))
}

function toggleElement(e) {
    if (e.is(':disabled')) {
        e.prop('disabled', false)
    } else {
        e.prop('disabled', true)
    }

    e.toggle()
}
