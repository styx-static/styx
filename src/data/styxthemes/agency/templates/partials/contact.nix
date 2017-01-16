{ conf, lib, ... }:
with lib;
optionalString (conf.theme.contact.enable)
''
<!-- Contact Section -->
<section id="contact">
  <div class="container">
    <div class="row">
      <div class="col-lg-12 text-center">
        <h2 class="section-heading">${conf.theme.contact.title}</h2>
        <h3 class="section-subheading text-muted">${conf.theme.contact.subtitle}</h3>
      </div>
    </div>
    <div class="row">
      <div class="col-lg-12">
        <form  action="//formspree.io/${conf.theme.contact.form.receiver}" method="POST" name="sentMessage" id="contactForm" novalidate>
          <div class="row">
            <div class="col-md-6">
              <div class="form-group">
                <input type="text" class="form-control" placeholder="${conf.theme.contact.form.name.text}" name="name" required data-validation-required-message="${conf.theme.contact.form.name.warning}">
                <p class="help-block text-danger"></p>
              </div>
              <div class="form-group">
                <input type="email" class="form-control" placeholder="${conf.theme.contact.form.email.text}" name="email" required data-validation-required-message="${conf.theme.contact.form.email.warning}">
                <p class="help-block text-danger"></p>
              </div>
              <div class="form-group">
                <input type="tel" class="form-control" placeholder="${conf.theme.contact.form.phone.text}" name="phone" required data-validation-required-message="${conf.theme.contact.form.phone.warning}">
                <p class="help-block text-danger"></p>
              </div>
            </div>
            <div class="col-md-6">
              <div class="form-group">
                <textarea class="form-control" placeholder="${conf.theme.contact.form.message.text}" name="message" required data-validation-required-message="${conf.theme.contact.form.message.warning}"></textarea>
                <p class="help-block text-danger"></p>
              </div>
            </div>
            <div class="clearfix"></div>
            <div class="col-lg-12 text-center">
              <div id="success"></div>
              <button type="submit" class="btn btn-xl">${conf.theme.contact.buttonText}</button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</section>
''
