var cb = function() { console.log('cb'); };
$(document).on('everyinsert', 'div', cb);
$('body').append('<div class="test" />');
$(document).off('everyinsert', 'div', cb);

var cb = function() { console.log('cb'); };
$(document).on('everyinsert', 'div', { existing: false }, cb);
$('body').append('<div class="test" />');
$(document).off('everyinsert', 'div', cb);