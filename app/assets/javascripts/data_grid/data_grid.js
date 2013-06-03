function dataGridSetInnerHtml(id, ih) {
  var e = document.getElementById(id);
  e.innerHTML = ih;
}

function dataGridSetValue(id, v) {
  var e = document.getElementById(id);
  e.value = v;
}

function handleCalendarClose(cal, dom_id, form_id) {
  if (cal)
    cal.hide(); 
  
  var e = document.getElementById(dom_id);
  var es = document.getElementsByName(dom_id);
  for(var i=0;i<es.length;i++) {
    es[i].value = e.value;
  }
  
  if (form_id)
    document.getElementById(form_id).submit();
}

