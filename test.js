var cb = function() { console.log('cb'); }
$(document).on('everyInsert', 'div', cb);
$('body').append('<div class="test" />');
$(document).off('everyInsert', 'div', cb);