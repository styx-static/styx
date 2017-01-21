/* Enable disqus comments for a page, take a page as parameter

   Use either, page.disquID, page.rootPage.path or page.path
   
   Example:

     templates.services.disqus page

*/
env:
page:
/* For multipage pages
*/
let id = 
  if page ? disqusID
  then page.disqusID
  else if page ? rootPage
       then page.rootPage.path
       else page.path;
in
''
<div id="disqus_thread"></div>
<script>

/**
*  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
*  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables*/
var disqus_config = function () {
this.page.identifier = ${id};
};
(function() { // DON'T EDIT BELOW THIS LINE
var d = document, s = d.createElement('script');
s.src = '//styx-site.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
''
