{ conf, templates, ... }:
block:
{
  content = ''
    <div class="profile-container">
    <img class="profile" src="${templates.url block.image}" alt="${block.name}" />
    <h1 class="name">${block.name}</h1>
    <h3 class="tagline">${block.tagline}</h3>
    </div><!--//profile-container-->
  '';
}
