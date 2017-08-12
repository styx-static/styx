$(document).ready(function($) {
  $('.level-bar-inner').css('width', '0');

  $('.level-bar-inner').each(function() {
      var itemWidth = $(this).data('level');
      $(this).animate({
         width: itemWidth
      }, 800);
  });
});
