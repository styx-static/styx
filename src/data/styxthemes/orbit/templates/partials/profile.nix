{ conf, ... }:
''
<div class="profile-container">
  <img class="profile" src="${conf.siteUrl}/assets/images/${conf.theme.profile.image}" alt="${conf.theme.profile.name}" />
  <h1 class="name">${conf.theme.profile.name}</h1>
  <h3 class="tagline">${conf.theme.profile.tagline}</h3>
</div><!--//profile-container-->
''
